LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.classes = LibFloatingIcons.classes or {}
LibFloatingIcons.classes.positionHandler = {}

local PositionHandler = LibFloatingIcons.classes.positionHandler

PositionHandler.type = "position"

function PositionHandler:ClearRegistry()
    for id, obj in pairs( self.registry ) do 
        if self.render[id] then 
            self:RemoveFromRenderList( obj )  
        end
        --- put custom ctrls in pool  
        LFI.objectPool:StoreObject( obj )  
        --- remove obj from addonHandler
    end
    --- ToDo also need to deal with buffer 
end


function PositionHandler:AddToBuffer( obj ) 
    --- here include logic for to far away, subzone, mapindex check etc 
    
    self:AddToRenderList( obj.name, obj )
     
end



