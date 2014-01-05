// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Hive.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/DetectableMixin.lua")

Script.Load("lua/CommandStructure.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/IdleMixin.lua")

kHiveInfestationRadius = 6

class 'Hive' (CommandStructure)

local networkVars =
{
    extendAmount = "float (0 to 1 by 0.01)",
    bioMassLevel = "integer (0 to 6)"
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

kResearchToHiveType =
{
    [kTechId.UpgradeToCragHive] = kTechId.CragHive,
    [kTechId.UpgradeToShadeHive] = kTechId.ShadeHive,
    [kTechId.UpgradeToShiftHive] = kTechId.ShiftHive,
}

Hive.kMapName = "hive"

Shared.PrecacheSurfaceShader("cinematics/vfx_materials/hive_frag.surface_shader")

Hive.kModelName = PrecacheAsset("models/alien/harvester/harvester.model")
local kAnimationGraph = PrecacheAsset("models/alien/harvester/harvester.animation_graph")

Hive.kWoundSound = PrecacheAsset("sound/NS2.fev/alien/structures/hive_wound")
// Play special sound for players on team to make it sound more dramatic or horrible
Hive.kWoundAlienSound = PrecacheAsset("sound/NS2.fev/alien/structures/hive_wound_alien")

Hive.kIdleMistEffect = PrecacheAsset("cinematics/alien/hive/idle_mist.cinematic")
Hive.kL2IdleMistEffect = PrecacheAsset("cinematics/alien/hive/idle_mist_lev2.cinematic")
Hive.kL3IdleMistEffect = PrecacheAsset("cinematics/alien/hive/idle_mist_lev3.cinematic")
Hive.kGlowEffect = PrecacheAsset("cinematics/alien/hive/glow.cinematic")
Hive.kSpecksEffect = PrecacheAsset("cinematics/alien/hive/specks.cinematic")

Hive.kCompleteSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/hive_complete")
Hive.kUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/hive_under_attack")
Hive.kDyingSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/hive_dying")

Hive.kHealRadius = 2     // From NS1
Hive.kHealthPercentage = .04
Hive.kHealthUpdateTime = 1

if Server then
    Script.Load("lua/Hive_Server.lua")
elseif Client then
    Script.Load("lua/Hive_Client.lua")
end

function Hive:OnCreate()

    CommandStructure.OnCreate(self)
    
    InitMixin(self, CloakableMixin)
    
    InitMixin(self, FireMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, MaturityMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, BiomassMixin)
    
    self.extendAmount = 0
    
    if Server then
    
        self.biomassResearchFraction = 0
    
        self.cystChildren = { }
        
        self.lastImpulseFireTime = Shared.GetTime()
        
        self.timeOfLastEgg = Shared.GetTime()
        
        // when constructed first level is added automatically
        self.bioMassLevel = 0
        
        self:UpdateIncludeRelevancyMask()
        
    end
    
end

function Hive:OnInitialized()

    InitMixin(self, InfestationMixin)
    
    CommandStructure.OnInitialized(self)

    // Pre-compute list of egg spawn points.
    if Server then
        
        self:SetModel(Hive.kModelName, kAnimationGraph)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        
    elseif Client then
    
        // Create glowy "plankton" swimming around hive, along with mist and glow
        local coords = self:GetCoords()
        self:AttachEffect(Hive.kSpecksEffect, coords)
        //self:AttachEffect(Hive.kGlowEffect, coords, Cinematic.Repeat_Loop)
        
        // For mist creation
        self:SetUpdates(true)
        
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self.glowIntensity = ConditionalValue(self:GetIsBuilt(), 1, 0)
        
    end
    
    InitMixin(self, IdleMixin)
    
//    self:SetInfestationFullyGrown()    
end

local kHelpArrowsCinematicName = PrecacheAsset("cinematics/alien/commander_arrow.cinematic")
PrecacheAsset("models/misc/commander_arrow_aliens.model")

if Client then

    function Hive:GetHelpArrowsCinematicName()
        return kHelpArrowsCinematicName
    end
    
end

function Hive:SetIncludeRelevancyMask(includeMask)

    includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)    
    CommandStructure.SetIncludeRelevancyMask(self, includeMask)    

end

function Hive:GetCanBeUsed(player, useSuccessTable)

    useSuccessTable.useSuccess = false
    
end

function Hive:GetMaturityRate()
    return kHiveMaturationTime
end

function Hive:GetMatureMaxHealth()
    return kMatureHiveHealth
end 

function Hive:GetMatureMaxArmor()
    return kMatureHiveArmor
end

