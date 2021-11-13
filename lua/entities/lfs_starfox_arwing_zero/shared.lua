ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Arwing Mk. I"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/starfox/vehicles/arwing_zero.mdl"

ENT.AITEAM = 1

ENT.Mass = 2000
ENT.Inertia = Vector(400000,400000,400000)
ENT.Drag = -1

ENT.HideDriver = false
ENT.SeatPos = Vector(-12,0,-7)
ENT.SeatAng = Angle(0,-90,0)

-- ENT.WheelMass 		= 	325 -- wheel mass is 1 when the landing gear is retracted
-- ENT.WheelRadius 	= 	50
-- ENT.WheelPos_L 		= 	Vector(0,-120,-180)
-- ENT.WheelPos_R 		= 	Vector(0,120,-180)
-- ENT.WheelPos_C   	= 	Vector(150,0,-180)

ENT.IdleRPM = 1
ENT.MaxRPM = 3600
ENT.LimitRPM = 4400

ENT.RotorPos = Vector(225,0,10)
ENT.WingPos = Vector(100,0,10)
ENT.ElevatorPos = Vector(-200,0,10)
ENT.RudderPos = Vector(-200,0,10)

ENT.MaxVelocity = 4400

ENT.MaxThrust = 50000

ENT.MaxTurnPitch = 800
ENT.MaxTurnYaw = 800
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 	1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = 650
ENT.MaxShield = 450

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 10000

ENT.Stability 	= 	1
ENT.MaxStability 	= 	1

SF.AddShipData("lfs_starfox_arwing_zero",ENT.PrintName,ENT.MDL,ENT.MaxHealth,ENT.MaxShield,ENT.MaxPrimaryAmmo,ENT.MaxSecondaryAmmo,nil,5)

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
	self:NetworkVar("Float",21,"ChargeT")
end