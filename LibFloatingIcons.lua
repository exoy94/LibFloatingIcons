LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons
--local Lib = LibExoYsUtilities

local EM = GetEventManager() 
local WM = GetWindowManager()
 

--[[ ------------- ]]
--[[ -- Globals -- ]] 
--[[ ------------- ]]


--[[ --------------------- ]]
--[[ -- Saved Variables -- ]]
--[[ --------------------- ]]

local SV = {}
local defaultSV = {
    ["interval"] = 100,
    ["fadeout"] = true,
    ["fadedist"] = 1,
    ["scaling"] = true, 
    ["alpha"] = 1,
    ["maxSize"] = 5,
    ["standardSize"] = 5, 
    ["debug"] = false, 
    ["dev"] = false, 
}

--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

-- addon variables 
local idLFI = "LibFloatingIcons"
local vLFI = 0
local uLFI 

-- categories 
local catId = 1
local catBuff = 2
local catMech = 3 
local catPos = 4
local numCat = 4

-- player data 
local player = ""
local cZone = 0  

-- tables 
local playerIcons = {}
local petIcons = {} --including companions, assistant etc. ???? 
local positionIcons = {} 
local positionIconVault = {}


--[[ ----------------]]
--[[ -- Utilities -- ]]
--[[ --------------- ]]

local function Debug(str) 
    if SV.debug then 
        d( "[|c00FFFFLFI-Debug|r] "..str) 
    end
end

local function DevDebug(str) 
    if SV.dev then 
        d( "[|c00FFFFLFI-Dev|r] "..str) 
    end
end

local function Evaluate(v, ...) 
    if type(v) == "function" then 
        return v(...) 
    else   
        return v 
    end
end   


--[[ --------------------- ]]
--[[ -- Control Handler -- ]]
--[[ --------------------- ]]

local RenderSpace 
local Window 
local controlPool = {} 
local poolHandler = {}  -- keeps track of how many controls of one catorgory are currently not in use
local cacheHandler = {} -- keeps track of how many controls of one category exist


local function CreateNewControl(cat) 
    local name = string.format("%s_%s_%d_%d", idLFI, "Ctrl", cat, cacheHandler[cat])
    local ctrl = WM:CreateControl( name, Window, CT_CONTROL) 

    ctrl:ClearAnchors()
    ctrl:SetAnchor( CENTER, Window, CENTER, 0, 0)
    ctrl:SetHidden(false) 

    ctrl.cat = cat 
    
    -- support functions 
    local function AddTexture() 
        local tex = WM:CreateControl( name.."_Texture", ctrl, CT_TEXTURE)
        tex:ClearAnchors()
        tex:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
        tex:SetTexture( GetAbilityIcon(112323) )
        tex:SetDimensions(50,50)
        return tex
    end

    -- add different controls depending on category 
    if cat == catId then 
        ctrl.tex = AddTexture()
    elseif cat == catBuff then 

    elseif cat == catMech then 

    elseif cat == catPos then 
        ctrl.tex = AddTexture() 
    end

    return ctrl 
end


local function AssignControl(cat)
    if poolHandler[cat] > 0 then 
        local ctrl = controlPool[cat][poolHandler[cat]]
        table.remove(controlPool[cat])
        poolHandler[cat] = poolHandler[cat] - 1
        ctrl:SetHidden(false) 
        return ctrl 
    else 
        cacheHandler[cat] = cacheHandler[cat] + 1
        return CreateNewControl(cat)
    end

end


local function ReleaseControl(ctrl)
    ctrl:SetHidden(true) 
    table.insert(controlPool[ctrl.cat], ctrl)
    poolHandler[ctrl.cat] = poolHandler[ctrl.cat] + 1
end



--[[ ------------ ]]
--[[ -- Update -- ]]
--[[ ------------ ]]


