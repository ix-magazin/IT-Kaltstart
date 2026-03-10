$Computer      = "SERVER01"
$RemoteOutput  = "C:\Windows\Temp\fw_export.txt"

# PowerShell-Kommando, das remote ausgeführt wird
$PsCommand = @"
Get-NetFirewallRule |
    Select-Object DisplayName, Enabled, Direction, Action, Profile |
    Format-Table -AutoSize |
    Out-String
"@

# In eine saubere Einzeile umwandeln
$EncodedCommand = [Convert]::ToBase64String(
    [Text.Encoding]::Unicode.GetBytes($PsCommand)
)

$CommandLine = "powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $EncodedCommand > `"$RemoteOutput`" 2>&1"

Write-Host "Starte Remote-Prozess..."

# Prozess remote starten
$Result = Invoke-WmiMethod `
            -Class Win32_Process `
            -Name Create `
            -ComputerName $Computer `
            -ArgumentList $CommandLine

if ($Result.ReturnValue -ne 0) {
    Write-Host "Fehler beim Starten des Prozesses."
    return
}

Write-Host "PID: $($Result.ProcessId)"

# Kurz warten, damit Datei geschrieben wird
Start-Sleep -Seconds 4

Write-Host "Lese Ausgabe zurück..."

# Datei über WMI lesen
$EscapedPath = $RemoteOutput.Replace("\","\\")
$File = Get-WmiObject -Class CIM_DataFile `
                      -ComputerName $Computer `
                      -Filter "Name='$EscapedPath'"

if ($File -eq $null) {
    Write-Host "Datei nicht gefunden."
    return
}

$Content = ([WMI]$File.__PATH).GetText()

Write-Host "================ FIREWALL OUTPUT ================"
Write-Host $Content
Write-Host "================================================="
