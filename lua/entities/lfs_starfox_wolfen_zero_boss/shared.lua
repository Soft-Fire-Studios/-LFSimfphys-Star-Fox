ENT.Type            = "anim"
ENT.Base 		    = "lfs_starfox_wolfen_zero"

ENT.PrintName = "Wolfen Mk. I (Boss)"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] Star Fox"

ENT.Spawnable		= true
ENT.AdminSpawnable  = true

ENT.Pilots = {"Wolf (Zero)"}

ENT.CameraPos = {Start=Vector(-800,0,60),End=Vector(367,66,60)}
ENT.CameraTime = 5

ENT.MaxHealth = 5000
ENT.MaxShield = 500

function ENT:AddDataTables()
	self:NetworkVar("Int",2,"AITEAM",{KeyName = "aiteam",Edit = { type = "Int", order = 2,min = 0, max = 100, category = "AI"}})

	self:NetworkVar("Bool",6,"Invincible")

	self:NetworkVar("Bool",7,"LightningBlaster")
	self:NetworkVar("Bool",8,"LightningTornado")
	self:NetworkVar("Bool",9,"OrbitalWolf")
	self:NetworkVar("Bool",10,"ShadowEdge")

	self:NetworkVar("Int",3,"LightningBlasterTime")
	self:NetworkVar("Int",4,"LightningTornadoTime")
	self:NetworkVar("Int",5,"OrbitalWolfTime")
	self:NetworkVar("Int",6,"ShadowEdgeTime")
	self:NetworkVar("Int",7,"SpecialAttackTime")
end