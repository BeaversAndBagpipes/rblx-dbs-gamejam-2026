--!strict

-- Services
--local BadgeService      = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage
local RunService        = game:GetService("RunService") :: RunService
local TweenService      = game:GetService("TweenService") :: TweenService

-- Modules
--local Settings        = require(ReplicatedStorage.Shared.Settings)
local Util              = require(ReplicatedStorage.Shared.Lib.Util)
local ParticleEmitter   = require(ReplicatedStorage.Shared.Lib.ParticleEmitter)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)



-- ████████╗██╗   ██╗██████╗ ███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
--    ██║      ██║   ██║     ███████╗
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝
--

export type T_Anim_Particles = {
	DoParticleBlast: (
		GuiObject,
		GuiObject,
		number,
		number,
		Vector2,
		number
	) -> nil,
	DoParticleBurst: (
		GuiObject,
		{ GuiObject },
		number,
		number,
		number,
		number,
		(() -> Vector2)?
	) -> nil,
	DoParticleStream: (
		GuiObject,
		GuiObject,
		number,
		Vector2,
		Vector2,
		number,
		number
	) -> nil
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Anim = {} :: T_Anim_Particles



-- ██████╗ ██╗      █████╗ ███████╗████████╗
-- ██╔══██╗██║     ██╔══██╗██╔════╝╚══██╔══╝
-- ██████╔╝██║     ███████║███████╗   ██║
-- ██╔══██╗██║     ██╔══██║╚════██║   ██║
-- ██████╔╝███████╗██║  ██║███████║   ██║
-- ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝
--
-- BLAST = BLAST upwards (blast-off?), and fall down, like fireworks

function Anim.DoParticleBlast(
	parent         : GuiObject,
	particle       : GuiObject,
	number         : number,
	duration       : number,
	initialVelocity: Vector2,
	maxAge         : number
)
	-- Trigger some explosive particle effects
	local particleEmitter = ParticleEmitter.new(parent, particle)
	particleEmitter.rate  = number / duration

	local origSize    = particle.Size
	local elapsedTime = 0

	-- Handle emit duration
	local elapsedTime = 0
	local runConnect
	runConnect = RunService.RenderStepped:Connect(function(deltaTime)
		-- elapsedTime
		elapsedTime += deltaTime
		if elapsedTime > duration then
			particleEmitter.rate = 0
			runConnect:Disconnect()
		end
	end)

	initialVelocity = initialVelocity or Vector2.new(256, 500)

	particleEmitter.onSpawn = function(particle)
		particle.velocity        = Vector2.new(math.random(-initialVelocity.X, initialVelocity.X), initialVelocity.Y)
		particle.maxAge          = maxAge or 2
		particle.element.Visible = true
		particle.element.ZIndex  = 999
	end

	particleEmitter.onUpdate = function(particle, deltaTime)
		-- Change velocity and update position
		particle.velocity = particle.velocity - Vector2.new(0, 20);
		particle.position = particle.position - (particle.velocity * deltaTime);

		-- Shrink
		local progress = particle.age / particle.maxAge
		local scale    = 1 - progress
		particle.element.Size  = UDim2.fromOffset(origSize.X.Offset * scale, origSize.Y.Offset * scale)

	end

end



-- ██████╗ ██╗   ██╗██████╗ ███████╗████████╗
-- ██╔══██╗██║   ██║██╔══██╗██╔════╝╚══██╔══╝
-- ██████╔╝██║   ██║██████╔╝███████╗   ██║
-- ██╔══██╗██║   ██║██╔══██╗╚════██║   ██║
-- ██████╔╝╚██████╔╝██║  ██║███████║   ██║
-- ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝
--
-- BURST - All Directions - Emit in all directions, like a cloud

function Anim.DoParticleBurst(
	parent         : GuiObject,
	particles      : { GuiObject },
	number         : number,
	duration       : number,
	initialVelocity: number,
	maxAge         : number,
	spawnPos       : (() -> Vector2)?
)
	number          = number          or 50
	duration        = duration        or 1
	maxAge          = maxAge          or 3
	spawnPos        = spawnPos        or function() return Vector2.new(0,0) end
	initialVelocity = initialVelocity or 256

	print("Anim.DoParticleBurst: ", number, duration, "p/s: ", (number / duration))

	-- Create the required number of emitters
	local particleEmitters = {}
	local particleSizes    = {}

	for _, particle in ipairs(particles) do
		local emitter = ParticleEmitter.new(parent, particle)
		emitter.rate  = number / duration / #particles

		table.insert(particleEmitters, emitter)
		table.insert(particleSizes, particle.Size)
	end

	-- Handle emit duration
	local elapsedTime = 0
	local runConnect
	runConnect = RunService.RenderStepped:Connect(function(deltaTime)
		-- elapsedTime
		elapsedTime += deltaTime
		if elapsedTime > duration then
			for _,particleEmitter in ipairs(particleEmitters) do
				particleEmitter.rate = 0
			end
			runConnect:Disconnect()
		end
	end)

	for index,particleEmitter in ipairs(particleEmitters) do
		local origSize = particleSizes[index]

		particleEmitter.onSpawn = function(particle)
			particle.position        = spawnPos()

			local angle              = math.random() * 2 * math.pi
			particle.velocity        = Vector2.new(math.cos(angle), math.sin(angle)) * initialVelocity
			particle.maxAge          = maxAge

			particle.element.Size    = UDim2.new()
			particle.element.Visible = true
			particle.element.ZIndex  = 999
		end

		particleEmitter.onUpdate = function(particle, deltaTime)
			local progress = particle.age / particle.maxAge
			local lerpProgress = TweenService:GetValue(progress, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

			local scale    = math.abs(progress * 2 - 1) + 0.1 -- 1.1 => 0.1 => 1.1
				scale    = math.min(scale, 1)               -- 1   => 0.1 => 1
			local negScale = 1.1 - scale                      -- 0.1 => 1   => 0.1

			-- Change velocity and update position
			particle.velocity = particle.velocity * (1 - ((scale) * 0.1))
			--particle.velocity = rotateVector2(particle.velocity, 2)
			particle.position = particle.position - (particle.velocity * deltaTime)

			-- Shrink
			local size = 1 - math.abs(lerpProgress * 2 - 1)
			particle.element.Size  = UDim2.fromOffset(origSize.X.Offset * size, origSize.Y.Offset * size)
		end
	end

end



-- ███████╗████████╗██████╗ ███████╗ █████╗ ███╗   ███╗
-- ██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔══██╗████╗ ████║
-- ███████╗   ██║   ██████╔╝█████╗  ███████║██╔████╔██║
-- ╚════██║   ██║   ██╔══██╗██╔══╝  ██╔══██║██║╚██╔╝██║
-- ███████║   ██║   ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║
-- ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
--

function Anim.DoParticleStream(
	parent      : GuiObject,
	particle    : GuiObject,
	number      : number,
	startPos    : Vector2,
	endPos      : Vector2,
	emitDuration: number,
	moveDuration: number
)
	number       = number or 100
	emitDuration = emitDuration or 1
	moveDuration = moveDuration or 1

	local particleEmitter = ParticleEmitter.new(parent, particle)
	particleEmitter.rate  = number / emitDuration

	local origSize    = particle.AbsoluteSize

	-- Handle emit duration
	local elapsedTime = 0
	local runConnect
	runConnect = RunService.RenderStepped:Connect(function(deltaTime)
		elapsedTime += deltaTime
		if elapsedTime > emitDuration then
			particleEmitter.rate = 0
			runConnect:Disconnect()
		end
	end)

	-- particle spawning
	-- every particle has a random easing style, direction, and strength
	particleEmitter.onSpawn = function(particle)
		particle.maxAge          = moveDuration
		particle.easingStyle     = Anim.GetRandomEasingStyle()
		particle.easingDirection = Anim.GetRandomEasingDirection()
		particle.easingStrength  = math.random()
		particle.element.Size    = UDim2.fromOffset(0, 0)
		particle.element.Visible = true
	end

	-- particle movement
	particleEmitter.onUpdate = function(particle, deltaTime)
		-- progress, for tweening
		local progress      = particle.age / particle.maxAge
		local progressEased = TweenService:GetValue(progress, particle.easingStyle, particle.easingDirection)

		-- get lerped position
		local posXLinear    = Util.Lerp(startPos.X, endPos.X, progress)
		local posXEased     = Util.Lerp(startPos.X, endPos.X, progressEased)

		local posYLinear    = Util.Lerp(startPos.Y, endPos.Y, progress)
		local posYEased     = Util.Lerp(startPos.Y, endPos.Y, progressEased)

		-- update position
		local position = Vector2.new(
			Util.MixValues(posXLinear, posXEased, particle.easingStrength),
			Util.MixValues(posYLinear, posYEased, 1 - particle.easingStrength)
		)
		particle.position = position
		--print("particle:OnUpdate(): progress:", progress .. "/" .. progressEased, " x/y:", posX, posY, position)

		-- handle scale
		local scale = Util.TriangleWave(progress) -- 0 -> 1 -> 0
		particle.element.Size  = UDim2.fromOffset(origSize.X * scale, origSize.Y * scale)
	end


end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Anim :: T_Anim_Particles
