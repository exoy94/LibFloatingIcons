LibFloatingIcons = LibFloatingIcons or {}
local LFI = LibFloatingIcons 

local WM = GetWindowManager()


local Handler = {}
Handler.__index = Handler 


function Handler:New(addon, name, position, texture) 
    local obj = setmetatable( {}, Handler)

    --- position *table*:nilable
    -- defines zone, world position, vertical offset 

    --- texture *table*:nilable 
    -- defines, texture, color, size for default texture (simple usecase) 

    local ctrl = WM:CreateControl( name.."ctrl", LFI.window, CT_CONTROL) 
    ctrl:ClearAnchors()
    ctrl:SetAnchor( BOTTOM, Window, CENTER, 0, 0)
    ctrl:SetHidden(false) 

    local icon = WM:CreateControl( name.."_Icon", ctrl, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    icon:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES) 
    icon:SetTexture( GetAbilityIcon(112323) )
    icon:SetDimensions(50,50)

    obj.addon = addon
    obj.name = name 
    obj.ctrl = ctrl 

    obj.position = {position.x, position.y, position.z}
    
    -- create a control to the top level window 
    -- create a texture control 

    --- need some sort of list, where the library keeps track of all the handler 

    return obj
end

function Handler:GetPosition() 
    return self.position
end

function Handler:GetCtrl() 
    return self.ctrl 
end



-- function like this to adjust the predefined texture 
function Handler:SetTexture() 

end




--- advanced display option 
-- you add your controls here and can build your own display 
-- since you have the ctrl, you can do all kind of fancy stuff that do not need to be covered by the library 
function Handler:AddControl( ctrlType )
    --- need to determine name 
    --- potentially some objPool aspect? 
    local ctrl = WM:CreateControl( name, self.ctrl, ctrlType ) --- can probably use a template control here, where i removed all the functions i dont want 
    ctrl:ClearAnchors() 
    ctrl:SetAnchor( CENTER, self.ctrl, CENTER )
    --- have to save the ctrl somewhere?!
    return ctrl 
end


--[[ ----------------- ]]
--[[ -- Moving Icon -- ]] -- Dynamic Icon 
--[[ ----------------- ]] 

-- flag to set a icon dynamic. this adds the constant position check. 

-- feature to define a path for the icon to move along 

--- define starting position 
--- define end position 
--- define midway points 
--- define time points for each waypoint 
-- define total duration in seconds, then all position in between are relativ with end position value = 1 

--- function for start animation 
--- need to define how icon behaves outside of animation (probably need different name to prevent confusion) 

--[[ internally, i just need to update the current position ]]


--position = {zone, x, y, z, activeState} 
--icon = {texture, size, color, }


function LFI.RegisterPositionIcon( addon, name, position, icon )
    local obj = Handler:New( addon, name, position, icon )  
    table.insert(LFI.activePositionIcons, obj)
    return obj 
    --- i need to provide a subclass only with the things that i want to have exposed 
end
