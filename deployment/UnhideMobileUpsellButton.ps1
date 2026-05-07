<#
.SYNOPSIS
    Removes the "Hide Mobile Upsell Footer Button" ScriptLink from a SharePoint site collection.

.DESCRIPTION
    Removes the Location="ScriptLink" UserCustomAction previously added by
    HideMobileUpsellButton.ps1.

.PARAMETER siteCollectionUrl
    URL of the target site collection (typically the MySite host).

.PARAMETER appCatalogUrl
    URL of the SharePoint App Catalog (used to compute the same ScriptSrc URL that was
    registered originally, so the matching custom action can be located).

.EXAMPLE
    .\UnhideMobileUpsellButton.ps1 `
        -siteCollectionUrl "https://sp.contoso.local/my" `
        -appCatalogUrl     "https://sp.contoso.local/sites/appcatalog"
#>

param
(
    [Parameter(Mandatory)]
    [string]$siteCollectionUrl,
    [Parameter(Mandatory)]
    [string]$appCatalogUrl
)

$scriptSrc = "$appCatalogUrl/ClientSideAssets/025c4c9b-56f3-47ce-b70d-49ee31584f10/HideMobileUpsellButton.js"

.\AddOrRemoveUserCustomAction.ps1 -siteCollectionUrl $siteCollectionUrl -scriptSrc $scriptSrc -remove
