print("Loading [LFSimfphys] Star Fox Autorun file...")

SF_AI_TEAM_CORNERIA = 1
SF_AI_TEAM_ANDROSS = 2
SF_AI_TEAM_APAROID = 5

if CLIENT then
	local ships = {
		["lfs_starfox_arwing"] = "Arwing Mk. II",
		["lfs_starfox_cornerian_fighter_aparoid"] = "Cornerian Fighter Mk. II (Infected)",
		["lfs_starfox_venom_bomber"] = "Venomian Stealth Bomber",
		["lfs_starfox_venom_cruiser"] = "Venomian Cruiser Mk. II",
		["lfs_starfox_venom_fighter"] = "Venomian Figher Mk. II",
		["lfs_starfox_wolfen"] = "Wolfen Mk. II",
		["lfs_starfox_wolfen_zero"] = "Wolfen Mk. I",
	}
	for class,name in pairs(ships) do
		language.Add(class,name)
		language.Add("#" .. class,name)
		killicon.Add(class,"HUD/killicons/default",Color(255,80,0,255))
		killicon.Add("#" .. class,"HUD/killicons/default",Color(255,80,0,255))
	end
end

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

-- function PLY:lfsGetAITeam()
-- 	print("RAN")
-- 	return self:GetNWInt("lfsAITeam",simfphys.LFS.PlayerDefaultTeam:GetInt())
-- end

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
end

print("Successfully Loaded [LFSimfphys] Star Fox Autorun file!")