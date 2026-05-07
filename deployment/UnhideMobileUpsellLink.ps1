<#
.SYNOPSIS
    Removes the "Hide Mobile Upsell In-Page Banner" Application Customizer from a SharePoint site collection.

.DESCRIPTION
    Removes the Location="ClientSideExtension.ApplicationCustomizer" UserCustomAction
    (ClientSideComponentId 76ea3b27-ad3e-4434-874c-8f2ac39fad77) previously added by
    HideMobileUpsellLink.ps1, re-enabling the in-page "Get the mobile app" banner on the
    target site collection.

.PARAMETER siteCollectionUrl
    URL of the target site collection.

.EXAMPLE
    .\UnhideMobileUpsellLink.ps1 -siteCollectionUrl "https://sp.contoso.local/sites/site1"
#>

param
(
    [Parameter(Mandatory)]
    [string]$siteCollectionUrl
)
.\AddOrRemoveUserCustomAction.ps1 -SiteCollectionUrl $siteCollectionUrl -clientSideComponentId "76ea3b27-ad3e-4434-874c-8f2ac39fad77" -remove