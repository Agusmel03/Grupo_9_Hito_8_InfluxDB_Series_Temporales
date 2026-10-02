from(bucket: "estadisticas_live")
    |> range(
        start: 2030-06-08T18:59:00Z,
        stop: 2030-06-08T21:00:00Z
    )
    |> filter(fn: (r) =>
        r._measurement == "estadisticas_equipo"
    )
    |> filter(fn: (r) =>
        r._field == "posesion_pct"
    )
    |> group(
        columns: [
            "partido_id",
            "equipo_codigo",
            "sede_id"
        ]
    )
    |> count(column: "_value")
    |> keep(
        columns: [
            "partido_id",
            "equipo_codigo",
            "sede_id",
            "_value"
        ]
    )
    |> sort(
        columns: [
            "partido_id",
            "equipo_codigo"
        ]
    )