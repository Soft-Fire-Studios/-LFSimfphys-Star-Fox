print("Loading [LFSimfphys] Star Fox Functions file...")

SF = {}
SF.CachedSounds = {}
SF.AITurrets = {}

//https://wiki.facepunch.com/gmod/PhysObj:AddAngleVelocity

SF.GetLaser = function(ent,tr)
	if !IsValid(ent) then return end
	local time = ent:GetNW2Int("LaserUpgradeTime") or 0
	local upgrade = ent:GetNW2Int("LaserUpgrade") or 0
	if CurTime() > time then
		upgrade = 0
	end
	local tbl = {}
	tbl.DMG = upgrade == 2 && 2 or upgrade == 1 && 1.5 or 1
	tbl.Effect = upgrade == 2 && (tr == "lfs_laser_red" && "lfs_sf_laser_purple" or "lfs_laser_red_large") or upgrade == 1 && "lfs_laser_blue" or tr
	tbl.Level = upgrade
	tbl.Time = time -CurTime()

	return tbl
end

SF.SetSmartBombs = function(ent,i)
	if !IsValid(ent) then return end
	ent:SetNW2Int("SmartBombs",i)
end

SF.GetSmartBombs = function(ent)
	if !IsValid(ent) then return end
	local count = ent:GetNW2Int("SmartBombs") or 0
	return count
end

SF.BoneData = function(ent,bone)
	local pos,ang = ent:GetBonePosition(bone)
	local tbl = {}
	tbl.Pos = pos
	tbl.Ang = ang

	return tbl
end

SF.GetVOLine = function(ent,VO)
	if !IsValid(ent) then return end
	local VO = VO or ent:GetNW2String("VO")
	return ent.VO_DeathSound == true && ent.LinesDeath[VO] or ent.Lines[VO]
end

SF.PlayVO = function(ply,snd,VO)
	local snd = VJ_PICK(snd)
	if !snd then return end
	local snddur = SoundDuration(snd) +1
	ply.SF_TalkT = CurTime() +snddur
	ply.SF_NextTalkT = ply.SF_TalkT +0.2
	ply.SF_CurrentSound = snd
	ply.SF_CurrentVO = VO
	ply.SF_TalkTexture = Material("hud/starfox/vo_" .. VO .. ".vtf")

	ply:EmitSound("cpthazama/starfox/64/RadioTransmissionon.wav",110,100,1)
	ply:EmitSound(snd,110,100,1)
	timer.Simple(snddur -0.025,function()
		if IsValid(ply) && ply.SF_CurrentSound == snd then
			ply:EmitSound("cpthazama/starfox/64/RadioTransmissionOff.wav",110,100,1)
		end
	end)
	return snddur
end

SF.PlaySound = function(sndType,ent,snd,vol,pit,delay,cache)
	delay = delay or 0
	vol = vol or 75
	if cache then
		for _,v in pairs(SF.CachedSounds) do
			if v.Name == snd then
				snd = v.Sound
				vol = v.Level
				break
			end
		end
	end
	timer.Simple(delay,function()
		pit = (pit or 100) *VJ_GetVarInt("host_timescale")
		if sndType == 1 && IsValid(ent) then
			return VJ_CreateSound(ent,snd,vol,pit)
		elseif sndType == 2 && IsValid(ent) then
			return VJ_EmitSound(ent,snd,vol,pit)
		elseif sndType == 3 then
			sound.Play(VJ_PICK(snd),type(ent) == "Vector" && ent or (IsValid(ent) && ent:GetPos()) or VJ_Vec0,vol,pit,1)
		end
	end)
end

SF.AddSound = function(name,snd,lvl,chan)
	sound.Add({
		name = name,
		channel = chan or CHAN_STATIC,
		volume = 1.0,
		level = lvl or 75,
		sound = snd
	})
	table.insert(SF.CachedSounds,{Name=name,Sound=snd,Level=lvl})
	print("Successfully added sound '" .. name .. "'!")
