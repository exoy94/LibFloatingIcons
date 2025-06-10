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
    obj:Initialize( Interface, name, objData, iconSettings ) 
    return obj

end


function HandlerClass:AddToBuffer(id, obj) 
    self.buffer[id] = obj 
    self:AddToRenderList(id, obj) 
end


function HandlerClass:RemoveFromBuffer( id ) 
    self:RemoveFromRenderList( id ) 
end


function HandlerClass:AddToRenderList( id, obj ) 
    -- obj: unit = masterCtrl; position = obj
    self.render[id] = obj 
    obj:SetHidden( false ) 
end


function HandlerClass:RemoveFromRenderList( id ) 
    -- unit: id = unitTag
    -- position: id = obj.id 
    if self.render[id] then 
        self.render[id]:SetHidden(true) 
    end 
    self.render[id] = nil 
end





