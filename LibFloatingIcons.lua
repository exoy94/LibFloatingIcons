LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

local EM = GetEventManager() 
local WM = GetWindowManager()
 
LFI.name = "LibFloatingIcons"


--[[ ----------- ]]
--[[ -- Debug -- ]] 
--[[ ----------- ]]

function LFI.debugMsg(title, msg) 
    
    if LibExoYsUtilities then 
        LibExoYsUtilities.Debug(msg, {"LFI-"..title, "cyan"} ) 
    else 
        d( zo_strformat("[<<1>> <<2>> - <<3>>] <<4>>", GetTimeString(), LFI.util.ColorString("LFI", "green"), LFI.util.ColorString(title, "cyan"), msg) )  
    end
end

--[[ ------------- ]]
--[[ -- Utility -- ]]
--[[ ------------- ]]

LFI.util = {}
local Util = LFI.util 

function Util.IsTable( t ) 
    return type(t) == "table"
end

function Util.ColorString(str, colorName) 
    local colorList = {
      ["green"] = "00ff00",  
      ["orange"] = "ff8800", 
      ["cyan"] = "00ffff", 
    }
    local colorHex = colorList[colorName]
    if colorHex then 
      return string.format( "|c%s%s|r", colorHex, str)
    else
      return str 
    end
  end

--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

local function OnZoneChange( oldZone, newZone )
    
    if LFI.debug then 
        LFI.debugMsg("ZoneChange", zo_strformat("<<1>> (<<2>>) -> <<3>> (<<4>>)", LFI.util.ColorString(GetZoneNameById(oldZone), "orange"), oldZone, LFI.util.ColorString(GetZoneNameById(newZone), "orange"), newZone )  )
    end  
    LFI.positionIcon:OnZoneChange( oldZone, newZone ) 
    LFI.zone = newZone
 
end



local function OnPlayerActivated() 
    local zone = GetZoneId(GetUnitZoneIndex("player")) 
    if zone ~= LFI.zone then 
        OnZoneChange( LFI.zone, zone ) 
    end 
end


local function OnInitialPlayerActivated() 
    EM:UnregisterForEvent( LFI.name, EVENT_PLAYER_ACTIVATED)
    
    LFI.zone = GetZoneId(GetUnitZoneIndex("player"))
    OnZoneChange(0, LFI.zone)

    EM:RegisterForUpdate( LFI.name, 10, LFI.OnUpdate )

    EM:RegisterForEvent( LFI.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)


end

--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]

local function Initialize() 

    LFI.debug = true
    LFI.handlerVault = {}
    
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
	HUD_UI_SCENE:AddFragment( frag )
    HUD_SCENE:AddFragment( frag )
    LOOT_SCENE:AddFragment( frag )

    EM:RegisterForEvent(LFI.name, EVENT_PLAYER_ACTIVATED, OnInitialPlayerActivated) 
    
    LFI.initialized = true
end

local function OnAddonLoaded(_, addonName) 
    if addonName == LFI.name then 
        Initialize()
        EM:UnregisterForEvent(LFI.name, EVENT_ADD_ON_LOADED)
    end
end

EM:RegisterForEvent(LFI.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)




--[[ Handler ]]

LFI.handler = LFI.handler or {}
local Handler = LFI.handler 

function Handler:ToggleDebug() 
    self.debug = not self.debug 

end


--[[ Exposed Functions   ]]

function LibFloatingIcons:RegisterHandler( handlerName ) 

    if LFI.handlerVault[handlerName] then 
        LFI.debugMsg("Error", zo_strformat("Duplicate Handler Registration: <<1>>", Util.ColorString(handlerName, "orange") ) )
        return 
    end

    local Meta = self.internal.handler
    local Handler = {}
    setmetatable( Handler, {__index = Meta} )

    Handler.name = handlerName
    Handler.debug = true

    --- PositionIcon - Specific 
    Handler.positionIconDefault = {}
    setmetatable(Handler.positionIconDefault, {__index = LFI.positionIcon:GetLibraryIconDefaults() })

    Handler.positionIconVault = {}


    LFI.handlerVault[handlerName] = Handler 
    return Handler
end