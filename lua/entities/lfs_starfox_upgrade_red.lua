AddCSLuaFile()

ENT.Base 			= "lfs_starfox_upgrade_blue"
ENT.Type 			= "anim"
ENT.PrintName 		= "Laser Upgrade (Red)"
ENT.Category 		= "[LFS] Star Fox - Entities"

ENT.Spawnable = true
ENT.AdminOnly = true
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInit()
	self:SetSkin(1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoUpgrade(ent)
	ent:SetNW2Int("LaserUpgrade",2)
	ent:SetNW2Int("LaserUpgradeTime",CurTime() +60)
	VJ_CreateSound(ent,"cpthazama/starfox/vehicles/arwing_enter.wav",80,110)

	if IsValid(ent:GetDriver()) then
		ent:GetDriver():ChatPrint("[Upgrade Aquired] 100% Damage Boost to Primary Lasers!")
	end
end