# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------------
# Created By  : David Armando Castro Salinas david.castro@utem.cl
# Created Date: 2024/05/18
# version ='1.0'
# ---------------------------------------------------------------------------


##### Librerías
from pyspark.sql.functions import substring
from pyspark.sql.functions import col,regexp_extract,split,udf, regexp_replace, collect_list, concat_ws
import re
from pyspark.sql.functions import regexp_replace
from pyspark.sql import functions as F
from pyspark.sql import SparkSession
from pyspark.sql.types import *
import zipfile
import os
import pandas as pd
import os
import json
import csv
from ttictoc import tic,toc
from datetime import datetime

import time

def fechaSTR():
	now = datetime.now()
	return now.strftime("%Y%m%d%H%M%S")
 

####PARAMETRIZAMOS EL SISTEMA
import json
def leer_parametros(ruta_archivo):
    with open(ruta_archivo) as archivo:
        parametros = json.load(archivo)
    return parametros

parametros = leer_parametros("config.json")    
    
archivoReferencia = parametros.get("archivoReferencia")
archivoSecuencia = parametros.get("archivoSecuencia")
particiones = parametros.get("particiones")    
####PARAMETRIZAMOS EL SISTEMA    

print(f"inicio: {fechaSTR()}")
start_time = time.time()


num_particiones = particiones

###########################################Funciones
 
fecha = fechaSTR() 

def log(_filename, _date, _type, _read, _length, _position, _timeprocess, _sequence):
    new_entry = {
        'date': _date,
        'read': _read,
        'type': _type,
        'length': _length,
        'position': _position,
        'timeprocess': _timeprocess,
        'sequence': _sequence
    }

    try:
        with open(_filename, 'r') as file:
            data = json.load(file)
    except FileNotFoundError:
        data = []


    # Agregar la nueva entrada
    data.append(new_entry)

    # Escribir el contenido actualizado de vuelta al archivo
    with open(_filename, 'w') as file:
        json.dump(data, file, indent=4)

#enddef


def logCSV(nombre_archivo="log.csv", mode='w', newline='', datos=''):
        
  with open(nombre_archivo, mode='w', newline='') as archivo:
      escritor_csv = csv.writer(archivo, delimiter='\t')
      escritor_csv.writerows(datos)        
#enddef


def buscarSequencia(_referencia, _secuenciaBuscada):
    posicionEnReferencia = _referencia.find(_secuenciaBuscada)
    return posicionEnReferencia
#end def


def find_position(search_text, target):
    return target.find(search_text)
# enddef



def buscarSequenciaUDF(_df, _columna, _cadenaBuscada):
    # Definir la UDF para encontrar la posición del texto

    # Registrar la UDF
    find_position_udf = udf(lambda target: find_position(_cadenaBuscada, target), IntegerType())

    # Aplicar la UDF para encontrar la posición del texto en el DataFrame
    result_df = _df.withColumn("position", find_position_udf(_df[_columna]))
    posicion = result_df.collect()[0][1]
    return posicion
# enddef


def procesarLecturas(_referencia, _reads):
    lecturas = _reads.count()
    print("Tamaño del vector de secuencias buscadas:", lecturas)
    lectura = ""
    textCSV = [ ["lectura", "posicionEncontrada", "tamano", "tiempo"] ]

    for linea in range(lecturas):  # recorremos todas las líneas del archivo
        secuenciaProcesar = _reads.collect()[linea][0]

        # secuenciaProcesar = ','.join(str(x) for x in _reads[linea]) #pasamos de numpy to string
        print(secuenciaProcesar)
        # print(type(secuenciaProcesar))
        columna = "referencia"
        if secuenciaProcesar.startswith('>'):  # salto los encabezados            
            #glosa, lectura = secuenciaProcesar.split('=')
            resultadoSplit = secuenciaProcesar.split('=')
            if(len(resultadoSplit)>1):
              glosa = resultadoSplit(0)
              lectura = resultadoSplit(1)
            else:
              glosa = resultadoSplit
              
            
        else:  # en este caso leemos una nueva secuencia
            # posicionEncontrada = buscarSequencia(_referencia, secuenciaProcesar)
            tic()
            posicionEncontrada = buscarSequenciaUDF(_referencia, columna, secuenciaProcesar)
            
            tiempoToc = toc() 
             
            if(posicionEncontrada != -1):
              nueva_linea = [lectura, posicionEncontrada, len(secuenciaProcesar), tiempoToc]
              textCSV.append(nueva_linea)
              print(f'{lectura}\t{posicionEncontrada}\t{len(secuenciaProcesar)}\t{tiempoToc}')
            #endif                        
            
            # posicionEncontrada = -1
            #print(f'Lectura: {lectura} posicion: {posicionEncontrada}  tamaño Secuencia: {len(secuenciaProcesar)} secuencia: {secuenciaProcesar}')
            #print(f'Lectura: {lectura} posicion: {posicionEncontrada}  tamaño Secuencia: {len(secuenciaProcesar)} tiempo:{tiempoToc}')
            
        #endif        
      #endfor
    logCSV("log-spark-"+fecha+".csv", 'w', '\n', textCSV);
    log("log-spark-"+fecha+".json", fecha, 'pyspark', lectura, len(secuenciaProcesar), posicionEncontrada, tiempoToc, "")

# enddef
# procesarLecturas(dfReferencia, dfSecuencia)


def leerArchivoALinea2(nombreArchivo='Genoma_referencia.fasta'):
    df = spark.read.csv(nombreArchivo, header=True)
    rdd = df.rdd
    # rdd.collect()[0][0] #mostrar primer registro

    # Agrupar todas las filas en una sola colección
    collected_list_df = df.agg(collect_list(">Genoma de Referencia").alias("collected_list"))

    # Concatenar todas las filas en una sola cadena
    result_df = collected_list_df.withColumn(">Genoma de Referencia", concat_ws("", "collected_list"))

    # Seleccionar solo el campo concatenado
    final_result_df = result_df.select(">Genoma de Referencia")

    # Mostrar el contenido del nuevo DataFrame
    # final_result_df.show(10)

    # print(final_result_df.collect()[0][0][0:2300])
    return final_result_df
#enddef


def leerArchivoALinea(nombreArchivo= 'Genoma_referencia.fasta'):
    df = spark.read.csv(nombreArchivo, header=False)
    df = df.withColumnRenamed("_c0", "referencia")
    return df.repartition(num_particiones)
#enddef

def leerArchivoSecuencia(nombreArchivo= 'Genoma_referencia.fasta'):
    df = spark.read.csv(nombreArchivo, header=False)
    df = df.withColumnRenamed("_c0", "secuencia")
    return df.repartition(num_particiones)
#enddef



################################MAIN

spark = SparkSession.builder\
        .appName('Spark Genoma Process')\
        .master('local[*]')\
        .getOrCreate()


dfReferencia = leerArchivoALinea(archivoReferencia)
dfSecuencia  = leerArchivoSecuencia(archivoSecuencia)


procesarLecturas(dfReferencia, dfSecuencia)

print(f"fin: {fechaSTR()}")
end_time = time.time()
print(f"Tiempo total de procesamiento: {end_time - start_time} segundos")

