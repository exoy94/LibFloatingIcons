LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons
local Lib = LibExoYsUtilities

local EM = GetEventManager() 
local WM = GetWindowManager()
 

--[[ ------------- ]]
--[[ -- Globals -- ]]
--[[ ------------- ]]

LFI_TYPE_IDENTIFY = 1
LFI_TYPE_MECHANIC = 2 
--LFI_TYPE_



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
}

--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

local idLFI = "LibFloatingIcons"
local vLFI = 0


local currentZone = 0

local icons = {}
local playerIcons = {}
local playerIconVault
local positionIcons = {}
local positionIconVault = {}

local iconCache = {}

--[[ ------------------ ]]
--[[ -- Icon Handler -- ]]
--[[ ------------------ ]]

local RenderSpace 
local Window 
local iconPool = {}

local function CreateIcon() 
    local icon = WM:CreateControl( name, Window, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( BOTTOM, OSI.win, CENTER, 0, 0 )
    icon:SetHidden(true)
    return {
        ["ctrl"] = icon, 
    }
end 

local function GrapIcon() 

end

local function ReleaseIcon() 

end

--[[ ------------ ]]
--[[ -- Update -- ]]
--[[ ------------ ]]

local function OnUpdate()   

    -- early out, check if any icons need to be rendered

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

    local function GetPosition(pos) 
        local x,y,z 
        if Lib.IsString(pos) then  ~, x,y,z = GetUnitWorldPosition(pos) end
        if Lib.IsTable(pos) then x,y,z = pos.x, pos.y, pos.z end
        if Lib.IsFunc(pos) then x,y,z = pos( t ) end
        return x,y,z
    end
    
    local zOrder = {}
    local zTotal = 0

    local function CalculateIconScreenData(pos)
        local wX, wY, wZ = GetPosition(pos)

        wY = wY + 2*100 --offset
        local ata = {}

        -- calculate unit view position
        local pX = wX * i11 + wY * i21 + wZ * i31 + i41
        local pY = wX * i12 + wY * i22 + wZ * i32 + i42
        local pZ = wX * i13 + wY * i23 + wZ * i33 + i43
        
        -- early out if icon is behind camera
        if pZ < 0 then return false end
        zorder[1 + zo_floor( pZ * 100 )] = icon --check
        ztotal = ztotal + 1

        iconData.pZ = pZ

        -- calculate unit screen position
        local w, h = GetWorldDimensionsOfViewFrustumAtDepth( pZ )
        iconData.x, iconData.y = pX * uiW / w, -pY * uiH / h

        -- calculate distance
        local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
        local dist       = 1 + zo_sqrt( dX * dX + dY * dY + dZ * dZ )

        iconData.scale = SV.scaling and 1000 / dist or 1

        local alpha = SV.fadeout and zo_clampedPercentBetween( 1, SV.fadedist * 100, dist ) or 1
        iconData.fade = SV.alpha * alpha * alpha  

        return iconData
    end

    local renderCache = {}

    for i = 1, GROUP_SIZE_MAX do 
        local unit = "group"..i
        local displayName = GetUnitDisplayName(unit) 
        
        if playerIcons[displayName] then 
            CalculateIconScreenData(unit) 
        end        
    end

end


--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

-- update current zoneId 
local function OnZoneIdChange() 
    local newZoneId 
    currentZone = newZoneId
    if not positionIconVault[newZoneId] then return false end
    positionIcons = ZO_ShallowCopy( positionIconVault[newZoneId] )
end 


--[[ ----------------------- ]]
--[[ -- Exposed Functions -- ]]
--[[ ----------------------- ]]

-- positionCallback for moving position icon 
-- blinking 
-- callback to updateIcon (for countdown etc) 
-- mechanicIcon: 

-- for unique icon: texture, callback for animation, 

-- overwrite / return existing icons 


function LFI.RegisterPlayerIcon(player, type, iconData)
    playerIconList[player] = true 
end


function LFI.UnregisterPlayerIcon(player, type)

end


function LFI.RegisterPositionIcon(zoneId, uniqueId, iconData) 
    -- zone id (or map id?)
    -- have iconInfo being a callback to allow for changing texture, size, position etc.
    

    if not positionIconVault[zoneId] then positionIconVault[zoneId] = {} end 

    -- return false if identifier for this zoneId is already used 
    if positionIconVault[zoneId][uniqueId] then return false end

    positionIconVault[zoneId][uniqueId] = iconData 

    if zoneId == currentId then 
        -- Update list 
    end

end


function LFI.UnregisterPositionIcon( zoneId, uniqueId )

    if not positionIconVault[zoneId] then return false end 
    if not positionIconVault[zoneId][uniqueId] then return false end 

    positionIconVault[zoneId][uniqueId] = nil 

    if zoneId == currentId then 
        -- update current list 
    end

end

--[[ ---------- ]]
--[[ -- Menu -- ]]
--[[ ---------- ]]

local function DefineSetting(setting, name, var, param, warning)
    local s = {}
        s.type = setting
        s.name = name 
        s.getFunc = function() return var end
        s.setFunc = function(v) var = v end 
        if setting == "slider" then  
            s.min = param[1] 
            s.max = param[2] 
            s.step = param[3]
            s.decimals = 2
        end
        if warning then 
            s.warning = "Changes require Reloadui"
        end
    return s
end

local function DefineMenu() 
    local LAM2 = LibAddonMenu2

    local panelData = {
        type='panel', 
        name=idLFI, 
        displayName=idLFI, 
        author = "@|c00FF00ExoY|r94 (PC/EU)", 
        version = vLFI, 
        registerForRefresh = true, 
    }
    local optionsTable = {} 

    --TODO add describtions and maybe support for multiple languages? 
    table.insert(optionsTable, Lib.FeedbackSubmenu(idLFI, "info3599-LibFloatingIcons.html"))
    table.insert(optionsTable, {type="header", name="Performance"})
    table.insert(optionsTable, DefineSetting("slider", "Update Interval", SV.interval, {0,100,10}, true))
    table.insert(optionsTable, {type = "header", name="Visual"})
    table.insert(optionsTable, DefineSetting("slider", "Maximum Size", SV.maxSize, {1,10,1}))
    table.insert(optionsTable, DefineSetting("checkbox", "Fadeout", SV.fadeout))
    table.insert(optionsTable, DefineSetting("checkbox", "Distance Scaling", SV.scaling))
    table.insert(optionsTable, DefineSetting("slider", "Fade Distance", SV.fadedist, {0,1,0.1}))
    table.insert(optionsTable, DefineSetting("slider", "Alpha-MaxValue", SV.alpha, {0,1,0.1}))

    LAM2:RegisterAddonPanel('LFI_Menu', panelData)
    LAM2:RegisterOptionControls('LFI_Menu', optionsTable)
end 

-- Setting for max Distance for Render 

-- allow for animated unique icons --> understand animations --> 


--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]

local function Initialize() 
    
    -- load SavedVariables 
    SV = ZO_SavedVars:NewAccountWide('LFI_SV', 1, nil, defaultSV, 'Settings')

    -- register update on first player activated event
    EM:RegisterForEvent(idLFI, EVENT_PLAYER_ACTIVATED, function() 
            EM:UnregisterForEvent(idLFI, EVENT_PLAYER_ACTIVATED)
            EM:RegisterForUpdate(idLFI, SV.interval, OnUpdate)
        end)

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