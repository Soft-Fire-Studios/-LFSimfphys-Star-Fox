--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr, ClassName)
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 50)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:ReloadWeapon()
	self:SetAmmoPrimary(self:GetMaxAmmoPrimary())

	self:OnReloadWeapon()
end

function ENT:RunOnSpawn()
	self:SetAmmoSecondary(0)
	if self.PilotCode then
		self:SetNW2Entity("Enemy",NULL)
		self:SetNW2String("VO",nil)
	end
	self:SetChargeT(0)
	self.CanChargeT = 0

	self.Charge = CreateSound(self,"cpthazama/starfox/vehicles/arwing_laser_charge.wav")
	self.Charge:SetSoundLevel(120)
end

function ENT:OnRemove()
	if self.Charge then
		self.Charge:Stop()
	end
	SafeRemoveEntity(self.Trail)
end

function ENT:PrimaryAttack(isCharged)
	if not self:CanPrimaryAttack() then return end
	isCharged = isCharged or (self:GetChargeT() -CurTime()) >= 6

	self:SetNextPrimary(isCharged && 1 or 0.1)
	
	if isCharged then
			SF.FireProjectile(self,"lfs_starfox_projectile",self:GetAttachment(7).Pos,true,function(ent)
				ent:SetLaser(true)
				ent:SetStartVelocity(self:GetVelocity():Length() +500)
			end,function(ent)
				ent.DMG = 200
				ent.DMGDist = 400
				if IsValid(ent:GetPhysicsObject()) then
					ent:GetPhysicsObject():SetVelocity(self:GetVelocity() +self:GetForward() *500)
				end
			end)

			self:TakePrimaryAmmo(10)

			self:SetChargeT(0)
			self.CanChargeT = CurTime() +2
	else
		local upgrade = SF.GetLaser(self,"lfs_laser_red")
		for i = 1,4 do
			self.MirrorPrimary = not self.MirrorPrimary
			
			local Mirror = i

			if upgrade.Level == 0 then
				if i > 1 then return end
				Mirror = 7
			elseif upgrade.Level == 1 then
				if i > 2 then return end
			end

			local target = self:GetAI() && SF.FindEnemy(self) -- This vehicle has Multi-Target capabilities
			local bullet = {}
			bullet.Num 		= 1
			bullet.Src 		= self:GetAttachment(Mirror).Pos
			bullet.Dir 		= IsValid(target) && (target:GetPos() -bullet.Src):Angle():Forward() or self:LocalToWorldAngles(Angle(0,0,0)):Forward()
			bullet.Spread 	= Vector(0.01,0.01,0)
			bullet.Tracer	= 1
			bullet.TracerName = upgrade.Effect
			bullet.Force	= 100
			bullet.HullSize = 25
			bullet.Damage	= 50 *upgrade.DMG
			bullet.Attacker = self:GetDriver()
			bullet.AmmoType = "Pistol"
			bullet.Callback = function(att,tr,dmginfo)
				dmginfo:SetDamageType(DMG_AIRBOAT)
				-- sound.Play("cpthazama/starfox/vehicles/laser_hit.wav", tr.HitPos, 110, 100, 1)
			end
			self:FireBullets(bullet)
			self:TakePrimaryAmmo()
			SF.PlaySound(3,bullet.Src,"LFS_SFEH_SHARPCLAW_FIRE",nil,nil,nil,true)
		end
	end
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	if self:GetAmmoSecondary() <= 0 then return end

	self:EmitSound("LFS_SF_APAROID_MISSILE")
	self:SetNextSecondary(1)

	SF.FireProjectile(self,"lfs_starfox_projectile",self:GetAttachment(5).Pos,false,nil,function(ent)
		ent.DMG = 500
		ent.DMGDist = 750
	end)

	self:TakeSecondaryAmmo()
end

function ENT:OnKeyThrottle(bPressed)

end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:OnKeyThrottle(bPressed)
	if bPressed && self.CanUseTrail && !IsValid(self.Trail) then
		self:EmitSound("LFS_SFEH_SOUL_UP")
	end
end

function ENT:HandleWeapons(Fire1, Fire2)
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()
	local AI = self:GetAI()

	SF.HoverMode(self)

	self:SetNW2Bool("VTOL",self:IsVtolModeActive())

	if self.PilotCode && AI then
		self:SetNW2Entity("Enemy",self:AIGetTarget())
		self:SetNW2Int("Team",self:GetAITEAM())
	end

	if RPM <= MaxRPM *0.05 then
		SafeRemoveEntity(self.Trail)
	elseif self.CanUseTrail && !IsValid(self.Trail) && RPM > MaxRPM *0.05 then
		local size = 1000
		self.Trail = util.SpriteTrail(self, 6, Color(192,153,255), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
	end
	local Driver = self:GetDriver()
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			if Driver:KeyDown(IN_ATTACK) then
				if CurTime() > self.CanChargeT then
					if self:GetChargeT() < CurTime() then self:SetChargeT(CurTime()) end
					self:SetChargeT(self:GetChargeT() +0.1)
					self.Charge:Play()
				end
			else
				self.Charge:Stop()
				self.CanChargeT = CurTime() +1
			end
			Fire1 = Driver:KeyReleased(IN_ATTACK)
		end
		Fire2 = Driver:KeyReleased(IN_ATTACK2)
	end
	
	if Fire1 then
		self:PrimaryAttack(AI && math.random(1,200) == 1)
	end
	
	if Fire2 then
		self:SecondaryAttack()
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
	SafeRemoveEntity(self.Trail)
end

function ENT:Destroy()
	SF.Destroy(self)
	SF.OnDestroyed(self,1)
end

function ENT:AIGetTarget()
	return SF.FindEnemy(self)
end