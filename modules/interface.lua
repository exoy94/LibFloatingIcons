LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal

LFI.interface = LFI.interface or {}
local Interface = LFI.interface 


--[[ Icon Templates ]] 

local libraryIconTemplateDefault = {
    texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", 
    width = 0, 
    height = 0, 
    hidden = true,
    color = {1,1,1}, 
    offsetX = 0,
    offsetY = 0,
}

function Interface:DefineIconTemplate( name, opt )
    opt = opt or {}
    self.iconTemplates[name] = opt 
    setmetatable(self.iconTemplates[name], {__index = libraryIconTemplateDefault } ) 
end


function Interface:GetIconTemplate( name ) 
    return self.iconTemplates[name] or libraryIconTemplateDefault
end
 


local libraryPositionObjectDataDefault = { 
    x = 0, 
    y = 0, 
    z = 0, 
    enabled = false, 
    hidden = true, 
}



local libraryUnitObjectDataDefault = {
    enabled = false, 
    hidden = true,    
}




--[[ Object Handling ]]

local function AddObject( self, objType, name, objData, iconSettings ) 
    -- self = respective Interface 
    --- ToDo variable check 
    -- unique name 
    -- correct variable types 

    local Handler = self:GetHandler()
    -- provides the interfac to use individual default values 
    local obj = Handler:AddObject( self, name, objData, iconSettings)

    --- ToDo initial enabled/buffer/render decision 

    self.objectVault[objType][name] = obj

    return obj
end


-- seperate syntax for position and unit to reduce amout of input parameters 

function Interface:AddPositionObject( ...  )
    return AddObject( self, "position", ...)
end

function Interface:AddUnitObject( ...  )
    return AddObject( self, "position", ...)
end




--[[ Exposed Handler Definition ]]

function LibFloatingIcons:RegisterHandler( handlerName ) 
    --- early outs 
    if not LFI.initialized then -- library not properly initialized 
        LFI.debugMsg({"Error", "red"}, zo_strformat("Handler Registration: <<1>> attempted before LFI initialize", LFI.util.ColorString(handlerName, "orange") ) )
        return 
    end 

    if LFI.interfaceVault[handlerName] then -- duplicate handlerName
        LFI.debugMsg({"Error", "red"}, zo_strformat("Duplicate Handler Registration: <<1>>", LFI.util.ColorString(handlerName, "orange") ) )
        return 
    end

    LFI.debugMsg({"Interface", "green"}, zo_strformat("new handler registered: <<1>>", LFI.util.ColorString() ))

    local Handler = {}
    setmetatable( Handler, {__index = Interface } )
    Handler.name = handlerName 

    --- object data defaults 
    Handler.objectDataDefaults = { position = {}, unit = {} }
    setmetatable( Handler.objectDataDefaults.position, {__index = libraryPositionObjectDataDefault} )
    setmetatable( Handler.objectDataDefaults.unit, {__index = libraryUnitObjectDataDefault} )

    Handler.objectVault = { position= {}, unit = {} }

    Handler.iconTemplates = {}

    LFI.interfaceVault[handlerName] = Handler

    return Handler
end 




--[[ ------------------- ]]
--[[ -- Custom Events -- ]]
--[[ ------------------- ]]


local function CustomEventHandler( action, name, callback ) 
    if action then 
        LFI.CM:RegisterCallback(name, callback)
    else 
        LFI.CM:UnregisterCallback(name, callback)
    end
end


function LibFloatingIcons:RegisterForZoneEnter( callback ) 
    CustomEventHandler(true, "LFI_ZoneEnter", callback)
end


function LibFloatingIcons:RegisterForZoneExit( callback ) 
    CustomEventHandler(true, "LFI_ZoneExit", callback)
end


function LibFloatingIcons:UnregisterForZoneEnter( callback ) 
    CustomEventHandler(false, "LFI_ZoneEnter", callback)
end


function LibFloatingIcons:UnregisterForZoneExit( callback ) 
    CustomEventHandler(false, "LFI_ZoneExit", callback)
end




--[[ --------------- ]]
--[[ -- Functions -- ]]
--[[ --------------- ]]


function LibFloatingIcons:PrintUnitPosition( unitTag ) 
    unitTag = unitTag or "player" 
    local CStr = LFI.util.ColorString

    if not DoesUnitExist(unitTag) then 
        d( zo_strformat("[<<1>>] position print: invalid unit (<<2>>)", CStr("LFI", "cyan"), CStr(unitTag,"white")) )
        return 
    end 

    local zone, wX, wY, wZ = GetUnitRawWorldPosition( unitTag )

    local str = zo_strformat("[<<1>>] Position of <<2>> (<<3>>) in <<4>> (<<5>>)", CStr("LFI", "cyan"), CStr(GetUnitName(unitTag), "orange"), CStr(unitTag, "white"), CStr(GetZoneNameById(LFI.zone),"orange"), CStr(LFI.zone, "white") )
    d( zo_strformat("<<1>> at {x,y,z} = {<<2>>, <<3>>, <<4>>}", str, CStr(tostring(wX), "white"), CStr(tostring(wY), "white"), CStr(tostring(wZ), "white")) )
end


function LibFloatingIcons:GetCurrentZoneId() 
    return LFI.zone 
end