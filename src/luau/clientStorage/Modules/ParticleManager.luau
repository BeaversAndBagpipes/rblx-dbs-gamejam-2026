--!strict

-- Services
local Players                     = game:GetService("Players")
local ReplicatedStorage           = game:GetService("ReplicatedStorage")

-- Types
local T_Particles                 = require(ReplicatedStorage.Shared.Types.Particles)
local T_ParticleManager           = require(ReplicatedStorage.ClientStorage.Types.ParticleManager)


-- Modules
local Anim                        = require(ReplicatedStorage.Shared.Lib["Anim.Particles"])

-- Local vars
local LocalPlayer                 = Players.LocalPlayer :: Player
local PlayerGui                   = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local Gui                         = PlayerGui:WaitForChild("GUI"):WaitForChild("Particles") :: ScreenGui




-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

--[[
	ParticleManager

	This is a service for triggering particle on/from GUI Instances

	Include this as a singleton, and use it like so:

		local _ParticleManager = require(script.Parent.Parent.ParticleManager)
		_ParticleManager:Burst(guiObject)
		_ParticleManager:OutlineBurstCircle(guiObject, { repeatCount: 3 })

]]
local ParticleManager = {}



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function ParticleManager:Init()
	-- Get refs to UI Instances for Particles
	self.Frame_Particles = Gui:WaitForChild("Particles")
	self.Particles       = {
		CB                  = self.Frame_Particles:FindFirstChild("Particle_CB")        :: ImageLabel,
		CoinGold            = self.Frame_Particles:FindFirstChild("Particle_Coin_Gold") :: ImageLabel,
		CoinStar            = self.Frame_Particles:FindFirstChild("Particle_Coin_Star") :: ImageLabel,
		FXGlow              = self.Frame_Particles:FindFirstChild("Particle_FX_Glow")   :: ImageLabel,
		Spark               = self.Frame_Particles:FindFirstChild("Particle_FX_Spark")  :: ImageLabel,
		FXStar1             = self.Frame_Particles:FindFirstChild("Particle_FX_Star1")  :: ImageLabel,
		FXStar2             = self.Frame_Particles:FindFirstChild("Particle_FX_Star2")  :: ImageLabel,
		Star                = self.Frame_Particles:FindFirstChild("Particle_Star")      :: ImageLabel
	}

	-- Hide them all
	for _, p in pairs(self.Particles) do
		p.Visible = false
	end

	Gui.Enabled = true
end



-- ██████╗ ██╗   ██╗██████╗ ███████╗████████╗
-- ██╔══██╗██║   ██║██╔══██╗██╔════╝╚══██╔══╝
-- ██████╔╝██║   ██║██████╔╝███████╗   ██║
-- ██╔══██╗██║   ██║██╔══██╗╚════██║   ██║
-- ██████╔╝╚██████╔╝██║  ██║███████║   ██║
-- ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝
--

function ParticleManager:Burst(guiObject: GuiObject, props: T_Particles.Burst)

	if not guiObject then
		warn("ParticleManager:OutlineBurst(): invalid guiObject")
		return
	end
	props = props or {}

	-- Ensure osme default values
	local count          = props.count        or 192
	local maxAge         = props.maxAge       or 5
	local repeatCount    = props.repeatCount  or 1
	local emitDuration   = props.emitDuration or 0.5
	local interval       = props.interval     or 1
	local velocity       = props.velocity     or 640
	local particles      = props.particles or {
		self.Particles.Spark,
		self.Particles.Star,
		self.Particles.FXStar1,
		self.Particles.FXStar2,
		self.Particles.FXGlow,
	}
	local spawnPos       = props.spawnPos or function()
		return guiObject.AbsolutePosition + (guiObject.AbsoluteSize * 0.5)
	end

	-- Spawn the particles
	task.spawn(function()
		for i=1, repeatCount do
			Anim.DoParticleBurst(
				self.Frame_Particles,
				particles,
				count,
				emitDuration,
				velocity,
				maxAge,
				spawnPos)
			task.wait(interval)
		end
	end)
end



--  ██████╗ ██╗   ██╗████████╗██╗     ██╗███╗   ██╗███████╗
-- ██╔═══██╗██║   ██║╚══██╔══╝██║     ██║████╗  ██║██╔════╝
-- ██║   ██║██║   ██║   ██║   ██║     ██║██╔██╗ ██║█████╗
-- ██║   ██║██║   ██║   ██║   ██║     ██║██║╚██╗██║██╔══╝
-- ╚██████╔╝╚██████╔╝   ██║   ███████╗██║██║ ╚████║███████╗
--  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
--

