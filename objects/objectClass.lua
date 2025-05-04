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

    --- create basic controls 
    local ctrlName = zo_strformat("LFI_<<1>>Obj<<2>>", self.type, self.id)
    local rootCtrl = WM:CreateControl( ctrlName.."_rootCtrl" )
    rootCtrl:ClearAnchors()
    rootCtrl:SetAnchor( BOTTOM, LFI.window, CENTER, 0, 0)
    rootCtrl:SetHidden(true)
    obj.rootCtrl = rootCtrl

    local iconCtrl = WM:CreateControl( ctrlName.."_icon", rootCtrl, CT_TEXTURE)
    iconCtrl:ClearAnchors()
    iconCtrl:SetAnchor( CENTER, rootCtrl, CENTER, 0, 0)
    iconCtrl:SetHidden(false)
    obj.iconCtrl = iconCtrl
    
    obj.customControls = {}
    
    return obj 
end



function ObjectClass:Initialize( Interface, name, objData, iconOpt ) 

    self.name = name 

    
    --- apply default settings 


    --- apply icon settings to control 
    iconOpt = iconOpt or {}
    local iconTemplate = Interface:GetIconTemplate( iconOpt.template ) 
    setmetatable( iconOpt, {__index = iconTemplate} )

    local icon = self.iconCtrl
    icon:SetAnchor( CENTER, self.rootCtrl, CENTER, iconOpt.offsetX, iconOpt.offsetY )
    icon:SetTexture( iconOpt.texture )
    icon:SetDimensions( iconOpt.width, iconOpt.height )
    icon:SetColor( unpack(iconOpt.color) )  
    icon:SetHidden( iconOpt.hidden ) 

end




--[[ Basic Controls ]]

function ObjectClass:GetRootControl() 
    return self.rootCtrl
end 


function ObjectClass:GetIconControl() 
    return self.iconCtrl
end


--[[ Custom Controls ]]

function ObjectClass:GetCustomControls() 
    return self.customControls 
end


function ObjectClass:GetCustomControl( name ) 
    return self.customControls[name]
end

--- AddCustomControl() 

--- MoveCustomControl 









