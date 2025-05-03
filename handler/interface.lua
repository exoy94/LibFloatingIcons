LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}

local LFI = LibFloatingIcons.internal


LFI.interfaceHandler = LFI.interfaceHandler or {}
local Handler = LFI.interfaceHandler 


function Handler:GetPositionObjects() 
    return self.positionObjectVault
end


local libraryPositionObjectDefaults = {
    x = 0, 
    y = 0, 
    z = 0, 
    enabled = false, 
    hidden = true, 
    offset = 0, 
}


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

function Handler:DefineIconTemplate( name, opt )
    opt = opt or {}
    self.iconTemplates[name] = opt 
    setmetatable(self.iconTemplates[name], {__index = libraryIconTemplateDefault } ) 
end

function Handler:GetIconTemplate( name ) 
    return self.iconTemplates[name] or libraryIconTemplateDefault
end


function Handler:SetPositionObjectDefaults( defaults )
    defaults = defaults or {}
    for key, value in pairs(defaults) do 
       self.positionObjectDefaults[key] = value 
    end
end




--[[ Registration Function  ]]

function LibFloatingIcons:RegisterHandler( handlerName ) 

    if LFI.interfaceHandlerVault[handlerName] then 
        LFI.debugMsg({"Error", "red"}, zo_strformat("Duplicate Handler Registration: <<1>>", LFI.util.ColorString(handlerName, "orange") ) )
        return 
    end

    local Meta = self.internal.interfaceHandler
    local NewHandler = {}
    setmetatable( NewHandler, {__index = Meta} )

    NewHandler.name = handlerName

    --- PositionIcon - Specific 
    NewHandler.positionObjectDefaults = {}
    setmetatable(NewHandler.positionObjectDefaults, {__index = libraryPositionObjectDefaults} )

    NewHandler.positionObjectVault = {}
    NewHandler.iconTemplates = {}


    LFI.interfaceHandlerVault[handlerName] = NewHandler 
    return NewHandler
end




