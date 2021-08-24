AddCSLuaFile()

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Star Wolf"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""
ENT.Category 		= "[LFS] Star Fox - Entities"

ENT.Spawnable = true
ENT.AdminOnly = true
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	function ENT:Draw()
		return false
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:Initialize()
		local MKType = self:GetNW2Int("StarWolfMK")
		SF_CreateTrack(MKType == 2 && "cpthazama/starfox/music/star_wolf_assault.mp3" or MKType == 3 && "cpthazama/starfox/music/star_wolf_mkiii.mp3" or "cpthazama/starfox/music/star_wolf.mp3",LocalPlayer(),"Star Wolf")
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function ENT:OnRemove()
		SF_StopTrack("Star Wolf",true)
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetNW2Int("StarWolfMK",math.random(1,3))
	local MKType = self:GetNW2Int("StarWolfMK")
	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	for _,v in pairs(ents.FindByClass(self:GetClass())) do
		if v != self then
			self:Remove()
			return
		end
	end

	local phys = self:GetPhysicsObject()
	if phys and IsValid(phys) then
		phys:Wake()
	end

	self.Squad = {}

	local ent = MKType == 2 && "lfs_starfox_wolfen" or MKType == 3 && "lfs_starfox_wolfen_redfang" or "lfs_starfox_wolfen_zero"
	for i = 1,MKType > 1 && 3 or 4 do
		local tbl = self.Squad
		table.insert(tbl,self)

		local hull = 50
		local st1 = self:GetPos() +Vector(0,0,15)
		local tr1 = util.TraceHull({
			start = st1,
			endpos = st1 +Vector(0,0,32620),
			filter = tbl,
			mins = Vector(-hull,-hull,-hull),
			maxs = Vector(hull,hull,hull),
		})
		local st2 = tr1.HitPos +tr1.HitNormal *450
		local tr2 = util.TraceHull({
			start = st2,
			endpos = st2 +Vector(math.Rand(-1000,1000),math.Rand(-1000,1000),math.Rand(-1000,450)),
			filter = tbl,
			mins = Vector(-hull,-hull,-hull),
			maxs = Vector(hull,hull,hull),
		})

		local vehicle = ents.Create(ent)
		vehicle:SetPos(tr2.HitPos +tr2.HitNormal *450)
		vehicle:SetAngles(self:GetAngles())
		vehicle:Spawn()
		vehicle:SetAI(true)
		table.insert(self.Squad,vehicle)

		self:DeleteOnRemove(vehicle)
	end

	self.CanRemoveT = CurTime() +0.126
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	if CurTime() < self.CanRemoveT then return end
	local alive = 4
	for _,v in pairs(self.Squad) do
		if !IsValid(v) then
			alive = alive - 1
		end
	end

	if alive < 1 then
		self:Remove()
	end
end