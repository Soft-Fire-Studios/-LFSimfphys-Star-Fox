AddCSLuaFile()

local sfC = util.Compress
local sfD = util.Decompress

SF_C = SF_C or {}

if CLIENT then
    surface.CreateFont("StarFox_Default",{
        font = "Arwing",
        extended = false,
        size = 15,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("StarFox_Combat",{
        font = "Arwing",
        extended = false,
        size = 25,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = true,
    })
end

concommand.Add("lfs_sf_unlockship",function(ply,cmd,args,argStr)
    local ship = args[1]
    SF.SetLockStatus(ply,ship,true)
end)

concommand.Add("lfs_sf_gacha",function(ply,cmd,args,argStr)
    -- local ship = args[1]
    local results = SF.Gamble(ply)
end)

concommand.Add("lfs_sf_gacha_b",function(ply,cmd,args,argStr)
    -- local ship = args[1]
    for i = 1,5 do
        local results = SF.Gamble(ply)
    end
end)

local function compress(d)
	return sfC(d)
end

local function decompress(d)
	if type(d) == "table" then return d end
	if type(d) == "boolean" then return d end
	return sfD(d)
end

local function LZMA(dat,c)
	if c then
		local cDat = sfC(util.TableToJSON(dat,true))
		return cDat
	end
	local dDat = sfD(dat)
	return dDat
end

SF_C.CreateDir = function(dirName) // SF_C.CreateDir("customization")
	local dir = "lfsimfphys_starfox/" .. dirName .. "/"
    if !file.Exists(dir,"DATA") then
	    file.CreateDir(dir)
    end
end

SF_C.WriteData = function(fileName,dat,delete) // SF_C.WriteData("lfsimfphys_starfox/customization/lfs_starfox_arwing.dat",{Hip=true,Hop=false},true)
	dat = LZMA(dat,true)
	if delete then
		file.Write(fileName,dat)
		return
	end
	file.Append(fileName,dat)
end

SF_C.ReadData = function(fileName) // SF_C.ReadData("lfsimfphys_starfox/customization/lfs_starfox_arwing.dat")
	local data = file.Read(fileName,"DATA")
	if data == nil then return end
	local decompressed = LZMA(data)
	return (decompressed != nil && util.JSONToTable(decompressed)) or util.JSONToTable(data)
end

local function ShowStats(ply)
	net.Start("SF_Menu")
	net.Send(ply)
end
concommand.Add("lfs_sf_showmenu",ShowStats)

if SERVER then
    util.AddNetworkString("SF_Menu")
    return
end

net.Receive("SF_Menu",function(len,ply)
    local ply = LocalPlayer()

    ply.SFMenu_Katt = ply.SFMenu_Katt or 0
    ply.SFMenu_KattRand = ply.SFMenu_KattRand or 0
    ply.SFMenu_LastMenuID = 0

    if GetConVar("lfs_sf_menumusic"):GetInt() == 1 then
        sound.PlayFile("sound/cpthazama/starfox/music/menu.mp3","noplay noblock",function(station,errCode,errStr)
            if IsValid(station) then
                station:EnableLooping(true)
                station:Play()
                station:SetVolume(0.6)
                -- station:SetVolume(0)
                station:SetPlaybackRate(1)
                ply.SF_MenuTheme = station
            else
                print("Error playing sound!",errCode,errStr)
            end
            return station
        end)

        sound.PlayFile("sound/cpthazama/starfox/music/menu_good.mp3","noplay noblock",function(station,errCode,errStr)
            if IsValid(station) then
                station:EnableLooping(true)
                station:Play()
                -- station:SetVolume(0.6)
                station:SetVolume(0)
                station:SetPlaybackRate(1)
                ply.SF_MenuTheme_Good = station
            else
                print("Error playing sound!",errCode,errStr)
            end
            return station
        end)

        sound.PlayFile("sound/cpthazama/starfox/music/menu_bad.mp3","noplay noblock",function(station,errCode,errStr)
            if IsValid(station) then
                station:EnableLooping(true)
                station:Play()
                -- station:SetVolume(0.6)
                station:SetVolume(0)
                station:SetPlaybackRate(1)
                ply.SF_MenuTheme_Bad = station
            else
                print("Error playing sound!",errCode,errStr)
            end
            return station
        end)

        sound.PlayFile("sound/cpthazama/starfox/music/katt.mp3","noplay noblock",function(station,errCode,errStr)
            if IsValid(station) then
                station:EnableLooping(true)
                station:Play()
                -- station:SetVolume(0.6)
                station:SetVolume(0)
                station:SetPlaybackRate(1)
                ply.SF_MenuTheme_Gacha = station
            else
                print("Error playing sound!",errCode,errStr)
            end
            return station
        end)
    end
    
    local currentShip = LocalPlayer():GetInfo("lfs_sf_ship")
    surface.PlaySound("cpthazama/starfox/64/RadioTransmissionon.wav")

    local wMin,wMax = 1538,864
    local window = vgui.Create("DFrame")
    window:SetTitle("Star Fox Menu")
    window:SetSize(math.min(ScrW() -16,wMin),math.min(ScrH() -16,wMax))
    window:SetSizable(true)
    window:SetBackgroundBlur(true)
    window:SetMinWidth(wMin)
    window:SetMinHeight(wMax)
    window:SetDeleteOnClose(false)
    window:Center()
    window:MakePopup()
    window.LastMusicState = 0
    window.OnClose = function()
        if IsValid(ply) then
            ply:EmitSound("cpthazama/starfox/64/RadioTransmissionOff.wav",65)
            if IsValid(ply.SF_MenuTheme) && ply.SF_MenuTheme:GetState() == 1 then
                ply.SF_MenuTheme:Stop()
            end
            if IsValid(ply.SF_MenuTheme_Good) && ply.SF_MenuTheme_Good:GetState() == 1 then
                ply.SF_MenuTheme_Good:Stop()
            end
            if IsValid(ply.SF_MenuTheme_Bad) && ply.SF_MenuTheme_Bad:GetState() == 1 then
                ply.SF_MenuTheme_Bad:Stop()
            end
            if IsValid(ply.SF_MenuTheme_Gacha) && ply.SF_MenuTheme_Gacha:GetState() == 1 then
                ply.SF_MenuTheme_Gacha:Stop()
            end
        end
    end

    local function controlMusic(ply,play)
        if !IsValid(ply) then return end
        if GetConVar("lfs_sf_menumusic"):GetInt() == 0 then window.LastMusicState = play return end

        if play == 0 && window.LastMusicState != 0 then
            window.LastMusicState = 0
            if IsValid(ply.SF_MenuTheme) then
                ply.SF_MenuTheme:Play()
                ply.SF_MenuTheme:SetVolume(0.6)
            end
            if IsValid(ply.SF_MenuTheme_Good) then
                ply.SF_MenuTheme_Good:Pause()
                ply.SF_MenuTheme_Good:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Bad) then
                ply.SF_MenuTheme_Bad:Pause()
                ply.SF_MenuTheme_Bad:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Gacha) then
                ply.SF_MenuTheme_Gacha:Pause()
                ply.SF_MenuTheme_Gacha:SetVolume(0)
            end
        elseif play == 1 && window.LastMusicState != 1 then
            window.LastMusicState = 1
            if IsValid(ply.SF_MenuTheme) then
                ply.SF_MenuTheme:Pause()
                ply.SF_MenuTheme:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Good) then
                ply.SF_MenuTheme_Good:Play()
                ply.SF_MenuTheme_Good:SetVolume(0.6)
            end
            if IsValid(ply.SF_MenuTheme_Bad) then
                ply.SF_MenuTheme_Bad:Pause()
                ply.SF_MenuTheme_Bad:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Gacha) then
                ply.SF_MenuTheme_Gacha:Pause()
                ply.SF_MenuTheme_Gacha:SetVolume(0)
            end
        elseif play == 2 && window.LastMusicState != 2 then
            window.LastMusicState = 2
            if IsValid(ply.SF_MenuTheme) then
                ply.SF_MenuTheme:Pause()
                ply.SF_MenuTheme:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Good) then
                ply.SF_MenuTheme_Good:Pause()
                ply.SF_MenuTheme_Good:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Bad) then
                ply.SF_MenuTheme_Bad:Play()
                ply.SF_MenuTheme_Bad:SetVolume(0.6)
            end
            if IsValid(ply.SF_MenuTheme_Gacha) then
                ply.SF_MenuTheme_Gacha:Pause()
                ply.SF_MenuTheme_Gacha:SetVolume(0)
            end
        elseif play == 3 && window.LastMusicState != 3 then
            window.LastMusicState = 3
            if IsValid(ply.SF_MenuTheme) then
                ply.SF_MenuTheme:Pause()
                ply.SF_MenuTheme:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Good) then
                ply.SF_MenuTheme_Good:Pause()
                ply.SF_MenuTheme_Good:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Bad) then
                ply.SF_MenuTheme_Bad:Pause()
                ply.SF_MenuTheme_Bad:SetVolume(0)
            end
            if IsValid(ply.SF_MenuTheme_Gacha) then
                ply.SF_MenuTheme_Gacha:Play()
                ply.SF_MenuTheme_Gacha:SetVolume(0.6)
            end
        end
    end

    local sheet = window:Add("DPropertySheet")
    sheet:Dock(LEFT)
    sheet:SetSize(wMin *0.465,0)

    local modelListPnl = window:Add("DPanel")
    modelListPnl:DockPadding(8,8,8,8)

    local mdlPanel = window:Add("DPanel")
    mdlPanel:SetSize(wMin *0.535,0)
    mdlPanel:Dock(LEFT)
    mdlPanel:DockPadding(8,8,8,8)

    local mdl = mdlPanel:Add("DAdjustableModelPanel")
    mdl:Dock(FILL)
	mdl:SetAmbientLight(Color(255 *0.3,255 *0.3,255 *0.3))
	mdl:SetDirectionalLight(BOX_FRONT,Color(255 *1.3,255 *1.3,255 *1.3))
	mdl:SetDirectionalLight(BOX_BACK,Color(255 *0.2,255 *0.2,255 *0.2))
	mdl:SetDirectionalLight(BOX_RIGHT,Color(255 *0.2,255 *0.2,255 *0.2))
	mdl:SetDirectionalLight(BOX_LEFT,Color(255 *0.2,255 *0.2,255 *0.2))
	mdl:SetDirectionalLight(BOX_TOP,Color(255 *2.3,255 *2.3,255 *2.3))
	mdl:SetDirectionalLight(BOX_BOTTOM,Color(255 *0.1,255 *0.1,255 *0.1))
    mdl.FarZ = 32768

    -- mdlPanel:Hide()

    function modelListPnl:PaintOver()
        controlMusic(ply,0)
    
        if ply.SFMenu_LastMenuID != 0 then
            if ply.SFMenu_LastMenuID == 3 && CurTime() > ply.SFMenu_Katt then
                local snd = VJ_PICK({
                    "cpthazama/starfox/vo/katt/ah_hey.wav",
                    "cpthazama/starfox/vo/katt/cya_foxy.wav",
                    "cpthazama/starfox/vo/katt/later_foxy.wav",
                    "cpthazama/starfox/vo/katt/manners_cost_nothing.wav",
                    "cpthazama/starfox/vo/katt/my_place.wav",
                    "cpthazama/starfox/vo/katt/part_ways.wav",
                    "cpthazama/starfox/vo/katt/time_to_exit.wav",
                })
                surface.PlaySound(snd)
                ply.SFMenu_Katt = CurTime() +SoundDuration(snd)
                ply.SFMenu_KattRand = CurTime() +SoundDuration(snd) +math.Rand(15,30)
            end
            ply.SFMenu_LastMenuID = 0
        end
    end

    local PanelSelect = modelListPnl:Add("DPanelSelect")
    PanelSelect:Dock(FILL)

    local shipList = {}
    for _,data in SortedPairs(SF.ShipData) do
        local name = data.Name
        local mdl = data.Model
        local ID = data.ID

        local icon = vgui.Create("SpawnIcon")
        icon:SetModel(mdl)
        icon:SetSize(64,64)
        icon:SetTooltip(name)
        icon.ShipName = name
        icon.ShipModel = mdl
        icon.ShipID = ID
        icon.ShipData = data
        PanelSelect:AddPanel(icon,{lfs_sf_ship = ID})
        table.insert(shipList,data)
    end
    
    local function UpdateStats(panel,currentID)
        panel.TextData = panel.TextData or {}

        local function AddText(id,text)
            if panel.TextData[id] then
                panel.TextData[id]:SetText(text)
            else
                panel.TextData[id] = vgui.Create("RichText",panel)
                panel.TextData[id]:Dock(BOTTOM)
                panel.TextData[id]:SetText(text)
            end
        end

        local ship = SF.ShipData[currentID]
        if !ship then return end
        local plyData = SF.GetData(LocalPlayer())
        local shipData = SF.GetData(LocalPlayer(),currentID)
        local ammo1 = ship.PrimaryAmmo
        local ammo2 = ship.SecondaryAmmo
        local uLevel = ship.UnlockLevel
        local isUnlocked = shipData.Unlocked or false
        local rParts = ship.ReqParts or 1
        local sParts = shipData.Parts or 0
        local pLevel = plyData.Level or 1
        local sLevel = shipData.Level or 1
        local mult = (sLevel *0.1)
        mult = mult < 1 && 1 or mult

        if panel.tabButton then
            if isUnlocked then
                panel.tabButton:SetText("Already Unlocked")
                panel.tabButton:SetEnabled(false)
                RunConsoleCommand("lfs_sf_currentship",currentID)
            else
                local hasLevel = pLevel >= uLevel
                local hasParts = sParts >= rParts
                local canUnlock = (hasLevel or hasParts)

                panel.tabButton:SetText(canUnlock && "Unlock Ship" or "Requirements Not Met")
                panel.tabButton:SetEnabled(canUnlock)
                panel.tabButton:SetConsoleCommand("lfs_sf_unlockship",currentID)
            end
        end

        AddText("Description","Description - " .. ship.Bio)
        AddText("MaxSecondaryAmmo","Max Secondary Ammo - " .. ship.SecondaryAmmo *mult)
        AddText("MaxPrimaryAmmo","Max Primary Ammo - " .. ship.PrimaryAmmo *mult)
        AddText("Shield","Shield - " .. ship.Shield *mult)
        AddText("Health","Health - " .. ship.Health *mult)
        AddText("ShipLevel","Ship Level - " .. sLevel .. "/50")
        AddText("PilotLevel","Pilot Level - " .. pLevel .. "/50")
        AddText("Ship Parts",!isUnlocked && "Requires " .. rParts .. " part(s) to Unlock Early! (" .. sParts .. "/" .. rParts .. ")" or "")
        AddText("UnlockLevel",(pLevel < uLevel && !isUnlocked) && "Unlock At Pilot Level " .. uLevel .. " (" .. pLevel .. "/" .. uLevel .. ")" or "")
        AddText("Name",ship.Name)
    end

    local shipData = {}
    for _,v in pairs(shipList) do
        -- print(v.Name,v.Model,v.ID)
        if v.ID == currentShip then
            shipData = v
            break
        end
    end

    local modelname = shipData.Model
    util.PrecacheModel(modelname)
    mdl:SetModel(modelname)
    mdl.LastModel = modelname
    mdl.LastName = shipData.Name
    mdl.LastSavedName = shipData.Name
    mdl.LastID = shipData.ID

    modelListPnl.tabButton = vgui.Create("DButton")
    modelListPnl.tabButton:SetText("TEXT")
    modelListPnl.tabButton:SetSize(100,64)
    -- modelListPnl.tabButton:SetConsoleCommand("persona_addskill")
    modelListPnl.tabButton:SetEnabled(false)
    modelListPnl.tabButton:Dock(BOTTOM)
    modelListPnl:Add(modelListPnl.tabButton)

    UpdateStats(modelListPnl,mdl.LastID)

	local ent = mdl.Entity
    local height = select(2,ent:GetModelBounds()).z
    local pos = ent:GetPos() +ent:OBBCenter() +Vector(0,0,-50)
    local pos2 = ent:GetPos() +ent:OBBCenter() +Vector(ent:GetModelBounds()[1] *20,0,height *8)
    mdl:SetCamPos(pos2)
    mdl:SetFOV(12)
    mdl:SetLookAng((pos -pos2):Angle())

    modelListPnl.PreviewModel = mdl.Entity
    
    sheet:AddSheet("Ships",modelListPnl,"icons/starfox/logo16.png")

    function mdl:Think()
        if (!IsValid(self.Entity)) then return end
        local ent = self.Entity
        local currentShip = LocalPlayer():GetInfo("lfs_sf_ship")
        local shipData = {}
        for _,v in pairs(shipList) do
            if v.ID == currentShip then
                shipData = v
                break
            end
        end

        local modelname = shipData.Model
        if self.LastModel != modelname then
            surface.PlaySound("buttons/button24.wav")
        end

        util.PrecacheModel(modelname)
        mdl:SetModel(modelname)
        mdl.LastModel = modelname
        mdl.LastName = shipData.Name
        mdl.LastID = shipData.ID

        if self.LastSavedName != self.LastName then
            self.LastSavedName = self.LastName
            UpdateStats(modelListPnl,currentShip)

            local height = select(2,ent:GetModelBounds()).z
            local pos = ent:GetPos() +ent:OBBCenter() +Vector(0,0,-50)
            local pos2 = ent:GetPos() +ent:OBBCenter() +Vector(ent:GetModelBounds()[1] *20,0,height *8)
            mdl:SetCamPos(pos2)
            mdl:SetFOV(12)
            mdl:SetLookAng((pos -pos2):Angle())
        end

        if !self.Capturing then return end

        if self.m_bFirstPerson then
            return self:FirstPersonControls()
        end
    end

    function mdl:UpdateEntity(ent)
        ent:SetEyeTarget(self:GetCamPos())
    end
    
        -- Menu Good --

    local menuGood = window:Add("DPanel")
    menuGood:DockPadding(8,8,8,8)

    function menuGood:PaintOver()
        controlMusic(ply,1)
    
        if ply.SFMenu_LastMenuID != 1 then
            if ply.SFMenu_LastMenuID == 3 && CurTime() > ply.SFMenu_Katt then
                local snd = VJ_PICK({
                    "cpthazama/starfox/vo/katt/ah_hey.wav",
                    "cpthazama/starfox/vo/katt/cya_foxy.wav",
                    "cpthazama/starfox/vo/katt/later_foxy.wav",
                    "cpthazama/starfox/vo/katt/manners_cost_nothing.wav",
                    "cpthazama/starfox/vo/katt/my_place.wav",
                    "cpthazama/starfox/vo/katt/part_ways.wav",
                    "cpthazama/starfox/vo/katt/time_to_exit.wav",
                })
                surface.PlaySound(snd)
                ply.SFMenu_Katt = CurTime() +SoundDuration(snd)
                ply.SFMenu_KattRand = CurTime() +SoundDuration(snd) +math.Rand(15,30)
            end
            ply.SFMenu_LastMenuID = 1
        end
    end

    local missionsGood = vgui.Create("DListView")
    menuGood.MissionsGood = missionsGood
    missionsGood:SetTooltip(false)
    missionsGood:Dock(FILL)
    missionsGood:SetMultiSelect(false)
    missionsGood:AddColumn("Mission #",1)
    missionsGood:AddColumn("Mission Name",2)
    missionsGood:AddColumn("Description",3)
    missionsGood:AddColumn("Completion",4)
    menuGood:Add(missionsGood)

    for _,v in pairs(SF.MissionData) do
        if v.IsBad then continue end
        menuGood.MissionsGood:AddLine(v.ID,v.Name,v.Description,0)
    end
    
    local miscTab = sheet:AddSheet("Star Fox Missions",menuGood,"icons/starfox/logo_fox16.png")
    
        -- Menu Bad --

    local menuBad = window:Add("DPanel")
    menuBad:DockPadding(8,8,8,8)

    function menuBad:PaintOver()
        controlMusic(ply,2)
    
        if ply.SFMenu_LastMenuID != 2 then
            if ply.SFMenu_LastMenuID == 3 && CurTime() > ply.SFMenu_Katt then
                local snd = VJ_PICK({
                    "cpthazama/starfox/vo/katt/ah_hey.wav",
                    "cpthazama/starfox/vo/katt/cya_foxy.wav",
                    "cpthazama/starfox/vo/katt/later_foxy.wav",
                    "cpthazama/starfox/vo/katt/manners_cost_nothing.wav",
                    "cpthazama/starfox/vo/katt/my_place.wav",
                    "cpthazama/starfox/vo/katt/part_ways.wav",
                    "cpthazama/starfox/vo/katt/time_to_exit.wav",
                })
                surface.PlaySound(snd)
                ply.SFMenu_Katt = CurTime() +SoundDuration(snd)
                ply.SFMenu_KattRand = CurTime() +SoundDuration(snd) +math.Rand(15,30)
            end
            ply.SFMenu_LastMenuID = 2
        end
    end

    local missionsBad = vgui.Create("DListView")
    menuBad.MissionsBad = missionsBad
    missionsBad:SetTooltip(false)
    missionsBad:Dock(FILL)
    missionsBad:SetMultiSelect(false)
    missionsBad:AddColumn("Mission #",1)
    missionsBad:AddColumn("Mission Name",2)
    missionsBad:AddColumn("Description",3)
    missionsBad:AddColumn("Completion",4)
    menuBad:Add(missionsBad)

    for _,v in pairs(SF.MissionData) do
        if !v.IsBad then continue end
        menuBad.MissionsBad:AddLine(v.ID,v.Name,v.Description,0)
    end
    
    local miscTab = sheet:AddSheet("Star Wolf Missions",menuBad,"icons/starfox/logo_wolf16.png")
    
        -- Menu Gacha --

    local menuGacha = window:Add("DPanel")
    menuGacha:SetSize(wMin,wMax)
    menuGacha:Dock(FILL)
    menuGacha:DockPadding(8,8,8,8)

    local function AddText(id,text,font)
        if menuGacha.TextData[id] then
            menuGacha.TextData[id]:SetText(text)
        else
            menuGacha.TextData[id] = vgui.Create("DLabel",menuGacha)
            menuGacha.TextData[id]:Dock(TOP)
            menuGacha.TextData[id]:SetText(text)
            if font then
                menuGacha.TextData[id]:SetFont("StarFox_Default")
            end
        end
    end

    function menuGacha:PaintOver()
        controlMusic(ply,3)
    
        if ply.SFMenu_LastMenuID != 3 then
            if CurTime() > ply.SFMenu_Katt then
                local snd = VJ_PICK({
                    "cpthazama/starfox/vo/katt/hey.wav",
                    "cpthazama/starfox/vo/katt/music_to_ears.wav",
                    "cpthazama/starfox/vo/katt/well_hello_there.wav",
                    "cpthazama/starfox/vo/katt/help.wav"
                })
                surface.PlaySound(snd)
                ply.SFMenu_Katt = CurTime() +SoundDuration(snd)
                ply.SFMenu_KattRand = CurTime() +SoundDuration(snd) +math.Rand(15,30)
            end
            ply.SFMenu_LastMenuID = 3
        end

        if CurTime() > ply.SFMenu_KattRand && CurTime() > ply.SFMenu_Katt && math.random(1,20) == 1 then
            local snd = VJ_PICK({
                "cpthazama/starfox/vo/katt/checking_in.wav",
                "cpthazama/starfox/vo/katt/entertain_lady.wav",
                "cpthazama/starfox/vo/katt/hog_all_the_fun.wav",
                "cpthazama/starfox/vo/katt/little_farther.wav",
                "cpthazama/starfox/vo/katt/hey.wav",
            })
            surface.PlaySound(snd)
            ply.SFMenu_KattRand = CurTime() +SoundDuration(snd) +math.Rand(15,30)
            ply.SFMenu_Katt = CurTime() +SoundDuration(snd)
        end
        AddText("Results1","Your Last Gamble Results",true)
        AddText("Results2",ply:GetNW2String("SFMenu_LastGachaMessage") or " ")
    end
	local rates = {}
	rates.Pilots = 3 *SF_GACHA_RATE_PILOTS
	rates.ShipParts = 30 *SF_GACHA_RATE_PARTS

    menuGacha.TextData = menuGacha.TextData or {}

    -- AddText("Intro","Take A Gamble at Katt's Lylat Shop!")
    -- AddText("Blank1"," ")
    -- AddText("Info1","Drop Rates:")
    -- AddText("Info2","67% - Random Player XP")
    -- AddText("Info3","30% - Random Ship Part(s)")
    -- AddText("Info4","3% - Random Pilot")
    -- AddText("Results1"," ")

    local img_bg = vgui.Create("DImage",menuGacha)
    img_bg:Dock(FILL)
    img_bg:SetSize(window:GetSize())
    img_bg:SetImage("icons/starfox/rewards/menu.png")

    menuGacha.tabButton = vgui.Create("DButton")
    menuGacha.tabButton:SetText("Take A Gamble (x1) [25 SF Coins]")
    menuGacha.tabButton:SetSize(100,64)
    menuGacha.tabButton:SetConsoleCommand("lfs_sf_gacha")
    menuGacha.tabButton:SetEnabled(true)
    menuGacha.tabButton:Dock(BOTTOM)
    menuGacha:Add(menuGacha.tabButton)

    menuGacha.tabButton = vgui.Create("DButton")
    menuGacha.tabButton:SetText("Take A Gamble (x5) [125 SF Coins]")
    menuGacha.tabButton:SetSize(100,64)
    menuGacha.tabButton:SetConsoleCommand("lfs_sf_gacha_b")
    menuGacha.tabButton:SetEnabled(true)
    menuGacha.tabButton:Dock(BOTTOM)
    menuGacha:Add(menuGacha.tabButton)
    
    local miscTab = sheet:AddSheet("Katt's Lylat Shop",menuGacha,"icons/starfox/logo_kattgacha16.png")
