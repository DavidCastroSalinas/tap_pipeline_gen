#!/usr/bin/env nextflow

params.range = 100
params.path = "/home/dabits/proyectos/tap_pipeline_gen"
params.path_scripts =  params.path + "/Scripts" 
params.path_results =  params.path + "/Results"
params.path_reports =  params.path + "/Reports"
params.path_data =     params.path + "/Data"
params.file_refencia = "input1.fasta"
params.file_secuencia= "input2.fasta"

params.proceso = "date +%Y%m%d_%H%M%S".execute().text.trim()

process configuracionInicialTask {
    
shell:
    '''
    #!/usr/bin/bash
    bash !{params.path_scripts}/configuracionInicial.sh    
    '''

output:
    stdout      
}

process descargaDataTask {
input:
    stdin
        
shell:
    '''
    #!/usr/bin/bash
    bash !{params.path_scripts}/descargaData.sh    
    '''
    
output:
    stdout       
}


process limpiezaDatosTask {
input:
    stdin
    
shell:
    '''
    #!/usr/bin/bash
    cd !{params.path}
    cd Data

    archivoP1="input1.fasta_preprocesado"    
    if [ -f "$archivoP1" ]; then
      rm "$archivoP1"
      echo "Archivo eliminado: $archivoP1"
    else
      echo "El archivo no existe: $archivoP1"
    fi
    
    archivoP2="input2.fasta_preprocesado"    
    if [ -f "$archivoP2" ]; then
      rm "$archivoP2"
      echo "Archivo eliminado: $archivoP2"
    else
      echo "El archivo no existe: $archivoP2"
    fi
    
    
    cd !{params.path}
    cd Data
    
    archivoF1="input1.fasta"    
    if [ -f "$archivoF1" ]; then
      bash ../Scripts/procesarLineas.sh $archivoF1  $archivoP1
      echo "Archivo procesado: $archivoF1"
    else
      echo "El archivo no existe: $archivoF1"
    fi

    cd !{params.path}
    cd Data

    
    archivoF2="input2.fasta"    
    if [ -f "$archivoF2" ]; then
      bash ../Scripts/procesarLineas.sh $archivoF2  $archivoP2
      echo "Archivo procesado: $archivoF2"
    else
      echo "El archivo no existe: $archivoF2"
    fi
    
    '''
output:
    stdout    
}


process calculoSPARKTask {
input:
    stdin
    
shell:
    '''
    python !{params.path_scripts}/01_LOAD_CODE_SPARK.py
    '''

output:
    stdout

}

process calculoPyStackSQLTask {
input:
    stdin
    
shell:
    '''
    cd "!{params.path_scripts}"
    python !{params.path_scripts}/02_LOAD_CODE_SQL.py "!{params.path_scripts}"
    
    archivo="!{params.path_scripts}/02_data.csv"
    if [ -f "$archivo" ]; then      
      mv "$archivo" "!{params.path_results}/!{params.proceso}_02_data.csv"
      echo "Archivo movido: $archivo"
    else
      echo "El archivo no existe: $archivo"
    fi
    
    '''
output:
    stdout

}




process calculoBashTask {
input:
    stdin
    
shell:
    '''
    cd "!{params.path_scripts}"
    python "!{params.path_scripts}/03_LOAD_BASH.py" "!{params.path_scripts}"
    
    archivo="!{params.path_scripts}/03_data.csv"
    if [ -f "$archivo" ]; then      
      mv "$archivo" "!{params.path_results}/!{params.proceso}_03_data.csv"
      echo "Archivo movido: $archivo"
    else
      echo "El archivo no existe: $archivo"
    fi
    
    '''

output:
    stdout

}



process descripcionTask {
input:
    stdin
    
shell:
    '''
    cd "!{params.path_scripts}"
    bash "!{params.path_scripts}/04_DESCRIPTION_BASH.sh" "!{params.path_data}/!{params.file_secuencia}" "!{params.path_results}/04_DATA_!{params.proceso}.csv"  "!{params.path_results}/04_RESUM_!{params.proceso}.csv"  
    
    '''
    
output:
    stdout

}

process generaReporteTask {
input:
    stdin
    
shell:
    '''
    cd "!{params.path_scripts}"
    
    R -e "rmarkdown::render('!{params.path_scripts}/reporte_utf8.Rmd', params=list(id_proceso='!{params.proceso}'))"
              
    archivo="!{params.path_scripts}/reporte_utf8.pdf"
    if [ -f "$archivo" ]; then      
        mv "!{params.path_scripts}/reporte_utf8.pdf" "!{params.path_reports}/reporte_!{params.proceso}.pdf"
        echo "Archivo movido: $archivo"
    else
        echo "El archivo no existe: $archivo"
    fi
      
    '''

output:
    stdout

}



workflow {
    configuracionInicialTask | 
    descargaDataTask | 
    descripcionTask |
    limpiezaDatosTask | 
    calculoBashTask | 
    calculoPyStackSQLTask |     
    generaReporteTask | view
}
