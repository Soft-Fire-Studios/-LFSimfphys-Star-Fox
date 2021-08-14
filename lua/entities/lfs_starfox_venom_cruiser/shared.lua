ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

AddCSLuaFile("starfox/functions.lua")
include("starfox/functions.lua")

ENT.PrintName = "Venomian Carrier Mk. II"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= true
ENT.AdminSpawnable  = true

ENT.MDL = "models/cpthazama/starfox/vehicles/venom_carrier.mdl"

ENT.GibModels = {
	"models/cpthazama/starfox/vehicles/gibs/venom_carrier_1.mdl",
	"models/cpthazama/starfox/vehicles/gibs/venom_carrier_2.mdl",
	"models/cpthazama/starfox/vehicles/gibs/venom_carrier_3.mdl",
	"models/cpthazama/starfox/vehicles/gibs/venom_carrier_4.mdl",
	"models/cpthazama/starfox/vehicles/gibs/venom_carrier_5.mdl"
}

ENT.AITEAM = SF_AI_TEAM_ANDROSS

ENT.SF_BlockUpgrade = true

ENT.Mass = 30000
-- local inert = 200000
-- ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -10

ENT.HideDriver = true
ENT.SeatPos = Vector(7297,0,3000)
ENT.SeatAng = Angle(0,-90,0)

ENT.IdleRPM = 1
ENT.MaxRPM = 9000
ENT.LimitRPM = 12000

ENT.RotorPos = Vector(8000,0,3100)
ENT.WingPos = Vector(-4000,0,2500)
ENT.ElevatorPos = Vector(-6800,0,4200)
ENT.RudderPos = Vector(-6800,0,4200)

ENT.MaxVelocity = 1500

ENT.MaxThrust = 45000

ENT.MaxTurnPitch = 100
ENT.MaxTurnYaw = 100
ENT.MaxTurnRoll = 90

ENT.MaxPerfVelocity = 	1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = 5000
ENT.MaxShield = 7500

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 80000

ENT.Stability 	 = 1
ENT.MaxStability = 1

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
end

sound.Add({
	name = "LFS_SF_CRUISER_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 150,
	sound = "cpthazama/starfox/vehicles/arwing_eng_boost_loop.wav"
})