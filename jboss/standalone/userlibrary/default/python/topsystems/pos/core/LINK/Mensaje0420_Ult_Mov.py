# package topsystems.pos.core;

# Java import
from java.lang import Integer
from java.lang import Double
from java.lang import String
from java.lang import Long
from java.lang import Float
from topsystems.pos.core.process import MessageDefinition
from topsystems.pos.core.operation import OperationRequest
from topsystems.pos.core import POSException
from topsystems.pos.core.process import PosReturnCodes
from topsystems.pos.core import AuthorizationNumberGenerator
from topsystems.util.log import Log
from topsystems.pos.core.operation  import DummyRequest

# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.core.LINK.CrossReferences import BasicCross

class Mensaje0420_Ult_Mov(MessageDefinition):
    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.authorizationNumber = -1
        
    def getServices(self, services):
        var = 1

    def createRequest(self):

        request = DummyRequest()
        return request

    def createResponse(self, operResponse):
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", PosReturnCodes.OK))
        self.posMessage.setC90("")
        self.posMessage.setC95("00000000000")
        self.posMessage.setC122("00000000000")
        self.posMessage.setC123("00000000000")
        self.basicCreateResponse()
        return self.posMessage.getPosMessage()
        
    def createErrorResponse(self, failedService):
        
        self.basicCreateResponse()
        
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))
                
        return self.posMessage.getPosMessage()
        
    def basicCreateResponse(self):
        
        tipoMensaje = self.posMessage.getMessageType()
        
        self.posMessage.setMessageType("0430")
        
        # Elimino los campos que vienen en el 0200 y que no van en la respuesta
        self.posMessage.removeBodyElement(6) 
        self.posMessage.removeBodyElement(10) 
        self.posMessage.removeBodyElement(14) 
        self.posMessage.removeBodyElement(16) 
        self.posMessage.removeBodyElement(18) 
        self.posMessage.removeBodyElement(22) 
        self.posMessage.removeBodyElement(24) 
        self.posMessage.removeBodyElement(25) 
        self.posMessage.removeBodyElement(29) 
        self.posMessage.removeBodyElement(31) 
        self.posMessage.removeBodyElement(44) 
        self.posMessage.removeBodyElement(50) 
        self.posMessage.removeBodyElement(51) 
        #self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(53) 
        self.posMessage.removeBodyElement(98) 
        self.posMessage.removeBodyElement(120)
        
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber
           
        
    
