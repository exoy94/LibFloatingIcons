-- ExoY Addon Discord Server: 
-- https://discord.com/invite/MjfPKsJAS9


--[[ General idea of LFI ]]

-- The motivation of LibFloatingIcons is to move the widely used capabilities of OdySupportIcons in a standalone library. 
-- This way I can optimize for usage by multiple parties and seperate adding some new features to OSI and working on the 
-- performance of LFI. This will also bring the option for icons to console with u46. (Maybe there will also be a console version
-- of OSI at some point, but I dont know yet). Moreover, there will be changes to the vanilla api with U47 confirmed by zos. 

--- Main focus of this library is: 
-- 1. easy to use api, if you just want to use the lib the same way you use OSI now 
-- 2. enable much more flexibility for individual tasks beyong the current capabilities of OSI (e.g. animations, moving icons)
-- 3. as now multiple addons can display icons above units, this library will be the common ground to enable a nice user experience 
-- 4. as soon as the api is established, i will focus of further increasing performance 


--[[ Version 0.2 - Position Icons ]]
-- The library is in its early stages. While I am still working on the part to display icons above units, the part to place icons 
-- at specific locations in the world is already progressed nicely. I am looking for feedback for: 
-- 1. is there functionality missing (what were you trying to do)? 
-- 2. how intuitive the api is to use 
-- 3. bug reports or unexpected behavior  


--[[ Example for LFI ]]

-- Start by Registering a handler, 
-- e.g.: 

local name = "lfi_example"
local LFI = LibFloatingIcons:RegisterHandler( name )  

-- @name has to be unique and should indicate by which library/addon the handler was created 

--- Why do I need a handler?  
-- The handler is how i decided to expose the api to create icons. 
-- It enables intuitive api to use individual templates/default settings 
-- It will play a crucial role for the icons above units to work properly. 
-- (That part of the library is still under development. I provide a few more information on my discord) 
-- It will allow to evaluate, which addon outs how much strain on a client, if they experience performance issues due to too many icons. 


--[[ PositionObject ]]
-- The positionObject is a more sophisticated way to place controls in the world with many functionality 
-- The provided object includes a "root"-control, that will be render at the speicified location as are the position icons by OSI 
-- The user can anchor more controls to this root to display whatever they want. 
-- Objects can be define in advance and then enabled/disabled when needed 
--- It is recommended to define icons in advance, especially if multiple objects have to be created simultaneously during a fight. 
-- Objects can be repurposed by changing the attributes. 


--[[ Simple Usecase ]]
-- The simple use case basically is how OSI is used atm. 
-- For that every obj already contains one texture control by default to display an icon. 
-- The Syntax to create a icon (ex: Icon in the entrance are of the "Haven of the five companions")

local objectName = "simpleIcon"
-- name that must be unique for all position objects by the same handler 
local zoneId = 1495
-- zone the icon is to be displayed in 
local objectSettings = {x = 56079, y=30974, z=71492, offset = 100, enabled = true} 
-- (optional) table to define coordinates and offset. "enabled = true" means it will be rendered when in the zone
local iconSettings = {texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", width = 50, height = 50} 
-- (optional) table to define the icon 

--- see: /objects/position.lua 
-- for all properties that can be put into the object and icon settings 

LFI:AddPositionObject( "simpleIcon", 1495, opjectSettings, iconSettings)



--[[ More advanced usage ]]

--- Define Settings Defaults 
-- 




