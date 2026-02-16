param
(
    [Parameter(Mandatory)]
    [string]$siteCollectionUrl
)
.\AddOrRemoveApplicationCustomizerToOrFromSiteCollection.ps1 -SiteCollectionUrl $siteCollectionUrl -clientSideComponentId "76ea3b27-ad3e-4434-874c-8f2ac39fad77" -remove