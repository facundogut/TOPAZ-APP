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

# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.core.LINK.CrossReferences import BasicCross

class Mensaje0200_Tipo_Cambio(MessageDefinition):
    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.authorizationNumber = -1
        
    def getServices(self, services):
        var = 1
    
    def createRequest(self):
        
        operRequest = OperationRequest(self.context.getOperationMgrSession())
            
        # numero de operacion
        operRequest.setOperationNumber(7602)
        #cuentaLink = self.posMessage.getFromAccount()
        #operRequest.addParameter("CUENTALINK", cuentaLink)    
        
        #se agrego para el alta de historico
        #operRequest.addParameter("NROCAJERO", self.posMessage.getCardAcceptorTerminalIdentification())
        
        # Identificacion de la red
        #bin = self.posMessage.getAdquiringInstitutionIdentification()
        #operRequest.addParameter("BIN", bin)
        monedaRecibida = self.posMessage.getCurrencyCode()
        moneda = self.posMessage.getCross("CurrencyCode", monedaRecibida)

        tipoConsulta = self.posMessage.getTipoConsultaTipoCambio()
        cotzacionCompra = tipoConsulta[4:12]
        cotzacionVenta = tipoConsulta[12:20]

        operRequest.addParameter("MONEDA", Integer(moneda)) # moneda consulta
        operRequest.addParameter("TIPOSOL", tipoConsulta) # moneda extraccion

        
        return operRequest
        
    def createResponse(self, operResponse):
        
        self.basicCreateResponse()

        #Obtengo el codigo de Respuesta de la Operaci�n 7602
        codRetorno = operResponse.getResult("CODRETORNO")
        self.posMessage.setAuthorizationIdentificationResponse(self.getAuthorizationNumber())

        #Si el codigo de Respuesta es Null fall� la Operaci�n
        if codRetorno == None :
            raise POSException(999, "Error al crear la respuesta, el par�metro de salida de la operaci�n (COD_RETORNO) es null.")
        
        #Si el codigo de Respuesta es 99 
        if codRetorno == 99:
            self.posMessage.setResponseCode(76) 
        else:
            self.posMessage.setResponseCode(int(codRetorno)) 
            cVenta = operResponse.getResult("COTIZACION_VENTA")
            cCompra = operResponse.getResult("COTIZACION_COMPRA")
            tipoConsulta=self.posMessage.getTipoConsultaTipoCambio()
            self.posMessage.setC127(tipoConsulta,cCompra,cVenta)
            self.posMessage.setC90(" ")
            self.posMessage.setC95("000000000000000000000000000000000000000000")
            self.posMessage.setC122("00000000000")
            self.posMessage.setC123("00000000000 ")
            self.posMessage.setC44("2-00000000000-00000000000")


        return self.posMessage.getPosMessage()
        
    def createErrorResponse(self, failedService):
        
        self.basicCreateResponse()
        
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))
                
        return self.posMessage.getPosMessage()
        
    def basicCreateResponse(self):
        
        
        tipoMensaje = self.posMessage.getMessageType()
        
        if tipoMensaje == "0200" :
            self.posMessage.setMessageType("0210")
        else :
            self.posMessage.setMessageType("0230")
        
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
        self.posMessage.removeBodyElement(50) 
        self.posMessage.removeBodyElement(51) 
        self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(53) 
        self.posMessage.removeBodyElement(62) 
        self.posMessage.removeBodyElement(98) 

        
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber
           
        
    
