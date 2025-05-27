# Azure AD Office 365 Group Creation Policy

Questo script PowerShell consente di limitare la creazione di Gruppi Office 365 (Unified Groups) solo ai membri di un gruppo di sicurezza specifico in Azure AD.

## Requisiti

- Permessi da Global Administrator o ruolo equivalente in Azure AD.
- Modulo AzureAD installato (`Install-Module AzureAD`).
- PowerShell 5.1 o superiore.

## Come usare

1. Clona o scarica questo repository.
2. Esegui PowerShell come amministratore.
3. Lancia lo script specificando il nome del gruppo autorizzato alla creazione gruppi:

```powershell
.\Set-GroupCreationPolicy.ps1 -GroupName "MS-Teams-Managers"
```

## Funzionamento

Lo script si connette ad Azure AD, verifica la presenza della policy `Group.Unified` e imposta la creazione di gruppi limitata solo ai membri del gruppo specificato.

## Licenza

[MIT License](LICENSE)
