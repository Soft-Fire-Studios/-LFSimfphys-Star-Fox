local vehicleClass = "simfphys_starfox_landmaster"
local vehicleData = {
	Name = "Landmaster Mk. II",
	Model = "models/cpthazama/starfox/vehicles/landmaster.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "[Simfphys] Star Fox",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 3500,
		MaxHealth = 6000,
		-- LightsTable = "capc_siren",
		IsArmored = true,
		NoWheelGibs = true,
		OnSpawn = function(ent) 
			ent:SetNWBool("simfphys_NoRacingHud",true)
			ent:SetNWBool("simfphys_NoHud",true) 
			ent.OnTakeDamage = SFSIM.TankTakeDamage
		end,
		GibModels = {},
		FrontWheelRadius = 28,
		RearWheelRadius = 28,
		SeatOffset = Vector(-25,0,104),
		SeatPitch = 0,
		-- PassengerSeats = {
			-- {
			-- 	pos = Vector(0,-30,50),
			-- 	ang = Angle(0,0,0)
			-- },
		-- },
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		CustomWheelPosFL = Vector(125.84973144531,48.389747619629,30.290405273438),
		CustomWheelPosFR = Vector(125.84973144531,-48.389747619629,30.290405273438),
		CustomWheelPosML = Vector(11,53.490116119385,30.290405273438),
		CustomWheelPosMR = Vector(11,-53.490116119385,30.290405273438),
		CustomWheelPosRL = Vector(-114.63017272949,51.120929718018,30.289306640625),
		CustomWheelPosRR = Vector(-114.63017272949,-51.120929718018,30.289306640625),
		CustomWheelAngleOffset = Angle(0,0,90),
		CustomMassCenter = Vector(0,0,5),
		CustomSteerAngle = 60,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},

		FrontHeight = 10,
		FrontConstant = 50000,
		FrontDamping = 3000,
		FrontRelativeDamping = 3000,

		RearHeight = 10,
		RearConstant = 50000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,

		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 8,

		MaxGrip = 70,
		Efficiency = 1.8,
		GripOffset = 0,
		BrakePower = 70,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		FuelFillPos = Vector(32.82,-78.31,81.89),
		PowerBias = 0,

		EngineSoundPreset = 0,
		Sound_Idle = "simulated_vehicles/c_apc/apc_idle.wav",
		Sound_IdlePitch = 1,
		Sound_Mid = "simulated_vehicles/c_apc/apc_mid.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		Sound_High = "",
		Sound_Throttle = "",
		snd_horn = "ambient/alarms/apc_alarm_pass1.wav",
		
		ForceTransmission = 1,
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.1,0.2,0.3}
	}
}
list.Set("simfphys_vehicles",vehicleClass,vehicleData)

print("[LFSimfphys] Initialized " .. vehicleData.Name .. " [" .. vehicleClass .. "] successfully!")