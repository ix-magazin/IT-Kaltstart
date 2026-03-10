# Import AD PowerShell

<#
.SYNOPSIS
    Rebuild Active Directory from JSON Export
#>

Import-Module ActiveDirectory

$JsonFile = "C:\AD-Export\AD-Export.json"
$DefaultPassword = ConvertTo-SecureString "TempP@ssw0rd123!" -AsPlainText -Force

$Data = Get-Content $JsonFile -Raw | ConvertFrom-Json

Write-Host "Starte AD Wiederherstellung..."

# ========================
# 1. OU STRUKTUR
# ========================
foreach ($OU in $Data.OrganizationalUnits) {

    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$($OU.DistinguishedName)'" -ErrorAction SilentlyContinue)) {
        Write-Host "Erstelle OU: $($OU.Name)"
        New-ADOrganizationalUnit `
            -Name $OU.Name `
            -Path ($OU.DistinguishedName -replace "^OU=.*?,","") `
            -ProtectedFromAccidentalDeletion $OU.ProtectedFromAccidentalDeletion
    }
}

# ========================
# 2. GRUPPEN
# ========================
foreach ($Group in $Data.Groups) {

    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$($Group.SamAccountName)'" -ErrorAction SilentlyContinue)) {
        Write-Host "Erstelle Gruppe: $($Group.Name)"

        New-ADGroup `
            -Name $Group.Name `
            -SamAccountName $Group.SamAccountName `
            -GroupScope $Group.GroupScope `
            -GroupCategory $Group.GroupCategory `
            -Path ($Group.DistinguishedName -replace "^CN=.*?,","")
    }
}

# ========================
# 3. USER
# ========================
foreach ($User in $Data.Users) {

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($User.SamAccountName)'" -ErrorAction SilentlyContinue)) {

        Write-Host "Erstelle User: $($User.SamAccountName)"

        New-ADUser `
            -Name $User.Name `
            -SamAccountName $User.SamAccountName `
            -UserPrincipalName $User.UserPrincipalName `
            -GivenName $User.GivenName `
            -Surname $User.Surname `
            -Path ($User.DistinguishedName -replace "^CN=.*?,","") `
            -AccountPassword $DefaultPassword `
            -Enabled $User.Enabled `
            -PasswordNeverExpires $User.PasswordNeverExpires

        # SPNs wieder setzen
        if ($User.ServicePrincipalName) {
            Set-ADUser $User.SamAccountName -ServicePrincipalNames $User.ServicePrincipalName
        }

        # Delegation
        if ($User.'msDS-AllowedToDelegateTo') {
            Set-ADUser $User.SamAccountName -Add @{
                'msDS-AllowedToDelegateTo' = $User.'msDS-AllowedToDelegateTo'
            }
        }
    }
}

# ========================
# 4. COMPUTER
# ========================
foreach ($Computer in $Data.Computers) {

    if (-not (Get-ADComputer -Filter "SamAccountName -eq '$($Computer.SamAccountName)'" -ErrorAction SilentlyContinue)) {

        Write-Host "Erstelle Computer: $($Computer.Name)"

        New-ADComputer `
            -Name $Computer.Name `
            -SamAccountName $Computer.SamAccountName `
            -Path ($Computer.DistinguishedName -replace "^CN=.*?,","") `
            -Enabled $Computer.Enabled
    }
}

# ========================
# 5. SERVICE ACCOUNTS
# ========================
foreach ($SA in $Data.ServiceAccounts) {

    if (-not (Get-ADServiceAccount -Filter "SamAccountName -eq '$($SA.SamAccountName)'" -ErrorAction SilentlyContinue)) {

        Write-Host "Erstelle Service Account: $($SA.Name)"

        New-ADServiceAccount `
            -Name $SA.Name `
            -SamAccountName $SA.SamAccountName `
            -Path ($SA.DistinguishedName -replace "^CN=.*?,","")
    }
}

# ========================
# 6. GRUPPEN MITGLIEDSCHAFTEN
# ========================
foreach ($Group in $Data.Groups) {

    foreach ($Member in $Group.Members) {

        try {
            Add-ADGroupMember `
                -Identity $Group.SamAccountName `
                -Members $Member `
                -ErrorAction Stop
        }
        catch {
            Write-Warning "Mitglied konnte nicht hinzugefügt werden: $Member"
        }
    }
}

Write-Host "AD Rekonstruktion abgeschlossen."
