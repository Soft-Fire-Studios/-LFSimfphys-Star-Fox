AddCSLuaFile()

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Laser Upgrade (Blue)"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""
ENT.Category 		= "[LFS] Star Fox - Entities"

ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnFunction(ply,tr,ClassName)
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos +tr.HitNormal *600)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	
	function ENT:DrawTranslucent()
		self:Draw()
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoUpgrade(ent)
	ent:SetNW2Int("LaserUpgrade",1)
	ent:SetNW2Int("LaserUpgradeTime",CurTime() +60)
	VJ_CreateSound(ent,"cpthazama/starfox/vehicles/arwing_enter.wav",80,110)

	if IsValid(ent:GetDriver()) then
		ent:GetDriver():ChatPrint("[Upgrade Aquired] 50% Damage Boost to Primary Lasers!")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/cpthazama/starfox/items/laser_upgrade.mdl")
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_OBB)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	self.Dead = false

	self:ResetSequence("idle")

	if self.OnInit then self:OnInit() end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	self:NextThink(CurTime())
	if self.Dead then return end
	for _,v in ipairs(ents.FindInSphere(self:GetPos(),self:OBBMaxs().z *2)) do
		if v != self && string.find(v:GetClass(),"lfs_starfox_") && v.AITEAM && !v.SF_BlockUpgrade then
			self.Dead = true
			self:DoUpgrade(v)
			self:Remove()
			break
		end
	end
	return true
end