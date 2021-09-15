--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr, ClassName)
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos +tr.HitNormal *60)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel(self.MDL)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:AddFlags(FL_OBJECT)
	
	local PObj = self:GetPhysicsObject()
	if not IsValid(PObj) then 
		self:Remove()
		print("LFS: missing model. Plane terminated.")
		return
	end
	
	PObj:EnableMotion(false)
	PObj:SetMass(self.Mass) 
	PObj:SetDragCoefficient(self.Drag)
	self.LFSInertiaDefault = PObj:GetInertia()
	self.Inertia = self.LFSInertiaDefault
	PObj:SetInertia(self.Inertia)
	
	self:InitPod()

	timer.Simple(0,function()
		if not IsValid(self) then return end
		self:RunOnSpawn()
		self:InitWheels()
	end)
end

function ENT:OnSetPilot(pilot)
	self:SetBodygroup(1,pilot == "Andrew" && 1 or pilot == "Leon" && 2 or pilot == "Pigma" && 3 or pilot == "Wolf" && 4 or 0)
end

function ENT:OnRemovePilot(pilot)
	self:SetBodygroup(1,0)
end

function ENT:RunOnSpawn()
	if self.PilotCode then
		self:SetNW2Entity("Enemy",NULL)
		self:SetNW2String("VO",nil)
	end
end

function ENT:OnRemove()
	if self.Charge then
		self.Charge:Stop()
	end
	SafeRemoveEntity(self.Trail1)
	SafeRemoveEntity(self.Trail2)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary(0.11)
	-- self:SetNextPrimary(0.15)

	local upgrade = SF.GetLaser(self,"lfs_sf_laser_red")
	for i = 1,2 do		
		local bullet = {}
		bullet.Num 		= 1
		bullet.Src 		= self:GetAttachment(i).Pos
		bullet.Dir 		= self:LocalToWorldAngles(Angle(0,0,0)):Forward()
		bullet.Spread 	= Vector(0.01,0.01,0)
		bullet.Tracer	= 1
		bullet.TracerName = upgrade.Effect
		bullet.Force	= 100
		bullet.HullSize = 25
		bullet.Damage	= 40 *upgrade.DMG
		bullet.Attacker = self:GetDriver()
		bullet.AmmoType = "Pistol"
		bullet.Callback = function(att,tr,dmginfo)
			dmginfo:SetDamageType(DMG_AIRBOAT)
			-- sound.Play("cpthazama/starfox/vehicles/laser_hit.wav", tr.HitPos, 110, 100, 1)
		end
		SF.PlaySound(3,bullet.Src,upgrade.Level > 0 && "LFS_SF_ARWING_PRIMARY_DOUBLE" or "LFS_SF_ARWING_PRIMARY",nil,nil,nil,true)
		self:FireBullets(bullet)
		self:TakePrimaryAmmo()
	end
end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:HandleWeapons(Fire1, Fire2)
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()

	-- if self:GetIsMoving() then
	-- 	self:PlayAnimation("idle",1)
	-- else
	-- 	self:PlayAnimation("run_blend",self:GetVelocity():Length() *0.05)
	-- end

	if self:GetForwardVelocity() <= 5 then
		self:SetSequence(self:LookupSequence("idle"))
		self:SetPlaybackRate(1)
	else
		self:ResetSequence(self:LookupSequence("run_blend"))
		self:SetPlaybackRate(self:GetForwardVelocity() /150)
	end

	if self.PilotCode && self:GetAI() then
		self:SetNW2Entity("Enemy",self:AIGetTarget())
		self:SetNW2Int("Team",self:GetAITEAM())
	end

	local Driver = self:GetDriver()
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown(IN_ATTACK)
		end
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
end

function ENT:OnEngineStarted()
	self:EmitSound("cpthazama/starfox/vehicles/arwing_power_up.wav")
	if IsValid(self:GetDriver()) then
		self:GetDriver():EmitSound("cpthazama/starfox/vehicles/arwing_enter.wav")
	end
