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

class Mensaje0200_Consulta(MessageDefinition):
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
        operRequest.setOperationNumber(8911)
        cuentaLink = self.posMessage.getFromAccount()
        tipoCuenta = self.posMessage.getDebitAccount()
        
        #Se agrega para el armado de la cuenta redlink
        if tipoCuenta == "10":
           tipo = "11"
        elif tipoCuenta == "20":
            tipo = "01"
        else :
            tipo = tipoCuenta
                
        TipocuentaLink = tipo+cuentaLink
        
        operRequest.addParameter("CUENTALINK", TipocuentaLink)    
        
        #se agrego para el alta de historico
        operRequest.addParameter("NROCAJERO", self.posMessage.getCardAcceptorTerminalIdentification())
        
        # Identificacion de la red
        bin = self.posMessage.getAdquiringInstitutionIdentification()
        operRequest.addParameter("BIN", bin)
        
        
        return operRequest
        
    def createResponse(self, operResponse):
        
        self.basicCreateResponse()

        #Obtengo el codigo de Respuesta de la Operaci�n 8911
        codRetorno = operResponse.getResult("COD_RETORNO")
        self.posMessage.setAuthorizationIdentificationResponse(self.getAuthorizationNumber())

        #Si el codigo de Respuesta es Null fall� la Operaci�n
        if codRetorno == None :
            raise POSException(999, "Error al crear la respuesta, el par�metro de salida de la operaci�n (COD_RETORNO) es null.")
        
        #Si el codigo de Respuesta es 99 No existe la cuenta y se responde con codigo 76. Elemento 39 = 76
        if codRetorno == 99:
            self.posMessage.setResponseCode(76) 
            self.posMessage.setC122("00000000000")
            self.posMessage.setC123("00000000000 ")
            saldoContable = 0
            saldoDisponible = 0
            signoC = "0"
            signoD = "0"
            self.posMessage.setAccountsPosition(signoC, saldoContable, signoD, saldoDisponible)
        else:
            #Obteng el estado de la cuenta desde la operaci�n 8911
            estadoCuenta = operResponse.getResult("ESTADO_CUENTA")
            #Verifico el Estado de la Cuenta, si es 1 esta inhabilitada y se responde con codigo 05. Elemento 39 = 05
            if estadoCuenta == "1":
                self.posMessage.setResponseCode(5)
                self.posMessage.setFechaAlta("00000000")
                saldoContable = operResponse.getResult("SALDO_CONTABLE")
                saldoDisponible = operResponse.getResult("SALDO_DISPONIBLE")
                signoC = "0"
                signoD = "0"
                #Seteo el signo del Saldo Contable
                if saldoContable >= 0:
                    signoC = "0"
                else:
                    signoC = "-"
                #Seteo el signo del Saldo Disponible
                if saldoDisponible >= 0:
                    signoD = "0"
                else:
                    signoD = "-"
                #Seteo los campos requeridos por NBCH
                self.posMessage.setAccountsPosition(signoC, saldoContable, signoD, saldoDisponible)
                
            else:
                self.posMessage.setResponseCode(int(codRetorno))
                #Obtengo los siguientes campos desde la operaci�n 8911
                saldoContable = operResponse.getResult("SALDO_CONTABLE")
                saldoDisponible = operResponse.getResult("SALDO_DISPONIBLE")
                monedaCuenta = operResponse.getResult("MONEDA_CUENTA")
                cuenta = operResponse.getResult("CUENTA")
                fechaAlta = operResponse.getResult("FECHA_APERTURA")
                self.posMessage.setFechaAlta(fechaAlta)
                signoC = "0"
                signoD = "0"
                #Seteo el signo del Saldo Contable
                if saldoContable >= 0:
                    signoC = "0"
                else:
                    signoC = "-"
                #Seteo el signo del Saldo Disponible
                if saldoDisponible >= 0:
                    signoD = "0"
                else:
                    signoD = "-"
                #Seteo los campos requeridos por NBCH
                self.posMessage.setAccountsPosition(signoC, saldoContable, signoD, saldoDisponible)
            
            self.posMessage.setC90(" ")
            self.posMessage.setC95("000000000000000000000000000000000000000000")
            self.posMessage.setC122("00000000000")
            self.posMessage.setC123("00000000000 ")
            self.posMessage.setC52("                ")
            


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
        #self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(53) 
        self.posMessage.removeBodyElement(62) 
        self.posMessage.removeBodyElement(98) 

        
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber
           
        
    