local function OnUpdate()   
    DevDebug("update executed at "..tostring(GetGameTimeMilliseconds()))

    local earlyOut = true
    for i=1,numCat do  
        if poolHandler[i] < cacheHandler[i] then 
            earlyOut = false 
        end
    end
    if earlyOut then 
        DevDebug("update aborted")
        return
    end
    --TODO early out, check if any icons need to be rendered

    local t = GetGameTimeMilliseconds() 
    -- screen dimensions
    local uiW, uiH = GuiRoot:GetDimensions()
    -- prepare render space
    Set3DRenderSpaceToCurrentCamera( RenderSpace:GetName() )

    -- retrieve camera world position and orientation vectors
    local cX, cY, cZ = GuiRender3DPositionToWorldPosition( RenderSpace:Get3DRenderSpaceOrigin() )
    local fX, fY, fZ = RenderSpace:Get3DRenderSpaceForward()
    local rX, rY, rZ = RenderSpace:Get3DRenderSpaceRight()
    local uX, uY, uZ = RenderSpace:Get3DRenderSpaceUp()

    -- calculate camera inverse matrix 
    local i11 = -( uY * fZ - uZ * fY )
    local i12 = -( rZ * fY - rY * fZ )
    local i13 = -( rY * uZ - rZ * uY )
    local i21 = -( uZ * fX - uX * fZ )
    local i22 = -( rX * fZ - rZ * fX )
    local i23 = -( rZ * uX - rX * uZ )
    local i31 = -( uX * fY - uY * fX )
    local i32 = -( rY * fX - rX * fY )
    local i33 = -( rX * uY - rY * uX )
    local i41 = -( uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY )
    local i42 = -( rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY )
    local i43 = -( rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY )
    
    local zOrder = {}
    local zTotal = 0

    local function UpdateIcon(coord, ctrl, data)
        local wX, wY, wZ = coord[1], coord[2], coord[3]
        wY = wY + 2*100 --offset

        -- calculate unit view position
        local pX = wX * i11 + wY * i21 + wZ * i31 + i41
        local pY = wX * i12 + wY * i22 + wZ * i32 + i42
        local pZ = wX * i13 + wY * i23 + wZ * i33 + i43
        
        -- early out if icon is behind camera
        if pZ < 0 then return false end
        zOrder[1 + zo_floor( pZ * 100 )] = ctrl 
        zTotal = zTotal + 1

        -- calculate unit screen position
        local w, h = GetWorldDimensionsOfViewFrustumAtDepth( pZ )
        local x, y = pX * uiW / w, -pY * uiH / h

        -- calculate distance
        local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
        local dist       = 1 + zo_sqrt( dX * dX + dY * dY + dZ * dZ )

        -- calculate scale 
        local scale = SV.scaling and 1000 / dist or 1

        -- calculate alpha 
        local alpha = SV.fadeout and zo_clampedPercentBetween( 1, SV.fadedist * 100, dist ) or 1
        local fade = SV.alpha * alpha * alpha  

        -- apply settings to control 
        ctrl:ClearAnchors()
        ctrl:SetAnchor(BOTTOM, Window, CENTER, x, y)
        ctrl:SetScale( scale )
        ctrl:SetAlpha( fade )

        --TODO callbacks for texture, color etc.

        return true
    end

    if IsUnitGrouped("player") then 
        for i = 1, GROUP_SIZE_MAX do 
            local unit = "group"..i
            local displayName = GetUnitDisplayName(unit) 
            
            DevDebug("updating icons for ["..displayName.."]")
            --TODO check if unit is player and compare with settings 

            --if playerIcons[displayName] then 
            --    local offset = SV.offset
            --   for j = 1, 3 do 
            --      if playerIcons[displayName][j] then 
                        
                        -- CalculateIconScreenData(unit, data) 
                        -- offset = offset + size + margin
                        -- update other properties 
            --     end
            -- end
            --end   
        end
    end

    if not ZO_IsTableEmpty(positionIcons) then DevDebug("updating position icons in ["..cZone.."]" ) end
    for _,icon in ipairs(positionIcons) do   
        UpdateIcon({Evaluate(icon.coord.x,t), Evaluate(icon.coord.y,t), Evaluate(icon.coord.z,t)}, icon.ctrl)
    end
    
    -- sort draw order
    if zTotal > 1 then
        local keys = { }
        for k in pairs( zOrder ) do
            table.insert( keys, k )
        end
        table.sort( keys )

        -- adjust draw order
        for _, k in ipairs( keys ) do
            zOrder[k]:SetDrawLevel( zTotal )
            zTotal = zTotal - 1
        end
    end

end


local function DefineUpdateInterval(interval) 
    if uLFI then 
        EM:UnregisterForUpdate(idLFI) 
        uLFI = nil
    end 
    if not interval then 
        DevDebug("update stopped")    
        return 
    end
    EM:RegisterForUpdate(idLFI, interval, OnUpdate)
    uLFI = interval
    DevDebug("update running every "..tostring(interval).."ms") 
end

