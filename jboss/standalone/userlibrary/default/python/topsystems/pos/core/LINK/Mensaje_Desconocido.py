# package topsystems.pos.core;

# Java import
from java.lang import Integer
from java.lang import Double
from topsystems.pos.core.process import MessageDefinition
from topsystems.pos.core.operation import DummyRequest
from topsystems.pos.core import POSException;

# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage

# Esta clase implementa por defecto la interfase TransactionDefinition

class Mensaje_Desconocido(MessageDefinition):

    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)

    def getServices(self, services):
        var = 1 #return
        
    def createRequest(self):
        
        operRequest = DummyRequest()
        return operRequest
        
    def createResponse(self, operResponse):        
        self.posMessage.getPosMessage().configureAsErrorMessage()
        return self.posMessage.getPosMessage()
    
    def createErrorResponse(self, failedService):
        return