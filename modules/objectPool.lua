LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

local WM = GetWindowManager()

LFI.objectPool = {}
local ObjectPool = LFI.objectPool


function ObjectPool:Initialize() 
    local objectTypes = {"position", "unit"}
    for _, objType in ipairs(objectTypes) do 
        self[objType] = { objCounter = 0, objects = {}  }
    end
end


function ObjectPool:GetNextObjectId( objType ) 
    self[objType].objCounter = self[objType].objCounter + 1  --- error because table is only initialized in addon init function
    return self[objType].objCounter
end


function ObjectPool:StoreObject( obj ) 
    obj.name = nil 
    table.insert( self[obj.type].objects, obj ) 
end


function ObjectPool:RetrieveObject( objType ) 
    local Class = LFI[objType.."Object"] 
    local Pool = self[objType].objects
    local obj 

    if ZO_IsTableEmpty(pool) then 
        obj = Class:New( ... )
    else 
        obj = pool[#pool] 
        pool[#pool] = nil
    end

    return obj 
end