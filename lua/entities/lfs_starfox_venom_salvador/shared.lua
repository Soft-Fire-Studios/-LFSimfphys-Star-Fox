ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "The Salvadora"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= false
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/starfox/vehicles/salvadora.mdl"

ENT.GibModels = {}

ENT.AITEAM = SF_AI_TEAM_ANDROSS

ENT.SF_BlockUpgrade = true

ENT.Mass = 1
ENT.Drag = -10

ENT.HideDriver = true
ENT.SeatPos = Vector(7297,0,3000)
ENT.SeatAng = Angle(0,-90,0)

ENT.IdleRPM = 1
ENT.MaxRPM = 1
ENT.LimitRPM = 1

ENT.RotorPos = Vector(8000,0,3100)
ENT.WingPos = Vector(-4000,0,2500)
ENT.ElevatorPos = Vector(-6800,0,4200)
ENT.RudderPos = Vector(-6800,0,4200)

ENT.MaxVelocity = 0

ENT.MaxThrust = 1

ENT.MaxTurnPitch = 0
ENT.MaxTurnYaw = 0
ENT.MaxTurnRoll = 0

ENT.MaxPerfVelocity = 	1 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = 15000
ENT.MaxShield = 25000

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 1

ENT.MaxPrimaryAmmo = 150000

ENT.Stability 	 = 1
ENT.MaxStability = 1

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
end