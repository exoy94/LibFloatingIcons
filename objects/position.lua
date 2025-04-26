LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}

local LFI = LibFloatingIcons.internal



local WM = GetWindowManager()

--[[ ------------------------- ]]
--[[ -- Incremental Counter -- ]]
--[[ ------------------------- ]]

local snCounter = 0 
local function GetSerialNumber() 
    snCounter = snCounter + 1 
    return snCounter
end

--- objectId 
-- unique number for each object 
-- can be used for mapping 
local objCounter = 0 
local function GetObjectId() 
    objCounter = objCounter + 1
    return objCounter
end

--[[ ------------------------------ ]]
--[[ -- Internal - Position Icon -- ]]
--[[ ------------------------------ ]]

LibFloatingIcons.internal.positionObjects = {}
local PositionObject = LibFloatingIcons.internal.positionObjects



function PositionObject:OnZoneChange( oldZone, newZone )
    self:ClearRenderList() 
    self:AddZoneToRenderList( newZone ) 
end



--[[ Registry ]]

PositionObject.registry = {}

function PositionObject:RegisterObject( obj )
    local zone = obj.zone  
    if not self.registry[zone] then self.registry[zone] = {} end    -- initialize zone-specific subregistry table
    self.registry[zone][obj.sn] = obj -- add object to subregistry

    --- check current zone
    if not LFI.playerActivated then return end 

    if zone == LFI.zone then  
        if obj.data.enabled then self:AddToRenderList( obj ) end -- add obj to render list if it is in current zone and enabled 
    else
        obj.rootCtrl:SetHidden(true) -- ensure obj is hidden when in different zone
    end
end


function PositionObject:UnregisterObject( obj )
    table.insert(ObjectPool, self)  -- add icon to objectPool
    self.registry[obj.zone][obj.sn] = nil  -- remove icon from registry
end



--[[ Render List ]]

PositionObject.renderList = {}

function PositionObject:AddZoneToRenderList( zone ) 

    local SubRegistry = self.registry[zone] 
    if not SubRegistry then SubRegistry = {} end 

    local counter = 0 
    for sn, obj in pairs( SubRegistry ) do 
        if obj.data.enabled then 
            self:AddToRenderList( obj ) 
            counter = counter + 1
        end
    end

    if LFI.debug then 
        LFI.debugMsg("RenderList", zo_strformat("Added <<1>> object(s) for <<2>> (id=<<3>>)", LFI.util.ColorString(counter, "white"), LFI.util.ColorString(GetZoneNameById(zone), "orange"), zone ))
    end
end


function PositionObject:ClearRenderList() 
    for _, obj in pairs( self.renderList ) do 
        self:RemoveFromRenderList( obj ) 
    end

    if LFI.debug then 
        LFI.debugMsg("RenderList", zo_strformat("Removed objects for <<1>> (id=<<2>>)", LFI.util.ColorString(GetZoneNameById(LFI.zone), "orange"), LFI.zone ))
    end
end


function PositionObject:AddToRenderList( obj ) 
    self.renderList[obj.sn] = obj
    obj.controls.rootCtrl:SetHidden(false) 
end


function PositionObject:RemoveFromRenderList( obj )
    obj.controls.rootCtrl:SetHidden(true)  -- to ensure it is not rendered anymore 
    self.renderList[obj.sn] = nil 
end





--[[ ----------------------- ]]
--[[ -- Object Definition -- ]]
--[[ ----------------------- ]]

local ObjPool = {} 
local Object = {}

function Object:New(...) 
    local obj = {} 
    setmetatable( obj, self)
    self.__index = self

    obj.id = GetObjectId() 

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
        algorithm = "CameraMatrixInverse_Legacy", 
        scaling = true, 
        fadeout = true, 
        fadedist = 1, 
        baseAlpha = 1
    }

    return obj
end


