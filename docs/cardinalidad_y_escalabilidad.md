# Cardinalidad y escalabilidad - Hito 8 - Grupo 9

## 1. Objetivo

El modelo temporal debe permitir consultar estadísticas por partido, equipo y sede sin generar una cantidad innecesaria de series.

En InfluxDB, los tags forman parte de la identidad indexable de una serie, por lo que su selección afecta directamente la cardinalidad.

El objetivo es utilizar como tags únicamente dimensiones necesarias para los patrones de consulta declarados.

## 2. Tags utilizados

Se utilizan los siguientes tags:

```text
partido_id
equipo_codigo
sede_id
```

Estas dimensiones permiten localizar y segmentar las estadísticas por partido, equipo y sede.

## 3. Fields utilizados

Las medidas se almacenan como fields:

```text
posesion_pct
pases_completados_total
tiros_intervalo
recuperaciones_intervalo
```

Estos valores no se utilizan como tags porque cambian continuamente y representan observaciones del fenómeno medido.

Convertirlos en tags provocaría un crecimiento innecesario de cardinalidad.

## 4. Atributos excluidos de los tags

No se utilizan como tags:

```text
timestamp
identificadores únicos por punto
medidas numéricas
texto libre
```

El timestamp ya forma parte de la estructura temporal de cada punto y no debe utilizarse como dimensión indexable.

Un identificador único por observación generaría prácticamente una serie distinta por punto.

Las medidas numéricas presentan alta variabilidad y deben permanecer como fields.

El texto libre tampoco se utiliza como tag debido a su gran variabilidad potencial.

## 5. Identidad de una serie

En el modelo implementado, una serie queda determinada principalmente por la combinación:

```text
measurement
+
partido_id
+
equipo_codigo
+
sede_id
```

El measurement utilizado es:

```text
estadisticas_equipo
```

Por ejemplo:

```text
estadisticas_equipo
partido_id=P001
equipo_codigo=AAA
sede_id=S001
```

representa una serie diferente de:

```text
estadisticas_equipo
partido_id=P001
equipo_codigo=AAB
sede_id=S001
```

## 6. Cardinalidad de la muestra funcional

La muestra funcional utilizada durante las pruebas contiene:

```text
4 partidos
2 equipos por partido
```

Cada combinación partido/equipo genera una serie.

Por lo tanto:

```text
4 × 2 = 8 series
```

La validación realizada confirmó:

```text
8 series
1080 puntos por serie
8640 puntos totales
```

La sede no multiplica libremente la cardinalidad porque cada partido posee una sede determinada dentro del conjunto utilizado.

## 7. Estimación para el subconjunto del Fixture 2030

Para mantener coherencia con el Hito 5, este módulo reutiliza el subconjunto de 96 partidos implementado previamente en Neo4j.

En ese hito se trabajó con:

```text
64 equipos
96 partidos
12 sedes
```

y cada partido posee dos equipos participantes.

Por lo tanto, una estimación básica de las series del módulo temporal es:

```text
96 partidos × 2 equipos = 192 series
```

La sede depende del partido y no representa una dimensión independiente que multiplique libremente la cantidad de series.

Esta estimación corresponde al subconjunto efectivamente modelado y no pretende representar la totalidad del fixture global del escenario del TPO.

## 8. Riesgos de cardinalidad

La cardinalidad podría crecer de forma significativa si se agregaran como tags atributos de alta variabilidad.

Ejemplos que deben evitarse:

```text
id_unico_punto
timestamp_como_tag
valor_de_posesion
descripcion_libre
identificador_de_evento_unico
```

Si cada observación incorporara un identificador único como tag, la cantidad de series podría aproximarse a la cantidad de puntos, eliminando gran parte del beneficio del modelo temporal.

Por este motivo, los tags se limitan a dimensiones estables y relevantes para las consultas.

## 9. Objetivo de 10M+ puntos

El requisito de 10M+ puntos se interpreta como un objetivo de diseño y escalabilidad.

No significa que la cardinalidad deba crecer hasta 10 millones de series.

Una misma serie puede contener una gran cantidad de puntos asociados a timestamps diferentes.

Por ejemplo, para una serie correspondiente a un equipo dentro de un partido pueden almacenarse miles de observaciones manteniendo la misma combinación de tags.

Esto permite aumentar el volumen total de puntos sin aumentar en la misma proporción la cantidad de series.

## 10. Generación masiva

Para las pruebas de volumen se implementó:

```text
scripts/generacion_masiva.py
```

El script permite parametrizar la cantidad de puntos.

Ejemplo para generar diez millones:

```powershell
python .\scripts\generacion_masiva.py --puntos 10000000 --salida data\10_millones.lp
```

Los 10 millones de puntos constituyen un objetivo de generación y carga.