--[[ --------------------------- ]]
--[[ ---- Support Functions ---- ]]
--[[ -- for Exposed Framework -- ]]
--[[ --------------------------- ]]

local function VerifyHashTable(t, e) 
    if not type(t) == "table" then return false end 
    for _,ev in ipairs(e) do 
      if not t[ev] then return false end
    end
    return true
end

local function FormatData(i)
    local r = {}
    r.tex =     type(i.tex) == "function"   and i.tex   or function() return i.tex end
    r.col =     type(i.col) =="table"       and i.col   or {1,1,1,1}
    r.size =    type(i.size)=="number"      and i.size  or SV.standardSize
    return r 
end

local function HasNecessaryParamter(id, displayName, data) 
    if not id then return false end
    if not type(displayName) == "string" then return false end 
    if not string.find(displayName, "@") then return false end
    if not VerifyHashTable(data, {tex}) then return false end 
    return true
end

local function FindPositionIcon(t, id)
    for k,v in pairs(t) do 
        if v.id == id then 
            return k 
        end
    end
    return false
end

--[[ ----------------------- ]]
--[[ -- Exposed Functions -- ]]
--[[ ----------------------- ]]

function LFI.RegisterIdentifierIcon(displayName, data, meta) 

    if not playerIcons[displayName] then 
        playerIcons[displayName] = {catId = {}, catBuff = {}, catMech = {} }
    end

    playerIcons[displayName][catId] = {
        icon = AssignIcon(),
        data = data, 
        meta = meta, 
    }

end


function LFI.UnregisterIdentifierIcon(displayName) 
    playerIcons[displayName][catId] = {}
end


function LFI.HasIdentifierIcon(displayName) 
    local entry = playerIcons[displayName][catId]
    return not ZO_IsTableEmpty(entry) and ZO_ShallowCopy(entry.meta) or false 
end


function LFI.OverwriteIdentifierData(displayName, value, overwrite, termination) 

end


function LFI.RegisterPositionIcon(zone, id, coord)
    id = string.lower(id)
    
    -- create zone subtable if non existing
    if type(positionIconVault[zone]) ~= "table" then 
        positionIconVault[zone] = {}
    end

    -- return false if icon id is already used for this zone
    if FindPositionIcon(positionIconVault[zone], id) then 
        DevDebug("position icon >"..id.."< already exist in ["..tostring(zone).."]")
        return false 
    end

    table.insert(positionIconVault[zone], {id=id, coord=coord})
    DevDebug(zo_strformat("register position icon ><<2>>< in [<<1>>]", zone, id))

    -- add icon to currently displayed icons if already in the correct zone
    if zone == cZone then 
        table.insert(positionIcons, {id=id, coord=coord, ctrl=AssignControl(catPos)})
    end
end


function LFI.UnregisterPositionIcon(zone, id)
    id = string.lower(id)
    local k1 = FindPositionIcon(positionIconVault[zone], id)
    if not k1 then 
        DevDebug("position icon >"..id.."< doesnt exist in ["..tostring(zone).."]")
        return false 
    end

    table.remove(positionIconVault[zone], k1)
    
    if zone == cZone then 
        local k2 = FindPositionIcon(positionIcons, id)
        ReleaseControl(positionIcons[k2].ctrl)
        table.remove(positionIcons, k2)
    end
    DevDebug(zo_strformat("unregister position icon ><<2>>< in [<<1>>]", zone, id))

end
--TODO add temporary overwrite, meaning the current icon gets stored and re-enabled when the "new one" gets removed again

-- data:    -- texture (string or callback)  first param time, second unitTag, third custom (must be provided as callback)
            -- color (rgba or callback)
            -- size (nummer (or callback???) )
        --> wenn kein callback übergeben, in ein callback umwandeln beim abspeichern für einfacheres handhaben in der update function

--local exampleIconData = {
--    tex = "textureString", 
--    parTex = >callback<,
--    color  
--}



-- positionCallback for moving position icon 
-- blinking 
-- callback to updateIcon (for countdown etc) 
-- mechanicIcon: 

-- for unique icon: texture, callback for animation, 

--[[ ---------- ]]
--[[ -- Menu -- ]]
--[[ ---------- ]]

local function DefineSetting(setting, name, tab, var, param, warning)
    local s = {type=setting, name=name}
        s.getFunc = function() return tab[var] end
        s.setFunc = function(v) tab[var] = v end 
        if setting == "slider" then  
            s.min, s.max, s.step, s.decimals = param[1], param[2], param[3], 2
        end
        if warning then 
            s.warning = "Changes require Reloadui"
        end
    return s
