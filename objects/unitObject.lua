LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal


LFI.init = LibFloatingIcons.init or {}

LFI.init.unitObject = {}

local UnitObject = LFI.init.unitObject 

UnitObject.type = "unit"

function UnitObject:Output() 
    d( "Output UnitObject" )
end


LFI.init.testObject = {}