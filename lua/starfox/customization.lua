AddCSLuaFile()

local sfC = util.Compress
local sfD = util.Decompress

SF_C = {}

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

    sound.PlayFile("sound/cpthazama/starfox/music/menu.mp3","noplay noblock",function(station,errCode,errStr)
        if IsValid(station) then
            station:EnableLooping(true)
            station:Play()
            station:SetVolume(0.6)
            station:SetPlaybackRate(1)
            ply.SF_MenuTheme = station
        else
            print("Error playing sound!",errCode,errStr)
        end
        return station
    end)
    
    local currentShip = LocalPlayer():GetInfo("lfs_sf_ship")
    surface.PlaySound("cpthazama/starfox/64/RadioTransmissionon.wav")

    local wMin,wMax = 1538,864
    local window = vgui.Create("DFrame")
    window:SetTitle(LocalPlayer():Nick() .. "'s Hangar Bay")
    window:SetSize(math.min(ScrW() -16,wMin),math.min(ScrH() -16,wMax))
    window:SetSizable(true)
    window:SetBackgroundBlur(true)
    window:SetMinWidth(wMin)
    window:SetMinHeight(wMax)
    window:SetDeleteOnClose(false)
    window:Center()
    window:MakePopup()
    window.OnClose = function()
        if IsValid(ply) then
            ply:EmitSound("cpthazama/starfox/64/RadioTransmissionOff.wav",65)
            if IsValid(ply.SF_MenuTheme) && ply.SF_MenuTheme:GetState() == 1 then
                ply.SF_MenuTheme:Stop()
            end
        end
    end

    local mdl = window:Add("DAdjustableModelPanel")
    mdl:Dock(FILL)
    -- mdl:SetFOV(85)
    -- mdl:SetCamPos(vector_origin)
	mdl:SetAmbientLight(Color( 255 * 0.3, 255 * 0.3, 255 * 0.3 ) )
	mdl:SetDirectionalLight( BOX_FRONT, Color( 255 * 1.3, 255 * 1.3, 255 * 1.3 ) )
	mdl:SetDirectionalLight( BOX_BACK, Color( 255 * 0.2, 255 * 0.2, 255 * 0.2 ) )
	mdl:SetDirectionalLight( BOX_RIGHT, Color( 255 * 0.2, 255 * 0.2, 255 * 0.2 ) )
	mdl:SetDirectionalLight( BOX_LEFT, Color( 255 * 0.2, 255 * 0.2, 255 * 0.2 ) )
	mdl:SetDirectionalLight( BOX_TOP, Color( 255 * 2.3, 255 * 2.3, 255 * 2.3 ) )
	mdl:SetDirectionalLight( BOX_BOTTOM, Color( 255 * 0.1, 255 * 0.1, 255 * 0.1 ) )
    -- mdl:SetAmbientLight(Vector(-64,-64,-64))
    -- mdl:SetAnimated(true)
    mdl.FarZ = 32768
    -- mdl.Angles = angle_zero
    -- mdl:SetLookAt(Vector(0,0,0))

    local sheet = window:Add("DPropertySheet")
    sheet:Dock(LEFT)
    sheet:SetSize(430,0)

    local modelListPnl = window:Add("DPanel")
    modelListPnl:DockPadding(8,8,8,8)

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
        local ammo1 = ship.PrimaryAmmo
        local ammo2 = ship.SecondaryAmmo
        local uLevel = ship.UnlockLevel
        local pLevel = SF.GetData(LocalPlayer()).Level or 1
        local sLevel = SF.GetData(LocalPlayer(),currentID).Level or 1
        local mult = (sLevel *0.1)
        mult = mult < 1 && 1 or mult

        AddText("Description","Description - " .. ship.Bio)
        AddText("MaxSecondaryAmmo","Max Secondary Ammo - " .. ship.SecondaryAmmo *mult)
        AddText("MaxPrimaryAmmo","Max Primary Ammo - " .. ship.PrimaryAmmo *mult)
        AddText("Shield","Shield - " .. ship.Shield *mult)
        AddText("Health","Health - " .. ship.Health *mult)
        AddText("ShipLevel","Ship Level - " .. sLevel .. "/50")
        AddText("PilotLevel","Pilot Level - " .. pLevel .. "/50")
        AddText("UnlockLevel",pLevel < uLevel && "Unlock At Pilot Level " .. uLevel or "")
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

    UpdateStats(modelListPnl,mdl.LastID)

	local ent = mdl.Entity
	local pos = ent:GetPos()
	local ang = ent:GetAngles()
	local tab = PositionSpawnIcon(ent,pos,true)
	ent:SetAngles(ang)
	if tab then
		mdl:SetCamPos(tab.origin)
		mdl:SetFOV(tab.fov)
		mdl:SetLookAng(tab.angles)
	end

    modelListPnl.PreviewModel = mdl.Entity
    
    sheet:AddSheet("Ships",modelListPnl,"icon16/chart_organisation.png")

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

        if self.LastSavedName != self.LastName then
            self.LastSavedName = self.LastName
            UpdateStats(modelListPnl,currentShip)
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

        if !self.Capturing then return end

        if self.m_bFirstPerson then
            return self:FirstPersonControls()
        end

        local pos = ent:GetPos()
        local ang = ent:GetAngles()
        local tab = PositionSpawnIcon(ent,pos,true)
        if tab then
            mdl:SetCamPos(tab.origin)
            mdl:SetFOV(tab.fov)
            mdl:SetLookAng(tab.angles)
        end
    end

    function mdl:UpdateEntity(ent)
        ent:SetEyeTarget(self:GetCamPos())
    end
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
			}
			Panel:AddControl("ComboBox",DefaultBox)
			Panel:AddControl("CheckBox",{Label = "Enable XP chat prompts",Command = "lfs_sf_xpchat"})
			Panel:AddControl("CheckBox",{Label = "Only enemy VO will appear on your screen",Command = "lfs_sf_voteams"})
			Panel:AddControl("Slider",{Label = "Third-Person Camera Refresh Speed",Command = "lfs_sf_cameraspeed",Min = 1,Max = 30})
			Panel:AddControl("Button",{Label = "Open Hangar Bay",Command = "lfs_sf_showmenu"})

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