# Hide "Get the Mobile App" — SPFx Application Customizer

A SharePoint Framework (SPFx) Application Customizer that hides the **"Get the mobile app"** upsell link from SharePoint SE pages.

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Building the Solution](#building-the-solution)
- [Deployment](#deployment)
- [Adding to a Site Collection](#adding-to-a-site-collection)
- [Removing from a Site Collection](#removing-from-a-site-collection)
- [Compatibility](#compatibility)
- [Version History](#version-history)
- [Author](#author)
- [License](#license)

## Overview

SharePoint SE displays a **"Get the mobile app"** promotional link to users. This link cannot be disabled through standard SharePoint admin settings. This Application Customizer injects a small CSS rule to hide the link from the UI.

## How It Works

The extension injects a `<style>` element into the page using the following CSS selector:

```css
div[class*="feedback_"]:has(> a[class*="MobileUpsellView_"]) {
  display: none !important;
}
```

This targets the `<div>` container that wraps the "Get the mobile app" link and hides it via `display: none`.

> **⚠️ Important:** This CSS selector has only been tested on **SharePoint SE Communication Sites**. The selector may not work — or may target different elements — on Team Sites or future SharePoint UI updates. Microsoft may change the underlying DOM structure at any time without notice.

## Prerequisites

| Tool | Version |
|------|--------|
| **Node.js** | 8.17.x |
| **SharePoint Framework** | 1.4.1 |
| **Gulp** | 3.x (installed globally) |
| **Yeoman** | 3.x (installed globally) |

> **Note:** Node.js 8.17 is required for SPFx 1.4.1 compatibility. Using a newer version of Node.js may cause build errors. Consider using [nvm-windows](https://github.com/coreybutler/nvm-windows) to manage multiple Node.js versions.

## Building the Solution

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd HideGetMobileApp
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Build the solution:

   ```bash
   gulp build
   ```

4. Bundle the solution (production):

   ```bash
   gulp bundle --ship
   ```

5. Package the solution:

   ```bash
   gulp package-solution --ship
   ```

   The `.sppkg` file will be created at `sharepoint/solution/hide-get-mobile-app.sppkg`.

## Deployment

1. Upload `hide-get-mobile-app.sppkg` to your **SharePoint App Catalog**.
2. When prompted, select **"Make this solution available to all sites in the organization"**. 
   
   ![Make this solution available to all sites in the organization](Make-this-solution.png)

   This makes the extension available but does **not** activate it on any site yet.
3. Trust the solution when prompted.

## Adding to a Site Collection

After deploying to the App Catalog, you need to run a PowerShell script for **each site collection** where you want to hide the link.

The `deployment` folder contains three scripts:

| Script | Purpose |
|--------|--------|
| `HideMobileUpsellLink.ps1` | Adds the Application Customizer to a site collection |
| `UnhideMobileUpsellLink.ps1` | Removes the Application Customizer from a site collection |
| `AddOrRemoveApplicationCustomizerToOrFromSiteCollection.ps1` | Shared helper script used by the above two scripts |

To activate on a site collection, run the following from the `deployment` folder:

```powershell
.\HideMobileUpsellLink.ps1 -siteCollectionUrl "https://yourserver/sites/yoursite"
```

The script uses the SharePoint CSOM client DLLs (automatically located from the SharePoint hive) to register a `UserCustomAction` on the site collection.

## Removing from a Site Collection

To remove the Application Customizer from a site collection, run the following from the `deployment` folder:

```powershell
.\UnhideMobileUpsellLink.ps1 -siteCollectionUrl "https://yourserver/sites/yoursite"
```

## Compatibility

| Aspect | Details |
|--------|--------|
| **SharePoint Framework** | 1.4.1 |
| **Node.js** | 8.17.x |
| **SharePoint SE Communication Sites** | ✅ Tested |
| **Any other SharePoint Versions or Sites** | ❓ Not tested |

## Version History

| Version | Date | Notes |
|---------|------|------|
| 1.0.0 | 2026-02-16 | Initial release |

## Author

**Matthias Glubrecht**

## License

This project is licensed under the [MIT License](LICENSE).
