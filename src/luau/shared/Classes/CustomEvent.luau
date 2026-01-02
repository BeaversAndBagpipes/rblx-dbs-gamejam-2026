--!strict

--[[
	CustomEvent

	CustomEvent is a class that implements a custom event system
	simulating the behavior of Robloxs native events
	(which return RBXScriptSignal objects and support :Connect and :Disconnect).

	It allows you to connect callback functions with :Connect,
	and invoke them later by calling :Fire with any arguments.

	Example use:

		self.OnCustomEvent = CustomEvent.new()

		local connection
		connection = self.OnCustomEvent:Connect(function(value)
			print("CustomEvent value", val)
		end)

		self.OnCustomEvent:Fire("foo")

		--Dispose of connection
		connection:Disconnect()
]]

-- ████████╗██╗   ██╗██████╗ ███████╗███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
--    ██║      ██║   ██║     ███████╗███████║
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝
--

export type Connection = {
	Disconnect : (self: Connection) -> (),
	IsConnected: boolean,
}

export type CustomEvent = {
	Connect      : (
		self    : CustomEvent,
		callback: (...any) -> ()
	) -> Connection,
	Fire         : (
		self: CustomEvent, ...any
	) -> (),
	DisconnectAll: (
		self: CustomEvent
	) -> (),
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local CustomEvent = {}
CustomEvent.__index = CustomEvent

---
-- Creates a new CustomEvent instance.\
-- @return CustomEvent: A new CustomEvent object.
function CustomEvent.new(): CustomEvent
	local self = setmetatable({}, CustomEvent) :: any

	self.Connections = {} :: { [number]: (...any) -> () }
	self.Index       = 0 -- start at 0, as we will increment it before storing the callback

	return self
end



--  ██████╗ ██████╗ ███╗   ██╗███╗   ██╗███████╗ ██████╗████████╗
-- ██╔════╝██╔═══██╗████╗  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝
-- ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║        ██║
-- ██║     ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║        ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║███████╗╚██████╗   ██║
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝
--

---
-- Connects a callback function to the event.\
-- @param callback function: The function to be called when the event is fired.\
-- @return Connection: A connection object that can be used to disconnect the callback.
function CustomEvent:Connect(
	callback: (...any) -> ()
): Connection

	if type(callback) ~= "function" then
		error("Expected function for Connect")
	end

	-- Increment the index and store it
	self.Index += 1
	local index = self.Index

	-- Store the callback
	self.Connections[index] = callback

	-- Build a Connection object to return, which can be used to disconnect the connection
	local connection = {
		IsConnected = true,
		Disconnect  = function(self)
			if not self.IsConnected then return end
			self.IsConnected = false
			self.Connections[index] = nil
		end
	} :: Connection

	return connection
end



-- ███████╗██╗██████╗ ███████╗
-- ██╔════╝██║██╔══██╗██╔════╝
-- █████╗  ██║██████╔╝█████
-- ██╔══╝  ██║██╔══██╗██╔══
-- ██║     ██║██║  ██║███████╗
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝
--

---
-- Fires the event, calling all connected callbacks with the provided arguments.\
-- @param ... any: Arguments to pass to the connected callbacks.
function CustomEvent:Fire(...: any) 
	for _, callback in pairs(self.Connections) do
		task.spawn(callback, ...)
	end
end



-- ██████╗ ██╗███████╗ ██████╗ ██████╗ ███╗   ██╗███╗   ██╗███████╗ ██████╗████████╗    █████╗ ██╗     ██╗
-- ██╔══██╗██║██╔════╝██╔════╝██╔═══██╗████╗  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝   ██╔══██╗██║     ██║
-- ██║  ██║██║███████╗██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║        ██║      ███████║██║     ██║
-- ██║  ██║██║╚════██║██║     ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║        ██║      ██╔══██║██║     ██║
-- ██████╔╝██║███████║╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║███████╗╚██████╗   ██║      ██║  ██║███████╗███████╗
-- ╚═════╝ ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝      ╚═╝  ╚═╝╚══════╝╚══════╝

---
-- Disconnects all connected callbacks from the event.
function CustomEvent:DisconnectAll()
	self.Connections = {}
	self.Index       = 0
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return CustomEvent
