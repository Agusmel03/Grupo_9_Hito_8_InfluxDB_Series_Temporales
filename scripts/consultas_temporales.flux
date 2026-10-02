// ============================================================
// HITO 8 - CONSULTAS TEMPORALES
// Grupo 9 - Fixture 2030
// ============================================================


// ------------------------------------------------------------
// CONSULTA 1
// Ventana temporal de posesion para AAA en P001.
// Recupera datos crudos de 5 minutos.
// ------------------------------------------------------------

from(bucket: "estadisticas_live")
    |> range(
        start: 2030-06-08T19:20:00Z,
        stop: 2030-06-08T19:25:00Z
    )
    |> filter(fn: (r) =>
        r._measurement == "estadisticas_equipo"
    )
    |> filter(fn: (r) =>
        r.partido_id == "P001"
    )
    |> filter(fn: (r) =>
        r.equipo_codigo == "AAA"
    )
    |> filter(fn: (r) =>
        r._field == "posesion_pct"
    )
    |> keep(
        columns: [
            "_time",
            "partido_id",
            "equipo_codigo",
            "_value"
        ]
    )
    |> limit(n: 12)
    |> yield(name: "ventana_temporal_P001_AAA")


// ------------------------------------------------------------
// CONSULTA 2
// Comparacion AAA vs AAB en P001.
// Promedia posesion en ventanas de 15 minutos.
// ------------------------------------------------------------

from(bucket: "estadisticas_live")
    |> range(
        start: 2030-06-08T19:00:00Z,
        stop: 2030-06-08T20:30:00Z
    )
    |> filter(fn: (r) =>
        r._measurement == "estadisticas_equipo"
    )
    |> filter(fn: (r) =>
        r.partido_id == "P001"
    )
    |> filter(fn: (r) =>
        r.equipo_codigo == "AAA" or
        r.equipo_codigo == "AAB"
    )
    |> filter(fn: (r) =>
        r._field == "posesion_pct"
    )
    |> group(
        columns: ["equipo_codigo"]
    )
    |> aggregateWindow(
        every: 15m,
        fn: mean,
        createEmpty: false
    )
    |> keep(
        columns: [
            "_time",
            "equipo_codigo",
            "_value"
        ]
    )
    |> yield(name: "comparacion_posesion_P001")