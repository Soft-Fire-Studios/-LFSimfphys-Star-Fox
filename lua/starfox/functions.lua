print("Loading [LFSimfphys] Star Fox Functions file...")

SF = {}
SF.CachedSounds = {}
SF.AITurrets = {}

//https://wiki.facepunch.com/gmod/PhysObj:AddAngleVelocity

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

SF.AddSound("LFS_SF_GENERIC_ENGINE","cpthazama/starfox/vehicles/generic_loop.wav",125)

SF.AddSound("LFS_SF64_ARWING_ENGINE","cpthazama/starfox/64/vehicles/Engine.wav",125)
SF.AddSound("LFS_SF64_ARWING_BOOST","cpthazama/starfox/64/vehicles/Boost.wav",125)
SF.AddSound("LFS_SF64_ARWING_NITRO","cpthazama/starfox/64/vehicles/ArwingINtro.wav",125)

SF.AddSound("LFS_SF64_WOLFEN_ENGINE","cpthazama/starfox/64/vehicles/Wolfen.wav",125)
SF.AddSound("LFS_SF64_WOLFEN_BOOST","cpthazama/starfox/64/vehicles/Boost2.wav",125)

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
			for _, v in pairs( players ) do
				if IsValid( v ) then
					if v:Alive() then
						local Dist = (v:GetPos() - pos):Length()
						if Dist < TargetDistance then
							local Plane = v:lfsGetPlane()
							
							if IsValid( Plane ) then
								if ent:Visible( Plane ) and not Plane:IsDestroyed() and Plane ~= ent then
									local HisTeam = Plane:GetAITEAM()
									if HisTeam ~= 0 then
										if HisTeam ~= team or HisTeam == 3 then
											ClosestTarget = v
											TargetDistance = Dist
										end
									end
								end
							else
								local HisTeam = v:lfsGetAITeam()
								if v:IsLineOfSightClear( ent ) then
									if HisTeam ~= 0 then
										if HisTeam ~= team or HisTeam == 3 then
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
		
		for _, v in pairs( ent.FoundPlanes ) do
			if IsValid( v ) and v ~= ent and v.LFS then
				local Dist = (v:GetPos() - pos):Length()
				
				if Dist < TargetDistance and ent:AITargetInfront( v, 100 ) then
					if not v:IsDestroyed() and v.GetAITEAM then
						local HisTeam = v:GetAITEAM()
						if HisTeam ~= 0 then
							if HisTeam ~= team or HisTeam == 3 then
								if ent:Visible( v ) then
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
			ent:TurretAI(self.Enemy,att,pos) -- (Enemy, Turret Index, Position)
		else -- Default AI
			if IsValid(self.Enemy) then
				ent:FireTurret(att,self.Enemy:GetPos() +self.Enemy:OBBCenter())
			end
		end
	end)
end

print("Successfully Loaded [LFSimfphys] Star Fox Functions file!")