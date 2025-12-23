# package topsystems.pos.core;

# Java import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.protocol import PosMessageKey

class Obtener_Msj_Existente:
    
    def __init__(self, context):
        self.context = context
    
    def getResponseToOriginalMessage(self, posMessage) :
        reversesKey = self.getReversesKey(posMessage)
        originalResponse = self.context.getMessageRegistry().getSavedResponse(reversesKey)
        if originalResponse != None :
            return PosMessage(originalResponse, self.context)
        else :
            return None
    
    def getResponseVOForOriginalMessage(self, posMessage):
        reversesKey = self.getReversesKey(posMessage)
        return self.context.getMessageRegistry().getSavedResponseVO(reversesKey)    
        
    
    def getReversesKey(self, posMessage):
        reversesKey = PosMessageKey()
        
        #reversesKey.addField(2, posMessage.getPAN())
        #Busco que el mensaje no haya Sido reversado de forma desordenada
        reversesKey.addField(0, "0430")
        reversesKey.addField(41, posMessage.getCardAcceptorTerminalIdentification())
        reversesKey.addField(37, posMessage.getRetrievalReferenceNumber())
        reversesKey.addField(12, posMessage.getLocalTransactionTime())
        reversesKey.addField(13, posMessage.getBodyElement(13))
        reversesKey.addField(3, posMessage.getProcessingCode())
        
        return reversesKey