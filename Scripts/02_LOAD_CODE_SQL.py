#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------------
# Created By  : David Armando Castro Salinas david.castro@utem.cl
# Created Date: 2024/05/18
# version ='1.0'
# ---------------------------------------------------------------------------


#####PARAMETROS
from datetime import datetime
import time
import os

####PARAMETRIZAMOS EL SISTEMA
import json
def leer_parametros(ruta_archivo):
    with open(ruta_archivo) as archivo:
        parametros = json.load(archivo)
    return parametros
#enddef

parametros = leer_parametros("/home/dabits/proyectos/tap_pipeline_gen/Scripts/config.json")    
    
archivoReferencia = parametros.get("archivoReferencia")
archivoSecuencia = parametros.get("archivoSecuencia")
particiones = 1 #parametros.get("particiones")    
####PARAMETRIZAMOS EL SISTEMA  


def fechaSTR():
	now = datetime.now()
	return now.strftime("%Y%m%d%H%M%S")

print(f"inicio: {fechaSTR()}")
start_time = time.time()

archivoSalidaCSV = "resultado_psSpark_SQL_"+fechaSTR() + ".csv"
archivoSalidaJSON= "resultado_psSpark_SQL_"+fechaSTR() + ".json"
num_particiones = particiones

#LIBRERIAS
from pyspark.sql.functions import collect_list, concat_ws
from pyspark.sql.types import *

# ACTIVAR PYSPARK
from pyspark.sql import SparkSession
# LIBRERIAS
from pyspark.sql.functions import collect_list, concat_ws
from pyspark.sql.types import *

spark = SparkSession.builder \
    .appName('Spark Genoma Process SQL') \
    .master('local[*]') \
    .getOrCreate()

# FUNCIONES QUE VAMOS A OCUPAR
def leerArchivoALinea2(nombreArchivo):
    df = spark.read.csv(nombreArchivo, header=True)
    #rdd = df.rdd
    df = df.withColumnRenamed(">Genoma de Referencia", "referencia")
    # Agrupar todas las filas en una sola colección
    collected_list_df = df.agg(collect_list("referencia").alias("collected_list"))

    # Concatenar todas las filas en una sola cadena
    result_df = collected_list_df.withColumn("referencia", concat_ws("", "collected_list"))

    # Seleccionar solo el campo concatenado
    final_result_df = result_df.select("referencia")

    return final_result_df.repartition(num_particiones)
# enddef


def leerArchivoALinea(nombreArchivo):
    df = spark.read.csv(nombreArchivo, header=False)
    df = df.withColumnRenamed("_c0", "referencia")
    return df.repartition(num_particiones)
# enddef


def leerArchivoSecuencia(nombreArchivo):
    df = spark.read.csv(nombreArchivo, header=False)
    df = df.withColumnRenamed("_c0", "secuencia")
    return df.repartition(num_particiones)
# enddef


#############CARGA DE DATOS
df = leerArchivoALinea(archivoReferencia)
print(df.count())
df.show(10)



##CODIGO COPIADO
# Función para convertir el RDD en pares de (header, sequence)
def parse_fasta(rdd):
    fasta_entries = []
    current_header = None
    current_sequence = []

    for line in rdd.collect():
        if line.startswith('>'):
            if current_header is not None:
                fasta_entries.append((current_header, ''.join(current_sequence)))
            current_header = line[1:]  # Eliminar el '>'
            current_sequence = []
        else:
            current_sequence.append(line)

    # Añadir el último par (header, sequence)
    if current_header is not None:
        fasta_entries.append((current_header, ''.join(current_sequence)))

    return fasta_entries
    
# Leer el archivo FASTA en RDD
fasta_rdd = spark.sparkContext.textFile(archivoSecuencia)    
    
# Parsear el RDD
parsed_fasta = parse_fasta(fasta_rdd)

# Convertir a DataFrame
dfSecuencia = spark.createDataFrame(parsed_fasta, ["Header", "Sequence"])

##FIN CODIGO COPIADO



#####PREPARACION DE TABLAS PARA PROCESAR SQL
# Create temporary table 
df.createOrReplaceTempView("referencia_table")
dfSecuencia.createOrReplaceTempView("secuencia_table")
dfSecuencia.show(10)

# PROCESAMIENTO VIA SQL DOS CAMPOS DESDE LAS FILAS
# SE ASUME QUE LOS DATOS SON 1 a 1
df_seq = spark.sql(
    "SELECT s.Header nombre, SUBSTRING(s.Header, INSTR(s.Header, ' ') + 1) AS id_reads," 
    " s.Sequence glosa, length(s.Sequence) tamano FROM secuencia_table s")


# CREAMOS EL MASTER PARA OPERAR EN SQL
df_seq.createOrReplaceTempView("sencuencia_master_table")
df_seq.show(10)

# COMPLEMENTAMOS EL MASTER CON LOS QUE SON ENCONTRADOS, Y OBTENEMOS LA POSICIÓN
df_resultado = spark.sql(
    "SELECT s.id_reads READ, s.tamano TAMANO, INSTR(r.referencia , substring(s.glosa,0,10)) AS POSICION "
    "   FROM sencuencia_master_table s, referencia_table r "
    "       WHERE r.referencia like CONCAT('%', substring(s.glosa,0,10), '%') ")    

#df_resultado = spark.sql(
#    "SELECT s.id_reads READ, s.tamano TAMANO, INSTR(r.referencia , s.glosa) AS POSICION "
#    "   FROM sencuencia_master_table s, referencia_table r "
#    "       WHERE r.referencia like CONCAT('%', s.glosa, '%') ")


df_pd  = df_resultado.toPandas()
df_pd.to_csv('02_data.csv', index=False)


# GENERAMOS UN ARCHIVO CSV CON LOS DATOS
if df_resultado is not None:
    #df_resultado.printSchema()
    #df_resultado.show()
    #df_resultado.coalesce(1).write.option("header", True).option("delimiter", "\t").csv(archivoSalidaCSV)
    #df.write.csv(archivoSalidaCSV, header=True)
    
    print("csv")
else: 
    print("Error no se pudo crear el archivo CSV")

df_resultado = df_resultado.repartition(num_particiones)

df_resultado.count()
print(df_resultado.count())
df_resultado.show(10)


# GENERAMOS UN ARCHIVO JSON CON LOS DATOS
if df_resultado is not None:
    #df_resultado.printSchema()
    #df_resultado.show()
    #df_resultado.write.option("header", True).json(archivoSalidaJSON)
    print("json")
else:
    print("Error no se pudo crear el archivo CSV")


print(f"fin: {fechaSTR()}")
end_time = time.time()
print(f"Tiempo total de procesamiento: {end_time - start_time} segundos")
