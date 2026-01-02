--!strict

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

-- Types
local T_SoundParams     = require(ReplicatedStorage.Shared.Types.SoundParams)
local T_SoundHandler    = require(ReplicatedStorage.ClientStorage.Types.SoundHandler)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)
local D_Sfx             = require(ReplicatedStorage.Shared.Data.Sfx)

-- Modules
local Settings          = require(ReplicatedStorage.Shared.Settings)
--local Util            = require(ReplicatedStorage.Shared.Lib.Util)

-- Local vars
local LocalPlayer       = Players.LocalPlayer :: Player

--[[

	SoundHandler

	What do:

	- Plays sound effects and music for the LocalPlayer
	- Pre-loads all sound effects during Init
	- Uses 2 sound groups (sfx and music)
	- Auto-ducks music when sfx are triggered

	How to use:

	- Reacts to RE_TriggerSound and BE_TriggerSound firing
	- Can also be included as a singleton and called directly
	- Accepts two params
		- soundKeys: Sound instance or table of Sound Instances
			- Eg D_sfx.onGameStart
		- params: TriggerSound.Params:
			- see ReplicatedStorage.Shared.Types.SoundParams for options


]]



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local SoundHandler = {}


--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝
--

function SoundHandler:Config()
	self.musicFadeOutDuration = 0.5
	self.musicFadeInDuration  = 0.5

	self.musicPlayOnLoad = D_Sfx.Music_Lobby
end



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

type InitConfig = {
	BE_TriggerSound: BindableEvent,
	RE_TriggerSound: RemoteEvent,
}

function SoundHandler:Init(config: InitConfig)
	self:Config()

	-- Pre-load all the sound files
	self:PreloadSounds()

	-- Mute music for local test players
	if LocalPlayer.UserId < 1 then
		self.musicMuted = true
	end

	-- Watch the Player Attributes which control muting sfx/music
	LocalPlayer:GetAttributeChangedSignal(D_Attributes.PlayerPrefs.Sfx):Connect(function()
		self.sfxMuted = not LocalPlayer:GetAttribute(D_Attributes.PlayerPrefs.Sfx)
	end)
	LocalPlayer:GetAttributeChangedSignal(D_Attributes.PlayerPrefs.Music):Connect(function()
		self.musicMuted = not LocalPlayer:GetAttribute(D_Attributes.PlayerPrefs.Music)
		if self.musicMuted then
			self:StopMusic(0.25)
		else
			self:StartMusic(self.currentMusic)
		end
	end)

	-- Bind to TriggerSound Remote/Bindable events
	assert(config.RE_TriggerSound, "RE_TriggerSound not provided")
	config.RE_TriggerSound.OnClientEvent:Connect(
		function(sound: Sound | { Sound }, params: T_SoundParams.SoundParams)
			self:TriggerSound(sound, params)
		end
	)

	assert(config.BE_TriggerSound, "BE_TriggerSound not provided")
	config.BE_TriggerSound.Event:Connect(
		function(sound: Sound | { Sound }, params: T_SoundParams.SoundParams)
			self:TriggerSound(sound, params)
		end
	)

	-- Tirgger music
	if self.musicPlayOnLoad then
		if LocalPlayer.UserId > 1 then
			self:TriggerMusic(self.musicPlayOnLoad)
		end
	end
end




-- ██████╗ ██████╗ ███████╗██╗      ██████╗  █████╗ ██████╗     ███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗ ███████╗
-- ██╔══██╗██╔══██╗██╔════╝██║     ██╔═══██╗██╔══██╗██╔══██╗    ██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗██╔════╝
-- ██████╔╝██████╔╝█████╗  ██║     ██║   ██║███████║██║  ██║    ███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║███████╗
-- ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██║   ██║██╔══██║██║  ██║    ╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║╚════██║
-- ██║     ██║  ██║███████╗███████╗╚██████╔╝██║  ██║██████╔╝    ███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝███████║
-- ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝
--