end

function ENT:OnEngineStopped()
	self:EmitSound("cpthazama/starfox/vehicles/arwing_power_down.wav")
end

function ENT:Destroy()
	SF.Destroy(self)
	SF.OnDestroyed(self,1)
end

function ENT:AIGetTarget()
	return SF.FindEnemy(self)
end

function ENT:ApplyThrustVtol(PhysObj, vDirection, fForce) -- kill vtol function
end

function ENT:ApplyThrust(PhysObj, vDirection, fForce) -- kill thrust
end

function ENT:CalcFlightOverride(Pitch, Yaw, Roll, Stability) -- kill planescript handling
	return 0,0,0,0,0,0
end

function ENT:OnKeyThrottle(bPressed)
end

function ENT:OnVtolMode(IsOn)
end

function ENT:OnLandingGearToggled(bOn)
end

local GroupCollide = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_VEHICLE_CLIP] = true,
	[COLLISION_GROUP_WORLD] = true,
}

local CanMoveOn = {
	["func_door"] = true,
	["func_movelinear"] = true,
	["prop_physics"] = true, -- nice to have if someone wants to build his own eleveator using props.
}

function ENT:VeryLowTick()
	return FrameTime() > (1 /30)
end

function ENT:OnStartMaintenance()
	if not self:GetRepairMode() and not self:GetAmmoMode() then return end

	self.IsReloading = true
end

function ENT:OnStopMaintenance()
	self.IsReloading = nil
end

