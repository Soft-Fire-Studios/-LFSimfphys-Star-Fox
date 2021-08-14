--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

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

function ENT:RunOnSpawn()
	self:SetSkin(math.random(0,2))
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Trail)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary(0.25)

	local upgrade = SF.GetLaser(self,"lfs_laser_red")
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= self:GetAttachment(1).Pos
	bullet.Dir 		= self:LocalToWorldAngles(Angle(0,0,0)):Forward()
	bullet.Spread 	= Vector(0.01,0.01,0)
	bullet.Tracer	= 1
	bullet.TracerName = upgrade.Effect
	bullet.Force	= 100
	bullet.HullSize = 25
	bullet.Damage	= 30 *upgrade.DMG
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

	local startpos = self:GetRotorPos()
	local Pod = self:GetDriverSeat()
	if IsValid(Pod) then
		local Driver = Pod:GetDriver()
		local EyeAngles = IsValid(Driver) && Pod:WorldToLocalAngles(Driver:EyeAngles()) or self:GetAngles()
		local TracePlane = util.TraceHull( {
			start = startpos,
			endpos = (startpos +EyeAngles:Forward() * 50000),
			mins = Vector( -10, -10, -10 ),
			maxs = Vector( 10, 10, 10 ),
			filter = function( ent ) 
				if IsValid( ent ) then
					if ent == self then
						return false
					end
				end
				return true
			end
		})

		local aimAngles = self:WorldToLocalAngles((TracePlane.HitPos -self:GetAttachment(1).Pos):GetNormalized():Angle())
		self:SetPoseParameter("aim_pitch",aimAngles.p)
		self:SetPoseParameter("aim_yaw",aimAngles.y)
	end

	if RPM <= MaxRPM *0.05 then
		SafeRemoveEntity(self.Trail)
	elseif self.CanUseTrail && !IsValid(self.Trail) && RPM > MaxRPM *0.05 then
		local size = 1000
		self.Trail = util.SpriteTrail(self, 2, Color(240,38,31), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
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
	SafeRemoveEntity(self.Trail)
end

function ENT:Destroy()
	self.Destroyed = true
	
	local PObj = self:GetPhysicsObject()
	if IsValid( PObj ) then
		PObj:SetDragCoefficient( -20 )
	end

	local ai = self:GetAI()
	if !ai then return end

	local attacker = self.FinalAttacker or Entity(0)
	local inflictor = self.FinalInflictor or Entity(0)
	if attacker:IsPlayer() then attacker:AddFrags(1) end
	gamemode.Call("OnNPCKilled",self,attacker,inflictor)
end