ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

AddCSLuaFile("starfox/pilots_shared.lua")
include("starfox/pilots_shared.lua")

ENT.PrintName = "Wolfen Mk. I (Hunter)"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= false
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/starfox/vehicles/wolfen_zero_hunter.mdl"

ENT.AITEAM = 2

ENT.Mass = 2000

ENT.HideDriver = true
ENT.SeatPos = Vector(-25,0,25)
ENT.SeatAng = Angle(0,-90,0)

ENT.RotorPos = Vector(225,0,10)

ENT.MaxHealth = 1000
ENT.MaxShield = 500

ENT.MaxPrimaryAmmo = 10000

function ENT:AddDataTables()
	self:NetworkVar("Float",22,"Move")

	self:NetworkVar("Bool",19,"IsMoving")
	self:NetworkVar("Bool",20,"FrontInRange")
	self:NetworkVar("Bool",21,"RearInRange")
end