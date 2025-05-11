LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.classes = LibFloatingIcons.classes or {}
LibFloatingIcons.classes.positionObject = {}

local PositionObject = LibFloatingIcons.classes.positionObject

PositionObject.type = "position"

function PositionObject:TestFunc() 
    d("---hello world" )
end