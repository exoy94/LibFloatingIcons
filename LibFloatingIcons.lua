LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons

local em = GetEventManager() 
local wm = GetWindowManager() 


--[[ -- Constants -- ]]


--[[ -- Variables -- ]]

local positionIconVault = {}
local positionIcons = {}
local currentZone = 0
local RenderSpace 

--[[ -- IconCache -- ]]



local function OnUpdate() 
    
    -- check 
    -- early out, check if any icons need to be rendered
    -- calculate camera inverse

    -- screen dimensions
    local uiW, uiH = GuiRoot:GetDimensions()

    -- prepare render space
    Set3DRenderSpaceToCurrentCamera( LFI.space:GetName() )

    -- retrieve camera world position and orientation vectors
    local cX, cY, cZ = GuiRender3DPositionToWorldPosition( LFI.space:Get3DRenderSpaceOrigin() )
    local fX, fY, fZ = LFI.space:Get3DRenderSpaceForward()
    local rX, rY, rZ = LFI.space:Get3DRenderSpaceRight()
    local uX, uY, uZ = LFI.space:Get3DRenderSpaceUp()

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

--- 



--[[ OLD ]]

--[[ 1. Create Render Space ]]

LFI.space = wm:CreateControl( "LFI_Space", GuiRoot, CT_CONTROL )
LFI.space:SetAnchorFill( GuiRoot )
LFI.space:Create3DRenderSpace() 
LFI.space:SetHidden( true ) 



--[[ 2. Inverse Camera Matrix ]]
-- Currently at start of OnUpdate function 

-- prepare render space
Set3DRenderSpaceToCurrentCamera( LFI.space:GetName() )

-- retrieve camera world position and orientation vectors
local cX, cY, cZ = GuiRender3DPositionToWorldPosition( LFI.space:Get3DRenderSpaceOrigin() )
local fX, fY, fZ = LFI.space:Get3DRenderSpaceForward()
local rX, rY, rZ = LFI.space:Get3DRenderSpaceRight()
local uX, uY, uZ = LFI.space:Get3DRenderSpaceUp()

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

-- screen dimensions
local uiW, uiH = GuiRoot:GetDimensions()


local function UpdateIcon() 
    local zone, wX, wY, wZ  

    wY = wY + offset*100 -- offset needed for position icons? 

    -- calculate unit view position
    local pX = wX * i11 + wY * i21 + wZ * i31 + i41
    local pY = wX * i12 + wY * i22 + wZ * i32 + i42
    local pZ = wX * i13 + wY * i23 + wZ * i33 + i43

    --early out if icon is in back
    if pz <= 0 then return end 

    local w, h = GetWorldDimensionsOfViewFrustumAtDepth( pZ )
    local x, y = pX * uiW / w, -pY * uiH / h

    --update icon position 
    --local ctrl = icon.ctrl
    --SetAnchor( BOTTOM, OSI.win, CENTER, x, y )

    --update icon data 

    -- calculate distance
    local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
    local dist       = 1 + zo_sqrt( dX * dX + dY * dY + dZ * dZ )

    -- update icon size
    ctrl:SetDimensions( size, size )
    ctrl:SetScale( scaling and 1000 / dist or 1 )

    -- update icon opacity
    local alpha = fadeout and zo_clampedPercentBetween( 1, fadedist * 100, dist ) or 1
    ctrl:SetAlpha( basealpha * alpha * alpha )

        -- FIXME: handle draw order
    -- in theory, 2 icons could have the same floored pZ
    -- zorder buffer should either store icons in tables or
    -- decrease chance for same depth by multiplying pZ before
    -- flooring for additional precision
    zorder[1 + zo_floor( pZ * 100 )] = icon
    ztotal = ztotal + 1
end

--TODO!!! DRAW ORDER 


for k,v in ipairs( ListOfPositionIcons ) do

end


for i = 1, GROUP_SIZE_MAX do 
    
end


for k,v in ipairs( allys/ companions ) do 

end



--[[ 3. Update Icons ]]

local zone, wX, wY, wZ 
-- given for positions
-- determine for units by "GetUnitRawWorldPosition( unitTag)"

wY = wY + offset * 100
    
-- calculate unit view position
local pX = wX * i11 + wY * i21 + wZ * i31 + i41
local pY = wX * i12 + wY * i22 + wZ * i32 + i42
local pZ = wX * i13 + wY * i23 + wZ * i33 + i43

-- if unit is in front
if pZ > 0 then
    -- calculate unit screen position
    local w, h = GetWorldDimensionsOfViewFrustumAtDepth( pZ )
    local x, y = pX * uiW / w, -pY * uiH / h

    -- update icon position
    local ctrl = icon.ctrl
    ctrl:ClearAnchors()
    ctrl:SetAnchor( BOTTOM, OSI.win, CENTER, x, y )

    -- update icon data
    OSI.UpdateIconData( icon, tex, col, hodor )

    -- calculate distance
    local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
    local dist       = 1 + zo_sqrt( dX * dX + dY * dY + dZ * dZ )

    -- update icon size
    ctrl:SetDimensions( size, size )
    ctrl:SetScale( scaling and 1000 / dist or 1 )

    -- update icon opacity
    local alpha = fadeout and zo_clampedPercentBetween( 1, fadedist * 100, dist ) or 1
    ctrl:SetAlpha( basealpha * alpha * alpha )

    -- show icon
    ctrl:SetHidden( false )

    -- FIXME: handle draw order
    -- in theory, 2 icons could have the same floored pZ
    -- zorder buffer should either store icons in tables or
    -- decrease chance for same depth by multiplying pZ before
    -- flooring for additional precision
    zorder[1 + zo_floor( pZ * 100 )] = icon
    ztotal = ztotal + 1
end


--[[ 4. Handling of Allies etc. ]]

-- ally icons
local ally = ALLIES[GetActiveCollectibleByType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER )]
if ally then
    for i = 1, MAX_PET_UNIT_TAGS do
        local unit = "playerpet" .. i
        if DoesUnitExist( unit ) and IsUnitFriendlyFollower( unit ) and (GetUnitCaption( unit )  or GetUnitName(unit) == "Giladil the Ragpicker") then
            local data = OSI.GetOption( ally )
            if data.show then
                tex = data.icon
                col = data.color

                UpdateUnit( unit, OSI.GetIconForCompanion() )
            end
            break
        end
    end
elseif DoesUnitExist( "companion" ) then
    local did  = GetActiveCompanionDefId()
    local cid  = GetCompanionCollectibleId( did )
    local comp = cid and COMPANIONS[cid] or nil
    local data = comp and OSI.GetOption( comp ) or nil
    if data then
        local show  = data.show
        local color = nil

        if show then
            if IsUnitDead( "companion" ) then
                offset = dead.offset

                if data.dead then
                    data  = dead
                    color = IsUnitBeingResurrected( "companion" ) and data.colrez or data.color
                    show  = true
                end
            end

            tex = data.icon
            col = color or data.color

            UpdateUnit( "companion", OSI.GetIconForCompanion() )
        end
    end
end