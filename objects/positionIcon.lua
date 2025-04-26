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

LibFloatingIcons.internal.positionIcon = {}
local PositionIcon = LibFloatingIcons.internal.positionIcon



function PositionIcon:OnZoneChange( oldZone, newZone )
    self:ClearRenderList() 
    self:AddZoneToRenderList( newZone ) 
end


function PositionIcon:GetLibraryIconDefaults() 
    return {
        texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", 
        width = 50, 
        height = 50, 
        color = {1,1,1}, 
        desaturation = 1, 
        offsetX = 0,
        offsetY = 0,
    }
end


function PositionIcon:GetLibraryObjectDefaults() 
    return {
        verticalOffset = 100, 
        enabled = true, 
    }
end


function PositionIcon:GetLibraryRenderDefaults() 
    return {
        scaling = true, 
        fadeout = true, 
        fadedist = 1, 
        basicAlpha = 1
    }
end

--[[ Registry ]]

PositionIcon.registry = {}

function PositionIcon:RegisterObject( obj )
    local zone = obj.zone  
    if not self.registry[zone] then self.registry[zone] = {} end    -- initialize zone-specific subregistry table
    self.registry[zone][obj.sn] = obj -- add object to subregistry

    --- check current zone
    if not LFI.playerActivated then return end 

    if zone == LFI.zone then  
        if obj.enabled then self:AddToRenderList( obj ) end -- add obj to render list if it is in current zone and enabled 
    else
        obj.rootCtrl:SetHidden(true) -- ensure obj is hidden when in different zone
    end
end


function PositionIcon:UnregisterObject( obj )
    table.insert(ObjectPool, self)  -- add icon to objectPool
    self.registry[obj.zone][obj.sn] = nil  -- remove icon from registry
end



--[[ Render List ]]

PositionIcon.renderList = {}

function PositionIcon:AddZoneToRenderList( zone ) 

    local SubRegistry = self.registry[zone] 
    if not SubRegistry then SubRegistry = {} end 

    local counter = 0 
    for sn, obj in pairs( SubRegistry ) do 
        if obj.enabled then 
            self:AddToRenderList( obj ) 
            counter = counter + 1
        end
    end

    if LFI.debug then 
        LFI.debugMsg("RenderList", zo_strformat("Added <<1>> object(s) for <<2>> (id=<<3>>)", LFI.util.ColorString(counter, "white"), LFI.util.ColorString(GetZoneNameById(zone), "orange"), zone ))
    end
end


function PositionIcon:ClearRenderList() 
    for _, obj in pairs( self.renderList ) do 
        self:RemoveFromRenderList( obj ) 
    end

    if LFI.debug then 
        LFI.debugMsg("RenderList", zo_strformat("Removed objects for <<1>> (id=<<2>>)", LFI.util.ColorString(GetZoneNameById(LFI.zone), "orange"), LFI.zone ))
    end
end


function PositionIcon:AddToRenderList( obj ) 
    self.renderList[obj.sn] = obj
    obj.rootCtrl:SetHidden(false)  
end


function PositionIcon:RemoveFromRenderList( obj )
    obj.rootCtrl:SetHidden(true)  -- to ensure it is not rendered anymore 
    self.renderList[obj.sn] = nil 
end





--[[ ------------------------- ]]
--[[ -- PositionIcon Object -- ]]
--[[ ------------------------- ]]

local ObjPool = {} 
local Object = {}

