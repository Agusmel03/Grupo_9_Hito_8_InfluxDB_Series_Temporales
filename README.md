# Hito 8 - Series Temporales con InfluxDB



## Ingeniería de Datos II - Grupo 9



**Repositorio GitHub:** https://github.com/Agusmel03/Grupo_9_Hito_8_InfluxDB_Series_Temporales


Implementación del módulo de series temporales del proyecto **Fixture 2030** utilizando InfluxDB.



El objetivo del módulo es registrar, consultar y conservar estadísticas que evolucionan durante los partidos, definiendo de forma explícita el modelo temporal, la granularidad, cardinalidad, agregaciones, retención y estrategia de escalabilidad.



---



## 1. Tecnologías utilizadas



- InfluxDB

- Docker Compose

- Python

- PowerShell

- Flux

- Line Protocol



Imagen Docker utilizada:



```text

influxdb:latest

```



Versión observada durante las pruebas:



```text

InfluxDB v2.9.1

```



---



## 2. Modelo temporal



El measurement principal es:



```text

estadisticas_equipo

```



Cada punto representa las estadísticas de un equipo dentro de un partido en un instante determinado.



### Tags



```text

partido_id

equipo_codigo

sede_id

```



### Fields



```text

posesion_pct

pases_completados_total

tiros_intervalo

recuperaciones_intervalo

```



### Precisión temporal



```text

milisegundos

```



### Granularidad funcional



```text

5 segundos

```



---



## 3. Semántica de las medidas



| Field | Tipo | Semántica | Agregación |

|---|---|---|---|

| `posesion_pct` | float | Porcentaje observado | `mean()` |

| `pases_completados_total` | integer | Contador acumulativo | `last()` |

| `tiros_intervalo` | integer | Eventos por intervalo | `sum()` |

| `recuperaciones_intervalo` | integer | Eventos por intervalo | `sum()` |



La función de agregación se selecciona según la naturaleza de cada medida.



Por ejemplo, no corresponde sumar `pases_completados_total`, ya que se trata de un contador acumulativo.



---



## 4. Política de retención



Se utilizan tres buckets.



### Datos en vivo



```text

Bucket: estadisticas_live

Retención: 720h

Equivalencia: 30 días

Granularidad: 5 segundos

```



### Datos históricos



```text

Bucket: estadisticas_historicas

Retención: 8760h

Equivalencia: 365 días

Granularidad: 1 minuto

```



### Benchmark



```text

Bucket: estadisticas_benchmark

Retención: 24h

```



Los datos históricos se generan mediante downsampling.



Las funciones utilizadas son:



```text

posesion_pct              -> mean()

pases_completados_total   -> last()

tiros_intervalo           -> sum()

recuperaciones_intervalo  -> sum()

```



---



## 5. Estructura del proyecto



```text

Grupo_9_Hito_8_InfluxDB_Series_Temporales/

│

├── docker-compose.yml

├── .env.example

├── .gitignore

├── README.md

│

├── data/

│   └── .gitkeep

│

├── scripts/

│   ├── inicializacion.ps1

│   ├── generacion_puntos.py

│   ├── generacion_masiva.py

│   ├── carga_lotes.ps1

│   ├── consultas_temporales.flux

│   ├── agregaciones.flux

│   ├── downsampling.flux

│   ├── validacion.flux

│   ├── validacion_distribucion.flux

│   ├── validacion_historico.flux

│   └── validacion_benchmark.flux

│

└── docs/

&#x20;   ├── patrones_de_acceso.md

&#x20;   ├── modelo_multidimensional.md

&#x20;   ├── cardinalidad_y_escalabilidad.md

&#x20;   ├── retencion_y_granularidad.md

&#x20;   ├── rendimiento.md

&#x20;   ├── coherencia_tpo.md

&#x20;   │

&#x20;   └── evidencia/

&#x20;       ├── 00_ambiente.txt

&#x20;       ├── 01_inicializacion.txt

&#x20;       ├── 02_carga_muestra.txt

&#x20;       ├── 03_validacion_distribucion.txt

&#x20;       ├── 04_consultas_temporales.txt

&#x20;       ├── 05_agregaciones.txt

&#x20;       ├── 06_retencion_downsampling.txt

&#x20;       ├── 07_benchmark.txt

&#x20;       └── 08_carga_lotes.txt

```



Los archivos `.lp` generados durante las pruebas no se versionan.



---



## 6. Requisitos



Para ejecutar el proyecto se requiere:



