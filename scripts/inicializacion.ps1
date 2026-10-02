# ============================================================
# HITO 8 - INICIALIZACION
# Fixture 2030 - Grupo 9
# ============================================================

$ErrorActionPreference = "Stop"

$Raiz = Split-Path -Parent $PSScriptRoot
$EnvPath = Join-Path $Raiz ".env"

if (-not (Test-Path $EnvPath)) {
    Write-Error "No existe el archivo .env."
}

# ============================================================
# LEER VARIABLES DESDE .env
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
# VERIFICAR INFLUXDB
# ============================================================

Write-Host "Verificando InfluxDB..."

docker exec fixture2030-influxdb influx ping

if ($LASTEXITCODE -ne 0) {
    Write-Error "InfluxDB no esta disponible."
}

Write-Host ""
Write-Host "Buckets actuales:"

$buckets = docker exec fixture2030-influxdb influx bucket list `
    --host http://localhost:8086 `
    --org $Org `
    --token $Token

$buckets

# Convertimos toda la salida a un unico texto para validar
# correctamente la existencia de los buckets.

$bucketsTexto = $buckets -join "`n"

# ============================================================
# BUCKET HISTORICO
# ============================================================

if ($bucketsTexto -notmatch "estadisticas_historicas") {

    Write-Host ""
    Write-Host "Creando estadisticas_historicas..."

    docker exec fixture2030-influxdb influx bucket create `
        --host http://localhost:8086 `
        --org $Org `
        --name estadisticas_historicas `
        --retention 8760h `
        --token $Token

    if ($LASTEXITCODE -ne 0) {
        Write-Error "No se pudo crear estadisticas_historicas."
    }
}
else {

    Write-Host ""
    Write-Host "estadisticas_historicas ya existe."
}

# ============================================================
# BUCKET BENCHMARK
# ============================================================

if ($bucketsTexto -notmatch "estadisticas_benchmark") {

    Write-Host ""
    Write-Host "Creando estadisticas_benchmark..."

    docker exec fixture2030-influxdb influx bucket create `
        --host http://localhost:8086 `
        --org $Org `
        --name estadisticas_benchmark `
        --retention 24h `
        --token $Token

    if ($LASTEXITCODE -ne 0) {
        Write-Error "No se pudo crear estadisticas_benchmark."
    }
}
else {

    Write-Host ""
    Write-Host "estadisticas_benchmark ya existe."
}

# ============================================================
# RESULTADO FINAL
# ============================================================

Write-Host ""
Write-Host "Inicializacion finalizada."
Write-Host ""

docker exec fixture2030-influxdb influx bucket list `
    --host http://localhost:8086 `
    --org $Org `
    --token $Token