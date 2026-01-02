--!strict

-- Define a static type. This is a a lot of work just to get IDE hinting but I don't see a way around it. Cursor auto-complete does most of the heavy lifting here.
export type T_Events = {
    BindableEvent: {
        OnClientLoad  : BindableEvent,
        TriggerHaptic : BindableEvent,
        TriggerMessage: BindableEvent,
        TriggerSound  : BindableEvent,
		HideWindow    : BindableEvent,
		ShowWindow    : BindableEvent,
    },
	BindableFunction: {
	},
	RemoteEvent: {
		TriggerHaptic : RemoteEvent,
		TriggerMessage: RemoteEvent,
		TriggerSound  : RemoteEvent,
	},
	RemoteFunction: {
		--GetPlayerData: RemoteFunction,
	}
}

-- Data
local Events                        = {} :: { [string]: table }

-- Bindable Events
Events.BindableEvent                = {} :: { [string]: BindableEvent }
Events.BindableEvent.OnClientLoad   = Instance.new("BindableEvent")  :: BindableEvent
Events.BindableEvent.TriggerHaptic  = Instance.new("BindableEvent")  :: BindableEvent
Events.BindableEvent.TriggerMessage = Instance.new("BindableEvent")  :: BindableEvent
Events.BindableEvent.TriggerSound   = Instance.new("BindableEvent")  :: BindableEvent
Events.BindableEvent.HideWindow     = Instance.new("BindableEvent")  :: BindableEvent
Events.BindableEvent.ShowWindow     = Instance.new("BindableEvent")  :: BindableEvent

-- Bindable Functions
Events.BindableFunction             = {} :: { [string]: BindableFunction }

-- Remote Events
Events.RemoteEvent                  = {} :: { [string]: RemoteEvent }
Events.RemoteEvent.TriggerHaptic    = Instance.new("RemoteEvent")  :: RemoteEvent
Events.RemoteEvent.TriggerMessage   = Instance.new("RemoteEvent")  :: RemoteEvent
Events.RemoteEvent.TriggerSound     = Instance.new("RemoteEvent")  :: RemoteEvent

-- Remote Functions
Events.RemoteFunction               = {} :: { [string]: RemoteFunction }
--Events.RemoteFunction.GetKeys       = Instance.new("RemoteFunction")  :: RemoteFunction

-- Returns
return Events :: T_Events
