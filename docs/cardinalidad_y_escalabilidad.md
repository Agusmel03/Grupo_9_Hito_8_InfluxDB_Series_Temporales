\# Cardinalidad y escalabilidad - Hito 8 - Grupo 9



\## 1. Dimensiones del modelo



El measurement principal utiliza los siguientes tags:



```text

partido\_id

equipo\_codigo

sede\_id

```



Estas dimensiones permiten localizar y comparar las series necesarias para los patrones de acceso del módulo.



\## 2. Cardinalidad esperada



Para el Fixture 2030 se consideran:



```text

96 partidos

64 equipos

12 sedes

```



Sin embargo, las tres dimensiones no varían de manera independiente.



Cada partido posee:



\- dos equipos participantes;

\- una única sede.



Por lo tanto, para las estadísticas por equipo el número esperado de combinaciones válidas es aproximadamente:



```text

96 partidos × 2 equipos = 192 series

```



La sede depende del partido y no multiplica libremente la cantidad de series.



\## 3. Cardinalidad de la muestra



La muestra funcional contiene cuatro partidos.



Cada partido tiene dos equipos:



```text

4 partidos × 2 equipos = 8 series

```



Cada serie posee:



```text

1080 puntos

```



correspondientes a una observación cada cinco segundos durante 90 minutos.



Por lo tanto:



```text

8 × 1080 = 8640 puntos

```



La validación ejecutada confirmó exactamente 8640 puntos.



\## 4. Distribución observada



La validación mostró:



```text

P001 AAA S001 -> 1080

P001 AAB S001 -> 1080



P002 AAA S002 -> 1080

P002 AAC S002 -> 1080



P003 AAA S003 -> 1080

P003 AAD S003 -> 1080



P004 AAB S004 -> 1080

P004 AAC S004 -> 1080

```



Esto confirma que la distribución real coincide con el modelo declarado.



\## 5. Atributos excluidos de tags



No se utilizan como tags:



\- timestamp;

\- posesion\_pct;

\- pases\_completados\_total;

\- tiros\_intervalo;

\- recuperaciones\_intervalo;

\- identificadores únicos por punto;

\- textos libres.



Estos atributos presentan alta variación o corresponden a valores observados.



Utilizarlos como tags incrementaría la cardinalidad sin mejorar los patrones de consulta prioritarios.



\## 6. Objetivo de 10M+ puntos



El Hito 8 plantea un objetivo de diseño superior a:



```text

10.000.000 de puntos

```



Para soportar ese escenario se implementó:



```text

scripts/generacion\_masiva.py

```



El generador recibe como parámetro la cantidad de puntos deseada.



Ejemplo:



```powershell

python .\\scripts\\generacion\_masiva.py --puntos 10000000 --salida data\\10\_millones.lp

```



El script escribe secuencialmente el Line Protocol en disco y no necesita mantener todos los puntos simultáneamente en memoria.



\## 7. Estrategia de carga masiva



Para una carga de 10M+ puntos no se propone enviar un único request de tamaño completo.



La estrategia recomendada consiste en:



```text

lotes aproximados de 50.000 a 100.000 puntos

```



Cada lote debe:



\- generarse con timestamps válidos;

\- escribirse utilizando Line Protocol;

\- registrar errores de escritura;

\- reintentarse en caso de fallo controlado;

\- contabilizar los puntos procesados;

\- validarse posteriormente.



En un escenario de mayor escala también podrían utilizarse varios productores con concurrencia controlada.



\## 8. Prueba local realizada



La prueba real se realizó con:



```text

100000 puntos

```



Tamaño del archivo generado:



```text

17584323 bytes

```



Resultado:



```text

Tiempo: 2.3678593 segundos

Throughput observado: 42232.24 puntos/segundo

```



La validación posterior confirmó:



```text

100000 puntos almacenados

```



\## 9. Hardware de prueba



La medición se realizó sobre:



```text

Intel(R) Core(TM) i9-9900K CPU @ 3.60GHz

8 núcleos físicos

16 procesadores lógicos

31,93 GB RAM

```



InfluxDB se ejecutó localmente mediante Docker Desktop.



\## 10. Interpretación del objetivo de 10M+



Los 10M+ puntos constituyen un objetivo de diseño y escalabilidad.



La prueba local no declara haber cargado 10 millones de puntos.



Se ejecutó y documentó una prueba real de 100.000 puntos y se implementó un mecanismo capaz de generar conjuntos mayores.



No se extrapola el throughput medido como una garantía para 10M, porque al aumentar el volumen pueden cambiar:



\- utilización de CPU;

\- consumo de memoria;

\- actividad de disco;

\- comportamiento de cachés;

\- compactación;

\- latencia;

\- throughput sostenido.



\## 11. Escalabilidad futura



Ante un crecimiento de fuentes, partidos o frecuencia de captura podrían incorporarse:



\- generación y escritura por lotes;

\- productores concurrentes;

\- control de reintentos;

\- backpressure;

\- separación entre ingestión y almacenamiento histórico;

\- downsampling más temprano;

\- políticas de retención diferenciadas;

\- reducción adicional de dimensiones indexadas.



La decisión de mantener solamente dimensiones de consulta como tags ayuda a evitar crecimiento innecesario de cardinalidad.

