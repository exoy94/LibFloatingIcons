LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}

local LFI = LibFloatingIcons.internal


LFI.handler = LFI.handler or {}
local Handler = LFI.handler 



function Handler:GetPositionObjects() 
    return self.positionIconVault
end

--[[ Position Icon Default ]]


function Handler:SetPositionIconDefault( param, default )
    self.positionIconDefault[param] = default 
end


function Handler:ResetPositionIconDefault( param ) 
    self.positionIconDefault[param] = nil 
end


function Handler:GetPositionIconDefault() 
    return self.positionIconDefault
end




function Handler:GetPositionObjectDefault() 
    return self.positionObjectDefault
end



--[[ Icon Templates ]] 

local libraryIconTemplateDefault = { 



}

function Handler:DefineIconTemplate( name, opt )
    
    self.iconTemplate[name] = opt 
    setmetatable(self.iconTemplate, {__index = libraryIconTemplateDefault } ) 

end



--[[ Registration Function  ]]

function LibFloatingIcons:RegisterHandler( handlerName ) 

    if LFI.handlerVault[handlerName] then 
        LFI.debugMsg({"Error", "red"}, zo_strformat("Duplicate Handler Registration: <<1>>", LFI.util.ColorString(handlerName, "orange") ) )
        return 
    end

    local Meta = self.internal.handler
    local Handler = {}
    setmetatable( Handler, {__index = Meta} )

    Handler.name = handlerName

    --- PositionIcon - Specific 
    Handler.positionIconDefault = {}
    setmetatable(Handler.positionIconDefault, {__index = LFI.positionIcon:GetLibraryIconDefaults() })

    Handler.positionObjectDefault = {}
    setmetatable(Handler.positionObjectDefault, {__index = LFI.positionIcon:GetLibraryObjectDefaults() })

    Handler.positionRenderDefault = {} 
    setmetatable(Handler.positionRenderDefault, {__index = LFI.positionIcon:GetLibraryRenderDefaults() })

    Handler.positionIconVault = {}
    Handler.iconTemplate = {}


    LFI.handlerVault[handlerName] = Handler 
    return Handler
end




