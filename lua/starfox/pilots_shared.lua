print("Loading [LFSimfphys] Star Fox Pilot AI file...")

include("subtitles.lua")

ENT.PilotCode = true

ENT.VO_DeathSound = false -- Did they run the death sound code yet?

ENT.Lines = {}
ENT.LinesDeath = {}

local lerpColor = Vector(0,255,63)
local lerpColor2 = Vector(0,255,63)
local lerpColor3 = Vector(255,93,0)
local HUDVO = Material("hud/starfox/HUD_VO.png")
local HUDMessage = Material("hud/starfox/HUD_Message.png")
hook.Add("HUDPaint","StarFox_AI",function()
	local ply = LocalPlayer()

	ply.SF_NextTalkT = ply.SF_NextTalkT or 0
	ply.SF_TalkT = ply.SF_TalkT or 0
	ply.SF_TalkTexture = ply.SF_TalkTexture or nil
	ply.SF_CurrentVO = ply.SF_CurrentVO or nil
	ply.SF_CurrentVOEntity = ply.SF_CurrentVOEntity or NULL
	ply.SF_CurrentSound = ply.SF_CurrentSound or nil

	-- ply.SF_TalkT = CurTime() +1
	-- ply.SF_TalkTexture = Material("hud/starfox/vo_wolf_assault.vtf")
	-- ply.SF_CurrentVO = "Wolf O'Donnell"
	-- ply.SF_CurrentSound = "cpthazama/starfox/vo/wolf/WollfCant let you do that.mp3"

	if ply.SF_TalkT > CurTime() then
		local ent = ply.SF_CurrentVOEntity
		local scale = 250
		local x = ScrW() *0.24
		local y = ScrH() *0.89
		local tX = ScrW() *0.191
		local tY = ScrH() *0.803
		local boxText = ply.SF_CurrentSound != nil && SF_SUBTITLES && SF_SUBTITLES[ply.SF_CurrentSound] or "[Subtitles Missing for Sound]" // false
		local textSize = boxText && surface.GetTextSize(boxText) or scale *1.25
		local boxSize = scale +textSize *3.08
		local barLen = ScrW() *0.177

		draw.RoundedBox(1,tX,tY -20,ScrW() *0.464,scale +20,Color(5,5,5,225))

		local posX = (tX +scale *4.75) *0.45
		local posY = tY +scale *0.065
		local len = boxSize *0.378
		local height = 20
		local hp = IsValid(ent) && ent:GetHP() or 0
		local hpMax = IsValid(ent) && ent:GetMaxHP() or 1
		local hpPercent = hp /hpMax
		local shield = IsValid(ent) && ent:GetShield() or 0
		local shieldMax = IsValid(ent) && ent:GetMaxShield() or 1
		local shieldPercent = shield /shieldMax
		lerpColor = LerpVector(FrameTime() *10,lerpColor,hpPercent >= 0.75 && Vector(0,255,63) or hpPercent < 0.75 && hpPercent > 0.25 && Vector(255,255,0) or Vector(255,0,0))

		surface.SetMaterial(ply.SF_TalkTexture)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRectRotated(x,y,scale,scale,0)

		surface.SetMaterial(HUDVO)
		surface.SetDrawColor(0,107,5)
		surface.DrawTexturedRectRotated(x,y -15,scale,scale *1.13,0)

		local posX_2 = tX *2.475
		local posY_2 = tY *1.095
		surface.SetMaterial(HUDMessage)
		surface.SetDrawColor(0,107,5)
		surface.DrawTexturedRectRotated(posX_2,posY_2,943.2,282,0)

		surface.SetFont("CloseCaption_Bold")
		surface.SetTextColor(0,255,42)
		surface.SetTextPos((tX +scale *4.125) *0.5,tY -18)
		surface.DrawText(SF_AI_TRANSLATE[ply.SF_CurrentVO] or ply.SF_CurrentVO)
	
		draw.RoundedBox(1,posX,posY,barLen,height,Color(0,0,0,150))
		draw.RoundedBox(1,posX,posY,math.Clamp(barLen *(hpPercent),0,barLen),height,Color(lerpColor.x,lerpColor.y,lerpColor.z))
		draw.RoundedBox(1,posX,posY,math.Clamp(barLen *(shieldPercent),0,barLen),height,Color(0,110,255,math.abs(math.sin(CurTime() *1) *150)))

		if boxText then
			surface.SetFont("CloseCaption_Bold")
			surface.SetTextColor(0,255,42)
			surface.SetTextPos((tX +scale *4.125) *0.5,tY +scale *0.22)
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
	local hp = IsValid(vehicle) && vehicle:GetHP() or 0
	local hpMax = IsValid(vehicle) && vehicle:GetMaxHP() or 1
	local hpPercent = hp /hpMax
	local shield = IsValid(vehicle) && vehicle:GetShield() or 0
	local shieldMax = IsValid(vehicle) && vehicle:GetMaxShield() or 1
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

function ENT:OnTakeDamage(dmginfo)
	SF.OnTakeDamage(self,dmginfo)
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