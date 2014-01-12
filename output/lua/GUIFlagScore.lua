
class 'GUIFlagScore' (GUIScript)

local kFontScale = GUIScale(Vector(1, 1, 0))
local kTextFontName = "fonts/AgencyFB_large.fnt"
local kFontColor = Color(1, 1, 1, 1)

local kEggSize = GUIScale( Vector(64, 64, 0) )

local kPadding = GUIScale(32)
local kEggTopOffset = GUIScale(8)
local kEggSideOffset = GUIScale(8)

local kNoEggsColor = Color(1, 0, 0, 1)
local kWhite = Color(1, 1, 1, 1)
local kBlueColor = ColorIntToColor(kMarineTeamColor)
local kBlueHighlightColor = Color(0.30, 0.69, 1, 1)
local kRedColor = kRedColor--ColorIntToColor(kAlienTeamColor)
local kRedHighlightColor = Color(1, 0.79, 0.23, 1)

local kEggTexture = "ui/Gorge.dds"

local kSpawnInOffset = GUIScale(Vector(0, -125, 0))

function AlienUI_GetPoints( teamNumber )

    local points = 0

        local teamInfo = GetTeamInfoEntity(teamNumber)
        if teamInfo then
            points = teamInfo:GetPoints()
        end
    
    return points
    
end

function AlienUI_GetEnemyPoints( teamNumber )

    local enemyPoints = 0

        local teamInfo = GetTeamInfoEntity(teamNumber)
        if teamInfo then
            enemyPoints = teamInfo:GetEnemyPoints()
        end
    
    return enemyPoints
    
end


function AlienUI_GetTeamMode( teamNumber )

    local teamMode = false

        local teamInfo = GetTeamInfoEntity(teamNumber)
        if teamInfo then
            teamMode = teamInfo:GetTeamMode()
        end
    
    return teamMode
    
end


function GUIFlagScore:Initialize()
/*
    self.spawnText = GUIManager:CreateTextItem()
    self.spawnText:SetFontName(kTextFontName)
    self.spawnText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.spawnText:SetTextAlignmentX(GUIItem.Align_Center)
    self.spawnText:SetTextAlignmentY(GUIItem.Align_Center)
    self.spawnText:SetColor(kFontColor)
    self.spawnText:SetPosition(kSpawnInOffset) */
    
    self.teamIcon = GUIManager:CreateGraphicItem()
    self.teamIcon:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.teamIcon:SetPosition(Vector(kEggSideOffset, kEggTopOffset, 0))
    self.teamIcon:SetTexture(kEggTexture)
    self.teamIcon:SetSize(kEggSize)
    
    self.teamPoints = GUIManager:CreateTextItem()
    self.teamPoints:SetFontName(kTextFontName)
    self.teamPoints:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.teamPoints:SetPosition(Vector(kPadding * 0.5, 0, 0))
    self.teamPoints:SetTextAlignmentX(GUIItem.Align_Min)
    self.teamPoints:SetTextAlignmentY(GUIItem.Align_Center)
    self.teamPoints:SetColor(kFontColor)
    self.teamPoints:SetScale(kFontScale)
    self.teamPoints:SetFontName(kTextFontName)
    
    self.teamIcon:AddChild(self.teamPoints)
    
    // ENEMY
    
    self.enemyTeamIcon = GUIManager:CreateGraphicItem()
    self.enemyTeamIcon:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.enemyTeamIcon:SetPosition(Vector(-kEggSideOffset - kEggSize.x, kEggTopOffset, 0))
    self.enemyTeamIcon:SetTexture(kEggTexture)
    self.enemyTeamIcon:SetSize(kEggSize)
    
    self.enemyTeamPoints = GUIManager:CreateTextItem()
    self.enemyTeamPoints:SetFontName(kTextFontName)
    self.enemyTeamPoints:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.enemyTeamPoints:SetPosition(Vector(-kPadding * 0.5, 0, 0))
    self.enemyTeamPoints:SetTextAlignmentX(GUIItem.Align_Max)
    self.enemyTeamPoints:SetTextAlignmentY(GUIItem.Align_Center)
    self.enemyTeamPoints:SetColor(kFontColor)
    self.enemyTeamPoints:SetScale(kFontScale)
    self.enemyTeamPoints:SetFontName(kTextFontName)
    
    self.enemyTeamIcon:AddChild(self.enemyTeamPoints)
end

function GUIFlagScore:Uninitialize()

    GUI.DestroyItem(self.teamIcon)
    self.teamIcon = nil
    
    GUI.DestroyItem(self.teamPoints)
    self.teamPoints = nil
    
    GUI.DestroyItem(self.enemyTeamIcon)
    self.enemyTeamIcon = nil
    
    GUI.DestroyItem(self.enemyTeamPoints)
    self.enemyTeamPoints = nil

    eggCount = nil
    
end

function GUIFlagScore:Update(deltaTime)

    local player = Client.GetLocalPlayer()
    isVisible = (player ~= nil) and AlienUI_GetTeamMode(player:GetTeamNumber())

    self.enemyTeamPoints:SetIsVisible(isVisible)
    self.enemyTeamIcon:SetIsVisible(isVisible)
    self.teamPoints:SetIsVisible(isVisible)
    self.teamIcon:SetIsVisible(isVisible)
        
    if player then
    
        local teamNumber = player:GetTeamNumber()
        
        local myTeamColor = kBlueColor 
        local enemyTeamColor = kRedColor 
        
        if (teamNumber == kVanillaTeamIndex) then
            myTeamColor = kRedColor
            enemyTeamColor = kBlueColor
        end
        
        local points = AlienUI_GetPoints( teamNumber )

        self.teamPoints:SetText(string.format("x %s", ToString(points))) 
        self.teamPoints:SetColor(myTeamColor)
        self.teamIcon:SetColor(myTeamColor)
        
        local enemyPoints = AlienUI_GetEnemyPoints( teamNumber )

        self.enemyTeamPoints:SetText(string.format("x %s", ToString(enemyPoints)))           
        self.enemyTeamPoints:SetColor(enemyTeamColor)
        self.enemyTeamIcon:SetColor(enemyTeamColor)
    end
    
end