end

SF.AddSound("LFS_SF_ARWING_ENGINE","cpthazama/starfox/vehicles/arwing_eng_boost_loop.wav",125)
SF.AddSound("LFS_SF_ARWING_ENGINE2","cpthazama/starfox/vehicles/arwing_eng.wav",90)
SF.AddSound("LFS_SF_ARWING_BOOST","cpthazama/starfox/vehicles/arwing_eng_boost_short.wav",125)
SF.AddSound("LFS_SF_ARWING_PRIMARY","cpthazama/starfox/vehicles/arwing_laser_single_hit.wav",95,CHAN_WEAPON)
SF.AddSound("LFS_SF_ARWING_PRIMARY_CHARGED","cpthazama/starfox/vehicles/arwing_fire_charged.wav",95,CHAN_WEAPON)
SF.AddSound("LFS_SF_ARWING_PRIMARY_DOUBLE","cpthazama/starfox/vehicles/arwing_laser_double.wav",95,CHAN_WEAPON)

SF.AddSound("LFS_SF_WOLFEN_ENGINE","cpthazama/starfox/vehicles/arwing_loop_hover.wav",125)
SF.AddSound("LFS_SF_WOLFEN_ENGINE2","cpthazama/starfox/vehicles/wolfen_loop.wav",90)
SF.AddSound("LFS_SF_WOLFEN_BOOST","cpthazama/starfox/vehicles/wolfen_boost2_a.wav",125)
SF.AddSound("LFS_SF_WOLFEN_BOOST2","cpthazama/starfox/vehicles/wolfen_boost.wav",90)

SF.AddSound("LFS_SF_APAROID_MISSILE","cpthazama/starfox/vehicles/se_apa-0003_06.wav",90)

SF.AddSound("LFS_SF_GENERIC_ENGINE","cpthazama/starfox/vehicles/generic_loop.wav",125)
SF.AddSound("LFS_SF_GENERIC_EXPLOSION","cpthazama/starfox/vehicles/laser_hit.wav",125)
SF.AddSound("LFS_SF_GENERIC_EXPLOSION7","cpthazama/starfox/64/Explosion7.wav",125)

SF.AddSound("LFS_SF64_ARWING_ENGINE","cpthazama/starfox/64/vehicles/Engine.wav",125)
SF.AddSound("LFS_SF64_ARWING_BOOST","cpthazama/starfox/64/vehicles/Boost.wav",125)
SF.AddSound("LFS_SF64_ARWING_NITRO","cpthazama/starfox/64/vehicles/ArwingINtro.wav",125)

SF.AddSound("LFS_SF64_WOLFEN_ENGINE","cpthazama/starfox/64/vehicles/Wolfen2.wav",125)
SF.AddSound("LFS_SF64_WOLFEN_BOOST","cpthazama/starfox/64/vehicles/Boost2.wav",125)

SF.FireProjectile = function(self,ent,pos,lockOn,funcPre,funcPost)
	local startpos = self:GetRotorPos()
	local tr = util.TraceHull({
		start = startpos,
		endpos = (startpos +self:GetForward() *50000),
		mins = Vector(-40,-40,-40),
		maxs = Vector(40,40,40),
		filter = function(e)
			local collide = e != self
			return collide
		end
	})
	
	local ent = ents.Create(ent)
	if !IsValid(ent) then return end
	ent:SetPos(pos)
	ent:SetAngles(self:GetAngles())
	if funcPre then funcPre(ent) end
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker(self:GetDriver())
	ent:SetInflictor(self)
	ent:SetStartVelocity(self:GetVelocity():Length())
	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetVelocity(self:GetVelocity() +self:GetForward() *300)
	end
	if funcPost then funcPost(ent) end

	if !lockOn then return end
	if self:GetAI() then
		local enemy = SF.FindEnemy(self)
		if IsValid(enemy) then
			if enemy.OnEngineStarted then -- Must be a LFS or Simfphys entity
				ent:SetLockOn(enemy)
				ent:SetStartVelocity(0)
			end
		end
	else
		if tr.Hit then
			local Target = tr.Entity
			if IsValid(Target) then
				if Target.OnEngineStarted && Target != self then
					ent:SetLockOn(Target)
					ent:SetStartVelocity(0)
				end
			end
		end
	end
	constraint.NoCollide(ent,self,0,0)
