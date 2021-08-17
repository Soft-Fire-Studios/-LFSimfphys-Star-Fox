AddCSLuaFile()

ENT.Base 			= "lfs_starfox_upgrade_silver"
ENT.Type 			= "anim"
ENT.PrintName 		= "Supply Ring (Gold)"
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
	local maxHP = ent:GetMaxHP()
	ent:SetHP(math.Clamp(ent:GetHP() +ent:GetMaxHP() *0.5,0,maxHP))
	VJ_CreateSound(ent,"cpthazama/starfox/vehicles/arwing_enter.wav",80,110)

	if IsValid(ent:GetDriver()) then
		ent:GetDriver():ChatPrint("[Upgrade Aquired] Obtained 50% Health!")
	end
end