--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 60)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnSetPilot(pilot)
	-- self:SetBodygroup(2,pilot == "Andrew" && 1 or pilot == "Leon" && 2 or pilot == "Pigma" && 3 or pilot == "Wolf" && 4 or 0)
end

function ENT:OnRemovePilot(pilot)
	-- self:SetBodygroup(2,0)
end

function ENT:RunOnSpawn()
	-- self:SetBodygroup(1,1)
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

	self:SetNextPrimary(0.1)
	-- self:SetNextPrimary(0.15)

	local upgrade = SF.GetLaser(self,"lfs_laser_red")

	local target = self:GetAI() && SF.FindEnemy(self) -- This vehicle has Multi-Target capabilities
	for i = 1,2 do		
		local bullet = {}
		bullet.Num 		= 1
		bullet.Src 		= self:GetAttachment(i).Pos
		bullet.Dir 		= IsValid(target) && (target:GetPos() -bullet.Src):Angle():Forward() or self:LocalToWorldAngles(Angle(0,0,0)):Forward()
		bullet.Spread 	= Vector(0.01,0.01,0)
		bullet.Tracer	= 1
		bullet.TracerName = upgrade.Effect
		bullet.Force	= 100
		bullet.HullSize = 25
		bullet.Damage	= 75 *upgrade.DMG
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

function ENT:OnKeyThrottle( bPressed )

end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:HandleWeapons(Fire1, Fire2)
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()

	for _,v in pairs(ents.FindInSphere(self:GetPos(), 2000)) do
		if v:GetClass() == "lunasflightschool_missile" then
			v.Explode = true
		end
	end

	if self.PilotCode && self:GetAI() then
		self:SetNW2Entity("Enemy",self:AIGetTarget())
		self:SetNW2Int("Team",self:GetAITEAM())
	end

	if RPM <= MaxRPM *0.05 then
		SafeRemoveEntity(self.Trail1)
		SafeRemoveEntity(self.Trail2)
	elseif self.CanUseTrail && !IsValid(self.Trail1) && !IsValid(self.Trail2) && RPM > MaxRPM *0.05 then
		local size = 800
		self.Trail1 = util.SpriteTrail(self, 3, Color(113,200,116), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
		self.Trail2 = util.SpriteTrail(self, 4, Color(113,200,116), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
	end
	local Driver = self:GetDriver()
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			-- Fire1 = Driver:KeyReleased(IN_ATTACK)
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

	self.CanUseTrail = true
end

function ENT:OnEngineStopped()
	self:EmitSound("cpthazama/starfox/vehicles/arwing_power_down.wav")

	self.CanUseTrail = false
	SafeRemoveEntity(self.Trail1)
	SafeRemoveEntity(self.Trail2)
end

function ENT:Destroy()
	SF.Destroy(self)
	SF.OnDestroyed(self,1)
end

function ENT:AIGetTarget()
	return SF.FindEnemy(self)
end