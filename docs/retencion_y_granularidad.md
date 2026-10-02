\# Retención y granularidad - Hito 8 - Grupo 9



\## 1. Estrategia temporal



El módulo utiliza dos niveles principales de almacenamiento:



```text

estadisticas\_live

estadisticas\_historicas

```



El objetivo es separar las necesidades operativas de corto plazo de las consultas históricas.



\## 2. Bucket de datos en vivo



Bucket:



```text

estadisticas\_live

```



Retención configurada:



```text

720 horas

30 días

```



Granularidad funcional:



```text

5 segundos

```



Los datos de alta resolución permiten analizar cambios durante el partido y consultar ventanas recientes.



\## 3. Bucket histórico



Bucket:



```text

estadisticas\_historicas

```



Retención configurada:



```text

8760 horas

365 días

```



Granularidad:



```text

1 minuto

```



El histórico conserva una versión resumida de las estadísticas.



\## 4. Downsampling



Los datos de cinco segundos se resumen en ventanas de un minuto.



La función aplicada depende de la semántica de cada medida.



\### posesion\_pct



Tipo:



```text

gauge

```



Función:



```text

mean()

```



Se calcula el promedio de las observaciones del minuto.



\### pases\_completados\_total



Tipo:



```text

contador acumulativo

```



Función:



```text

last()

```



Se conserva el último valor observado dentro del minuto.



Sumar las muestras produciría un resultado incorrecto.



\### tiros\_intervalo



Tipo:



```text

eventos por intervalo

```



Función:



```text

sum()

```



\### recuperaciones\_intervalo



Tipo:



```text

eventos por intervalo

```



Función:



```text

sum()

```



\## 5. Measurement histórico



El resumen utiliza:



```text

estadisticas\_equipo\_resumen\_1m

```



y mantiene las dimensiones:



```text

partido\_id

equipo\_codigo

sede\_id

```



\## 6. Reducción de granularidad



En los datos en vivo:



```text

90 minutos × 60 segundos / 5 segundos

=

1080 puntos por serie

```



Después del downsampling:



```text

90 puntos por serie

```



Para las ocho series de la muestra:



```text

8 × 90 = 720

```



La validación del histórico para `posesion\_pct` devolvió exactamente:



```text

720 puntos

```



\## 7. Ciclo de vida



El ciclo de las estadísticas es:



```text

Captura cada 5 segundos

&#x20;       ↓

estadisticas\_live

&#x20;       ↓

Downsampling cada 1 minuto

&#x20;       ↓

estadisticas\_historicas

&#x20;       ↓

Expiración según retención

```



Los datos live expiran después de 30 días.



Los datos históricos permanecen durante 365 días.



\## 8. Justificación



Durante el partido resulta útil conservar alta resolución porque permite:



\- representar cambios recientes;

\- consultar ventanas pequeñas;

\- comparar equipos;

\- analizar evolución temporal.



Después del período operativo, conservar indefinidamente un punto cada cinco segundos aumenta el almacenamiento sin aportar el mismo valor.



El resumen de un minuto permite conservar tendencias y resultados históricos reduciendo significativamente el volumen.



\## 9. Futuras extensiones



Si se requiriera conservar información durante varios años podría incorporarse un tercer nivel de agregación, por ejemplo:



```text

5 minutos

15 minutos

resultado final por partido

```



La granularidad elegida debería depender siempre de las preguntas históricas que deban responderse.

