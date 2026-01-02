-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

-- Data
local D_Attributes = require(ReplicatedStorage.Shared.Data.Attributes)
local D_Events     = require(ReplicatedStorage.Shared.Data.Events)

-- Modules
local Settings = require(ReplicatedStorage.Shared.Settings)
local Util     = require(ReplicatedStorage.Shared.Lib.Util)


--[[ WHATDO

Creates and stores refrences to Remote/Bindable Event/Functions

Configure it:

	See: src/luau/shared/Data/Events.luau

Require it:

	local _EventManager = require(ReplicatedStorage.Shared.Modules.EventManager)

Call it:

	_EventManager.Instances.RemoteEvent.TriggerHaptic:Fire()

]]



-- ████████╗██╗   ██╗██████╗ ███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
--    ██║      ██║   ██║     ███████╗
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝
--

export type T_EventManager = {
	-- Methods
	--Init          : () -> nil, -- Disabled, because they're not public, so we don't need hinting for them
	--SetupInstances: () -> nil, -- Disabled, because they're not public, so we don't need hinting for them

	-- Properties
	Instances     : D_Events.T_Events,
	IsLoaded      : boolean,
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local EventManager = {
	IsLoaded      = false,
} :: T_EventManager

function EventManager:Init()

	-- Get the list of Event/Functions to be created
	self.Instances = D_Events

	-- Set the location for all Event/Functions
	self.Parent     = nil
	self.FolderName = "EventManager"

	-- Create those Event/Function instances, or find them in ReplicatedStorage
	if RunService:IsServer() then
		self:SetupInstances()
	else
		self:AssociateInstances()
	end

	self.IsLoaded = true
end



-- ███████╗███████╗████████╗██╗   ██╗██████╗     ██╗███╗   ██╗███████╗████████╗ █████╗ ███╗   ██╗ ██████╗███████╗███████╗
-- ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔════╝
-- ███████╗█████╗     ██║   ██║   ██║██████╔╝    ██║██╔██╗ ██║███████╗   ██║   ███████║██╔██╗ ██║██║     █████╗  ███████╗
-- ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝     ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║╚██╗██║██║     ██╔══╝  ╚════██║
-- ███████║███████╗   ██║   ╚██████╔╝██║         ██║██║ ╚████║███████║   ██║   ██║  ██║██║ ╚████║╚██████╗███████╗███████║
-- ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝         ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚══════╝
--

function EventManager:SetupInstances()
	-- Server only
	-- Creates the Event/Function Instances in ReplicatedStorage

	print("EventManager:SetupInstances()")

	-- Create a folder to store the Event/Functions in
	self.Parent      = Instance.new("Folder", ReplicatedStorage)
	self.Parent.Name = self.FolderName

	-- Create all required Event/Functions
	for eventType, names in pairs(self.Instances) do
		for name, _ in pairs(names) do
			local instanceName = eventType:gsub("%l", "") .. "_" .. name -- prefix names with event types, eg BE_OnClientLoad
			--print("EventManager:SetupInstances() - creating", instanceName)

			self.Instances[eventType][name].Name   = instanceName
			self.Instances[eventType][name].Parent = self.Parent
		end
	end
end



--  █████╗ ███████╗███████╗ ██████╗  ██████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ███╗   ██╗ ██████╗███████╗███████╗
-- ██╔══██╗██╔════╝██╔════╝██╔═══██╗██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔════╝
-- ███████║███████╗███████╗██║   ██║██║         ██║██╔██╗ ██║███████╗   ██║   ███████║██╔██╗ ██║██║     █████╗  ███████╗
-- ██╔══██║╚════██║╚════██║██║   ██║██║         ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║╚██╗██║██║     ██╔══╝  ╚════██║
-- ██║  ██║███████║███████║╚██████╔╝╚██████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║██║ ╚████║╚██████╗███████╗███████║
-- ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝  ╚═════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚══════╝
--

function EventManager:AssociateInstances()
	-- Client Only
	-- Loops through the list of self.Get Events/Functions and find the relevant Instance for them

	-- Locate the folder of Event/Functions, or wait while it's created
	self.Parent = ReplicatedStorage:WaitForChild(self.FolderName, 10)

	if not self.Parent then
		error("EventManager:AssociateInstances() - couldn't find parent folder: " .. self.FolderName)
		return
	end

	-- Loop through all the Event/Functions and find the associated Instance
	for eventType, names in pairs(self.Instances) do
		for name, _ in pairs(names) do
			local instanceName = eventType:gsub("%l", "") .. "_" .. name
			self.Instances[eventType][name] = self.Parent:WaitForChild(instanceName, 10)

			-- Error handling for missing Instances
			if not self.Instances[eventType][name] then
				error("EventManager:AssociateInstances() - couldn't find event/function: " .. instanceName)
				return
			end
		end
	end
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return EventManager :: T_EventManager
