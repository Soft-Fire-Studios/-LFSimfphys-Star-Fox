AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:RunOnSpawn()
	self:SetBodygroup(1,1)
	if self.PilotCode then
		self:SetNW2Entity("Enemy",NULL)
		self:SetNW2String("VO",nil)
	end
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:OnSetPilot(pilot)
	self:SetBodygroup(2,pilot == "Andrew (Zero)" && 1 or pilot == "Leon (Zero)" && 2 or pilot == "Pigma (Zero)" && 3 or pilot == "Wolf (Zero)" && 4 or 0)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self:GetLightningTornado() then return end

	self:SetNextPrimary(self:GetLightningBlaster() && 0.065 or 0.11)

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
		bullet.Damage	= (self:GetLightningBlaster() && 60 or 40) *upgrade.DMG
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

function ENT:SecondaryAttack(aType)
	aType = aType or math.random(1,4)
	local didAttack = false
	if aType == 1 then
		if CurTime() < self:GetLightningBlasterTime() or self:GetLightningBlaster() then return end
		self:SetLightningBlaster(true)
		self:SetLightningBlasterTime(CurTime() +math.Rand(15,30))

		SF.DoVO(self,"cpthazama/starfox/vo/wolf_zero/lightning_blaster.wav",100,true)

		timer.Simple(5,function()
			if IsValid(self) then
				self:SetLightningBlaster(false)
			end
		end)

		didAttack = true
	elseif aType == 2 then
		if CurTime() < self:GetLightningTornadoTime() or self:GetLightningTornado() then return end
		self:SetLightningTornado(true)
		self:SetLightningTornadoTime(CurTime() +math.Rand(15,30))

		SF.DoVO(self,"cpthazama/starfox/vo/wolf_zero/lightning_tornado.wav",100,true)

		timer.Simple(10,function()
			if IsValid(self) && self:GetLightningTornado() then
				self:SetLightningTornado(false)
			end
		end)

		didAttack = true
	elseif aType == 3 then
		if CurTime() < self:GetOrbitalWolfTime() or self:GetOrbitalWolf() then return end
		self:SetOrbitalWolf(true)
		self:SetOrbitalWolfTime(CurTime() +math.Rand(15,30))

		SF.DoVO(self,"cpthazama/starfox/vo/wolf_zero/orbital_wolf.wav",100,true)

		for i = 1,3 do
			timer.Simple(i *0.8,function()
				if IsValid(self) && self:GetOrbitalWolf() then
					local AI = self:GetAI()
					local enemy = AI && SF.FindEnemy(self)
					if !AI then
						local startpos = self:GetRotorPos()
						local tr = util.TraceHull({
							start = startpos,
							endpos = (startpos +self:GetForward() *50000),
							mins = Vector(-80,-80,-80),
							maxs = Vector(80,80,80),
							filter = function(e)
								local collide = e != self
								return collide
							end
						})
						enemy = tr.Entity
					end
					if AI && !IsValid(enemy) then return end
					VJ_EmitSound(self,"cpthazama/starfox/eh/w_gyroblast1.wav",100)
					SF.FireProjectile(self,"lfs_starfox_projectile",self:GetAttachment(3).Pos,true,function(ent)
						ent:SetLaser(true)
						ent:SetStartVelocity(self:GetVelocity():Length() +800)
					end,function(ent)
						ent.DMG = 200
						ent.DMGDist = 400
						if IsValid(ent:GetPhysicsObject()) then
							ent:GetPhysicsObject():SetVelocity(self:GetVelocity() +self:GetForward() *800)
						end
						ent:SetLockOn(enemy)
					end)
				end
			end)
		end

		timer.Simple(3,function()
			if IsValid(self) then
				self:SetOrbitalWolf(false)
			end
		end)

		didAttack = true
	elseif aType == 4 then
		if CurTime() < self:GetShadowEdgeTime() or self:GetShadowEdge() then return end
		self:SetShadowEdge(true)
		self:SetShadowEdgeTime(CurTime() +math.Rand(15,30))

		SF.DoVO(self,"cpthazama/starfox/vo/wolf_zero/shadow_edge.wav",100,true)

		timer.Simple(10,function()
			if IsValid(self) then
				self:SetShadowEdge(false)
			end
		end)

		didAttack = true
	end

	if didAttack then
		self:SetSpecialAttackTime(CurTime() +math.Rand(10,20))
	end
end

