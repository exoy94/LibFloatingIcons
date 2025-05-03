LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.internal.positionObject = {}
local PositionObject = LibFloatingIcons.internal.positionObject

local WM = GetWindowManager()



function PositionObject:New(...) 
    local obj = {} 
    setmetatable( obj, self)
    self.__index = self

    obj.id = LFI.objectPool:GetNextObjectId( "position" ) 

    obj.ctrlName = "LFI_PositionObj"..tostring(obj.id) 

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

    obj.renderOpt = {
        scaling = true, 
        fadeout = true, 
        fadedist = 1, 
        baseAlpha = 1
    }
    
    return obj
end


function PositionObject:Initialize( Handler, objName, zone, objOpt, iconOpt ) 
    self.handlerName = Handler.name 
    self.objName = objName 
    self.zone = zone
    self.sn = LFI.objectPool:GetNextSerialNumber( "position" )  

    --- object data 
    self.data = {}

    setmetatable( self.data, {__index = Handler.positionObjectDefaults } ) 
    objOpt = objOpt or {}
    for key, value in pairs(objOpt) do 
        self.data[key] = value
    end

    self.controls.rootCtrl:SetHidden( self.data["hidden"] )

    --- basic icon 
    iconOpt = iconOpt or {}
    local iconTemplate = Handler:GetIconTemplate( iconOpt.template ) 
    setmetatable( iconOpt, {__index = iconTemplate} )
    
    local icon = self.controls.icon
    icon:SetAnchor( CENTER, self.controls.rootCtrl, CENTER, offsetX, offsetY )
    icon:SetTexture( iconOpt.texture )
    icon:SetDimensions( iconOpt.width, iconOpt.height )
    icon:SetColor( unpack(iconOpt.color) )    

    if LFI.debug then 
        LFI.debugMsg("Position", zo_strformat("Registered Object: <<1>> by Handler: <<2>>", LFI.util.ColorString(self.objName, "orange"), LFI.util.ColorString(self.handlerName, "orange") )  )
    end 

end


function PositionObject:Enable() 
    self.data.enabled = true 
    if LFI.zone == self.zone then 
        PositionObjectHandler:AddToRenderList( self ) 
    end
end


function PositionObject:Disable() 
    self.data.enabled = false 
    PositionObjectHandler:RemoveFromRenderList( self ) 
end



--[[ Controls ]] 

function PositionObject:CreateControl(name, ctrlType, offsetX, offsetY) 
    local controls = self.controls 
    local ctrl = WM:CreateControl( self.ctrlName.."_"..tostring(name), controls.rootCtrl, ctrlType )
    ctrl:ClearAnchors() 
    ctrl:SetAnchor( CENTER, controls.rootCtrl, CENTER, offsetX or 0 , offsetY or 0) 
    controls[name] = ctrl 
    return ctrl 
end

function PositionObject:GetControl(name) 
    return self.controls[name] 
end

function PositionObject:SetCtrlOffset( name, offsetX, offsetY )
    if name == "rootCtrl" then return end 
    local ctrl = self.controls[name] 
    if ctrl then
        ctrl:SetAnchor( CENTER, controls.rootCtrl, CENTER, offsetX, offsetY )
    end
end