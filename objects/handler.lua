LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}

local LFI = LibFloatingIcons.internal


LFI.handler = LFI.handler or {}
local Handler = LFI.handler 



function Handler:GetPositionObjects() 
    return self.positionObjectVault
end

--[[ Position Icon Default ]]


function Handler:GetPositionObjectDefault() 
    return self.positionObjectDefault
end

local libraryPositionObjectDefaults = {
    x = 0, 
    y = 0, 
    z = 0, 
    enabled = true, 
    hidden = true, 
    offset = 100, 
}


--[[ Icon Templates ]] 

local libraryIconTemplateDefault = {
    texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", 
    width = 50, 
    height = 50, 
    hidden = false,
    color = {1,1,1}, 
    desaturation = 1, 
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



--[[ Registration Function  ]]

function LibFloatingIcons:RegisterHandler( handlerName ) 

    if LFI.handlerVault[handlerName] then 
        LFI.debugMsg({"Error", "red"}, zo_strformat("Duplicate Handler Registration: <<1>>", LFI.util.ColorString(handlerName, "orange") ) )
        return 
    end

    local Meta = self.internal.handler
    local NewHandler = {}
    setmetatable( NewHandler, {__index = Meta} )

    NewHandler.name = handlerName

    --- PositionIcon - Specific 
    NewHandler.positionObjectDefaults = {}
    setmetatable(NewHandler.positionObjectDefaults, {__index = libraryPositionObjectDefaults} )

    NewHandler.positionObjectVault = {}
    NewHandler.iconTemplates = {}


    LFI.handlerVault[handlerName] = NewHandler 
    return NewHandler
end




