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

class Mensaje0200_Transferencias_inm_debin(MessageDefinition):

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
        if self.codigoReversa != "32":
            services.add(Validacion_Msj_Existente(self.responseToMsjObtenido))
    
    def createRequest(self):
        operRequest = OperationRequest(self.context.getOperationMgrSession())


        operRequest.setOperationNumber(7610)

        debitAccount = self.posMessage.getDebitAccount()
        monedaCuenta = self.cross.map("AccountCurrency", debitAccount)
        tipoCuentaDebito = self.posMessage.getDebitAccount()
        tipoCuentaCredito = self.posMessage.getCreditAccount()
        tarjeta = self.posMessage.getCardNumber()
        cuentaLinkFrom = self.posMessage.getFromAccount()
        cuentaLinkTo = self.posMessage.getToAccount()
        importe = self.posMessage.getAmount()
        tipoTransaccion = self.posMessage.getMessageType()
        tipoTr = self.posMessage.getTransactionCode()
        codigoMensaje=self.posMessage.getProcessingCode()
        horaMensaje=self.posMessage.getLocalTransactionTime()
        
        if tipoTr == "09" or tipoTr == "29":
            tipo = "T"
        else:
            tipo = "D"

    #Armado de la cuenta redLink. Si es 09 es debito, si es 29 credito. Dependiendo que es, se le concatena el tipo
    #En caso que sea Transferencias Inmediatas, 09 y 29
        if tipo == "T" and tipoTr == "09":
            if tipoCuentaDebito == "10":
                tipodeCuenta = "11"
            elif tipoCuentaDebito == "20":
                tipodeCuenta = "01"
            else :
                tipodeCuenta = tipoCuentaDebito
        elif tipo == "T" and tipoTr == "29":
            if tipoCuentaCredito == "10":
                tipodeCuenta = "11"
            elif tipoCuentaCredito == "20":
                tipodeCuenta = "01"
            else :
                tipodeCuenta = tipoCuentaCredito

    #En caso que sean tipo Debin Credin F3, F4
        if tipo =="D" and tipoTr == "F3":
            if tipoCuentaDebito == "10":
                tipodeCuenta = "11"
            elif tipoCuentaDebito == "20":
                tipodeCuenta = "01"
            else :
                tipodeCuenta = tipoCuentaDebito
        elif tipo == "D" and tipoTr == "F4":
            if tipoCuentaCredito == "10":
                tipodeCuenta = "11"
            elif tipoCuentaCredito == "20":
                tipodeCuenta = "01"
            else :
                tipodeCuenta = tipoCuentaCredito
    #PROBAR EN 0
        if cuentaLinkFrom == 0 or cuentaLinkFrom == " ":
            cuentaLinkTo = tipodeCuenta+cuentaLinkTo
            #TipocuentaLinkFrom = "0"
        elif cuentaLinkTo == 0 or cuentaLinkTo == " ":
            cuentaLinkFrom = tipodeCuenta+cuentaLinkFrom
            #TipocuentaLinkTo = "0"

        moneda = self.posMessage.getCross("CurrencyCode", self.posMessage.getCurrencyCode())

        operRequest.addParameter("TIPO_TRANS", tipoTransaccion) # tipo Transacción (0200 - 0220)
        operRequest.addParameter("CUENTALINK102", cuentaLinkFrom) # cuenta
        operRequest.addParameter("CUENTALINK103", cuentaLinkTo) # cuenta
        operRequest.addParameter("IMPORTE", Double(importe)) # importe
        operRequest.addParameter("MONEDA", Integer(moneda)) # moneda extraccion
        operRequest.addParameter("NROTARJETA", tarjeta) # numero tarjeta
        operRequest.addParameter("FECHA", self.posMessage.getLocalTransactionDate())  # fecha
        operRequest.addParameter("REDCAJERO", self.posMessage.getTerminalNetwork()) # red del cajero
        #operRequest.addParameter("PRODUCTO", producto)
        operRequest.addParameter("MONEDA_CUENTA", monedaCuenta)
        operRequest.addParameter("NUMERO_AUTORIZACION", self.getAuthorizationNumber())
        operRequest.addParameter("ORIGEN", tipo)
        operRequest.addParameter("TRANSACCION",codigoMensaje)
        operRequest.addParameter("SECUENCIA", self.posMessage.getTraceNumber())
        operRequest.addParameter("HORA",horaMensaje)
        operRequest.addParameter("RECIBO", self.posMessage.getRetrievalReferenceNumber())
        operRequest.addParameter("TERMINAL", self.posMessage.getCardAcceptorTerminalIdentification())
        operRequest.addParameter("IDENTIFICACION_DEBIN", self.posMessage.getIdentidadDebin())
        operRequest.addParameter("CONCEPTO", self.posMessage.getConcepto())
        #operRequest.addParameter("BANCO_COMPRADOR", self.posMessage.getBancoComprador())
        #operRequest.addParameter("CUIT_COMPRADOR", self.posMessage.getCuitComprador())
        #operRequest.AddParameter("CBU_COMPRADOR", self.posMessage.getCbuComprador())
        #operRequest.addParameter("BANCO_VENDEDOR", self.posMessage.getBancoVendedor())
        #operRequest.addParameter("CUIT_VENDEDOR", self.posMessage.getCuitVendedor())
        #operRequest.addParameter("CBU_VENDEDOR", self.posMessage.getCbuVendedor())
        #operRequest.addParameter("CUENTA_COMPRADOR", self.posMessage.getCuentaComprador())
        #operRequest.addParameter("CUENTA_VENDEDOR", self.posMessage.getCuentaVendedor())
        #consultar si se puede reutilizar NROTARJETA
        operRequest.addParameter("NUMERO_TARJETA", self.posMessage.getNumeroTarjeta())
        operRequest.addParameter("NOMBRE_APELLIDO", self.posMessage.getNombreApellido())
        operRequest.addParameter("MISMO_TITULAR", self.posMessage.getMismoTitular())
        operRequest.addParameter("MISMO_TITULAR_TRANSF_INM", self.posMessage.getMismoTitularTransfInm())
        operRequest.addParameter("DEBITO_PREAUTORIZADO", self.posMessage.getDebitoPreAutorizado())
        operRequest.addParameter("ORGIEN_DEBIN_TRAN", self.posMessage.getOrigen_D_T())
        operRequest.addParameter("SCORING", self.posMessage.getScoring())
        operRequest.addParameter("ID_CONTRA_CARGO", self.posMessage.getID_ContraCargo())
        operRequest.addParameter("CONTRA_CARGO", self.posMessage.getContraCargo())
        operRequest.addParameter("CONCEPTO_TRANSF_INMEDIATA", self.posMessage.getConceptoInmediata())
        
        
        if tipoTr == "F3" or tipoTr == "F4":
            if tipoTr =="F3" :
                operRequest.addParameter("CBU", self.posMessage.getCbuVendedor())
                operRequest.addParameter("CUENTA", self.posMessage.getCuentaVendedor())
                operRequest.addParameter("CUIT", self.posMessage.getCuitVendedor())
                operRequest.addParameter("BANCO", self.posMessage.getBancoVendedor())
                
                #cuit banco y cuenta 
            else :
                operRequest.addParameter("CBU", self.posMessage.getCbuComprador())
                operRequest.addParameter("CUENTA", self.posMessage.getCuentaComprador())
                operRequest.addParameter("CUIT", self.posMessage.getCuitComprador())
                operRequest.addParameter("BANCO", self.posMessage.getBancoComprador())
                

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
            self.posMessage.setC122("00000000000")
            self.posMessage.setC123("00000000000 ")
            saldoContable = 0
            saldoDisponible = 0
            signoC = "0"
            signoD = "0"
            self.posMessage.setAccountsPosition(signoC, saldoContable, signoD, saldoDisponible)            
        else:
            #Obteng el estado de la cuenta desde la operación 8911
            estadoCuenta = operResponse.getResult("ESTADO_CUENTA")
            #Verifico el Estado de la Cuenta, si es 1 esta inhabilitada y se responde con codigo 05. Elemento 39 = 05
            if estadoCuenta == "1":
                self.posMessage.setResponseCode(5)
                self.posMessage.setFechaAlta("00000000")
                self.posMessage.setC122("00000000000")
                self.posMessage.setC123("00000000000 ")
                saldoContable = 0
                saldoDisponible = 0
                signoC = "0"
                signoD = "0"
                self.posMessage.setAccountsPosition(signoC, saldoContable, signoD, saldoDisponible)
                
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
            self.posMessage.setC52("                ")


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
        #self.posMessage.removeBodyElement(52) 
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
