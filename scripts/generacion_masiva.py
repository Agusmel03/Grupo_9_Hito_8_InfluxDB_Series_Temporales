from pathlib import Path
from datetime import datetime, timezone
import argparse
import random


# ============================================================
# HITO 8 - GENERADOR MASIVO
# Fixture 2030 - Grupo 9
#
# Genera Line Protocol de manera secuencial, sin almacenar
# todos los puntos en memoria.
#
# Permite generar desde una muestra pequena hasta 10M+ puntos.
# ============================================================


def codigo_equipo(numero):
    letras = []

    valor = numero

    for _ in range(3):
        letras.append(
            chr(ord("A") + (valor % 26))
        )
        valor //= 26

    return "".join(reversed(letras))


def main():

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--puntos",
        type=int,
        default=100000
    )

    parser.add_argument(
        "--salida",
        default="data/benchmark.lp"
    )

    args = parser.parse_args()

    random.seed(2030)

    raiz = Path(__file__).resolve().parent.parent

    archivo_salida = raiz / args.salida

    archivo_salida.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    inicio_ms = int(
        datetime.now(
            timezone.utc
        ).timestamp() * 1000
    )

    with open(
        archivo_salida,
        "w",
        encoding="utf-8",
        newline="\n"
    ) as archivo:

        for i in range(args.puntos):

            partido_numero = (
                i % 96
            ) + 1

            partido_id = (
                f"P{partido_numero:03d}"
            )

            equipo_numero = (
                i % 64
            )

            equipo_codigo = codigo_equipo(
                equipo_numero
            )

            sede_numero = (
                (partido_numero - 1) % 12
            ) + 1

            sede_id = (
                f"S{sede_numero:03d}"
            )

            timestamp_ms = (
                inicio_ms + i
            )

            posesion = random.uniform(
                38.0,
                62.0
            )

            pases = random.randint(
                0,
                700
            )

            tiros = (
                1 if random.random() < 0.01 else 0
            )

            recuperaciones = (
                1 if random.random() < 0.05 else 0
            )

            linea = (
                "estadisticas_equipo,"
                f"partido_id={partido_id},"
                f"equipo_codigo={equipo_codigo},"
                f"sede_id={sede_id} "
                f"posesion_pct={posesion:.2f},"
                f"pases_completados_total={pases}i,"
                f"tiros_intervalo={tiros}i,"
                f"recuperaciones_intervalo={recuperaciones}i "
                f"{timestamp_ms}\n"
            )

            archivo.write(linea)

    print(
        "Generacion finalizada."
    )

    print(
        f"Puntos generados: {args.puntos}"
    )

    print(
        f"Archivo: {archivo_salida}"
    )

    print(
        f"Tamano bytes: {archivo_salida.stat().st_size}"
    )


if __name__ == "__main__":
    main()