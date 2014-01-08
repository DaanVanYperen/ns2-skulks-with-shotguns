

// Misc
Script.Load("lua/SkulksWithShotguns/sws_NS2ConsoleCommands_Server.lua")
Script.Load("lua/SkulksWithShotguns/sws_Respawn.lua")

// Custom entity prepping for our mod.
local OriginalGetCreateEntityOnStart = GetCreateEntityOnStart
function GetCreateEntityOnStart(mapName, groupName, values)

    return mapName ~= ShadowSpawn.kMapName
       and mapName ~= VanillaSpawn.kMapName
       and OriginalGetCreateEntityOnStart(mapName, groupName, values)

end

Server.shadowSpawnList = table.array(64)
Server.vanillaSpawnList = table.array(64)

// Custom entity loading for our mod.
local OriginalLoadSpecial = GetLoadSpecial
function GetLoadSpecial(mapName, groupName, values)

    local success = false
    
    if mapName == ShadowSpawn.kMapName then
    
        local entity = ShadowSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.shadowSpawnList, entity)
        success = true
        
    elseif mapName == VanillaSpawn.kMapName then
    
        local entity = VanillaSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.vanillaSpawnList, entity)
        success = true
        
    else 
        return OriginalLoadSpecial(mapName, groupName, values)
    end
    
    return success
    
end