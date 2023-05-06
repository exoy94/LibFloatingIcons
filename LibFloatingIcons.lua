LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons
--local Lib = LibExoYsUtilities

local EM = GetEventManager() 
local WM = GetWindowManager()
 

--[[ ------------- ]]
--[[ -- Globals -- ]] 
--[[ ------------- ]]

LFI_ID = 1
LFI_BUFF = 2
LFI_MECH = 3
LFI_POS = 4
LFI_ALLY = 5

local globalLookup = {
    [LFI_ID] = "identifier", 
    [LFI_BUFF] = "buff", 
    [LFI_MECH] = "mechanic",
    [LFI_POS] = "position",
    [LFI_ALLY] = "allied"
}
--[[ --------------------- ]]
--[[ -- Saved Variables -- ]]
--[[ --------------------- ]]

local SV = {}
local defaultSV = {
    ["interval"] = 10,
    ["fadeout"] = true,
    ["fadedist"] = 1,
    ["scaling"] = true, 
    ["alpha"] = 1,
    ["standardSize"] = 40, 
    ["maxSize"] = 80,
    ["debug"] = false, 
    ["dev"] = false, 
}

--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

-- addon variables 
local idLFI = "LibFloatingIcons"
local vLFI = "0.1"
local uLFI 

-- categories 
local catId = 1
local catBuff = 2
local catMech = 3 
local catPos = 4
local numCat = 4

-- player data 
local user = ""
local cZone = 0  

-- rendering 
local RenderSpace 
local Window 

-- tables 
local playerIcons = {}
local playerIconVault = {}
local alliedIcons = {}                  --including companions, assistant etc. ???? 
local alliedIconVault = {}
local positionIcons = {} 
local positionIconVault = {}

-- standardValue 
local standard = {
    color = {1,1,1}, 
}

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

local function IsFunc(f) 
    return type(f) == "function" 
end

local function IsUserdata(u) 
    return type(u) == "userdata"
end

local function IsTable(t) 
    return type(t) == "table" 
end

--[[ --------------------- ]]
--[[ -- Control Handler -- ]]
--[[ --------------------- ]]

local serialNumber = 0      -- highest existing serialNumber
local memorySize = 0        -- number of controls created
local cacheSize = 0         -- number of controlls currently not used
local controlCache = {}     -- table with unused controls
local activeControls = {}   -- table with serialNumbers, who are assigned a control


local function AssignSN()
    serialNumber = serialNumber + 1
    return serialNumber 
end

local function IsControlActive(sn) 
    return IsTable(activeControls[sn])
end

local function CreateNewControls() 
    local name = string.format("%s_%s_%d", idLFI, "Gui", memorySize)

    local ctrl = WM:CreateControl( name.."ctrl", Window, CT_CONTROL) 
    ctrl:ClearAnchors()
    ctrl:SetAnchor( BOTTOM, Window, CENTER, 0, 0)
    ctrl:SetHidden(false) 

    local backdrop 
    local edge 

    local icon = WM:CreateControl( name.."_Icon", ctrl, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    icon:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES) 
    icon:SetTexture( GetAbilityIcon(112323) )
    icon:SetDimensions(50,50)

    local label = WM:CreateControl( name.."_Label", ctrl, CT_LABEL)
    label:ClearAnchors() 
    label:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
    label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
    label:SetFont("ZoFontWinH1")

    local index = WM:CreateControl( name.."_Index", ctrl, CT_TEXTURE)
    index:ClearAnchors()
    index:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    index:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES) 

    return {ctrl=ctrl, back=back, edge=edge, icon=icon, label=label, index=index}
end


local function AssignControls(sn, cat, subT, name) 
    local controls
    if cacheSize > 0 then 

        controls = controlCache[cacheSize]
        table.remove(controlCache, cacheSize)
        cacheSize = cacheSize - 1
        DevDebug("grab free control - new cacheSize: "..tostring(cacheSize) )

        controls.ctrl:SetHidden(false)
    else 
        memorySize = memorySize + 1
        controls = CreateNewControls() 
        DevDebug("create new controls - new memorySize: "..tostring(memorySize) )
    end
    
    controls.meta = {sn, cat, subT, name} 
    activeControls[sn] = controls -- todo give it controls here? 
    DevDebug("allocated controls (sn = "..tostring(sn)..")")
    return controls
end


local function ReleaseControls(sn) 
    if not IsTable(activeControls[sn]) then return end

    local controls = activeControls[sn]
    controls.ctrl:SetHidden(true) 
    controls.icon:SetTexture(nil) 
    controls.index:SetTexture(nil) 
    controls.meta = nil 

    DevDebug("released controls (sn = "..tostring(sn)..")")
    table.insert(controlCache, controls)
    cacheSize = cacheSize + 1
    activeControls[sn] = nil
end


--[[ ------------ ]]
--[[ -- Update -- ]]
--[[ ------------ ]]


