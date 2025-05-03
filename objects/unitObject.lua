LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.internal.unitObject = {}
local UnitObject = LibFloatingIcons.internal.unitObject

local WM = GetWindowManager()


function UnitObject:New(...) 
    local obj = {}
    setmetatable( obj, self)
    self.__index = self

    obj.id = LFI.objectPool:GetNextObjectId( "unit" ) 

    obj.ctrlName = "LFI_UnitObj"..tostring(obj.id)

    local rootCtrl = WM:CreateControl( obj.ctrlName.."_rootCtrl", LFI.window, CT_CONTROL) 
    rootCtrl:ClearAnchors()
    rootCtrl:SetAnchor( BOTTOM, LFI.window, CENTER, 0, 0)
    rootCtrl:SetHidden(true)
    
    local icon = WM:CreateControl( obj.ctrlName.."_Icon", rootCtrl, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( CENTER, rootCtrl, CENTER, 0, 0)
    icon:SetHidden(false)

    obj.controls = {rootCtrl = rootCtrl, icon = icon}


    obj:Initialize(...) 
    
    return obj
end