--[[
	       	                                       ,,          ,,                  
	          `7MM"""Mq.                    mm     db        `7MM                  
	            MM   `MM.                   MM                 MM                  
	MM    MM    MM   ,M9 ,6"Yb.  `7Mb,od8 mmMMmm `7MM  ,p6"bo  MM  .gP"Ya  ,pP"Ybd 
	MM    MM    MMmmdM9 8)   MM    MM' "'   MM     MM 6M'  OO  MM ,M'   Yb 8I   `" 
	MM    MM    MM       ,pm9MM    MM       MM     MM 8M       MM 8M"""""" `YMMMa. 
	MM    MM    MM      8M   MM    MM       MM     MM YM.    , MM YM.    , L.   I8 
	MVbgd"'Ybo.JMML.    `Moo9^Yo..JMML.     `Mbmo.JMML.YMbmd'.JMML.`Mbmmd' M9mmmP' 
	M.                                                                             
	M8           
								 |_      |\/| _ -+-|_ 							 
								 [_)\_|  |  |(_| | | |
								     _|               
______________________________________________________________________________________
																					  
  Version: 0.3 Release
  License: CC0-1.0
  Github: https://github.com/Matthhhh/MuParticles
  
]]--

export type IProperty = {
	Color 		      	: ColorSequence	 ; 
	Orientation       	: number		 ; 
	Scale 		      	: NumberSequence ;
	Texture 	      	: string		 ; 
	Transparency      	: NumberSequence ; 
	Direction 	      	: Vector2		 ; 
	Enabled 	      	: boolean		 ;
	Lifetime 	      	: NumberRange	 ; 
	Rate 		      	: number		 ;
	Rotation 	      	: NumberRange	 ; 
	RotSpeed 	      	: NumberSequence ; 
	Speed 		      	: NumberRange	 ; 
	Spread 		      	: number		 ; 
	FlipbookLayout    	: Vector2		 ;
	FlipbookMode   	  	: number		 ; 
	FlipbookFramerate 	: number		 ;
	FlipbookStartRandom : boolean		 ;
	MaxParticles        : number         ;
	Acceleration        : Vector2		 ; 
	Drag                : number		 ; 
	TimeScale 			: number		 ;
	AspectRatio         : number         ;
	IsPoint             : boolean        ;
	ResampleMode        : Enum           ;
	Resolution          : Vector2        ;
	Size                : UDim2          ;
}

export type IParticle = {
	Position : UDim2,
	Velocity : UDim2,
	Acceleration : UDim2,
	Drag : number,
	Orientation : number,
	Rotation : number,
	Object : ImageLabel,
	IFlipbook : {any},
	ISequences : {any},
	IConstraints : {UIConstraint},
	Lifetime : number,
	Time : number,
	Alpha : number
}

local Template : ImageLabel = Instance.new('ImageLabel')
Template.AnchorPoint = Vector2.one / 2
Template.Transparency = 1
Instance.new('UIAspectRatioConstraint', Template)
Instance.new('UIScale', Template)
local RunService = game:GetService('RunService')
local __Random = Random.new()

--[[ Section : Settings ]]--
local MAX_PARTICLES = -1 -- ∞
local FRAMERATE = 30
local VECTOR2_TO_UDIM2_FACTOR = 20
local TAU = 2 * math.pi
local FOLDER_NAME = "μParticles"
local DEFAULT : IProperty = {
	Color		 	    = ColorSequence.new(Color3.new(1, 1, 1)) ;
	Orientation 	    = 0										 ;
	Scale 			    = NumberSequence.new(1) 				 ;
	Texture 		    = 'rbxasset://textures/sparkle.png'		 ;
	Transparency 	    = NumberSequence.new(0)					 ;
	Direction 		    = Vector2.yAxis							 ;
	Enabled 		    = false									 ;
	Lifetime 		    = NumberRange.new(1)					 ;
	Rate		        = 5										 ;
	Rotation 		    = 0										 ;
	RotSpeed 		    = NumberSequence.new(0)					 ;
	Speed 			    = NumberRange.new(5)					 ;
	Spread			    = 0										 ;
	FlipbookLayout 	    = Vector2.one							 ;
	FlipbookMode 	    = 0										 ;
	FlipbookFramerate   = 5										 ;
	FlipbookStartRandom = false									 ;
	MaxParticles        = -1                                     ;
	Acceleration 		= Vector2.zero							 ;
	Drag 				= 0										 ;
	TimeScale 			= 1										 ;
	AspectRatio         = 1         						 	 ;
	IsPoint             = false       						 	 ;
	ResampleMode        = Enum.ResamplerMode.Default      		 ;
	Resolution          = Vector2.new(1024, 1024)                ;
	Size                = UDim2.new(.1, 0, .1, 0)         		 ;
}

--[[ Section : Constants ]]--
local function CAST_NUMBER_SEQUENCE(x : any?) : NumberSequence?
	if (typeof(x) == 'NumberSequence') then
		return x
	end
	if (typeof(x) == 'number') then
		return NumberSequence.new(x)
	end
	if (typeof(x) == 'NumberRange') then
		local k = (x.Min + x.Max) / 2
		local w = NumberSequence.new({
			NumberSequenceKeypoint.new(0, k),
			NumberSequenceKeypoint.new(1, k)
		})
		return w
	end
end

local function CAST_NUMBER_RANGE(x : any?) : NumberRange?
	if (typeof(x) == 'NumberRange') then
		return x
	end
	if (typeof(x) == 'number') then
		return NumberRange.new(x)
	end
	if (typeof(x) == 'NumberSequence') then
		return NumberRange.new(x.Keypoints[1].Value, x.Keypoints[#x.Keypoints].Value)
	end
end

local function CAST_VECTOR2(x : any?) : Vector2?
	if (typeof(x) == 'Vector2') then
		return x
	end
	if (typeof(x) == 'Vector3') then
		return Vector2.new(x.X, x.Y)
	end
	if (typeof(x) == 'number') then
		return Vector2.new(x, x)
	end
end

local function CAST_COLOR_SEQUENCE(x : any?) : ColorSequence?
	if (typeof(x) == 'ColorSequence') then
		return x
	end
	if (typeof(x) == 'Color3') then
		return ColorSequence.new(x)
	end
	if (typeof(x) == 'BrickColor') then 
		return ColorSequence.new(x.Color)
	end 
	if (typeof(x) == 'number') then 
		return ColorSequence.new(Color3.new(x, x, x))
	end 
end

local function CAST_ORIENTATION(x : any?) : number
	if (x == Enum.ParticleOrientation.VelocityParallel) then
		return 1
	end
	if (typeof(x) == 'number') then
		return x
	end
	return 0
end

local function CAST_DIRECTION(x : any?) : Vector2?
	if (typeof(x) == 'EnumItem') then
		return CAST_VECTOR2(Vector3.fromNormalId(x))
	end
	if (typeof(x) == 'Vector2') then
		return x
	end
end

local function CAST_RESAMPLE_MODE(x : any?): Enum
	if (typeof(x) == 'EnumItem') then
		return x
	end
	if (x == 1) then
		return Enum.ResamplerMode.Pixelated
	end
	return Enum.ResamplerMode.Default
end

local function CAST_UDIM2(x : any?): UDim2?
	if (typeof(x) == 'UDim2') then
		return x
	end
	if (typeof(x) == 'Vector2') then
		return UDim2.fromOffset(VECTOR2_TO_UDIM2_FACTOR * x.X, -VECTOR2_TO_UDIM2_FACTOR * x.Y)
	end
	if (typeof(x) == 'number') then
		return UDim2.fromOffset(x, x)
	end
end

local function GET_ENVELOPE_TABLE(s : NumberSequence) : NumberSequence
	local k = {}
	for i, x in pairs(s.Keypoints) do
		k[i] = NumberSequenceKeypoint.new(x.Time, x.Value + x.Envelope * (2 * __Random:NextNumber() - 1), 0) 
	end
	return NumberSequence.new(k)
end

local function EVAL_NUMBER_RANGE(x : NumberRange) : number
	return x.Min + (x.Max - x.Min) * __Random:NextNumber()
end

local function EVAL_NUMBER_SEQUENCE(x : NumberSequence, t : number) : number
	-- Source : https://create.roblox.com/docs/reference/engine/datatypes/NumberSequence
	if (t == 0) then
		return x.Keypoints[1].Value
	end
	if (t == 1) then
		return x.Keypoints[#x.Keypoints].Value
	end
	for i = 1, #x.Keypoints - 1 do
		local a = x.Keypoints[i]
		local b = x.Keypoints[i + 1]
		if (t >= a.Time and t < b.Time) then
			local k = (t - a.Time) / (b.Time - a.Time)
			return (b.Value - a.Value) * k + a.Value
		end
	end
end

local function EVAL_COLOR_SEQUENCE(x : ColorSequence, t : number) : Color3
	-- Source : https://create.roblox.com/docs/reference/engine/datatypes/ColorSequence
	if (t == 0) then
		return x.Keypoints[1].Value
	end
	if (t == 1) then
		return x.Keypoints[#x.Keypoints].Value
	end
	for i = 1, #x.Keypoints - 1 do
		local a = x.Keypoints[i]
		local b = x.Keypoints[i + 1]
		if (t >= a.Time and t < b.Time) then
			local k = (t - a.Time) / (b.Time - a.Time)
			return Color3.new(
				(b.Value.R - a.Value.R) * k + a.Value.R,
				(b.Value.G - a.Value.G) * k + a.Value.G,
				(b.Value.B - a.Value.B) * k + a.Value.B
			)
		end
	end
end

local function FIX_ANGLE(x : number)
	return x - TAU * math.floor(x / TAU)
end

local function GET_UI() : ScreenGui
	local Player = game.Players.LocalPlayer
	local Folder = Player.PlayerGui:FindFirstChild(FOLDER_NAME)
	if (not Folder) then
		Folder = Instance.new('ScreenGui')
		Folder.Name = FOLDER_NAME
		Folder.ResetOnSpawn = false
		Folder.Parent = Player.PlayerGui
	end
	return Folder
end

local function MULTIPLY_UDIM2(a : UDim2, n : number) : UDim2
	return UDim2.fromOffset(a.X.Offset * n, a.Y.Offset * n)
end

local function ROTATE_UNIT_VECTOR(v : Vector2, t) : Vector2
	local a : number = math.atan2(
		v.Y, v.X
	)
	return Vector2.new(math.cos(a + t), math.sin(a + t))
end

local function PLACE_INSIDE(a : GuiLabel, x, y) : UDim2
	local p, s = a.AbsolutePosition, a.AbsoluteSize
	local m = p + .5 * s
	local o = p + Vector2.new(x, y) * s - m
	local R = math.sqrt((o.X)^2 + (o.Y)^2)
	local Theta, Phi = math.atan2(o.Y, o.X), math.rad(a.Rotation)
	local V = Vector2.new(R * math.cos(Theta + Phi), R * math.sin(Theta + Phi)) + m
	return UDim2.fromOffset(V.X, V.Y)
end

--[[ Section : Main ]]--
local Emitter = {}
Emitter.__index = Emitter

--[[
	.new(|Properties|, |Parent|) is the constructor function of |Emitter|.
	This function creates a new emitter and returns it.
]]--
function Emitter.new(Properties : IProperty, Parent : GuiBase)
	assert(typeof(Parent) == 'Instance' and Parent:IsA('GuiBase'), 'μParticle : Type '..typeof(Parent)..' is invalid for the parent of an emitter.')
	local self = {}
	setmetatable(self, Emitter)
	
	self.Properties = setmetatable(Properties, {__index = DEFAULT}) :: IProperty
	self.Particles = {} :: {IParticle?}
	self.Parent = Parent
	
	self.Connections = {
		RunService.Heartbeat:Connect(function(DT)
			local Destroy = {}
			local Fix = 0
			for I, Particle : IParticle in pairs(self.Particles) do
				if (not self:Update(Particle, DT)) then
					table.insert(Destroy, {I, Particle})
				end
			end
			for _, Info in pairs(Destroy) do
				local I = Info[1] - Fix
				table.remove(self.Particles, I)
				Info[2].Object:Destroy()
				if (I <= #self.Particles) then
					Fix += 1
				end
			end
		end)
	}
	
	self:Sync()
	return self
end

--[[
	.inherit() is a function used mainly to create custom particles.
	It will create a new table that is linked to the main |Emitter|.
]]--
function Emitter.inherit()
	local self = {}
	setmetatable(self, Emitter)
	return self
end

--[[
	.from(|Object|) is a secondary constructor function of |Emitter|.
	This function creates a new emitter from an existing object and returns it.
]]--
function Emitter.from(Object : ParticleEmitter?)
	local U, V = nil, nil
	local P = false
	if (typeof(Object) == 'Instance') then
		local Attr = Object:GetAttributes()
		if (Object:IsA('ParticleEmitter')) then
			P = true
			U, V = Object, Attr
		else
			U, V = Attr, Attr
		end
	else
		if (typeof(Object) == 'table') then
			U, V = Object, Object
		else
			return
		end
	end
	
	local Properties : IProperty = {
		Color = CAST_COLOR_SEQUENCE(U.Color),
		Orientation = CAST_ORIENTATION(U.Orientation),
		Scale = CAST_NUMBER_SEQUENCE(P and U.Size or U.Scale),
		Texture = U.Texture,
		Transparency = CAST_NUMBER_SEQUENCE(U.Transparency),
		Direction = CAST_DIRECTION(P and U.EmissionDirection or U.Direction),
		Enabled = U.Enabled,
		Lifetime = CAST_NUMBER_RANGE(U.Lifetime),
		Rate = U.Rate,
		Rotation = CAST_NUMBER_RANGE(U.Rotation),
		RotSpeed = CAST_NUMBER_SEQUENCE(U.RotSpeed),
		Speed = CAST_NUMBER_RANGE(U.Speed),
		Spread = CAST_VECTOR2(P and U.SpreadAngle or U.Spread).X,
		FlipbookLayout = CAST_VECTOR2(V.FlipbookLayout),
		FlipbookMode = V.FlipbookMode,
		FlipbookFramerate = V.FlipbookFramerate,
		FlipbookStartRandom = V.FlipbookStartRandom,
		MaxParticles = V.MaxParticles,
		Acceleration = CAST_VECTOR2(U.Acceleration),
		Drag = U.Drag,
		TimeScale = U.TimeScale,
		AspectRatio = V.AspectRatio,
		IsPoint = V.IsPoint,
		ResampleMode = CAST_RESAMPLE_MODE(V.ResampleMode),
		Resolution = CAST_VECTOR2(V.Resolution),
		Size = CAST_UDIM2(V.Size)
	}
	
	return Emitter.new(Properties, U.Parent :: GuiBase)
end

--[[
	:Set(|Property|, |Value|) is a replacement for .Properties[|Property|] = |Value|.
	This should be used to set a property to the given value.
]]--
function Emitter:Set(x : string | {any}, y : any?) : nil
	if (typeof(x) == 'table') then
		for __x, __y in pairs(x) do
			self:Set(__x, __y)
		end
		return
	end
	if (y == nil or x == nil) then
		return
	end
	self.Properties[x] = y
	self:OnSet(x, y)
end

--[[
	:Enable(|E|) is a shortcut for :Set('Enabled', |E|).
	Use this to enable or disable the emitter.
]]--
function Emitter:Enable(E : boolean)
	self:Set('Enabled', E or true)
end

--[[
	:Disable() is a shortcut for :Enable(false).
	Use this to disable the emitter.
]]--
function Emitter:Disable()
	self:Set('Enabled', false)
end

--[[
	:Clear() is a emitter method.
	This function clears all particles from the emitter.
]]--
function Emitter:Clear()
	for _, Particle in pairs(self.Particles) do
		Particle.Object:Destroy()
	end
	self.Particles = {}
end

--[[
	:OnSet(|Property|) is called after a property is set using :Set(|Property|, ...).
	This function can be overriden after creating a new Emitter to create custom behaviour.
]]--
function Emitter:OnSet(x : string) : nil
	local y : any? = self.Properties[x]
	if (x == 'Enabled') then
		if (self.Connections[2]) then
			self.Connections[2]:Disconnect()
		end
		if (y) then
			local Alpha, Beta = 0, 0
			self.Connections[2] = RunService.Heartbeat:Connect(function(dt)
				local Rate = self.Properties.Rate
				Alpha += dt
				local K = math.floor(Alpha * Rate)
				Alpha -= K / Rate
				if (Beta + K >= Rate) then
					K -= Beta + K - Rate
					Beta = -K
				end
				if (K > 0) then
					self:Emit(K)
				end
				Beta += K
			end)
		end
	end
	return
end

--[[
	:Sync() will update all properties of the Emitter.
	This is used after the .new() call.
]]--
function Emitter:Sync()
	for x, _ in pairs(DEFAULT) do
		self:OnSet(x)
	end
end

--[[
	:Update(|Particle|, |DT|) is called every heartbeat to update the given particle.
	This function can be overriden after creating a new Emitter to create custom behaviour.
]]--
function Emitter:Update(Particle : IParticle, DT) : nil
	local P = self.Properties
	DT *= P.TimeScale
	Particle.Time += DT
	Particle.Rotation += EVAL_NUMBER_SEQUENCE(Particle.ISequences.Rotation, Particle.Alpha)
	Particle.Velocity = MULTIPLY_UDIM2(Particle.Velocity + MULTIPLY_UDIM2(Particle.Acceleration, DT), Particle.Drag)
	Particle.Position += MULTIPLY_UDIM2(Particle.Velocity, DT)
	-- Flipbook Start
	if (Particle.IFlipbook.Enabled) then
		local A, B = Particle.IFlipbook.Alpha, Particle.IFlipbook.Beta
		local Rate = Particle.IFlipbook.Rate
		A += DT
		local K = math.floor(A * Rate)
		A -= K / Rate
		if (B + K >= Rate) then
			K -= B + K - Rate
			B = -K
		end
		for i = 1, K do
			-- Flip
			local Mode = Particle.IFlipbook.Mode
			if (Mode == 1 or Mode == 2) then
				self:Flip(Particle, false)
			end		
			if (Mode == 3) then
				local Revert = Particle.IFlipbook.Revert
				local Off = self:Flip(Particle, Revert)
				if (Particle.IFlipbook.Skip) then
					Particle.IFlipbook.Skip = false
				else
					if (Revert and Off == Vector2.zero) then
						Particle.IFlipbook.Revert = false
						Particle.IFlipbook.Skip = true
						self:Flip(Particle, false)
					end
					if (not Revert and Off == Particle.IFlipbook.Resolution - Particle.IFlipbook.Size) then
						Particle.IFlipbook.Revert = true
						Particle.IFlipbook.Skip = true
						self:Flip(Particle, true)
					end
				end
			end
			if (Mode == 4) then
				self:FlipToRandom(Particle)
			end
		end
		B += K
		Particle.IFlipbook.Alpha, Particle.IFlipbook.Beta = A, B
	end
	-- Flipbook End
	if (Particle.Time > Particle.Lifetime) then
		return false
	end
	Particle.Object.ImageColor3 = EVAL_COLOR_SEQUENCE(Particle.ISequences.Color, Particle.Alpha)
	Particle.IConstraints.Scale.Scale = EVAL_NUMBER_SEQUENCE(Particle.ISequences.Scale, Particle.Alpha)
	Particle.Object.ImageTransparency = EVAL_NUMBER_SEQUENCE(Particle.ISequences.Transparency, Particle.Alpha)
	if (Particle.Orientation == 1) then
		local Angle = FIX_ANGLE(math.atan2(Particle.Velocity.Y.Offset, Particle.Velocity.X.Offset))
		Particle.Object.Rotation =  math.deg(Angle) + Particle.Rotation
	else
		Particle.Object.Rotation = Particle.Rotation
	end
	Particle.Object.Rotation = Particle.Rotation
	Particle.Object.Position = Particle.Position
	Particle.Alpha = Particle.Time / Particle.Lifetime
	return true
end

--[[
	:Flip(|Particle|, |Back|, |N|) is called to flip the given particles's flipbook |N| times.
	If |Back| is true or non-null, flip backwards.
]]--
function Emitter:Flip(Particle : IParticle, Back : boolean, N)
	local K = Particle.Object.ImageRectOffset
	local Size = Particle.IFlipbook.Size
	local Res = Particle.IFlipbook.Resolution
	if (not Back) then
		for _ = 1, (N or 1) do
			if (K.X - Size.X < 0) then
				if (K.Y - Size.Y < 0) then
					K = Res - Size
				else
					K = Vector2.new(Res.X - Size.X, K.Y - Size.Y)
				end
			else
				K -= Vector2.xAxis * Size.X
			end
			Particle.Object.ImageRectOffset = K
		end
	else
		for _ = 1, (N or 1) do
			if (K.X + Size.X >= Res.X) then
				if (K.Y + Size.Y >= Res.Y) then
					K = Vector2.zero
				else
					K = Vector2.new(0, K.Y + Size.Y)
				end
			else
				K += Vector2.xAxis * Size.X
			end
			Particle.Object.ImageRectOffset = K
		end
	end
	return Particle.Object.ImageRectOffset
end

--[[
	:FlipToRandom(|Particle|) is called to flip the given particle's flipbook to a random frame.
	This function is a shortcut to :Flip(|Particle|, false, __Random:NextInteger(0, Cells)).
]]--
function Emitter:FlipToRandom(Particle : IParticle)
	local Cells = Particle.IFlipbook.Cells
	return self:Flip(Particle, false, __Random:NextInteger(0, Cells))
end

--[[
	:__Emit() is the main emitter function. It is used by :Emit(|N|) to emit multiple particles.
	Calling it will immediatly emit a single particle. This function can be overriden to create custom behaviour.
--]]
function Emitter:__Emit()
	local UI : ScreenGui = GET_UI()
	local P : IProperty = self.Properties
	if (#UI:GetChildren() >= MAX_PARTICLES and MAX_PARTICLES > -1) then
		return
	end
	if (#self.Particles >= P.MaxParticles and P.MaxParticles > -1) then
		return
	end
	local Particle : IParticle = {}
	local Image = Template:Clone()
	Image.Image = P.Texture
	if (P.AspectRatio <= 0) then
		Image:FindFirstChildOfClass('UIAspectRatioConstraint'):Destroy()
	else
		Image:FindFirstChildOfClass('UIAspectRatioConstraint').AspectRatio = P.AspectRatio
	end
	Image.Size = P.Size
	Image.ResampleMode = P.ResampleMode
	local IFlipbook = {
		Enabled = P.FlipbookMode > 0,
		Mode = P.FlipbookMode,
		Size = P.Resolution / P.FlipbookLayout,
		Cells = P.FlipbookLayout.X * P.FlipbookLayout.Y,
		Resolution = P.Resolution,
		Rate = P.FlipbookFramerate,
		Skip = false,
		Alpha = 0,
		Beta = 0,
		Revert = false
	}
	local ISequences = {
		Color = P.Color,
		Scale = GET_ENVELOPE_TABLE(P.Scale),
		Transparency = GET_ENVELOPE_TABLE(P.Transparency),
		Rotation = GET_ENVELOPE_TABLE(P.RotSpeed)
	}
	local IConstraints = {
		Scale = Image:FindFirstChildWhichIsA('UIScale'),
		AspectRatio = Image:FindFirstChildWhichIsA('UIAspectRatioConstraint')
	}
	Particle.Object = Image
	Particle.Position = P.IsPoint and PLACE_INSIDE(self.Parent, .5, .5) or PLACE_INSIDE(self.Parent, __Random:NextNumber(), __Random:NextNumber())
	Particle.Velocity = CAST_UDIM2(EVAL_NUMBER_RANGE(P.Speed) * ROTATE_UNIT_VECTOR(P.Direction, math.rad(P.Spread * (__Random:NextNumber() - .5))))
	Particle.Acceleration = CAST_UDIM2(P.Acceleration)
	Particle.Rotation = EVAL_NUMBER_RANGE(P.Rotation)
	Particle.Drag = math.max(1 - P.Drag, .05)
	Particle.Orientation = P.Orientation
	Particle.IFlipbook = IFlipbook
	Particle.ISequences = ISequences
	Particle.IConstraints = IConstraints
	Particle.Lifetime = EVAL_NUMBER_RANGE(P.Lifetime)
	Particle.Time = 0
	Particle.Alpha = 0
	if (IFlipbook.Enabled) then
		Image.ImageRectSize = Particle.IFlipbook.Size
		if (IFlipbook.Mode == 2) then
			Particle.IFlipbook.Rate = (IFlipbook.Cells / Particle.Lifetime)
		end
	end
	if (P.FlipbookStartRandom) then
		self:FlipToRandom(Particle)
	end
	Image.Position = Particle.Position
	Image.Parent = UI
	table.insert(self.Particles, Particle)
end

--[[
	:Emit(|N|) will emit |N| particles.
	If |N| is not provided, it will emit a single particle.
]]--
function Emitter:Emit(N : number?)
	local k = N or 1
	if (k < 1) then
		return
	end
	for i = 1, math.round(k) do
		self:__Emit()
	end
end

--[[
	:Destroy() will destroy the emitter.
	This will clear all connections and clear all particles with the :Clear() function.
]]--
function Emitter:Destroy()
	for _, x : RBXScriptConnection in pairs(self.Connections) do
		x:Disconnect()
	end
	self:Clear()
	table.clear(self)
end

return Emitter
