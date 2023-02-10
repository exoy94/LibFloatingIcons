LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons




-- Math / Basics 

    -- create render space control
    OSI.ctrl = OSI.window:CreateControl( "OSICtrl", GuiRoot, CT_CONTROL )
    OSI.ctrl:SetAnchorFill( GuiRoot )
    OSI.ctrl:Create3DRenderSpace()
    OSI.ctrl:SetHidden( true )


    function OSI.OnUpdate()

        -- reset icons
    
        -- early out if 3d icons are toggled
    
        -- prepare render space
        Set3DRenderSpaceToCurrentCamera( OSI.ctrl:GetName() )
    
        -- retrieve camera world position and orientation vectors
        local cX, cY, cZ = GuiRender3DPositionToWorldPosition( OSI.ctrl:Get3DRenderSpaceOrigin() )
        local fX, fY, fZ = OSI.ctrl:Get3DRenderSpaceForward()
        local rX, rY, rZ = OSI.ctrl:Get3DRenderSpaceRight()
        local uX, uY, uZ = OSI.ctrl:Get3DRenderSpaceUp()
    
        -- https://semath.info/src/inverse-cofactor-ex4.html
        -- calculate determinant for camera matrix
        -- local det = rX * uY * fZ - rX * uZ * fY - rY * uX * fZ + rZ * uX * fY + rY * uZ * fX - rZ * uY * fX
        -- local mul = 1 / det
        -- determinant should always be -1
        -- instead of multiplying simply negate
        -- calculate inverse camera matrix
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
    
        -- drawing order
    
        -- icon data
    
        local function UpdateUnit( unit, icon )
            local zone, wX, wY, wZ
            if unit then
                -- get unit world position
                zone, wX, wY, wZ = GetUnitRawWorldPosition( unit )
            else
                -- get icon position
                wX, wY, wZ = icon.x, icon.y, icon.z
            end
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
        end
    
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
    
        -- render position icons
        local posIcons = OSI.GetPositionIcons()
        for _, icon in pairs( posIcons ) do
            icon.ctrl:SetHidden( true )
            if icon.use then
                if type( icon.callback ) == "function" then
                    icon.callback( icon.data )
                end
    
                tex    = icon.data.texture
                size   = icon.data.size
                col    = icon.data.color
                offset = icon.data.offset
    
                UpdateUnit( nil, icon )
            end
        end
    
        -- handle group icons
        if IsUnitGrouped( "player" ) then
            -- update icon config
            icon3DConfig.raid   = OSI.GetOption( "raidallow" )
            icon3DConfig.dead   = dead.show
            icon3DConfig.leader = OSI.GetOption( OSI.ROLE_LEAD ).show
            icon3DConfig.tank   = OSI.GetOption( OSI.ROLE_TANK ).show
            icon3DConfig.healer = OSI.GetOption( OSI.ROLE_HEAL ).show
            icon3DConfig.dps    = OSI.GetOption( OSI.ROLE_DPS ).show
            icon3DConfig.bg     = OSI.GetOption( OSI.ROLE_BG ).show
            icon3DConfig.custom = OSI.GetOption( "customuse" )
            icon3DConfig.unique = not OSI.GetOption( "ignore" )
    
            -- DEBUG:
            local bgdebug = ""
            if OSI.debug then
                bgdebug = "lead: |c00ff00" .. tostring( GetGroupLeaderUnitTag() ) .. "|r\n"
                bgdebug = bgdebug .. "zone: |cff00ff" .. GetUnitZone( "player" ) .. "|r id=" .. GetUnitWorldPosition( "player" ) .. " index=" .. GetCurrentMapZoneIndex() .. "\n"
            end
    
            -- update group icons
            for i = 1, GROUP_SIZE_MAX do    
                local unit        = "group" .. i
                local displayName = GetUnitDisplayName( unit )
                local error       = OSI.UnitErrorCheck( unit )
    
                -- DEBUG:
                if OSI.debug then
                    bgdebug = bgdebug .. "|cff0000" .. error .. "|r |c00ff00" .. unit .. "|r |cff00ff" .. ( displayName and ( displayName .. " " ) or "" ) .. "|r" .. ( error > 0 and ERRORS[error] or "" ) .. "\n"
                end
    
                -- only update if no errors occured
                if error == 0 then
                    -- retrieve texture, color and size
                    tex, col, size, hodor, offset = OSI.GetIconDataForPlayer( displayName, icon3DConfig, unit )
                    -- only update if texture available
                    if tex then
                        UpdateUnit( unit, OSI.GetIconForPlayer( displayName ) )
                    end
                end
            end
    
            -- DEBUG:
            if OSI.debug then
                OSI.bgd:SetText( bgdebug )
            end
        end
    
        -- sort draw order
        if ztotal > 1 then
            local keys = { }
            for k in pairs( zorder ) do
                table.insert( keys, k )
            end
            table.sort( keys )
    
            -- adjust draw order
            for _, k in ipairs( keys ) do
                zorder[k].ctrl:SetDrawLevel( ztotal )
                ztotal = ztotal - 1
            end
        end
    end
    
    function OSI.GetIconDataForPlayer( displayName, config, unit )
        local name   = string.lower( displayName )
        local size   = OSI.GetOption( "iconsize" )
        local offset = OSI.GetOption( "offset" )
        local dead   = OSI.GetOption( OSI.ROLE_DEAD )
        local isDead = unit and IsUnitDead( unit ) or false
        local role   = nil
    
        -- adjust dead player offset
        if dead.useoff and isDead then
            offset = dead.offset
        end
    
        -- handle dead player icon with priority
        if config.dead and dead.priority and isDead then
            return dead.icon, DoesUnitHaveResurrectPending( unit ) and dead.colrdy or ( IsUnitBeingResurrected( unit ) and dead.colrez or dead.color ), size, nil, offset
        end
    
        -- handle mechanic icon
        if config.mechanic and OSI.mechanic and OSI.mechanic[name] then
            local mech = OSI.mechanic[name]
            if type( mech.callback ) == "function" then
                mech.data.unitTag = unit
                mech.callback( mech.data )
            end
            return mech.data.texture, mech.data.color, mech.data.size, nil, mech.data.offset + offset
        end
    
        -- handle raid icon
        if config.raid and OSI.raidlead and OSI.raidlead[name] then
            return OSI.raidlead[name], OSI.BASECOLOR, size, nil, offset
        end
    
        -- retrieve role icon
        if unit then
            local r = GetGroupMemberSelectedRole( unit )
            if config.leader and IsUnitGroupLeader( unit ) then
                role = OSI.GetOption( OSI.ROLE_LEAD )
            elseif config.tank and r == LFG_ROLE_TANK then
                role = OSI.GetOption( OSI.ROLE_TANK )
            elseif config.healer and r == LFG_ROLE_HEAL then
                role = OSI.GetOption( OSI.ROLE_HEAL )
            elseif config.dps and r == LFG_ROLE_DPS then
                role = OSI.GetOption( OSI.ROLE_DPS )
            elseif config.bg and r == LFG_ROLE_INVALID and IsActiveWorldBattleground() then
                role = OSI.GetOption( OSI.ROLE_BG )
            end
        end
    
        -- handle role icon with priority
        if role and role.priority then
            return role.icon, role.color, role.usesize and role.size or size, nil, offset
        end
    
        local reflex  = OSI.GetOption( "hodoruse" ) and HodorReflexes
        local hodor   = reflex and HodorReflexes.users[displayName] or nil
        local anim    = ( reflex and OSI.GetOption( "hodoranim" ) ) and HodorReflexes.anim.users[displayName] or nil
        local unique  = OSI.users[name]
        local special = OSI.special[name]
    
        -- handle custom icon
        if config.custom and special then
            return special.texture, OSI.BASECOLOR, size, nil, offset
        end
    
        -- handle unique or hodor icon
        if config.unique then
            -- handle hodor with priority
            if OSI.GetOption( "hodorprio" ) then
                if config.anim and anim then
                    return anim[1], OSI.BASECOLOR, size, anim, offset
                end
                if hodor and hodor[3] then
                    return hodor[3], OSI.BASECOLOR, size, nil, offset
                end
            end
    
            -- handle unique icon
            if unique then
                return unique, OSI.BASECOLOR, size, nil, offset
            end
    
            -- handle hodor
            if config.anim and anim then
                return anim[1], OSI.BASECOLOR, size, anim, offset
            end
            if hodor and hodor[3] then
                return hodor[3], OSI.BASECOLOR, size, nil, offset
            end
        end
    
        -- handle role icon
        if role then
            return role.icon, role.color, role.usesize and role.size or size, nil, offset
        end
    
        -- handle dead player icon
        if config.dead and isDead then
            return dead.icon, DoesUnitHaveResurrectPending( unit ) and dead.colrdy or ( IsUnitBeingResurrected( unit ) and dead.colrez or dead.color ), size, nil, offset
        end
    
        return nil, OSI.BASECOLOR, size, nil, offset
    end







-- Initialize 


-- On Addon Loaded 


