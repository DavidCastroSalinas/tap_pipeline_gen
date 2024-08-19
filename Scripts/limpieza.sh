archivo="input1.fasta_procesar"    
if [ -f "$archivo" ]; then
  rm "$archivo"
  echo "Archivo eliminado: $archivo"
else
  echo "El archivo no existe: $archivo"
fi

archivo="input2.fasta_procesar"    
if [ -f "$archivo" ]; then
  rm "$archivo"
  echo "Archivo eliminado: $archivo"
else
  echo "El archivo no existe: $archivo"
fi


archivo="input1.fasta"    
if [ -f "$archivo" ]; then
  bash ./Scripts/procesarLineas.sh "$archivo  $archivo_procesar"
  echo "Archivo procesado: $archivo"
else
  echo "El archivo no existe: $archivo"
fi

archivo="input2.fasta"    
if [ -f "$archivo" ]; then
  bash ./Scripts/procesarLineas.sh "$archivo  $archivo_procesar"
  echo "Archivo procesado: $archivo"
else
  echo "El archivo no existe: $archivo"
fi