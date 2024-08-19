# Proyecto de Análisis de Secuencias Genómicas

## Descripción del Proyecto

Este proyecto tiene como objetivo analizar y visualizar datos genómicos a partir de sets de datos proporcionados en formato CSV. El pipeline de análisis incluye la generación de gráficos que muestran relaciones clave entre diversas métricas, como longitud, posición, y tiempo, permitiendo una comprensión más profunda de las características genómicas. Este pipeline está desarrollado en Python, pySpark, Bash y R.
## Contexto
Las investigaciones biomédicas modernas se nutren fuertemente de herramientas computacionales para el procesamiento de grandes cantidades de información, y a esta disciplina se le denomina Bioinformática, y es en esta disciplina que encontramos técnicas computacionales avanzadas que permiten abordar problemas complejos de la biología y ciencias de la salud y dentro de sus principales desafíos se encuentra el poder procesar grandes volúmenes de información como las secuencias de ADN, ARN y proteínas, fijándose principalmente en sus variaciones genéticas y comparación de distintas secuencias obtenidas experimentalmente con alguno de los genomas existentes. Otra de las áreas que requiere grandes cantidades de datos para sus análisis es la física experimental, y uno de sus usos es el procesamiento y análisis del comportamiento a escala atómica de combinaciones posibles y sus condiciones límite.

## Instrucciones de Uso

### Requisitos Previos

- [Java](https://www.java.org/) versión 21 o superior
- [Python](https://www.python.org/) versión 3.12.4 o superior
- [R](https://www.r-project.org/) versión 3.6 o superior
- Paquetes de R necesarios: `ggplot2` (opcional si se desean gráficos más avanzados)

### Pasos para Ejecutar el Pipeline

1. **Clonar el repositorio**:
    ```bash
    git clone https://github.com/DavidCastroSalinas/tap_pipeline_gen.git
    cd tap_pipeline_gen
    ```

2. **Preparar el entorno**:
   Asegúrate de que Conda esté instalado en tu sistema.
   Genera un nuevo entorno Conda (proponemos el nombre de tap):   
    ```bash
       conda create -n tap python=3.7 
    ```
    Luego activa el entorno:
    ```bash
       conda activate tab 
    ```
   Instala pySpark: 
   
   Asegúrate de que R esté instalado en tu sistema. Puedes instalar los paquetes necesarios ejecutando el siguiente comando en la consola de R:
    ```bash
    sudo apt -y install r-base
    sudo apt install pandoc
    sudo apt install texlive-latex-extra 
    sudo apt install texlive-lang-all
    ```

4. **Ejecutar el script de análisis**:
   Navega al directorio donde se encuentra el archivo mail.nf. Luego, ejecuta el script con:
    ```bash    
    nextflow main.nf
    ```

5. **Interpretación de los Resultados**:
   - El script generará un archivo PDF que contiene gráficos de dispersión muestran la relación entre diferentes variables del set de datos.
   - Los archivos PDFs se guardarán en el directorio /Reports.

### Estructura de Archivos

- `main.f`: Script de netflow que contiene la procesos que serán ejecutados en el pipeline.
- `Scripts/`: Directorio donde se almacenan los scripts que son parte del pipeline.
- `Data/`: Directorio que contiene los archivos CSV con los datos de entrada.
- `Results/`: Directorio donde se almacenan los archivos csv generados.
- `Reports/`: Directorio donde se almacenan los archivos PDF generados.

## Autor

- **Nombre del Autor**: David Armando Castro Salinas
- **Correo Electrónico**: david.castro@utem.cl

## Afiliación

- **Institución**: Universidad Tecnológica Metropolitana
- **Departamento**: Departamento de Informática
