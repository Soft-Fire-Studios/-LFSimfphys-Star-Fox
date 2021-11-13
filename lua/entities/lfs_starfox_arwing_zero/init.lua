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
	-- if self.PilotCode then
	-- 	self:SetNW2Entity("Enemy",NULL)
	-- 	self:SetNW2String("VO",nil)
	-- end
	self:SetAmmoSecondary(0)
	self:SetChargeT(0)
	self.CanChargeT = 0

	self.Charge = CreateSound(self,"cpthazama/starfox/vehicles/arwing_laser_charge.wav")
	self.Charge:SetSoundLevel(120)
end

function ENT:OnRemove()
	if self.Charge then
		self.Charge:Stop()
	end
	SafeRemoveEntity(self.Trail1)
end

function ENT:PrimaryAttack(isCharged)
	if not self:CanPrimaryAttack() then return end
	hasFinishedCharging = self:GetAI() or (self:GetChargeT() -CurTime()) >= 6
	if isCharged && !hasFinishedCharging then return end

	self:EmitSound((isCharged && hasFinishedCharging) && "LFS_SF_ARWING_PRIMARY_CHARGED" or "LFS_SF_ARWING_PRIMARY")
	self:SetNextPrimary((isCharged && hasFinishedCharging) && 1 or 0.2)
	
	if (isCharged && hasFinishedCharging) then
			SF.FireProjectile(self,"lfs_starfox_projectile",self:GetAttachment(1).Pos,true,function(ent)
				ent:SetLaser(true)
				ent:SetStartVelocity(self:GetVelocity():Length() +500)
				ent:SetSpriteColor(Vector(65,255,65))
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
		local upgrade = SF.GetLaser(self,"lfs_sf_laser_green","lfs_sf_laser_green","lfs_sf_laser_blue")
		if upgrade.Level > 0 then
			self:SetNextPrimary(0.12)
			for i = 1,2 do
				local target = self:GetAI() && SF.FindEnemy(self) -- This vehicle has Multi-Target capabilities
				local bullet = {}
				bullet.Num 		= 1
				bullet.Src 		= self:GetAttachment(i +1).Pos
				bullet.Dir 		= IsValid(target) && (target:GetPos() -bullet.Src):Angle():Forward() or self:LocalToWorldAngles(Angle(0,0,0)):Forward()
				bullet.Spread 	= Vector(0.01,0.01,0)
				bullet.Tracer	= 1
				bullet.TracerName = upgrade.Effect
				bullet.Force	= 100
				bullet.HullSize = 25
				bullet.Damage	= 25 *upgrade.DMG
				bullet.Attacker = self:GetDriver()
				bullet.AmmoType = "Pistol"
				bullet.Callback = function(att,tr,dmginfo)
					dmginfo:SetDamageType(DMG_AIRBOAT)
				end
				self:FireBullets(bullet)
				SF.PlaySound(3,bullet.Src,"LFS_SF_ARWING_PRIMARY_DOUBLE",nil,nil,nil,true)
			end
		else
			local target = self:GetAI() && SF.FindEnemy(self) -- This vehicle has Multi-Target capabilities
			local bullet = {}
			bullet.Num 		= 1
			bullet.Src 		= self:GetAttachment(1).Pos
			bullet.Dir 		= IsValid(target) && (target:GetPos() -bullet.Src):Angle():Forward() or self:LocalToWorldAngles(Angle(0,0,0)):Forward()
			bullet.Spread 	= Vector(0.01,0.01,0)
			bullet.Tracer	= 1
			bullet.TracerName = upgrade.Effect
			bullet.Force	= 100
			bullet.HullSize = 25
			bullet.Damage	= 25 *upgrade.DMG
			bullet.Attacker = self:GetDriver()
			bullet.AmmoType = "Pistol"
			bullet.Callback = function(att,tr,dmginfo)
				dmginfo:SetDamageType(DMG_AIRBOAT)
			end
			self:FireBullets(bullet)
			SF.PlaySound(3,bullet.Src,"LFS_SF_ARWING_PRIMARY",nil,nil,nil,true)
		end
		self:TakePrimaryAmmo()
	end
end

function ENT:OnKeyThrottle( bPressed )

end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:GetLightColor()
	local col = self.ColorLast
	return Color(col.x,col.y,col.z)
end

function ENT:HandleWeapons(Fire1, Fire2)
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()
	local skin = self:GetSkin()

	self:SetBodygroup(1,self:GetHP() <= self:GetMaxHP() *0.4 && 1 or 0)

	local col = skin == 0 && Vector(78,210,250) or Vector(179,77,238)
	self.ColorLast = self.ColorLast or col
	local throttle = self:GetThrottlePercent()
	if throttle > 80 && throttle < 100 then
		self.ColorLast = LerpVector(FrameTime() *5,self.ColorLast,Vector(255,189,47))
	elseif throttle > 100 then
		self.ColorLast = LerpVector(FrameTime() *5,self.ColorLast,Vector(255,0,0))
	else
		self.ColorLast = LerpVector(FrameTime() *5,self.ColorLast,col)
	end
	self:SetNW2Vector("LightColor",self.ColorLast)
	if IsValid(self.Trail1) then
		local lColor = self:GetLightColor()
		local color = lColor.r .. " " .. lColor.g .. " " .. lColor.b
		self.Trail1:SetKeyValue("rendercolor",color)
	end

	-- if self.PilotCode && self:GetAI() then
	-- 	self:SetNW2Entity("Enemy",self:AIGetTarget())
	-- 	self:SetNW2Int("Team",self:GetAITEAM())
	-- end

	if RPM <= MaxRPM *0.05 then
		SafeRemoveEntity(self.Trail1)
	elseif self.CanUseTrail && !IsValid(self.Trail1) && RPM > MaxRPM *0.05 then
		local size = 400
		self.Trail1 = util.SpriteTrail(self, 5, self:GetLightColor(), false, size, 0, 0.25, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
	end
	local Driver = self:GetDriver()
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			-- Fire1 = Driver:KeyReleased(IN_ATTACK)
			if Driver:KeyDown(IN_ATTACK2) then
				if CurTime() > self.CanChargeT then
					if self:GetChargeT() < CurTime() then self:SetChargeT(CurTime()) end
					self:SetChargeT(self:GetChargeT() +0.1)
					self.Charge:Play()
				end
			else
				self.Charge:Stop()
				self.CanChargeT = CurTime() +1
			end
			Fire1 = Driver:KeyDown(IN_ATTACK)
			Fire2 = Driver:KeyReleased(IN_ATTACK2)
		end
	end
	
	if Fire2 then
		self:PrimaryAttack(true)
		return
	end
	if Fire1 then
		self:PrimaryAttack(false)
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
end

function ENT:Destroy()
	SF.Destroy(self)
	SF.OnDestroyed(self,1)
end

function ENT:AIGetTarget()
	return SF.FindEnemy(self)
end