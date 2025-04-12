LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons

local EM = GetEventManager() 
local WM = GetWindowManager()
 

LFI.name = "LibFloatingIcons"


--[[ ------------------------ ]]
--[[ -- Calculation Legacy -- ]] 
--[[ ------------------------ ]]





local function Update() 
    -- iterates through a table of ctrls 
    -- for each control, determine screen position 
    -- update posiiton and all other 

    --- execute selected render function 

end



--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]

local function Initialize() 
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

    -- create parent window scene fragment
    local frag = ZO_HUDFadeSceneFragment:New( Window )
	HUD_UI_SCENE:AddFragment( frag )
    HUD_SCENE:AddFragment( frag )
    LOOT_SCENE:AddFragment( frag )

    LFI.window = Window

    LFI.activePositionIcons = {}

    EM:RegisterForEvent(LFI.name, EVENT_PLAYER_ACTIVATED, function() 
        EM:UnregisterForEvent(LFI.name, EVENT_PLAYER_ACTIVATED)

        EM:RegisterForUpdate(LFI.name, 10, LFI.OnUpdate)
    end)


    --- dev 
    LFI.RegisterPositionIcon("LFI_Dev", "test1", {x=83599, y=36919, z=87239}, {   texture = "/esoui/art/icons/achievement_u30_groupboss6.dds" } )
end

local function OnAddonLoaded(_, addonName) 
    if addonName == LFI.name then 
        Initialize()
        EM:UnregisterForEvent(LFI.name, EVENT_ADD_ON_LOADED)
    end
end

EM:RegisterForEvent(LFI.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

