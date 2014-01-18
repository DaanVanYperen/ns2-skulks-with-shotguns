
EventMessageMixin = CreateMixin( EventMessageMixin )
EventMessageMixin.type = "EventMessage"

EventMessageMixin.expectedConstants =
{
    kGUIScriptName = "The name of the GUI script to use when displaying event messages."
}

function EventMessageMixin:__initmixin()

    // Only for use on the Client.
    assert(Client)
    
    self.eventMessageGUI = GetGUIManager():CreateGUIScript(self:GetMixinConstants().kGUIScriptName)
    
end

function EventMessageMixin:OnDestroy()

    if self.eventMessageGUI then
    
        GetGUIManager():DestroyGUIScript(self.eventMessageGUI)
        self.eventMessageGUI = nil
        
    end
    
end

function EventMessageMixin:SetEventMessage(message)

    if self.eventMessageGUI then
        self.eventMessageGUI:SetEventMessage(message)
    end
    
end