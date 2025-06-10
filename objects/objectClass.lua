LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.classes = LibFloatingIcons.classes or {}
LibFloatingIcons.classes.objectClass = {}

local ObjectClass = LibFloatingIcons.classes.objectClass

local WM = GetWindowManager() 



function ObjectClass:New( obj ) 

    obj = obj or {}
    setmetatable( obj, self ) 
    self.__index = self 

    --- early out when defining the subclasses 
    if not LFI.initialized then return obj end

    obj.id = LFI.objectPool:GetNextObjectId( obj.objType )

    --- create basic controls 
    local ctrlName = zo_strformat("LFI_<<1>>Obj<<2>>", obj.objType, obj.id)
    local rootCtrl = WM:CreateControl( ctrlName.."_rootCtrl", LFI.window, CT_CONTROl)
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
    self.data = objData or {}
    setmetatable( self.data, {__index = Interface.objectDefaults[self.objType] } )

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

    if self.data.enabled then 
        self:Enable()
    end

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




--[[ Interaction with Handler ]]

function ObjectClass:GetHandler() 
    return LFI[self.objType.."Handler"]
end