function Hive:GetInfestationMaxRadius()
    return kHiveInfestationRadius
end

function Hive:GetMatureMaxEnergy()
    return kMatureHiveMaxEnergy
end

function Hive:OnCollision(entity)

    // We may hook this up later.
    /*if entity:isa("Player") and GetEnemyTeamNumber(self:GetTeamNumber()) == entity:GetTeamNumber() then    
        self.lastTimeEnemyTouchedHive = Shared.GetTime()
    end*/
    
end

function GetIsHiveTypeResearch(techId)
    return techId == kTechId.UpgradeToCragHive or techId == kTechId.UpgradeToShadeHive or techId == kTechId.UpgradeToShiftHive
end

function GetHiveTypeResearchAllowed(self, techId)
    
    local hiveTypeTechId = kResearchToHiveType[techId]
    return not GetHasTech(self, hiveTypeTechId) and not GetIsTechResearching(self, techId)

end

function Hive:GetInfestationRadius()
    return kHiveInfestationRadius
end

function Hive:GetCanTakeDamageOverride()
    return false
end

function Hive:GetCystParentRange()
    return kHiveCystParentRange
end

function Hive:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player)

    if techId == kTechId.ResearchBioMassTwo then
        allowed = allowed and self.bioMassLevel == 2
    end
    
    return allowed, canAfford
    
end

function Hive:GetBioMassLevel()
    return self.bioMassLevel * kHiveBiomass
end

function Hive:GetCanResearchOverride(techId)

    local allowed = true

    if GetIsHiveTypeResearch(techId) then
        allowed = GetHiveTypeResearchAllowed(self, techId)
    end
    
    return allowed and GetIsUnitActive(self)

end

function Hive:GetTechButtons(techId)

    local techButtons = { kTechId.ShiftHatch, kTechId.None, kTechId.UpgradeGorge, kTechId.None,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.None }

    if self:GetTechId() == kTechId.Hive then
    
        techButtons[5] = ConditionalValue(GetHiveTypeResearchAllowed(self, kTechId.UpgradeToCragHive), kTechId.UpgradeToCragHive, kTechId.None)
        techButtons[6] = ConditionalValue(GetHiveTypeResearchAllowed(self, kTechId.UpgradeToShadeHive), kTechId.UpgradeToShadeHive, kTechId.None)
        techButtons[7] = ConditionalValue(GetHiveTypeResearchAllowed(self, kTechId.UpgradeToShiftHive), kTechId.UpgradeToShiftHive, kTechId.None)
    
    end
    
    if self.bioMassLevel <= 1 then
        techButtons[2] = kTechId.ResearchBioMassOne
    elseif self.bioMassLevel <= 2 then
        techButtons[2] = kTechId.ResearchBioMassTwo 
    end
    
    return techButtons
    
end

function Hive:GetIsOccupied()
    return true
end


function Hive:OnSighted(sighted)
    CommandStructure.OnSighted(self, sighted)
end

function Hive:GetHealthbarOffset()
    return 0.8
end 

// Don't show objective after we become cloaked
function Hive:OnCloak()

    local attached = self:GetAttached()
    if attached then
        attached.showObjective = false
    end
    
end

function Hive:OverrideVisionRadius()
    return 20
end

function Hive:OnUpdatePoseParameters()
    self:SetPoseParam("extend", self.extendAmount)
end

/**
 * Return true if a connected cyst parent is availble at the given origin normal. 
 */
function GetTechPointInfested(techId, origin, normal, commander)

    local attachClass = LookupTechData(techId, kStructureAttachClass)  
    local attachEntity = GetNearestFreeAttachEntity(techId, origin, kStructureSnapRadius)
    
    return attachEntity and attachEntity:GetGameEffectMask(kGameEffect.OnInfestation)
    
end

// return a good spot from which a player could have entered the hive
// used for initial entry point for the commander
function Hive:GetDefaultEntryOrigin()
    return self:GetOrigin() + Vector(2,0,2)
end

function Hive:GetInfestationBlobMultiplier()
    return 5
end

Shared.LinkClassToMap("Hive", Hive.kMapName, networkVars)

class 'CragHive' (Hive)
CragHive.kMapName = "crag_hive"
Shared.LinkClassToMap("CragHive", CragHive.kMapName, { })

class 'ShadeHive' (Hive)
ShadeHive.kMapName = "shade_hive"
Shared.LinkClassToMap("ShadeHive", ShadeHive.kMapName, { })

class 'ShiftHive' (Hive)
ShiftHive.kMapName = "shift_hive"
Shared.LinkClassToMap("ShiftHive", ShiftHive.kMapName, { })