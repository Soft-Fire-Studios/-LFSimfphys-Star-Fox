--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 1500)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()
	local ramp = ents.Create("lfs_vehicle_spammer_better")
	ramp:SetPos(self:LocalToWorld(Vector(500,0,1541)))
	ramp:SetAngles(self:GetAngles() +Angle(0,90,0))
	ramp:SetParent(self)
	ramp:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ramp:Spawn()
	ramp:SetType("lfs_starfox_venom_fighter")
	ramp:SetRespawnTime(10)
	ramp:SetAmount(5)
	ramp:SetMasterSwitch(false)
	self:DeleteOnRemove(ramp)
	self.Ramp = ramp

	for i = 1,12 do
		SF.AddAI("Turret_" .. i,self,i)
	end
end

function ENT:OnRemove()

end

function ENT:PrimaryAttack(ai,pos)
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary(0)

	-- if ai && pos then
	-- 	self:FireTurret(ai,pos)
	-- else
		for i = 1, 12 do
			self:FireTurret(i,self:GetAI() && IsValid(self.LastTarget) && self.LastTarget:GetPos() +self.LastTarget:OBBCenter())
		end
	-- end
end

function ENT:FireTurret(num,targetPos)
	local hasAI = self:GetAI()
	local EyeAngles = !hasAI && self:GetDriverSeat():WorldToLocalAngles(self:GetDriver():EyeAngles()) or nil
	local startpos = self:GetAttachment(num).Pos
	local trace = util.TraceHull({
		start = startpos,
		endpos = targetPos or (startpos +EyeAngles:Forward() *50000),
		mins = Vector(-10,-10,-10),
		maxs = Vector(10,10,10),
		-- filter = self
	})

	if trace.Entity && trace.Entity == self then return end

	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= startpos
	bullet.Dir 		= (trace.HitPos -startpos):GetNormalized()
	bullet.Spread 	= Vector(0,0,0)
	bullet.Tracer	= 1
	bullet.TracerName = "lfs_sf_laser_venom"
	bullet.Force	= 100
	bullet.HullSize = 25
	bullet.Damage	= 5
	bullet.Attacker = self:GetDriver()
	bullet.AmmoType = "AR2"
	bullet.Callback = function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
		sound.Play("ambient/energy/zap7.wav", tr.HitPos, 65, 150, 1)
	end
	sound.Play("ambient/energy/weld1.wav",startpos,75,80,1)
	self:FireBullets(bullet)
	self:TakePrimaryAmmo()
end

function ENT:CreateAI()
	self.Ramp:SetMasterSwitch(true)
end

function ENT:RemoveAI()
	self.Ramp:SetMasterSwitch(false)
end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:IsEngineStartAllowed()
	local Driver = self:GetDriver()
	local Pod = self:GetDriverSeat()
	
	if self:GetAI() or not IsValid( Driver ) or not IsValid( Pod ) then return true end

	return true
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown(IN_ATTACK)
		end
	end

	-- if self:GetAI() then
	-- 	if IsValid(self.LastTarget) then
	-- 		Fire1 = true
	-- 	end
	-- end
	
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