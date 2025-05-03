LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

local EM = GetEventManager() 
local WM = GetWindowManager()
 
LFI.name = "LibFloatingIcons"
LFI.version = "0.2"

--[[ ------------- ]]
--[[ -- Utility -- ]]
--[[ ------------- ]]

LFI.util = LFI.util or {}
local Util = LFI.util 

function Util.IsTable( t ) 
    return type(t) == "table"
end

function Util.IsString( s ) 
    return type(s) == "string" 
end

function Util.IsNumber( n ) 
    return type(n) == "number" 
end 

function Util.IsNil( v ) 
    return type(v) == "nil" 
end


function Util.ColorString(str, colorName) 
    local colorList = {
      ["green"] = "00ff00",  
      ["orange"] = "ff8800", 
      ["cyan"] = "00ffff", 
      ["gray"] = "8f8f8f",
      ["white"] = "ffffff",
      ["red"] = "ff0000", 
    }
    local colorHex = colorList[colorName]
    if colorHex then 
      return string.format( "|c%s%s|r", colorHex, str)
    else
      return str 
    end
  end



--[[ ----------- ]]
--[[ -- Debug -- ]] 
--[[ ----------- ]]

function LFI.debugMsg(title, msg) 
    
    local titleStr, titleColor
    if Util.IsTable(title) then 
        titleStr = title[1] 
        titleColor = title[2]
    else 
        titleStr = title 
        titleColor = "cyan" 
    end

    local header = "LFI"
    if titleStr then 
        header = header.." - "..titleStr
    end

    if LibExoYsUtilities then 
        LibExoYsUtilities.Debug(msg, {header, titleColor} ) 
    else 
        d( zo_strformat("[<<1>> <<2>>] <<3>>", Util.ColorString(GetTimeString(), "gray"), Util.ColorString(header, titleColor), msg) )  
    end
end


--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

local function OnPlayerActivated() 

    

    local newZone = GetZoneId(GetUnitZoneIndex("player")) 
    if newZone ~= LFI.zone then 
        --if LFI.debug then 
        --    LFI.debugMsg("ZoneChange", zo_strformat("<<1>> (<<2>>) -> <<3>> (<<4>>)", 
        --    Util.ColorString(GetZoneNameById(LFI.zone), "orange"), LFI.zone, 
        --    Util.ColorString(GetZoneNameById(newZone), "orange"), newZone )  )
        --end  
        LFI.positionObjectHandler:OnZoneChange( LFI.zone, newZone ) 
        LFI.zone = newZone
    end 
end


local function OnInitialPlayerActivated() 

    EM:UnregisterForEvent( LFI.name, EVENT_PLAYER_ACTIVATED)
    
    LFI.zone = GetZoneId(GetUnitZoneIndex("player"))
 
    LFI.positionObjectHandler:AddZoneToRenderList( LFI.zone )   
    LFI.playerActivated = true 
    
    LFI.OnUpdate() -- prevents objs to shortly pop-up on cneter screen after reload
    EM:RegisterForUpdate( LFI.name, 10, LFI.OnUpdate )
    EM:RegisterForEvent( LFI.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end


--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]

local function Initialize() 

    LFI.objectPool:Initialize() 

    local storeDefault = {debug = false}

    --LFI.store = ZO_SavedVars:NewAccountWide("LibFloatingIconsSavedVariables", 0, nil, storeDefault)
    LFI.interfaceHandlerVault = {}
    --LFI.debug = LFI.store.debug 
    LFI.debug = true
    LFI.playerActivated = false 

    local RenderSpace = WM:CreateControl("LFI_RenderSpace", GuiRoot, CT_CONTROl)
    RenderSpace:SetAnchorFill( GuiRoot )
    RenderSpace:Create3DRenderSpace() 
    RenderSpace:SetHidden( true ) 
    LFI.renderSpace = RenderSpace

    -- create parent window for controls
    local Window = WM:CreateTopLevelWindow( 'LFI_Window' )
    Window:SetClampedToScreen( true )
    Window:SetMouseEnabled( false )
    Window:SetMovable( false )
    Window:SetAnchorFill( GuiRoot )
    Window:SetDrawLayer( DL_BACKGROUND )
    Window:SetDrawTier( DT_LOW )
    Window:SetDrawLevel( 0 )
    LFI.window = Window

    -- create parent window scene fragment
    local frag = ZO_HUDFadeSceneFragment:New( Window )
    LFI.sceneFrag = frag
    HUD_UI_SCENE:AddFragment( LFI.sceneFrag )
    HUD_SCENE:AddFragment( LFI.sceneFrag )
    LOOT_SCENE:AddFragment( LFI.sceneFrag )

    EM:RegisterForEvent(LFI.name, EVENT_PLAYER_ACTIVATED, OnInitialPlayerActivated) 

    --LFI:CreateMenu()
    LFI.initialized = true
end

local function OnAddonLoaded(_, addonName) 
    if addonName == LFI.name then 
        Initialize()
        EM:UnregisterForEvent(LFI.name, EVENT_ADD_ON_LOADED)
    end
end

EM:RegisterForEvent(LFI.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)







