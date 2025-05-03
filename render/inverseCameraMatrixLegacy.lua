LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}

local LFI = LibFloatingIcons.internal

function LFI.OnUpdate()  

    --- using LFI variables 
    local RenderSpace = LFI.renderSpace
    local Window = LFI.window

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

    --- calculation of position for each icon 
    local function RenderCtrl(ctrl, wX, wY, wZ, offset, renderOpt) 
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
        local scale = renderOpt.scaling and 1000 / dist or 1

        -- calculate alpha 
        local alpha = renderOpt.fadeout and zo_clampedPercentBetween( 1, renderOpt.fadedist * 100, dist ) or 1
        local fade = renderOpt.baseAlpha * alpha * alpha  

        -- apply settings to control 
        ctrl:SetAnchor(BOTTOM, Window, CENTER, x, y)
        ctrl:SetScale( scale )
        ctrl:SetAlpha( fade )
    end

    --- render position icons 
    for _,obj in pairs( LFI.positionObjectHandler.renderList ) do   
        local data = obj.data 
        RenderCtrl(obj.controls.rootCtrl, data.x, data.y, data.z, data.offset, obj.renderOpt)
    end
    
    --- render unit icons 
    for unit, ctrl in pairs(LFI.unitObjectHandler.renderList) do
        local x,y,z = GetUnitRawWorldPosition(unit) 
        local offset = 100 
        local renderOpt = {scaling = true, fadeout = true, fadedist = 1, baseAlpha = 1}
        RenderCtrl( ctrl, x, y, z, offset, renderOpt)
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