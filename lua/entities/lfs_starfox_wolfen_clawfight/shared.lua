ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

AddCSLuaFile("starfox/pilots_shared.lua")
include("starfox/pilots_shared.lua")

ENT.PrintName = "Wolfen Mk. III (Claw Fight)"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.Pilots = {"Wolf_Assault"}

ENT.MDL = "models/cpthazama/starfox/vehicles/wolfen_clawfight.mdl"

ENT.AITEAM = 2

ENT.SF_HasSmartBombs = true

ENT.Mass = 2000
ENT.Inertia = Vector(400000,400000,400000)
ENT.Drag = -1

ENT.HideDriver = false
ENT.SeatPos = Vector(50,0,-10)
ENT.SeatAng = Angle(0,-90,0)

-- ENT.WheelMass 		= 	325 -- wheel mass is 1 when the landing gear is retracted
-- ENT.WheelRadius 	= 	60
-- ENT.WheelPos_L 		= 	Vector(0,-120,-180)
-- ENT.WheelPos_R 		= 	Vector(0,120,-180)
-- ENT.WheelPos_C   	= 	Vector(-40,0,-180)

ENT.IdleRPM = 1
ENT.MaxRPM = 3600
ENT.LimitRPM = 4400

ENT.RotorPos = Vector(350,0,10)
ENT.WingPos = Vector(100,0,10)
ENT.ElevatorPos = Vector(-200,0,10)
ENT.RudderPos = Vector(-200,0,10)

ENT.MaxVelocity = 4400

ENT.MaxThrust = 50000

ENT.MaxTurnPitch = 800
ENT.MaxTurnYaw = 800
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 	150 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = 950
ENT.MaxShield = 850

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 10000
ENT.MaxSecondaryAmmo = 6

ENT.Stability 	= 	1
ENT.MaxStability 	= 	1

SF.AddShipData("lfs_starfox_wolfen_redfang",ENT.PrintName,ENT.MDL,ENT.MaxHealth,ENT.MaxShield,ENT.MaxPrimaryAmmo,ENT.MaxSecondaryAmmo,nil,45)

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
	self:NetworkVar("Float",21,"ChargeT")
end