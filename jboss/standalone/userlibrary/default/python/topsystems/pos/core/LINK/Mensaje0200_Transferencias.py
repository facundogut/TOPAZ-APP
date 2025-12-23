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
from topsystems.pos.core.LINK.Validacion_Msj_Existente import Validacion_Msj_Existente
from topsystems.pos.core.LINK.Obtener_Msj_Existente import Obtener_Msj_Existente
from topsystems.pos.core.LINK.Obtener_Msj_0420_0220 import Obtener_Msj_0420_0220

class Mensaje0200_Transferencias(MessageDefinition):

    def __init__(self, isoMessage, context):
        self.context = context
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.authorizationNumber = -1
        self.saldo = None
        self.jtsSaldo = None
        #self.msjObtenido = Obtener_Msj_Existente(context)
        #self.responseToMsjObtenido = self.msjObtenido.getResponseToOriginalMessage(self.posMessage)
        #self.codigoReversa = self.posMessage.getResponseCode()
        
    #Se agrega para validar que no sea una restransmición
        if self.posMessage.getMessageType() == "0221" or self.posMessage.getMessageType() == "0220":
            self.msjObtenido = Obtener_Msj_0420_0220(context)
            self.responseToMsjObtenido = self.msjObtenido.getResponseToOriginalMessage(self.posMessage)
            Validacion_Msj_Existente(self.responseToMsjObtenido)
        #Se agrega para validar que el movimiento no haya sido ya reversado
        else :
            self.msjObtenido = Obtener_Msj_Existente(context)
            self.responseToMsjObtenido = self.msjObtenido.getResponseToOriginalMessage(self.posMessage)

        self.codigoReversa = self.posMessage.getResponseCode()

    def getServices(self, services):
    #Se agrega para validar que el movimiento no haya sido ya reversado
        if self.codigoReversa != "32":
            services.add(Validacion_Msj_Existente(self.responseToMsjObtenido))
    
    def createRequest(self):
        operRequest = OperationRequest(self.context.getOperationMgrSession())

        # numero de operacion dependiendo si es Intermoneda o no
        
        tCuentaOrig=self.posMessage.getProcessingCode()[3:4]
        tCuentaDest=self.posMessage.getProcessingCode()[5:6]
        #igual Moneda transferencia entre cuentas
        if tCuentaOrig == tCuentaDest :
            operRequest.setOperationNumber(7601)
        #diferente Moneda es Compra/Venta de moneda
        else:
            operRequest.setOperationNumber(7603)

        debitAccount = self.posMessage.getDebitAccount()
        monedaCuenta = self.cross.map("AccountCurrency", debitAccount)
        tipoCuentaDebito = self.posMessage.getDebitAccount()
        tipoCuentaCredito = self.posMessage.getCreditAccount()
        tarjeta = self.posMessage.getCardNumber()
        cuentaLinkFrom = self.posMessage.getFromAccount()
        cuentaLinkTo = self.posMessage.getToAccount()
        importe = self.posMessage.getAmount()
        tipoTransaccion = self.posMessage.getMessageType()

        #Se agrega para el armado de la cuenta redlink 102, debito
        if tipoCuentaDebito == "10":
           tipoDebito = "11"
        elif tipoCuentaDebito == "20":
            tipoDebito = "01"
        else :
            tipoDebito = tipoCuentaDebito

        #Se agrega para el armado de la cuenta redlink 103, crédito
        if tipoCuentaCredito == "10":
           tipoCredito = "11"
        elif tipoCuentaCredito == "20":
            tipoCredito = "01"
        else :
            tipoCredito = tipoCuentaCredito
        
        
        #Concateno el tipo para cuenta destino y cuenta origen
        TipocuentaLinkFrom = tipoDebito+cuentaLinkFrom
        TipocuentaLinkTo = tipoCredito+cuentaLinkTo
        #Log.debug(cuentaLink)
        
        moneda = self.posMessage.getCross("CurrencyCode", self.posMessage.getCurrencyCode())

        operRequest.addParameter("TIPO_TRANS", tipoTransaccion) # tipo Transacción (0200 - 0220)
        operRequest.addParameter("CUENTALINKORG", TipocuentaLinkFrom) # cuenta
        operRequest.addParameter("CUENTALINKDEST", TipocuentaLinkTo) # cuenta
        operRequest.addParameter("IMPORTE", Double(importe)) # importe
        operRequest.addParameter("MONEDA", Integer(moneda)) # moneda extraccion
        operRequest.addParameter("NROTARJETA", tarjeta) # numero tarjeta
        operRequest.addParameter("FECHA", self.posMessage.getLocalTransactionDate())  # fecha
        operRequest.addParameter("REDCAJERO", self.posMessage.getTerminalNetwork()) # red del cajero
        #operRequest.addParameter("PRODUCTO", producto)
        operRequest.addParameter("MONEDA_CUENTA", monedaCuenta)
        operRequest.addParameter("NUMERO_AUTORIZACION", self.getAuthorizationNumber())

        return operRequest

    def createResponse(self, operResponse):
        self.basicCreateResponse()


        #Obtengo el codigo de Respuesta de la Operación 8911
        codRetorno = operResponse.getResult("CODRETORNO")
        self.posMessage.setAuthorizationIdentificationResponse(self.getAuthorizationNumber())

        #Si el codigo de Respuesta es Null falló la Operación
        if codRetorno == None :
            raise POSException(999, "Error al crear la respuesta, el parámetro de salida de la operación (COD_RETORNO) es null.")
        
        #Si el codigo de Respuesta es 99 No existe la cuenta y se responde con codigo 76. Elemento 39 = 76
        if codRetorno == 99:
            self.posMessage.setResponseCode(76) 
        else:
            #Obteng el estado de la cuenta desde la operación 8911
            estadoCuenta = operResponse.getResult("ESTADO_CUENTA")
            #Verifico el Estado de la Cuenta, si es 1 esta inhabilitada y se responde con codigo 05. Elemento 39 = 05
            if estadoCuenta == "1":
                self.posMessage.setResponseCode(5)
                self.posMessage.setFechaAlta("00000000")
            else:
                self.posMessage.setResponseCode(int(codRetorno))
                #Obtengo los siguientes campos desde la operación 8911
                saldoContable = operResponse.getResult("SALDO_CONTABLE")
                saldoDisponible = operResponse.getResult("SALDO_DISPONIBLE")
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


            return self.posMessage.getPosMessage()

    def createErrorResponse(self, failedService):
        self.basicCreateResponse()

        # Para esta primer prueba esto es lo único que cambié con respecto al create response
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))

        # campo 44 - Accounts Position - Saldos de la cuenta
        #self.posMessage.setAccountsPosition("00", "00", "000", 0, 0)

        return self.posMessage.getPosMessage()

    def basicCreateResponse(self):

        tipoMensaje = self.posMessage.getMessageType()
        if  tipoMensaje == "0220" or tipoMensaje == "0221":
            self.posMessage.setMessageType("0230")
        else :
            self.posMessage.setMessageType("0210")
        #self.posMessage.setMessageType("0210")

        self.posMessage.getHeader().setResponderCode(5)

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

        self.posMessage.setAuthorizationIdentificationResponse(self.getAuthorizationNumber())

    def getTipoOperacion(self, transactionCode): 
        tipoOperacion = self.cross.map("OperationCode", transactionCode)
        return tipoOperacion

    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()

        return self.authorizationNumber
