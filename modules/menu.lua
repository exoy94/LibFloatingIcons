LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal


function LFI:CreateMenu() 
    
    local LAM2 = LibAddonMenu2
    local displayName = "Lib Floating Icons"


    local isServerEU = GetWorldName() == "EU Megaserver"

    local function SendIngameMail() 
        SCENE_MANAGER:Show('mailSend')
        zo_callLater(function() 
                ZO_MailSendToField:SetText("@Exoy94")
                ZO_MailSendSubjectField:SetText( self.name )
                ZO_MailSendBodyField:TakeFocus()   
            end, 250)
    end


    local function FeedbackButton() 
        ClearMenu() 
        if isServerEU then 
            AddCustomMenuItem("Ingame Mail", SendIngameMail)
        end
        AddCustomMenuItem("Esoui.com", function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3599-LibFloatingIcons.html") end )  
        AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.com/invite/MjfPKsJAS9") end )  
        ShowMenu() 
    end

    local function DonationButton() 
        ClearMenu() 
        if isServerEU then 
            AddCustomMenuItem("Ingame Mail", SendIngameMail)
        end
        AddCustomMenuItem("Buy Me a Coffee!", function() RequestOpenUnsafeURL("https://www.buymeacoffee.com/exoy") end )  
        ShowMenu() 
    end


    local addonPanel = {
        type                = "panel",
        name                = self.name,
        displayName         = displayName,
        author              = LFI.util.ColorString( "ExoY", "green").." (PC/EU)",
        version             = LFI.util.ColorString( self.version, "orange") ,
        feedback            = FeedbackButton, 
        donation            = isServerEU and DonationButton or "https://www.buymeacoffee.com/exoy",
        registerForRefresh = true,
        registerForUpdate = true,
    }

    local optionControls = {}

    table.insert(optionControls, {
        type = "checkbox", 
        name = "debug", 
        getFunc = function() return LFI.store.debug end, 
        setFunc = function(bool)
            LFI.store.debug = bool   
            LFI.debug = bool     
        end, 
    }) 

    LAM2:RegisterAddonPanel(self.name.."_Menu", addonPanel )
    LAM2:RegisterOptionControls(self.name.."_Menu", optionControls)
end