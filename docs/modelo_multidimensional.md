\# Modelo multidimensional - Hito 8 - Grupo 9



\## 1. Measurement principal



El módulo utiliza el measurement:



```text

estadisticas\_equipo

```



Cada punto representa el estado de las estadísticas de un equipo dentro de un partido en un instante determinado.



\## 2. Tags



Los tags definidos son:



```text

partido\_id

equipo\_codigo

sede\_id

```



\### partido\_id



Identifica al partido del Fixture 2030.



Ejemplos:



```text

P001

P002

P003

```



Se utiliza como tag porque las consultas frecuentemente se filtran por partido.



\### equipo\_codigo



Identifica al equipo.



Ejemplos:



```text

AAA

AAB

AAC

```



Permite filtrar y comparar los dos equipos participantes de un partido.



\### sede\_id



Identifica la sede donde se disputa el encuentro.



Ejemplos:



```text

S001

S002

S003

```



Se conserva como dimensión para permitir consultas o comparaciones asociadas a una sede.



\## 3. Fields



\### posesion\_pct



Tipo:



```text

float

```



Semántica:



Porcentaje de posesión observado en un instante.



Agregación apropiada:



```text

mean()

```



No corresponde sumar porcentajes de diferentes instantes.



\### pases\_completados\_total



Tipo:



```text

integer

```



Semántica:



Contador acumulativo de pases completados durante el encuentro.



Agregación apropiada:



```text

last()

```



También podría utilizarse `max()` si se garantiza que el contador nunca disminuye.



No debe utilizarse `sum()` sobre todas las muestras porque se contarían repetidamente los valores acumulados.



\### tiros\_intervalo



Tipo:



```text

integer

```



Semántica:



Cantidad de tiros ocurridos durante el intervalo de captura.



Agregación apropiada:



```text

sum()

```



\### recuperaciones\_intervalo



Tipo:



```text

integer

```



Semántica:



Cantidad de recuperaciones ocurridas durante el intervalo.



Agregación apropiada:



```text

sum()

```



\## 4. Timestamp



Cada punto posee un timestamp expresado con precisión de milisegundos.



Ejemplo:



```text

1907175600000

```



La carga se ejecuta especificando:



```text

\--precision ms

```



\## 5. Line Protocol



Ejemplo de punto:



```text

estadisticas\_equipo,partido\_id=P001,equipo\_codigo=AAA,sede\_id=S001 posesion\_pct=49.85,pases\_completados\_total=0i,tiros\_intervalo=0i,recuperaciones\_intervalo=0i 1907175600000

```



La estructura separa:



```text

measurement

tags

fields

timestamp

```



\## 6. Identidad de una serie



Conceptualmente, las series quedan definidas mediante:



```text

measurement + tags

```



En este modelo:



```text

estadisticas\_equipo

\+

partido\_id

\+

equipo\_codigo

\+

sede\_id

```



El timestamp diferencia las observaciones que forman la evolución temporal de la serie.



\## 7. Tags versus fields



Se utilizan como tags únicamente dimensiones necesarias para localizar o segmentar consultas.



No se utilizan como tags:



\- timestamp;

\- porcentaje de posesión;

\- cantidad de pases;

\- tiros;

\- recuperaciones;

\- identificadores únicos por observación;

\- texto libre.



Esos valores presentan alta variación o representan medidas, por lo que incorporarlos como tags aumentaría la cardinalidad sin aportar valor a los patrones de acceso definidos.



\## 8. Measurement histórico



El downsampling genera:



```text

estadisticas\_equipo\_resumen\_1m

```



dentro del bucket:



```text

estadisticas\_historicas

```



Mantiene las mismas dimensiones, pero reduce la granularidad temporal de cinco segundos a un minuto.



La función aplicada depende de cada field:



```text

posesion\_pct              -> mean()

pases\_completados\_total   -> last()

tiros\_intervalo           -> sum()

recuperaciones\_intervalo  -> sum()

```

