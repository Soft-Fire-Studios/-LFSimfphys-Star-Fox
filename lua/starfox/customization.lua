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

SF_C.WriteData = function(fileName,dat,delete) // SF_C.WriteData("lfsimfphys_starfox/customization/arwing.dat",{Hip=true,Hop=false},true)
	dat = LZMA(dat,true)
	if delete then
		file.Write(fileName,dat)
		return
	end
	file.Append(fileName,dat)
end

SF_C.ReadData = function(fileName) // SF_C.ReadData("lfsimfphys_starfox/customization/arwing.dat")
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

local translations_Ships = {
    ["models/cpthazama/starfox/vehicles/arwing.mdl"] = "Arwing Mk. II",
    ["models/cpthazama/starfox/vehicles/cornerian_carrier.mdl"] = "Cornerian Cruiser",
    -- ["models/cpthazama/starfox/vehicles/cornerian_fighter.mdl"] = "Cornerian Figher Mk. II",
    ["models/cpthazama/starfox/vehicles/cornerian_fighter_aparoid.mdl"] = "Cornerian Figher Mk. II (Infected)",
    ["models/cpthazama/starfox/vehicles/venom_carrier.mdl"] = "Venomian Carrier",
    -- ["models/cpthazama/starfox/vehicles/venom_battleship.mdl"] = "Venomian Battleship",
    ["models/cpthazama/starfox/vehicles/venom_dragon_fighter.mdl"] = "Venomian Figher Mk. I",
    ["models/cpthazama/starfox/vehicles/venomian_bomber.mdl"] = "Venomian Stealth Bomber",
    ["models/cpthazama/starfox/vehicles/venomian_fighter.mdl"] = "Venomian Fighter Mk. II",
    ["models/cpthazama/starfox/vehicles/wolfen.mdl"] = "Wolfen Mk. II",
    ["models/cpthazama/starfox/vehicles/wolfen_ii.mdl"] = "Wolfen II (64)",
    ["models/cpthazama/starfox/vehicles/wolfen_ii_zero.mdl"] = "Wolfen II",
    ["models/cpthazama/starfox/vehicles/wolfen_redfang.mdl"] = "Wolfen Mk. III",
    ["models/cpthazama/starfox/vehicles/wolfen_zero.mdl"] = "Wolfen Mk. I",
}

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
    for mdl,name in SortedPairs(translations_Ships) do
        local icon = vgui.Create("SpawnIcon")
        icon:SetModel(mdl)
        icon:SetSize(64,64)
        icon:SetTooltip(name)
        icon.ShipName = name
        icon.ShipModel = mdl
        local tName = string.Replace(mdl,"models/cpthazama/starfox/vehicles/","")
        tName = string.Replace(tName,".mdl","")
        icon.ShipID = tName
        PanelSelect:AddPanel(icon,{lfs_sf_ship = tName})
        table.insert(shipList,{Name=name,Model=mdl,ID=tName})
    end
    
    local function UpdateStats(panel,currentShip)
        if panel.StatsName then
            panel.StatsName:SetText(currentShip)
        else
            panel.StatsName = vgui.Create("RichText",panel)
            panel.StatsName:Dock(BOTTOM)
            panel.StatsName:SetText(currentShip)
        end
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

    UpdateStats(modelListPnl,mdl.LastName)

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
            UpdateStats(modelListPnl,self.LastSavedName)
            -- net.Start("PersonaMod_UpdateSVPersona")
            --     net.WriteEntity(LocalPlayer())
            --     net.WriteString(currentShip)
            -- net.SendToServer()
            -- surface.PlaySound("cpthazama/persona5/misc/00086.wav")
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

        -- if !IsValid(self.Room) then
        --     self.Room = ClientsideModel("models/cpthazama/starfox/skybox/skybox1.mdl",RENDER_GROUP_OPAQUE_ENTITY)
        --     self.Room:SetPos(ent:GetPos())
        --     self.Room:SetModelScale(2)
        --     self.Room:SetParent(ent)
        --     self.Room:SetNoDraw(true)
        --     local index = "SF_CSRemove_" .. ent:EntIndex()
        --     hook.Add("Think",index,function()
        --         if !IsValid(ent) then
        --             SafeRemoveEntity(self.Room)
        --             hook.Remove("Think",index)
        --         end
        --     end)
        --     return
        -- end
        
        -- self.Room:DrawModel()
        -- ent:DrawModel()

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