end)

if CLIENT then
	hook.Add("AddToolMenuTabs","StarFox_AddIcon",function()
		spawnmenu.AddToolTab("Star Fox","Star Fox","icons/starfox/logo16.png")
	end)
	hook.Add("PopulateToolMenu","StarFox_AddMenus",function()
		spawnmenu.AddToolMenuOption("Star Fox","Settings","Main Settings","Main Settings","","",function(Panel)
			local DefaultBox = {Options = {},CVars = {},Label = "#Presets",MenuButton = "1",Folder = "Main Settings"}
			DefaultBox.Options["#Default"] = {
				lfs_sf_voteams = "1",
				lfs_sf_cameraspeed = "3",
				lfs_sf_xpvehicle = "1",
				lfs_sf_xpchat = "1",
				lfs_sf_menumusic = "1",
			}
			Panel:AddControl("ComboBox",DefaultBox)
			Panel:AddControl("CheckBox",{Label = "Enable Music in the Menu",Command = "lfs_sf_menumusic"})
			Panel:AddControl("CheckBox",{Label = "Enable XP chat prompts",Command = "lfs_sf_xpchat"})
			Panel:AddControl("CheckBox",{Label = "Only enemy VO will appear on your screen",Command = "lfs_sf_voteams"})
			Panel:AddControl("Slider",{Label = "Third-Person Camera Refresh Speed",Command = "lfs_sf_cameraspeed",Min = 1,Max = 30})
			Panel:AddControl("Button",{Label = "Open Star Fox Menu",Command = "lfs_sf_showmenu"})

            if !(!game.SinglePlayer() && !LocalPlayer():IsAdmin()) then
			    Panel:AddControl("CheckBox",{Label = "Only allow XP to be earned while using vehicles",Command = "lfs_sf_xpvehicle"})
            end
		end,{})
		spawnmenu.AddToolMenuOption("Star Fox","Settings","Mission Settings","Mission Settings","","",function(Panel)
            if !(!game.SinglePlayer() && !LocalPlayer():IsAdmin()) then
                local DefaultBox = {Options = {},CVars = {},Label = "#Presets",MenuButton = "1",Folder = "Mission Settings"}
                DefaultBox.Options["#Default"] = {
                    lfs_sf_mission_allies = "1",
                    lfs_sf_mission_forceply = "1",
                }

			    Panel:AddControl("CheckBox",{Label = "Allow NPC Allies in Missions",Command = "lfs_sf_mission_allies"})
			    Panel:AddControl("CheckBox",{Label = "Force Players into vehicles during Aerial Missions",Command = "lfs_sf_mission_forceply"})
            end
		end,{})
    end)
end