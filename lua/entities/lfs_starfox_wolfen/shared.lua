ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Wolfen Mk. II"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox: Assault"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/starfox/vehicles/wolfen.mdl"

ENT.AITEAM = 2

ENT.Mass = 2000
ENT.Inertia = Vector(400000,400000,400000)
ENT.Drag = -1

ENT.HideDriver = false
ENT.SeatPos = Vector(50,0,32)
ENT.SeatAng = Angle(0,-90,0)

ENT.WheelMass 		= 	325 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	50
ENT.WheelPos_L 		= 	Vector(0,-120,-180)
ENT.WheelPos_R 		= 	Vector(0,120,-180)
ENT.WheelPos_C   	= 	Vector(150,0,-180)

ENT.IdleRPM = 1
ENT.MaxRPM = 3600
ENT.LimitRPM = 4400

ENT.RotorPos = Vector(490,0,10)
ENT.WingPos = Vector(-50,0,10)
ENT.ElevatorPos = Vector(-270,0,10)
ENT.RudderPos = Vector(-270,0,10)

ENT.MaxVelocity = 4400

ENT.MaxThrust = 50000

ENT.MaxTurnPitch = 800
ENT.MaxTurnYaw = 800
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 	1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = 1000
ENT.MaxShield = 500

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 10000

ENT.Stability 	= 	1
ENT.MaxStability 	= 	1

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})
end

sound.Add({
	name = "LFS_SF_ARWING_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/starfox/vehicles/arwing_eng_boost_loop.wav"
})

sound.Add({
	name = "LFS_SF_ARWING_ENGINE2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "cpthazama/starfox/vehicles/arwing_eng.wav"
})

sound.Add({
	name = "LFS_SF_ARWING_BOOST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/starfox/vehicles/arwing_eng_boost_short.wav"
})

sound.Add({
	name = "LFS_SF_ARWING_PRIMARY",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/starfox/vehicles/arwing_laser_single_hit.wav"
})

sound.Add({
	name = "LFS_SF_ARWING_PRIMARY_CHARGED",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/starfox/vehicles/arwing_fire_charged.wav"
})

sound.Add({
	name = "LFS_SF_ARWING_PRIMARY_DOUBLE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/starfox/vehicles/arwing_laser_double.wav"
})