local kAlienBuyMenuSounds = { Open = "sound/NS2.fev/alien/common/alien_menu/open_menu",
                              Close = "sound/NS2.fev/alien/common/alien_menu/close_menu",
                              Evolve = "sound/NS2.fev/alien/common/alien_menu/evolve",
                              BuyUpgrade = "sound/NS2.fev/alien/common/alien_menu/buy_upgrade",
                              SellUpgrade = "sound/NS2.fev/alien/common/alien_menu/sell_upgrade",
                              Hover = "sound/NS2.fev/alien/common/alien_menu/hover",
                              SelectSkulk = "sound/NS2.fev/alien/common/alien_menu/skulk_select",
                              SelectFade = "sound/NS2.fev/alien/common/alien_menu/fade_select",
                              SelectGorge = "sound/NS2.fev/alien/common/alien_menu/gorge_select",
                              SelectOnos = "sound/NS2.fev/alien/common/alien_menu/onos_select",
                              SelectLerk = "sound/NS2.fev/alien/common/alien_menu/lerk_select" }

function ScoringMixin:AddKill()

    if not self.kills then
        self.kills = 0
    end    

    self.kills = Clamp(self.kills + 1, 0, kMaxKills)
    self:SetScoreboardChanged(true)

    if self.kills == 2 then
         StartSoundEffect(kAlienBuyMenuSounds.Evolve)
         ShotgunMessage(self:GetName() .. " is on fire!")
        if HasMixin(self, "Fire") then
            hitEnt:SetOnFire(nil, nil)
        end
    end
end