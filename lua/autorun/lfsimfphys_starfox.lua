print("Loading [LFSimfphys] Star Fox Autorun file...")

SF_AI_TEAM_CORNERIA = 1
SF_AI_TEAM_ANDROSS = 2
SF_AI_TEAM_APAROID = 5

SF_MUS = {}

SF_AI_UNIQUE = {
	["Fox"] = NULL,
	["Falco"] = NULL,
	["Slippy"] = NULL,
	["Peppy"] = NULL,
	["Krystal"] = NULL,
	["Bill"] = NULL,
	["Dash"] = NULL,

	["Wolf"] = NULL,
	["Leon"] = NULL,
	["Andrew"] = NULL,
	["Pigma"] = NULL,
	["Panther"] = NULL,
}

local PLY = FindMetaTable("Player")

local tblSetTeamText = {
	[0] = "Everyone Are Allies",
	[1] = "Team 1 / Corneria Faction",
	[2] = "Team 2 / Andross Faction",
	[3] = "No Allies",
	[SF_AI_TEAM_APAROID] = "Aparoid Faction",
}

function PLY:lfsSetAITeam(iTeam)
	iTeam = iTeam or simfphys.LFS.PlayerDefaultTeam:GetInt()

	if self:lfsGetAITeam() != iTeam && tblSetTeamText[iTeam] then -- Really? You couldn't add this check yourself? Expected from someone who still uses NW instead of NW2
		self:PrintMessage(HUD_PRINTTALK,"[LFS] Your AI-Team has been updated to: " .. tblSetTeamText[iTeam])
	end
	self:SetNWInt("lfsAITeam",iTeam)
end

if CLIENT then
function SF_CreateTrack(song,ply,ID)
	if song == false or song == nil then return end
	sound.PlayFile("sound/" .. song,"noplay noblock",function(soundchannel,errorID,errorName)
		if IsValid(soundchannel) then
			soundchannel:Play()
			soundchannel:EnableLooping(true)
			soundchannel:SetVolume(0.8)
			soundchannel:SetPlaybackRate(1)
			table.insert(SF_MUS,{ID=ID,Channel=soundchannel})
		end
	end)
end

function SF_StopTrack(track,isID)
	if isID then
		for _,v in pairs(SF_MUS) do
			if v && IsValid(v.Channel) && v.ID == track then
				v.Channel:Stop()
			end
		end
		return
	end
	if IsValid(track) then
		track:Stop()
	end
end

function SF_StopAllTracks()
	for _,v in pairs(SF_MUS) do
		if v && IsValid(v.Channel) then
			SF_StopTrack(v)
		end
	end
end

hook.Add("HUDPaint","StarFox_AI",function()
	local ply = LocalPlayer()
	local vehicle = ply:lfsGetPlane()
	if !IsValid(vehicle) then return end
	ply.SF_NextTalkT = ply.SF_NextTalkT or 0
	ply.SF_TalkT = ply.SF_TalkT or 0
	ply.SF_TalkTexture = ply.SF_TalkTexture or nil

	if ply.SF_TalkT > CurTime() then
		local scale = 350
		local x = ScrW() *0.075
		local y = ScrH() *0.87
		surface.SetMaterial(ply.SF_TalkTexture)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRectRotated(x,y,scale,scale,0)
	end
end)
end

print("Successfully Loaded [LFSimfphys] Star Fox Autorun file!")