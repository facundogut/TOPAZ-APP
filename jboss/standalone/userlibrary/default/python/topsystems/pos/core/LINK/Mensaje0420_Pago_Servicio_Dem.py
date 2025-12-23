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
from topsystems.pos.core.operation import ExtornRequest
# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.core.LINK.CrossReferences import BasicCross
from topsystems.pos.core.LINK.ReversePreprocessor import ReversePreprocessor
from topsystems.pos.core.LINK.Validacion_Msj_Existente import Validacion_Msj_Existente
from topsystems.pos.core.LINK.Obtener_Msj_0420_0220 import Obtener_Msj_0420_0220

class Mensaje0420_Pago_Servicio_Dem(MessageDefinition):
    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.authorizationNumber = -1
        self.reversePreprocessor = ReversePreprocessor(context)
        self.msjObtenido = Obtener_Msj_0420_0220(context)
        self.responseToMsjObtenido = self.msjObtenido.getResponseToOriginalMessage(self.posMessage)
        self.codigoReversa = self.posMessage.getResponseCode()
        
    def getServices(self, services):
        if self.posMessage.getMessageType() == "0421":
            services.add(Validacion_Msj_Existente(self.responseToMsjObtenido))
    
    #def getServices(self, services):
    #   var = 1

    def createRequest(self):
        self.responseToOriginalMessage = self.reversePreprocessor.getResponseToOriginalMessage(self.posMessage)
        #Log.debug(self.posMessage.toString())
        #Log.debug(self.responseToOriginalMessage.getResponseCode())

        if self.originalRequestEffectivelyProcessed(self.responseToOriginalMessage) :
            #importeAReversar = int(self.posMessage.getParcialAmount())
            #importeAReversar = self.posMessage.getParcialAmount()

            #if importeAReversar == "000000000000" :
            registro = self.reversePreprocessor.getResponseVOForOriginalMessage(self.posMessage)
            nroAsiento = registro.getTopazPostingNumber();
            nroSucursal = registro.getTopazBranch()
            fechaProceso = registro.getTopazProcessDate()
            sessionInfo = self.context.getOperationMgrSession().getTopazSession().getSessionInfo()
            posProcessorRequest = ExtornRequest(nroAsiento, nroSucursal, fechaProceso, sessionInfo)
            #ret = posProcessorRequest.process()
            return posProcessorRequest
        else :
            return DummyRequest()

    def originalRequestEffectivelyProcessed(self, responseToOriginalMessage) :
            return responseToOriginalMessage != None and responseToOriginalMessage.getResponseCode() == "00"

    def createResponse(self, extornResponse):
        self.basicCreateResponse()

        if self.originalRequestEffectivelyProcessed(self.responseToOriginalMessage) :
            codRetorno = extornResponse.getResultCode()
            if codRetorno == None :
                raise POSException(999, "Error al crear la respuesta, el parámetro de salida de la operación (CODRETORNO) es null.")

            self.posMessage.setResponseCode(codRetorno)
        
        return self.posMessage.getPosMessage()
        
    def createErrorResponse(self, failedService):
        
        self.basicCreateResponse()
        
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))
                
        return self.posMessage.getPosMessage()
        
    def basicCreateResponse(self):
        
        tipoMensaje = self.posMessage.getMessageType()
        self.posMessage.setResponseCode(0)
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
        self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(53) 
        self.posMessage.removeBodyElement(98) 
        self.posMessage.removeBodyElement(120) 

        
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber
           
        
    
