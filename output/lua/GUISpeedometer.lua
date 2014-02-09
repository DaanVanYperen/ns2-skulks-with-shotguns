// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUISpeedometer.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Manages the marine buy/purchase menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Globals.lua")
Script.Load("lua/GUIDial.lua")

class 'GUISpeedometer' (GUIScript)

local kBallFillVisibleTimer = 5
local kBarMoveRate = 1.1

GUISpeedometer.kJetpackFuelTexture = "ui/marine_jetpackfuel.dds"

local kArmorCircleColor = Color(1, 121/255, 12/255, 1)

GUISpeedometer.kFont = "fonts/MicrogrammaDMedExt_medium.fnt"

GUISpeedometer.kBackgroundWidth = GUIScale(32)
GUISpeedometer.kBackgroundHeight = GUIScale(144)
GUISpeedometer.kBackgroundOffsetX = 6
GUISpeedometer.kBackgroundOffsetY = GUIScale(-240)

GUISpeedometer.kBarWidth = GUIScale(20)
GUISpeedometer.kBarHeight = GUIScale(123)

GUISpeedometer.kBgCoords = {0, 0, 32, 144}

GUISpeedometer.kBarCoords = {39, 10, 39 + 18, 10 + 123}

GUISpeedometer.kFuelBlueIntensity = .8

GUISpeedometer.kBackgroundColor = Color(0, 0, 0, 0.5)
GUISpeedometer.kFuelBarOpacity = 0.8

local kBackgroundNoiseTexture = "ui/alien_commander_bg_smoke.dds"

local kHealthTextureX1 = 0
local kHealthTextureY1 = 128
local kHealthTextureX2 = 128
local kHealthTextureY2 = 256
local kHealthBackgroundWidth = 160
local kHealthBackgroundHeight = 160
local kHealthBackgroundOffset = Vector(60, -50, 0)
local kHealthBackgroundTextureX1 = 0
local kHealthBackgroundTextureY1 = 0
local kHealthBackgroundTextureX2 = 128
local kHealthBackgroundTextureY2 = 128
local kTextureName = PrecacheAsset("ui/alien_hud_health.dds")

local kEnergyBackgroundWidth = 160
local kEnergyBackgroundHeight = 160
local kEnergyBackgroundOffset = Vector(-kEnergyBackgroundWidth*1.8 - 45, -50, 0)

function GUISpeedometer:Initialize()    

    self.speedPercentage = 0
    self.fadeValues = { }
    
    local healthBallSettings = { }
    healthBallSettings.BackgroundWidth = GUIScale(kHealthBackgroundWidth)
    healthBallSettings.BackgroundHeight = GUIScale(kHealthBackgroundHeight)
    healthBallSettings.BackgroundAnchorX = GUIItem.Right
    healthBallSettings.BackgroundAnchorY = GUIItem.Bottom
    healthBallSettings.BackgroundOffset = kEnergyBackgroundOffset * GUIScale(1)
    healthBallSettings.BackgroundTextureName = kTextureName
    healthBallSettings.BackgroundTextureX1 = kHealthBackgroundTextureX1
    healthBallSettings.BackgroundTextureY1 = kHealthBackgroundTextureY1
    healthBallSettings.BackgroundTextureX2 = kHealthBackgroundTextureX2
    healthBallSettings.BackgroundTextureY2 = kHealthBackgroundTextureY2
    healthBallSettings.ForegroundTextureName = kTextureName
    healthBallSettings.ForegroundTextureWidth = 128
    healthBallSettings.ForegroundTextureHeight = 128
    healthBallSettings.ForegroundTextureX1 = kHealthTextureX1
    healthBallSettings.ForegroundTextureY1 = kHealthTextureY1
    healthBallSettings.ForegroundTextureX2 = kHealthTextureX2
    healthBallSettings.ForegroundTextureY2 = kHealthTextureY2
    healthBallSettings.InheritParentAlpha = true
    self.speedBall = GUIDial()
    self.speedBall:Initialize(healthBallSettings)
    
    local healthBallBackground = self.speedBall:GetBackground()
    healthBallBackground:SetShader("shaders/GUISmokeHUD.surface_shader")
    healthBallBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
    healthBallBackground:SetFloatParameter("correctionX", 1)
    healthBallBackground:SetFloatParameter("correctionY", 1)
    healthBallBackground:SetLayer(kGUILayerPlayerHUDBackground)
    
    self.speedBall:GetLeftSide():SetColor(Color(230/255, 171/255, 46/255, 1))
    self.speedBall:GetRightSide():SetColor(Color(230/255, 171/255, 46/255, 1))

    self:Update(0)
    self.speedBall:SetIsVisible(true)
    self:ForceUnfade(self.speedBall:GetBackground())
end

function GUISpeedometer:UpdateSpeed( percentageGoal, deltaTime )
    PROFILE("GUIAlienHUD:UpdateHealthBall")
    
    Shared.Message( ToString(percentageGoal) .. " " .. ToString(self.speedPercentage))
    
    self.speedPercentage = Slerp(self.speedPercentage, percentageGoal, deltaTime * kBarMoveRate)
    self.speedBall:SetPercentage(self.speedPercentage)
    self.speedBall:Update(deltaTime)
    self:UpdateFading(self.speedBall:GetBackground(), self.speedPercentage, deltaTime)
end

function GUISpeedometer:ForceUnfade(unfadeItem)

    if self.fadeValues[unfadeItem] ~= nil then
    
        unfadeItem:SetColor(Color(1, 1, 1, 1))
        self.fadeValues[unfadeItem].fadeTime = kBallFillVisibleTimer
        self.fadeValues[unfadeItem].currentFadeAmount = 1
        
    end
    
end

function GUISpeedometer:UpdateFading(fadeItem, itemFillPercentage, deltaTime)

    if self.fadeValues[fadeItem] == nil then
    
        self.fadeValues[fadeItem] = { }
        self.fadeValues[fadeItem].lastFillPercentage = 0
        self.fadeValues[fadeItem].currentFadeAmount = 1
        self.fadeValues[fadeItem].fadeTime = 0
        
    end
    
    local lastFadePercentage = self.fadeValues[fadeItem].lastPercentage
    self.fadeValues[fadeItem].lastPercentage = itemFillPercentage
    
    if itemFillPercentage < 0.5 then
    
        // Check if we should start fading (itemFillPercentage just hit 100%).
        if lastFadePercentage ~= nil and lastFadePercentage >= 5 then
            self:ForceUnfade(fadeItem)
        end       
        
    else
    
        fadeItem:SetIsVisible(true)
        fadeItem:SetColor(Color(1, 1, 1, 1))
        
    end

end


function GUISpeedometer:Update(deltaTime)
    local player = Client.GetLocalPlayer()

    local velocity = player:GetVelocity()
    local speed = velocity:GetLengthXZ() - 7
    local bonusSpeedFraction = speed / 6


    if speed > 0 then
        self:UpdateSpeed(bonusSpeedFraction,deltaTime)    
    else 
        self:UpdateSpeed(0,deltaTime)    
    end
end


function GUISpeedometer:Uninitialize()
    if self.speedBall then   
        self.speedBall:Uninitialize()
        self.speedBall = nil
    end
end