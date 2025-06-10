LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.classes = LibFloatingIcons.classes or {}
LibFloatingIcons.classes.unitObject = {}

local UnitObject = LibFloatingIcons.classes.unitObject

UnitObject.type = "unit"



function UnitObject:Enable() 
    local Handler = self:GetHandler() 
    --- assign master ctrl 
    self.data.enabled = true 
end



function UnitObject:Disable() 
    self.data.enabled = false 
    local Handler = self:GetHandler() 
    --- master ctrl
end



function UnitObject:UpdateMasterControl() 
    -- adjusts lists when an attribute is changed 
end
