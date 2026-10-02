// ============================================================
// HITO 8 - VALIDACION DEL BENCHMARK
// Grupo 9 - Fixture 2030
// ============================================================

from(bucket: "estadisticas_benchmark")
    |> range(start: -24h)
    |> filter(fn: (r) =>
        r._measurement == "estadisticas_equipo"
    )
    |> filter(fn: (r) =>
        r._field == "posesion_pct"
    )
    |> group()
    |> count(column: "_value")