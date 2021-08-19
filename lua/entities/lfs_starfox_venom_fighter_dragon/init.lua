--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

ENT.Mirror = 1

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Trail1)
	SafeRemoveEntity(self.Trail2)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary(0.2)

	local upgrade = SF.GetLaser(self,"lfs_sf_laser_red")

	self.Mirror = self.Mirror == 1 && 2 or 1
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= self:GetAttachment(self.Mirror).Pos
	bullet.Dir 		= self:LocalToWorldAngles(Angle(0,0,0)):Forward()
	bullet.Spread 	= Vector(0.01,0.01,0)
	bullet.Tracer	= 1
	bullet.TracerName = upgrade.Effect
	bullet.Force	= 100
	bullet.HullSize = 25
	bullet.Damage	= 20 *upgrade.DMG
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

	if RPM <= MaxRPM *0.05 then
		SafeRemoveEntity(self.Trail1)
		SafeRemoveEntity(self.Trail2)
	elseif self.CanUseTrail && !IsValid(self.Trail1) && !IsValid(self.Trail2) && RPM > MaxRPM *0.05 then
		local size = 400
		self.Trail1 = util.SpriteTrail(self, 3, Color(240,38,31), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
		self.Trail2 = util.SpriteTrail(self, 4, Color(240,38,31), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
	end
	local Driver = self:GetDriver()
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyReleased(IN_ATTACK)
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
	SF.OnDestroyed(self,15)
end

function ENT:AIGetTarget()
	return SF.FindEnemy(self)
end

ENT.ShieldEffect = "lfs_sf_shield_corneria"
function ENT:OnTakeDamage(dmginfo)
	SF.OnTakeDamage(self,dmginfo)
end