```text

Docker Desktop

Docker Compose

Python 3

PowerShell

Git

```



---



## 7. Configuración local



Crear el archivo `.env` utilizando `.env.example` como plantilla:



```powershell

Copy-Item .env.example .env

```



Completar las variables locales:



```text

INFLUXDB_USERNAME=

INFLUXDB_PASSWORD=

INFLUXDB_ORG=

INFLUXDB_BUCKET_LIVE=

INFLUXDB_TOKEN=

```



El archivo:



```text

.env

```



se encuentra incluido en `.gitignore` y no debe publicarse en el repositorio.



---



## 8. Levantar InfluxDB



Ejecutar:



```powershell

docker compose up -d

```



Verificar el contenedor:



```powershell

docker compose ps

```



Verificar conectividad:



```powershell

docker exec fixture2030-influxdb influx ping

```



Respuesta esperada:



```text

OK

```



---



## 9. Inicialización



Ejecutar:



```powershell

.\scripts\inicializacion.ps1

```



El script verifica la disponibilidad de InfluxDB y crea, en caso de no existir:



```text

estadisticas_historicas

estadisticas_benchmark

```



El bucket:



```text

estadisticas_live

```



se crea durante el setup inicial de Docker Compose con una retención de:



```text

720h

```



El script de inicialización puede ejecutarse múltiples veces sin volver a crear buckets existentes.



---



## 10. Generación de la muestra funcional



Ejecutar:



```powershell

python .\scripts\generacion_puntos.py

```



Resultado esperado:



```text

Partidos: 4

Equipos por partido: 2

Intervalo temporal: 5 segundos

Duracion simulada: 90 minutos

Puntos por equipo: 1080

Total de puntos: 8640

```



Se genera:



```text

data\estadisticas_muestra.lp

```



La generación utiliza una semilla fija para permitir reproducibilidad.



---



## 11. Carga de datos



La muestra puede cargarse directamente mediante:



```powershell

docker exec fixture2030-influxdb influx write --host http://localhost:8086 --org grupo9 --bucket estadisticas_live --token <TOKEN_LOCAL> --precision ms --file /data/estadisticas_muestra.lp

```



También se implementó un mecanismo de carga por lotes:



```powershell

.\scripts\carga_lotes.ps1 -Archivo "data\estadisticas_muestra.lp" -Bucket "estadisticas_live" -TamanoLote 50000

```



El script permite configurar:



```text

tamaño de lote

bucket destino

cantidad máxima de reintentos

```



Además incluye:



- detección de errores;

- reintentos;

- conteo de puntos procesados;

- limpieza del archivo temporal.



---



## 12. Validación de la muestra



Ejecutar:



```powershell

docker exec fixture2030-influxdb influx query --host http://localhost:8086 --org grupo9 --token <TOKEN_LOCAL> --file /scripts/validacion.flux

```



Resultado obtenido:



```text

8640 puntos

```



También se validó la distribución:



```text

8 series

1080 puntos por serie

```



Distribución observada:



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



---



## 13. Consultas temporales



Ejecutar:



```powershell

docker exec fixture2030-influxdb influx query --host http://localhost:8086 --org grupo9 --token <TOKEN_LOCAL> --file /scripts/consultas_temporales.flux

```



Se implementaron consultas para:



- recuperar una ventana temporal;

- filtrar por partido;

- filtrar por equipo;

- comparar equipos;

- agregar estadísticas mediante ventanas temporales.



Ejemplo:



```text

Partido: P001

Equipo: AAA

Ventana: 19:20 a 19:25

```



---



## 14. Agregaciones



Ejecutar:



```powershell

docker exec fixture2030-influxdb influx query --host http://localhost:8086 --org grupo9 --token <TOKEN_LOCAL> --file /scripts/agregaciones.flux

```



Para el partido P001 se obtuvieron:



```text

posesión promedio

pases finales

tiros totales

recuperaciones totales

```



Resultados observados:



```text

Posesión promedio

AAA: 45.32 %

AAB: 54.68 %



Pases finales

AAA: 588

AAB: 498



Tiros totales

AAA: 16

AAB: 13



Recuperaciones

AAA: 51

AAB: 48

```



---



## 15. Downsampling



Ejecutar:



```powershell

docker exec fixture2030-influxdb influx query --host http://localhost:8086 --org grupo9 --token <TOKEN_LOCAL> --file /scripts/downsampling.flux

```



Los datos pasan de:



```text

granularidad de 5 segundos

```



a:



```text

granularidad de 1 minuto

```



