# package topsystems.pos.Middleware;

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
from topsystems.pos.service import PosServiceValidezTarjeta
from topsystems.pos.service import PosServiceValidacionCuenta
from topsystems.pos.service.pinmanager.verifypin import PosServiceValidacionPINWithRetries
from topsystems.pos.service import TipoTarjeta
from topsystems.util.log import Log

# jython import
from topsystems.pos.core.PosMessage import PosMessage
from topsystems.pos.core.CrossReferences import BasicCross
from topsystems.pos.middleware.OARProcessor import OARProcessor

class Mensaje0200_Autorizacion(MessageDefinition):

    def __init__(self, isoMessage, context):
        Log.debug("Python: Se va crear una instancia de la clase 'Mensaje0200_Autorizacion'.")
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.oarProcessor = OARProcessor(isoMessage, context)
        Log.debug("Python: Finaliza el constructor de la clase 'Mensaje0200_Autorizacion'.")
        
        
    def getServices(self, services):
        Log.debug("Python: Mensaje0200_Autorizacion.getServices - Se van a cargar los servicios a procesar")
        
        services.add(PosServiceValidezTarjeta(self.context, self.posMessage.getCardNumber(), self.posMessage.getLocalTransactionDate()))
        
        self.context.setIdTarjeta(self.posMessage.getCardNumber())
        tarjeta = self.context.getTarjeta()

        transportKeySet = "NBC"
        if tarjeta != None and \
            tarjeta.getVoTipoTarjeta() != None and \
            tarjeta.getVoTipoTarjeta().getClase() == TipoTarjeta.CLASE_TARJETA_BANRED :
            verificationKeySet = "BanRed"
        else :
            verificationKeySet = "NBC"
            
        services.add(PosServiceValidacionPINWithRetries(self.context, transportKeySet, verificationKeySet, self.posMessage.getCardNumber(), self.posMessage.getLocalTransactionDate(), self.posMessage.getPIN(), self.posMessage.getPINLength()))

        Log.debug("Python: Mensaje0200_Autorizacion.getServices - Se finalizó la carga de los servicios")

    def createRequest(self):        
        Log.debug("Python: Mensaje0200_Autorizacion.createRequest - Se van a cargar el request de la solicitud")
        operRequest = self.oarProcessor.createRequest()        
        Log.debug("Python: Mensaje0200_Autorizacion.createRequest - Se finalizó la creación del request")
        return operRequest

        
    def createResponse(self, operResponse):        
        Log.debug("Python: Mensaje0200_Autorizacion.createResponse - Se va a crear las respuesta al mensaje") 
        return self.oarProcessor.createResponse(operResponse)

    
    def createErrorResponse(self, failedService):    
        Log.debug("Python: Mensaje0200_Autorizacion.createErrorResponse - Se va a crear una respuesta de error")
        return self.oarProcessor.createErrorResponse(failedService)


    def getTipoOperacion(self, transactionCode): 
        tipoOperacion = self.cross.map("OperationCode", transactionCode)
        if tipoOperacion == None:
            raise POSException(999, "No se definio el mapping para el tipo de transaccion '" + transactionCode + "'.")
        return tipoOperacion