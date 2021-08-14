AddCSLuaFile()

ENT.Type            = "anim"

ENT.FireStraight = false
ENT.DMG = 150
ENT.DMGDist = 180
ENT.ExplodeSound = "cpthazama/bwii/rocket_explode" .. math.random(1,2) .. ".wav"

function ENT:SetupDataTables()
	self:NetworkVar( "Bool",0, "Disabled" )
	self:NetworkVar( "Bool",1, "CleanMissile" )
	self:NetworkVar( "Bool",2, "DirtyMissile" )
	self:NetworkVar( "Entity",0, "Attacker" )
	self:NetworkVar( "Entity",1, "Inflictor" )
	self:NetworkVar( "Entity",2, "LockOn" )
	self:NetworkVar( "Float",0, "StartVelocity" )
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if !tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 20 )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:SpiralFire()
	if self:GetDisabled() then return end
	
	local pObj = self:GetPhysicsObject()
	
	if IsValid( pObj ) then
		local targetdir = ((self:GetPos() +self:GetUp() *math.Rand(-700,700) +self:GetRight() *math.Rand(-700,700)) - self:GetPos()):GetNormalized()
		
		local AF = self:WorldToLocalAngles( targetdir:Angle() )
		AF.p = math.Clamp( AF.p * 400,-90,90 )
		AF.y = math.Clamp( AF.y * 400,-90,90 )
		AF.r = math.Clamp( AF.r * 400,-90,90 )
		
		local AVel = pObj:GetAngleVelocity()
		pObj:AddAngleVelocity( Vector(AF.r,AF.p,AF.y) - AVel )
		pObj:SetVelocityInstantaneous(self:GetForward() *(self:GetStartVelocity() +3000))
	end
end

function ENT:BlindFire()
	if self:GetDisabled() then return end
	
	local pObj = self:GetPhysicsObject()
	
	if IsValid( pObj ) then
		pObj:SetVelocityInstantaneous( self:GetForward() * (self:GetStartVelocity() + 3000) )
	end
end

function ENT:FollowTarget( followent )
	if followent == NULL then self:SpiralFire() return end
	if self.DisableChase then self:SpiralFire() return end
	if self:GetDisabled() then self:SpiralFire() return end
	local speed = self:GetStartVelocity() + (self:GetDirtyMissile() && 5000 or 3500)
	local turnrate = (self:GetCleanMissile() or self:GetDirtyMissile()) && 60 or 50
	
	local TargetPos = followent:LocalToWorld( followent:OBBCenter() )
	
	if isfunction( followent.GetMissileOffset ) then
		local Value = followent:GetMissileOffset()
		if isvector( Value ) then
			TargetPos = followent:LocalToWorld( Value )
		end
	end
	
	local pos = TargetPos + followent:GetVelocity() * 0.25
	
	local pObj = self:GetPhysicsObject()
	
	if IsValid( pObj ) then
		if self:GetDisabled() then self:SpiralFire() return end
		if !self:GetDisabled() then
			local targetdir = (pos - self:GetPos()):GetNormalized()
			
			local AF = self:WorldToLocalAngles( targetdir:Angle() )
			AF.p = math.Clamp( AF.p * 400,-turnrate,turnrate )
			AF.y = math.Clamp( AF.y * 400,-turnrate,turnrate )
			AF.r = math.Clamp( AF.r * 400,-turnrate,turnrate )
			
			local AVel = pObj:GetAngleVelocity()
			if self:GetDisabled() then self:SpiralFire() return end
			pObj:AddAngleVelocity( Vector(AF.r,AF.p,AF.y) - AVel ) 
			
			pObj:SetVelocityInstantaneous( self:GetForward() * speed )
		end
	end
end

