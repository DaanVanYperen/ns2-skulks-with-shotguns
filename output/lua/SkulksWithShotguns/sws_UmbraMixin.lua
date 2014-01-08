function UmbraMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    // make umbra much more effective.
    if self:GetHasUmbra() then
        damageTable.damage = damageTable.damage * 0.1
    end

end