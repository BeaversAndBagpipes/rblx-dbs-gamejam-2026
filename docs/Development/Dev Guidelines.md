- [[Dev Guidelines#Project Overview – Roblox + Rojo Template]]
- [[Dev Guidelines#Rojo Configurations]]
- 
---

### Project Overview: Roblox + Rojo Template

This project provides a semi-managed workflow for developing Roblox games using Rojo, syncing between local files and a Roblox **Online Experience (OE)** (a Team Create-enabled place).

### Key Features

- Sync code changes live to the OE **without overwriting in-game content**
- Use `.rbxm` snapshots to build complete local versions for testing
- Pull latest content from OE to local using a custom **Lune script**
- Support for two Rojo configs:
    - `default`: full local build (code + assets)
    - `codeOnly`: live sync (code-only)

### Online Experience (OE)

- The OE is the **live Roblox Team Create place**.    
- Studio Builders make their contributions here: eg Maps, GUIs, Models
- A Lune script is used to pull the latest state of the OE into local `.rbxm` files:    
    - Example: `Workspace.rbxm`, `GUI.rbxm`        
- These `.rbxm` files are committed and used by the `default` config to reconstruct the scene for local development.

### Rojo Configurations

- #### `default.project.json`
	- Used for **local development** builds.
	- Includes:    
	    - Code from `src/luau/`
	    - Assets from `srx/rbxm/*.rbxm` files (`Workspace`, `StarterGui`, etc.)
	- Do **not** use to sync with the live Online Experience (OE)
	- Built by combining Luau source and pulled `.rbxm` data (via Lune)
	  
- #### `codeOnly.project.json`
	- Used for **live code sync** with the OE.
	- Contains **only** scripts mapped to Roblox services (no assets)
	- Safe to connect to the live game to push script changes
	- Prevents accidental overwrite of in-game assets

> ⚠️ **Important:** Don't push with `default` config to the OE — use `codeOnly` to avoid overwriting assets.

### Project Structure (Rojo Configuration)

This project uses Rojo to map local filesystem paths into the Roblox game tree:

`codeOnly/`
- `ReplicatedStorage/`
    - `ClientStorage/` → `src/luau/clientStorage`
    - `Shared/` → `src/luau/shared`        
- `ReplicatedFirst/`    
    - `Shared/` → `src/luau/replicatedFirst`        
- `ServerScriptService/`    
    - `Server/` → `src/luau/server`        
- `ServerStorage/` → `src/luau/serverStorage`    
- `StarterPlayer/`    
    - `StarterPlayerScripts/`        
        - `Client/` → `src/luau/client`

`default/` - *inherits from above, and additionally links these*
- `Workspace`→ `src/rbxm/Workspace.rbxm`
- `StarterGUI/`    
    - `GUI` → `src/rbxm/GUI.rbxm`
        - `Client/` → `src/luau/client`

## Code Practices:

- Single-entry point, eg `client/init.client.luau`, `server/init.server.luau` for all scripts
- Use existing `EventManager` from `stom66/rblx-project-template`
- Use existing Client scripts for UI/Sound etc (with adjustments) from `stom66/rblx-project-template` for familiarity
- Avoid direct references to singletons from other singletons - references should be passed to `:Init()` via entry point where practical
- Use Attributes on Player Characters to sync data where practical

### Workspace:

  - All Workspace contents should be organised into folders, but do not need to exist under a single root folder.

### Sounds

- No Asphalt - sounds are manually uploaded
- Sounds are stored directly on entities
- `SoundManager` has been re-worked to take Sound Instances instead of asphalt keys

### ScreenGui

- All contents must exist under a single root `ScreenGui` instance, eg `StarterGui/Root`