function SoundHandler:PreloadSounds()

	local soundsLoaded = 0 -- counter for debug prints
	--self.sounds = {} -- Not used as they're never referenced - left as stub in case it changes to clone existing sfx

	-- Utility function, load a given sound
	local function LoadSound(name, soundId, soundGroup, volume, isLooped)
		local sound        = Instance.new("Sound", soundGroup)
		sound.Name         = name
		sound.SoundId      = soundId
		sound.Looped       = isLooped or false
		sound.PlayOnRemove = false
		sound.Volume       = volume or 1
		sound.SoundGroup   = soundGroup

		--self.sounds[key] = sound -- disabled, old code stored these sounds in a table but they're not referenced again.
		soundsLoaded += 1
	end

	-- Utility function, load all sounds from an asphalt table
	local function LoadTableOfSounds(t, soundGroup, volume)
		if not t then return end
		for key, value in pairs(t) do
			if typeof(value) == "string" then
				LoadSound(key, value, soundGroup, volume)
			elseif typeof(value) == "table" then
				LoadTableOfSounds(value, soundGroup, volume)
			end
		end
	end

	-- Create a folder to store the Sound Groups, and Sounds
	local soundsFolder = LocalPlayer:WaitForChild("Sounds", 1)
	if not soundsFolder then
		soundsFolder        = Instance.new("Folder", LocalPlayer)
		soundsFolder.Name   = "Sounds"
	end

	-- Create the Sound Groups
	self.SG_Sfx          = Instance.new("SoundGroup", soundsFolder)
	self.SG_Sfx.Name     = "SG_Sfx"
	self.SG_Sfx.Volume   = Settings.Audio.EffectsVolume

	self.SG_Music        = Instance.new("SoundGroup", soundsFolder)
	self.SG_Music.Name   = "SG_Music"
	self.SG_Music.Volume = Settings.Audio.MusicVolume

	-- Create Sound instance to use for playing the BGM
	self.Sound_Music              = Instance.new("Sound", self.SG_Music) :: Sound
	self.Sound_Music.Looped       = true
	self.Sound_Music.Name         = "MUSIC"
	self.Sound_Music.PlayOnRemove = false
	self.Sound_Music.Volume       = Settings.Audio.MusicVolume
	self.Sound_Music.SoundGroup   = self.SG_Music

	-- Setup the SoundCompressor used for 🦆ing
	local duck     = Instance.new("CompressorSoundEffect", self.SG_Music) :: CompressorSoundEffect
	duck.SideChain = self.SG_Sfx
	duck.Threshold = -55
	duck.Attack    = 0.05
	duck.Release   = 0.05
	duck.Ratio     = 3

	-- Track the music currently being played - used when resuming music
	self.currentMusic = nil

	-- Preload all the sfx and music to speed up loading later
	--LoadTableOfSounds(D_Asphalt.sfx, self.SG_Sfx, Settings.Audio.EffectsVolume)
	--LoadTableOfSounds(D_Asphalt.music, self.SG_Music, Settings.Audio.MusicVolume)

	print("SoundHandler:PreloadSounds():", soundsLoaded, "loaded")
end



-- ████████╗██████╗ ██╗ ██████╗  ██████╗ ███████╗██████╗     ███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
-- ╚══██╔══╝██╔══██╗██║██╔════╝ ██╔════╝ ██╔════╝██╔══██╗    ██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
--    ██║   ██████╔╝██║██║  ███╗██║  ███╗█████╗  ██████╔╝    ███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
--    ██║   ██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██╔══██╗    ╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
--    ██║   ██║  ██║██║╚██████╔╝╚██████╔╝███████╗██║  ██║    ███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
--    ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
--

