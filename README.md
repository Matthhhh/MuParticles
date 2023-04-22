```                                              
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
__________________________________________________________________________________________________________
```
# Introduction
**μ**Particles or **Mu**Particles (**M**ath’s **U**I Particles) is a client-based easy-to-use user interface particle emitter for [Roblox](https://en.wikipedia.org/wiki/Roblox) experiences.
It is heavily inspired by Synitx’s [2D Emitter](https://github.com/Synitx/2D-Emitter-2), also made for Roblox. 


This module was initially created for exclusive use in *Project Æsir* but is now open-source.

# Documentation
## API
### Properties
> - Color
> - Orientation
> - Scale
> - Texture 	
> - Transparency    
> - Direction 	  
> - Enabled 	   
> - Lifetime 	 
> - Rate 		   
> - Rotation
> - RotSpeed
> - Speed 
> - Spread 	 
> - FlipbookLayout
> - FlipbookMode
> - FlipbookFramerate	 
> - FlipbookStartRandom	
> - MaxParticles    
> - Acceleration 
> - Drag
> - TimeScale
> - AspectRatio     
> - IsPoint   
> - ResampleMode
> - Resolution    
> - Size     
### Methods
```lua
--[[
  .new(...) is the constructor function for the |Emitter| object.
  Consider using .from(...) instead.
]]--
function Emitter.new(Properties : {any}?, Parent : Instance) : Emitter

--[[
  .from(...) is another constructor function for the |Emitter| object.
  The |Object| parameter is expected to be a instance (with attributes/properties) or a property table.
]]--
function Emitter.from(Object : ParticleEmitter?) : Emitter

--[[
  :Set(...) should be used to set the properties of an |Emitter|.
  The |Value| parameter is expected to be nil when |Property| :: {any}.
]]--
function Emitter:Set(Property : string | {any}, Value : any?)

--[[
  :Enable(...) is a shortcut for :Set("Enabled", |State|).
  This enables or disables the emitter.
]]--
function Emitter:Enable(State : boolean)

--[[
  :Disable() is a shortcut for :Enable(false).
  This disables the emitter.
]]--
function Emitter:Disable()

--[[
  :Emit(...) will emit |Amount| particle(s).
  This function uses :__Emit().
]]--
function Emitter:Emit(|Amount| : number)

--[[
  :Clear() should be used to clear all particles from the emitter.
  This is also used in :Destroy().
]]--
function Emitter:Clear()

--[[
  :Destroy() will destroy the emitter.
  This will clear all connections and clear all particles with the :Clear() function.
]]--
function Emitter:Destroy()
```
## Example
Let's start by requiring the module.
```lua
local Particles = require(path.to.module)
```
We can now create a new emitter from an existing ParticleEmitter, and emit some particles!
```lua
local Particles = require(path.to.module)
local Emitter = Particles.from(path.to.emitter)

Emitter:Enable()
task.delay(5, Emitter.Disable, Emitter) -- Disable after 5 seconds.
```
## Custom Particles
You can also create custom particles, using **μ**Particles and basic [OOP](https://en.wikipedia.org/wiki/Object-oriented_programming) knowledge.

There is an example file in this repository, but this is how to create a very basic custom particle that is kept alive forever.
```lua
local Base = require(path.to.module)

--[[
local Emitter = {} ... -- Deprecated.
]]--
local Emitter = Base.inherit() -- This is a custom function that simplifies inheritance.
Emitter.__index = Emitter

function Emitter:Update(Particle : Base.IParticle, DT)
    return true -- If the particle is alive this frame, return true, else false.
end

return Emitter
```
