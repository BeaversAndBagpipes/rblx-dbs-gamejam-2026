--!strict

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

-- Types
local T_ParticleManager = require(ReplicatedStorage.ClientStorage.Types.ParticleManager)
local T_SoundHandler    = require(ReplicatedStorage.ClientStorage.Types.SoundHandler)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)
local D_Sfx             = require(ReplicatedStorage.Shared.Data.Sfx)

--Modules
local AnimParticles     = require(ReplicatedStorage.Shared.Lib["Anim.Particles"])
local Settings          = require(ReplicatedStorage.Shared.Settings)
local Util              = require(ReplicatedStorage.Shared.Lib.Util)

-- Local vars
local LocalPlayer       = Players.LocalPlayer :: Player
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local Gui               = PlayerGui:WaitForChild("GUI"):WaitForChild("UI_Coins") :: ScreenGui



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Coins = {}


-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

type InitConfig = {
	BE_TriggerSound: BindableEvent
}

function Coins:Init(config: InitConfig)
	Gui.Enabled = true

	-- Always show this UI
	self:Show()

	-- Get references to GameUI elements for later user
	self.Frame_CoinCount      = Gui:WaitForChild("CoinCount")                          :: Frame
	self.Frame_Particles_Root = Gui:WaitForChild("Particles_Root")                     :: Frame
	self.Frame_Particles      = self.Frame_Particles_Root:FindFirstChild("Particles")  :: Frame
	self.Particles            = self.Frame_Particles:GetChildren()

	-- UI References: Coins
	self.Txt_Coins_Value = self.Frame_CoinCount:FindFirstChild("Txt_Coins_Value", true) :: TextLabel

	-- Read Coin Coint, Update UI
	self.coins = LocalPlayer:GetAttribute(D_Attributes.PlayerData.Coins) :: number
	self:UpdateCoins()

	-- Set a flag we can use to ignore the first time the balance changes, eg when the player gets their initial balance
	self.IsFirstAnimation = true --disabled, as it stops the animation during the welcome tutorial

	-- Watch Attributes for changes
	LocalPlayer:GetAttributeChangedSignal(D_Attributes.PlayerData.Coins):Connect(function()
		print("C_Coins: GetAttributeChangedSignal for", D_Attributes.PlayerData.Coins)
		self:UpdateCoins()
	end)

	assert(config.BE_TriggerSound, "BE_TriggerSound not provided")
	self.BE_TriggerSound = config.BE_TriggerSound
end



-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function Coins:Show()
	print("Coins:Show()")
	Gui.Enabled = true
end

function Coins:Hide()
	print("Coins:Hide()")
	Gui.Enabled = false
end



-- ███████╗███████╗████████╗   ██████╗ ██████╗ ██╗███╗   ██╗  ██╗   ██╗ █████╗ ██╗     ██╗   ██╗███████╗
-- ██╔════╝██╔════╝╚══██╔══╝  ██╔════╝██╔═══██╗██║████╗  ██║  ██║   ██║██╔══██╗██║     ██║   ██║██╔════╝
-- ███████╗█████╗     ██║     ██║     ██║   ██║██║██╔██╗ ██║  ██║   ██║███████║██║     ██║   ██║█████╗  
-- ╚════██║██╔══╝     ██║     ██║     ██║   ██║██║██║╚██╗██║  ╚██╗ ██╔╝██╔══██║██║     ██║   ██║██╔══╝  
-- ███████║███████╗   ██║     ╚██████╗╚██████╔╝██║██║ ╚████║   ╚████╔╝ ██║  ██║███████╗╚██████╔╝███████╗
-- ╚══════╝╚══════╝   ╚═╝      ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝    ╚═══╝  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝
--