function ParticleManager:OutlineBurst(guiObject: GuiObject, props: T_Particles.Burst)

	if not guiObject then
		warn("ParticleManager:OutlineBurst(): invalid guiObject")
		return
	end

	props = props or {}
	props.count        = props.count         or  128
	props.maxAge       = props.maxAge        or  2
	props.repeatCount  = props.repeatCount   or  1
	props.emitDuration = props.emitDuration  or  5
	props.interval     = props.interval      or  1
	props.velocity     = props.velocity      or  10
	props.particles    = props.particles     or  {
		self.Particles.Spark,
		self.Particles.Star,
		self.Particles.FXStar1,
		self.Particles.FXStar2,
		self.Particles.FXGlow,
	}
	props.spawnPos = props.spawnPos or function()
		return self:GetPointOnBorder(guiObject)
	end

	self:Burst(guiObject, props)
end

	function ParticleManager:CBBurst(guiObject)
		-- Special CB Burst, only needs a parent object
		self:OutlineBurst(guiObject, {
			emitDuration = 0.2,
			number       = 64,
			velocity     = 1000,
			particles    = {
				self.Particles.Spark,
				--self.Particles.Star,
				--self.Particles.FXStar1,
				--self.Particles.FXStar2,
				--self.Particles.FXGlow,
				self.Particles.CB
			}
		})
	end



--  ██████╗ ██╗   ██╗████████╗██╗     ██╗███╗   ██╗███████╗    ██████╗██╗██████╗  ██████╗██╗     ███████╗
-- ██╔═══██╗██║   ██║╚══██╔══╝██║     ██║████╗  ██║██╔════╝   ██╔════╝██║██╔══██╗██╔════╝██║     ██╔════╝
-- ██║   ██║██║   ██║   ██║   ██║     ██║██╔██╗ ██║█████╗     ██║     ██║██████╔╝██║     ██║     █████╗
-- ██║   ██║██║   ██║   ██║   ██║     ██║██║╚██╗██║██╔══╝     ██║     ██║██╔══██╗██║     ██║     ██╔══╝
-- ╚██████╔╝╚██████╔╝   ██║   ███████╗██║██║ ╚████║███████╗   ╚██████╗██║██║  ██║╚██████╗███████╗███████╗
--  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝    ╚═════╝╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚══════╝
--

function ParticleManager:OutlineBurstCircle(guiObject: GuiObject, props: T_Particles.Burst)

	if not guiObject then
		warn("ParticleManager:OutlineBurst(): invalid guiObject")
		return
	end

	props = props or {}
	props.count        = props.count         or  64
	props.maxAge       = props.maxAge        or  0.75
	props.repeatCount  = props.repeatCount   or  nil
	props.emitDuration = props.emitDuration  or  nil
	props.interval     = props.interval      or  nil
	props.velocity     = props.velocity      or  2

	props.particles    = props.particles or {
		self.Particles.Spark,
		self.Particles.FXGlow,
	}
	props.spawnPos = props.spawnPos or function()
		return self:GetPointOnCircle(guiObject)
	end

	self:Burst(guiObject, props)
end



-- ██╗   ██╗████████╗██╗██╗
-- ██║   ██║╚══██╔══╝██║██║
-- ██║   ██║   ██║   ██║██║
-- ██║   ██║   ██║   ██║██║
-- ╚██████╔╝   ██║   ██║███████╗
--  ╚═════╝    ╚═╝   ╚═╝╚══════╝
--

function ParticleManager:GetPointOnBorder(guiObject: GuiObject): Vector2
	local size   = guiObject.AbsoluteSize
	local offset = guiObject.AbsolutePosition


	local random = 5
	local edges = {
		{{0, size.X}, {-random, random}}, -- Top
		{{0, size.X}, {size.Y-random, size.Y+random}}, -- Bottom
		{{-random, random}, {0, size.Y}}, -- Left
		{{size.X-random, size.X+random}, {0, size.Y}}, -- Right
	}
	local randomEdge = edges[math.random(#edges)]

	local point = Vector2.new(
		offset.X + math.random(randomEdge[1][1], randomEdge[1][2]),
		offset.Y + math.random(randomEdge[2][1], randomEdge[2][2])
	)

	return point
end

function ParticleManager:GetPointOnCircle(guiObject: GuiObject): Vector2
	local random = 3
	local size   = guiObject.AbsoluteSize
	local center = guiObject.AbsolutePosition + (size / 2)
	local radius = size.Magnitude / 2 + (math.random(random * 2) - random)
	local angle  = math.rad(math.random(0, 360))
	local pos    = center + Vector2.new(math.cos(angle) * radius, math.sin(angle) * radius)
	return pos
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return ParticleManager :: T_ParticleManager.ParticleManager