end

local function DefineMenu() 
    local LAM2 = LibAddonMenu2

    local panelData = {
        type="panel", 
        name=idLFI, 
        displayName=idLFI, 
        author = "@|c00FF00ExoY|r94 (PC/EU)", 
        version = vLFI, 
        registerForRefresh = true, 
    }
    local optionsTable = {} 

    table.insert(optionsTable, {type="header", name="Performance"})
    table.insert(optionsTable, DefineSetting("slider", "Update Interval", SV, "interval", {0,100,10}, true))
    table.insert(optionsTable, {type = "header", name="Visual"})
    table.insert(optionsTable, DefineSetting("slider", "Maximum Size", SV, "maxSize", {1,10,1}))
    table.insert(optionsTable, DefineSetting("checkbox", "Fadeout", SV, "fadeout"))
    table.insert(optionsTable, DefineSetting("checkbox", "Distance Scaling", SV, "scaling"))
    table.insert(optionsTable, DefineSetting("slider", "Fade Distance", SV, "fadedist", {0,1,0.1}))
    table.insert(optionsTable, DefineSetting("slider", "Alpha-MaxValue", SV, "alpha", {0,1,0.1}))
    table.insert(optionsTable, {type="divider"})
    table.insert(optionsTable, DefineSetting("checkbox", "Debug Mode", SV, "debug"))
    --table.insert(optionsTable, DefineSetting("checkbox", "Developer Mode", SV, "dev"))

    LAM2:RegisterAddonPanel('LFI_Menu', panelData)
    LAM2:RegisterOptionControls('LFI_Menu', optionsTable)
end 

-- allow for animated unique icons --> understand animations --> 

--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

local function OnPlayerActivated() 
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId ~= cZone then 
        Debug( zo_strformat("zone update [<<1>> -> <<2>>]",cZone, zoneId) )

        -- release all position icons in old zone
        for _, icon in ipairs(positionIcons) do 
            ReleaseControl(icon.ctrl) 
        end

        -- reset position icon table and change zone variable
        positionIcons = {}
        cZone = zoneId

        -- add position icons from vault to current zone
        if not positionIconVault[cZone] then return end
        for _, icon in ipairs(positionIconVault[cZone]) do 
            local entry = ZO_ShallowTableCopy(icon) 
            entry.ctrl = AssignControl(catPos)
            table.insert(positionIcons, entry)
        end

    end
end


--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]