end

SF.Destroy = function(self)
	self.Destroyed = true
	
	local PObj = self:GetPhysicsObject()
	if IsValid(PObj) then
		PObj:SetDragCoefficient(-20)
	end

	local ai = self:GetAI()
	if !ai then return end

	local attacker = self.FinalAttacker or Entity(0)
	local inflictor = self.FinalInflictor or Entity(0)
	if attacker:IsPlayer() then attacker:AddFrags(1) end
	gamemode.Call("OnNPCKilled",self,attacker,inflictor)
end

SF.OnDestroyed = function(self,spawnChance)
	if !IsValid(self) then return end

	if math.random(1,spawnChance) == 1 then
		local p = VJ_PICK({
			"lfs_starfox_upgrade_blue",
			"lfs_starfox_upgrade_blue",
			"lfs_starfox_upgrade_red",
			"lfs_starfox_upgrade_smartbomb",
			"lfs_starfox_upgrade_smartbomb",
			"lfs_starfox_upgrade_smartbomb",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_gold",
			"lfs_starfox_upgrade_gold",
			"lfs_starfox_upgrade_gold",
		})
		local item = ents.Create(p)
		if !IsValid(item) then return end
		item:SetPos(self:GetPos())
		item:Spawn()
		timer.Simple(30,function()
			SafeRemoveEntity(item)
		end)
	end
end

SF.FindEnemy = function(self)
	if !IsValid(self) then return NULL end

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
		for _,v in pairs(players) do
			if IsValid(v) then
				if v:Alive() then
					local Dist = (v:GetPos() - MyPos):Length()
					if Dist < TargetDistance then
						local Plane = v:lfsGetPlane()
						
						if IsValid(Plane) then
							-- if self:CanSee(Plane) and not Plane:IsDestroyed() and Plane != self then
							if self:Visible(Plane) and not Plane:IsDestroyed() and Plane != self then
								local HisTeam = Plane:GetAITEAM()
								if HisTeam != 0 && (HisTeam != MyTeam or HisTeam == 3) then
									ClosestTarget = v
									TargetDistance = Dist
								end
							end
						else
							local HisTeam = v:lfsGetAITeam()
							if v:IsLineOfSightClear(self) && HisTeam != 0 && (HisTeam != MyTeam or HisTeam == 3) then
								ClosestTarget = v
								TargetDistance = Dist
							end
						end
					end
				end
			end
		end
	end

	if not simfphys.LFS.IgnoreNPCs then
		for _,v in pairs(self:AIGetNPCTargets()) do
			if IsValid(v) then
				local HisTeam = self:AIGetNPCRelationship(v:GetClass())
				if HisTeam != "0" then
					if HisTeam != MyTeam or HisTeam == 3 then
						local Dist = (v:GetPos() - MyPos):Length()
						if Dist < TargetDistance then
							-- if self:CanSee(v) then
							if self:Visible(v) then
								ClosestTarget = v
								TargetDistance = Dist
							end
						end
					end
				end
			end
		end
	end

	self.FoundPlanes = simfphys.LFS:PlanesGetAll()
	
	for _,v in pairs(self.FoundPlanes) do
		if IsValid(v) and v != self and v.LFS then
			local Dist = (v:GetPos() - MyPos):Length()
			if Dist < TargetDistance /*and self:AITargetInfront(v,100)*/ then
				if not v:IsDestroyed() and v.GetAITEAM then
					local HisTeam = v:GetAITEAM()
					if HisTeam != 0 && (HisTeam != self:GetAITEAM() or HisTeam == 3) then
						-- if self:CanSee(v) then -- This function 9/10 times can never return true,if we use default Visible() function then they see enemies 10x better and its much more optimized than running hull traces
						if self:Visible(v) then
							-- print(tostring(self) .. " Found plane: " .. tostring(v))
							ClosestTarget = v
							TargetDistance = Dist
						end
					end
				end
			end
		end
	end

	self.LastTarget = ClosestTarget
	
	return ClosestTarget
