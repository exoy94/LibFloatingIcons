LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.classes = LibFloatingIcons.classes or {}
LibFloatingIcons.classes.handlerClass = {}

local HandlerClass = LibFloatingIcons.classes.handlerClass


function HandlerClass:New( obj ) 

    obj = obj or {}
    setmetatable( obj, self ) 
    self.__index = self 

    obj.registry = {} 
    obj.buffer = {}
    obj.render = {} 

    return obj 
end


function HandlerClass:AddObject( Interface, name, objData, iconSettings )
    
    local obj = LFI.objectPool:RetrieveObject( self.type )
    obj:Initialize( Interface, name, objData, iconSettings  ) 

end



function HandlerClass:AddToRenderList( id, obj ) 
    self.render[id] = obj 
end



function HandlerClass:RemoveFromRenderList( key ) 
    local obj = self.render[id] 
    --- hide icon 
    self.render[id] = nil 
end




