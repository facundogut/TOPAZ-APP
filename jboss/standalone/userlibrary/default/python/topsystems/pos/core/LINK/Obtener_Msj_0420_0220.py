# package topsystems.pos.core;

# Java import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.protocol import PosMessageKey

class Obtener_Msj_0420_0220:
    
    def __init__(self, context):
        self.context = context
    
    def getResponseToOriginalMessage(self, posMessage) :
        reversesKey = self.getReversesKey(posMessage)
        originalResponse = self.context.getMessageRegistry().getSavedResponse(reversesKey)
        if originalResponse != None :
            return PosMessage(originalResponse, self.context)
            
        elif (originalResponse == None and (posMessage.getMessageType() == "0221" or posMessage.getMessageType() == "0220")):
            reversesKey1 = self.getReversesKey1(posMessage)
            originalResponse1 = self.context.getMessageRegistry().getSavedResponse(reversesKey1)
            if originalResponse1 != None :
                return PosMessage(originalResponse1, self.context)
            else :
                return None
        else :
            return None
    
    def getResponseVOForOriginalMessage(self, posMessage):
        reversesKey = self.getReversesKey(posMessage)
        return self.context.getMessageRegistry().getSavedResponseVO(reversesKey)
        
    
    def getReversesKey(self, posMessage):
        reversesKey = PosMessageKey()
        
        #reversesKey.addField(2, posMessage.getPAN())
        #Se agrega el campo 0 para validar que el mensaje no se una restransmición, y en caso que sea no retornar error
        if posMessage.getMessageType() == "0421" or posMessage.getMessageType() == "0420":
            reversesKey.addField(0, "0430")
        elif posMessage.getMessageType() == "0221" or posMessage.getMessageType() == "0220":
            reversesKey.addField(0, "0230")
        else:
            reversesKey.addField(0, "0210")
        reversesKey.addField(41, posMessage.getCardAcceptorTerminalIdentification())
        reversesKey.addField(37, posMessage.getRetrievalReferenceNumber())
        reversesKey.addField(12, posMessage.getLocalTransactionTime())
        reversesKey.addField(13, posMessage.getBodyElement(13))
        reversesKey.addField(3, posMessage.getProcessingCode())
        #Se setea cuenta para realizar busqueda por vacio/espacio y no por 0
        fromAccount = posMessage.getFromAccount()
        if fromAccount == 0 :
            fromAccount = ""
        else :           
            fromAccount = fromAccount 
        toAccount = posMessage.getToAccount()
        if toAccount == 0:
            toAccount = ""
        else :            
            toAccount = toAccount
        reversesKey.addField(102, fromAccount)
        reversesKey.addField(103, toAccount)
        return reversesKey

    def getReversesKey1(self, posMessage):
        reversesKey = PosMessageKey()
        
        reversesKey.addField(0, "0210")
        reversesKey.addField(41, posMessage.getCardAcceptorTerminalIdentification())
        reversesKey.addField(37, posMessage.getRetrievalReferenceNumber())
        reversesKey.addField(12, posMessage.getLocalTransactionTime())
        reversesKey.addField(13, posMessage.getBodyElement(13))
        reversesKey.addField(3, posMessage.getProcessingCode())
        #Se setea cuenta para realizar busqueda por vacio/espacio y no por 0
        fromAccount = posMessage.getFromAccount()
        if fromAccount == 0 :
            fromAccount = ""
        else :           
            fromAccount = fromAccount 
        toAccount = posMessage.getToAccount()
        if toAccount == 0:
            toAccount = ""
        else :            
            toAccount = toAccount
        reversesKey.addField(102, fromAccount)
        reversesKey.addField(103, toAccount)
        return reversesKey