LibFloatingIcons = LibFloatingIcons or {}
local LFI = LibFloatingIcons 

local WM 


local PosIconHandler = {}
PosIconHandler.__index = PosIconHandler 


function PosIconHandler:New( position, texture) 
    local obj = setmetatable( {}, PosIconHandler)

    --- position *table*:nilable
    -- defines zone, world position, vertical offset 

    --- texture *table*:nilable 
    -- defines, texture, color, size for default texture (simple usecase) 

    
    -- create a control to the top level window 
    -- create a texture control 

    --- need some sort of list, where the library keeps track of all the handler 

    return obj
end



-- function like this to adjust the predefined texture 
function PosIconHandler:SetTexture() 

end




--- advanced display option 
-- you add your controls here and can build your own display 
-- since you have the ctrl, you can do all kind of fancy stuff that do not need to be covered by the library 
function PosIconHandler:AddControl( ctrlType )
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





function LFI.RegisterPositionIcon( addon, position, texture )
    return PosIconHandler:New( addon, position, texture )  
end