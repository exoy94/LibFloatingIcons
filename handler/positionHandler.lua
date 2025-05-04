LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.init = LibFloatingIcons.init or {}
LibFloatingIcons.init.positionHandler = {}

local PositionHandler = LibFloatingIcons.init.positionHandler


function PositionHandler:ClearRegistry()
    for id, obj in pairs( self.registry ) do 
        if self.render[id] then 
            self:RemoveFromRenderList( obj )  
        end
        --- put custom ctrls in pool  
        LFI.objectPool:StoreObject( obj )  
        --- remove obj from addonHandler
    end
end