local function Initialize() 
    
    -- load SavedVariables 
    SV = ZO_SavedVars:NewAccountWide('LFI_SV', 1, nil, defaultSV, 'Settings')

    -- register update on first player activated event
    EM:RegisterForEvent(idLFI, EVENT_PLAYER_ACTIVATED, function() 
            EM:UnregisterForEvent(idLFI, EVENT_PLAYER_ACTIVATED)

            DevDebug("DevMode is |c00FF00active|r")
            if not SV.dev then
                DefineUpdateInterval(SV.interval) 
            end

            EM:RegisterForEvent(idLFI, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        end)

    -- initialize player data 
    cZone, _, _, _ = GetUnitRawWorldPosition("player") 
    player = GetUnitDisplayName("player")

    -- initialize tables for control handler 
    for i=1,numCat do 
        controlPool[i] = {}
        poolHandler[i] = 0
        cacheHandler[i] = 0
    end

    -- create render space 
    RenderSpace = WM:CreateControl( 'LFI_RenderSpace', GuiRoot, CT_CONTROL )
    RenderSpace:SetAnchorFill( GuiRoot )
    RenderSpace:Create3DRenderSpace() 
    RenderSpace:SetHidden( true ) 

    -- create parent window for icons 
    Window = WM:CreateTopLevelWindow( 'LFI_Window' )
    Window:SetClampedToScreen( true )
    Window:SetMouseEnabled( false )
    Window:SetMovable( false )
    Window:SetAnchorFill( GuiRoot )
	Window:SetDrawLayer( DL_BACKGROUND )
	Window:SetDrawTier( DT_LOW )
	Window:SetDrawLevel( 0 )

    -- create parent window scene fragment
    local frag = ZO_HUDFadeSceneFragment:New( Window )
	HUD_UI_SCENE:AddFragment( frag )
    HUD_SCENE:AddFragment( frag )
    LOOT_SCENE:AddFragment( frag )

    DefineMenu()
end 

local function OnAddonLoaded(_, addonName) 
    if addonName == idLFI then 
        Initialize()
        EM:UnregisterForEvent(idLFI, EVENT_ADD_ON_LOADED)
    end
end

EM:RegisterForEvent(idLFI, EVENT_ADD_ON_LOADED, OnAddonLoaded)


--[[ ----------------- ]]
--[[ -- Development -- ]]
--[[ ----------------- ]]

local devCmd = {
    ["dev"] = function(par)  
        -- check if requested state is already set
        if par == "on" and SV.dev then par = nil end 
        if par == "off" and not SV.dev then par = nil end 
        -- activating development mode
        if par == "on" then
            d(zo_strformat("[|c00FFFFLFI|r]: DevMode got |c00FF00activated|r")) 
            SV.dev = true
            DefineUpdateInterval() 
        -- deactivating development mode
        elseif par == "off" then 
            DefineUpdateInterval(SV.interval)
            SV.dev = false
            d(zo_strformat("[|c00FFFFLFI|r]: DevMode got |cFF0000deactived|r" ))	
        -- output development mode status
        else 
            d(zo_strformat("[|c00FFFFLFI|r]: DevMode is <<1>>", SV.dev and "|c00FF00active|r" or "|cFF0000inactive|r" ))
            return
        end
    end, 
    ["interval"] = function(par) 
        if not SV.dev then return end 
        if not par then 
            if uLFI then 
                DevDebug("update running every "..tostring(uLFI).."ms") 
            else 
                DevDebug("update not running")  
            end
        elseif par == "-1" then 
            DefineUpdateInterval(SV.interval)    
        elseif par == "0" then 
            DefineUpdateInterval() 
        else 
            if type(tonumber(par)) == "number" then 
                DefineUpdateInterval(tonumber(par)*1000)
            end
        end
    end, 
    ["cache"] = function() 
        if not SV.dev then return end
        local out = ""
        for i=1,numCat do 
            out = out..tostring(cacheHandler[i])
            if i ~= numCat then out=out.."," end
        end
        DevDebug("cache {"..out.."}")
    end, 
    ["pool"] = function() 
        if not SV.dev then return end
        local out = ""
        for i=1,numCat do 
            out = out..tostring(poolHandler[i])
            if i ~= numCat then out=out.."," end
        end
        DevDebug("pool {"..out.."}")
    end, 
    ["pos"] = function(par) 
        if not SV.dev then return end
        -- list all position icons for current zone
        if par == "here" then 
            d(positionIcons[cZone])
        -- list all position icons for specific zone
        elseif type(par) == "number" then 

        -- list number of position icons for all zones
        else 

        end
    end, 
    ["here"] = function(par)
        if not par then par = "LFI_Here" end
        local zone, wX, wY, wZ = GetUnitRawWorldPosition("player") 
        LFI.RegisterPositionIcon(zone, par, {x = wX, y=wY, z=wZ})
    end, 
}


SLASH_COMMANDS["/lfi"] = function(argStr) 

    -- display current player position, if no argument is provided
    if argStr == "" then 
        local zone, wX, wY, wZ = GetUnitRawWorldPosition("player")
        d( zo_strformat("[|c00FFFFLFI|r] {x;y;z}={<<2>>;<<3>>;<<4>>}; zone=<<1>>", zone, wX, wY, wZ) )
        return
    end

    -- seperate command from parameter
    argStr = string.lower(argStr)
    local arg={}
    for str in string.gmatch(argStr, "%S+") do
        table.insert(arg, str)
    end

    local cmd = arg[1]
    local par = arg[2]

    -- check if command exists
    if not devCmd[cmd] then return end

    -- call command and provide parameter
    local func = devCmd[cmd]
    if type(func) == "function" then func(par) end 

end

--[[ Ideas ]]
--[[
icon_type:
* mechanic
    * remainAfterDead option (default off) 
    * display name 
    * callback 
    * priority 
* fallen 
    * overwriteEverthingElse
    * eigher way have it as a flag (and then check if person is actually dead)
        or a callback when a player dies
* identify 
    * hodor icons or custom icons 
* buffs (different name)
 
-------
set mechanic icon 
HasMechanicIcon (t/f, prio, name)
remove mechanic icon 

------
register position icon (callback, texture, position, zone)
unregister position icon 

--- ]]