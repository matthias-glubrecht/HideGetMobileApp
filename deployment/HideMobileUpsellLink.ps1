<#
.SYNOPSIS
    Registers the "Hide Mobile Upsell In-Page Banner" Application Customizer on a SharePoint site collection.

.DESCRIPTION
    Adds a Location="ClientSideExtension.ApplicationCustomizer" UserCustomAction that activates
    the SPFx Application Customizer (ClientSideComponentId 76ea3b27-ad3e-4434-874c-8f2ac39fad77)
    on the target site collection. The customizer injects CSS that hides the in-page
    <div class="feedback_…"> container wrapping the "Get the mobile app" link.

    Run this once per site collection where the in-page banner should be hidden.

.PARAMETER siteCollectionUrl
    URL of the target site collection.

.EXAMPLE
    .\HideMobileUpsellLink.ps1 -siteCollectionUrl "https://sp.contoso.local/sites/site1"
#>

param
(
    [Parameter(Mandatory)]
    [string]$siteCollectionUrl
)
.\AddOrRemoveUserCustomAction.ps1 -SiteCollectionUrl $siteCollectionUrl -clientSideComponentId "76ea3b27-ad3e-4434-874c-8f2ac39fad77"