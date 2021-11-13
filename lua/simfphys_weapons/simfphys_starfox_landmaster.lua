local ENT = {}

ENT.Class = {"simfphys_starfox_landmaster"}
ENT.ReloadTime = 2

function simfphys.weapon:PrimaryAttack(ply,veh,shootOrigin,shootDirection)
	if not self:CanPrimaryAttack(veh) then return end
	veh:EmitSound("LFS_SF_APAROID_MISSILE")

	SF.FireProjectile(veh,"lfs_starfox_projectile",veh:GetAttachment(1).Pos,false,nil,function(ent)
		ent.DMG = 500
		ent.DMGDist = 750
	end)

	self:SetNextPrimaryFire(veh,CurTime() +ENT.ReloadTime)
end

function simfphys.weapon:ControlTrackSounds(veh,wheelslocked) 
	local speed = math.abs(self:GetForwardSpeed(veh))
	local fastenuf = speed > 20 && not wheelslocked && self:IsOnGround(veh)
	
	if fastenuf != veh.fastenuf then
		veh.fastenuf = fastenuf
		if fastenuf then
			veh.track_snd = CreateSound(veh,"simulated_selfs/sherman/tracks.wav")
			veh.track_snd:PlayEx(0,0)
			veh:CallOnRemove("stopmesounds",function(veh)
				if veh.track_snd then
					veh.track_snd:Stop()
				end
			end)
		else
			if veh.track_snd then
				veh.track_snd:Stop()
				veh.track_snd = nil
			end
		end
	end
	
	if veh.track_snd then
		veh.track_snd:ChangePitch(math.Clamp(60 +speed /70,0,150)) 
		veh.track_snd:ChangeVolume(math.min(math.max(speed -20,0) /600,1)) 
	end
end

function simfphys.weapon:DoWheelSpin(veh)
	-- local spin_r = (veh.VehicleData["spin_4"] +veh.VehicleData["spin_6"]) *1.2
	-- local spin_l = (veh.VehicleData["spin_3"] +veh.VehicleData["spin_5"]) *1.2
	
	-- veh:SetPoseParameter("spin_wheels_right",spin_r)
	-- veh:SetPoseParameter("spin_wheels_left",spin_l)
	
	-- net.Start("simfphys_update_tracks",true)
	-- 	net.WriteEntity(veh)
	-- 	net.WriteFloat(spin_r) 
	-- 	net.WriteFloat(spin_l) 
	-- net.Broadcast()
end

    ///////////////////////////////
    //							  //
    //							  //
    //		NO MAN'S LAND		  //
    //							  //
    //							  //
    ///////////////////////////////

function simfphys.weapon:ValidClasses()
	return ENT.Class
end

function simfphys.weapon:Initialize(veh)
	veh:SetNWBool("SpecialCam_Loader",true)
	veh:SetNWFloat("SpecialCam_LoaderTime",veh.ReloadTime)
	
	simfphys.RegisterCrosshair(veh:GetDriverSeat(),{Direction = Vector(0,0,1),Attachment = "muzzle",Type = 2})

	timer.Simple(1,function()
		if not IsValid(veh) then return end
		if not veh.VehicleData["filter"] then print("[simfphys Armed Vehicle Pack] ERROR:TRACE FILTER IS INVALID. PLEASE UPDATE SIMFPHYS BASE") return end

		veh.WheelOnGround = function(ent)
			ent.FrontWheelPowered = ent:GetPowerDistribution() != 1
			ent.RearWheelPowered = ent:GetPowerDistribution() != -1
			
			for i = 1,table.Count(ent.Wheels) do
				local Wheel = ent.Wheels[i]
				if IsValid(Wheel) then
					local dmgMul = Wheel:GetDamaged() && 0.5 or 1
					local surfacemul = simfphys.TractionData[Wheel:GetSurfaceMaterial():lower()]
					
					ent.VehicleData["SurfaceMul_" .. i] = (surfacemul && math.max(surfacemul,0.001) or 1) *dmgMul
					
					local WheelPos = ent:LogicWheelPos(i)
					
					local WheelRadius = WheelPos.IsFrontWheel && ent.FrontWheelRadius or ent.RearWheelRadius
					local startpos = Wheel:GetPos()
					local dir = -ent.Up
					local len = WheelRadius +math.Clamp(-ent.Vel.z /50,2.5,6)
					local HullSize = Vector(WheelRadius,WheelRadius,0)
					local tr = util.TraceHull({
						start = startpos,
						endpos = startpos +dir *len,
						maxs = HullSize,
						mins = -HullSize,
						filter = ent.VehicleData["filter"]
					})
					
					local onground = veh:IsOnGround(ent) && 1 or 0
					Wheel:SetOnGround(onground)
					ent.VehicleData["onGround_" .. i] = onground
					
					if tr.Hit then
						Wheel:SetSpeed(Wheel.FX)
						Wheel:SetSkidSound(Wheel.skid)
						Wheel:SetSurfaceMaterial(util.GetSurfacePropName(tr.SurfaceProps))
					end
				end
			end
			
			local FrontOnGround = math.max(ent.VehicleData["onGround_1"],ent.VehicleData["onGround_2"])
			local RearOnGround = math.max(ent.VehicleData["onGround_3"],ent.VehicleData["onGround_4"])
			
			ent.DriveWheelsOnGround = math.max(ent.FrontWheelPowered && FrontOnGround or 0,ent.RearWheelPowered && RearOnGround or 0)
		end
	end)
