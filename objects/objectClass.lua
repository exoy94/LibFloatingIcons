LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.init = LibFloatingIcons.init or {}
LibFloatingIcons.init.objectClass = {}

local ObjectClass = LibFloatingIcons.init.objectClass

local WM = GetWindowManager() 



function ObjectClass:New( obj ) 

    obj = obj or {}
    setmetatable( obj, self ) 
    self.__index = self 

    --- early out when defining the subclasses 
    if not LFI.initialized then return obj end

    obj.id = LFI.objectPool:GetNextObjectId( obj.type )
    obj.controls = obj:CreateBasicControls() 

    

    return obj 
end



function ObjectClass:Initialize() 

end



function ObjectClass:CreateBasicControls()
    local ctrlName = zo_strformat("LFI_<<1>>Obj<<2>>", self.type, self.id)
    local rootCtrl = WM:CreateControl( ctrlName.."_rootCtrl" )
    rootCtrl:ClearAnchors()
    rootCtrl:SetAnchor( BOTTOM, LFI.window, CENTER, 0, 0)
    rootCtrl:SetHidden(true)

    local icon = WM:CreateControl( ctrlName.."_icon", rootCtrl, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( CENTER, rootCtrl, CENTER, 0, 0)
    icon:SetHidden(false)

    return { rootCtrl = rootCtrl, icon = icon }
end


function ObjectClass:AddControl() 
    --- take control from controlPool
end


function ObjectClass:GetControls() 
    return self.controls
end


function ObjectClass:GetControl( name ) 
    return self.controls[name]
end



