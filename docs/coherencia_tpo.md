\# Coherencia con el TPO - Hito 8 - Grupo 9



\## 1. Continuidad del Fixture 2030



El módulo de series temporales se incorpora a la arquitectura del Fixture 2030 como un componente especializado en estadísticas que cambian durante los partidos.



No reemplaza a los módulos implementados en hitos anteriores, sino que complementa la persistencia políglota del proyecto.



\## 2. Identificadores compartidos



Las estadísticas temporales mantienen identificadores coherentes con el resto del TPO.



Ejemplos:



```text

Partidos:

P001

P002

P003



Equipos:

AAA

AAB

AAC

AAD



Sedes:

S001

S002

S003

```



Esto permite asociar las observaciones temporales con las entidades gestionadas por otros módulos sin replicar toda su información descriptiva.



\## 3. Relación con MongoDB



MongoDB se utilizó previamente para información documental de equipos y jugadores.



InfluxDB no replica esos documentos completos.



Solamente conserva identificadores de equipo como dimensiones necesarias para consultar las estadísticas.



\## 4. Relación con Neo4j



Neo4j modela relaciones entre:



\- equipos;

\- jugadores;

\- partidos;

\- sedes;

\- eventos.



El módulo temporal reutiliza los identificadores de partido y sede definidos en ese contexto.



Neo4j responde preguntas relacionales, mientras que InfluxDB responde preguntas sobre evolución en el tiempo.



\## 5. Relación con Cassandra



Cassandra fue utilizado para comentarios masivos asociados a partidos.



Ese módulo está orientado a grandes volúmenes de mensajes y patrones conocidos de lectura/escritura.



Las estadísticas en vivo poseen una naturaleza diferente porque requieren:



\- timestamp;

\- ventanas temporales;

\- agregaciones;

\- evolución histórica.



Por esa razón se almacenan en InfluxDB y no en Cassandra.



\## 6. Relación con Redis



Redis se utiliza para información que requiere acceso temporal de muy baja latencia, como caché o sesiones.



InfluxDB se utiliza para conservar series temporales y realizar consultas sobre su evolución.



Los módulos pueden coexistir porque responden a necesidades diferentes.



\## 7. Persistencia políglota



La solución del Fixture 2030 utiliza diferentes tecnologías según el tipo de acceso requerido.



El Hito 8 agrega InfluxDB como motor específico para:



```text

estadísticas temporales

\+

ventanas de tiempo

\+

agregaciones

\+

retención

\+

downsampling

```



Esta decisión mantiene el enfoque de seleccionar cada tecnología según la naturaleza de los datos y los patrones de acceso.

