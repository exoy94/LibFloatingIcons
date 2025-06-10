LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.classes = LibFloatingIcons.classes or {}
LibFloatingIcons.classes.positionObject = {}

local PositionObject = LibFloatingIcons.classes.positionObject

PositionObject.objType = "position"


function PositionObject:SetHidden( state ) 
    self.rootCtrl:SetHidden( state ) 
end


function PositionObject:Enable() 
    local Handler = self:GetHandler() 
    Handler:AddToBuffer( self.id, self )
    self.data.enabled = true 
end


function PositionObject:Disable() 
    self.data.enabled = false 
    local Handler = self:GetHandler() 
    Handler:RemoveFromBuffer( self.id ) 

end 