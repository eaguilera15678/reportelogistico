param(
    [string]$Folder = ""
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetFolder = if ([string]::IsNullOrWhiteSpace($Folder)) {
    Join-Path $root "imagen"
} else {
    $Folder
}

if (-not (Test-Path $targetFolder)) {
    throw "Carpeta no encontrada: $targetFolder"
}

$shell = New-Object -ComObject Shell.Application

function Get-Prop {
    param($dir, $item, [int]$index)
    $value = $dir.GetDetailsOf($item, $index)
    if ([string]::IsNullOrWhiteSpace($value)) { return $null }
    return $value.Trim()
}

$imagenes = Get-ChildItem $targetFolder -File | ForEach-Object {
    $dir = $shell.Namespace($_.DirectoryName)
    $item = $dir.ParseName($_.Name)

    $titulo = (Get-Prop $dir $item 21) -as [string]
    $comentarios = (Get-Prop $dir $item 24) -as [string]
    
    # Extraer título corto (primera parte antes de ':' o '.')
    $tituloCorto = if ($titulo) {
        $titulo -replace '[:.].*$', ''
    } else {
        $_.BaseName
    }

    [PSCustomObject]@{
        archivo       = $_.Name
        titulo        = $tituloCorto.Trim()
        descripcion   = if ($comentarios) { $comentarios.Trim() } else { $titulo }
        fecha_captura = (Get-Prop $dir $item 12) -as [string]
    }
}

$output = @{ imagenes = $imagenes } | ConvertTo-Json -Depth 3
Set-Content -Path (Join-Path $root "metadata.json") -Value $output -Encoding utf8

Write-Host "metadata.json actualizado con $($imagenes.Count) entradas desde: $targetFolder"