function ENT:Initialize()
	self:SetModel("models/cpthazama/starfox/items/smartbomb_proj.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:PhysWake()
	local pObj = self:GetPhysicsObject()
	
	if IsValid( pObj ) then
		pObj:EnableGravity( false ) 
		pObj:SetMass( 1 ) 
	end
	
	self.DisableChase = false
	self.SpawnTime = CurTime()
end

function ENT:Think()	
	local curtime = CurTime()
	self:NextThink( curtime )
	
	local Target = self:GetLockOn()
	if IsValid( Target ) then
		if self.DisableChase == true then
			self:SpiralFire()
			return
		end
		self:FollowTarget( Target )
	else
		if self.FireStraight then
			self:BlindFire()
		else
			self:SpiralFire()
		end
	end
	
	if self.MarkForRemove then
		self:Remove()
	end
	
	if self.Explode then
		local Inflictor = self:GetInflictor()
		local Attacker = self:GetAttacker()
		util.BlastDamage( IsValid( Inflictor ) && Inflictor or Entity(0), IsValid( Attacker ) && Attacker or Entity(0), self:GetPos(),self.DMGDist,self.DMG)
		
		self:Remove()
	end
	
	if (self.SpawnTime + 12) < curtime then
		self:Remove()
	end
	
	return true
end

function ENT:PhysicsCollide( data )
	if self:GetDisabled() then
		self.MarkForRemove = true
	else
		self.Explode = true
	end
end

function ENT:OnTakeDamage( dmginfo )	
	if dmginfo:GetDamageType() ~= DMG_AIRBOAT then return end
	
	if self:GetAttacker() == dmginfo:GetAttacker() then return end
	
	if !self:GetDisabled() then
		self:SetDisabled( true )
		
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:EnableGravity( true )
			self:PhysWake()
			self:EmitSound( "Missile.ShotDown" )
		end
	end
end

if SERVER then return end

function ENT:Initialize()	
	self.Emitter = ParticleEmitter( self:GetPos(), false )
	self.Materials = {
		"sprites/strider_bluebeam"
	}
	
	self.snd = CreateSound(self, "weapons/flaregun/burn.wav")
	self.snd:Play()
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	if self.Disabled then return end
	local pos = self:GetPos()
	local r = 0
	local g = 161
	local b = 255
	render.SetMaterial( mat )
	if self:GetCleanMissile() then
		for i =0,10 do
			local Size = (10 - i) * 25.6
			render.DrawSprite( pos - self:GetForward() * i * 5, 0.3, 0.3, Color( r, g, b, 255 ) )
		end
	end
	render.DrawSprite( pos, 70, 70, Color( r, g, b, 255 ) )
end

function ENT:Think()
	local curtime = CurTime()

	local effect = "sprites/strider_bluebeam"
	
	self.SmokeEmitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.SmokeEmitter:Add(effect,self:GetPos())
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.6)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)
	self.SmokeEmitter:Finish()

	self.NextFX = self.NextFX or 0
	
	if self.NextFX < curtime then
		self.NextFX = curtime + 0.02
		
		local pos = self:LocalToWorld( Vector(-8,0,0) )
		
		if self:GetDisabled() then 
			if !self.Disabled then
				self.Disabled = true
				
				if self.snd then
					self.snd:Stop()
				end
			end
			
			self:doFXbroken( pos )
			
			return
		end
		
		self:doFX( pos )
	end
	
	return true
end

function ENT:doFXbroken( pos )
	local emitter = self.Emitter
	if !emitter then return end
	
	local particle = emitter:Add( self.Materials[math.random(1, table.Count(self.Materials) )], pos )
	
	if particle then
		particle:SetGravity( Vector(0,0,100) + VectorRand() * 50 ) 
		particle:SetVelocity( -self:GetForward() * 500  )
		particle:SetAirResistance( 600 ) 
		particle:SetDieTime( math.Rand(4,6) )
		particle:SetStartAlpha( 150 )
		particle:SetStartSize( math.Rand(6,12) )
		particle:SetEndSize( math.Rand(40,90) )
		particle:SetRoll( math.Rand( -1, 1 ) )
		particle:SetColor( 50,50,50 )
		particle:SetCollide( false )
	end

	local particle = emitter:Add( "particles/flamelet"..math.random(1,5), self:GetPos() )
	if particle then
		particle:SetVelocity( -self:GetForward() * 500 + VectorRand() * 50 )
		particle:SetDieTime( 0.25 )
		particle:SetAirResistance( 600 ) 
		particle:SetStartAlpha( 255 )
		particle:SetStartSize( math.Rand(25,40) )
		particle:SetEndSize( math.Rand(10,15) )
		particle:SetRoll( math.Rand(-1,1) )
		particle:SetColor( 255,255,255 )
		particle:SetGravity( Vector( 0, 0, 0 ) )
		particle:SetCollide( false )
	end
end

