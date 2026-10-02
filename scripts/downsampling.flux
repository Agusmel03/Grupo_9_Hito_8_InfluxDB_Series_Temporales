// ============================================================
// HITO 8 - DOWNSAMPLING
// Grupo 9 - Fixture 2030
//
// Convierte datos de alta resolucion (5 segundos)
// en resumen historico de 1 minuto.
//
// La funcion utilizada depende de la semantica del field.
// ============================================================

base =
    from(bucket: "estadisticas_live")
        |> range(
            start: 2030-06-08T19:00:00Z,
            stop: 2030-06-08T20:30:00Z
        )
        |> filter(fn: (r) =>
            r._measurement == "estadisticas_equipo"
        )


// ------------------------------------------------------------
// POSESION
// Gauge instantaneo -> promedio por minuto.
// ------------------------------------------------------------

posesion =
    base
        |> filter(fn: (r) =>
            r._field == "posesion_pct"
        )
        |> aggregateWindow(
            every: 1m,
            fn: mean,
            createEmpty: false
        )


// ------------------------------------------------------------
// PASES
// Contador acumulativo -> ultimo valor del minuto.
// No corresponde sumar las muestras.
// ------------------------------------------------------------

pases =
    base
        |> filter(fn: (r) =>
            r._field == "pases_completados_total"
        )
        |> aggregateWindow(
            every: 1m,
            fn: last,
            createEmpty: false
        )


// ------------------------------------------------------------
// TIROS
// Eventos por intervalo -> suma por minuto.
// ------------------------------------------------------------

tiros =
    base
        |> filter(fn: (r) =>
            r._field == "tiros_intervalo"
        )
        |> aggregateWindow(
            every: 1m,
            fn: sum,
            createEmpty: false
        )


// ------------------------------------------------------------
// RECUPERACIONES
// Eventos por intervalo -> suma por minuto.
// ------------------------------------------------------------

recuperaciones =
    base
        |> filter(fn: (r) =>
            r._field == "recuperaciones_intervalo"
        )
        |> aggregateWindow(
            every: 1m,
            fn: sum,
            createEmpty: false
        )


// ------------------------------------------------------------
// UNION Y ESCRITURA AL BUCKET HISTORICO
// ------------------------------------------------------------

union(
    tables: [
        posesion,
        pases,
        tiros,
        recuperaciones
    ]
)
    |> set(
        key: "_measurement",
        value: "estadisticas_equipo_resumen_1m"
    )
    |> to(
        bucket: "estadisticas_historicas",
        org: "grupo9"
    )