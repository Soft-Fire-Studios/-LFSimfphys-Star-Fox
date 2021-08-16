--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 100)
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
	self:SetChargeT(0)
	self.CanChargeT = 0

	self.Charge = CreateSound(self,"cpthazama/starfox/vehicles/arwing_laser_charge.wav")
	self.Charge:SetSoundLevel(120)

	-- if FrameTime() > 0.067 then
	-- 	self.ElevatorPos = Vector(-200,0,54.62)
	-- 	self.RudderPos = Vector(-200,0,54.62)
	-- end
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

	self:EmitSound(isCharged && "LFS_SF_ARWING_PRIMARY_CHARGED" or "LFS_SF_ARWING_PRIMARY")
	self:SetNextPrimary(isCharged && 1 or 0.15)
	
	if isCharged then
			SF.FireProjectile(self,"lfs_starfox_projectile",self:GetAttachment(5).Pos,true,function(ent)
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
		local upgrade = SF.GetLaser(self,"lfs_laser_green")
		for i = 0,1 do
			self.MirrorPrimary = not self.MirrorPrimary
			
			local Mirror = self.MirrorPrimary and 2 or 1

			if upgrade.Level == 0 then
				if i == 1 then return end
				Mirror = 5
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
			bullet.Damage	= 40 *upgrade.DMG
			bullet.Attacker = self:GetDriver()
			bullet.AmmoType = "Pistol"
			bullet.Callback = function(att,tr,dmginfo)
				dmginfo:SetDamageType(DMG_AIRBOAT)
				-- sound.Play("cpthazama/starfox/vehicles/laser_hit.wav", tr.HitPos, 110, 100, 1)
			end
			self:FireBullets(bullet)
			self:TakePrimaryAmmo()
			SF.PlaySound(3,bullet.Src,upgrade.Level > 0 && "LFS_SF_ARWING_PRIMARY_DOUBLE" or "LFS_SF_ARWING_PRIMARY",nil,nil,nil,true)
		end
	end
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	if self:GetAmmoSecondary() <= 0 then return end

	self:EmitSound("LFS_SF_APAROID_MISSILE")
	self:SetNextSecondary(1)

	SF.FireProjectile(self,"lfs_starfox_projectile",self:GetAttachment(3).Pos,false,nil,function(ent)
		ent.DMG = 500
		ent.DMGDist = 750
	end)

	self:TakeSecondaryAmmo()
end

function ENT:OnKeyThrottle( bPressed )
	-- if bPressed && self.CanUseTrail && !IsValid(self.Trail) && self:GetRPM() > self:GetMaxRPM() *0.05 then
	-- 	local size = 1000
	-- 	self.Trail = util.SpriteTrail(self, 4, Color(192,153,255), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
	-- else
	-- 	if (self:GetRPM() + 1) > self:GetMaxRPM() then
	-- 		SafeRemoveEntity(self.Trail)
	-- 	end
	-- end
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:HandleWeapons(Fire1, Fire2)
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()

	self:SetNW2Bool("VTOL",self:IsVtolModeActive())

	if RPM <= MaxRPM *0.05 then
		SafeRemoveEntity(self.Trail)
	elseif self.CanUseTrail && !IsValid(self.Trail) && RPM > MaxRPM *0.05 then
		local size = 1000
		self.Trail = util.SpriteTrail(self, 4, Color(192,153,255), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
	end
	local Driver = self:GetDriver()
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			-- Fire1 = Driver:KeyDown( IN_ATTACK )
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
		self:PrimaryAttack()
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