function ENT:doFX( pos )
	local emitter = self.Emitter
	if !emitter then return end

	if self:GetDirtyMissile() then
		local particle = emitter:Add( self.Materials[math.random(1, table.Count(self.Materials) )], pos )
		if particle then
			particle:SetGravity( Vector(0,0,100) + VectorRand() * 50 ) 
			particle:SetVelocity( -self:GetForward() * 500  )
			particle:SetAirResistance( 600 ) 
			particle:SetDieTime( math.Rand(2,3) )
			particle:SetStartAlpha( 100 )
			particle:SetStartSize( math.Rand(10,13) )
			particle:SetEndSize( math.Rand(25,60) )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetColor( 50,50,50 )
			particle:SetCollide( false )
		end

		local particle = emitter:Add( "particles/flamelet"..math.random(1,5), pos )
		if particle then
			particle:SetVelocity( -self:GetForward() * math.Rand(500,1600) + self:GetVelocity())
			particle:SetDieTime( math.Rand(0.2,0.4) )
			particle:SetAirResistance( 0 ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand(20,30) )
			particle:SetEndSize( 10 )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 0,161,255 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetCollide( false )
		end
		
		local particle = emitter:Add( "particles/flamelet"..math.random(1,5), self:GetPos() )
		if particle then
			particle:SetVelocity( -self:GetForward() * 500 + VectorRand() * 50 )
			particle:SetDieTime( 0.25 )
			particle:SetAirResistance( 600 ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand(13,20) )
			particle:SetEndSize( math.Rand(5,7) )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 0,161,255 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetCollide( false )
		end
	else
		if !self:GetCleanMissile() then
			local particle = emitter:Add( self.Materials[math.random(1, table.Count(self.Materials) )], pos )
			
			if particle then
				particle:SetGravity( Vector(0,0,100) + VectorRand() * 50 ) 
				particle:SetVelocity( -self:GetForward() * 500  )
				particle:SetAirResistance( 600 ) 
				particle:SetDieTime( math.Rand(4,6) )
				particle:SetStartAlpha( 150 )
				particle:SetStartSize( math.Rand(6,12) )
				particle:SetEndSize( math.Rand(40,90) )
				particle:SetRoll( math.Rand( -1, 1 ) )
				particle:SetColor( 50,50,50 )
				particle:SetCollide( false )
			end
		end
		
		local particle = emitter:Add( "particles/flamelet"..math.random(1,5), pos )
		if particle then
			particle:SetVelocity( -self:GetForward() * 300 + self:GetVelocity())
			particle:SetDieTime( 0.1 )
			particle:SetAirResistance( 0 ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 4 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 0,161,255 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetCollide( false )
		end
	end
end

function ENT:OnRemove()
	if self.snd then
		self.snd:Stop()
	end
	
	local Pos = self:GetPos()
	
	self:Explosion( Pos + self:GetVelocity() / 20 )
	
	local random = math.random(1,2)
	
	sound.Play(self.ExplodeSound, Pos, 95, 140, 1 )
	
	if self.Emitter then
		self.Emitter:Finish()
	end
end

function ENT:Explosion( pos )
	local emitter = self.Emitter
	if !emitter then return end
	
	for i = 0,60 do
		local particle = emitter:Add( self.Materials[math.random(1,table.Count( self.Materials ))], pos )
		
		if particle then
			particle:SetVelocity( VectorRand(-1,1) * 600 )
			particle:SetDieTime( math.Rand(4,6) )
			particle:SetAirResistance( math.Rand(200,600) ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand(10,30) )
			particle:SetEndSize( math.Rand(80,120) )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 50,50,50 )
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetCollide( false )
		end
	end
	
	for i = 0, 40 do
		local particle = emitter:Add( "sprites/flamelet"..math.random(1,5), pos )
		
		if particle then
			particle:SetVelocity( VectorRand(-1,1) * 500 )
			particle:SetDieTime( 0.14 )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 10 )
			particle:SetEndSize( math.Rand(30,60) )
			particle:SetEndAlpha( 100 )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetColor( 0,161,255 )
			particle:SetCollide( false )
		end
	end
	
	local dlight = DynamicLight( math.random(0,9999) )
	if dlight then
		dlight.pos = pos
		dlight.r = 0
		dlight.g = 161
		dlight.b = 255
		dlight.brightness = 8
		dlight.Decay = 2000
		dlight.Size = 200
		dlight.DieTime = CurTime() + 0.1
	end
end