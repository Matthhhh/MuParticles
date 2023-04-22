local Particles = require(path.to.module)
local Emitter = Particles.from(path.to.particle)
Emitter:Emit(100)
task.wait(1)
Emitter:Set(
  Rate        = 100, 
  Size        = UDim2.fromScale(.1, .1), 
  AspectRatio = 1 
})
Emitter:Enable()
