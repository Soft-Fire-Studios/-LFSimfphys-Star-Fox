print("Loading [LFSimfphys] Star Fox Pilot AI file...")

include("subtitles.lua")

ENT.PilotCode = true

ENT.VO_DeathSound = false -- Did they run the death sound code yet?

ENT.Lines = {}
ENT.LinesDeath = {}

local lerpColor = Vector(0,255,63)
local lerpColor2 = Vector(0,255,63)
local lerpColor3 = Vector(255,93,0)
hook.Add("HUDPaint","StarFox_AI",function()
	local ply = LocalPlayer()

	ply.SF_NextTalkT = ply.SF_NextTalkT or 0
	ply.SF_TalkT = ply.SF_TalkT or 0
	ply.SF_TalkTexture = ply.SF_TalkTexture or nil
	ply.SF_CurrentVO = ply.SF_CurrentVO or nil
	ply.SF_CurrentVOEntity = ply.SF_CurrentVOEntity or NULL
	ply.SF_CurrentSound = ply.SF_CurrentSound or nil

	-- ply.SF_TalkT = CurTime() +1
	-- ply.SF_TalkTexture = Material("hud/starfox/vo_wolf.vtf")
	-- ply.SF_CurrentVO = "Wolf O'Donnell"
	-- ply.SF_CurrentSound = "cpthazama/starfox/vo/wolf/WollfCant let you do that.mp3"

	if ply.SF_TalkT > CurTime() then
		local ent = ply.SF_CurrentVOEntity
		local scale = 250
		local x = ScrW() *0.24
		local y = ScrH() *0.89
		local tX = ScrW() *0.191
		local tY = ScrH() *0.803
		local boxText = ply.SF_CurrentSound != nil && SF_SUBTITLES && SF_SUBTITLES[ply.SF_CurrentSound] or false
		local textSize = boxText && surface.GetTextSize(boxText) or scale *1.25
		local boxSize = scale +textSize *1.225

		draw.RoundedBox(1,tX,tY,boxSize,scale,Color(5,5,5,225))

		local posX = (tX +scale *4.75) *0.45
		local posY = tY +scale *0.235
		local len = boxSize *0.55
		local height = 20
		local hp = IsValid(ent) && ent:GetHP() or 100
		local hpMax = IsValid(ent) && ent:GetMaxHP() or 100
		local hpPercent = hp /hpMax
		local shield = IsValid(ent) && ent:GetShield() or 0
		local shieldMax = IsValid(ent) && ent:GetMaxShield() or 0
		local shieldPercent = shield /shieldMax
		lerpColor = LerpVector(FrameTime() *10,lerpColor,hpPercent >= 0.75 && Vector(0,255,63) or hpPercent < 0.75 && hpPercent > 0.25 && Vector(255,255,0) or Vector(255,0,0))
		draw.RoundedBox(1,posX,posY,len,height,Color(0,0,0,150))
		draw.RoundedBox(1,posX,posY,math.Clamp(len *(hpPercent),0,boxSize),height,Color(lerpColor.x,lerpColor.y,lerpColor.z))
		draw.RoundedBox(1,posX,posY,math.Clamp(len *(shieldPercent),0,boxSize),height,Color(0,110,255,math.abs(math.sin(CurTime() *1) *150)))

		surface.SetMaterial(ply.SF_TalkTexture)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRectRotated(x,y,scale,scale,0)

		surface.SetFont("CloseCaption_Bold")
		surface.SetTextColor(0,255,42)
		surface.SetTextPos((tX +scale *4.75) *0.5,tY +scale *0.1)
		surface.DrawText(SF_AI_TRANSLATE[ply.SF_CurrentVO] or ply.SF_CurrentVO)

		if boxText then
			surface.SetFont("CloseCaption_Bold")
			surface.SetTextColor(0,255,42)
			surface.SetTextPos(tX +scale *1.1,tY +scale *0.45)
			surface.DrawText(boxText)
		end
	else
		ply.SF_CurrentVO = nil
		ply.SF_CurrentVOEntity = NULL
		ply.SF_CurrentSound = nil
		ply.SF_TalkTexture = nil
	end

	local vehicle = ply:lfsGetPlane()
	if !IsValid(vehicle) then return end

	local x = ScrW() *0.7
	local y = ScrH() *0.41
	local barLength = 40
	local barHeight = 250
	local hp = IsValid(vehicle) && vehicle:GetHP() or 1
	local hpMax = IsValid(vehicle) && vehicle:GetMaxHP() or 1
	local hpPercent = hp /hpMax
	local shield = IsValid(vehicle) && vehicle:GetShield() or 0
	local shieldMax = IsValid(vehicle) && vehicle:GetMaxShield() or 0
	local shieldPercent = shield /shieldMax
	local throttle = IsValid(vehicle) && vehicle:GetThrottlePercent() or 0
	local throttleMax = 125
	local throttlePercent = throttle /throttleMax
	lerpColor2 = LerpVector(FrameTime() *10,lerpColor2,hpPercent >= 0.75 && Vector(0,255,63) or hpPercent < 0.75 && hpPercent > 0.25 && Vector(255,255,0) or Vector(255,0,0))
	lerpColor3 = LerpVector(FrameTime() *10,lerpColor3,throttlePercent >= 0.805 && Vector(255,0,0) or Vector(255,93,0))

	draw.RoundedBox(1,x,y,barLength,barHeight,Color(5,5,5,150))

	draw.RoundedBox(1,x,y,barLength /2,barHeight *hpPercent,Color(lerpColor.x,lerpColor.y,lerpColor.z))
	draw.RoundedBox(1,x,y,barLength /2,barHeight *shieldPercent,Color(0,110,255,math.abs(math.sin(CurTime() *1) *150)))

	draw.RoundedBox(1,x *1.0114,y,barLength /2,barHeight *throttlePercent,Color(lerpColor3.x,lerpColor3.y,lerpColor3.z))
end)