end

function simfphys.weapon:Think(veh)
	if not IsValid(veh) or not veh:IsInitialized() then return end

	veh.wOldPos = veh.wOldPos or Vector(0,0,0)
	local deltapos = veh:GetPos() -veh.wOldPos
	veh.wOldPos = veh:GetPos()

	local handbrake = veh:GetHandBrakeEnabled()
	self:UpdateSuspension(veh)
	self:DoWheelSpin(veh)
	self:ControlTurret(veh,deltapos)
	self:ControlTrackSounds(veh,handbrake)
	self:ModPhysics(veh,handbrake)
end

function simfphys.weapon:ControlTurret(veh,deltapos)
	local pod = veh:GetDriverSeat()
	if not IsValid(pod) then return end
	local ply = pod:GetDriver()
	if not IsValid(ply) then return end

	local safemode = ply:KeyDown(IN_WALK)
	if veh.ButtonSafeMode != safemode then
		veh.ButtonSafeMode = safemode
		if safemode then
			veh:SetNWBool("TurretSafeMode",not veh:GetNWBool("TurretSafeMode",true))
		end
	end

	if veh:GetNWBool("TurretSafeMode",true) then return end

	local ID = veh:LookupAttachment("muzzle")
	local Attachment = veh:GetAttachment(ID)

	self:AimCannon(ply,veh,pod,Attachment)

	local shootOrigin = Attachment.Pos +deltapos *engine.TickInterval()
	local fire = ply:KeyDown(IN_ATTACK)

	if fire then
		self:PrimaryAttack(veh,ply,shootOrigin,Attachment.Ang:Forward())
	end
end

function simfphys.weapon:AimCannon(ply,veh,pod,Attachment)	
	if not IsValid(pod) then return end
	
	local Aimang = pod:WorldToLocalAngles(ply:EyeAngles())
	local AimRate = 50
	local Angles = veh:WorldToLocalAngles(Aimang)

	veh.sm_pp_yaw = veh.sm_pp_yaw && math.ApproachAngle(veh.sm_pp_yaw,Angles.y,AimRate *FrameTime()) or 0
	veh.sm_pp_pitch = veh.sm_pp_pitch && math.ApproachAngle(veh.sm_pp_pitch,Angles.p,AimRate *FrameTime()) or 0

	local TargetAng = Angle(veh.sm_pp_pitch,veh.sm_pp_yaw,0)
	TargetAng:Normalize() 

	veh:SetPoseParameter("aim_pitch",TargetAng.p)
	veh:SetPoseParameter("aim_yaw",TargetAng.y)
end

function simfphys.weapon:CanPrimaryAttack(veh)
	veh.NextShoot = veh.NextShoot or 0
	return veh.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire(veh,time)
	veh.NextShoot = time
	veh:SetNWFloat("SpecialCam_LoaderNext",time)
end

function simfphys.weapon:GetForwardSpeed(veh)
	return veh.ForwardSpeed
end

function simfphys.weapon:IsOnGround(veh)
	return (veh.susOnGround == true)
end

function simfphys.weapon:ModPhysics(veh,wheelslocked)
	if wheelslocked && self:IsOnGround(veh) then
		local phys = veh:GetPhysicsObject()
		phys:ApplyForceCenter(-veh:GetVelocity() *phys:GetMass() *0.04)
	end
end

function simfphys.weapon:UpdateSuspension(veh)
	if not veh.filterEntities then
		veh.filterEntities = player.GetAll()
		table.insert(veh.filterEntities,veh)
		for i,wheel in pairs(ents.FindByClass("gmod_sent_self_fphysics_wheel")) do
			table.insert(veh.filterEntities,wheel)
		end
	end

    local pos = veh:GetPos() +veh:OBBCenter()
    local trace = util.TraceHull({
        start = pos,
        endpos = pos +veh:GetUp() *-100,
        maxs = Vector(15,15,0),
        mins = -Vector(15,15,0),
        filter = veh.filterEntities,
    })
    local Dist = (pos -trace.HitPos):Length() -30

    if trace.Hit then
        veh.susOnGround = true
    end
end