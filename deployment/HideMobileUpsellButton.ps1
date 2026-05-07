<#
.SYNOPSIS
    Registers the "Hide Mobile Upsell Footer Button" ScriptLink on a SharePoint site collection.

.DESCRIPTION
    Adds a Location="ScriptLink" UserCustomAction that loads HideMobileUpsellButton.js (shipped
    inside the .sppkg as a ClientSideAsset) on every page of the target site collection. The
    script injects CSS that hides the <a class="MobileUpsellFooterButtonView"> footer button.

    Typical target is the MySite host site collection (e.g. https://contoso-my.sharepoint.com/).

.PARAMETER siteCollectionUrl
    URL of the target site collection (typically the MySite host).

.PARAMETER appCatalogUrl
    URL of the SharePoint App Catalog where the .sppkg has been deployed.

.EXAMPLE
    .\HideMobileUpsellButton.ps1 `
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

.\AddOrRemoveUserCustomAction.ps1 -siteCollectionUrl $siteCollectionUrl -scriptSrc $scriptSrc
