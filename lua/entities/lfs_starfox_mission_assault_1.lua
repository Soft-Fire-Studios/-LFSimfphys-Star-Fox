AddCSLuaFile()

ENT.Base 			= "lfs_starfox_mission_base"
ENT.Type 			= "anim"
ENT.PrintName 		= "Venom Cruiser Bust"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= "Star Fox team has been sent to take out a Venomian Cruiser carrying cargo that would benefit Andross greatly should it make it back. The Cruiser is heavily guarded, focus on destroying the smaller ships first to make taking out the objective easier!"
ENT.FinishedText 	= "The Venomian Cruiser has been destroyed! Now Andross will never receive those supplies, Mission Complete!"
ENT.Category 		= "[LFS] Star Fox - Missions"

ENT.MissionType = 1 -- 0 = None, 1 = Assault, 2 = War Zone, 3 = Escort, 4 = Versus
ENT.MissionForceTeam = true
ENT.MissionTeam = SF_AI_TEAM_CORNERIA

ENT.Spawnable = true
ENT.AdminOnly = true

if CLIENT then
	ENT.StartedStarWolf = false
	function ENT:Think()
		local SW = self:GetNW2Bool("StarWolf")
		if SW && !self.StartedStarWolf then
			self.StartedStarWolf = true
			SF_PauseTrack("Assault01",true)
			SF_CreateTrack("cpthazama/starfox/music/star_wolf_assault.mp3",LocalPlayer(),"Star Wolf")
		elseif self.StartedStarWolf && SW == false then
			self.StartedStarWolf = false
			SF_PlayTrack("Assault01",true)
			SF_StopTrack("Star Wolf",true)
		end
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:WhenRemoved()
		SF_StopTrack("Star Wolf",true)
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RespawnEnemies(count)
	while table.Count(self.Enemies) < count do
		local sPos = self:GetSpawnPos(200)
		if sPos then
			local enemy = self:SpawnVehicle("lfs_starfox_venom_fighter_dragon",sPos,true)
			table.insert(self.Enemies,enemy)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartAssaultMission()
	self:Chat(self.Instructions)

	self.Friends = {}

	self.Enemies = {}
	self.EnemyRespawnTime = 120
	self.EnemyRespawnT = CurTime() +self.EnemyRespawnTime

	timer.Simple(0,function()
		timer.Simple(3,function()
			if IsValid(self) then
				self:RespawnEnemies(15)
			end
		end)
	
		if GetConVar("lfs_sf_mission_allies"):GetInt() == 1 then
			while table.Count(self.Friends) < 3 do
				local sPos = self:GetSpawnPos(200)
				if sPos then
					local friend = self:SpawnVehicle("lfs_starfox_arwing",sPos,true)
					table.insert(self.Friends,friend)
				end
			end
		end
	end)

	self.HasBoss = false
	self.Boss = NULL
	self.HasStarWolf = false
	self.StarWolfCount = 0
	self.StarWolfTime = CurTime() +math.Rand(40,480)
	self:SetNW2Bool("StarWolf",false)

	self.StarWolf = {}

	if GetConVar("lfs_sf_mission_forceply"):GetInt() == 1 then
		for _,v in pairs(player.GetAll()) do
			if !v:Alive() then v:Spawn() end
			v:SelectWeapon("weapon_physgun")
			local sPos = self:GetSpawnPos(500,10)
			if sPos then
				local veh = self:SpawnVehicle(v:GetInfo("lfs_sf_ship"),sPos,false)
				-- local veh = self:SpawnVehicle("lfs_starfox_" .. v:GetInfo("lfs_sf_ship"),sPos,false)
				if self.MissionForceTeam then
					veh:SetAITEAM(self.MissionTeam)
				end
				-- local veh = self:SpawnVehicle("lfs_starfox_arwing",sPos,false)
				timer.Simple(0,function()
					veh:SetPassenger(v)
					veh:ToggleEngine()
				end)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MissionThink(mType)
	if mType == 1 then
		if !IsValid(self.Boss) && self.HasBoss then
			self:Chat(self.FinishedText)
			self:Remove()
			return
		end
		if !self.HasBoss then -- Spawn Boss
			local sPos = self:GetSpawnPos(800)
			if sPos then
				local boss = self:SpawnVehicle("lfs_starfox_venom_cruiser",sPos,true)
				if IsValid(boss.Ramp) then boss.Ramp:Remove() end
				self.Boss = boss
				self.HasBoss = true
			end
		end

		if CurTime() > self.EnemyRespawnT then -- Respawn enemies
			self:RespawnEnemies(15)

			self.EnemyRespawnTime = math.Clamp(self.EnemyRespawnTime -30,30,120)
			self.EnemyRespawnT = CurTime() +self.EnemyRespawnTime
		end

		for k,v in pairs(self.Enemies) do -- Check for enemies
			if !IsValid(v) then
				table.remove(self.Enemies,k)
			end
		end

		if !self.HasStarWolf then -- Spawn Star Wolf
			if self.StarWolfTime <= CurTime() then
				while self.StarWolfCount < 3 do
					local sPos = self:GetSpawnPos(200)
					if sPos then
						local wolfen = self:SpawnVehicle("lfs_starfox_wolfen",sPos,true)
						self.StarWolfCount = self.StarWolfCount +1
						table.insert(self.StarWolf,wolfen)
						if self.StarWolfCount == 3 then
							self.HasStarWolf = true
							self:SetNW2Bool("StarWolf",true)
						end
					end
				end
			end
		else
			local alive = 3
			for _,v in pairs(self.StarWolf) do
				if !IsValid(v) or IsValid(v) && v:GetHP() <= 0 then
					alive = alive -1
				end
			end
			if alive <= 0 then
				self:SetNW2Bool("StarWolf",false)
				self.HasStarWolf = false
			end
		end
	end
end