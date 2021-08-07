AddCSLuaFile()

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "AI Creator"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""
-- ENT.Category 		= "[LFS] Star Fox"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.Vehicles = {}
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	function ENT:Draw()
		return false
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = (self:GetPos() +Vector(0,0,-1000)),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = {self,vehicle}
	})
	local vehicle = ents.Create(VJ_PICK(self.Vehicles))
	vehicle:SetPos(tr.HitPos +tr.HitNormal *vehicle:OBBMaxs().z +Vector(0,0,300))
	vehicle:SetAngles(self:GetAngles())
	vehicle:Spawn()
	vehicle:SetAI(true)
	-- local tr = util.TraceHull( {
	-- 	start = vehicle:GetPos(),
	-- 	endpos = (vehicle:GetPos() +Vector(0,0,-1000)),
	-- 	mins = Vector( -10, -10, -10 ),
	-- 	maxs = Vector( 10, 10, 10 ),
	-- 	filter = {self,vehicle}
	-- })
	-- vehicle:SetPos(tr.HitPos +tr.HitNormal *vehicle:OBBMaxs().z)

	timer.Simple(0.01,function()
		if self.OnSpawn then self:OnSpawn(vehicle) end
		undo.ReplaceEntity(self,vehicle)
		cleanup.ReplaceEntity(self,vehicle)
		self:Remove()
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	return false
end