--!strict

-- Main
export type PlayerManager = {
	Init: (
		self      : PlayerManager
	) -> nil,

	OnPlayerConnect: (
		self      : PlayerManager,
		player    : Player
	) -> nil,

	OnPlayerDisconnect      : (
		self      : PlayerManager,
		player    : Player
	) -> nil,

	UpdatePlayerStats: (
		self      : PlayerManager,
		player    : Player
	) -> nil,

	ConfigurePlayerCharacter: (
		self      : PlayerManager,
		player    : Player,
		character : Model
	) -> nil,

	OnPlayerChat: (
		self      : PlayerManager,
		player    : Player,
		msg       : string
	) -> nil,

	SavePlayerStats: (
		self      : PlayerManager,
		player    : Player
	) -> nil,

	SaveAllPlayerStats: (
		self      : PlayerManager
	) -> nil,

}

-- Return
return {}
