#!/usr/bin/env nextflow

params.range = 100
params.path = "/home/dabits/proyectos/tap_pipeline_gen"
params.proceso = 1

process configuracionInicialTask {
    
shell:
    '''
    #!/usr/bin/bash
    cd !{params.path}
    #bash ./Scripts/configuracionInicial.sh    
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
    cd !{params.path}
    bash ./Scripts/descargaData.sh    
    '''
    
output:
    stdout       
}

process calculoBashTask2 {
input:
    stdin
    
shell:
    '''
    #!/usr/bin/bash
    echo "calculando"
    '''
output:
    stdout    
}




process calculoSPARKTask {
input:
    stdin
    
shell:
    '''
    cd !{params.path}/Scripts
    python 01_LOAD_CODE_SPARK.py
    '''

output:
    stdout

}

process calculoSQLTask {
input:
    stdin
    
shell:
    '''
    cd !{params.path}/Scripts
    python 02_LOAD_CODE_SQL.py
    '''

output:
    stdout

}



process calculoBashTask {
input:
    stdin
    
shell:
    '''
    cd !{params.path}/Scripts
    python 03_LOAD_BASH.py
    '''

output:
    stdout

}


process generaReporteTask {
input:
    stdin
    
shell:
    '''
    cd !{params.path}/Scripts
     R -e "rmarkdown::render('reporte_utf8.Rmd')"
     mv reporte_utf8.pdf ../Results/reporte_$(date +'%d%m%Y_%H%M').pdf 
    '''

output:
    stdout

}


/*
 * A trivial Perl script that produces a list of number pairs
 */
process calculoPySparkTask_Eliminiar {
input:
    stdin
    
output:
    stdout

    shell:
    '''
    #!/usr/bin/env perl
    use strict;
    use warnings;

    my $count;
    my $range = !{params.range};
    for ($count = 0; $count < 10; $count++) {
        print rand($range) . ', ' . rand($range) . "\n";
    }
    '''
}


/*
 * A Python script which parses the output of the previous script
 */
process generacionGraficospyTask {
    input:
    stdin

    output:
    stdout

    """
    #!/usr/bin/env python3
    import sys

    x = 0
    y = 0
    lines = 0
    for line in sys.stdin:
        items = line.strip().split(",")
        x += float(items[0])
        y += float(items[1])
        lines += 1

    print("avg: %s - %s" % ( x/lines, y/lines ))
    """
}

workflow {
    configuracionInicialTask | descargaDataTask | calculoBashTask | calculoSQLTask | generaReporteTask | view
}