function SoundHandler:TriggerSound(
	sound : Sound | { Sound },
	params: T_SoundParams.SoundParams
)
	print("SoundHandler:TriggerSound(sound, params)", sound, params)

	if self.sfxMuted then
		print("SoundHandler:TriggerSound(): disabled so aborting")
		return
	end

	-- Ensure sound is valid
	if not sound then
		error("SoundHandler:TriggerSound() - invalid Sound:")
	end

	-- Convert single Sound to table of Sounds
	if typeof(sound) ~= "table" then
		sound = { sound }
	end

	-- Set param defaults
	params                = params :: T_SoundParams.SoundParams or {} :: T_SoundParams.SoundParams
	params.parent         = params.parent or self.SG_Sfx
	params.pitchIncrement = params.pitchIncrement or 0
	params.pitchOffset    = params.pitchOffset or 0
	params.pitchRandom    = params.pitchRandom or 0
	params.repeatCount    = params.repeatCount or 1
	params.repeatDelay    = params.repeatDelay or 1
	params.repeatRandom   = params.repeatRandom or 0

	-- Function to return a random pitch shift value
	local function GetRandomPitchShiftOctave()
		local randomPitch = 0
		while randomPitch == 0 do
			randomPitch = (math.random() * 2 - 1) * params.pitchRandom
		end
		return randomPitch
	end

	local pitchIncrementRunningTotal = 1

	-- Repeat it as required
	for i=1, params.repeatCount do
		print("SoundHandler:TriggerSound(): repeat", i)

		-- Choose a random sfx from the table of options
		local sfx = sound[math.random(#sound)]
		if not sfx then
			error("SoundHandler:TriggerSound() - invalid soundEffect:")
		end

		-- Create the sound
		local soundInstance        = Instance.new("Sound", params.parent) :: Sound
		local pitchShift           = nil -- placeholder
		soundInstance.Parent       = params.parent
		soundInstance.SoundId      = sfx.SoundId
		soundInstance.Volume       = 1
		soundInstance.PlayOnRemove = false
		soundInstance.Looped       = false
		soundInstance.SoundGroup   = self.SG_Sfx

		-- Wait until loaded
		if not soundInstance.IsLoaded then
			print("SoundHandler:TriggerSound(): Waiting for sound to load...")
			soundInstance.Loaded:Wait()
		end

		-- Random pitch stuff
		if
			params.pitchRandom ~= 0 or
			params.pitchIncrement ~= 0 or
			params.pitchOffset ~= 0
		then
			-- Find or create the pitchshift instance
			pitchShift = Instance.new("PitchShiftSoundEffect", soundInstance)

			-- Increment the pitch, if required
			if params.pitchIncrement ~= 0 then
				pitchShift.Octave = pitchIncrementRunningTotal
				pitchIncrementRunningTotal += params.pitchIncrement
			end

			-- Randomise pitch, if required
			if params.pitchRandom ~= 0 then
				pitchShift.Octave += GetRandomPitchShiftOctave()
			end

			-- Offset pitch, if required
			if params.pitchOffset ~= 0 then
				pitchShift.Octave += params.pitchOffset
			end
		end

		-- Trigger the sound and then destroy it
		task.spawn(function()
			print("SoundHandler:TriggerSound(): sound:Play()")
			soundInstance:Play()
			soundInstance.Ended:Wait()

			-- Remove the sound, and pitchshift
			if pitchShift then pitchShift:Destroy() end
			soundInstance:Destroy()
		end)

		-- If repeat, configure delay
		if params.repeatCount > 1 then
			local repeatDelay = params.repeatDelay

			-- random delay?
			if params.repeatRandom and params.repeatRandom ~= 0 then
				repeatDelay += (math.random(params.repeatRandom * 2000) / 1000) + params.repeatRandom
			end

			print("SoundHandler:TriggerSound(): Waiting repeatDelay:", repeatDelay)
			task.wait(repeatDelay)
		end
	end
end



-- ████████╗██████╗ ██╗ ██████╗  ██████╗ ███████╗██████╗     ███╗   ███╗██╗   ██╗███████╗██╗ ██████╗
-- ╚══██╔══╝██╔══██╗██║██╔════╝ ██╔════╝ ██╔════╝██╔══██╗    ████╗ ████║██║   ██║██╔════╝██║██╔════╝
--    ██║   ██████╔╝██║██║  ███╗██║  ███╗█████╗  ██████╔╝    ██╔████╔██║██║   ██║███████╗██║██║
--    ██║   ██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██╔══██╗    ██║╚██╔╝██║██║   ██║╚════██║██║██║
--    ██║   ██║  ██║██║╚██████╔╝╚██████╔╝███████╗██║  ██║    ██║ ╚═╝ ██║╚██████╔╝███████║██║╚██████╗
--    ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝
--

function SoundHandler:TriggerMusic(
	sound: Sound,
	fade : boolean
)
	fade = fade == false and false or true

	print("SoundHandler:TriggerMusic()", sound, fade)

	if self.currentMusic then
		self:StopMusic(fade and self.musicFadeOutDuration or 0)
		task.wait(fade and self.musicFadeOutDuration or 0)
	end

	if not self.musicMuted then
		self:StartMusic(sound, fade and self.musicFadeInDuration or 0)
	end

	self.currentMusic = sound
end



-- ███████╗████████╗ █████╗ ██████╗ ████████╗    ███╗   ███╗██╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝    ████╗ ████║██║   ██║██╔════╝██║██╔════╝
-- ███████╗   ██║   ███████║██████╔╝   ██║       ██╔████╔██║██║   ██║███████╗██║██║
-- ╚════██║   ██║   ██╔══██║██╔══██╗   ██║       ██║╚██╔╝██║██║   ██║╚════██║██║██║
-- ███████║   ██║   ██║  ██║██║  ██║   ██║       ██║ ╚═╝ ██║╚██████╔╝███████║██║╚██████╗
-- ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝       ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝
--

function SoundHandler:StartMusic(
	sound: Sound,
	fadeInDuration: number
)
	print("SoundHandler:StartMusic(sound, fadeInDuration)", sound, fadeInDuration)

	fadeInDuration = fadeInDuration or self.musicFadeInDuration

	-- Start the previously playing music if no track was specified
	if not sound then
		warn("SoundHandler:StartMusic() - invalid sound:")
		return
	end

	-- Update the current sound
	self.Sound_Music.SoundId = sound.SoundId
	self.Sound_Music:Play()

	-- Update the volume, either fadeIn or instant
	if fadeInDuration == 0 then
		self.Sound_Music.Volume = Settings.Audio.MusicVolume
	else
		self:FadeMusicVolume(0, Settings.Audio.MusicVolume, fadeInDuration)
	end

end



-- ███████╗████████╗ ██████╗ ██████╗ ███╗   ███╗██╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗████╗ ████║██║   ██║██╔════╝██║██╔════╝
-- ███████╗   ██║   ██║   ██║██████╔╝██╔████╔██║██║   ██║███████╗██║██║
-- ╚════██║   ██║   ██║   ██║██╔═══╝ ██║╚██╔╝██║██║   ██║╚════██║██║██║
-- ███████║   ██║   ╚██████╔╝██║     ██║ ╚═╝ ██║╚██████╔╝███████║██║╚██████╗
-- ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝
--

function SoundHandler:StopMusic(fadeOutDuration: number)
	print("SoundHandler:StopMusic()")
	fadeOutDuration = fadeOutDuration or 0

	if fadeOutDuration == 0 then
		self.Sound_Music.Volume = 0
		return
	end

	self:FadeMusicVolume(self.Sound_Music.Volume, 0, fadeOutDuration)
	task.wait(fadeOutDuration)
end



-- ███████╗ █████╗ ██████╗ ███████╗███╗   ███╗██╗   ██╗███████╗██╗ ██████╗██╗   ██╗ ██████╗ ██╗     ██╗   ██╗███╗   ███╗███████╗
-- ██╔════╝██╔══██╗██╔══██╗██╔════╝████╗ ████║██║   ██║██╔════╝██║██╔════╝██║   ██║██╔═══██╗██║     ██║   ██║████╗ ████║██╔════╝
-- █████╗  ███████║██║  ██║█████╗  ██╔████╔██║██║   ██║███████╗██║██║     ██║   ██║██║   ██║██║     ██║   ██║██╔████╔██║█████╗  
-- ██╔══╝  ██╔══██║██║  ██║██╔══╝  ██║╚██╔╝██║██║   ██║╚════██║██║██║     ╚██╗ ██╔╝██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══╝  
-- ██║     ██║  ██║██████╔╝███████╗██║ ╚═╝ ██║╚██████╔╝███████║██║╚██████╗ ╚████╔╝ ╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║███████╗
-- ╚═╝     ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝  ╚═══╝   ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
--

function SoundHandler:FadeMusicVolume(
	startVolume: number,
	finalVolume: number,
	duration   : number
)
	-- Use RunConnect to fade volume in
	local connect
	local elapsed = 0
	self.Sound_Music.Volume = startVolume
	connect = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		local progress          = elapsed / duration
		local currentVolume     = progress * finalVolume
		self.Sound_Music.Volume = currentVolume

		if elapsed > duration then
			self.Sound_Music.Volume = finalVolume
			connect:Disconnect()
		end
	end)
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return SoundHandler :: T_SoundHandler.SoundHandler
