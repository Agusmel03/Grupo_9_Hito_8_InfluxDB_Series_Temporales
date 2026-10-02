## 11. Medición de consulta

También se realizó una medición de consulta sobre el bucket `estadisticas_benchmark`, que contiene 100.000 puntos.

La consulta utilizada fue:

```text
scripts/validacion_benchmark.flux
```

La medición se realizó desde PowerShell utilizando:

```text
Measure-Command
```

Resultado observado:

```text
Volumen considerado: 100000 puntos
Tiempo de consulta: 215.82 ms
```

La medición incluye el costo de invocar la consulta mediante `docker exec`, por lo que representa el tiempo observado desde el cliente local y no exclusivamente el tiempo interno de ejecución de InfluxDB.

El resultado corresponde únicamente al hardware, ambiente y volumen utilizados durante esta prueba.