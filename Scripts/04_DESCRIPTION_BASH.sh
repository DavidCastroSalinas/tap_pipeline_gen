#!/bin/bash

#parametros de entrada
archivo_referencia=$1
archivo_csv=$2
archivo__resumen_csv=$3
varseq=""
idRegistro=""
echo "$1 $2  $3"

# Función para obtener el tiempo en milisegundos
get_time_ms() { 
  date +%s%3N 
}

# Función para registrar el tiempo inicial
tic() { 
  start_time=$(get_time_ms)
}

# Función para calcular y mostrar el tiempo transcurrido
toc() {
  end_time=$(get_time_ms) #en milisegundos
  elapsed=$((end_time - start_time)) #lo pasamos a segundos
  echo -e "\t$elapsed"
}

tocr() {
  end_time=$(get_time_ms) #en milisegundos
  elapsed=$((end_time - start_time)) #lo pasamos a segundos
  return $elapsed
}

tocconsola() {
  end_time=$(get_time_ms) #en milisegundos
  elapsed=$((end_time - start_time)) #lo pasamos a segundos
  echo -n -e "$elapsed\n"
}


echo -n -e "HEADER,LONGITUD,CANTIDAD_CG\n" >> $archivo_csv

secuencia=""
header=""
contador_secuencias=0

while IFS= read -r line; do
  if [[ $line == ">"* ]]; then
    
    if [ -n "$secuencia" ]; then
      longitud=$(echo -n "$secuencia" | wc -c)
      cantidad_CG=$(echo "$secuencia" | grep -o "CG" | wc -l)
      echo -n -e "$header,$longitud,$cantidad_CG\n" >> $archivo_csv
    fi
    header="$line"
    secuencia=""
     ((contador_secuencias++))
  else
    secuencia="$secuencia$line"
  fi
done < "$archivo_referencia"

echo -n -e "FILE,SECUENCIAS\n" >> $archivo__resumen_csv
echo -n -e "$archivo_referencia,$contador_secuencias\n" >> $archivo__resumen_csv
