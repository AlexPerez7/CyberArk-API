# ========================== #
#   CyberArk License Check   #
#   Compatible con Gen2 clásico
#   Uso general para múltiples clientes
# ========================== #

# ====== CONFIGURACIÓN GENERAL ======
# Solicita el subdominio del cliente (ej. "midominio" para https://midominio.privilegecloud.cyberark.cloud)
$Subdomain = Read-Host "🔧 Ingresa el subdominio del cliente (sin dominio completo)"
$BaseUrl   = "https://$Subdomain.privilegecloud.cyberark.cloud/PasswordVault/API"

# Endpoints REST
$LogonUrl    = "$BaseUrl/auth/CyberArk/Logon"
$LicensesUrl = "$BaseUrl/licenses/pcloud/"

# ====== INGRESO SEGURO DE CREDENCIALES ======
$Username = Read-Host "👤 Usuario (ej: installeruser@cyberark.cloud.midominio)"
$Password = Read-Host "🔑 Password" -AsSecureString

# Conversión de SecureString a texto plano de forma segura (necesario para autenticación API)
$BSTR     = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$PlainPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# ====== AUTENTICACIÓN ======
$LogonHeaders = @{ "Content-Type" = "application/json" }
$LogonBody    = @{ username = $Username; password = $PlainPwd } | ConvertTo-Json

try {
    $raw = Invoke-WebRequest -Uri $LogonUrl -Method POST -Headers $LogonHeaders -Body $LogonBody -ErrorAction Stop
    $SessionToken = $raw.Content.Trim('"')  # El token viene como string plano, no JSON
    if (-not $SessionToken) { throw "No se recibió token en Logon." }
    Write-Host "`n✅ Logon OK. Token de sesión obtenido.`n"
}
catch {
    Write-Host "❌ Error en Logon: $($_.Exception.Message)"
    return
}
finally {
    # Limpieza segura de contraseña en memoria
    if ($BSTR) { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR) }
    $PlainPwd = $null
}

# ====== CONSULTA DE LICENCIAS ======
$LicHeaders = @{
    "Authorization" = $SessionToken  # En Gen2 clásico no usa 'Bearer'
    "Content-Type"  = "application/json"
}

try {
    $resp = Invoke-RestMethod -Uri $LicensesUrl -Method GET -Headers $LicHeaders -ErrorAction Stop
    Write-Host "✅ Licencias obtenidas correctamente:`n"
    $resp | ConvertTo-Json -Depth 6

    # ====== VALIDACIÓN DE UMBRAL DE USO TOTAL ======
    $used = [int]$resp.optionalSummary.used
    $total = [int]$resp.optionalSummary.total
    $porcentaje = ($used / $total) * 100

    if ($porcentaje -ge 90) {
        Write-Warning "⚠️ Alerta: Uso de licencias sobrepasa el 90% ($used de $total - $([math]::Round($porcentaje,2))%)"
    } else {
        Write-Host "✅ Uso dentro de límites: $used de $total en uso ($([math]::Round($porcentaje,2))%)"
    }

    # ====== EXPORTACIÓN DE DATOS A CSV ======
    $output = $resp.licensesData.licencesElements | ForEach-Object {
        [PSCustomObject]@{
            TipoLicencia = $_.name
            EnUso        = $_.used
            Total        = $_.total
        }
    }

    # Archivo con timestamp para seguimiento histórico
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $csvFile = "LicenciasCyberArk_$Subdomain`_$timestamp.csv"
    $output | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8

    Write-Host "`n💾 Licencias exportadas a archivo: $csvFile"
}
catch {
    Write-Host "❌ Error al consultar licencias: $($_.Exception.Message)"
    Write-Host "ℹ️ Si obtienes código 401, prueba con 'Bearer ' + token:"
    Write-Host "   Set-Item -Path variable:LicHeaders['Authorization'] -Value ('Bearer ' + $SessionToken)"
}
