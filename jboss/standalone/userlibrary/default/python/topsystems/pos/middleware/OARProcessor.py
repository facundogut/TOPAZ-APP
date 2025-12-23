# package topsystems.pos.Middleware;

# Java import
from java.lang import Integer
from java.lang import Double
from java.lang import String
from topsystems.pos.core.process import MessageDefinition
from topsystems.pos.core.operation import OARRequestMiddleware
from topsystems.pos.core import POSException;
from topsystems.pos.core.process import PosReturnCodes
from topsystems.pos.core import AuthorizationNumberGenerator

# jython import
from topsystems.pos.core.PosMessage import PosMessage
from topsystems.pos.core.PosMessage import InfoCuenta
from topsystems.pos.core.CrossReferences import BasicCross
      
class OARProcessor(MessageDefinition):

    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.ang = AuthorizationNumberGenerator()
    
    def createRequest(self):
    
        oarRequest = OARRequestMiddleware(self.context)
        
        nroTarjeta = self.posMessage.getCardNumber()
        
        oarRequest.setIdTarjeta(nroTarjeta)
                        
        return oarRequest

        
    def createResponse(self, oarResponse):
        if oarResponse.getResultCode() == PosReturnCodes.OK :      
            self.createOkResponse(oarResponse)
        else:
            self.internalCreateErrorResponse(oarResponse.getResultCode())
            
        return self.posMessage.getPosMessage()
        
    def createOkResponse(self, oarResponse):
        self.basicCreateResponse()

        self.posMessage.setAuthorizationIdentificationResponse(self.ang.getNext())
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", PosReturnCodes.OK))
        
        # Defino las listas para 'guardar' las cuentas
        cuentas = []
        
        # Inicializo la recorrida del resultado
        oarResponse.start()        
        while oarResponse.hasNext() :
            oarResponse.next()
            
            sucursal   = oarResponse.getResult("SUCURSAL")
            producto   = oarResponse.getResult("PRODUCTO")
            moneda     = oarResponse.getResult("MONEDA")
            nroCuenta  = long(oarResponse.getResult("CUENTA"))
            operacion  = oarResponse.getResult("OPERACION")
            ordinal    = oarResponse.getResult("ORDINAL")

            cuenta = InfoCuenta(sucursal, producto, moneda, nroCuenta, operacion, ordinal)
            
            cuentas.append(cuenta)                
             
        self.posMessage.setListaCuentasMiddlewareAD(self.getPermisosTarjeta(), cuentas)        
    
    def createErrorResponse(self, failedService):    
        self.internalCreateErrorResponse(failedService.getErrorCode())        
        return self.posMessage.getPosMessage()
        
    def internalCreateErrorResponse(self, errorCode):

        self.basicCreateResponse()
        
        self.posMessage.setAuthorizationIdentificationResponse(self.ang.getNext())
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", errorCode))

        # campo 125 - Statement Print
        cuentas = []
        self.posMessage.setListaCuentasMiddlewareAD("C", cuentas)                
    
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
    
    def getPermisosTarjeta(self):
        tipoTarjeta = self.context.getTarjeta().getVoTipoTarjeta()
        permisos = "C" # Por defecto solo le dejo consultar
        if tipoTarjeta !=  None:
            permisos = tipoTarjeta.getGrupoOperacionesPermitidas().strip()       
            
        return permisos