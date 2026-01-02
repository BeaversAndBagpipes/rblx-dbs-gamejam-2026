-- Lune libs
local roblox  = require("@lune/roblox")
local fs      = require("@lune/fs")
local stdio   = require("@lune/stdio")
local process = require("@lune/process")

-- Custom libs
local GetGuiFromPlace = require("./lib/GetGuiFromPlace")
local GetWorkspaceFromPlace = require("./lib/GetWorkspaceFromPlace")


--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝
--

local rbxmOutputDir = "../src/rbxm/" -- Where Rojo will load the files from

local workspaceToSave = { -- List of Workspace folders and PlaceIDS to fetch
	134512934127662
}

local UIsToSave = { -- table of placeIDs to save StarterGUIs from
	134512934127662
}



--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗██████╗ ███╗   ███╗
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔══██╗████╗ ████║
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██████╔╝██╔████╔██║
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██╔══██╗██║╚██╔╝██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║██║  ██║██║ ╚═╝ ██║
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
--
local confirmAll = false
for _, v in ipairs(process.args) do
	if v == "--confirm-all" then
		confirmAll = true
	end
end

local confirm_uis = confirmAll
local confirm_workspace = confirmAll

if not confirmAll then
	confirm_uis = stdio.prompt("confirm", "Download & export UIs?", "yes")
	confirm_workspace = stdio.prompt("confirm", "Download & export Workspace?", "yes")
end

print("---")


-- ██╗   ██╗██╗
-- ██║   ██║██║
-- ██║   ██║██║
-- ██║   ██║██║
-- ╚██████╔╝██║
--  ╚═════╝ ╚═╝
--

local function UIToRbxm(placeID, outputFolder)
	print("> Saving UIs to: " .. outputFolder)

	-- Get the contents of the StarterGui
	local uiData = GetGuiFromPlace(placeID)

	-- Save each child to it's own file
	for i, child in ipairs(uiData) do
		if child:IsA("LayerCollector") then
			print("Found folder:" .. child.Name)

			local fileOut = outputFolder .. child.Name .. ".rbxm"
			fs.writeFile(fileOut, roblox.serializeModel({ child }))

			print("> Saved " .. placeID .. "/StarerGui --> " .. fileOut)
			print("> Saved ui " .. child.Name .. " to " .. fileOut)
		end
	end
end


-- ██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗███████╗██████╗  █████╗  ██████╗███████╗
-- ██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
-- ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ ███████╗██████╔╝███████║██║     █████
-- ██║███╗██║██║   ██║██╔══██╗██╔═██╗ ╚════██║██╔═══╝ ██╔══██║██║     ██╔══
-- ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗███████║██║     ██║  ██║╚██████╗███████╗
--  ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝
--

local function WorkspaceToRbxm(placeID, outputFolder)

	local workspace = GetWorkspaceFromPlace(placeID)
	local fileOut = outputFolder .. "Workspace.rbxm"

	fs.writeFile(fileOut, roblox.serializeModel({ workspace }))
	print("> Saved " .. placeID .. "/Workspace --> " .. fileOut)

	print("---")
end



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

if confirm_uis then
	for _, placeID in ipairs(UIsToSave) do
		UIToRbxm(placeID, rbxmOutputDir)
	end
end


if confirm_workspace then
	for _, id in ipairs(workspaceToSave) do
		WorkspaceToRbxm(id, rbxmOutputDir)
	end
end
