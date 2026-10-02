param (
    [string]$Archivo = "data\estadisticas_muestra.lp",
    [string]$Bucket = "estadisticas_live",
    [int]$TamanoLote = 50000,
    [int]$MaxReintentos = 3
)

# ============================================================
# HITO 8 - CARGA POR LOTES
# Fixture 2030 - Grupo 9
#
# Divide un archivo Line Protocol en lotes y los escribe
# secuencialmente en InfluxDB.
#
# Incluye:
# - lectura de credenciales desde .env
# - batching configurable
# - reintentos ante error
# - conteo de puntos procesados
# - limpieza del archivo temporal
# ============================================================

$ErrorActionPreference = "Stop"

$Raiz = Split-Path -Parent $PSScriptRoot
$EnvPath = Join-Path $Raiz ".env"
$ArchivoCompleto = Join-Path $Raiz $Archivo
$TemporalHost = Join-Path $Raiz "data\_lote_temp.lp"

# ============================================================
# VALIDACIONES
# ============================================================

if (-not (Test-Path $EnvPath)) {
    Write-Error "No existe el archivo .env."
}

if (-not (Test-Path $ArchivoCompleto)) {
    Write-Error "No existe el archivo: $ArchivoCompleto"
}

if ($TamanoLote -le 0) {
    Write-Error "TamanoLote debe ser mayor que 0."
}

# ============================================================
# LEER .env
# ============================================================

Get-Content $EnvPath | ForEach-Object {

    if ($_ -match '^\s*([^#][^=]*)=(.*)$') {

        $nombre = $matches[1].Trim()
        $valor = $matches[2].Trim()

        Set-Item -Path "Env:$nombre" -Value $valor
    }
}

$Token = $env:INFLUXDB_TOKEN
$Org = $env:INFLUXDB_ORG

if (-not $Token) {
    Write-Error "INFLUXDB_TOKEN no esta definido en .env."
}

if (-not $Org) {
    Write-Error "INFLUXDB_ORG no esta definido en .env."
}

# ============================================================
# FUNCION PARA CARGAR UN LOTE
# ============================================================

function Enviar-Lote {

    param (
        [System.Collections.Generic.List[string]]$Lineas,
        [int]$NumeroLote
    )

    # IMPORTANTE:
    # Se escribe con LF y no CRLF para evitar errores
    # de timestamp en InfluxDB Line Protocol.

    $contenido = ($Lineas -join "`n") + "`n"

    [System.IO.File]::WriteAllText(
        $TemporalHost,
        $contenido,
        [System.Text.UTF8Encoding]::new($false)
    )

    $Intento = 1
    $CargaExitosa = $false

    while (
        (-not $CargaExitosa) -and
        ($Intento -le $MaxReintentos)
    ) {

        Write-Host ""
        Write-Host "Lote $NumeroLote - intento $Intento de $MaxReintentos"
        Write-Host "Puntos del lote: $($Lineas.Count)"

        docker exec fixture2030-influxdb influx write `
            --host http://localhost:8086 `
            --org $Org `
            --bucket $Bucket `
            --token $Token `
            --precision ms `
            --file /data/_lote_temp.lp

        if ($LASTEXITCODE -eq 0) {

            $CargaExitosa = $true

            Write-Host "Lote $NumeroLote cargado correctamente."
        }
        else {

            Write-Host "Error al cargar el lote $NumeroLote."

            if ($Intento -lt $MaxReintentos) {
                Write-Host "Reintentando..."
                Start-Sleep -Seconds 2
            }

            $Intento++
        }
    }

    if (-not $CargaExitosa) {
        Write-Error "El lote $NumeroLote fallo luego de $MaxReintentos intentos."
    }
}

# ============================================================
# PROCESAMIENTO
# ============================================================

$NumeroLote = 0
$TotalProcesado = 0

$Buffer = New-Object System.Collections.Generic.List[string]

Write-Host "============================================="
Write-Host "Carga por lotes - Hito 8"
Write-Host "============================================="
Write-Host "Archivo: $Archivo"
Write-Host "Bucket: $Bucket"
Write-Host "Tamano del lote: $TamanoLote"
Write-Host "Maximo de reintentos: $MaxReintentos"
Write-Host ""

Get-Content $ArchivoCompleto | ForEach-Object {

    $Buffer.Add($_)

    if ($Buffer.Count -ge $TamanoLote) {

        $NumeroLote++

        Enviar-Lote `
            -Lineas $Buffer `
            -NumeroLote $NumeroLote

        $TotalProcesado += $Buffer.Count

        $Buffer.Clear()
    }
}

# ============================================================
# ULTIMO LOTE
# ============================================================

if ($Buffer.Count -gt 0) {

    $NumeroLote++

    Enviar-Lote `
        -Lineas $Buffer `
        -NumeroLote $NumeroLote

    $TotalProcesado += $Buffer.Count

    $Buffer.Clear()
}

# ============================================================
# LIMPIEZA
# ============================================================

if (Test-Path $TemporalHost) {
    Remove-Item $TemporalHost
}

Write-Host ""
Write-Host "============================================="
Write-Host "Carga finalizada"
Write-Host "============================================="
Write-Host "Lotes procesados: $NumeroLote"
Write-Host "Puntos procesados: $TotalProcesado"