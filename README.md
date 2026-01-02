# Roblox Project Template

A simplified project structure for developing Roblox experiences in small teams using a semi-managed Rojo pipeline.

## Table of Contents

- [Getting Started](#getting-started)
- [Pipeline Overview](#pipeline-overview)
- [Code Sync Workflow](#code-sync-workflow)
- [Project Structure](#project-structure)
- [Resources](#resources)

---

## Getting Started

1. Clone the template:  
   ```bash
   git clone https://github.com/stom66/rblx-simple-template rblx-project
   cd rblx-project
   git remote remove origin
   ```

2. **Build the base scene** using the `default.project.json` Rojo profile.

3. Open the generated scene in Roblox Studio and **Save to Roblox**.

4. Use this uploaded scene as the **Online Experience (OE)** for game development.
	- Update `Lune/SaveAssets.luau` with the new OE experience id

---

## Pipeline Overview

- Workspace and GUI are developed in a shared **Online Experience**.
- Blender assets are imported into Roblox Studio using a [Blender → Roblox plugin](https://github.com/Roblox/roblox-blender-plugin).
- Code is written externally and synced via Rojo:
  - `default`: for local dev (uses local `.rbxm` assets).
  - `codeOnly`: for syncing Luau code to the OE.

---

## Code Sync Workflow

1. Pull latest changes:
   ```bash
   git pull
   ```

2. *(Optional, recommended)* Run the asset fetch script:
   ```bash
   cd lune
   lune run SaveAssets -- --confirm-all
   ```

3. Use Rojo to serve the `codeOnly.project.json`:
   - Start the Rojo server.
   - Load the OE in Roblox Studio.
   - Connect Rojo.

> ⚠️ Ensure a valid Roblox API key is configured in a `.env` file. See `.env.example` for reference.

---

## Project Structure

```
.github/     → GitHub Actions for CI/CD (ignore)
.vscode/     → VSCode workspace settings
build/       → Output from Rojo (local dev builds)
docs/        → Additional documentation
lune/        → Scripts to sync OE assets locally
src/
  ├── audio/     → Music/SFX source and exported files
  ├── luau/      → All Luau code (see Rojo config for structure)
  ├── models/    → 3D source files (`.blend`, `.fbx`)
  ├── rbxm/      → Saved assets (Workspace, ScreenGuis)
  ├── textures/  → Textures, sprites, and GUI assets
```

---

## Resources

- [Test Experience (Roblox)](https://create.roblox.com/dashboard/creations/experiences/8186116224/overview)
