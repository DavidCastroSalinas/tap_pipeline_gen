#Proceso de creaci�n carpeta
dirdest="./Data/"
if [ ! -d $dirdest ]
then
  mkdir $dirdest
else 
  cd $dirdest 
  rm *.fasta.*
  cd ..
fi


dirdest="./Results/"
if [ ! -d $dirdest ]
then
  mkdir $dirdest
fi


dirdest="./Reports/"
if [ ! -d $dirdest ]
then
  mkdir $dirdest
fi


