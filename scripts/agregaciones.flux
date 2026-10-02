// ============================================================
// HITO 8 - AGREGACIONES TEMPORALES
// Grupo 9 - Fixture 2030
// Partido analizado: P001
// ============================================================


// ------------------------------------------------------------
// 1. POSESION
//
// Es un gauge / porcentaje observado.
// Tiene sentido calcular el promedio.
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
        r._field == "posesion_pct"
    )
    |> group(
        columns: ["equipo_codigo"]
    )
    |> mean()
    |> keep(
        columns: [
            "equipo_codigo",
            "_value"
        ]
    )
    |> yield(name: "posesion_promedio")


// ------------------------------------------------------------
// 2. PASES COMPLETADOS
//
// Es un contador acumulativo.
// NO se deben sumar sus muestras.
// Se toma el ultimo valor del partido.
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
        r._field == "pases_completados_total"
    )
    |> group(
        columns: ["equipo_codigo"]
    )
    |> last()
    |> keep(
        columns: [
            "equipo_codigo",
            "_value"
        ]
    )
    |> yield(name: "pases_finales")


// ------------------------------------------------------------
// 3. TIROS
//
// Representa eventos ocurridos en cada intervalo.
// Tiene sentido sumar los intervalos.
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
        r._field == "tiros_intervalo"
    )
    |> group(
        columns: ["equipo_codigo"]
    )
    |> sum()
    |> keep(
        columns: [
            "equipo_codigo",
            "_value"
        ]
    )
    |> yield(name: "tiros_totales")


// ------------------------------------------------------------
// 4. RECUPERACIONES
//
// Representa eventos ocurridos en cada intervalo.
// Tiene sentido sumar los valores.
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
        r._field == "recuperaciones_intervalo"
    )
    |> group(
        columns: ["equipo_codigo"]
    )
    |> sum()
    |> keep(
        columns: [
            "equipo_codigo",
            "_value"
        ]
    )
    |> yield(name: "recuperaciones_totales")