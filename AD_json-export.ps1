# Export AD PowerShell

<#
.SYNOPSIS
    Exportiert kritische AD Informationen in strukturierte JSON-Datei
.DESCRIPTION
    Exportiert OUs, Users, Computer, Service Accounts, Gruppen inkl. Memberships
#>

Import-Module ActiveDirectory

$ExportPath = "C:\AD-Export"
$Timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$JsonFile   = "$ExportPath\AD-Export-$Timestamp.json"

if (!(Test-Path $ExportPath)) {
    New-Item -ItemType Directory -Path $ExportPath | Out-Null
}

Write-Host "Starte AD Export..."

# ========================
# ORGANISATIONAL UNITS
# ========================
$OUs = Get-ADOrganizationalUnit -Filter * -Properties * |
Select-Object `
    Name,
    DistinguishedName,
    ObjectGUID,
    ObjectClass,
    WhenCreated,
    WhenChanged,
    ProtectedFromAccidentalDeletion

# ========================
# USERS
# ========================
$Users = Get-ADUser -Filter * -Properties * |
Select-Object `
    SamAccountName,
    Name,
    GivenName,
    Surname,
    UserPrincipalName,
    DistinguishedName,
    ObjectSID,
    ObjectGUID,
    Enabled,
    LastLogonDate,
    PasswordLastSet,
    PasswordNeverExpires,
    CannotChangePassword,
    AccountExpirationDate,
    ServicePrincipalName,
    AdminCount,
    MemberOf,
    msDS-AllowedToDelegateTo,
    msDS-SupportedEncryptionTypes

# ========================
# COMPUTER OBJECTS
# ========================
$Computers = Get-ADComputer -Filter * -Properties * |
Select-Object `
    Name,
    SamAccountName,
    DistinguishedName,
    ObjectSID,
    ObjectGUID,
    Enabled,
    OperatingSystem,
    OperatingSystemVersion,
    LastLogonDate,
    ServicePrincipalName,
    MemberOf,
    msDS-AllowedToDelegateTo,
    msDS-SupportedEncryptionTypes

# ========================
# GROUPS
# ========================
$Groups = Get-ADGroup -Filter * -Properties * |
ForEach-Object {
    [PSCustomObject]@{
        Name              = $_.Name
        SamAccountName    = $_.SamAccountName
        DistinguishedName = $_.DistinguishedName
        ObjectSID         = $_.ObjectSID
        ObjectGUID        = $_.ObjectGUID
        GroupScope        = $_.GroupScope
        GroupCategory     = $_.GroupCategory
        Members           = (Get-ADGroupMember $_ -Recursive | Select-Object -ExpandProperty DistinguishedName)
        WhenCreated       = $_.WhenCreated
        WhenChanged       = $_.WhenChanged
    }
}

# ========================
# SERVICE ACCOUNTS (gMSA & sMSA)
# ========================
$ServiceAccounts = Get-ADServiceAccount -Filter * -Properties * |
Select-Object `
    Name,
    SamAccountName,
    DistinguishedName,
    ObjectSID,
    ObjectGUID,
    ServicePrincipalNames,
    msDS-GroupMSAMembership,
    PrincipalsAllowedToRetrieveManagedPassword,
    Enabled

# ========================
# DOMAIN INFO
# ========================
$DomainInfo = Get-ADDomain | Select-Object *
$ForestInfo = Get-ADForest | Select-Object *

# ========================
# EXPORT STRUCTURE
# ========================
$ExportObject = [PSCustomObject]@{
    ExportTimestamp = Get-Date
    Domain          = $DomainInfo
    Forest          = $ForestInfo
    OrganizationalUnits = $OUs
    Users           = $Users
    Computers       = $Computers
    Groups          = $Groups
    ServiceAccounts = $ServiceAccounts
}

Write-Host "Erzeuge JSON..."

$ExportObject | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $JsonFile

Write-Host "Export abgeschlossen: $JsonFile"

