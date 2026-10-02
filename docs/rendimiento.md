\# Rendimiento y pruebas - Hito 8 - Grupo 9



\## 1. Ambiente utilizado



Fecha de prueba:



```text

01/10/2026

```



Imagen Docker:



```text

influxdb:latest

```



Versión observada:



```text

InfluxDB v2.9.1

```



La versión fue obtenida directamente desde el contenedor utilizado durante la prueba.



\## 2. Hardware



Procesador:



```text

Intel(R) Core(TM) i9-9900K CPU @ 3.60GHz

```



Recursos:



```text

8 núcleos

16 procesadores lógicos

31,93 GB RAM

```



El ambiente se ejecutó localmente mediante Docker Desktop.



\## 3. Carga funcional



La muestra funcional contiene:



```text

8640 puntos

```



Distribuidos en:



```text

4 partidos

2 equipos por partido

1080 puntos por equipo

```



La validación posterior a la carga devolvió:



```text

8640

```



\## 4. Distribución



Cada serie de la muestra contiene:



```text

1080 puntos

```



Se validaron ocho combinaciones partido/equipo.



El total esperado y observado fue:



```text

8 × 1080 = 8640

```



\## 5. Prueba de carga



Para medir la capacidad de ingestión local se generó:



```text

100000 puntos

```



mediante:



```text

scripts/generacion\_masiva.py

```



Archivo generado:



```text

benchmark\_100k.lp

```



Tamaño:



```text

17584323 bytes

```



\## 6. Método de medición



Se utilizó PowerShell:



```text

Measure-Command

```



para medir la ejecución de:



```text

influx write

```



Los puntos fueron escritos en un bucket independiente:



```text

estadisticas\_benchmark

```



con precisión:



```text

ms

```



\## 7. Resultado



Tiempo observado:



```text

2.3678593 segundos

```



Puntos enviados:



```text

100000

```



Throughput calculado:



```text

42232.24 puntos por segundo

```



La consulta de validación posterior confirmó:



```text

100000 puntos efectivamente almacenados

```



\## 8. Interpretación



La prueba demuestra que el ambiente utilizado pudo almacenar 100.000 puntos a aproximadamente 42.232 puntos por segundo durante esta ejecución particular.



La cifra no debe interpretarse como garantía de producción ni como throughput sostenido para cualquier volumen.



\## 9. Limitaciones



La prueba se realizó:



\- sobre una única computadora;

\- utilizando Docker Desktop;

\- contra una única instancia de InfluxDB;

\- mediante un archivo local;

\- sin latencia de red externa;

\- con un único escritor;

\- sin concurrencia de múltiples fuentes.



Al aumentar el volumen o duración de la prueba podrían cambiar los resultados.



\## 10. Objetivo de 10M+



El proyecto incluye un generador parametrizable capaz de producir archivos con más de 10M de puntos.



Sin embargo, la medición efectivamente realizada corresponde a 100.000 puntos.



Esta distinción permite documentar de manera reproducible:



```text

objetivo de diseño

vs.

volumen realmente probado

```



sin presentar cifras no medidas como resultados reales.

