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

    PositionIcon:ClearRenderList() 

    local SubRegistry = self.registry[newZone] 
    if not SubRegistry then return end 

    for sn, obj in pairs( SubRegistry ) do 
        if obj.enabled then 
            self:AddToRenderList( obj ) 
        end
    end
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


--[[ Registry ]]
PositionIcon.registry = {}

function PositionIcon:RegisterObject( obj )
    local zone = obj.zone  
    if not self.registry[zone] then self.registry[zone] = {} end    -- initialize zone-specific subregistry table
    self.registry[zone][obj.sn] = obj -- add object to subregistry

    --- check current zone
    if zone == LFI.zone then  
        if obj.enabled then self:AddToRenderList( obj ) end -- add obj to render list if it is in current zone and enabled 
    else
        obj.rootCtrl:SetHidden(true) -- ensure obj is hidden when in different zone
    end
end


function PositionIcon:UnregisterObject( obj )
   self.registry[obj.zone][obj.sn] = nil  
end


--[[ Render List ]]
PositionIcon.renderList = {}

function PositionIcon:AddToRenderList( obj ) 
    self.renderList[obj.sn] = obj
    obj.rootCtrl:SetHidden(false)  
end

function PositionIcon:ClearRenderList() 
    for _, obj in pairs( self.renderList ) do 
        self:RemoveFromRenderList( obj ) 
    end
end

function PositionIcon:RemoveFromRenderList( obj )
    obj.rootCtrl:SetHidden(true)  -- to ensure it is not rendered anymore 
    self.renderList[obj.sn] = nil 
end





--[[ ------------------------- ]]
--[[ -- PositionIcon Object -- ]]
--[[ ------------------------- ]]

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
    obj.rootCtrl = rootCtrl 

    local icon = WM:CreateControl( name.."_Icon", rootCtrl, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( CENTER, rootCtrl, CENTER, 0, 0)
    obj.icon = icon 

    obj:Initialize(...) 

    return obj
end


function Object:Initialize( Handler, name, zone, initValues ) 
    self.handlerName = Handler.name 
    self.name = name 
    self.zone = zone
    self.sn = GetSerialNumber() 

    local defaults = Handler:GetPositionIconDefault()

    local function _optVar( varName ) 
        return initValues[varName] or defaults[varName] 
    end

    local function _reqVar( varName) 

    end
        self.verticleOffset = 0
    if LFI.util.IsTable(initValues) then
        ---ToDO check for coordinates (required fields) 
        self.x = initValues.x 
        self.y = initValues.y 
        self.z = initValues.z     
        ---ToDO apply icon properties (optional fields) or use default values 
        self.icon:SetTexture( _optVar("texture") )
        self.icon:SetDimensions( _optVar("width"), _optVar("height") )
        self.icon:SetHidden(false) 
    else 
        self.rootCtrl:SetHidden(true)
        self.enabled = false 
    end

    if LFI.debug then 
        LFI.debugMsg("PositionIcon", zo_strformat("Registered Object: <<1>> by Handler: <<2>>", LFI.util.ColorString(self.name, "orange"), LFI.util.ColorString(self.handlerName, "orange") )  )
    end 

end


function Object:Release() 
    PositionIcon:UnregisterObject( self )   -- remove from registry 
    self:Disable() -- remove icon from renderList and hide it

    self.sn = nil
    self.zone = nil 
    self.name = nil 
    self.handlerName = nil 

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

local ObjPool = {} 
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
    return obj 
end


function Handler:SetPositionIconDefault( param, default )
    self.positionIconDefault[param] = default 
end


function Handler:ResetPositionIconDefault( param ) 
    self.positionIconDefault[param] = nil 
end


function Handler:GetPositionIconDefault() 
    return self.positionIconDefault
end