local function OnUpdate()   

    DevDebug("update executed at "..tostring(GetGameTimeMilliseconds()))
    if cacheSize == memorySize then 
        DevDebug("update aborted - no icons used")
        return
    end
    if cacheSize > memorySize then 
        DevDebug("update aborted - corrupted data")
        return
    end

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

    local function UpdateIcon(ctrl, coord, offset)
        local wX, wY, wZ = coord[1], coord[2], coord[3]
        wY = wY + offset

        -- calculate unit view position
        local pX = wX * i11 + wY * i21 + wZ * i31 + i41
        local pY = wX * i12 + wY * i22 + wZ * i32 + i42
        local pZ = wX * i13 + wY * i23 + wZ * i33 + i43
        
        -- early out if icon is behind camera
        if pZ < 0 then return end
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
        ctrl:SetAnchor(BOTTOM, Window, CENTER, x, y)
        ctrl:SetScale( scale )
        ctrl:SetAlpha( fade )
    end
    
    -- update icons for group members
    if IsUnitGrouped("player") then 
        for i = 1, GROUP_SIZE_MAX do 
            local unit = "group"..i
            local displayName = GetUnitDisplayName(unit) 
            if displayName and not displayName == user then 
                DevDebug("updating icons for ["..displayName.."]")  
            end
        end
    end

    -- update icons for player 
    if playerIcons[user] then --todo add here SV check 
        local _, a,b,c = GetUnitRawWorldPosition("player")
        UpdateIcon( playerIcons[user].ctrl, {a,b,c}, 100)
    end


    -- update icons for positions
    if not ZO_IsTableEmpty(positionIcons) then DevDebug("updating position icons in ["..cZone.."]" ) end
    for _,data in ipairs(positionIcons) do   
        --UpdateIcon({Evaluate(info.coord[1],t), Evaluate(info.coord[2],t), Evaluate(info.coord[3],t)}, info.ctrl, info.data)
        UpdateIcon(data.controls.ctrl, data.coord, 100)
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
    OnUpdate()
    DevDebug("update running every "..tostring(interval).."ms") 
end

--[[ --------------------------- ]]
--[[ ---- Support Functions ---- ]]
--[[ -- for Exposed Framework -- ]]
--[[ --------------------------- ]]

local function FindPositionIcon(t, id)
    for k,v in pairs(t) do 
        if v.id == id then 
            return k 
        end
    end
    return false
end

local function ExistPositionIcon(zone, name) 
    local t =  positionIconVault[zone] or {}
    local vault
    local sn

    for k,v in ipairs(t) do 
        if v.name == name then 
            vault = k
            sn = v.sn
        end 
    end

    local active 
    if IsControlActive(sn) then 
        for k,v in ipairs(positionIcons) do 
            if v.name == name then 
                active = k 
            end
        end
    end

    return sn, vault, active
end

-- TODO check input and insert default values if needed

--[[ ----------------------- ]]
--[[ -- Exposed Functions -- ]]
--[[ ----------------------- ]]

-- cat: LFI_ID, LFI_BUFF, LFI_MECH, LFI_POS
-- name: so that other add
-- icon: texture or table 
-- extra: getter/setter, children, meta  

-- icon: texture or {texture, color, size}
function LFI.RegisterPlayerIcon(cat, player, icon) 

    playerIconVault[player] = playerIconVault[player] or {[LFI_ID] = false, [LFI_BUFF] = false, [LFI_MECH] = false}

end



--[[ Position Icons ]]

function LFI.RegisterPositionIcon(zone, name, coord, icon) 
    name = string.lower(name) 

    -- initialize position icon zone subtable
    positionIconVault[zone] = positionIconVault[zone] or {}

    -- early out if name is already used within this zone 
    if ExistPositionIcon(zone, name) then 
        DevDebug("position icon >"..name.."< already exist in ["..tostring(zone).."]")
        return
    end

    -- ToDo: additional checks to verify parameter 

    -- 
    local sn = AssignSN()
    local data = {sn=sn, name=name, coord=coord, icon=icon}

    -- add icon to position vault
    table.insert(positionIconVault[zone], data)
    DevDebug(zo_strformat("add to position vault: > <<1>> < in [<<2>>]; SN: <<3>>", name, zone, sn))  

    -- check current zone, add to displayed icons
    if zone == cZone then 
        data.controls = AssignControls(sn, LFI_POS, zone, name)
        table.insert(positionIcons, ZO_ShallowTableCopy(data) )    
    end

end


function LFI.UnregisterPositionIcon(zone, name) 
    name = string.lower(name) 

    local sn, vault, active = ExistPositionIcon(zone, name)
    if not sn then 
        DevDebug("position icon > "..name.." < doesnt exist in ["..tostring(zone).."]")
    end

    table.remove(positionIconVault[zone], vault)

    if active then 
       ReleaseControls(sn) 
       table.remove(positionIcons, active)  
    end
end

--[[ ---------- ]]
--[[ -- Menu -- ]]
--[[ ---------- ]]

