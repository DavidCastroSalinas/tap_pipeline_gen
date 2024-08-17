# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------------
# Created By  : David Armando Castro Salinas david.castro@utem.cl
# Created Date: 2024/05/18
# version ='1.0'
# ---------------------------------------------------------------------------

import subprocess
import time
from datetime import datetime


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


# Ruta al archivo shell que deseas ejecutar
ruta_archivo_sh = "/home/dabits/proyectos/tap_pipeline_gen/Scripts/03_CODE_BASH.sh"
parametro1 = archivoSecuencia
parametro2 = archivoReferencia




def fechaSTR():
	now = datetime.now()
	return now.strftime("%Y%m%d%H%M%S")

print(f"inicio: {fechaSTR()}")
start_time = time.time()


# Ejecutar el archivo shell
try:
    # Utiliza el método run de subprocess para ejecutar el archivo shell
    subprocess.run([ruta_archivo_sh, parametro1, parametro2], check=True)
    print(f"El archivo shell {ruta_archivo_sh} se ejecuto correctamente.")
except subprocess.CalledProcessError as e:
    print(f"Ocurrio un error al ejecutar el archivo shell: {e}")


print(f"fin: {fechaSTR()}")
end_time = time.time()
print(f"Tiempo total de procesamiento: {end_time - start_time} segundos")