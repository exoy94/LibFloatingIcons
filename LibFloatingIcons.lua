LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

local EM = GetEventManager() 
local WM = GetWindowManager()
local CM = ZO_CallbackObject:New()
 
LFI.name = "LibFloatingIcons"
LFI.version = "0.3"

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

function LFI.debugMsg(titleInfo, msg) 
    local titleStr = Util.IsTable(titleInfo) and " - "..titleInfo[1] or ""
    local titleColor = Util.IsTable(titleInfo) and titleInfo[2] or "cyan"
    local title = Util.ColorString( "LFI"..titleStr, titleColor)
    d( zo_strformat("<<1>> <<2>><<3>> <<4>>", Util.ColorString("["..GetTimeString(), "gray"), title, Util.ColorString("]", "gray"), msg) )  
end


--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

local function OnPlayerActivated() 
    local newZone = GetZoneId(GetUnitZoneIndex("player")) 
    if newZone ~= LFI.zone then 
        LFI.debugMsg( {"Zone", "green"} , "new zone "..tostring(newZone) )
        LFI.positionHandler:ClearRegistry() 
        CM:FireCallbacks("LFI_ZoneChange", newZone)
    LFI.zone = newZone 
    end 
end


local function OnInitialPlayerActivated() 

    EM:UnregisterForEvent( LFI.name, EVENT_PLAYER_ACTIVATED)
    
    LFI.zone = GetZoneId(GetUnitZoneIndex("player"))
    CM:FireCallbacks("LFI_ZoneChange", LFI.zone)
    --LFI.positionObjectHandler:AddZoneToRenderList( LFI.zone )   
    --LFI.playerActivated = true 
    
    LFI.OnUpdate() -- prevents objs to shortly pop-up on cneter screen after reload
    EM:RegisterForUpdate( LFI.name, 10, LFI.OnUpdate )
    EM:RegisterForEvent( LFI.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

end


--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]

local function Initialize() 

    --- saved variables 

    --- menu 


    --- variables 
    LFI.interfaceVault = {}

    --- initialize objects and handler
    LFI.objectPool:Initialize()

    local Classes = LibFloatingIcons.classes 
    LFI.unitObject = Classes.objectClass:New( Classes.unitObject ) 
    LFI.positionObject = Classes.objectClass:New( Classes.positionObject ) 

    LFI.unitHandler = Classes.handlerClass:New( Classes.unitHandler ) 
    LFI.positionHandler = Classes.handlerClass:New( Classes.positionHandler )

    LibFloatingIcons.classes = nil 

    --- initialize render environment 
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

    -- create parent window scene fragment (only local to prevent crash when iterating over internal)
    local frag = ZO_HUDFadeSceneFragment:New( Window )
    HUD_UI_SCENE:AddFragment( frag )
    HUD_SCENE:AddFragment( frag )
    LOOT_SCENE:AddFragment( frag )

    LFI.unitHandler:CreateMasterControls()

    LFI.initialized = true 

    EM:RegisterForEvent(LFI.name, EVENT_PLAYER_ACTIVATED, OnInitialPlayerActivated) 

end

local function OnAddonLoaded(_, addonName) 
    if addonName == LFI.name then 
        Initialize()
        EM:UnregisterForEvent(LFI.name, EVENT_ADD_ON_LOADED)
    end
end

EM:RegisterForEvent(LFI.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)