--{name, tt, width, warning}
local menuText = {
    ["interval"] = {LFI_MENU_INTERVAL, LFI_MENU_INTERVAL_TT, "full", nil},
    ["standardSize"] = {LFI_MENU_SIZE, LFI_MENU_SIZE_TT, "half", LFI_MENU_WARNING_RETRO},
    ["maxSize"] = {LFI_MENU_MAXSIZE, LFI_MENU_MAXSIZE_TT, "half", LFI_MENU_WARNING_RETRO},
    ["fadeout"] = {"fadeout", nil, "half", nil},
    ["alpha"] = {"alpha", nil, "half", nil}, 
    ["scaling"] = {"scaling", nil, "half", nil},
    ["fadedist"] = {"fadedist", nil, "half", nil},
    ["debug"] = {LFI_MENU_DEBUG, nil, "full", LFI_MENU_DEBUG_WARN},
}

local function AddOption(setting, var, callback, slider) 
    local text = menuText[var]
    local opt = {type=setting, name=text[1], tooltip=text[2], width = text[3], warning = text[4]}
    opt.getFunc = function() return SV[var] end 
    opt.setFunc = function(v) 
        SV[var] = v 
        if IsFunc(callback) then callback(v) end
    end 
    if slider then 
        opt.min, opt.max, opt.step, opt.decimals = slider[1], slider[2], slider[3], slider[4]
    end
    return opt
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

    table.insert(optionsTable, {
        type="button", 
        name=LFI_MENU_DONATE,
        tooltip = LFI_MENU_DONATE_TT,
        func = function() RequestOpenUnsafeURL( "https://www.buymeacoffee.com/exoy" ) end, 
        width = "half", 
        warning = LFI_MENU_URL,
    })
    table.insert(optionsTable, {
        type="button", 
        name=LFI_MENU_ESOUI,
        func = function() RequestOpenUnsafeURL( "https://www.esoui.com/downloads/info3599-LibFloatingIcons.html" ) end, 
        width = "half", 
        warning = LFI_MENU_URL,
    })
    table.insert(optionsTable, {
        type="button", 
        name=LFI_MENU_MAIL,
        tooltip=LFI_MENU_MAIL_TT,
        func = function() 
            if GetWorldName() == "EU Megaserver" then
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function() 
                        ZO_MailSendToField:SetText("@Exoy94")
                        ZO_MailSendSubjectField:SetText( idLFI )
                        ZO_MailSendBodyField:TakeFocus()   
                    end, 250)
            end
        end, 
        width = "half", 
    })
    table.insert(optionsTable, {
        type="button", 
        name=LFI_MENU_DISCORD,
        func = function() RequestOpenUnsafeURL( "https://discord.gg/MjfPKsJAS9" ) end, 
        width = "half", 
        warning = LFI_MENU_URL,
    })

    table.insert(optionsTable, {type="header", name=LFI_MENU_PERFORMANCE} )
    table.insert(optionsTable, AddOption("slider", "interval", DefineUpdateInterval, {0,80,2,0}) )

    table.insert(optionsTable, {type = "header", name=LFI_MENU_VISUAL} )

    table.insert(optionsTable, AddOption("slider", "standardSize", nil, {10,150,5,0}) )
    table.insert(optionsTable, AddOption("slider", "maxSize", nil, {10,150,5,0}) )

    table.insert(optionsTable, AddOption("checkbox", "fadeout"))
    table.insert(optionsTable, AddOption("slider", "alpha", nil, {0,1,0.1,2}))

    table.insert(optionsTable, AddOption("checkbox", "scaling"))
    table.insert(optionsTable, AddOption("slider", "fadedist", nil, {0,1,0.1,2}))

    table.insert(optionsTable, {type="divider"})
    table.insert(optionsTable, AddOption("checkbox", "debug") ) 

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
        for _, info in ipairs(positionIcons) do 
            ReleaseControl(info.ctrl) 
        end

        -- reset position icon table and change zone variable
        positionIcons = {}
        cZone = zoneId

        -- add position icons from vault to current zone
        if not positionIconVault[cZone] then return end
        for _,info in ipairs(positionIconVault[cZone]) do 
            local entry = ZO_ShallowTableCopy(info) 
            entry.ctrl = AssignControl(catPos, info.data)
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
    user = GetUnitDisplayName("player")

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
    ["active"] = function(par)
        if not SV.dev then return end 
        local empty = ZO_IsTableEmpty(activeControls)
        local detailCache = {}
        for _,controls in pairs(activeControls) do 
            table.insert(detailCache, controls.meta)
        end
        DevDebug(zo_strformat("active control list size: <<1>>", empty and "|cFF0000empty|r" or "|c00FF00"..tostring(#detailCache).."|r"))
        if par=="detail" then 
            for _, metaData in ipairs(detailCache) do  
                d(zo_strformat("[<<1>>] - <<2>> icon; <<3>>; <<4>>", metaData[1], globalLookup[metaData[2]], metaData[3], metaData[4]))
            end
        end
    end, 
    ["test"] = function() 
        d(ExistPositionIcon(1063, "exoytest1"))
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

--[[ --------------- ]]
--[[ -- ToDO List -- ]]
--[[ --------------- ]]


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