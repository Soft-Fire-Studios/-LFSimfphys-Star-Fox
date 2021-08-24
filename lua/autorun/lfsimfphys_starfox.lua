print("Loading [LFSimfphys] Star Fox Autorun file...")

CreateConVar("lfs_sf_voteams",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"If enabled, only enemy VO will appear on your screen")
CreateConVar("lfs_sf_cameraspeed",3,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Update speed of the third person camera")
CreateConVar("lfs_sf_mission_allies",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Enables the spawning of allies in missions")
CreateConVar("lfs_sf_mission_forceply",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Enables the forcing of players into vehicles during missions")
CreateClientConVar("lfs_sf_ship","arwing",true,true)

include("starfox/customization.lua")

SF_C.CreateDir("customization")
SF_C.CreateDir("factions")

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
		["lfs_starfox_venom_fighter_dragon"] = "Venomian Figher Mk. I",
		["lfs_starfox_wolfen"] = "Wolfen Mk. II",
		["lfs_starfox_wolfen_zero"] = "Wolfen Mk. I",
		["lfs_starfox_wolfen_ii"] = "Wolfen II (64)",
		["lfs_starfox_wolfen_ii_zero"] = "Wolfen II",
		["lfs_starfox_wolfen_redfang"] = "Wolfen Mk. III",
	}
	for class,name in pairs(ships) do
		language.Add(class,name)
		language.Add("#" .. class,name)
		killicon.Add(class,"HUD/killicons/default",Color(255,80,0,255))
		killicon.Add("#" .. class,"HUD/killicons/default",Color(255,80,0,255))
	end

	SF_AI_TRANSLATE = {
		["Fox"] = "Fox McCloud",
		["Falco"] = "Falco Lombardi",
		["Slippy"] = "Slippy Toad",
		["Peppy"] = "Peppy Hare",
		["Krystal"] = "Krystal",
		["Bill"] = "Bill Grey",
		["Dash"] = "Dash Bowman",
		["James"] = "James McCloud",
		["Katt"] = "Katt Monroe",

		["Wolf"] = "Wolf O'Donnell",
		["Leon"] = "Leon Powalski",
		["Andrew"] = "Andrew Oikonny",
		["Pigma"] = "Pigma Dengar",

		["Wolf_Assault"] = "Wolf O'Donnell",
		["Leon_Assault"] = "Leon Powalski",
		["Panther_Assault"] = "Panther Caroso",
	}
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
	["James"] = NULL,
	["Katt"] = NULL,

	["Wolf"] = NULL,
	["Leon"] = NULL,
	["Andrew"] = NULL,
	["Pigma"] = NULL,

	["Wolf_Assault"] = NULL,
	["Leon_Assault"] = NULL,
	["Panther_Assault"] = NULL,
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
function SF_CreateTrack(song,ply,ID,noplay)
	if song == false or song == nil then return end
	sound.PlayFile("sound/" .. song,"noplay noblock",function(soundchannel,errorID,errorName)
		if IsValid(soundchannel) then
			if noplay != true then
				soundchannel:Play()
			end
			soundchannel:EnableLooping(true)
			soundchannel:SetVolume(0.8)
			soundchannel:SetPlaybackRate(1)
			for k,v in pairs(SF_MUS) do
				if v && !IsValid(v.Channel) then
					table.remove(v,k)
				end
			end
			table.insert(SF_MUS,{ID=ID,Channel=soundchannel})
		end
	end)
end

function SF_PlayTrack(track,isID)
	if isID then
		for _,v in SortedPairs(SF_MUS) do
			if v && IsValid(v.Channel) && v.ID == track then
				v.Channel:Play()
				break
			end
		end
		return
	end
	if IsValid(track) then
		track:Play()
	end
end

function SF_PauseTrack(track,isID)
	if isID then
		for _,v in SortedPairs(SF_MUS) do
			if v && IsValid(v.Channel) && v.ID == track then
				v.Channel:Pause()
				break
			end
		end
		return
	end
	if IsValid(track) then
		track:Pause()
	end
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

if SERVER then
	hook.Add("PlayerEnteredVehicle","SF_PlayerEnteredVehicle",function(ply,ent,seatID)
		if ply:Nick() == "Cpt. Hazama" then
			VJ_CreateSound(ply,"cpthazama/starfox/vo/wolf_assault/enter_ship.wav",72)
			-- local vehicle = ply:lfsGetPlane()
			-- vehicle:ToggleEngine()
		end
	end)
end

print("Successfully Loaded [LFSimfphys] Star Fox Autorun file!")