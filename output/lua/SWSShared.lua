
// deal full damage to friendlies
kFriendlyFireScalar = 1

// enable deathmatch mode by making everyone enemy of everyone.
local original_GetAreEnemies = GetAreEnemies;
function GetAreEnemies(entityOne, entityTwo)  
    return entityOne and entityTwo
end

// specifically allow command chair entry using original enemy logic.
function TeamMixin:GetCanBeUsed(player, useSuccessTable)
    if original_GetAreEnemies(player, self) then
        useSuccessTable.useSuccess = false
    end
end

// aliens never sprint. 
function Alien:GetIsSprinting()
    return false
end

function Skulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(Shotgun.kMapName)
    self:SetActiveWeapon(Shotgun.kMapName)
end

/*


// Borrowed from Xenoswarm, cause we're noobs.
local function addTechId(techIdName)
        
        // We have to reconstruct the kTechId enum to add values.
        local enumTable = {}
        for index, value in ipairs(kTechId) do
                table.insert(enumTable, value)
        end
        
        table.remove(enumTable, #enumTable)
        table.insert(enumTable, techIdName)
        table.insert(enumTable, 'Max')
        
        kTechId = enum(enumTable)
        kTechIdMax = kTechId.Max
        
end

addTechId("AlienShotgun")

kModdedTechData =
{
    { [kTechDataId] = kTechId.AlienShotgun,     [kTechDataMapName] = AlienShotgun.kMapName,        [kTechDataDamageType] = kParasiteDamageType,    [kTechDataDisplayName] = "PARASITE", [kTechDataTooltipInfo] = "PARASITE_TOOLTIP"},
}

//local overrideBuildTechData = BuildTechData
function BuildTechData()

    return kModdedTechData

    local defaultTechData = overrideBuildTechData()
    local moddedTechData = {}
    local usedTechIds = {}
    
    for i = 1, #kModdedTechData do
        local techEntry = kModdedTechData[i]
        table.insert(moddedTechData, techEntry)
        table.insert(usedTechIds, techEntry[kTechDataId])
    end
    
    for i = 1, #defaultTechData do
        local techEntry = defaultTechData[i]
        if not table.contains(usedTechIds, techEntry[kTechDataId]) then
            table.insert(moddedTechData, techEntry)
        end
    end
    
    return moddedTechData 

end
*/