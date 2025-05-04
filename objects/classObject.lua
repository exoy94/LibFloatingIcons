LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.internal.objectClass = {}
local ObjectClass = LibFloatingIcons.internal.objectClass


function ObjectClass:New( objType, ... ) 

    local obj = {}
    setmetatable( obj, self ) 
    self.__index = self 

    obj.id = LibFloatingIcons.internal.objectPool:GetNextObjectId( objType ) 
    obj.type = objType 

    return obj 
end


function ObjectClass:Output() 
    d("Output ObjectClass")
end