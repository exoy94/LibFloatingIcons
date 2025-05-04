LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.init = LibFloatingIcons.init or {}
LibFloatingIcons.init.handlerClass =     {}

local HandlerClass = LibFloatingIcons.init.handlerClass


function HandlerClass:New( obj ) 

    obj = obj or {}
    setmetatable( obj, self ) 
    self.__index = self 

    obj.render = {} 
    obj.registry = {}


    return obj 
end


function HandlerClass:AddToRenderList( id, obj ) 
    self.render[id] = obj 
end



function HandlerClass:RemoveFromRenderList( key ) 
    self.render[id] = nil 
end




