LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LFI.objects = {} 
LFI.objects.class = {}

local ObjectClass = LFI.objects.class 


function ObjectClass:New( obj ) 

    obj = obj or {}
    setmetatable( obj, self ) 
    self.__index = self 

    return obj 
end