end

SF.AddAI = function(name,ent,att)
	local index = #SF.AITurrets +1
	SF.AITurrets[index] = {}
	SF.AITurrets[index].Name = name
	SF.AITurrets[index].Ship = ent
	SF.AITurrets[index].Attachment = att
	SF.AITurrets[index].Enemy = NULL

	local hookName = "LFS_StarFox_TurretAI_" .. name .. "_" .. ent:EntIndex()
	hook.Add("Think",hookName,function()
		if !IsValid(ent) then
			hook.Remove("Think",hookName)
			return
		end

		-- local self = NULL
		-- for _,v in pairs(SF.AITurrets) do
		-- 	if v.Name == name then
		-- 		self = v
		-- 		print("FOUND " .. tostring(v))
		-- 		break
		-- 	end
		-- end
		local self = SF.AITurrets[index] && SF.AITurrets[index].Name == name && SF.AITurrets[index] or nil
		if self == nil then hook.Remove("Think",hookName) return end

		local hasAI = ent:GetAI()
		if !hasAI then return end -- Don't run the code if a player is driving the ship
		local pos = ent:GetAttachment(att).Pos
		local dist = GetConVar("lfs_bullet_max_range"):GetInt()
		local team = ent:GetAITEAM()

		if team == 0 then self.Enemy = NULL end

		local players = player.GetAll()
		local ClosestTarget = NULL
		local TargetDistance = 60000

		if not simfphys.LFS.IgnorePlayers then
			for _,v in pairs(players) do
				if IsValid(v) then
					if v:Alive() then
						local Dist = (v:GetPos() - pos):Length()
						if Dist < TargetDistance then
							local Plane = v:lfsGetPlane()
							
							if IsValid(Plane) then
								if ent:Visible(Plane) and not Plane:IsDestroyed() and Plane != ent then
									local HisTeam = Plane:GetAITEAM()
									if HisTeam != 0 then
										if HisTeam != team or HisTeam == 3 then
											ClosestTarget = v
											TargetDistance = Dist
										end
									end
								end
							else
								local HisTeam = v:lfsGetAITeam()
								if v:IsLineOfSightClear(ent) then
									if HisTeam != 0 then
										if HisTeam != team or HisTeam == 3 then
											ClosestTarget = v
											TargetDistance = Dist
										end
									end
								end
							end
						end
					end
				end
			end
		end

		ent.FoundPlanes = simfphys.LFS:PlanesGetAll()
		
		for _,v in pairs(ent.FoundPlanes) do
			if IsValid(v) and v != ent and v.LFS then
				local Dist = (v:GetPos() - pos):Length()
				
				if Dist < TargetDistance and ent:AITargetInfront(v,100) then
					if not v:IsDestroyed() and v.GetAITEAM then
						local HisTeam = v:GetAITEAM()
						if HisTeam != 0 then
							if HisTeam != team or HisTeam == 3 then
								if ent:Visible(v) then
									ClosestTarget = v
									TargetDistance = Dist
								end
							end
						end
					end
				end
			end
		end

		self.Enemy = ClosestTarget

		if ent.TurretAI then
			ent:TurretAI(self.Enemy,att,pos) -- (Enemy,Turret Index,Position)
		else -- Default AI
			if IsValid(self.Enemy) then
				ent:FireTurret(att,self.Enemy:GetPos() +self.Enemy:OBBCenter())
			end
		end
	end)
end

print("Successfully Loaded [LFSimfphys] Star Fox Functions file!")