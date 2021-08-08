ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Venomian Stealth Bomber"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/starfox/vehicles/venomian_bomber.mdl"

ENT.AITEAM = SF_AI_TEAM_ANDROSS

ENT.Mass = 2000
local inert = 100000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -10

ENT.HideDriver = true
ENT.SeatPos = Vector(50,0,500)
ENT.SeatAng = Angle(0,-90,0)

-- ENT.WheelMass 		= 	325 -- wheel mass is 1 when the landing gear is retracted
-- ENT.WheelRadius 	= 	10
-- ENT.WheelPos_L 		= 	Vector(0,-80,-160)
-- ENT.WheelPos_R 		= 	Vector(0,80,-160)
-- ENT.WheelPos_C   	= 	Vector(120,0,-160)

ENT.IdleRPM = 1
ENT.MaxRPM = 2400
ENT.LimitRPM = 3000

ENT.RotorPos = Vector(2300,0,10)
ENT.WingPos = Vector(950,0,10)
ENT.ElevatorPos = Vector(-1190,0,150)
ENT.RudderPos = Vector(-1300,0,250)

ENT.MaxVelocity = 2700

ENT.MaxThrust = 45000

ENT.MaxTurnPitch = 800
ENT.MaxTurnYaw = 800
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 	1200 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = 1000
ENT.MaxShield = 0

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 240

ENT.Stability 	= 1
ENT.MaxStability 	= 1

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
end