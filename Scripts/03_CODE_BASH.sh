#!/bin/bash

#parametros de entrada
archivo_referencia=$1
archivo_secuencia=$2
archivo_csv=$3
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


echo -n -e "ID,LONGITUD,POSICION,TIEMPO" >> $archivo_csv

#extraer la secuencia o segmento de secuencia para buscarla
while IFS= read -r linea; do
  #echo "$linea $archivo_referencia"
  varseq="$linea"  
    if [[ $varseq == '>'* ]]; then
      tic #inicio de toma del tiempo
      ##TRAEMOS EL ID DE LA SECUENCIA
      # Usar awk para extraer el texto después del signo igual
      idRegistro=$(echo "$varseq" | awk -F ' ' '{print $1}')
             
   else 
      if grep -q "$varseq" "$archivo_secuencia"; then
           
          #######Ahora comprobaremos en qué posición esta la línea      
          # Usar awk para buscar la cadena y mostrar la posición
          posicion=$( awk -v texto="$varseq" '
          {
              posicion = index($0, texto)
              if (posicion > 0) {
                printf "%d", NR 
                exit # para mostrar solo la primera coincidencia
              }
          }' "$archivo_referencia") 
          
          longitud=$(echo "$varseq" | awk '{ print length }')
          
          echo -n -e "$idRegistro,$longitud,$posicion," >> $archivo_csv
          tocconsola >> $archivo_csv
          ###FIN COMPROBACION
                    
          #toc
      fi
   fi
done < "$archivo_referencia"
echo "finalizado"