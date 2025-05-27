<#
.SYNOPSIS
    Limita la creazione di Gruppi Office 365 solo ai membri di un gruppo di sicurezza specifico in Azure AD.

.DESCRIPTION
    Lo script si connette ad Azure AD, verifica o crea la directory setting 'Group.Unified',
    e applica una policy per abilitare la creazione di gruppi solo ai membri del gruppo specificato.

.PARAMETER GroupName
    Nome del gruppo di sicurezza AD autorizzato a creare gruppi Office 365.

.EXAMPLE
    .\Set-GroupCreationPolicy.ps1 -GroupName "MS-Teams-Managers"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

try {
    Write-Host "Connessione ad Azure AD..."
    Connect-AzureAD -ErrorAction Stop

    Write-Host "Recupero gruppo '$GroupName'..."
    $Group = Get-AzureADGroup -SearchString $GroupName -ErrorAction Stop | Where-Object { $_.DisplayName -eq $GroupName }

    if (-not $Group) {
        throw "Gruppo '$GroupName' non trovato in Azure AD."
    }

    $GroupID = $Group.ObjectId
    Write-Host "Gruppo trovato. ObjectId: $GroupID"

    Write-Host "Verifica impostazioni Group.Unified..."
    $GroupCreationSettings = Get-AzureADDirectorySetting | Where-Object { $_.DisplayName -eq "Group.Unified" }

    if (-not $GroupCreationSettings) {
        Write-Host "Impostazioni non trovate, creazione da template..."
        $Template = Get-AzureADDirectorySettingTemplate | Where-Object { $_.DisplayName -eq "Group.Unified" }
        if (-not $Template) {
            throw "Template 'Group.Unified' non trovato."
        }
        $DirectorySettings = $Template.CreateDirectorySetting()
        New-AzureADDirectorySetting -DirectorySetting $DirectorySettings -ErrorAction Stop
        $GroupCreationSettings = Get-AzureADDirectorySetting | Where-Object { $_.DisplayName -eq "Group.Unified" }
    }

    Write-Host "Applicazione impostazioni per limitare creazione gruppi..."
    $GroupCreationSettings["EnableGroupCreation"] = "False"
    $GroupCreationSettings["GroupCreationAllowedGroupId"] = $GroupID

    Set-AzureADDirectorySetting -Id $GroupCreationSettings.Id -DirectorySetting $GroupCreationSettings -ErrorAction Stop

    Write-Host "Impostazioni aggiornate con successo:"
    (Get-AzureADDirectorySetting -Id $GroupCreationSettings.Id).Values | Format-Table -AutoSize
}
catch {
    Write-Error "Errore: $_"
    exit 1
}
