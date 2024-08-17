#!/bin/bash

# Verificar que se hayan pasado dos parámetros
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 archivo_entrada archivo_salida"
    exit 1
fi

# Asignar parámetros a variables
archivo_entrada=$1
archivo_salida=$2

# Utilizar awk para procesar el archivo
awk 'BEGIN {ORS=""} {print}' "$archivo_entrada" > "$archivo_salida"
