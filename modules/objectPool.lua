LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

local WM = GetWindowManager()

LFI.objectPool = {}
local ObjectPool = LFI.objectPool


function ObjectPool:Initialize() 
    local objects = {"position", "unit"}
    for _, objType in ipairs(objects) do 
        self[objType] = { objCounter = 0, snCounter = 0, objects = {}  }
    end
end


function ObjectPool:GetNextObjectId( objType ) 
    self[objType].objCounter = self[objType].objCounter + 1  --- error because table is only initialized in addon init function
    return self[objType].objCounter
end


function ObjectPool:GetNextSerialNumber( objType )     
    self[objType].snCounter = self[objType].snCounter + 1
    return self[objType].snCounter
end


function ObjectPool:StoreObject( objType, obj ) 
    table.insert( self[objType].objects, obj ) 
end


function ObjectPool:AssignObject( objType, ... ) 
    local class = LFI[objType.."Object"] 
    local pool = self[objType].objects
    local obj 

    if ZO_IsTableEmpty(pool) then 
        obj = class:New( ... )
    else 
        obj = pool[#pool] 
        pool[#pool] = nil
        obj:Initialize( ... ) 
    end
    return obj 
end