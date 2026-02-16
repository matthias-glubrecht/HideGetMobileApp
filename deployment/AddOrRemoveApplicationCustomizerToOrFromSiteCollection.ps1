<#
    Add or remove application customizer to or from a site collection
#>

param
(
    [Parameter(Mandatory)]
    [string]$siteCollectionUrl,
    [Parameter(Mandatory)]
    [string]$clientSideComponentId,
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

# This may be necessary if you use self signed certificates in your SharePoint farm
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteCollectionUrl)

if ($remove.IsPresent)
{
    Remove-CUApplicationCustomizer -ctx $ctx -componentId $clientSideComponentId
}
else
{
    Add-CUApplicationCustomizer -ctx $ctx -componentId $clientSideComponentId
}