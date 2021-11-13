ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Cornerian Fighter Mk. II"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/starfox/vehicles/cornerian_fighter.mdl"

ENT.AITEAM = SF_AI_TEAM_CORNERIA

ENT.SF_HasSmartBombs = false

ENT.Mass = 1000
local inert = 200000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -10

ENT.HideDriver = false
ENT.SeatPos = Vector(50,0,25)
ENT.SeatAng = Angle(0,-90,0)

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

SF.AddShipData("lfs_starfox_cornerian_fighter",ENT.PrintName,ENT.MDL,ENT.MaxHealth,ENT.MaxShield,ENT.MaxPrimaryAmmo,ENT.MaxSecondaryAmmo,nil,10)

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
	self:NetworkVar("Float",21,"ChargeT")
end