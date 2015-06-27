
class 'GUIFlagScore' (GUIScript)

local kFontScale = GUIScale(Vector(1, 1, 0))
local kTextFontName = "fonts/AgencyFB_large.fnt"
local kFontColor = Color(1, 1, 1, 1)

local kEggSize = GUIScale( Vector(64, 64, 0) )
local kCarrySize = GUIScale( Vector(200, 200, 0) )

local kPadding = GUIScale(32)
local kEggTopOffset = GUIScale(8)
local kBarTopOffset = GUIScale(7)
local kEggSideOffset = GUIScale(72)
local kNameOffset = GUIScale(32)

local kNoEggsColor = Color(1, 0, 0, 1)
local kWhite = Color(1, 1, 1, 1)
local kBlueColor = ColorIntToColor(kMarineTeamColor)
local kBlueHighlightColor = Color(0.30, 0.69, 1, 1)
local kRedColor = kRedColor--ColorIntToColor(kAlienTeamColor)
local kRedHighlightColor = Color(1, 0.79, 0.23, 1)

local kEggTexture = "ui/Gorge.dds"

local kSpawnInOffset = GUIScale(Vector(0, -125, 0))

function AlienUI_GetSecondsRemaining( teamNumber )

    local points = 0

        local teamInfo = GetTeamInfoEntity(teamNumber)
        if teamInfo then
            points = teamInfo:GetSecondsRemaining()
        end
    
    return points
        
end

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


function AlienUI_GetCarrierName( teamNumber )

    local teamInfo = GetTeamInfoEntity(teamNumber)
    if teamInfo then
        local clientIndex = teamInfo:GetCarrierId()
        if clientIndex ~= nil then
            return Scoreboard_GetPlayerName(clientIndex)
        end
    end
    
    return nil
end

function AlienUI_GetIsCarrier( teamNumber )

    local teamInfo = GetTeamInfoEntity(teamNumber)
    if teamInfo then
        local clientIndex = teamInfo:GetCarrierId()
        if clientIndex ~= nil then
            return clientIndex == Client.GetLocalPlayer():GetClientIndex()
        end
    end
    
    return false
end

function AlienUI_GetEnemyCarrierName( teamNumber )

    local teamInfo = GetTeamInfoEntity(teamNumber)
    if teamInfo then
        local clientIndex = teamInfo:GetEnemyCarrierId()
        if clientIndex ~= nil then
            return Scoreboard_GetPlayerName(clientIndex)
        end
    end
    
    return nil
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
    
    self.carryGorgeIcon = GUIManager:CreateGraphicItem()
    self.carryGorgeIcon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.carryGorgeIcon:SetPosition(Vector(-kCarrySize.x/2,-kCarrySize.y*2, 0))
    self.carryGorgeIcon:SetTexture(kEggTexture)
    self.carryGorgeIcon:SetSize(kCarrySize)

    self.pointsDash = GUIManager:CreateTextItem()
    self.pointsDash:SetFontName(kTextFontName)
    self.pointsDash:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.pointsDash:SetPosition(Vector(0, kBarTopOffset + kEggSize.y / 2, 0))
    self.pointsDash:SetTextAlignmentX(GUIItem.Align_Center)
    self.pointsDash:SetTextAlignmentY(GUIItem.Align_Center)
    self.pointsDash:SetColor(kFontColor)
    self.pointsDash:SetScale(kFontScale)
    self.pointsDash:SetFontName(kTextFontName)        
    
    self.timeRemaining = GUIManager:CreateTextItem()
    self.timeRemaining:SetFontName(kTextFontName)
    self.timeRemaining:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.timeRemaining:SetPosition(Vector(0, kBarTopOffset + kEggSize.y, 0))
    self.timeRemaining:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemaining:SetTextAlignmentY(GUIItem.Align_Center)
    self.timeRemaining:SetColor(kFontColor)
    self.timeRemaining:SetScale(kFontScale)
    self.timeRemaining:SetFontName(kTextFontName)        
    
    ///////////////////
        
    self.teamIcon = GUIManager:CreateGraphicItem()
    self.teamIcon:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.teamIcon:SetPosition(Vector(-kEggSideOffset-kEggSize.x, kEggTopOffset, 0))
    self.teamIcon:SetTexture(kEggTexture)
    self.teamIcon:SetSize(kEggSize)
    
    // Points
    
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
    
    // Carrier 
    
    self.teamCarrier = GUIManager:CreateTextItem()
    self.teamCarrier:SetFontName(kTextFontName)
    self.teamCarrier:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.teamCarrier:SetPosition(Vector(-kPadding * 0.5 - kEggSize.x, 0, 0))
    self.teamCarrier:SetTextAlignmentX(GUIItem.Align_Max)
    self.teamCarrier:SetTextAlignmentY(GUIItem.Align_Center)
    self.teamCarrier:SetColor(kFontColor)
    self.teamCarrier:SetScale(kFontScale)
    self.teamCarrier:SetFontName(kTextFontName)
    
    self.teamIcon:AddChild(self.teamCarrier)
    
    // ENEMY
    
    self.enemyTeamIcon = GUIManager:CreateGraphicItem()
    self.enemyTeamIcon:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.enemyTeamIcon:SetPosition(Vector(kEggSideOffset, kEggTopOffset, 0))
    self.enemyTeamIcon:SetTexture(kEggTexture)
    self.enemyTeamIcon:SetSize(kEggSize)
    
    // Points
    
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
    
    // Carrier

    self.enemyTeamCarrier = GUIManager:CreateTextItem()
    self.enemyTeamCarrier:SetFontName(kTextFontName)
    self.enemyTeamCarrier:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.enemyTeamCarrier:SetPosition(Vector(kPadding * 0.5 + kEggSize.x, 0, 0))
    self.enemyTeamCarrier:SetTextAlignmentX(GUIItem.Align_Min)
    self.enemyTeamCarrier:SetTextAlignmentY(GUIItem.Align_Center)
    self.enemyTeamCarrier:SetColor(kFontColor)
    self.enemyTeamCarrier:SetScale(kFontScale)
    self.enemyTeamCarrier:SetFontName(kTextFontName)
    
    self.enemyTeamIcon:AddChild(self.enemyTeamCarrier)