La prueba de rendimiento efectivamente ejecutada durante el desarrollo utilizó:

```text
100000 puntos
```

Por lo tanto, los resultados medidos no se extrapolan como si se hubieran cargado realmente 10 millones de puntos.

## 11. Estrategia de carga para grandes volúmenes

Para cargas de gran tamaño se propone trabajar con lotes de:

```text
50000 a 100000 puntos
```

El script:

```text
scripts/carga_lotes.ps1
```

implementa carga por lotes y permite configurar el tamaño utilizado.

La estrategia contempla:

- escritura secuencial de lotes;
- validación de cada ejecución;
- conteo de puntos procesados;
- reintentos ante errores;
- limpieza del archivo temporal;
- posibilidad de incorporar concurrencia controlada si el entorno lo requiere.

En la prueba realizada se utilizaron:

```text
2 lotes
50000 puntos por lote
100000 puntos procesados
```

## 12. Generación de timestamps

La muestra funcional utiliza timestamps relacionados con el partido y una frecuencia de cinco segundos.

Para las pruebas masivas se generan timestamps sintéticos con precisión de milisegundos.

La generación de timestamps evita utilizar un identificador único como tag y permite almacenar múltiples observaciones dentro de las mismas series.

En una carga distribuida de mayor escala sería necesario coordinar las fuentes para evitar colisiones no deseadas de measurement, tags y timestamp.

## 13. Orden temporal

La muestra funcional se genera de manera ordenada temporalmente.

Para grandes volúmenes, InfluxDB puede recibir puntos con timestamps explícitos incluso si algunas observaciones llegan con retraso.

Los datos tardíos deben conservar su timestamp original.

La estrategia de carga debe diferenciar el instante de llegada del instante real de la observación.

## 14. Manejo de errores y reintentos

El script de carga por lotes implementa reintentos ante errores.

Se configuró un máximo de reintentos para evitar que una falla genere un bucle infinito.

Cuando un lote falla:

```text
se detecta el error
se reintenta la escritura
se espera entre intentos
```

Si la operación continúa fallando después del máximo permitido, el proceso informa el problema.

La validación posterior permite comprobar que la cantidad de puntos almacenados coincide con el volumen esperado.

## 15. Validación de carga

La muestra funcional fue validada con:

```text
8640 puntos
8 series
1080 puntos por serie
```

La prueba de benchmark fue validada con:

```text
100000 puntos efectivamente almacenados
```

Esto permite diferenciar entre la cantidad generada y la cantidad realmente persistida.

## 16. Benchmark observado

La prueba real de ingestión se realizó con:

```text
100000 puntos
```

Hardware:

```text
Intel(R) Core(TM) i9-9900K CPU @ 3.60GHz
8 núcleos
16 procesadores lógicos
31,93 GB RAM
```

Resultado de carga:

```text
Tiempo: 2.3678593 segundos
Throughput: 42232.24 puntos por segundo
```

También se realizó una medición de consulta sobre los 100.000 puntos almacenados:

```text
Tiempo de consulta observado: 215.82 ms
```

Estos valores corresponden exclusivamente al ambiente local y a las condiciones de la prueba realizada.

No representan una garantía de rendimiento para producción ni una medición real sobre 10 millones de puntos.

## 17. Alcance del generador masivo

`generacion_masiva.py` se utiliza exclusivamente para pruebas de ingestión, batching y escalabilidad.

Su objetivo es generar un gran volumen de puntos y no reproducir exactamente la evolución deportiva de un partido real.

Por este motivo:

```text
generacion_puntos.py
```

se utiliza para validar la semántica funcional de las estadísticas, mientras que:

```text
generacion_masiva.py
```

se utiliza para pruebas de volumen y rendimiento.

Esta separación permite distinguir claramente:

```text
muestra funcional y semántica
vs.
muestra sintética de carga
```

## 18. Escalabilidad futura

Si el volumen o la cantidad de fuentes aumentara considerablemente, podrían evaluarse:

- múltiples productores de datos;
- carga concurrente controlada;
- archivos o streams divididos por fuente;
- validaciones automáticas por lote;
- monitoreo de errores de escritura;
- análisis periódico de cardinalidad;
- distribución del servicio en una infraestructura adecuada.

Estas decisiones no fueron necesarias para la prueba local, pero forman parte de la estrategia de crecimiento hacia volúmenes superiores.

## 19. Conclusión

El modelo mantiene baja la cardinalidad al limitar los tags a dimensiones necesarias para las consultas.

El crecimiento esperado se concentra principalmente en la cantidad de puntos por serie y no en la creación indiscriminada de nuevas series.

La separación entre la muestra funcional y el generador masivo permite validar tanto la semántica del modelo como su estrategia de carga y escalabilidad.