function Object:Initialize( Handler, objName, zone, objOpt, iconOpt ) 
    self.handlerName = Handler.name 
    self.objName = objName 
    self.zone = zone
    self.sn = GetSerialNumber() 


    ExoYTest1 = objOpt
    --- object data 
    self.data = {}

    setmetatable( self.data, {__index = Handler.positionObjectDefaults } ) 
    objOpt = objOpt or {}
    for key, value in pairs(objOpt) do 
        self.data[key] = value
    end
    ExoYTest2 = self.data

    self.controls.rootCtrl:SetHidden( self.data["hidden"] )

    --- basic icon 
    iconOpt = iconOpt or {}
    local iconTemplate = Handler:GetIconTemplate( iconOpt.template ) 
    setmetatable( iconOpt, {__index = iconTemplate} )
    
    local icon = self.controls.icon
    icon:SetAnchor( CENTER, self.rootCtrl, CENTER, offsetX, offsetY )
    icon:SetTexture( iconOpt.texture )
    icon:SetDimensions( iconOpt.width, iconOpt.height )
    icon:SetColor( unpack(iconOpt.color) )    

    if LFI.debug then 
        LFI.debugMsg("Position", zo_strformat("Registered Object: <<1>> by Handler: <<2>>", LFI.util.ColorString(self.objName, "orange"), LFI.util.ColorString(self.handlerName, "orange") )  )
    end 

end



function Object:Release() 
      
    self:Disable() -- remove icon from renderList and hide it

    self.sn = nil
    self.zone = nil 
    self.name = nil 
    self.handlerName = nil 

    PositionObject:UnregisterObject( self )
end


function Object:Enable() 
    self.data.enabled = true 
    if LFI.zone == self.zone then 
        PositionObject:AddToRenderList( self ) 
    end
end


function Object:Disable() 
    self.data.enabled = false 
    PositionObject:RemoveFromRenderList( self ) 
end



--[[ Controls ]] 

function Object:CreateControl(name, ctrlType, offsetX, offsetY) 
    local controls = self.controls 
    local ctrl = WM:CreateControl( self.ctrlName.."_"..tostring(name), controls.rootCtrl, ctrlType )
    ctrl:ClearAnchors() 
    ctrl:SetAnchor( CENTER, controls.rootCtrl, CENTER, offsetX, offsetY) 
    controls[name] = ctrl 
    return ctrl 
end

function Object:GetControl(name) 
    return self.controls[name] 
end

function Object:SetCtrlOffset( name, offsetX, offsetY )
    local ctrl = self.controls[name] 
    if ctrl then
        ctrl:SetAnchor( CENTER, controls.rootCtrl, CENTER, offsetX, offsetY )
    end
end

--[[ ------------------------ ]]
--[[ -- LFI Object Handler -- ]]
--[[ ------------------------ ]]

LFI.handler = LFI.handler or {}
local Handler = LFI.handler 


local function AssignObject(...) 
    local obj  
    if ZO_IsTableEmpty(ObjPool) then 
        obj = Object:New(...)  
    else 
        obj = ObjPool[#ObjPool] 
        ObjPool[#ObjPool] = nil  
        obj:Initialize(...) 
    end
    return obj
end


--- Input: 
-- name *string* - name to identify obj. must be unique within all position objects of this handler 
-- zone *number* - specifies the zone, must be provided 
-- objOpt *table*:nilable (optional) - sets objects data, inherits positionObjDefaults from handler
--      x *number* 
--      y *number*
--      z *number*
--      hidden *boolean*
--      enabled *boolean*
--      offset *number*
---      render *table*

-- iconOpt *table*:nilable (optional) - sets up the default icon 
--      template *string* - specifies the template to take non provided properties from 
--      hidden *boolean* 
--      offsetX *number* 
--      offsetY *number* 
--      texture *string* 
--      color *table* 
--      width *number* 
--      height *number* 



function Handler:AddPositionObject( name, zone, objOpt, iconOpt ) 
    -- name must be a unique string for position objects of this handler 
    if not name then return end 
    if not LFI.util.IsString(name) then return end 
    if self.positionObjectVault[name] then return end 

    if not zone then return end 

    local obj = AssignObject( self, name, zone, objOpt, iconOpt ) -- get obj from pool and initialize it 
    ExoyTest = obj
    PositionObject:RegisterObject( obj ) -- add to registry and render list (if applicable) 
    self.positionObjectVault[name] = obj
    return obj 
end



function Handler:RemovePositionObject( obj ) 

    ---ToDO 

end