y se almacenan en:



```text

estadisticas_historicas

```



El measurement resultante es:



```text

estadisticas_equipo_resumen_1m

```



Validación:



```powershell

docker exec fixture2030-influxdb influx query --host http://localhost:8086 --org grupo9 --token <TOKEN_LOCAL> --file /scripts/validacion_historico.flux

```



Resultado obtenido:



```text

720 puntos

```



Esto coincide con:



```text

8 series × 90 minutos = 720 puntos

```



para el field `posesion_pct`.



---



## 16. Cardinalidad



Se utilizan como tags:



```text

partido_id

equipo_codigo

sede_id

```



Para el Fixture 2030 considerado:



```text

96 partidos

2 equipos por partido

```



Por lo tanto, se estiman aproximadamente:



```text

96 × 2 = 192 series

```



La sede depende del partido y no multiplica libremente la cantidad de series.



No se utilizan como tags:



```text

timestamps

IDs únicos por punto

medidas numéricas

texto libre

```



para evitar crecimiento innecesario de cardinalidad.



---



## 17. Estrategia para 10M+ puntos



Se implementó:



```text

scripts/generacion_masiva.py

```



El generador permite parametrizar la cantidad de puntos.



Ejemplo:



```powershell

python .\scripts\generacion_masiva.py --puntos 10000000 --salida data\10_millones.lp

```



Los 10 millones de puntos representan un objetivo de diseño.



La prueba real realizada localmente fue menor y se documenta de forma diferenciada.



Para grandes volúmenes se propone trabajar con lotes de:



```text

50000 a 100000 puntos

```



y utilizar:



- escritura secuencial;

- reintentos;

- validación posterior;

- conteo de puntos;

- concurrencia controlada en escenarios de mayor escala.



---



## 18. Benchmark real



Se realizó una prueba real con:



```text

100000 puntos

```



Hardware utilizado:



```text

Intel(R) Core(TM) i9-9900K CPU @ 3.60GHz

8 núcleos

16 procesadores lógicos

31,93 GB RAM

```



Resultado:



```text

Tiempo: 2.3678593 segundos

Throughput: 42232.24 puntos por segundo

```



La consulta posterior confirmó:



```text

100000 puntos efectivamente almacenados

```



También se probó la carga por lotes utilizando:



```text

2 lotes de 50000 puntos

```



Resultado:



```text

Lotes procesados: 2

Puntos procesados: 100000

Puntos almacenados luego de la prueba: 100000

```



Estos valores corresponden exclusivamente al ambiente y volumen medidos y no representan una garantía de rendimiento para una carga completa de 10M+ puntos.



---



## 19. Persistencia



InfluxDB utiliza almacenamiento persistente en:



```text

~/docker/data/influxdb

```



mediante un bind mount configurado en Docker Compose.



Los archivos generados durante las pruebas se encuentran en:



```text

data/

```



pero los archivos `.lp` se excluyen del repositorio mediante `.gitignore`.



---



## 20. Seguridad



El repositorio no debe contener:



```text

.env

tokens reales

contraseñas reales

archivos .lp generados

```



El archivo:



```text

.env.example

```



se utiliza únicamente como plantilla.



Las credenciales utilizadas son exclusivamente locales.



---



## 21. Evidencia



Los resultados reales de las pruebas se encuentran en:



```text

docs/evidencia/

```



Incluyen:



```text

00_ambiente.txt

01_inicializacion.txt

02_carga_muestra.txt

03_validacion_distribucion.txt

04_consultas_temporales.txt

05_agregaciones.txt

06_retencion_downsampling.txt

07_benchmark.txt

08_carga_lotes.txt

```



---



## 22. Documentación adicional



El análisis completo se encuentra en:



```text

docs/patrones_de_acceso.md

docs/modelo_multidimensional.md

docs/cardinalidad_y_escalabilidad.md

docs/retencion_y_granularidad.md

docs/rendimiento.md

docs/coherencia_tpo.md

```



---



## 23. Coherencia con el Fixture 2030



InfluxDB complementa los motores utilizados en los hitos anteriores.



Su responsabilidad específica dentro del TPO es resolver:



```text

series temporales

ventanas de tiempo

evolución de estadísticas

agregaciones temporales

retención

downsampling

```



Se mantienen identificadores coherentes para:



```text

partidos

equipos

sedes

```



permitiendo integrar conceptualmente el módulo temporal con el resto del Fixture 2030.



---



## Grupo 9 - Ingeniería de Datos II

