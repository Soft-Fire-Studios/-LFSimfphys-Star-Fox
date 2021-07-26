print("Loading [LFSimfphys] Star Fox Pilot AI file...")

ENT.PilotCode = true

ENT.VO_DeathSound = false -- Did they run the death sound code yet?

ENT.Lines = {}
ENT.LinesDeath = {}

function ENT:PlayVOSound(ply)
	local VO = self:GetNW2String("VO")
	tbl = self.VO_DeathSound == true && self.LinesDeath[VO] or self.Lines[VO]
	return VJ_PICK(tbl)
end

function ENT:DoVOSound()
	for _,ply in RandomPairs(player.GetAll()) do
		local plyTeam = ply:lfsGetAITeam()
		local team = self:GetNW2Int("Team")
		if self:GetAI() && team != plyTeam then
			local vehicle = ply:lfsGetPlane()
			if !IsValid(vehicle) then continue end
			local VO = self:GetNW2String("VO")
			if !VO then continue end
			self.SF_NextTalkT = self.SF_NextTalkT or CurTime() +math.Rand(5,60)
			ply.SF_NextTalkT = ply.SF_NextTalkT or 0
			ply.SF_TalkT = ply.SF_TalkT or 0
			ply.SF_TalkTexture = ply.SF_TalkTexture or nil
			if CurTime() > self.SF_NextTalkT && CurTime() > ply.SF_NextTalkT && math.random(1,100) < 30 then
				local snd = self:PlayVOSound(ply,tbl)
				if !snd then continue end
				local snddur = SoundDuration(snd) +1
				ply:EmitSound(snd,110,100,1)
				-- EmitSound(snd,ply:EyePos(),-2,CHAN_STATIC,1,90,0,100)
				ply.SF_TalkTexture = Material("hud/starfox/vo_" .. VO .. ".vtf")
				ply.SF_TalkT = CurTime() +snddur
				ply.SF_NextTalkT = ply.SF_TalkT +0.2
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