from pathlib import Path
from datetime import datetime, timedelta
import random

# ============================================================
# HITO 8 - FIXTURE 2030
# Generacion reproducible de estadisticas temporales
# Grupo 9
# ============================================================

random.seed(2030)

INTERVALO_SEGUNDOS = 5
DURACION_MINUTOS = 90

PUNTOS_POR_EQUIPO = (
    DURACION_MINUTOS * 60
) // INTERVALO_SEGUNDOS


# ------------------------------------------------------------
# Se mantienen identificadores coherentes con los hitos
# anteriores del Fixture 2030.
#
# P001, P002, etc. corresponden a los partidos.
# AAA, AAB, etc. corresponden a los codigos de equipos.
# S001, S002, etc. corresponden a las sedes.
# ------------------------------------------------------------

PARTIDOS = [
    {
        "partido_id": "P001",
        "local": "AAA",
        "visitante": "AAB",
        "sede_id": "S001",
        "inicio": "2030-06-08T19:00:00Z"
    },
    {
        "partido_id": "P002",
        "local": "AAA",
        "visitante": "AAC",
        "sede_id": "S002",
        "inicio": "2030-06-08T19:00:00Z"
    },
    {
        "partido_id": "P003",
        "local": "AAA",
        "visitante": "AAD",
        "sede_id": "S003",
        "inicio": "2030-06-08T19:00:00Z"
    },
    {
        "partido_id": "P004",
        "local": "AAB",
        "visitante": "AAC",
        "sede_id": "S004",
        "inicio": "2030-06-08T19:00:00Z"
    }
]


def limitar(valor, minimo, maximo):
    return max(minimo, min(maximo, valor))


def instante_a_ms(instante):
    return int(instante.timestamp() * 1000)


def linea_influx(
    partido_id,
    equipo_codigo,
    sede_id,
    timestamp_ms,
    posesion,
    pases,
    tiros,
    recuperaciones
):
    return (
        f"estadisticas_equipo,"
        f"partido_id={partido_id},"
        f"equipo_codigo={equipo_codigo},"
        f"sede_id={sede_id} "
        f"posesion_pct={posesion:.2f},"
        f"pases_completados_total={pases}i,"
        f"tiros_intervalo={tiros}i,"
        f"recuperaciones_intervalo={recuperaciones}i "
        f"{timestamp_ms}"
    )


def generar_partido(partido):

    inicio = datetime.fromisoformat(
        partido["inicio"].replace(
            "Z",
            "+00:00"
        )
    )

    posesion_local = 50.0

    pases_local = 0
    pases_visitante = 0

    lineas = []

    for indice in range(PUNTOS_POR_EQUIPO):

        instante = inicio + timedelta(
            seconds=indice * INTERVALO_SEGUNDOS
        )

        timestamp_ms = instante_a_ms(instante)

        # ====================================================
        # POSESION
        #
        # Medida de tipo gauge.
        # Representa un porcentaje observado en un instante.
        # Los dos equipos suman aproximadamente 100%.
        # ====================================================

        posesion_local += random.uniform(
            -0.35,
            0.35
        )

        posesion_local = limitar(
            posesion_local,
            38.0,
            62.0
        )

        posesion_visitante = (
            100.0 - posesion_local
        )

        # ====================================================
        # PASES COMPLETADOS
        #
        # Contador acumulativo.
        # El valor no disminuye durante el partido.
        # ====================================================

        pases_local += random.choices(
            [0, 1, 2],
            weights=[55, 40, 5]
        )[0]

        pases_visitante += random.choices(
            [0, 1, 2],
            weights=[55, 40, 5]
        )[0]

        # ====================================================
        # TIROS
        #
        # Cantidad de eventos ocurridos dentro del intervalo.
        # ====================================================

        tiros_local = (
            1 if random.random() < 0.009 else 0
        )

        tiros_visitante = (
            1 if random.random() < 0.009 else 0
        )

        # ====================================================
        # RECUPERACIONES
        #
        # Cantidad de recuperaciones ocurridas dentro del
        # intervalo temporal.
        # ====================================================

        recuperaciones_local = (
            1 if random.random() < 0.045 else 0
        )

        recuperaciones_visitante = (
            1 if random.random() < 0.045 else 0
        )

        # ====================================================
        # EQUIPO LOCAL
        # ====================================================

        lineas.append(
            linea_influx(
                partido["partido_id"],
                partido["local"],
                partido["sede_id"],
                timestamp_ms,
                posesion_local,
                pases_local,
                tiros_local,
                recuperaciones_local
            )
        )

        # ====================================================
        # EQUIPO VISITANTE
        # ====================================================

        lineas.append(
            linea_influx(
                partido["partido_id"],
                partido["visitante"],
                partido["sede_id"],
                timestamp_ms,
                posesion_visitante,
                pases_visitante,
                tiros_visitante,
                recuperaciones_visitante
            )
        )

    return lineas


def main():

    raiz = Path(__file__).resolve().parent.parent

    archivo_salida = (
        raiz
        / "data"
        / "estadisticas_muestra.lp"
    )

    lineas = []

    for partido in PARTIDOS:
        lineas.extend(
            generar_partido(partido)
        )

    # ========================================================
    # IMPORTANTE:
    # newline="\n" evita que Windows genere CRLF.
    #
    # InfluxDB Line Protocol necesita que cada punto termine
    # correctamente en LF.
    # ========================================================

    with open(
        archivo_salida,
        "w",
        encoding="utf-8",
        newline="\n"
    ) as archivo:

        archivo.write(
            "\n".join(lineas) + "\n"
        )

    print(
        "Archivo generado correctamente."
    )

    print(
        f"Partidos: {len(PARTIDOS)}"
    )

    print(
        "Equipos por partido: 2"
    )

    print(
        f"Intervalo temporal: "
        f"{INTERVALO_SEGUNDOS} segundos"
    )

    print(
        f"Duracion simulada: "
        f"{DURACION_MINUTOS} minutos"
    )

    print(
        f"Puntos por equipo: "
        f"{PUNTOS_POR_EQUIPO}"
    )

    print(
        f"Total de puntos: "
        f"{len(lineas)}"
    )

    print(
        f"Archivo: {archivo_salida}"
    )


if __name__ == "__main__":
    main()