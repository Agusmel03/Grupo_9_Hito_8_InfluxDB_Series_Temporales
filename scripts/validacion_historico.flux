from(bucket: "estadisticas_historicas")
    |> range(
        start: 2030-06-08T18:59:00Z,
        stop: 2030-06-08T21:00:00Z
    )
    |> filter(fn: (r) =>
        r._measurement == "estadisticas_equipo_resumen_1m"
    )
    |> filter(fn: (r) =>
        r._field == "posesion_pct"
    )
    |> group()
    |> count(column: "_value")