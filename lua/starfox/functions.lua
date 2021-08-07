print("Loading [LFSimfphys] Star Fox Functions file...")

SF = {}
SF.CachedSounds = {}
SF.AITurrets = {}

SF.BoneData = function(ent,bone)
	local pos,ang = ent:GetBonePosition(bone)
	local tbl = {}
	tbl.Pos = pos
	tbl.Ang = ang

	return tbl
end

SF.AddSound = function(name,snd,lvl,chan)
	sound.Add({
		name = name,
		channel = chan or CHAN_STATIC,
		volume = 1.0,
		level = lvl or 75,
		sound = snd
	})
	table.insert(SF.CachedSounds,{Name=name,Sound=snd})
	print("Successfully added sound '" .. name .. "'!")
end

SF.AddSound("LFS_SF_ARWING_ENGINE","cpthazama/starfox/vehicles/arwing_eng_boost_loop.wav",125)
SF.AddSound("LFS_SF_ARWING_ENGINE2","cpthazama/starfox/vehicles/arwing_eng.wav",90)
SF.AddSound("LFS_SF_ARWING_BOOST","cpthazama/starfox/vehicles/arwing_eng_boost_short.wav",125)
SF.AddSound("LFS_SF_ARWING_PRIMARY","cpthazama/starfox/vehicles/arwing_laser_single_hit.wav",95,CHAN_WEAPON)
SF.AddSound("LFS_SF_ARWING_PRIMARY_CHARGED","cpthazama/starfox/vehicles/arwing_fire_charged.wav",95,CHAN_WEAPON)
SF.AddSound("LFS_SF_ARWING_PRIMARY_DOUBLE","cpthazama/starfox/vehicles/arwing_laser_double.wav",95,CHAN_WEAPON)

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