LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal


LFI.unitObject = LFI.objectClass:New( "unit", ... ) 

local UnitObject = LFI.unitObject or {}

local WM = GetWindowManager()


LFI.testObject = LFI.objectClass:New( "position", ...) 

function UnitObject:Output() 
    d( "Output UnitObject" )
end