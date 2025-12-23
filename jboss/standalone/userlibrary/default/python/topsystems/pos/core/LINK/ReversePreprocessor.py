# package topsystems.pos.core;

# Java import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.protocol import PosMessageKey

class ReversePreprocessor:
    
    def __init__(self, context):
        self.context = context
    
    def getResponseToOriginalMessage(self, posMessage) :
        reversesKey = self.getReversesKey(posMessage)
        reversesKey_1 = self.getReversesKey_1(posMessage)
        originalResponse = self.context.getMessageRegistry().getSavedResponse(reversesKey)
        if originalResponse == None :
            originalResponse = self.context.getMessageRegistry().getSavedResponse(reversesKey_1)

        if originalResponse != None :
            return PosMessage(originalResponse, self.context)
        else :
            return None
    
    def getResponseVOForOriginalMessage(self, posMessage):

        reversesKey = self.getReversesKey(posMessage)
        reversesKey_1 = self.getReversesKey_1(posMessage)
        responsoVO = self.context.getMessageRegistry().getSavedResponseVO(reversesKey)
        if responsoVO == None:
            responsoVO = self.context.getMessageRegistry().getSavedResponseVO(reversesKey_1)

        return responsoVO


    
    def getReversesKey(self, posMessage):
        reversesKey = PosMessageKey()
        
        #reversesKey.addField(2, posMessage.getPAN())
        reversesKey.addField(0, "0210")
        reversesKey.addField(41, posMessage.getCardAcceptorTerminalIdentification())
        reversesKey.addField(37, posMessage.getRetrievalReferenceNumber())
        reversesKey.addField(12, posMessage.getLocalTransactionTime())
        reversesKey.addField(13, posMessage.getBodyElement(13))
        reversesKey.addField(3, posMessage.getProcessingCode())
        reversesKey.addField(39, "00")
        
        return reversesKey

    def getReversesKey_1(self, posMessage):
        reversesKey = PosMessageKey()
        
        #reversesKey.addField(2, posMessage.getPAN())
        reversesKey.addField(0, "0230")
        reversesKey.addField(41, posMessage.getCardAcceptorTerminalIdentification())
        reversesKey.addField(37, posMessage.getRetrievalReferenceNumber())
        reversesKey.addField(12, posMessage.getLocalTransactionTime())
        reversesKey.addField(13, posMessage.getBodyElement(13))
        reversesKey.addField(3, posMessage.getProcessingCode())
        reversesKey.addField(39, "00")
        
        return reversesKey