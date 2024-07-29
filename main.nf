#!/usr/bin/env nextflow

params.range = 100
params.path = "/home/dabits/proyectos/tap_pipeline_gen"
params.proceso = 1

process configuracionInicialTask {
    
shell:
    '''
    #!/usr/bin/bash
    cd !{params.path}
    bash ./Scripts/configuracionInicial.sh    
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

process calculoBashTask {
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




/*
 * A trivial Perl script that produces a list of number pairs
 */
process calculoPySparkTask {
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
    configuracionInicialTask | descargaDataTask | calculoBashTask | calculoPySparkTask | generacionGraficospyTask | view
}
