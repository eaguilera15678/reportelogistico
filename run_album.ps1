param(
    [int]$Port = 8000,
    [switch]$NoBrowser
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $root
try {
    # 1) Genera metadata.json desde imagen/
    .\generate_metadata.ps1

    # 2) Verifica que Python esté disponible
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        throw "Python no está en el PATH. Instálalo o ejecuta el servidor manualmente: python -m http.server $Port"
    }

    # 3) Inicia servidor HTTP simple
    Write-Host "Iniciando servidor en http://localhost:$Port/"
    $server = Start-Process -FilePath $python.Source -ArgumentList "-m","http.server","$Port" -WorkingDirectory $root -PassThru

    # 4) Abre el álbum en el navegador (espera 2 segundos para que el servidor inicie)
    if (-not $NoBrowser) {
        Start-Sleep -Seconds 2
        Start-Process "http://localhost:$Port/index%20-%20copia.html"
    }

    Write-Host "Presiona Ctrl+C en la ventana del servidor para detenerlo (PID: $($server.Id))."
    Write-Host "Álbum disponible en: http://localhost:$Port/index%20-%20copia.html"
} finally {
    Pop-Location
}
