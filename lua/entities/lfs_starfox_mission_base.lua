AddCSLuaFile()

/*
	### Mission Details ###

	Mission Types:
		- Assault
			- Player(s) lead an assault with Star Fox team on a large enemy vehicle/base
			- Swarms of minor enemies with rare chance of strong enemies
			- Chance of special unit to appear (I.E. Star Wolf team)
		- War Zone
			- Player(s) enter a large battle space with tons of AI units (friendly and enemy)
			- Player(s) must destroy all enemy units
			- Chance of special unit to appear (I.E. Star Wolf team)
		- Escort
			- Player(s) must defend a large enemy vehicle/base (I.E. Great Fox, Cornerian Cruiser, etc)
			- Mission ends after X time has passed or objective is destroyed
		- Versus (MP Only)
			- Player(s) battle it out for the most kills
			- Mission ends after X time has passed
			- Vehicles are spawned randomly around the map
			- Players spawn with SF SWEPs and must locate vehicles if they want to
*/

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Mission Base"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""
ENT.Category 		= "[LFS] Star Fox - Missions"

ENT.MissionType = 0 -- 0 = None, 1 = Assault, 2 = War Zone, 3 = Escort, 4 = Versus
ENT.MissionForceTeam = false
ENT.MissionTeam = SF_AI_TEAM_CORNERIA
ENT.MissionMap = false // gm_cruisercanyon

ENT.Spawnable = false
ENT.AdminOnly = false
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	function ENT:Draw()
		return false
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:InitializeCS(mType)
		return true
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:InitializeCS_Post(mType)
		return true
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:WhenRemoved() end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:Initialize()
		for _,v in pairs(ents.FindByClass(self:GetClass())) do
			if v != self then
				return
			end
		end

		local mType = self.MissionType
		if self:InitializeCS(mType) == false then return end

		SF_CreateTrack("cpthazama/starfox/music/mission/Corneria_DefenseA.ogg",LocalPlayer(),"Escort01",true)

		SF_CreateTrack("cpthazama/starfox/music/mission/Corneria_OrbitA.ogg",LocalPlayer(),"Assault01",true)

		SF_CreateTrack("cpthazama/starfox/music/mission/Corneria_OrbitB.ogg",LocalPlayer(),"WarZone01",true)

		timer.Simple(0,function()
			local mType = self.MissionType
			if self:InitializeCS_Post(mType) == false then return end
			if mType == 1 then
				SF_PlayTrack("Assault01",true)
			elseif mType == 2 then
				SF_PlayTrack("WarZone01",true)
			elseif mType == 3 then
				SF_PlayTrack("Escort01",true)
			elseif mType == 4 then
				SF_PlayTrack("Assault01",true)
			end
		end)
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:Think() end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:OnRemove()
		SF_StopTrack("Escort01",true)
		SF_StopTrack("Assault01",true)
		SF_StopTrack("WarZone01",true)

		self:WhenRemoved()
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartAssaultMission() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartWarZoneMission() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartEscortMission() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartVersusMission() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MissionThink(mType) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:DrawShadow(false)

	for _,v in pairs(ents.FindByClass(self:GetClass())) do
		if v != self then
			self:Remove()
			return
		end
	end

	if self.MissionMap then
		if game.GetMap() != self.MissionMap then
			Entity(1):ChatPrint("You must be playing on " .. self.MissionMap .. " to play this mission!")
			self:Remove()
			return
		end
	end

	local phys = self:GetPhysicsObject()
	if phys and IsValid(phys) then
		phys:Wake()
	end

	self.WorldData = game.GetWorld():GetSaveTable()
	self.WorldMins = self.WorldData.m_WorldMins
	self.WorldMaxs = self.WorldData.m_WorldMaxs

	local mType = self.MissionType
	if mType == 1 then
		self:StartAssaultMission()
	elseif mType == 2 then
		self:StartWarZoneMission()
	elseif mType == 3 then
		self:StartEscortMission()
	elseif mType == 4 then
		self:StartVersusMission()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	self:SetPos(VJ_PICK(player.GetAll()):GetPos())
	if self.MissionForceTeam then
		for _,v in pairs(player.GetAll()) do v:lfsSetAITeam(self.MissionTeam) end
	end
	self:MissionThink(self.MissionType)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Chat(text)
	for _,v in pairs(player.GetAll()) do
		v:PrintMessage(HUD_PRINTTALK,text)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnVehicle(class,pos,AI)
	local vehicle = ents.Create(class)
	vehicle:SetPos(pos)
	vehicle:SetAngles(self:GetAngles())
	vehicle:Spawn()
	if AI then
		vehicle:SetAI(true)
	end
	-- table.insert(self.Vehicles,vehicle)

	self:DeleteOnRemove(vehicle)

	return vehicle
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetSpawnPos(normAmount,tries)
	tries = tries or 3
	normAmount = normAmount or 20
	local sendPos = false
	for i = 1,tries do
		local r = math.random(1,4)
		local r2 = math.random(1,2)
		local pos = r == 1 && Vector(r2 == 1 && self.WorldMaxs.x or self.WorldMins.x,0,0) or r == 2 && Vector(0,r2 == 1 && self.WorldMaxs.y or self.WorldMins.y,0) or r == 3 && Vector(0,0,r2 == 1 && self.WorldMaxs.z or self.WorldMins.z) or Vector(math.random(1,2) == 1 && self.WorldMaxs.x or self.WorldMins.x,math.random(1,2) == 1 && self.WorldMaxs.y or self.WorldMins.y,math.random(1,2) == 1 && self.WorldMaxs.z or self.WorldMins.z)
		local tr = util.TraceLine({
			-- start = pos,
			-- endpos = pos +VectorRand() *800,
			start = pos +VectorRand() *800,
			endpos = pos,
			mask = MASK_SOLID,
		})
		local targetPos = tr.Hit && tr.HitPos +tr.HitNormal *normAmount
		if tr.Hit && util.IsInWorld(targetPos) then
			-- local ent = VJ_CreateTestObject(targetPos, Angle(0,0,0),Color(255,0,0),10)
			-- ent:SetModelScale(10)
			sendPos = targetPos
			break
		end
	end
	return sendPos
end