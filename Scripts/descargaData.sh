
cd ../Data/


archivo="input1.fasta"
if [ -e "$archivo" ]; then
    
    echo "El archivo $archivo existe."
else
    wget  https://raw.githubusercontent.com/amoyabeltran/varios/main/input1.fasta
    echo "El archivo $archivo no existe."
fi

archivo="input2.fasta"
if [ -e "$archivo" ]; then
    echo "El archivo $archivo existe."
else
    wget  https://raw.githubusercontent.com/amoyabeltran/varios/main/input2.fasta
    echo "El archivo $archivo no existe."
fi

cd .. 