function Coins:UpdateCoins()

	local newCoinValue = LocalPlayer:GetAttribute(D_Attributes.PlayerData.Coins)

	if not newCoinValue then
		warn("Coins:UpdateCoins: Error! Couldn't find Coins attribute on Player. This might happen during first start, but shouldn't happen later in a game.")
		return
	end

	if not self.coins then
		self.coins                = newCoinValue
		self.Txt_Coins_Value.Text = Util.FormatNumber(newCoinValue)
		return
	end


	local diff = newCoinValue - self.coins

	local particleCount  = 10
	local sfxRepeatCount = 1
	local pitchIncrement = 0.05
	local pitchOffset    = 0

	do -- adjust counts for particles and sfx repeats
		if math.abs(diff) > 4000 then
			particleCount  = 500
			sfxRepeatCount = 40
			pitchIncrement = 0.03
			pitchOffset    = -0.4

		elseif math.abs(diff) > 2000 then
			particleCount  = 350
			sfxRepeatCount = 25
			pitchIncrement = 0.04
			pitchOffset    = -0.2

		elseif math.abs(diff) > 500 then
			particleCount  = 300
			sfxRepeatCount = 19
			pitchIncrement = 0.045

		elseif math.abs(diff) > 300 then
			particleCount  = 250
			sfxRepeatCount = 15

		elseif math.abs(diff) > 200 then
			particleCount  = 150
			sfxRepeatCount = 10

		elseif math.abs(diff) > 100 then
			particleCount  = 75
			sfxRepeatCount = 5
		end
	end

	-- If no diff then we're just updating the UI, so skip the lerp
	if diff == 0 then
		self.Txt_Coins_Value.Text = Util.FormatNumber(newCoinValue)
	end

	if diff > 0 then -- Player gained coins
		self:LerpCoinLabel(self.coins, newCoinValue)
		self:ParticleStream(particleCount)

		if diff > 1 then
			self.BE_TriggerSound:Fire(D_Sfx.UI_CoinBalance_Increase, {
				repeatCount    = sfxRepeatCount,
				repeatDelay    = 0.05,
				pitchIncrement = pitchIncrement,
				pitchOffset    = pitchOffset,
			})
		end
	end

	if diff < 0 then
		self:LerpCoinLabel(self.coins, newCoinValue)
		self:ParticleStream(particleCount, true)

		self.BE_TriggerSound:Fire(D_Sfx.UI_CoinBalance_Decrease, {
			repeatCount    = sfxRepeatCount,
			repeatDelay    = 0.05,
			pitchIncrement = -0.05,
			pitchOffset    = pitchOffset,
		})
	end

	-- store the new value for future comparison
	self.coins = newCoinValue
	print("Coins:UpdateCoins(): newCoinValue, currCoins, diff:", self.coins, " ->", newCoinValue, "=", diff)
end



function Coins:LerpCoinLabel(from: number, to: number, steps: number, duration: number)
	if not steps then steps = 10 end
	if not to then to = from end
	if not duration then duration = 1 end

	local diff = to - from

	print("Coins:LerpCoinLabel: from, to, diff, steps, duration:", from, to, diff, steps, duration)


	-- Use Runservice to update the text value
	local elapsedTime = 0
	local runConnect
	runConnect = RunService.RenderStepped:Connect(function(dt)
		elapsedTime += dt
		if elapsedTime > duration then
			self.Txt_Coins_Value.Text = Util.FormatNumber(to)
			runConnect:Disconnect()
			return
		end

		local progress = elapsedTime / duration
		local value    = from + math.floor(progress * diff)

		self.Txt_Coins_Value.Text = Util.FormatNumber(value)
	end)
end


function Coins:ParticleStream(amount: number, reverse: boolean)

	amount = amount or 100
	-- Trigger some coin bursts
	-- Default start pos is middle of the screen, end pos is the coin icon in the Coins frame
	local startPos = Vector2.new(self.Frame_Particles.AbsoluteSize.X / 2,self.Frame_Particles.AbsoluteSize.Y / 2)
	local endPos   = Vector2.new(
		self.Frame_CoinCount.AbsolutePosition.X - self.Frame_Particles.AbsolutePosition.X + (self.Frame_Particles.AbsoluteSize.X / 2),
		self.Frame_CoinCount.AbsolutePosition.Y - self.Frame_Particles.AbsolutePosition.Y + (self.Frame_Particles.AbsoluteSize.Y / 2)
	)
	if amount < 0 or reverse then
		startPos, endPos = endPos, startPos
		amount = math.abs(amount)
	end

	amount = amount / #self.Particles
	local duration = amount / 25

	for _, imgLabel in ipairs(self.Particles) do
		AnimParticles.DoParticleStream(self.Frame_Particles, imgLabel, amount, startPos, endPos, duration, 1)
	end
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Coins