ENT.SpecialAttackMode = 1
ENT.SpecialAttackModeT = 0
function ENT:HandleWeapons(Fire1, Fire2)
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()
	local Jump = false

	self:SetInvincible(self:GetLightningTornado())

	if self.PilotCode && self:GetAI() then
		self:SetNW2Entity("Enemy",SF.FindEnemy(self))
		self:SetNW2Int("Team",self:GetAITEAM())
	end

	if RPM <= MaxRPM *0.05 then
		SafeRemoveEntity(self.Trail1)
		SafeRemoveEntity(self.Trail2)
	elseif self.CanUseTrail && !IsValid(self.Trail1) && !IsValid(self.Trail2) && RPM > MaxRPM *0.05 then
		local size = 400
		self.Trail1 = util.SpriteTrail(self, 4, Color(113,200,116), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
		self.Trail2 = util.SpriteTrail(self, 5, Color(113,200,116), false, size, 0, 3, 1 /(10 +1) *0.5, "VJ_Base/sprites/vj_trial1.vmt")
	end
	local Driver = self:GetDriver()
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown(IN_ATTACK)
		end
		Fire2 = Driver:KeyDown(IN_ATTACK2)
		Jump = Driver:KeyDown(IN_JUMP)
	end

	if self:GetLightningTornado() then
		local Target = SF.FindEnemy(self)
		if IsValid(Target) then
			if Target:IsPlayer() && IsValid(Target:lfsGetPlane()) then
				Target = Target:lfsGetPlane()
			end
			local TargetPos = Target:GetPos()
			if self:GetPos():Distance(TargetPos) <= 900 then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(300)
				dmginfo:SetDamageType(bit.bor(DMG_CRUSH,DMG_VEHICLE,DMG_DISSOLVE))
				dmginfo:SetAttacker(self)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageForce(self:GetVelocity() *1.2)
				Target:TakeDamageInfo(dmginfo)
				self:SetLightningTornado(false)
			end
		end
	elseif self:GetShadowEdge() then
		SafeRemoveEntity(self.Trail1)
		SafeRemoveEntity(self.Trail2)
		for _,v in pairs(simfphys.LFS:PlanesGetAll()) do
			if v != self && v:GetAI() then
				local Target = SF.FindEnemy(v)
				if Target == self or Target == self:GetDriver() then
					if v:CanPrimaryAttack() then
						v:SetNextPrimary(1)
					end
					if v:CanSecondaryAttack() then
						v:SetNextSecondary(1)
					end
				end
			end
		end
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	
	if Jump && CurTime() > self.SpecialAttackModeT then
		self.SpecialAttackMode = self.SpecialAttackMode +1
		if self.SpecialAttackMode > 4 then
			self.SpecialAttackMode = 1
		end
		if IsValid(Driver) then
			local trans = {[1]="Lightning Blaster",[2]="Lightning Tornado",[3]="Orbital Wolf",[4]="Shadow Edge"}
			Driver:ChatPrint("Changed Special Attack to " .. trans[self.SpecialAttackMode] .. "!")
		end
		self.SpecialAttackModeT = CurTime() +1
	end
	
	if Fire2 then
		if CurTime() > self:GetSpecialAttackTime() then
			self:SecondaryAttack(!self:GetAI() && self.SpecialAttackMode)
		end
	end
end

function ENT:RunAI()
	local RangerLength = 15000
	local mySpeed = self:GetVelocity():Length()
	local MinDist = 600 + mySpeed * 2
	local StartPos = self:GetPos()

	local TraceFilter = {self,self.wheel_L,self.wheel_R,self.wheel_C}

	local FrontLeft = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(0,20,0) ):Forward() * RangerLength } )
	local FrontRight = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(0,-20,0) ):Forward() * RangerLength } )

	local FrontLeft2 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(25,65,0) ):Forward() * RangerLength } )
	local FrontRight2 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(25,-65,0) ):Forward() * RangerLength } )

	local FrontLeft3 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(-25,65,0) ):Forward() * RangerLength } )
	local FrontRight3 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(-25,-65,0) ):Forward() * RangerLength } )

	local FrontUp = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(-20,0,0) ):Forward() * RangerLength } )
	local FrontDown = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(20,0,0) ):Forward() * RangerLength } )

	local Up = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:GetUp() * RangerLength } )
	local Down = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - self:GetUp() * RangerLength } )

	local Down2 = util.TraceLine( { start = self:LocalToWorld( Vector(0,0,100) ), filter = TraceFilter, endpos = StartPos + Vector(0,0,-RangerLength) } )

	local cAvoid = Vector(0,0,0)
	if !self:GetLightningTornado() then
		if istable( self.FoundPlanes ) then
			local myRadius = self:BoundingRadius() 
			local myPos = self:GetPos()
			local myDir = self:GetForward()
			for _, v in pairs( self.FoundPlanes ) do
				if IsValid( v ) and v ~= self and v.LFS then
					local theirRadius = v:BoundingRadius() 
					local Sub = (myPos - v:GetPos())
					local Dir = Sub:GetNormalized()
					local Dist = Sub:Length()
					
					if Dist < (theirRadius + myRadius + 200) then
						if math.deg( math.acos( math.Clamp( myDir:Dot( -Dir ) ,-1,1) ) ) < 90 then
							cAvoid = cAvoid + Dir * (theirRadius + myRadius + 500)
						end
					end
				end
			end
		end
	end

	local FLp = FrontLeft.HitPos + FrontLeft.HitNormal * MinDist + cAvoid * 8
	local FRp = FrontRight.HitPos + FrontRight.HitNormal * MinDist + cAvoid * 8

	local FL2p = FrontLeft2.HitPos + FrontLeft2.HitNormal * MinDist
	local FR2p = FrontRight2.HitPos + FrontRight2.HitNormal * MinDist

	local FL3p = FrontLeft3.HitPos + FrontLeft3.HitNormal * MinDist
	local FR3p = FrontRight3.HitPos + FrontRight3.HitNormal * MinDist

	local FUp = FrontUp.HitPos + FrontUp.HitNormal * MinDist
	local FDp = FrontDown.HitPos + FrontDown.HitNormal * MinDist

	local Up = Up.HitPos + Up.HitNormal * MinDist
	local Dp = Down.HitPos + Down.HitNormal * MinDist

	local TargetPos = (FLp+FRp+FL2p+FR2p+FL3p+FR3p+FUp+FDp+Up+Dp) / 10

	local alt = (self:GetPos() - Down2.HitPos):Length()

	if !self:GetLightningTornado() then
		if alt < MinDist then 
			self.TargetRPM = self:GetMaxRPM()
			
			if self:GetStability() < 0.4 then
				self.TargetRPM = self:GetLimitRPM()
				TargetPos.z = self:GetPos().z + 2000
			end
			
			if self.LandingGearUp and mySpeed < 100 and not self:IsPlayerHolding() then
				local pObj = self:GetPhysicsObject()
				if IsValid( pObj ) then
					if pObj:IsMotionEnabled() then
						self:Explode()
					end
				end
			end
		else
			if self:GetStability() < 0.3 then
				self.TargetRPM = self:GetLimitRPM()
				TargetPos.z = self:GetPos().z + 600
			else
				if alt > mySpeed then
					local Target = SF.FindEnemy(self)
					if IsValid( Target ) then
						if self:AITargetInfront( Target, 65 ) then
							TargetPos = Target:GetPos() + cAvoid * 8 + Target:GetVelocity() * math.abs(math.cos( CurTime() * 150 ) ) * 3
							
							local Throttle = (self:GetPos() - TargetPos):Length() / 8000 * self:GetMaxRPM()
							self.TargetRPM = math.Clamp( Throttle,self:GetIdleRPM(),self:GetMaxRPM())
							
							local startpos =  self:GetRotorPos()
							local tr = util.TraceHull( {
								start = startpos,
								endpos = (startpos + self:GetForward() * 50000),
								mins = Vector( -30, -30, -30 ),
								maxs = Vector( 30, 30, 30 ),
								filter = TraceFilter
							} )
						
							local CanShoot = (IsValid( tr.Entity ) and tr.Entity.LFS and tr.Entity.GetAITEAM) and (tr.Entity:GetAITEAM() ~= self:GetAITEAM() or tr.Entity:GetAITEAM() == 0) or true
						
							if CanShoot then
								if self:AITargetInfront( Target, 15 ) then
									self:HandleWeapons( true )
									
									if self:AITargetInfront( Target, 10 ) then
										self:HandleWeapons( true, true )
									end
								end
							end
						else
							if alt > 6000 and self:AITargetInfront( Target, 90 ) then
								TargetPos = Target:GetPos()
							else
								TargetPos = TargetPos
							end
							
							self.TargetRPM = self:GetMaxRPM()
						end
					else
						self.TargetRPM = self:GetMaxRPM()
					end
				else
					self.TargetRPM = self:GetMaxRPM()
					TargetPos.z = self:GetPos().z + 2000
				end
			end
			self:RaiseLandingGear()
		end
	else
		local Target = SF.FindEnemy(self)
		if IsValid(Target) then
			self.TargetRPM = self:GetMaxRPM()
			TargetPos = Target:GetPos() +cAvoid *8 +Target:GetVelocity() *math.abs(math.cos(CurTime() *150)) *3
		end
	end

	if self:IsDestroyed() or not self:GetEngineActive() then
		self.TargetRPM = 0
	end

	self.smTargetPos = self.smTargetPos and self.smTargetPos + (TargetPos - self.smTargetPos) * FrameTime() or self:GetPos()

	local TargetAng = (self.smTargetPos - self:GetPos()):GetNormalized():Angle()

	return TargetAng
end