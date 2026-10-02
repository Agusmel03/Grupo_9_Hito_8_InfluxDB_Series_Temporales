\# Patrones de acceso - Hito 8 - Grupo 9



\## 1. Problema temporal



Durante los partidos del Fixture 2030 se generan estadísticas que cambian continuamente.



El módulo temporal debe permitir registrar y consultar la evolución de variables como:



\- posesión de pelota;

\- pases completados;

\- tiros;

\- recuperaciones.



Estas observaciones poseen un instante asociado y deben poder recuperarse mediante ventanas temporales.



InfluxDB se utiliza para este módulo porque permite almacenar y consultar eficientemente series temporales y separar dimensiones indexables de valores observados.



\## 2. Fuente de los datos



Para el desarrollo se implementó un generador sintético reproducible.



Cada punto representa el estado de las estadísticas de un equipo dentro de un partido en un instante determinado.



Se mantienen identificadores coherentes con los hitos anteriores del Fixture 2030.



Ejemplos:



```text

Partido: P001

Equipo: AAA

Sede: S001

```



\## 3. Frecuencia de captura



La muestra funcional utiliza:



```text

1 observación cada 5 segundos por equipo

```



Para un partido de 90 minutos:



```text

90 × 60 / 5 = 1080 puntos por equipo

```



Como cada partido posee dos equipos:



```text

2160 puntos por partido

```



La muestra desarrollada contiene cuatro partidos:



```text

4 × 2160 = 8640 puntos

```



La validación ejecutada en InfluxDB confirmó exactamente 8640 puntos.



\## 4. Precisión temporal



Los timestamps se generan y escriben con precisión de milisegundos.



Durante la carga se utiliza:



```text

\--precision ms

```



La precisión de milisegundos resulta suficiente para el escenario porque la frecuencia funcional de captura es de cinco segundos.



\## 5. Patrones prioritarios



\### PA1 - Recuperar una ventana temporal



Pregunta:



```text

¿Cómo evolucionó una estadística de un equipo durante un intervalo del partido?

```



Parámetros:



\- partido;

\- equipo;

\- inicio;

\- fin;

\- estadística.



Ejemplo implementado:



```text

Partido: P001

Equipo: AAA

Estadística: posesion\_pct

Ventana: 19:20 a 19:25

```



La consulta devuelve las observaciones ordenadas temporalmente.



\### PA2 - Comparar los equipos de un partido



Pregunta:



```text

¿Cómo evolucionó la posesión de ambos equipos durante el partido?

```



Dimensiones utilizadas:



\- `partido\_id`;

\- `equipo\_codigo`.



Medida:



```text

posesion\_pct

```



La consulta implementada compara AAA y AAB en P001 utilizando ventanas de 15 minutos.



Para cada ventana se utiliza:



```text

mean()

```



porque la posesión es un porcentaje observado y no un contador.



\### PA3 - Obtener los pases completados



Pregunta:



```text

¿Cuántos pases completó cada equipo al finalizar el partido?

```



Medida:



```text

pases\_completados\_total

```



Esta medida funciona como un contador acumulativo.



Por lo tanto, no corresponde sumar todas las muestras.



Se utiliza:



```text

last()

```



para recuperar el valor final.



\### PA4 - Obtener los tiros totales



Pregunta:



```text

¿Cuántos tiros realizó cada equipo durante el partido?

```



Medida:



```text

tiros\_intervalo

```



Cada punto indica la cantidad de tiros ocurridos en ese intervalo.



La agregación correcta es:



```text

sum()

```



\### PA5 - Obtener recuperaciones totales



Pregunta:



```text

¿Cuántas recuperaciones realizó cada equipo durante el partido?

```



Medida:



```text

recuperaciones\_intervalo

```



Cada punto representa eventos ocurridos dentro del intervalo.



Por lo tanto se utiliza:



```text

sum()

```



\### PA6 - Consulta histórica



Pregunta:



```text

¿Cómo evolucionaron las estadísticas de un partido después del período operativo en vivo?

```



Para esta consulta se utiliza:



```text

estadisticas\_historicas

```



Los datos históricos poseen granularidad de un minuto, reduciendo volumen sin perder la tendencia general del partido.



\## 6. Ausencia y retraso de datos



La ausencia de un punto representa ausencia de observación y no debe interpretarse automáticamente como valor cero.



En las agregaciones temporales se utiliza:



```text

createEmpty: false

```



para evitar fabricar observaciones inexistentes.



Los datos tardíos pueden incorporarse utilizando su timestamp original mientras se encuentren dentro del período admitido por la política de retención.

