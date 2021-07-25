--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 180)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()

end

function ENT:OnRemove()
	SafeRemoveEntity(self.Trail)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:EmitSound("LFS_SF_ARWING_PRIMARY")
	self:SetNextPrimary(0.25)

	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= self:GetAttachment(1).Pos
	bullet.Dir 		= self:LocalToWorldAngles(Angle(0,0,0)):Forward()
	bullet.Spread 	= Vector(0.01,0.01,0)
	bullet.Tracer	= 1
	bullet.TracerName = "lfs_laser_green"
	bullet.Force	= 100
	bullet.HullSize = 25
	bullet.Damage	= 30
	bullet.Attacker = self:GetDriver()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
		-- sound.Play("cpthazama/starfox/vehicles/laser_hit.wav", tr.HitPos, 110, 100, 1)
	end
	self:FireBullets(bullet)
	self:TakePrimaryAmmo()
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
		SafeRemoveEntity(self.Trail)
	elseif self.CanUseTrail && !IsValid(self.Trail) && RPM > MaxRPM *0.05 then
		local size = 1000
		self.Trail = util.SpriteTrail(self, 4, Color(192,153,255), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
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

function ENT:AIGetTarget()
	self.NextAICheck = self.NextAICheck or 0
	
	if self.NextAICheck > CurTime() then return self.LastTarget end
	
	self.NextAICheck = CurTime() + 2
	
	local MyPos = self:GetPos()
	local MyTeam = self:GetAITEAM()

	if MyTeam == 0 then self.LastTarget = NULL return NULL end

	local players = player.GetAll()

	local ClosestTarget = NULL
	local TargetDistance = 60000

	if not simfphys.LFS.IgnorePlayers then
		for _, v in pairs( players ) do
			if IsValid( v ) then
				if v:Alive() then
					local Dist = (v:GetPos() - MyPos):Length()
					if Dist < TargetDistance then
						local Plane = v:lfsGetPlane()
						
						if IsValid( Plane ) then
							if not Plane:IsDestroyed() and Plane ~= self then
								local HisTeam = Plane:GetAITEAM()
								if HisTeam ~= 0 then
									if HisTeam ~= MyTeam or HisTeam == 3 then
										ClosestTarget = v
										TargetDistance = Dist
									end
								end
							end
						else
							local HisTeam = v:lfsGetAITeam()
							-- if v:IsLineOfSightClear( self ) then
								if HisTeam ~= 0 then
									if HisTeam ~= MyTeam or HisTeam == 3 then
										ClosestTarget = v
										TargetDistance = Dist
									end
								end
							-- end
						end
					end
				end
			end
		end
	end

	if not simfphys.LFS.IgnoreNPCs then
		for _, v in pairs( self:AIGetNPCTargets() ) do
			if IsValid( v ) then
				local HisTeam = self:AIGetNPCRelationship( v:GetClass() )
				if HisTeam ~= "0" then
					if HisTeam ~= MyTeam or HisTeam == 3 then
						local Dist = (v:GetPos() - MyPos):Length()
						if Dist < TargetDistance then
							-- if self:CanSee( v ) then
								ClosestTarget = v
								TargetDistance = Dist
							-- end
						end
					end
				end
			end
		end
	end

	self.FoundPlanes = simfphys.LFS:PlanesGetAll()
	
	for _, v in pairs( self.FoundPlanes ) do
		if IsValid( v ) and v ~= self and v.LFS then
			local Dist = (v:GetPos() - MyPos):Length()
			
			if Dist < TargetDistance /*and self:AITargetInfront( v, 100 )*/ then
				if not v:IsDestroyed() and v.GetAITEAM then
					local HisTeam = v:GetAITEAM()
					if HisTeam ~= 0 then
						if HisTeam ~= self:GetAITEAM() or HisTeam == 3 then
							-- if self:CanSee( v ) then
								ClosestTarget = v
								TargetDistance = Dist
							-- end
						end
					end
				end
			end
		end
	end

	self.LastTarget = ClosestTarget
	
	return ClosestTarget
end