AddCSLuaFile()

ENT.Base 			= "lfs_starfox_mission_base"
ENT.Type 			= "anim"
ENT.PrintName 		= "Andross' Preemptive Strike"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= "Andross has given team Star Wolf the coordinates of a Cornerian Fleet that is supposedly waiting to ambush any Venomian ships that may pass through. Head there now and destroy them to establish a secure route in the area!"
ENT.FinishedText 	= "The Cornerian Fleet has been destroyed! Now Andross can safely move supplies through this area, Mission Complete!"
ENT.Category 		= "[LFS] Star Fox - Missions"

ENT.MissionType = 1 -- 0 = None, 1 = Assault, 2 = War Zone, 3 = Escort, 4 = Versus
ENT.MissionForceTeam = true
ENT.MissionTeam = SF_AI_TEAM_ANDROSS

SF.AddMissionData(1,ENT.PrintName,ENT.Instructions,"entities/lfs_starfox_mission_wolf_assault_1.png",true)

ENT.Spawnable = false
ENT.AdminOnly = false

if CLIENT then
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:InitializeCS_Post(mType)
		SF_CreateTrack("cpthazama/starfox/music/star_wolf_assault.mp3",LocalPlayer(),"Star Wolf")
		return false
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
			local enemy = self:SpawnVehicle("lfs_starfox_cornerian_fighter",sPos,true)
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
				self:RespawnEnemies(8)
			end
		end)
	
		if GetConVar("lfs_sf_mission_allies"):GetInt() == 1 then
			while table.Count(self.Friends) < 2 do
				local sPos = self:GetSpawnPos(200)
				if sPos then
					local friend = self:SpawnVehicle("lfs_starfox_wolfen",sPos,true)
					table.insert(self.Friends,friend)
				end
			end
		end
	end)

	self.HasBoss = false
	self.Boss = NULL

	if GetConVar("lfs_sf_mission_forceply"):GetInt() == 1 then
		for _,v in pairs(player.GetAll()) do
			if !v:Alive() then v:Spawn() end
			v:SelectWeapon("weapon_physgun")
			local sPos = self:GetSpawnPos(500,10)
			if sPos then
				local veh = self:SpawnVehicle("lfs_starfox_wolfen",sPos,false)
				if self.MissionForceTeam then
					veh:SetAITEAM(self.MissionTeam)
				end
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
				local boss = self:SpawnVehicle("lfs_starfox_cornerian_cruiser",sPos,true)
				if IsValid(boss.Ramp) then boss.Ramp:Remove() end
				self.Boss = boss
				self.HasBoss = true
			end
		end

		if CurTime() > self.EnemyRespawnT then -- Respawn enemies
			self:RespawnEnemies(8)

			self.EnemyRespawnTime = math.Clamp(self.EnemyRespawnTime -30,30,120)
			self.EnemyRespawnT = CurTime() +self.EnemyRespawnTime
		end

		for k,v in pairs(self.Enemies) do -- Check for enemies
			if !IsValid(v) then
				table.remove(self.Enemies,k)
			end
		end
	end
end