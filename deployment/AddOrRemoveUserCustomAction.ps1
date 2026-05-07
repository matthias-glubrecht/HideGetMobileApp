<#
.SYNOPSIS
    Adds or removes a UserCustomAction (Application Customizer or ScriptLink) on a SharePoint site collection.

.DESCRIPTION
    Two parameter sets:

    * ApplicationCustomizer (default) — registers/removes a ClientSideExtension.ApplicationCustomizer
      UserCustomAction. Backwards compatible with the previous single-purpose script.

    * ScriptLink — registers/removes a Location="ScriptLink" UserCustomAction that loads a JavaScript
      file (typically a ClientSideAsset shipped inside the .sppkg) on every page of the site collection.

.PARAMETER siteCollectionUrl
    URL of the target site collection.

.PARAMETER clientSideComponentId
    GUID of the SPFx Application Customizer component (ApplicationCustomizer parameter set).

.PARAMETER scriptSrc
    Absolute URL of the JavaScript file to load (ScriptLink parameter set). Typically:
    "{appCatalogUrl}/ClientSideAssets/{solutionId}/<file>.js".

.PARAMETER sequence
    Optional execution order for the ScriptLink (default: 1).

.PARAMETER remove
    Switch — remove the matching UserCustomAction instead of adding it.

.EXAMPLE
    .\AddOrRemoveUserCustomAction.ps1 -siteCollectionUrl "https://sp.contoso.local/sites/site1" `
                                      -clientSideComponentId "76ea3b27-ad3e-4434-874c-8f2ac39fad77"

.EXAMPLE
    .\AddOrRemoveUserCustomAction.ps1 -siteCollectionUrl "https://sp.contoso.local/my" `
                                      -scriptSrc "https://sp.contoso.local/sites/appcatalog/ClientSideAssets/025c4c9b-56f3-47ce-b70d-49ee31584f10/HideMobileUpsellButton.js"
#>

[CmdletBinding(DefaultParameterSetName = 'ApplicationCustomizer')]
param
(
    [Parameter(Mandatory)]
    [string]$siteCollectionUrl,

    [Parameter(Mandatory, ParameterSetName = 'ApplicationCustomizer')]
    [string]$clientSideComponentId,

    [Parameter(Mandatory, ParameterSetName = 'ScriptLink')]
    [string]$scriptSrc,

    [Parameter(ParameterSetName = 'ScriptLink')]
    [int]$sequence = 1,

    [switch]$remove
)

try
{
    Add-Type -Path "C:\program files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
    Add-Type -Path "C:\program files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
}
catch
{
    try
    {
        Add-Type -Path "C:\program files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "C:\program files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
    }
    catch
    {
        try
        {
            Add-Type -Path "$PSScriptRoot\Microsoft.SharePoint.Client.dll"
            Add-Type -Path "$PSScriptRoot\Microsoft.SharePoint.Client.Runtime.dll"
        }
        catch
        {
            Write-Host "Die SharePoint-Client-DLLs wurden nicht gefunden." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red;
            return;
        }
    }
}

function Get-CUApplicationCustomizer([Microsoft.SharePoint.Client.ClientContext]$ctx, [string]$componentId)
{
    $userCustomActions = $ctx.Site.UserCustomActions
    $ctx.Load($userCustomActions)
    $ctx.ExecuteQuery();

    foreach ($userCustomAction in $userCustomActions)
    {
        if ($userCustomAction.Location -eq "ClientSideExtension.ApplicationCustomizer" -and $userCustomAction.ClientSideComponentId -eq $componentId)
        {
            Write-Host "Application Customizer bereits vorhanden."
            return $userCustomAction;
        }
    }
    return $null;
}

function Remove-CUApplicationCustomizer([Microsoft.SharePoint.Client.ClientContext]$ctx, [string]$componentId)
{
    $uca = Get-CUApplicationCustomizer -ctx $ctx -componentId $componentId
    if ($uca) 
    {
        $uca.DeleteObject();
        $ctx.ExecuteQuery();
        Write-Host "Application Customizer mit der componentId '$componentId' wurde gelöscht." -ForegroundColor Green;
    }
}

function Add-CUApplicationCustomizer([Microsoft.SharePoint.Client.ClientContext]$ctx, [string]$componentId)
{
    if ($null -eq (Get-CUApplicationCustomizer -ctx $ctx -componentId $componentId))
    {
        $userCustomActions = $ctx.Site.UserCustomActions
        $newUserCustomAction = $userCustomActions.Add()
        $newUserCustomAction.Location = "ClientSideExtension.ApplicationCustomizer";
        $newUserCustomAction.Title = $newUserCustomAction.Name = "Ein Application Customizer" # Nur für's Auge
        $newUserCustomAction.Sequence = 1;
        $newUserCustomAction.ClientSideComponentId = $componentId
        $newUserCustomAction.ClientSideComponentProperties = ConvertTo-Json @{}
        $newUserCustomAction.Update();
        Write-Host "Speichere UserCustomAction..." -NoNewline
        $ctx.ExecuteQuery();
        Write-Host " Erfolg!" -ForegroundColor Green
    }
}

function Get-CUScriptLink([Microsoft.SharePoint.Client.ClientContext]$ctx, [string]$src)
{
    $userCustomActions = $ctx.Site.UserCustomActions
    $ctx.Load($userCustomActions)
    $ctx.ExecuteQuery();

    foreach ($userCustomAction in $userCustomActions)
    {
        if ($userCustomAction.Location -eq "ScriptLink" -and $userCustomAction.ScriptSrc -eq $src)
        {
            Write-Host "ScriptLink bereits vorhanden."
            return $userCustomAction;
        }
    }
    return $null;
}

function Remove-CUScriptLink([Microsoft.SharePoint.Client.ClientContext]$ctx, [string]$src)
{
    $uca = Get-CUScriptLink -ctx $ctx -src $src
    if ($uca)
    {
        $uca.DeleteObject();
        $ctx.ExecuteQuery();
        Write-Host "ScriptLink für '$src' wurde gelöscht." -ForegroundColor Green;
    }
}

function Add-CUScriptLink([Microsoft.SharePoint.Client.ClientContext]$ctx, [string]$src, [int]$seq)
{
    if ($null -eq (Get-CUScriptLink -ctx $ctx -src $src))
    {
        $userCustomActions = $ctx.Site.UserCustomActions
        $newUserCustomAction = $userCustomActions.Add()
        $newUserCustomAction.Location = "ScriptLink";
        $newUserCustomAction.Title = $newUserCustomAction.Name = "Ein ScriptLink" # Nur für's Auge
        $newUserCustomAction.ScriptSrc = $src
        $newUserCustomAction.Sequence = $seq
        $newUserCustomAction.Update();
        Write-Host "Speichere ScriptLink..." -NoNewline
        $ctx.ExecuteQuery();
        Write-Host " Erfolg!" -ForegroundColor Green
    }
}

# This may be necessary if you use self signed certificates in your SharePoint farm
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteCollectionUrl)

switch ($PSCmdlet.ParameterSetName)
{
    'ApplicationCustomizer'
    {
        if ($remove.IsPresent)
        {
            Remove-CUApplicationCustomizer -ctx $ctx -componentId $clientSideComponentId
        }
        else
        {
            Add-CUApplicationCustomizer -ctx $ctx -componentId $clientSideComponentId
        }
    }
    'ScriptLink'
    {
        if ($remove.IsPresent)
        {
            Remove-CUScriptLink -ctx $ctx -src $scriptSrc
        }
        else
        {
            Add-CUScriptLink -ctx $ctx -src $scriptSrc -seq $sequence
        }
    }
}
