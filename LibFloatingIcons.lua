LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons

local em = GetEventManager() 
local wm = GetWindowManager() 


--[[ ------------- ]]
--[[ -- Globals -- ]]
--[[ ------------- ]]

LFI_TYPE_IDENTIFY = 1
LFI_TYPE_MECHANIC = 2 
--LFI_TYPE_


--[[ --------------- ]]
--[[ -- Variables -- ]]
--[[ --------------- ]]

local positionIconVault = {}
local positionIcons = {}
local currentZone = 0
local RenderSpace 


--[[ --------------- ]]
--[[ -- IconCache -- ]]
--[[ --------------- ]]

local function OnUpdate() 
    
    -- check 
    -- early out, check if any icons need to be rendered

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


    local function CalculateIconScreenData(wX, wY, wZ)
        
        --[[ how to handle offset better]]

        --[[ ody sv!
            local tex       = nil
            local hodor     = nil
            local col       = OSI.BASECOLOR
            local size      = OSI.GetOption( "iconsize" )
            local offset    = OSI.GetOption( "offset" )
            local scaling   = OSI.GetOption( "scaling" )
            local fadeout   = OSI.GetOption( "fadeout" )
            local fadedist  = OSI.GetOption( "fadedist" )
            local basealpha = OSI.GetOption( "alpha" )
            local dead      = OSI.GetOption( OSI.ROLE_DEAD )
        ]]

        local iconData = {}

        wY = wY + 2*100 --offset

        -- calculate unit view position
        local pX = wX * i11 + wY * i21 + wZ * i31 + i41
        local pY = wX * i12 + wY * i22 + wZ * i32 + i42
        local pZ = wX * i13 + wY * i23 + wZ * i33 + i43
        
        -- early out if icon is behind camera
        if pZ < 0 then return false end
        iconData.pZ = pZ

        -- calculate unit screen position
        local w, h = GetWorldDimensionsOfViewFrustumAtDepth( pZ )
        iconData.x, iconData.y = pX * uiW / w, -pY * uiH / h

        -- calculate distance
        local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
        local dist       = 1 + zo_sqrt( dX * dX + dY * dY + dZ * dZ )

        iconData.scale = scaling and 1000 / dist or 1

        local alpha = fadeout and zo_clampedPercentBetween( 1, fadedist * 100, dist ) or 1
        iconData.fade = basealpha * alpha * alpha  

        return iconData
    end

  
    for i = 1, GROUP_SIZE_MAX do 
        local unit = "group"..i
        local displayName = GetUnitDisplayName(unit) 
        
        
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

-- Setting for Update Intervall 
-- Setting for max Distance for Render 

-- allow for animated unique icons --> understand animations --> 


--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]


local function Initialize() 
    
    -- register update (maybe on first player activation)

    -- create render space 
    RenderSpace = wm:CreateControl( "LFI_Space", GuiRoot, CT_CONTROL )
    RenderSpace:SetAnchorFill( GuiRoot )
    RenderSpace:Create3DRenderSpace() 
    RenderSpace:SetHidden( true ) 

end 

local function OnAddonLoaded(_, addonName) 
    if addonName == libName then 
        Initialize()
        em:UnregisterForEvent(libName, EVENT_ADD_ON_LOADED)
    end
end

em:RegisterForEvent(libName, EVENT_ADD_ON_LOADED, OnAddonLoaded)



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