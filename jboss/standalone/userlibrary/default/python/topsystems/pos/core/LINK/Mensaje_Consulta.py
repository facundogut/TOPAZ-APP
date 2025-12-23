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
from topsystems.pos.service import PosServiceValidezTarjeta
from topsystems.pos.service import PosServiceValidacionCuentaConOrdinal
from topsystems.pos.core import AuthorizationNumberGenerator
from topsystems.util.log import Log
#from topsystems.pos.service import PosServiceValidacionPIN


# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.core.LINK.CrossReferences import BasicCross

class Mensaje_Consulta(MessageDefinition):
    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.authorizationNumber = -1
        
    def getServices(self, services):
        var = 1
        #services.add(PosServiceValidezTarjeta(self.context, self.posMessage.getPAN(), self.posMessage.getLocalTransactionDate()))
        #services.add(PosServiceValidacionPIN(self.context, self.posMessage.getBin(), self.posMessage.getTrack2(), self.posMessage.getPIN()))
        #services.add(PosServiceValidacionCuentaConOrdinal(self.context, self.posMessage.getPAN(), int(self.posMessage.getAccountOrdinal())))
        
        #if int(self.posMessage.getCountryCode()) != 68 :
            #services.add(PosServiceValidacionPais(self.context, self.posMessage.getPAN(), int(self.posMessage.getCountryCode()), self.posMessage.getLocalTransactionDate()))
        
    def createRequest(self):
        
        operRequest = OperationRequest(self.context.getOperationMgrSession())
            
        # numero de operacion
        operRequest.setOperationNumber(8911)
        cuentaLink = self.posMessage.getFromAccount()
        operRequest.addParameter("CUENTALINK", cuentaLink)    
        
        #se agrego para el alta de historico
        operRequest.addParameter("NROCAJERO", self.posMessage.getCardAcceptorTerminalIdentification())
        
        # Identificacion de la red
        bin = self.posMessage.getAdquiringInstitutionIdentification()
        operRequest.addParameter("BIN", bin)
        
        
        #se agrego para el alta de historico
        #transactionCode = self.posMessage.getTransactionCodeFromBin(bin)
        #operRequest.addParameter("TRANSACCION_CODE", transactionCode)
        
        #tipoCuenta = self.posMessage.getDebitAccount()
        #operRequest.addParameter("TIPOCUENTA", tipoCuenta)    
        #codigoBIT39=self.posMessage.getResponseCode()
        #if codigoBIT39 != "Q1" :
        #     Log.debug("Tarjeta sin chip")

        #else:
        #     operRequest.addParameter("COD", codigoBIT39)
        
        #Pais = self.posMessage.getCardAcceptorCountryLocation()
        #operRequest.addParameter("PAIS", Pais) 
        
        #moneda no sirve para nada
        #moneda = self.posMessage.getCurrencyCode()
        #moneda = self.posMessage.getCross("CurrencyCode", moneda)
        #operRequest.addParameter("MONEDA", Double(moneda))
        
        return operRequest
        
    def createResponse(self, operResponse):
        
        self.basicCreateResponse()

        codRetorno = operResponse.getResult("COD_RETORNO")
        self.posMessage.setAuthorizationIdentificationResponse(self.getAuthorizationNumber())
        if codRetorno == None :
            raise POSException(999, "Error al crear la respuesta, el parámetro de salida de la operación (COD_RETORNO) es null.")
        
        if codRetorno == 99:
            self.posMessage.setResponseCode(39) #No existe la cuenta
        else:
            estadoCuenta = operResponse.getResult("ESTADO_CUENTA")
            saldoContable = operResponse.getResult("SALDO_CONTABLE")
            saldoDisponible = operResponse.getResult("SALDO_DISPONIBLE")
            monedaCuenta = operResponse.getResult("MONEDA_CUENTA")
            cuenta = operResponse.getResult("CUENTA")
            fechaAlta = operResponse.getResult("FECHA_APERTURA")
            if estadoCuenta == "1":
                self.posMessage.setResponseCode(76)
            else:
                self.posMessage.setResponseCode(int(codRetorno))
            signoC = "0"
            signoD = "0"
            if saldoContable >= 0:
                signoC = "0"
            else:
                signoC = "-"
            if saldoDisponible >= 0:
                signoD = "0"
            else:
                signoD = "-"
            self.posMessage.setAccountsPosition(signoC, saldoContable, signoD, saldoDisponible)
            self.posMessage.setFechaAlta(fechaAlta)
            self.posMessage.setC90("10          ")
            self.posMessage.setC95("000000000000000000000000000000000000000000")
            self.posMessage.setC122("00000000000")
            self.posMessage.setC123("00000000000 ")

            #codRetorno = 0
            #No mapeo el codigo de retorno en el crossreference, devuelvo en las operaciones Topaz el solicitado por el cliente
            #mapCodRet = self.cross.map("ReturnCode", int(codRetorno)) 
            #if mapCodRet == None :
                #raise POSException(999, "Error al crear la respuesta. No se encontró la referencia cruzada para el código de retorno '" + str(Float(codRetorno).intValue()) + "'.")
            #self.posMessage.setSaldos(saldoEnSoles,saldoEnSolesDisp,monedaCuenta)
            #self.posMessage.setToAccountBIT121(cuenta)

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
        #self.posMessage.removeBodyElement(12) 
        #self.posMessage.removeBodyElement(13) 
        self.posMessage.removeBodyElement(14) 
        #self.posMessage.removeBodyElement(15) 
        self.posMessage.removeBodyElement(16) 
        #self.posMessage.removeBodyElement(17) 
        self.posMessage.removeBodyElement(18) 
        self.posMessage.removeBodyElement(22) 
        self.posMessage.removeBodyElement(24) 
        self.posMessage.removeBodyElement(25) 
        self.posMessage.removeBodyElement(29) 
        self.posMessage.removeBodyElement(31) 
        #self.posMessage.removeBodyElement(32) 
        #self.posMessage.removeBodyElement(35) 
        #self.posMessage.removeBodyElement(37) 
        #self.posMessage.removeBodyElement(41) 
        #self.posMessage.removeBodyElement(42) 
        #self.posMessage.removeBodyElement(43) 
        self.posMessage.removeBodyElement(50) 
        self.posMessage.removeBodyElement(51) 
        self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(53) 
        #self.posMessage.removeBodyElement(90) 
        self.posMessage.removeBodyElement(98) 
        #self.posMessage.removeBodyElement(102)
        #self.posMessage.removeBodyElement(103)
        
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber
           
        
    
