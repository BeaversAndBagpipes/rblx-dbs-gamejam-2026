* Save `*.blend` files to the folder: `src/models/blend`
* Save `*.fbx`files to the folder `src/models/fbx`
* Save textures to `src/textures/` in a suitable sub-folder

### Importing Models to Studio

- Use the Roblox Blender plugin:
	- https://github.com/Roblox/roblox-blender-plugin
	- Test and working with Bender 4.2.11 LTS
	- Test and working with Bender 4.5.0 LTS
- Place models in **Collections** ⚠
	- Plugin only tracks package changes if the root is the same, so always place assets in a collection
- Select the **Collection** and **Upload to Roblox**
	- This publishes the whole collection as a package
	- Package can then be placed in scene via *Studio -> Toolbox -> My Packages*
	- Changes can be uploaded via the plugin and will update the existing Package


