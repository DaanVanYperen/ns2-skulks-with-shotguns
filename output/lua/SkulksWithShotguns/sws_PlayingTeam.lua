if Server then 
    
    function PlayingTeam:ResetTeam()
        self.conceded = false
        return nil
    end
    
    // stop anything from spawning initially.
    function PlayingTeam:SpawnInitialStructures(techPoint)
        return nil,nil
    end 
    
end