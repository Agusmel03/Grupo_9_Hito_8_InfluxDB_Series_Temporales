# Patrones de acceso - Hito 8 - Grupo 9

## 1. Problema temporal

Durante los partidos del Fixture 2030 se generan estadísticas que cambian continuamente.

El módulo temporal debe permitir registrar y consultar la evolución de variables como:

- posesión de pelota;
- pases completados;
- tiros;
- recuperaciones.

Estas observaciones poseen un instante asociado y deben poder recuperarse mediante ventanas temporales.

InfluxDB se utiliza para este módulo porque permite almacenar y consultar eficientemente series temporales y separar dimensiones indexables de valores observados.

## 2. Fuente de los datos

Para el desarrollo se implementó un generador sintético reproducible.

Cada punto representa el estado de las estadísticas de un equipo dentro de un partido en un instante determinado.

Se mantienen identificadores coherentes con los hitos anteriores del Fixture 2030.

Ejemplos:

```text
Partido: P001
Equipo: AAA
Sede: S001
```

## 3. Productores y consumidores

En el laboratorio, las observaciones temporales son producidas por `generacion_puntos.py`, que genera un conjunto sintético y reproducible de estadísticas por equipo y partido.

En el escenario conceptual del Fixture 2030, el productor sería el servicio o proveedor encargado de recibir y publicar las estadísticas oficiales durante cada encuentro.

Los principales consumidores del módulo son:

- la vista en vivo del partido, que necesita recuperar ventanas temporales recientes;
- los servicios de estadísticas, que comparan equipos y calculan agregados;
- el módulo de análisis histórico, que consulta información resumida una vez finalizado el período operativo.

Las consultas en vivo trabajan principalmente sobre `estadisticas_live`, mientras que las consultas históricas utilizan `estadisticas_historicas`.

## 4. Frecuencia de captura

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

## 5. Precisión temporal

Los timestamps se generan y escriben con precisión de milisegundos.

Durante la carga se utiliza:

```text
--precision ms
```

La precisión de milisegundos resulta suficiente para el escenario porque la frecuencia funcional de captura es de cinco segundos.

## 6. Patrones prioritarios

### PA1 - Recuperar una ventana temporal

Pregunta:

```text
¿Cómo evolucionó una estadística de un equipo durante un intervalo del partido?
```

Quién consulta:

```text
Vista en vivo del partido o servicio de estadísticas
```

Rango temporal:

```text
Ventanas recientes de pocos minutos dentro de un partido
```

Dimensiones:

- `partido_id`;
- `equipo_codigo`.

Medidas:

- `posesion_pct`;
- otras estadísticas temporales según necesidad.

Ejemplo implementado:

```text
Partido: P001
Equipo: AAA
Estadística: posesion_pct
Ventana: 19:20 a 19:25
```

La consulta devuelve las observaciones ordenadas temporalmente.

### PA2 - Comparar los equipos de un partido

Pregunta:

```text
¿Cómo evolucionó la posesión de ambos equipos durante el partido?
```

Quién consulta:

```text
Servicio de estadísticas o interfaz de seguimiento en vivo
```

Rango temporal:

```text
Duración completa del partido o ventanas parciales
```

Dimensiones utilizadas:

- `partido_id`;
- `equipo_codigo`.

Medida:

```text
posesion_pct
```

La consulta implementada compara AAA y AAB en P001 utilizando ventanas de 15 minutos.

Para cada ventana se utiliza:

```text
mean()
```

porque la posesión es un porcentaje observado y no un contador.

### PA3 - Obtener los pases completados

Pregunta:

```text
¿Cuántos pases completó cada equipo al finalizar el partido?
```

Quién consulta:

```text
Servicio de estadísticas o análisis posterior al partido
```

Rango temporal:

```text
Partido completo
```

Medida:

```text
pases_completados_total
```

Esta medida funciona como un contador acumulativo.

Por lo tanto, no corresponde sumar todas las muestras.

Se utiliza:

```text
last()
```

para recuperar el valor final.

### PA4 - Obtener los tiros totales

Pregunta:

```text
¿Cuántos tiros realizó cada equipo durante el partido?
```

Quién consulta:

```text
Servicio de estadísticas
```

Rango temporal:

```text
Partido completo o período seleccionado
```

Medida:

```text
tiros_intervalo
```

Cada punto indica la cantidad de tiros ocurridos en ese intervalo.

La agregación correcta es:

```text
sum()
```

### PA5 - Obtener recuperaciones totales

Pregunta:

```text
¿Cuántas recuperaciones realizó cada equipo durante el partido?
```

Quién consulta:

```text
Servicio de estadísticas
```

Rango temporal:

```text
Partido completo o período seleccionado
```

Medida:

```text
recuperaciones_intervalo
```

Cada punto representa eventos ocurridos dentro del intervalo.

Por lo tanto se utiliza:

```text
sum()
```

### PA6 - Consulta histórica

Pregunta:

```text
¿Cómo evolucionaron las estadísticas de un partido después del período operativo en vivo?
```

Quién consulta:

```text
Módulo de análisis histórico
```

Rango temporal:

```text
Partidos ya finalizados conservados durante el período histórico
```

Para esta consulta se utiliza:

```text
estadisticas_historicas
```

Los datos históricos poseen granularidad de un minuto, reduciendo volumen sin perder la tendencia general del partido.

## 7. Frecuencia esperada y precisión

La frecuencia funcional de llegada de datos es:

```text
1 punto cada 5 segundos por equipo
```

La precisión utilizada para los timestamps es:

```text
milisegundos
```

Esta precisión permite conservar correctamente el instante de cada observación y es superior a la frecuencia funcional de captura.

## 8. Ausencia, retraso y datos tardíos

La ausencia de un punto representa ausencia de observación y no debe interpretarse automáticamente como valor cero.

En las agregaciones temporales se utiliza:

```text
createEmpty: false
```

para evitar fabricar observaciones inexistentes.

Si una fuente entrega un dato con retraso, puede incorporarse utilizando su timestamp original siempre que el dato se encuentre dentro del período admitido por la política de retención.

Los datos tardíos deben conservar su instante real de observación para no alterar artificialmente la evolución temporal del partido.

## 9. Relación entre patrones y almacenamiento

Los patrones de acceso recientes utilizan principalmente:

```text
estadisticas_live
```

con granularidad de cinco segundos.

Los patrones históricos utilizan:

```text
estadisticas_historicas
```

con granularidad de un minuto.

Esta separación permite mantener alta precisión para el seguimiento operativo y reducir volumen para consultas históricas.