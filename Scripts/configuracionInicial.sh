
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