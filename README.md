# SB Control Center 3.0.0
## Complete Documentation: User Manual and Technical Reference

**Product:** SB Control Center (mod manager for *Stellar Blade*)  
**Documented version:** 3.0.0, based on the name of the supplied source package  
**Document language:** English  
**Documentation source:** Source code included in `SB Control Center 3.0.0.xml`

---

## Table of contents

1. [Overview](#1-overview)
2. [Requirements and preparation](#2-requirements-and-preparation)
3. [First launch and initial setup](#3-first-launch-and-initial-setup)
4. [Main interface](#4-main-interface)
5. [Installing mods](#5-installing-mods)
6. [Supported mod types](#6-supported-mod-types)
7. [Enabling, disabling, and deleting mods](#7-enabling-disabling-and-deleting-mods)
8. [Variants, editions, and conflicts](#8-variants-editions-and-conflicts)
9. [Nexus Mods integration](#9-nexus-mods-integration)
10. [Downloading from Nexus Mods](#10-downloading-from-nexus-mods)
11. [Updating mods and metadata](#11-updating-mods-and-metadata)
12. [Managing Eve's outfits](#12-managing-eves-outfits)
13. [CNS and UE4SS components](#13-cns-and-ue4ss-components)
14. [Repair and diagnostic tools](#14-repair-and-diagnostic-tools)
15. [Application settings](#15-application-settings)
16. [Files, paths, and persistence](#16-files-paths-and-persistence)
17. [Code architecture](#17-code-architecture)
18. [Service reference](#18-service-reference)
19. [Data models and metadata](#19-data-models-and-metadata)
20. [Observed integrations and dependencies](#20-observed-integrations-and-dependencies)
21. [Troubleshooting](#21-troubleshooting)
22. [Limitations of this documentation](#22-limitations-of-this-documentation)
23. [Glossary](#23-glossary)

---

# 1. Overview

SB Control Center is a desktop mod manager for *Stellar Blade*. Its purpose is to centralize the installation, classification, enabling, disabling, updating, and organization of mods, as well as the management of components required by certain mods.

The main features identified in the code are:

- Install one or more mod files or folders and preview the changes before applying them.
- Detect different mod categories from their structure and contents, not just their filenames.
- Manage **CNS** mods, outfit replacements, generic Unreal packages, UE4SS logic mods, videos, splash images, `.ini` files, and `.sav` save files.
- Identify a downloaded Nexus Mods mod or edition by filename, MD5 hash, and API validation when available.
- Download mods from `nxm://` links, with progress tracking and controls to pause, resume, cancel, or retry.
- Check Nexus Mods for updates and metadata, retrieve gallery images, and cache those images locally.
- Track multiple editions of the same mod separately.
- Detect conflicts between mods that replace the same outfit or files, then ask the user how to resolve them.
- Install and uninstall the base UE4SS and Custom Nanosuit System (CNS) components while maintaining manifests of managed files.
- Attempt to fix game startup failures by temporarily moving UE4SS/CNS aside, checking whether the game starts, and restoring the components.
- Run an IoStore container conflict patcher and restore its backups.
- Translate mod summaries and descriptions while preserving BBCode and links contained in the original text.

The application window is registered with the title **SB Control Center**. Some localization resources still contain the historical label “CNS Control Center”; the startup configuration uses SB Control Center.

## What the application does not do

- It does not guarantee that two mods are compatible merely because they can both be installed.
- It cannot verify that a mod works correctly in-game; it manages files and detects certain mod types and technical conflicts.
- It does not replace dependencies required by a mod if those dependencies are not included in the package.
- Do not assume every feature works offline: Nexus queries, `nxm://` link resolution, updates, online translation, and some file-identification features require an Internet connection.

# 2. Requirements and preparation

## 2.1 Functional requirements

| Requirement | Purpose | When it is needed |
|---|---|---|
| Valid *Stellar Blade* installation | Locate mod, video, configuration, save, and component folders | Whenever you install or manage mods |
| Read/write access to game and user folders | Copy, move, back up, enable, disable, and delete files | Always |
| 7-Zip `7z.exe` | Extract `.zip`, `.rar`, and `.7z` archives through the external 7-Zip process | When installing from those archives |
| Nexus Mods API key | Validate the account, retrieve metadata, identify some files, check updates, obtain download links, and endorse mods | Optional for basic local management; required for Nexus features that depend on it |
| Internet connection | Queries, downloads, gallery, updates, online translation | Only for online features |
| UE4SS | Runtime/tooling required by CNS and certain logic mods | For CNS and mods that depend on it |
| Custom Nanosuit System (CNS) | Manage mods specifically designed for CNS | For installing/running CNS mods; UE4SS must be installed first |

The code attempts to find `7z.exe` in these common Windows locations:

- `C:\Program Files\7-Zip\7z.exe`
- `C:\Program Files (x86)\7-Zip\7z.exe`

You can also select the executable manually. The selected file must be named `7z.exe`; selecting only the installation folder is not sufficient.

## 2.2 Windows compatibility

The code uses Windows environment variables, Steam paths, `windows_single_instance`, `nxm://` protocol registration, window management, and an application updater explicitly compatible with Windows. Therefore, **Windows is the platform whose support can be documented with the greatest confidence**. The supplied XML does not provide enough information to guarantee full functionality on other operating systems.

## 2.3 Recommendations before changing files

1. Close *Stellar Blade* before enabling/disabling mods, running the patcher, or repairing startup.
2. Keep your own backups of important files, especially save games and configurations.
3. Read replacement, downgrade, and outfit-conflict warnings before confirming.
4. Do not close the application or the game while the guided **Repair Game Startup** procedure is running.
5. If a file is locked, close other applications that may be inspecting or using game files, such as the game itself, FModel, File Explorer, or antivirus software scanning the directory.

# 3. First launch and initial setup

## 3.1 Locate the game

At startup, the application tries to find the *Stellar Blade* installation. It first checks the path saved in preferences, then uses the Steam installation locator. A saved path is accepted only if it contains the expected `SB/Content/Paks` structure.

If no valid installation is found:

1. Select **Choose game folder manually**.
2. Choose the installation's root folder—the folder that contains `SB`.
3. Do not select `SB`, `Content`, or `Paks` directly.
4. If detection fails, choose **Retry** and confirm that `SB/Content/Paks` exists.

After finding a valid path, the application prepares or verifies the folders it needs. These include locations for mods, movies, logic mods, UE4SS, configurations, saves, splash images, and backups.

## 3.2 Configure 7-Zip

Under **Settings → Paths & Tools**:

1. Check the **7-Zip Path** field.
2. If it shows a valid path, no change is needed.
3. If automatic detection fails, select the `7z.exe` file.
4. Try installing the archive again.

The extraction of `.zip`, `.rar`, and `.7z` files uses 7-Zip. If the executable is missing, installation stops and displays a warning.

## 3.3 Configure the Nexus Mods API

The key is optional for some local mod-management tasks, but it enables features that query Nexus Mods. The application links to the [Nexus Mods API access page](https://www.nexusmods.com/users/myaccount?tab=api%20access).

Steps:

1. Open **Settings → Connectivity & Updates → Nexus Mods API Key**.
2. Open the linked page and sign in to Nexus Mods.
3. Find **Personal API Key** and generate or copy your personal key.
4. Paste it into the application and save. The app attempts to validate it; if validation fails, check the key and your connection.

Some features—including exact file identification, version checks, download-link retrieval, galleries, and endorsements—depend on the API and its limits. The main interface displays account information and request counters when Nexus provides that data.

## 3.4 Initial API-key prompt

If no key is configured, the application may show a prompt offering to configure it, skip the setup, or select **Don't show this message again**. That choice is saved as a preference.

## 3.5 Language

Open **Settings → General → Language** and choose one of the available languages: English, Español, Português, Русский, Deutsch, 中文, 日本語, 한국어, Italiano, or Français. The selected language persists between launches.

# 4. Main interface

## 4.1 Mod panel

The main screen displays mods detected in the installation. Each entry can appear as a grid card or a list row. Depending on available metadata, an entry can show its name, version, author, category, cover image, status, and update notice.

Identified controls and filters:

- **Search:** filters entries based on the search text.
- **Status:** all, enabled, disabled, or updates available.
- **Type:** all, CNS, replacement, movies, logic, generic, save, configuration, or splash.
- **Sort:** name or date.
- **View:** grid or list.
- **Type tags:** can be shown or hidden in Settings.
- **Refresh list:** reads installed mods again and refreshes the displayed status.

Filters, sorting mode, and view mode are saved in preferences.

## 4.2 Actions for an individual mod

Depending on its type and available data, the card or details panel may offer these actions:

- Enable or disable the mod.
- Open the mod details panel.
- Open its corresponding Nexus Mods page.
- Show the mod in File Explorer.
- View its image gallery.
- Edit its name, version, and personal tag/category.
- Change the cover image, adjust its crop, or restore the original cover.
- Edit personal notes.
- Add or open a download link.
- Translate the summary/description or restore the original description.
- View or manage an endorsement if the mod is linked to Nexus and Nexus's requirements are met.
- Permanently delete a mod; the application requires it to be disabled before deletion.

Custom changes are stored in metadata in the mod folder so they can persist when the list is reloaded.

## 4.3 Batch operations

The interface includes actions to:

- Enable all disabled mods in the relevant set.
- Disable all enabled mods in the relevant set.
- Delete disabled mods in the relevant set.

These actions request confirmation where appropriate. If some mods cannot be enabled due to conflicts, the result reports how many were enabled and skipped.

## 4.4 Drag and drop

The window includes a drop area for files. Dropped items are passed to the installation workflow. They are added to an installation panel that groups selected or downloaded files, lets you review the options, and processes the queue.

## 4.5 Game status

The application can launch *Stellar Blade* and detect whether its process is running. If startup fails after the launch workflow's configured attempts, it may offer the game-startup repair procedure.

# 5. Installing mods

## 5.1 Typical workflow

1. Click **Install Mod** or drag a file into the window.
2. Select one or more files, or a folder containing extracted files.
3. If you select a `.zip`, `.rar`, or `.7z` archive, the application extracts it using 7-Zip.
4. The system looks for UE4SS components, game packages, configuration files, videos, images, saves, and Nexus metadata.
5. If the archive contains multiple mods or variants, they appear as separate entries in the preview.
6. Review the names, detected types, variants, and conflicts.
7. Confirm installation. The application copies or moves files to their destinations and creates or updates the metadata it can determine.
8. When finished, the list refreshes and the newly installed mod is highlighted.

## 5.2 Archive formats supported by the extractor

The code explicitly recognizes `.zip`, `.rar`, and `.7z`. Archives are extracted using the external 7-Zip command. If you select another format, the installer reports that it is unsupported.

Among the extracted files, the detector recognizes:

- Unreal packages: `.pak`, `.ucas`, `.utoc`.
- Configuration files: `.ini` files that pass text/configuration validation.
- Movies: `.bk2` and `.webm`.
- Saves: `.sav`.
- Splash images: `.bmp`, `.jpg`, `.jpeg`, and `.png`, depending on the package structure and detection rules.
- JSON metadata for CNS mods and special packages.

An extension appearing in this list does not guarantee that every file with that extension is valid for the game; context, contents, and structure also matter.

## 5.3 Automatic identification

When processing a file, the system tries to identify its Nexus entry using the filename, MD5, and API validation. If the identity is reliable, it can retrieve the mod name, file/edition, version, and Nexus ID. Otherwise, it uses a name derived from the file or folders.

When an archive contains multiple independent mods, the archive filename is not used as the unique identity for every mod inside it. The installer tries to preserve distinct variant names so separate folders do not overwrite each other.

## 5.4 Preview and confirmation dialogs

Before installation, the application may show:

- The list of mods to install.
- Whether an item is an update, reinstall, or downgrade.
- An alternative/edition of the same mod that is already installed.
- A conflict because the selected mod replaces an outfit already assigned to another mod.
- A selection of variants to install.
- Options for a special mod or a selection of splash images.
- A notice that UE4SS must be installed before CNS.

Do not confirm a replacement if you intend to keep both the existing and new editions. To keep multiple editions, choose **Install as New** when that option is offered, provided their files do not collide and the editions are genuinely independent.

# 6. Supported mod types

Classification is handled by `ModClassifierService`, `ArchiveService`, and—in some packages—inspection of the file index. Classification can change the installation destination and the way a mod is enabled or disabled.

| Type | How it is recognized (summary) | Destination/management | Notes |
|---|---|---|---|
| **CNS** | `.pak/.ucas/.utoc` packages alongside mod JSON; `.dekcns.json` is a strong indicator | Usually under `SB/Content/Paks/~mods/CustomNanosuitSystem` | Requires the base CNS system to be installed |
| **Outfit replacement** | A CNS-managed mod assigned to one or more outfits | CNS destination; outfit-to-mod association is stored in metadata | Used to detect exclusivity and conflicts between replacements |
| **Generic** | Unreal packages not classified as CNS or logic mods | `SB/Content/Paks/~mods` and a managed subfolder | No CNS-specific behavior is assumed |
| **Logic / UE4SS** | Inspection of `.utoc/.pak/.ucas` and/or `LogicMods` components and UE4SS folders; may detect `ModActor`/logic content | `SB/Content/Paks/LogicMods`; may include components in `SB/Binaries/Win64/ue4ss/Mods` or helper packages in `~mods` | Associated components are managed with the mod and backed up/restored when disabled |
| **Movies** | `.bk2` or `.webm` files, unless other signals indicate a different type | `SB/Content/Movies` | Preserves relative paths and manages backups of original videos for restoration |
| **Save game** | `.sav` files | `%LOCALAPPDATA%\SB\Saved\SaveGames` and, if present, the first detected user subfolder | Replacing a save may overwrite personal progress; keep your own backup |
| **Configuration** | Recognized `.ini` files validated as text | `%LOCALAPPDATA%\SB\Saved\Config\WindowsNoEditor` | Original files are backed up when enabling the mod |
| **Splash / startup screen** | Supported images and/or the structure/identity of a special mod | `SB/Content/Splash` and the managed splash subfolder | Supports selecting images and folders; originals are backed up |
| **UE4SS component** | The archive contains a recognizable UE4SS structure | `SB/Binaries/Win64` | Installed as a core component, not as an ordinary list mod |
| **CNS update package** | `SB/...` structure including `ue4ss/Mods/DekCNS/Scripts/main.lua` | Copied under the `SB` directory | Presented as an update to the CNS base system |

## 6.1 Outfit replacements

A replacement is more than a label: the app associates the mod with the name of the outfit or outfits it replaces. This association can be detected from asset names inside `.pak` or `.utoc` files; it can also be reviewed or edited in the mod details.

Once an outfit has been selected, the manager tries to prevent two mods from being enabled simultaneously for the same outfit. If it detects a conflict, it offers to keep the current mod or enable the new mod and disable the competing one.

## 6.2 Logic mods with multiple components

Some mods include `LogicMods` content as well as UE4SS files, loose files in the UE4SS root, or regular packages. The installer separates these pieces according to their purpose. When the mod is disabled, it attempts to remove and back up all registered pieces and restore any original files it replaced.

Mods that depend on HD-ATOOL receive special handling so their associated audio files can be grouped. The code identifies HD-ATOOL using Nexus ID `1662` and stores the relationship between managed files and the mod.

## 6.3 Special mods

An internal list of Nexus IDs is processed specially (`30`, `390`, `550`, `801`, and `1112`). These mods are not split using exactly the same rules as ordinary archives. Special mod ID `801` is handled as a splash mod and may show instructions for configuring Steam launch options. These rules depend on the archive being identifiable by its Nexus ID.

# 7. Enabling, disabling, and deleting mods

## 7.1 Enable a mod

Use the enable control on the card or row. The operation depends on the mod type:

- CNS and generic mods: move the directory from backup storage to the appropriate mod directory.
- Logic mods: restore linked packages and UE4SS/`~mods` components, then put the mod back in `LogicMods`.
- Movies: apply the video installation plan to the destination files.
- Splash: copy selected images and apply the managed indexing/structure.
- `.ini` and `.sav`: copy files to the managed destination, backing up originals that will be replaced.

The app may skip items because of detected conflicts and reports when a bulk operation could not enable everything.

## 7.2 Disable a mod

Disabling removes the mod from the active state without deleting its managed installation. For folder-based mods, the code moves the directory to:

`<game root>\SB\Content\__MOD_BACKUPS__`

For logic mods, it also attempts to back up separately the components installed in `~mods`, UE4SS folders, and loose files. Videos, configurations, saves, and splash images use specialized routines to restore original files.

## 7.3 Permanently delete a mod

The application asks for confirmation and requires the mod to be disabled before deleting it. This is a destructive operation and should not be used as a substitute for **Disable**.

Permanently deleting disabled mods in a batch is also irreversible. Check the number and names of the selected items before confirming.

# 8. Variants, editions, and conflicts

## 8.1 Variants inside one archive

If an archive contains multiple option folders, the detector may treat them as separate variants. The application displays each variant's relative name, and a dialog lets you choose what to install. Depending on the structure, you can install only one variant or all of them as independent mods.

## 8.2 Different editions of the same Nexus mod

A Nexus mod may offer multiple files/editions, for example a “CNS compatible” edition and another edition. SB Control Center tracks them separately instead of necessarily treating every file as an update to the same entry.

When an already-known edition is installed, the application may offer:

- **Replace:** replace the installed edition.
- **Install as New:** keep the editions separate.
- **Cancel:** stop the operation.

Edition identification uses Nexus data when available; older installations may lack this information until their metadata is refreshed.

## 8.3 Conflicts caused by an occupied outfit

A replacement mod can be assigned to one or more outfits. The application compares that list with assignments belonging to currently enabled mods and prevents incompatible replacements from occupying the same outfit at the same time. During installation it asks which mod should remain enabled; during activation it may skip conflicts or automatically disable competing mods, depending on the workflow.

If the detector assigned the wrong outfit, open the details and correct the selection. You can also disable **Automatically Assign Outfits** in Settings and assign outfits manually when installing or editing a mod.

## 8.4 File conflicts

Movie mods and some special mods can target the same files. The movie manager calculates installation plans and keeps backups of originals, but it cannot make two mutually exclusive files compatible. Disable the mod you do not want to use before enabling the other one.

# 9. Nexus Mods integration

## 9.1 Capabilities

With a valid API key and an Internet connection, the integration can:

- Validate the API key and retrieve basic account information.
- Show the detected account plan (Member, Supporter, or Premium) and remaining request counters exposed by the API.
- Retrieve mod details, names, latest versions, files, and galleries.
- Identify a file by its name, MD5 hash, and API queries.
- Retrieve download links for `nxm://` links.
- Check endorsements and add/remove endorsements when Nexus allows it.
- Cache gallery images locally to reduce requests and avoid downloading the same images repeatedly.
- Open the selected mod or file page on Nexus Mods.

## 9.2 Endorsing a mod

The endorsement button is subject to Nexus Mods' rules. The application accounts for cases including: the mod is not linked to Nexus, no API key is configured, the key is invalid, the file was not downloaded with that account, the 15-minute waiting period after download has not elapsed, the user is trying to endorse their own mod, the request limit has been reached, or a network error occurred.

The details panel can display or remove a mod's endorsement when the API returns the relevant status.

## 9.3 Endorsing the application itself

An invitation to endorse SB Control Center on Nexus Mods may appear under **Settings → General**. This action's status is stored per account in `self_endorse.json` next to the executable and stores a fingerprint of the key, not the API key in plain text. This is separate from endorsements for managed mods.

## 9.4 Mod metadata

The application keeps a `nexus_info.json` file in each managed mod folder. It can store Nexus identity, version, custom display name, author, summary/description, notes, source link, cover and gallery, edition, type, and replaced outfits, among other fields. The exact contents depend on how old the installation is and what information could be retrieved.

## 9.5 API limits and errors

Nexus may reject requests because of an invalid key, request limits, insufficient permissions, or network problems. SB Control Center displays available counters and avoids some metadata/image-update attempts when the hourly quota is low. An API failure does not necessarily mean the local mod files are damaged.

# 10. Downloading from Nexus Mods

## 10.1 `nxm://` links

The application registers the `nxm://` protocol. When a user clicks a compatible download link on Nexus Mods, the operating system can send it to SB Control Center. If the app is already open, a second invocation forwards the link to the existing instance, which processes it in the download/installation panel.

The protocol association in Windows also depends on how the application was installed/distributed and registered; that external installer is not included in the supplied XML.

## 10.2 Download states

The manager represents these states: fetching information, downloading, paused, completed, error, and cancelled. The interface offers controls for each task as appropriate:

- **Pause:** suspend the active task.
- **Resume:** continue a paused task.
- **Cancel:** stop the task.
- **Retry:** try again after an error.

The HTTP service supports range transfers and can resume a download when the server returns a compatible partial response. Resuming depends on server support and whether the link is still valid.

## 10.3 Download-link errors

A Nexus download link can expire. In that case, the application may need to retrieve a new link through the protocol/API. HTTP errors, timeouts caused by a lack of incoming data, no Internet connection, and general errors are shown as distinct states.

The UI strings in the code refer to approximate download limits of 1.5 MB/s for Member accounts and 3 MB/s for Supporter accounts. Actual speeds depend on Nexus, your connection, and other external conditions.

## 10.4 Queue and follow-up installation

Downloaded files can be added to the installation queue. The panel attempts to group downloads while it is open and process files in order. Files consumed by an installation are cleaned up afterward according to the queue workflow.

# 11. Updating mods and metadata

## 11.1 Check for updates

Select **Check for Updates**. For mods linked to Nexus, the service compares the installed files/editions with remote information and may follow update relationships between Nexus files.

When an update is found, the entry shows the new version and provides options to download it. The workflow warns in these cases:

- Updating to a newer version.
- Installing a version older than the one currently installed.
- Reinstalling the same version.
- An alternative mod/edition is already installed.

## 11.2 Ignore vs. skip a version

These actions are different:

- **Ignore:** dismisses the update notice for the current session.
- **Skip Version:** saves the version so future checks omit it until the preference is changed.

Skipped versions are managed under **Settings → Connectivity & Updates → Manage Skipped Versions**.

## 11.3 Refresh metadata

**Refresh Metadata** checks mods for missing information from Nexus, such as identity, author, description, version, and images. A valid API key is required. The local gallery and metadata can be refreshed separately from the mod's installed files.

## 11.4 Repair legacy mods

**Repair Legacy Mods** looks for mods without `nexus_info.json` and attempts to reconstruct that data using a local database and, when necessary, Nexus. It may also normalize a folder name to include the version it finds.

The interface warns that this feature is in development and may not be perfect. Review any folder renames and keep backups before running it on an important mod library.

# 12. Managing Eve's outfits

SB Control Center contains an internal list of *Stellar Blade* outfit names and a system for associating replacement mods with the outfits they affect.

Observed features:

- **Asset detector:** examines `.utoc` and `.pak` package information, directory indexes, and asset names. It uses tokens and paths that often distinguish textures, materials, meshes, physics, animations, and blueprints.
- **Automatic assignment during installation**, enabled by default in preferences.
- **Outfit picker** with search, preview when an image exists, multi-selection, an All/Selected filter, and actions to clear the selection.
- **Mod tag** that can display the replaced outfit.
- **Conflict handling** to prevent two replacements for the same outfit from remaining enabled.

Automatic assignment is a file-based heuristic, not definitive proof of compatibility. If an outfit is assigned incorrectly, edit it manually. The built-in outfit-name list may not include names or content added after the supplied code version.

# 13. CNS and UE4SS components

## 13.1 What each component means in the application

- **UE4SS:** a tooling/mod runtime used to run components that depend on that environment.
- **CNS (Custom Nanosuit System):** a base system that enables mods specifically prepared for CNS, including outfit JSON data and associated content.
- **CNS mod:** a user-installed mod normally managed under `SB/Content/Paks/~mods/CustomNanosuitSystem`.
- **Logic mod:** may combine packages in `LogicMods` with files/folders loaded by UE4SS.

## 13.2 Installation order

UE4SS must be installed before the CNS base system. The application warns about this dependency. If CNS is installed, it prevents UE4SS from being uninstalled first because that would leave CNS without its dependency.

When the application recognizes an archive containing UE4SS, it offers to install or reinstall the component. A CNS package identified as the base system is handled as a central system installation/update, not as an ordinary mod.

## 13.3 Manifests

The application creates manifests containing relative paths for the files it installs. They are stored under:

`SB/Binaries/Win64/_manager_metadata/ue4ss_manifest.json`  
`SB/Binaries/Win64/_manager_metadata/cns_manifest.json`

These manifests determine which files the uninstaller should manage. The system can recognize older installations from characteristic folders and adopt their components by creating a missing manifest.

**Important:** Do not manually delete manifests if you expect the uninstaller to remove those components. Without a manifest, the application may refuse to uninstall because it can no longer reliably determine the list of managed files.

## 13.4 Uninstalling the core components

The **Settings → Core Components** section shows the detected status of UE4SS and CNS and offers uninstall actions. The operation removes paths listed in the corresponding manifest. User mods are managed separately, but check the contents and keep backups before changing base components.

# 14. Repair and diagnostic tools

## 14.1 Repair Game Startup

Use this option if *Stellar Blade* closes or fails to start, especially if you suspect UE4SS or CNS. The intended workflow is:

1. Confirm the repair.
2. Close the game if it is running.
3. Temporarily move CNS and UE4SS into managed backup storage, preserving their files and manifests.
4. Start the game without those components and wait for initialization.
5. Close the game automatically.
6. Restore UE4SS and CNS.
7. Attempt to start the game one more time.

Startup detection has a time limit, and the procedure can fail. If it fails, the app attempts to restore the components; if restoration is not possible, the code records a pending repair and attempts recovery on the next launch. Do not manually close the application while the repair is running.

The repair is not intended to delete user mods. It temporarily moves the core components managed by the installer to check whether they are responsible for the problem.

## 14.2 Conflict Patcher

The **Conflict Patcher** scans IoStore packages, including `.utoc` and `.ucas` files, within mod directories. Among other tasks, it compares container identifiers and can change conflicting IDs when the package structure can be modified safely. It saves originals with the `.cnsbak` extension so the operation can be reverted.

The report distinguishes:

- `Container_Id` conflicts that were fixed.
- Groups of detected `Package_Id` conflicts that may overwrite files or prevent certain mods from coexisting.
- Mods that share an identifier but could not be repaired safely; these files are left unchanged.

Run the patcher on demand under **Settings → Paths & Tools → Conflict Patcher**. Review the summary and full log if warnings appear. Close the game before running it.

## 14.3 Revert patches

**Revert Conflict Patches** looks for `.cnsbak` files and restores the originals. The original conflicts will return, so some mods may stop appearing in CNS or begin competing for the same identifiers again.

## 14.4 Repair local metadata automatically

The legacy-mod repair tool attempts to recover missing or old information. It is not the same as repairing game files, and its results may vary with local database availability, API-key access, and the quality of folder names.

# 15. Application settings

Settings are organized into panels. Exact labels and descriptions may vary by language.

| Panel | Main options | Purpose |
|---|---|---|
| **General** | Language, show type tags, automatically assign outfits, About, endorse the app | Display preferences and detection behavior |
| **Paths** | Game folder, 7-Zip path | Configure required locations |
| **Tools** | Repair legacy mods, run/revert patcher, repair startup | Diagnostics and maintenance |
| **Core Components** | UE4SS/CNS status and uninstall | Manage base dependencies |
| **Connectivity & Updates** | API key, skipped versions, refresh metadata | Nexus integration |
| **Developer Options** | Delete `nexus_info.json`, extract IDs, test self-update | Advanced diagnostics; some actions are destructive |

## 15.1 Developer options

- **Delete all `nexus_info.json` files:** removes metadata files managed by the application from every mod. The interface warns that custom names, covers, and metadata will be lost. Use this only when you intend to force metadata reconstruction.
- **Extract identifiers:** creates `ID Mods.json` on the desktop with identification data, including `displayName` and `nexusId`, for mods that have those values. An existing file with the same name is overwritten.
- **Test self-update:** lets you select the app's ZIP package and run through the update workflow. In a non-release build, the code may validate it in test mode without installing it. Self-update is explicitly enabled only on Windows and in release builds.

These tools are mainly for diagnostics/development and are not required for everyday use.

# 16. Files, paths, and persistence

## 16.1 Main paths

The paths below are derived from the application's logic and the expected *Stellar Blade* directory structure. `<GAME_ROOT>` is the game's installation root; `%LOCALAPPDATA%` is the current Windows user's local application-data directory.

| Purpose | Expected path |
|---|---|
| Generic packages | `<GAME_ROOT>\SB\Content\Paks\~mods` |
| User CNS mods | `<GAME_ROOT>\SB\Content\Paks\~mods\CustomNanosuitSystem` |
| Logic mods | `<GAME_ROOT>\SB\Content\Paks\LogicMods` |
| UE4SS mods | `<GAME_ROOT>\SB\Binaries\Win64\ue4ss\Mods` |
| UE4SS core/files | `<GAME_ROOT>\SB\Binaries\Win64` |
| Movies | `<GAME_ROOT>\SB\Content\Movies` |
| Save games | `%LOCALAPPDATA%\SB\Saved\SaveGames\<user folder>` when that subfolder exists |
| Configuration | `%LOCALAPPDATA%\SB\Saved\Config\WindowsNoEditor` |
| Splash images | `<GAME_ROOT>\SB\Content\Splash` |
| Backups of disabled mods | `<GAME_ROOT>\SB\Content\__MOD_BACKUPS__` |
| Original movie backups | `<GAME_ROOT>\SB\Content\__MOVIES_ORIGINALS__` |
| Original save backups | `<GAME_ROOT>\SB\Content\__SAVES_ORIGINALS__` |
| Original configuration backups | `<GAME_ROOT>\SB\Content\__CONFIG_ORIGINALS__` |
| Original splash backups | `<GAME_ROOT>\SB\Content\__SPLASH_ORIGINALS__` |
| Manager manifests | `<GAME_ROOT>\SB\Binaries\Win64\_manager_metadata` |
| Mod gallery | `<mod folder>\_nexus_gallery` |
| App's own endorsement state | `self_endorse.json` beside the executable |

Some folders are created when the app prepares paths; others appear after installing or disabling a particular mod type. An empty folder alone does not prove that the corresponding mod is installed.

## 16.2 Preference persistence

The application uses `SharedPreferences` for settings such as language, game path, 7-Zip path, API key, skipped versions, filter, sort mode, view mode, type tags, and automatic outfit assignment. The physical location of this store depends on the platform implementation and cannot be confirmed from the supplied code alone.

## 16.3 `nexus_info.json`

This file accompanies managed mods and stores metadata that lets the application remember Nexus identity, editable fields, local gallery, edition, type, outfit assignments, and components associated with a logic mod. The application includes schema migrations to preserve data installed with earlier versions.

Do not edit this JSON manually unless you know its structure. Invalid or incomplete JSON can cause the manager to lose identification data, custom options, or knowledge of components it must move when a mod is enabled or disabled.

## 16.4 Gallery and cover images

A downloaded cover can be stored as `_nexus_cover` with the appropriate extension. The full gallery is stored in `_nexus_gallery/` with numeric prefixes to preserve image order. Metadata paths are relative so they remain valid when a mod folder moves between active and backup storage.

# 17. Code architecture

The supplied code is organized under `lib/` and uses Flutter/Dart. The startup class is `ModInstallerApp`; the main working screen is `ModInstallerHomePage`, whose state coordinates much of the interface, installation, updates, and game status.

## 17.1 Main layers

| Layer | Directory/file | Responsibility |
|---|---|---|
| Startup and orchestration | `lib/main.dart` | Initialization, `nxm://` protocol, single instance, path detection, install queue, mod list, user operations, game launch/repair |
| Settings | `lib/settings_page.dart`, `lib/ui/dialogs/settings_dialogs.dart` | Preference panels and related dialogs |
| Models | `lib/models/` | Mod model, filter types, prepared installations, and Nexus account-plan model |
| File/installation services | `lib/services/archive_service.dart`, `file_manager_service.dart`, `core_installer_service.dart`, `mod_manager_service.dart` | Extraction, classification, copying/moving, manifests, enabling and disabling |
| Online integration | `nexus_api_service.dart`, `nexus_file_identifier.dart`, `download_service.dart`, `download_manager.dart`, `update_service.dart` | API, identification, downloads, and updates |
| Specialized mods | `movie_mods_handler.dart`, `splash_mods_handler.dart`, `special_mods_handler.dart`, `hd_atool_audio_service.dart` | Workflows with specialized structures or restoration rules |
| Outfit/conflict detection | `outfit_detector.dart`, `outfit_id_map.dart`, `variant_conflict_service.dart` | Associate replacements with outfits and resolve variants |
| Repair/patching | `game_repair_service.dart`, `patcher_service.dart`, `iostore_toc.dart`, `package_index_reader.dart` | Startup repair and container analysis/patching |
| Presentation | `lib/ui/widgets/`, `lib/ui/dialogs/`, `lib/ui/theme/` | Cards, lists, details panel, image viewer, outfit picker, dialogs, and theme |
| Localization | `lib/l10n/` | ARB resources and generated localization classes |
| Utilities | `lib/utils/`, `thumbnail_service.dart`, `notification_service.dart` | Version handling, text utilities, thumbnails, and notifications |

## 17.2 Startup and download protocol

The `main()` function initializes Flutter, waits for a previous instance to finish during self-update, registers the `nxm` protocol, configures a single Windows instance, and opens the main window. If another instance receives a Nexus link, the existing application is brought to the foreground and receives the link for processing.

The window is configured with an initial size of 1100 × 700 and a minimum size of 680 × 700. The interface uses a dark theme visually inspired by iOS/macOS controls, although the core integration logic is Windows-oriented.

## 17.3 Localization

The supplied ARB resources include German (`de`), English (`en`), Spanish (`es`), French (`fr`), Italian (`it`), Japanese (`ja`), Korean (`ko`), Portuguese (`pt`), Russian (`ru`), and Chinese (`zh`). Generated Dart localization classes are also included.

## 17.4 Installation logic flow

1. Receive file paths from the picker, drag and drop, or download manager.
2. Identify the file with `NexusFileIdentifier` when possible.
3. Extract the archive using `ArchiveService`.
4. Detect whether the archive contains UE4SS or a CNS update.
5. Analyze possible logic mods and separate their components.
6. Detect video files, splash images, configuration files, and saves.
7. Find mod folders and classify each one.
8. Resolve installation variants and conflicts.
9. Show a preview and request any required confirmations.
10. Install files, update metadata/manifests, refresh the list, and report the result.

# 18. Service reference

The table describes the main responsibilities suggested by the classes and methods in the code. It is not a guarantee that every internal detail is exposed in the user interface.

| File/service | Technical responsibility |
|---|---|
| `archive_service.dart` | Extract/analyze archives, find mod folders, detect UE4SS and CNS update packages, coordinate initial classification |
| `config_mod_detector.dart` | Recognize configuration filenames, validate `.ini` text, and build configuration previews |
| `core_installer_service.dart` | Install/uninstall UE4SS and CNS via manifests; move/restore files during startup repair; maintain a pending-repair journal |
| `download_manager.dart` | Maintain the download queue, visible state, and pause/resume/cancel/retry controls |
| `download_service.dart` | HTTP downloads, progress, cancellation, and resuming from partial responses where supported |
| `endorse_info_store.dart` | Persist/read local information about mod endorsement status |
| `file_manager_service.dart` | Robust folder operations, copying, moving mods, recursive file discovery, and temporary-directory cleanup |
| `game_locator_service.dart` | Locate the Steam installation of *Stellar Blade* |
| `game_repair_service.dart` | Coordinate startup-repair steps, process waiting, game closing, and step results |
| `hd_atool_audio_service.dart` | Manage HD-ATOOL and audio files used by dependent logic mods while preserving/restoring original audio |
| `iostore_toc.dart` | Read IoStore TOC structures and access container IDs/entries |
| `logic_mod_detector.dart` | Classify packages based on logical content rather than filenames/folders alone |
| `logic_mod_stager.dart` | Inspect logic mods and separate LogicMods, UE4SS, and helper-package components |
| `mod_manager_service.dart` | Read CNS JSON names/categories/fields; load and persist mod data and local metadata |
| `mod_metadata_migrator.dart` | Migrate `nexus_info.json`, complete identity/edition metadata, and run automatic outfit detection when appropriate |
| `movie_mods_handler.dart` | Analyze, plan, install, disable, and restore movie mods while preserving originals and relative paths |
| `nexus_api_service.dart` | Validate the API, retrieve data and versions, search files by MD5, retrieve downloads and galleries, and read/update endorsements |
| `nexus_file_identifier.dart` | Parse Nexus filenames, normalize versions, and verify identity/edition using API/MD5 data |
| `outfit_detector.dart` | Read `.utoc/.pak` indexes and resolve asset tokens to suggest replaced outfits |
| `outfit_id_map.dart` | Maintain/query the outfit-entry map used by the picker |
| `package_index_reader.dart` | Read package indexes for content inspection and classification |
| `self_endorse_service.dart` | Handle SB Control Center's own endorsement, track status per account, and retry some transient errors |
| `self_update_service.dart` | Validate/apply an app update ZIP, replace files, and relaunch the executable on Windows |
| `special_mods_handler.dart` | Interpret mod IDs that need special handling and build installation selections |
| `splash_mods_handler.dart` | Read splash-image options, build installation selections, and assign destination indexes |
| `translation_service.dart` | Detect language and translate summaries/descriptions while protecting BBCode tags, URLs, and blocks that must not be translated |
| `update_service.dart` | Find new mod/CNS versions, interpret update strings, and account for editions/skipped versions |
| `variant_conflict_service.dart` | Group variants by file/identity and apply the selected installation options |
| `patcher_service.dart` | Scan packages, detect duplicate container IDs, apply safe changes, and restore `.cnsbak` originals |
| `mod_classifier_service.dart` | Classify folders as CNS, generic, logic, movies, saves, configuration, splash, or unknown |
| `notification_service.dart` | Display in-app notifications |
| `thumbnail_service.dart` | Manage thumbnails and cover images used by cards/lists |
| `version_utils.dart` | Compare and normalize versions |
| `text_utils.dart` | Text normalization and presentation utilities |

## 18.1 Important widgets and dialogs

| Path | Role in the interface |
|---|---|
| `ui/widgets/installation_panel.dart` | File selection, preview, and installation processing panel |
| `ui/widgets/mod_details_panel.dart` | Mod details and metadata actions |
| `ui/widgets/mod_grid_card.dart` / `mod_list_tile.dart` | Grid/list presentation for a mod |
| `ui/widgets/outfit_picker_sheet.dart` | Outfit search, selection, and preview |
| `ui/widgets/image_viewer.dart` / `mod_image_widgets.dart` | Image and gallery viewing |
| `ui/widgets/download_pill_overlay.dart` | Indicator/controls for active downloads |
| `ui/widgets/self_endorse_section.dart` | Section for endorsing the application itself |
| `ui/dialogs/variant_choice_dialog.dart` | Select variants and decide whether to install one or several |
| `ui/dialogs/special_mod_dialog.dart` | Select special-mod options |
| `ui/dialogs/splash_mod_dialog.dart` | Select splash images and folders |
| `ui/dialogs/mod_801_steam_dialog.dart` | Generate/copy Steam launch options for mod 801 |
| `ui/dialogs/repair_game_dialog.dart` | Confirm, monitor, and review startup-repair results |
| `ui/dialogs/self_update_dialog.dart` | Confirm and monitor self-update |
| `ui/dialogs/edit_dialogs.dart` | Edit names, metadata, and links |

# 19. Data models and metadata

## 19.1 `ModInfo`

The main mod model includes:

- Directory and enabled/disabled state.
- Nexus ID and local version.
- Modification/installation date.
- Display name and custom name.
- Mod type and tag/category.
- Author, summary, description, notes, and source URL.
- Cover image and cover alignment/modification date.
- Image gallery.
- Nexus mod name and file/edition name.
- List of replaced outfits.

Custom fields may take precedence over the original information received from Nexus.

## 19.2 `PreparedMod` and file processing

`PreparedMod` represents a mod detected before installation. It includes the source folder, type, filename, Nexus identity/ID/version, UE4SS and `~mods` components, variant label, and a reference to the source archive if it contains multiple options.

`ArchiveProcessingResult` groups the prepared-mod list and optionally a detected UE4SS component or CNS update folder. This lets the installer separate a base-system installation from ordinary mods.

## 19.3 Application preferences

The keys defined in `AppPrefs` include:

- `languageCode`
- `gameRootPath`
- `sevenZipPath`
- `nexusApiKey`
- `skippedVersions`
- `filterMode`
- `modTypeFilterMode`
- `sortMode`
- `viewMode`
- `showModTypeTags`
- `autoAssignOutfits`
- `hideApiKeyPrompt`

Additional Nexus-account preferences are stored in keys related to the detected account plan. The physical persistence mechanism is managed by `SharedPreferences`.

## 19.4 Installation manifests

The CNS/UE4SS manifests are lists of relative paths generated from each component's source folder. The installer uses them to uninstall only paths it believes it installed. The application also keeps a repair journal to detect an interrupted repair and attempt to restore the components during a later launch.

# 20. Observed integrations and dependencies

The imports visible in the code show that the application uses, among others:

| Package or platform | Usage visible in the code |
|---|---|
| Flutter / Dart | Interface, state, files, processes, and core logic |
| `shared_preferences` | App preferences |
| `file_picker` | File and folder selection |
| `desktop_drop` | Desktop drag and drop |
| `http` | Nexus requests and downloads |
| `path` | Path handling |
| `url_launcher` | Open external pages and links |
| `package_info_plus` | Retrieve the installed application version |
| `window_manager` | Window size, visibility, and focus |
| `protocol_handler` | Register and receive the `nxm://` protocol |
| `windows_single_instance` | Keep a single active Windows instance |
| `translator` | Online translation of mod text |
| `hugeicons` | Interface icons |

This list is derived from visible imports, not the complete dependency manifest. Without `pubspec.yaml`, exact package versions and SDK requirements cannot be confirmed.

# 21. Troubleshooting

| Problem | Likely cause | What to check |
|---|---|---|
| The app cannot find the game | Incorrect path or missing expected folder structure | Select the root containing `SB/Content/Paks`, not a subfolder |
| An archive will not install | 7-Zip is missing or its path is incorrect | Configure `7z.exe`; retry the `.zip`, `.rar`, or `.7z` file |
| Unsupported format message | The file is not `.zip`, `.rar`, or `.7z` | Download/select a format supported by the installer |
| Nexus API fails | Invalid key, missing permissions, connection issue, or request limit | Validate the key again and check counters/errors; if a temporary limit was reached, try later |
| Download link expired | The Nexus CDN link is no longer valid | Retry so a fresh link can be requested, if the workflow supports it |
| No gallery images appear | The mod has no gallery, the API key is missing, or the request failed | Configure the API and refresh metadata; distinguish a network failure from an empty gallery |
| A mod will not enable | Variant/outfit conflict, locked files, or incomplete component path | Review conflict messages, close the game and external tools, then retry |
| Two replacements cannot both be enabled | They are assigned to the same outfit | Decide which mod should remain enabled or correct the outfit assignment in Details |
| A logic mod stops working after disable/re-enable | A secondary component may not have moved/restored correctly | Check `nexus_info.json`, `LogicMods`, `~mods`, and UE4SS paths; review the app log |
| The game closes on startup | UE4SS/CNS or another mod may be involved | Close the game and use **Repair Game Startup**; do not interrupt the procedure |
| The patcher reports unresolved warnings | An unsafe conflict or `Package_Id` conflict cannot be resolved automatically | Read the full log; some groups are reported but left unchanged |
| The uninstall button fails | A manifest is missing | Do not delete manifests manually; the app needs them to identify installed paths |
| A file cannot be moved or deleted | Another process has it open or it is protected | Close the game, FModel, File Explorer, and other applications that may use it; check permissions |
| A translated description loses formatting | External service failure or complex text/BBCode | Restore the original description and try again with a working connection |
| Self-update does not install the ZIP | Not on Windows, not a release build, or package lacks the expected executable | Use the correct release package; test mode does not install on debug builds |

## 21.1 Recommended procedure when a mod fails

1. Disable the mod in SB Control Center.
2. Check its type and assigned destination; confirm whether it replaces an already occupied outfit.
3. Check that CNS/UE4SS dependencies are installed.
4. If the game still fails without the mod, try the startup repair.
5. If the issue appears related to container IDs, run the patcher and review its log before deciding whether to keep the changes.
6. Do not randomly delete internal folders/manifests; keep a backup first and use the restoration features.

# 22. Limitations of this documentation

This documentation was built from the supplied XML, which bundles source-code files. The following information is not fully included in that package, so it is not stated as fact:

- Exact versions of Flutter, Dart, and third-party packages.
- Official commands and build options for producing the final installer.
- Complete contents of distribution scripts, Windows protocol association, and packaging configuration.
- Automated tests, compatibility matrix by game version, and author documentation.
- Official distribution URLs and the product support policy.
- A complete inventory of resources, interface images, and local databases excluded from the XML.

Version 3.0.0 is taken from the supplied filename, not from a visible `pubspec.yaml`. Before publishing this guide as official release documentation, verify the version against the actual build and complete the installer/distribution details.

# 23. Glossary

- **API key:** a personal key used to authenticate SB Control Center requests to the Nexus Mods API.
- **CNS:** Custom Nanosuit System, the base system for mods built for it.
- **Container ID / `Container_Id`:** an identifier for a container in IoStore packages; duplicates can cause conflicts.
- **Endorse:** to support/rate a mod on Nexus Mods, subject to Nexus requirements.
- **Edition:** a specific file of a Nexus mod, such as a CNS-compatible edition; it may be managed separately from other editions.
- **LogicMod:** a logic mod whose content is installed in `LogicMods` and may use UE4SS.
- **MD5:** a hash used, among other signals, to help identify an exact downloaded file.
- **Nexus ID:** the numerical identifier of a mod on Nexus Mods.
- **`nexus_info.json`:** a local file accompanying a mod that stores its identity and managed metadata.
- **`nxm://`:** the protocol used by Nexus Mods to pass download links to a compatible manager.
- **`.pak`, `.ucas`, `.utoc`:** Unreal Engine content/container files examined by some manager routines.
- **`.cnsbak`:** a backup file used by the patcher to revert package changes.
- **Outfit replacement:** a mod that replaces content associated with a specific Eve outfit.
- **UE4SS:** a tool/runtime loaded by certain Unreal Engine mods; CNS depends on it in this implementation.
- **Variant:** an option included in an archive that can be installed separately from other options.

---

## Appendix A. Source files to inspect first

- `lib/main.dart`: application entry point and main coordinator.
- `lib/settings_page.dart`: Settings structure.
- `lib/config/app_prefs.dart`: persistent preference keys.
- `lib/models/mod_info.dart`: primary mod model.
- `lib/models/installation_models.dart`: representation of prepared mods before installation.
- `lib/mod_classifier_service.dart`: classification rules based on file/folder type.
- `lib/services/archive_service.dart`: initial archive analysis.
- `lib/services/mod_manager_service.dart`: CNS JSON and mod data handling.
- `lib/services/nexus_api_service.dart`: Nexus Mods integration.
- `lib/services/nexus_file_identifier.dart`: mod/file/edition identification.
- `lib/services/outfit_detector.dart`: asset-based outfit detection.
- `lib/services/variant_conflict_service.dart`: variant selection.
- `lib/services/core_installer_service.dart`: UE4SS/CNS installation and manifests.
- `lib/services/game_repair_service.dart`: startup repair.
- `lib/patcher_service.dart`: container-conflict patching and reversal.
- `lib/services/movie_mods_handler.dart`: movie installation/restoration.
- `lib/services/splash_mods_handler.dart`: splash-image installation.
- `lib/services/hd_atool_audio_service.dart`: special handling of HD-ATOOL audio.
- `lib/l10n/app_*.arb`: language resources.

## Appendix B. Release documentation checklist

- [ ] Confirm that the distributed application reports version 3.0.0.
- [ ] Confirm minimum Windows requirements and the Flutter/Dart versions used to build it.
- [ ] Verify which installer/distributor registers the `nxm://` protocol.
- [ ] Test UE4SS/CNS installation and uninstallation on both a clean installation and an already-modded installation.
- [ ] Test each mod type in a test profile, including backup and restoration.
- [ ] Test Nexus download, pause, resume, and link renewal.
- [ ] Test update/reinstall/downgrade flows and multi-edition management.
- [ ] Test startup repair on success and during interruption/recovery.
- [ ] Confirm and document exact paths in a real Steam installation.
- [ ] Review translations and screenshots from the final version.
