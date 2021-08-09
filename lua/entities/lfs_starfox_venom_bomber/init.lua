--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

ENT.Deployed = false
ENT.DeployT = 0
ENT.Camo = false

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:OnRemove()
	-- SafeRemoveEntity(self.Trail)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary(15)

	local Mirror = 1
	for i = 1,24 do
		timer.Simple(0.1 *i,function()
			if IsValid(self) then
				local startpos = self:GetRotorPos()
				local tr = util.TraceHull( {
					start = startpos,
					endpos = (startpos +self:GetForward() *50000),
					mins = Vector(-40,-40,-40),
					maxs = Vector(40,40,40),
					filter = self
				})
				local ent = ents.Create("lunasflightschool_missile")
				local Pos = self:GetAttachment(Mirror).Pos +self:GetUp() *math.random(-200,200) +self:GetRight() *math.random(-200,200)
				Mirror = Mirror == 1 && 2 or 1
				ent:SetPos(Pos)
				ent:SetAngles(((tr.HitPos +VectorRand() *math.Rand(500,1000)) -Pos):Angle())
				ent:Spawn()
				ent:Activate()
				ent:SetAttacker(self:GetDriver())
				ent:SetInflictor(self)
				ent:SetStartVelocity(self:GetVelocity():Length())
				SF.PlaySound(3,Pos,"cpthazama/starfox/vehicles/se_apa-0003_06.wav",80)
				
				if tr.Hit then
					local Target = tr.Entity
					if IsValid(Target) then
						if Target:GetClass():lower() != "lunasflightschool_missile" then
							ent:SetLockOn(Target)
							ent:SetStartVelocity(0)
						end
					end
				end
				constraint.NoCollide(ent,self,0,0)
			end
		end)
	end
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local Crouch = false

	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyReleased(IN_ATTACK)
		end
		Fire2 = Driver:KeyReleased(IN_ATTACK2)
		Crouch = Driver:KeyReleased(IN_WALK)
	end
	
	if Fire1 then
		if self.Deployed then self:PrimaryAttack() end
	end
	
	local Dir = self.Camo && -1 or 1
	local alpha = self:GetColor().a
	self:SetColor(Color(255,255,255,math.Clamp(alpha +(5 *Dir),0,255)))
	if Crouch && !self.Deployed then
		self.Camo = !self.Camo
		-- self:SetMaterial(self.Camo && "Models/effects/vol_light001" or "")
	elseif self.Deployed then
		-- self:SetMaterial("")
		self.Camo = false
	end
	
	self:SetNW2Bool("Camo",self.Camo)

	if Fire2 && CurTime() > self.DeployT then
		self:PlayAnimation(self.Deployed && "disarm" or "deploy")
		self.Deployed = !self.Deployed
		self.DeployT = CurTime() +1.75
	end
end

function ENT:OnEngineStarted()
	self:EmitSound("cpthazama/starfox/vehicles/arwing_power_up.wav")
	if IsValid(self:GetDriver()) then
		self:GetDriver():EmitSound("cpthazama/starfox/vehicles/arwing_enter.wav")
	end

	-- self.CanUseTrail = true
end

function ENT:OnEngineStopped()
	self:EmitSound("cpthazama/starfox/vehicles/arwing_power_down.wav")

	-- self.CanUseTrail = false
	-- SafeRemoveEntity(self.Trail)
end

function ENT:Destroy()
	self.Destroyed = true
	
	local PObj = self:GetPhysicsObject()
	if IsValid( PObj ) then
		PObj:SetDragCoefficient( -20 )
	end

	local ai = self:GetAI()
	if !ai then return end

	local attacker = self.FinalAttacker or Entity(0)
	local inflictor = self.FinalInflictor or Entity(0)
	if attacker:IsPlayer() then attacker:AddFrags(1) end
	gamemode.Call("OnNPCKilled",self,attacker,inflictor)
end