function ENT:DoVOSound()
	for _,ply in RandomPairs(player.GetAll()) do
		local plyTeam = ply:lfsGetAITeam()
		local team = self:GetNW2Int("Team")
		local reqTeam = GetConVar("lfs_sf_voteams"):GetBool()
		if self:GetAI() && (reqTeam && team != plyTeam or true) then
			-- local vehicle = ply:lfsGetPlane()
			-- if !IsValid(vehicle) then continue end
			local VO = self:GetNW2String("VO")
			if !VO then continue end
			self.SF_NextTalkT = self.SF_NextTalkT or CurTime() +math.Rand(5,10)
			ply.SF_NextTalkT = ply.SF_NextTalkT or 0
			ply.SF_TalkT = ply.SF_TalkT or 0
			ply.SF_TalkTexture = ply.SF_TalkTexture or nil
			if CurTime() > self.SF_NextTalkT && CurTime() > ply.SF_NextTalkT && math.random(1,100) < 30 then
				local snddur = SF.PlayVO(ply,SF.GetVOLine(self,VO),VO)
				if snddur == nil then continue end
				ply.SF_CurrentVOEntity = self
				self.SF_NextTalkT = CurTime() +snddur +math.Rand(15,40)
			end
		end
	end
end

function ENT:PilotThink()
	self:DoVOSound()
	if !self.VO_DeathSound && self:GetHP() <= 0 then
		self.VO_DeathSound = true
		self.SF_NextTalkT = 0
		self:DoVOSound()
	end
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )

	self:StopMaintenance()

	local Damage = dmginfo:GetDamage()
	local CurHealth = self:GetHP()
	local NewHealth = math.Clamp( CurHealth - Damage , -self:GetMaxHP(), self:GetMaxHP() )
	local ShieldCanBlock = dmginfo:IsBulletDamage() or dmginfo:IsDamageType( DMG_AIRBOAT )

	if ShieldCanBlock then
		local dmgNormal = -dmginfo:GetDamageForce():GetNormalized() 
		local dmgPos = dmginfo:GetDamagePosition()

		self:SetNextShieldRecharge( 3 )

		if self:GetMaxShield() > 0 and self:GetShield() > 0 then
			dmginfo:SetDamagePosition( dmgPos + dmgNormal * 250 * self:GetShieldPercent() )

			local effectdata = EffectData()
				effectdata:SetOrigin( dmginfo:GetDamagePosition() )
				effectdata:SetEntity( self )
			util.Effect( "lfs_shield_deflect", effectdata )

			self:TakeShieldDamage( Damage )
		else
			sound.Play( Sound( table.Random( {"physics/metal/metal_sheet_impact_bullet2.wav","physics/metal/metal_sheet_impact_hard2.wav","physics/metal/metal_sheet_impact_hard6.wav",} ) ), dmgPos, SNDLVL_70dB)
	
			local effectdata = EffectData()
				effectdata:SetOrigin( dmgPos )
				effectdata:SetNormal( dmgNormal )
			util.Effect( "MetalSpark", effectdata )
			
			self:SetHP( NewHealth )
		end
	else
		self:SetHP( NewHealth )
	end

	SF.OnDamage(self,dmginfo)
	
	if NewHealth <= 0 and not (self:GetShield() > Damage and ShieldCanBlock) then
		if not self:IsDestroyed() then
			self.FinalAttacker = dmginfo:GetAttacker() 
			self.FinalInflictor = dmginfo:GetInflictor()

			self:Destroy()
			
			self.MaxPerfVelocity = self.MaxPerfVelocity * 10
			local ExplodeTime = self:IsSpaceShip() and (math.Clamp((self:GetVelocity():Length() - 250) / 500,1.5,8) * math.Rand(0.2,1)) or (self:GetAI() and 30 or 9999)
			if self:IsGunship() then ExplodeTime = math.Rand(1,2) end

			local effectdata = EffectData()
				effectdata:SetOrigin( self:GetPos() )
			util.Effect( "lfs_explosion_nodebris", effectdata )

			local effectdata = EffectData()
				effectdata:SetOrigin( self:GetPos() )
				effectdata:SetStart( self:GetPhysicsObject():GetMassCenter() )
				effectdata:SetEntity( self )
				effectdata:SetScale( 1 )
				effectdata:SetMagnitude( ExplodeTime )
			util.Effect( "lfs_firetrail", effectdata )

			timer.Simple( ExplodeTime, function()
				if not IsValid( self ) then return end
				self:Explode()
			end)
		end
	end

	if NewHealth <= -self:GetMaxHP() then
		self:Explode()
	end
end

print("Successfully Loaded [LFSimfphys] Star Fox Pilot AI file!")

if CLIENT then return end -- Start Server Side Code

function ENT:OnSetPilot(pilot) end

function ENT:OnRemovePilot(pilot) end

function ENT:CreateAI()
	local selectable = self.Pilots or {"Wolf","Leon","Andrew","Pigma"}
	for name,ent in RandomPairs(SF_AI_UNIQUE) do
		if VJ_HasValue(selectable,name) && !IsValid(ent) then
			SF_AI_UNIQUE[name] = self
			self:SetNW2String("VO",name)
			self:OnSetPilot(name)
			break
		end
	end
end

function ENT:RemoveAI()
	local VO = self:GetNW2String("VO")
	SF_AI_UNIQUE[VO] = NULL

	self:OnRemovePilot(VO)
end