function ENT:OnTick()
	local Pod = self:GetDriverSeat()
	if not IsValid(Pod) then return end
	
	local Driver = Pod:GetDriver()

	local FT = FrameTime()
	local FTtoTick = FT *66.66666
	local TurnRate = FTtoTick *0.6
	
	local Hit = 0
	local HitMoveable = false
	local Vel = self:GetVelocity()
	
	self:SetMove(self:GetMove() +self:WorldToLocal(self:GetPos() +Vel).x *FT *1.8)

	local Move = self:GetMove()
	
	if Move > 360 then self:SetMove(Move -360) end
	if Move < -360 then self:SetMove(Move +360) end
	
	local EyeAngles = Angle(0,0,0)
	local KeyForward = false
	local KeyBack = false
	local KeyLeft = false
	local KeyRight = false
	
	local Sprint = false
	
	if IsValid(Driver) then
		EyeAngles = Driver:EyeAngles()
		KeyForward = Driver:lfsGetInput("+THROTTLE") or self.IsTurnMove
		KeyBack = Driver:lfsGetInput("-THROTTLE")
		KeyLeft = Driver:lfsGetInput("+ROLL")
		KeyRight = Driver:lfsGetInput("-ROLL") 
		
		if KeyBack then
			KeyForward = false
		end
		
		Sprint = Driver:lfsGetInput("VSPEC") or Driver:lfsGetInput("+PITCH") or Driver:lfsGetInput("-PITCH")

		local KeyReload = Driver:lfsGetInput("ENGINE")
		if self.OldKeyReload ~= KeyReload then
			self.OldKeyReload = KeyReload

			if KeyReload and not self.IsReloading then
				self:StartMaintenance()
			end
		end
	end
	local MoveSpeed = Sprint and 600 or 300
	self.smSpeed = self.smSpeed and self.smSpeed +((KeyForward and MoveSpeed or 0) -(KeyBack and MoveSpeed or 0) -self.smSpeed) *FTtoTick *0.05 or 0
	
	self:SetIsMoving(math.abs(self.smSpeed) > 1)

	local PObj = self:GetPhysicsObject()
	
	-- if IsValid(PObj) then
	-- 	local MassCselferL = PObj:GetMassCselfer()
	-- 	MassCselferL.z = 140
		
	-- 	local MassCselfer = self:LocalToWorld(MassCselferL)
		
	-- 	local Forward = self:GetForward()
	-- 	local Right = self:GetRight()
	-- 	local Up = self:GetUp()
		
	-- 	local Trace = util.TraceHull({
	-- 		start = MassCselfer, 
	-- 		endpos = MassCselfer -Up *195,
			
	-- 		filter = function(self) 
	-- 			if self == self or self == self:GetRearEnt() or self:IsPlayer() or self:IsNPC() or self:IsVehicle() or GroupCollide[ self:GetCollisionGroup() ] then
	-- 				return false
	-- 			end
				
	-- 			return true
	-- 		end,
			
	-- 		mins = Vector(-20, -20, 0),
	-- 		maxs = Vector(20, 20, 0),
	-- 	})

	-- 	local IsOnGround = Trace.Hit and math.deg(math.acos(math.Clamp(Trace.HitNormal:Dot(Vector(0,0,1)) ,-1,1))) < 70
		
	-- 	PObj:EnableGravity(not IsOnGround)
		
	-- 	if not HitMoveable then
	-- 		if IsValid(Trace.Entity) then
	-- 			HitMoveable = CanMoveOn[ Trace.Entity:GetClass() ]
	-- 		end
	-- 	end

	-- 	if IsOnGround then
	-- 		Hit = Hit +1
	-- 		local Mass = PObj:GetMass()
	-- 		local TargetDist = 140
	-- 		local Dist = (Trace.HitPos -MassCselfer):Length()
			
	-- 		local Vel = self:GetVelocity()
	-- 		local VelL = self:WorldToLocal(self:GetPos() +Vel)
			
	-- 		local P = math.cos(math.rad(Move *2)) *15
	-- 		local R = math.cos(math.rad(Move)) *15
			
	-- 		self.smNormal = self.smNormal and self.smNormal +(Trace.HitNormal -self.smNormal) *FTtoTick *0.01 or Trace.HitNormal
	-- 		local Normal = (self.smNormal +self:LocalToWorldAngles(Angle(P,0,R)):Up() *0.1):GetNormalized()
			
	-- 		local Force = (Up *(TargetDist -Dist) *3 -Up *VelL.z +Right *VelL.y) *0.5
			
	-- 		if self:VeryLowTick() then
	-- 			Force = (Up *(TargetDist -Dist) *1 -Up *VelL.z *0.5 +Right *VelL.y *0.5) *0.5
	-- 		end
			
	-- 		PObj:ApplyForceCselfer(Force *Mass *FTtoTick)
			
	-- 		local AngForce = Angle(0,0,0) 
	-- 		if IsValid(Driver) then
	-- 			if Driver:lfsGetInput("FREELOOK") then
	-- 				if isangle(self.StoredEyeAnglesMech) then
	-- 					EyeAngles = self.StoredEyeAnglesMech 
	-- 				end
	-- 			else
	-- 				self.StoredEyeAnglesMech  = EyeAngles
	-- 			end
	-- 			local AddYaw = (KeyRight and 30 or 0) -(KeyLeft and 30 or 0)
	-- 			local NEWsmY = math.ApproachAngle(self.smY, Pod:WorldToLocalAngles(EyeAngles +Angle(0,AddYaw,0)).y, TurnRate)
				
	-- 			self.IsTurnMove = math.abs(NEWsmY -self.smY) >= TurnRate *0.99

	-- 			self.smY = self.smY and NEWsmY or self:GetAngles().y
	-- 		else
	-- 			self.IsTurnMove = false
	-- 			self.smY = self:GetAngles().y
	-- 		end
			
	-- 		AngForce.y = self:WorldToLocalAngles(Angle(0,self.smY,0)).y
			
	-- 		if self:VeryLowTick() then
	-- 			self:ApplyAngForceTo(self, (AngForce *50 -self:GetAngVelFrom(self) *4) *Mass *2 *FTtoTick)
				
	-- 			PObj:ApplyForceOffset(-Normal *Mass *5 *FTtoTick, -Up *200)
	-- 			PObj:ApplyForceOffset(Normal *Mass *5 *FTtoTick, Up *200)
	-- 		else
	-- 			self:ApplyAngForceTo(self, (AngForce *50 -self:GetAngVelFrom(self) *2) *Mass *10 *FTtoTick)
			
	-- 			PObj:ApplyForceOffset(-Normal *Mass *5 *FTtoTick, -Up *2000)
	-- 			PObj:ApplyForceOffset(Normal *Mass *5 *FTtoTick, Up *2000)
	-- 		end
	-- 	end
	-- end
	
	if Hit >= 2 and not HitMoveable then
		local IsHeld = self:IsPlayerHolding() or self:GetRearEnt():IsPlayerHolding() 
		local ShouldMotionEnable = self:GetIsMoving() or IsHeld
		
		if IsHeld then
			self.smSpeed = 200
		end
		
		local PObj = self:GetPhysicsObject()
		if PObj:IsMotionEnabled() ~= ShouldMotionEnable then
			PObj:EnableMotion(ShouldMotionEnable)
		end
	else
		local ShouldMotionEnable = self:GetIsMoving() or IsHeld or HitMoveable
		
		local PObj = self:GetPhysicsObject()

		if not PObj:IsMotionEnabled() then
			PObj:EnableMotion(ShouldMotionEnable)
		end
	end
	
	if Hit > 0 then
		local PObj = self:GetPhysicsObject()
		local Mass = PObj:GetMass()

		local Vel = self:GetVelocity()
		local VelL = self:WorldToLocal(self:GetPos() +Vel)

		local Force = self:GetForward() *(self.smSpeed -VelL.x)
		
		if self:VeryLowTick() then
			PObj:ApplyForceCenter(Force *Mass *FTtoTick *0.1)
		else
			PObj:ApplyForceCenter(Force *Mass *FTtoTick)
		end
	end
