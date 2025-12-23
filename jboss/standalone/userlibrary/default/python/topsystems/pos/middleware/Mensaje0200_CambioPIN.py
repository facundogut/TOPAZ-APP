# package topsystems.pos.Middleware;

# Java import
from java.lang import Integer
from java.lang import Double
from java.lang import String
from java.lang import Long
from java.lang import Float
from topsystems.pos.core.process import MessageDefinition
from topsystems.pos.core import POSException;
from topsystems.pos.core.process import PosReturnCodes
from topsystems.pos.service import PosServiceValidezTarjeta
from topsystems.pos.service.pinmanager.verifypin import PosServiceValidacionPINWithRetries
from topsystems.pos.service.pinmanager.changepin import ChangePINProcessorRequestWithRetries
from topsystems.pos.core import AuthorizationNumberGenerator
from topsystems.pos.service import TipoTarjeta
from topsystems.util.log import Log

# jython import
from topsystems.pos.core.PosMessage import PosMessage
from topsystems.pos.core.CrossReferences import BasicCross

class Mensaje0200_CambioPIN(MessageDefinition):

    def __init__(self, isoMessage, context):
        Log.debug("Python: Se va crear una instancia de la clase 'Mensaje0200_CambioPIN'.")
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.ang = AuthorizationNumberGenerator()
        Log.debug("Python: Finaliza el constructor de la clase 'Mensaje0200_CambioPIN'.")
        
    def getServices(self, services):
        Log.debug("Python: Mensaje0200_CambioPIN.getServices - Se van a cargar los servicios a procesar")
        services.add(PosServiceValidezTarjeta(self.context, self.posMessage.getCardNumber(), self.posMessage.getLocalTransactionDate()))
        Log.debug("Python: Mensaje0200_CambioPIN.getServices - Se finalizó la carga de los servicios")

    def createRequest(self):
        Log.debug("Python: Mensaje0200_CambioPIN.createRequest - Se van a cargar el request de la solicitud")
        self.context.setIdTarjeta(self.posMessage.getCardNumber())
        tarjeta = self.context.getTarjeta()
        if tarjeta == None :
            raise POSException(999, "No se pudo recuperar la información de la tarjeta " + self.posMessage.getCardNumber())

        transportKeySet = "NBC"
        if tarjeta.getVoTipoTarjeta() != None and \
            tarjeta.getVoTipoTarjeta().getClase() == TipoTarjeta.CLASE_TARJETA_BANRED :
            verificationKeySet = "BanRed"
        else :
            verificationKeySet = "NBC"
                    
        operRequest = ChangePINProcessorRequestWithRetries(self.context, 
                                                           transportKeySet,
                                                           verificationKeySet,
                                                           self.posMessage.getCardNumber(), 
                                                           self.posMessage.getLocalTransactionDate(), 
                                                           self.posMessage.getPIN(), 
                                                           self.posMessage.getPINLength(), 
                                                           self.posMessage.getNewPIN())
        
        Log.debug("Python: Mensaje0200_CambioPIN.createRequest - Se finalizó la creación del request")

        return operRequest
        
    def createResponse(self, operResponse):        
        Log.debug("Python: Mensaje0200_CambioPIN.createResponse - Se va a crear las respuesta al mensaje") 
        
        self.basicCreateResponse()
        
            # codigo de retorno
        codRetorno = operResponse.getResultCode()
        mapCodRet = self.cross.map("ReturnCode", Float(codRetorno).intValue()) 
        self.posMessage.setResponseCode(mapCodRet)
        
        # código de autorización
        self.posMessage.setAuthorizationIdentificationResponse(self.ang.getNext())
        
        Log.debug("Python: Mensaje0200_CambioPIN.createResponse - Se finalizó la creación de la respuesta al mensaje") 
        return self.posMessage.getPosMessage()
    
    def createErrorResponse(self, failedService):        
        Log.debug("Python: Mensaje0200_CambioPIN.createErrorResponse - Se va a crear una respuesta de error")

        self.basicCreateResponse()
        
        # código de autorización
        self.posMessage.setAuthorizationIdentificationResponse(self.ang.getNext())

        # codigo de retorno
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))

        Log.debug("Python: Mensaje0200_CambioPIN.createResponse - Se finalizó la creación de la respuesta de error") 
        return self.posMessage.getPosMessage()
    
    def basicCreateResponse(self):
        self.posMessage.setMessageType("0210")
            
        self.posMessage.setOARFlag(9)
    
        # elimino los campos que vienen en el mensaje y que no van en la respuesta
        self.posMessage.removeBodyElement(42) 
        self.posMessage.removeBodyElement(43) 
        self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(54)         
        self.posMessage.removeBodyElement(63) 
        self.posMessage.removeBodyElement(67) 
        self.posMessage.removeBodyElement(93)         

    def getTipoOperacion(self, transactionCode): 
        tipoOperacion = self.cross.map("OperationCode", transactionCode)
        if tipoOperacion == None:
            raise POSException(999, "No se definio el mapping para el tipo de transaccion '" + transactionCode + "'.")
        return tipoOperacion