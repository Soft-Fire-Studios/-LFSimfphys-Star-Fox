AddCSLuaFile()

ENT.Base 			= "lfs_starfox_mission_base"
ENT.Type 			= "anim"
ENT.PrintName 		= "The Salvadora"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= "A Cornerian fleet carrying war resources is requesting assistance, they've reported a large unknown vessel heading towards their projected flight path. If we are to win this war, we need to take out that vessel before it can take out our supply line!"
ENT.FinishedText 	= "The Salvadora has been destroyed, Mission Complete!"
ENT.Category 		= "[LFS] Star Fox - Missions"

ENT.MissionType = 1 -- 0 = None, 1 = Assault, 2 = War Zone, 3 = Escort, 4 = Versus
ENT.MissionForceTeam = true
ENT.MissionTeam = SF_AI_TEAM_CORNERIA

ENT.Spawnable = false
ENT.AdminOnly = false

if CLIENT then
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:WhenRemoved()
		-- SF_StopTrack("Star Wolf",true)
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
		timer.Simple(5,function()
			if IsValid(self) then
				self:RespawnEnemies(20)
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

	if GetConVar("lfs_sf_mission_forceply"):GetInt() == 1 then
		for _,v in pairs(player.GetAll()) do
			if !v:Alive() then v:Spawn() end
			v:SelectWeapon("weapon_physgun")
			local sPos = self:GetSpawnPos(500,10)
			if sPos then
				local veh = self:SpawnVehicle("lfs_starfox_" .. v:GetInfo("lfs_sf_ship"),sPos,false)
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
			local sPos = self:GetSpawnPos(1500)
			if sPos then
				local boss = self:SpawnVehicle("lfs_starfox_venom_salvador",sPos,true)
				self.Boss = boss
				self.HasBoss = true
			end
		end

		if CurTime() > self.EnemyRespawnT then -- Respawn enemies
			self:RespawnEnemies(20)

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