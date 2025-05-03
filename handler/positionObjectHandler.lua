LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LibFloatingIcons.internal.positionObjectHandler = {}
local PositionObjectHandler = LFI.positionObjectHandler

local WM = GetWindowManager()



function PositionObjectHandler:OnZoneChange( oldZone, newZone )
    self:ClearRenderList() 
    self:AddZoneToRenderList( newZone ) 
end



--[[ Registry ]]

PositionObjectHandler.registry = {}

function PositionObjectHandler:RegisterObject( obj )
    local zone = obj.zone  
    if not self.registry[zone] then self.registry[zone] = {} end    -- initialize zone-specific subregistry table
    self.registry[zone][obj.sn] = obj -- add object to subregistry

    --- check current zone
    if not LFI.playerActivated then return end 

    if zone == LFI.zone then  
        if obj.data.enabled then self:AddToRenderList( obj ) end -- add obj to render list if it is in current zone and enabled 
    else
        obj.controls.rootCtrl:SetHidden(true) -- ensure obj is hidden when in different zone
    end
end


function PositionObjectHandler:UnregisterObject( obj )
    self.registry[obj.zone][obj.sn] = nil  -- remove icon from registry
end



--[[ Render List ]]

PositionObjectHandler.renderList = {}

function PositionObjectHandler:AddZoneToRenderList( zone ) 

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


function PositionObjectHandler:ClearRenderList() 
    for _, obj in pairs( self.renderList ) do 
        self:RemoveFromRenderList( obj ) 
    end

    if LFI.debug then 
        LFI.debugMsg("RenderList", zo_strformat("Removed objects for <<1>> (id=<<2>>)", LFI.util.ColorString(GetZoneNameById(LFI.zone), "orange"), LFI.zone ))
    end
end


function PositionObjectHandler:AddToRenderList( obj ) 
    self.renderList[obj.sn] = obj
    obj.controls.rootCtrl:SetHidden(false) 
end



function PositionObjectHandler:RemoveFromRenderList( obj )
    obj.controls.rootCtrl:SetHidden(true)  -- to ensure it is not rendered anymore 
    self.renderList[obj.sn] = nil 
end



--[[ ----------------------------------- ]]
--[[ -- Interface for PositionObjects -- ]]
--[[ ----------------------------------- ]]

LFI.interfaceHandler = LFI.interfaceHandler or {}
local InterfaceHandler = LFI.interfaceHandler 


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



function InterfaceHandler:AddPositionObject( name, zone, objOpt, iconOpt ) 
    -- name must be a unique string for position objects of this handler 
    if not name then return end 
    if not LFI.util.IsString(name) then return end 
    if self.positionObjectVault[name] then return end 

    if not zone then return end 

    local obj = LFI.objectPool:AssignObject( "position", self, name, zone, objOpt, iconOpt ) -- get obj from pool and initialize it 
    ExoyTest = obj
    PositionObjectHandler:RegisterObject( obj ) -- add to registry and render list (if applicable) 
    self.positionObjectVault[name] = obj
    return obj 
end



function InterfaceHandler:RemovePositionObject( obj ) 

    self.positionObjectVault[obj.objName] = nil     -- list of all objects from this handler
    obj:Disable() 
    obj.sn = nil 
    obj.zone = nil 
    obj.objName = nil 
    obj.handlerName = nil 
    
    PositionObjectHandler:UnregisterObject( obj ) 
    LFI.objectPool:StoreObject( "position", obj )
end