function Object:New(...) 
    local obj = {} 
    setmetatable( obj, self)
    self.__index = self

    obj.id = GetObjectId() 

    local name = "LFI_PositionIcon"..tostring(obj.id) 

    local rootCtrl = WM:CreateControl( name.."_rootCtrl", LFI.window, CT_CONTROL) 
    rootCtrl:ClearAnchors()
    rootCtrl:SetAnchor( BOTTOM, Window, CENTER, 0, 0)
    rootCtrl:SetHidden(true)
    obj.rootCtrl = rootCtrl 

    local icon = WM:CreateControl( name.."_Icon", rootCtrl, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( CENTER, rootCtrl, CENTER, 0, 0)
    icon:SetHidden(false)
    obj.icon = icon 

    obj:Initialize(...) 

    obj.renderOpt = {
        scaling = true, 
        fadeout = true, 
        fadedist = 1, 
        basicAlpha = 1
    }

    return obj
end


function Object:Initialize( Handler, name, zone, initValues ) 
    self.handlerName = Handler.name 
    self.name = name 
    self.zone = zone
    self.sn = GetSerialNumber() 

    local iconDefaults = Handler:GetPositionIconDefault()
    local objectDefaults = Handler:GetPositionObjectDefault() 

    local function _optVar( varName ) 
        return initValues[varName] or iconDefaults[varName] 
    end

    local function _reqVar( varName) 

    end

    self.verticleOffset = objectDefaults.verticalOffset
    self.enabled = objectDefaults.enabled 
    
    if LFI.util.IsTable(initValues) then
        self:SetCoordinates( initValues.x , initValues.y, initValues.z )
        self.icon:SetTexture( _optVar("texture") )
        self.icon:SetDimensions( _optVar("width"), _optVar("height") )
    end

    if LFI.debug then 
        LFI.debugMsg("PositionIcon", zo_strformat("Registered Object: <<1>> by Handler: <<2>>", LFI.util.ColorString(self.name, "orange"), LFI.util.ColorString(self.handlerName, "orange") )  )
    end 

end


function Object:Release() 
      
    self:Disable() -- remove icon from renderList and hide it

    self.sn = nil
    self.zone = nil 
    self.name = nil 
    self.handlerName = nil 

    PositionIcon:UnregisterObject( self )
end


function Object:Enable() 
    self.enabled = true 
    if LFI.zone == self.zone then 
        PositionIcon:AddToRenderList( self ) 
    end
end


function Object:Disable() 
    self.enabled = false 
    PositionIcon:RemoveFromRenderList( self ) 
end



--[[ Getter Functions ]]

function Object:GetRootControl() 
    return self.rootCtrl 
end


function Object:GetIconControl() 
    return self.icon
end


--[[ Setter Functions ]]

function Object:SetCoordinates(x,y,z)
    if x then self.x = x end 
    if y then self.y = y end 
    if z then self.z = z end 
end

function Object:SetVerticleOffset( offset ) 
    self.verticleOffset = offset
end


--[[ Direct Control for Basic Icon ]] 

function Object:SetIconTexture( texture ) 
    self.icon:SetTexture( texture ) 
end

function Object:SetIconDimensions( width, height ) 
    self.icon:SetDimensions( width, height ) 
end

function Object:SetIconOffset( offsetX, offsetY ) 
    self.icon:SetAnchor(CENTER, self.rootCtrl, CENTER, offsetX, offsetY )
end

function Object:SetIconColor( r,g,b,a )
    self.icon:SetColor( r,g,b, a or 1 )
end

function Object:setIconDesaturation( desaturation ) 
    self.icon:SetDesaturation( desaturation )
end


--[[ ------------------------ ]]
--[[ -- LFI Object Handler -- ]]
--[[ ------------------------ ]]

LFI.handler = LFI.handler or {}
local Handler = LFI.handler 


local function GetObject(...) 
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

--- initValues = {
-- x *number*; required
-- y *number*; required 
-- z *number*; required  
-- size *table* {width, height}; default = ??? 
-- texture *string*; default = ??? 
-- color *table* {r,g,b}; default={1,1,1}
-- enabled *bool*; default = ???  
-- desaturation 
-- verticleoffset
--- }

function Handler:RegisterPositionIcon( name, zone, initValues )
    if not name then return end 

    if self.positionIconVault[name] then -- positionIcon name must be unique within one handler
        return 
    end 

    if not zone then return end 

    local obj = GetObject( self, name, zone, initValues ) 
    PositionIcon:RegisterObject( obj ) 

    self.positionIconVault[name] = obj
    return obj 
end

function Handler:AddPositionObject( name, zone, objOpt, iconOpt ) 

    

end



function Handler:RemovePositionObject( obj ) 

end


