# Modelo multidimensional - Hito 8 - Grupo 9



## 1. Measurement principal



El módulo utiliza el measurement:



```text

estadisticas_equipo

```



Cada punto representa el estado de las estadísticas de un equipo dentro de un partido en un instante determinado.



## 2. Tags



Los tags definidos son:



```text

partido_id

equipo_codigo

sede_id

```



### partido_id



Identifica al partido del Fixture 2030.



Ejemplos:



```text

P001

P002

P003

```



Se utiliza como tag porque las consultas frecuentemente se filtran por partido.



### equipo_codigo



Identifica al equipo.



Ejemplos:



```text

AAA

AAB

AAC

```



Permite filtrar y comparar los dos equipos participantes de un partido.



### sede_id



Identifica la sede donde se disputa el encuentro.



Ejemplos:



```text

S001

S002

S003

```



Se conserva como dimensión para permitir consultas o comparaciones asociadas a una sede.



## 3. Fields



### posesion_pct



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



### pases_completados_total



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



### tiros_intervalo



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



### recuperaciones_intervalo



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



## 4. Timestamp



Cada punto posee un timestamp expresado con precisión de milisegundos.



Ejemplo:



```text

1907175600000

```



La carga se ejecuta especificando:



```text

--precision ms

```



## 5. Line Protocol



Ejemplo de punto:



```text

estadisticas_equipo,partido_id=P001,equipo_codigo=AAA,sede_id=S001 posesion_pct=49.85,pases_completados_total=0i,tiros_intervalo=0i,recuperaciones_intervalo=0i 1907175600000

```



La estructura separa:



```text

measurement

tags

fields

timestamp

```



## 6. Identidad de una serie



Conceptualmente, las series quedan definidas mediante:



```text

measurement + tags

```



En este modelo:



```text

estadisticas_equipo

+

partido_id

+

equipo_codigo

+

sede_id

```



El timestamp diferencia las observaciones que forman la evolución temporal de la serie.



## 7. Tags versus fields



Se utilizan como tags únicamente dimensiones necesarias para localizar o segmentar consultas.



No se utilizan como tags:



- timestamp;

- porcentaje de posesión;

- cantidad de pases;

- tiros;

- recuperaciones;

- identificadores únicos por observación;

- texto libre.



Esos valores presentan alta variación o representan medidas, por lo que incorporarlos como tags aumentaría la cardinalidad sin aportar valor a los patrones de acceso definidos.



## 8. Measurement histórico



El downsampling genera:



```text

estadisticas_equipo_resumen_1m

```



dentro del bucket:



```text

estadisticas_historicas

```



Mantiene las mismas dimensiones, pero reduce la granularidad temporal de cinco segundos a un minuto.



La función aplicada depende de cada field:



```text

posesion_pct              -> mean()

pases_completados_total   -> last()

tiros_intervalo           -> sum()

recuperaciones_intervalo  -> sum()

```

