print("Loading [LFSimfphys] Star Fox Autorun file...")

// https://github.com/Blu-x92/LunasFlightSchool/blob/master/lfs%20useful%20lua%20functions.txt

CreateConVar("lfs_sf_voteams",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"If enabled, only enemy VO will appear on your screen")
CreateConVar("lfs_sf_xpvehicle",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Only allow XP to be earned while using vehicles")
CreateConVar("lfs_sf_cameraspeed",3,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Update speed of the third person camera")
CreateConVar("lfs_sf_mission_allies",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Enables the spawning of allies in missions")
CreateConVar("lfs_sf_mission_forceply",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Enables the forcing of players into vehicles during missions")
CreateClientConVar("lfs_sf_ship","lfs_starfox_arwing",true,true)
CreateClientConVar("lfs_sf_currentship","lfs_starfox_arwing",true,true)
CreateClientConVar("lfs_sf_xpchat","1",true,true)
CreateClientConVar("lfs_sf_menumusic","1",true,true)

AddCSLuaFile("starfox/functions.lua")
include("starfox/functions.lua")
include("starfox/customization.lua")

SF_C.CreateDir("player")
SF_C.CreateDir("customization")
SF_C.CreateDir("factions")

SF_GACHA_RATE_PILOTS = 1
SF_GACHA_RATE_PARTS = 1
SF_GACHA_MULT_PART = 1
SF_GACHA_MULT_XP = 1

SF_CAMERA_CURRENT = NULL

SF_MAX_LEVEL = 50

SF_AI_TEAM_CORNERIA = 1
SF_AI_TEAM_ANDROSS = 2
SF_AI_TEAM_APAROID = 5

if CLIENT then
	local dir = "autorun/vehicles/" // Initialize simfphys vehicles
	for _,v in pairs(file.Find(dir .. "*","LUA")) do
		AddCSLuaFile(dir .. v)
		include(dir .. v)
	end

	-- SF.AddMissionData(1,"Test Star Wolf","Test","entities/lfs_starfox_mission_assault_2.png",true)

	local ships = {
		["lfs_starfox_arwing_zero"] = "Arwing Mk. I",
		["lfs_starfox_arwing"] = "Arwing Mk. II",
		["lfs_starfox_arwing_command"] = "Arwing Mk. III",
		["lfs_starfox_arwing_64"] = "Arwing Mk. I (64)",
		["lfs_starfox_cornerian_fighter_old"] = "Cornerian Fighter Mk. I",
		["lfs_starfox_cornerian_fighter"] = "Cornerian Fighter Mk. II",
		["lfs_starfox_cornerian_cruiser"] = "Cornerian Cruiser Mk. II",
		["lfs_starfox_cornerian_fighter_aparoid"] = "Cornerian Fighter Mk. II (Infected)",
		["lfs_starfox_venom_bomber"] = "Venomian Stealth Bomber",
		["lfs_starfox_venom_cruiser"] = "Venomian Cruiser Mk. II",
		["lfs_starfox_venom_fighter"] = "Venomian Figher Mk. II",
		["lfs_starfox_venom_fighter_dragon"] = "Venomian Figher Mk. I",
		["lfs_starfox_wolfen"] = "Wolfen Mk. II",
		["lfs_starfox_wolfen_zero"] = "Wolfen Mk. I",
		["lfs_starfox_wolfen_64"] = "Wolfen Mk. I (64)",
		["lfs_starfox_wolfen_zero_boss"] = "Wolfen Mk. I",
		["lfs_starfox_wolfen_ii"] = "Wolfen II (64)",
		["lfs_starfox_wolfen_ii_zero"] = "Wolfen II",
		["lfs_starfox_wolfen_redfang"] = "Wolfen Mk. III",
		["lfs_starfox_wolfen_blackrose"] = "Wolfen Mk. III (Black Rose)",
		["lfs_starfox_wolfen_clawfight"] = "Wolfen Mk. III (Claw Fight)",
		["lfs_starfox_wolfen_rainbowdelta"] = "Wolfen Mk. III (Rainbow Delta)",
	}
	for class,name in pairs(ships) do
		language.Add(class,name)
		language.Add("#" .. class,name)
		killicon.Add(class,"HUD/killicons/default",Color(255,80,0,255))
		killicon.Add("#" .. class,"HUD/killicons/default",Color(255,80,0,255))
	end

	SF_AI_TRANSLATE_TEXTURE = {
		["Wolf (Zero)"] = "wolf",
	}

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

		["Wolf (Zero)"] = "Wolf O'Donnell",
		["Leon (Zero)"] = "Leon Powalski",
		["Andrew (Zero)"] = "Andrew Oikonny",
		["Pigma (Zero)"] = "Pigma Dengar",

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

	["Wolf (Zero)"] = NULL,
	["Leon (Zero)"] = NULL,
	["Andrew (Zero)"] = NULL,
	["Pigma (Zero)"] = NULL,

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
	util.AddNetworkString("SF_PlayVO")

	hook.Add("PlayerEnteredVehicle","SF_PlayerEnteredVehicle",function(ply,ent,seatID)
		if ply:Nick() == "Cpt. Hazama" then
			VJ_CreateSound(ply,"cpthazama/starfox/vo/wolf_assault/enter_ship.wav",72)
			-- local vehicle = ply:lfsGetPlane()
			-- vehicle:ToggleEngine()
		end
	end)

	hook.Add("OnNPCKilled","SF_NPCKilled",function(ent,killer,weapon)
		if IsValid(killer) && killer:IsPlayer() then
			local vehicle = killer:lfsGetPlane()
			local vehOnly = GetConVar("lfs_sf_xpvehicle"):GetBool()
			local xp = SF.CalcXP(ent)
			if !vehOnly then
				SF.SetXP(killer,xp,true)
			end
			if IsValid(vehicle) then
				if vehOnly then
					SF.SetXP(killer,xp,true)
				end
				SF.SetXP(killer,xp,true,true)
			end
		end
	end)

	hook.Add("PlayerInitialSpawn","SF_PlayerInitSpawn",function(ply)
		SF.SetLockStatus(ply,"lfs_starfox_arwing",true)
	end)

	hook.Add("PlayerDeath","SF_PlayerKilled",function(ent,killer,weapon)
		if IsValid(killer) && killer:IsPlayer() && killer != ent then
			local vehicle = killer:lfsGetPlane()
			local vehOnly = GetConVar("lfs_sf_xpvehicle"):GetBool()
			local xp = SF.CalcXP(ent)
			if !vehOnly then
				SF.SetXP(killer,xp,true)
			end
			if IsValid(vehicle) then
				if vehOnly then
					SF.SetXP(killer,xp,true)
				end
				SF.SetXP(killer,xp,true,true)
			end
		end
	end)
end

SFSIM = SFSIM or {}

if CLIENT then
	local function GetTrackPos( ent, div, smoother )
		local spin_left = ent.trackspin_l and (-ent.trackspin_l / div) or 0
		local spin_right = ent.trackspin_r and (-ent.trackspin_r / div) or 0

		ent.sm_TrackDelta_L = ent.sm_TrackDelta_L and (ent.sm_TrackDelta_L + (spin_left - ent.sm_TrackDelta_L) * smoother) or 0
		ent.sm_TrackDelta_R = ent.sm_TrackDelta_R and (ent.sm_TrackDelta_R + (spin_right- ent.sm_TrackDelta_R) * smoother) or 0

		return {Left = ent.sm_TrackDelta_L,Right = ent.sm_TrackDelta_R}
	end

	local function UpdateTrackScrollTexture( ent )
		local id = ent:EntIndex()

		if not ent.wheel_left_mat then
			local left_mat_table = {
				["$basetexture"] = ent.TrackTexture,
				["$alphatest"] = "1",
				["$translate"] = "[0.0 0.0 0.0]",
				["Proxies"] = {
					["TextureTransform"] = {
						["translateVar"] = "$translate",
						["centerVar"]    = "$center",
						["resultVar"]    = "$basetexturetransform",
						}
					}
				}
			if ent.TrackNormal then
				left_mat_table["$bumpmap"] = ent.TrackNormal
			end
			ent.wheel_left_mat = CreateMaterial(ent.TrackID .. "trackmat_" .. id .. "_left", "VertexLitGeneric", left_mat_table )
		end

		if not ent.wheel_right_mat then
			local right_mat_table = {
				["$basetexture"] = ent.TrackTexture,
				["$alphatest"] = "1",
				["$translate"] = "[0.0 0.0 0.0]",
				["Proxies"] = {
					["TextureTransform"] = {
						["translateVar"] = "$translate",
						["centerVar"]    = "$center",
						["resultVar"]    = "$basetexturetransform",
						}
					}
				}
			if ent.TrackNormal then
				right_mat_table["$bumpmap"] = ent.TrackNormal
			end
			ent.wheel_right_mat = CreateMaterial(ent.TrackID .. "trackmat_" .. id .. "_right", "VertexLitGeneric", right_mat_table )
		end

		local TrackPos = GetTrackPos( ent, ent.TrackDiv, ent.TrackMult )

		ent.wheel_left_mat:SetVector("$translate", Vector(0,TrackPos.Left,0) )
		ent.wheel_right_mat:SetVector("$translate", Vector(0,TrackPos.Right,0) )

		ent:SetSubMaterial( ent.LeftTrackSubMatIndex or 1, "!" .. ent.TrackID .. "trackmat_" .. id .. "_left" )
		ent:SetSubMaterial( ent.RightTrackSubMatIndex or 2, "!" .. ent.TrackID .. "trackmat_" .. id .. "_right" )
	end

	local function UpdateTracks()
		for i, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
			if ent.TrackID then
				UpdateTrackScrollTexture(ent)
			end
		end
	end

	hook.Add( "Think", "SFSIM_misc_manage_tanks", function()
		UpdateTracks()
	end )

	SFSIM.VehicleSettings = SFSIM.VehicleSettings or {}

	net.Receive( "SFSIM_misc_register_tank", function( length )
		local ent = net.ReadEntity()
		local type = net.ReadString()

		if not IsValid( ent ) then return end

		local settings = SFSIM.VehicleSettings[type]

		ent.TrackID = settings.TrackID
		ent.TrackTexture = settings.TrackTexture
		ent.TrackNormal = settings.TrackNormal
		ent.TrackDiv = settings.TrackDiv
		ent.TrackMult = settings.TrackMult
		ent.LeftTrackSubMatIndex = settings.LeftTrackSubMatIndex
		ent.RightTrackSubMatIndex = settings.RightTrackSubMatIndex
	end)
elseif SERVER then
	util.AddNetworkString( "SFSIM_misc_register_tank" )
end

local function bcDamage( vehicle , position , cdamage )
	if not simfphys.DamageEnabled then return end
	
	cdamage = cdamage or false
	net.Start( "simfphys_spritedamage" )
		net.WriteEntity( vehicle )
		net.WriteVector( position ) 
		net.WriteBool( cdamage ) 
	net.Broadcast()
end

local function DestroyVehicle( ent )
	if not IsValid( ent ) then return end
	if ent.destroyed then return end
	
	ent.destroyed = true
	
	local ply = ent.EntityOwner
	local skin = ent:GetSkin()
	local Col = ent:GetColor()
	Col.r = Col.r * 0.8
	Col.g = Col.g * 0.8
	Col.b = Col.b * 0.8
	
	local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
	bprop:SetModel( ent:GetModel() )			
	bprop:SetPos( ent:GetPos() )
	bprop:SetAngles( ent:GetAngles() )
	bprop:Spawn()
	bprop:Activate()
	bprop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
	bprop:GetPhysicsObject():SetMass( ent.Mass * 0.75 )
	bprop.DoNotDuplicate = true
	bprop.MakeSound = true
	bprop:SetColor( Col )
	bprop:SetSkin( skin )
	
	ent.Gib = bprop
	
	simfphys.SetOwner( ply , bprop )
	
	if IsValid( ply ) then
		undo.Create( "Gib" )
		undo.SetPlayer( ply )
		undo.AddEntity( bprop )
		undo.SetCustomUndoText( "Undone Gib" )
		undo.Finish( "Gib" )
		ply:AddCleanup( "Gibs", bprop )
	end
	
	if ent.CustomWheels == true and not ent.NoWheelGibs then
		for i = 1, table.Count( ent.GhostWheels ) do
			local Wheel = ent.GhostWheels[i]
			if IsValid(Wheel) then
				local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
				prop:SetModel( Wheel:GetModel() )			
				prop:SetPos( Wheel:LocalToWorld( Vector(0,0,0) ) )
				prop:SetAngles( Wheel:LocalToWorldAngles( Angle(0,0,0) ) )
				prop:SetOwner( bprop )
				prop:Spawn()
				prop:Activate()
				prop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(0,25)) )
				prop:GetPhysicsObject():SetMass( 20 )
				prop.DoNotDuplicate = true
				bprop:DeleteOnRemove( prop )
				
				simfphys.SetOwner( ply , prop )
			end
		end
	end
	
	local Driver = ent:GetDriver()
	if IsValid( Driver ) then
		if ent.RemoteDriver ~= Driver then
			Driver:TakeDamage( Driver:Health() + Driver:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
		end
	end
	
	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			if IsValid( Passenger ) then
				Passenger:TakeDamage( Passenger:Health() + Passenger:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
			end
		end
	end
	
	ent:Extinguish() 
	
	ent:OnDestroyed()
	
	ent:Remove()
end

local function DamageVehicle( ent , damage, type )
	if not simfphys.DamageEnabled then return end
	
	local MaxHealth = ent:GetMaxHealth()
	local CurHealth = ent:GetCurHealth()
	
	local NewHealth = math.max( math.Round(CurHealth - damage,0) , 0 )
	
	if NewHealth <= (MaxHealth * 0.6) then
		if NewHealth <= (MaxHealth * 0.3) then
			ent:SetOnFire( true )
			ent:SetOnSmoke( false )
		else
			ent:SetOnSmoke( true )
		end
	end
	
	if MaxHealth > 30 and NewHealth <= 31 then
		if ent:EngineActive() then
			ent:DamagedStall()
		end
	end
	
	if NewHealth <= 0 then
		if type ~= DMG_GENERIC and type ~= DMG_CRUSH or damage > 400 then
			
			DestroyVehicle( ent )
			
			return
		end
		
		if ent:EngineActive() then
			ent:DamagedStall()
		end
		
		return
	end
	
	ent:SetCurHealth( NewHealth )
end

function SFSIM.TankTakeDamage( ent, dmginfo )
	ent:TakePhysicsDamage( dmginfo )

	if not ent:IsInitialized() then return end

	local Damage = dmginfo:GetDamage()
	local DamagePos = dmginfo:GetDamagePosition()
	local Type = dmginfo:GetDamageType()

	ent.LastAttacker = dmginfo:GetAttacker() 
	ent.LastInflictor = dmginfo:GetInflictor()

	bcDamage( ent , ent:WorldToLocal( DamagePos ) )

	local Mul = 1

	if Damage < (ent.DamageThreshold or 80) then
			Mul = Damage / (80 or ent.DamageThreshold)
	end

	DamageVehicle( ent , Damage * Mul, Type )
end

print("Successfully Loaded [LFSimfphys] Star Fox Autorun file!")