ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Cornerian Fighter Mk. II (Infected)"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/starfox/vehicles/cornerian_fighter_aparoid.mdl"

ENT.AITEAM = SF_AI_TEAM_APAROID

ENT.SF_HasSmartBombs = false

ENT.Mass = 1000
local inert = 200000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -10

ENT.HideDriver = false
ENT.SeatPos = Vector(50,0,25)
ENT.SeatAng = Angle(0,-90,0)

ENT.WheelMass 		= 	325 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	10
ENT.WheelPos_L 		= 	Vector(0,-80,-160)
ENT.WheelPos_R 		= 	Vector(0,80,-160)
ENT.WheelPos_C   	= 	Vector(120,0,-160)

ENT.IdleRPM = 1
ENT.MaxRPM = 3200
ENT.LimitRPM = 4000

ENT.RotorPos = Vector(490,0,10)
ENT.WingPos = Vector(-50,0,10)
ENT.ElevatorPos = Vector(-270,0,10)
ENT.RudderPos = Vector(-270,0,10)

ENT.MaxVelocity = 4000

ENT.MaxThrust = 45000

ENT.MaxTurnPitch = 800
ENT.MaxTurnYaw = 800
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 	1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = 250
ENT.MaxShield = 150

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 10000

ENT.Stability 	= 	0.8
ENT.MaxStability 	= 	0.8

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
	self:NetworkVar("Float",21,"ChargeT")
end