end

function GUIFlagScore:Uninitialize()

    GUI.DestroyItem(self.teamIcon)
    self.teamIcon = nil
    
    GUI.DestroyItem(self.carryGorgeIcon)
    self.carryGorgeIcon = nil
    
    GUI.DestroyItem(self.teamPoints)
    self.teamPoints = nil
    
    GUI.DestroyItem(self.teamCarrier)
    self.teamCarrier = nil
    
    GUI.DestroyItem(self.enemyTeamIcon)
    self.enemyTeamIcon = nil
    
    GUI.DestroyItem(self.enemyTeamPoints)
    self.enemyTeamPoints = nil

    GUI.DestroyItem(self.enemyTeamCarrier)
    self.enemyTeamCarrier = nil

    GUI.DestroyItem(self.pointsDash)
    self.pointsDash = nil
    
    GUI.DestroyItem(self.timeRemaining)
    self.timeRemaining = nil
    
    eggCount = nil
    
end

function GUIFlagScore:Update(deltaTime)

    local player = Client.GetLocalPlayer()
    isVisible = (player ~= nil) and AlienUI_GetTeamMode(player:GetTeamNumber())

    self.carryGorgeIcon:SetIsVisible(isVisible)
    self.enemyTeamPoints:SetIsVisible(isVisible)
    self.enemyTeamCarrier:SetIsVisible(isVisible)
    self.enemyTeamIcon:SetIsVisible(isVisible)
    self.teamPoints:SetIsVisible(isVisible)
    self.teamCarrier:SetIsVisible(isVisible)
    self.teamIcon:SetIsVisible(isVisible)
    self.pointsDash:SetIsVisible(isVisible)
    self.timeRemaining:SetIsVisible(isVisible)
        
    if player then
    
        local teamNumber = player:GetTeamNumber()
        
        local myTeamColor = kBlueColor 
        local enemyTeamColor = kRedColor 

        if (teamNumber == kVanillaTeamIndex) then
            myTeamColor = kRedColor
            enemyTeamColor = kBlueColor
        end
        
        self.carryGorgeIcon:SetIsVisible(AlienUI_GetIsCarrier(teamNumber))
        self.carryGorgeIcon:SetColor(enemyTeamColor)    
        
        local points = AlienUI_GetPoints( teamNumber )

        self.teamPoints:SetText(ToString(points)) 
        self.teamPoints:SetColor(myTeamColor)
        self.teamIcon:SetColor(myTeamColor)

        local carrier = AlienUI_GetCarrierName( teamNumber )
        self.teamCarrier:SetIsVisible(carrier ~= nil)
        if carrier ~= nil then
            self.teamCarrier:SetText(carrier) 
            self.teamCarrier:SetColor(myTeamColor)
        end
        
        local enemyPoints = AlienUI_GetEnemyPoints( teamNumber )

        self.enemyTeamPoints:SetText(ToString(enemyPoints))           
        self.enemyTeamPoints:SetColor(enemyTeamColor)
        self.enemyTeamIcon:SetColor(enemyTeamColor)
        
        self.pointsDash:SetText("-")
        self.pointsDash:SetColor(kWhite)

        local seconds = math.round(AlienUI_GetSecondsRemaining( teamNumber ))
        local minutes = math.floor(seconds / 60)
        local hours = math.floor(minutes / 60)
        minutes = minutes - hours * 60
        seconds = seconds - minutes * 60 - hours * 3600
    
        local gameTimeText = string.format("%d:%02d", minutes, seconds)

        self.timeRemaining:SetText(gameTimeText)
        
        self.timeRemaining:SetColor(kWhite)
        
        if hours == 0 and minutes == 0 then         

            // blinking!
            if seconds % 2 == 1  then
                self.timeRemaining:SetColor(kRedColor)
            end

            // hide if no timer active (or ran out).
            if seconds == 0 then 
                self.timeRemaining:SetIsVisible(false)
            end     
        end
    
        local enemyCarrier = AlienUI_GetEnemyCarrierName( teamNumber )
        self.enemyTeamCarrier:SetIsVisible(enemyCarrier ~= nil)
        if enemyCarrier ~= nil then
            self.enemyTeamCarrier:SetText(enemyCarrier) 
            self.enemyTeamCarrier:SetColor(enemyTeamColor)
        end
    end
    
end