end

function ENT:IsEngineStartAllowed() -- always allow it to be turned on
	return true
end

function ENT:HandleStart() -- autostart 
	local Driver = self:GetDriver()
	
	local Active = (IsValid( Driver ) or self:GetAI())

	if Active then
		if not self:GetEngineActive() then
			self:StartEngine()
		end
	else
		if self:GetEngineActive() then
			self:StopEngine()
		end
	end
end

function ENT:GetAngVelFrom( ent )
	local phys = ent:GetPhysicsObject()
	if not IsValid( phys ) then return Angle(0,0,0) end
	
	local vec = phys:GetAngleVelocity()
	
	return Angle( vec.y, vec.z, vec.x )
end

function ENT:ApplyAngForceTo( ent, angForce )
	local phys = ent:GetPhysicsObject()

	if not IsValid( phys ) then return end
	
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()

	local pitch = up * (angForce.p * 0.5)
	phys:ApplyForceOffset( forward, pitch )
	phys:ApplyForceOffset( forward * -1, pitch * -1 )

	local yaw = forward * (angForce.y * 0.5)
	phys:ApplyForceOffset( left, yaw )
	phys:ApplyForceOffset( left * -1, yaw * -1 )

	local roll = left * (angForce.r * 0.5)
	phys:ApplyForceOffset( up, roll )
	phys:ApplyForceOffset( up * -1, roll * -1 )
end

function ENT:UnRagdoll()
	self:SetDieRagdoll( false )
	self.smSpeed = 200


	if istable( self.Constrainer ) then
		for k, v in pairs( self.Constrainer ) do
			if IsValid( v ) then
				if v ~= self then
					v:Remove()
				end
			end
		end

		self.Constrainer = nil
	end

	self.DoNotDuplicate = false
end

function ENT:BecomeRagdoll()
	self:SetDieRagdoll( true )
end