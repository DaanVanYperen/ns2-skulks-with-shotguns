// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/GUIAuraDisplay.lua
//
// Shows how many shells, spurs, veils you have
//
// Created by Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Shared.PrecacheSurfaceShader("shaders/GUIAura.surface_shader")

class 'GUIAuraDisplay' (GUIScript)

local kIconSize = Vector(80, 80, 0)
local kHeartOffset = Vector(0, 0.5, 0)
local kTexture = "ui/Gorge.dds"

local kBlueColor = ColorIntToColor(kMarineTeamColor)
local kBlueHighlightColor = Color(0.30, 0.69, 1, 1)
local kRedColor = kRedColor--ColorIntToColor(kAlienTeamColor)
local kRedHighlightColor = Color(1, 0.79, 0.23, 1)


local function CreateAuaIcon(self)

    local icon = GetGUIManager():CreateGraphicItem()
    icon:SetTexture(kTexture)
    icon:SetShader("shaders/GUIAura.surface_shader")
    icon:SetBlendTechnique(GUIItem.Add)
    self.background:AddChild(icon)
    
    return icon

end

function GUIAuraDisplay:Initialize()

    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetColor(Color(0,0,0,0))
    
    self.icons = {}

end

function GUIAuraDisplay:Uninitialize()
    
    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end
    
    self.icons = nil
    
end

function GUIAuraDisplay:Update(deltaTime)

    local players = {}
    
    local player = Client.GetLocalPlayer()
    if player then
    
        local viewDirection = player:GetViewCoords().zAxis
        local eyePos = player:GetEyePos()
        
        for _, enemyPlayer in ientitylist(Shared.GetEntitiesWithClassname("Flag")) do
        
              // looking in the right direction but obscured?
              if viewDirection:DotProduct(GetNormalizedVector(enemyPlayer:GetOrigin() - eyePos)) > 0 and
                 not GetCanSeeEntity(player, enemyPlayer) then
                   table.insert(players, enemyPlayer)    
              end
                
        end
    
    end
    
    local numPlayers = #players
    local numIcons = #self.icons
    
    if numPlayers > numIcons then
    
        for i = 1, numPlayers - numIcons do
            
            local icon = CreateAuaIcon(self)
            table.insert(self.icons, icon)
            
        end
    
    elseif numIcons > numPlayers then
    
        for i = 1, numIcons - numPlayers do
            
            GUI.DestroyItem(self.icons[#self.icons])
            self.icons[#self.icons] = nil
            
        end
    
    end
    
    local eyePos = player:GetEyePos()
    
    for i = 1, numPlayers do
    
        local enemy = players[i]
        local icon = self.icons[i]
        
        local color = kBlueColor
        if (enemy:GetTeamNumber() == kVanillaTeamIndex) then
            color = kRedColor
        end
            
        local yellTime = enemy:GetLastTimeYelled()
        if (enemy:GetTeamNumber() ~= player:GetTeamNumber()) or (yellTime == 0) then
            -- Can always see the enemy team gorge, or a gorge that is out of danger.
            icon:SetIsVisible(true)
            color.a = 1
        else
            local secondsSinceYell = Shared.GetTime() - yellTime
            --  Only see your abducted gorge when it yells.
            icon:SetIsVisible(secondsSinceYell < 2)
            if icon:GetIsVisible() then
                color.a = Clamp(2-secondsSinceYell,0,1)
            end
        end
       
        local offset = kHeartOffset
        
        local worldPos = enemy:GetOrigin() + offset
        local screenPos = Client.WorldToScreen(worldPos)
        
        // hide when too close.
        if ( (worldPos - eyePos):GetLength() < 2 ) then
            icon:SetIsVisible(false)
        end
        
        local distanceFraction = (1 - Clamp((worldPos - eyePos):GetLength() / 30, 0, 0.75)) * 1.5

        local size = Vector(kIconSize.x, kIconSize.y, 0) * distanceFraction
        icon:SetPosition(screenPos - size * 0.5)
        icon:SetSize(size)  
        icon:SetColor(color)
    
    end

end