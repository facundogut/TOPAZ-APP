# -*- coding: latin-1 -*- 
# package topsystems.pos.core;
# Java import
from java.lang import Integer
from java.lang import Double
from java.lang import String
from java.lang import Long
from java.lang import Float
from topsystems.pos.core.process import MessageDefinition
from topsystems.pos.core.operation import OperationRequest
from topsystems.pos.core.operation import DummyRequest
from topsystems.pos.core import POSException
from topsystems.pos.core.process import PosReturnCodes
from topsystems.pos.service import PosServiceValidezTarjeta
from topsystems.pos.service import PosServiceValidacionCuentaConOrdinal
from topsystems.pos.service import PosServiceValidacionPais
from topsystems.pos.core import AuthorizationNumberGenerator
from topsystems.util.log import Log
from topsystems.pos.core.LINK.ReversePreprocessor import ReversePreprocessor
from topsystems.pos.core.operation import ExtornRequest
from topsystems.pos.core.LINK.Mensaje0200_Retiro import Mensaje0200_Retiro
#from topsystems.pos.core.operation import process
#from topsystems.pos.core.operation import extornResponse
#from topsystems.pos.core.operation import ExtornProcessResponse


# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.core.LINK.CrossReferences import BasicCross

class Mensaje_ReversaSospechozaRetiro(MessageDefinition):

    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.posMessageOrg = MessageDefinition
        self.cross = BasicCross()
        self.authorizationNumber = -1
        self.reversePreprocessor = ReversePreprocessor(context)
        self.jtsSaldo = None
        
    def getServices(self, services):
        var = 1
        #services.add(PosServiceValidezTarjeta(self.context, self.posMessage.getPAN(), self.posMessage.getLocalTransactionDate()))
        #services.add(PosServiceValidacionCuentaConOrdinal(self.context, self.posMessage.getPAN(), int(self.posMessage.getAccountOrdinal())))


        
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
            ret = posProcessorRequest.process()

            #Operación para retirar nuevamente el dinero
            operRequest = OperationRequest(self.context.getOperationMgrSession())
            operRequest.setOperationNumber(8912)

            debitAccount = self.posMessage.getDebitAccount()
            moneda = self.posMessage.getCurrencyCode()
            monedaCuenta = self.cross.map("AccountCurrency", debitAccount)
            tipoCuenta = self.posMessage.getDebitAccount()
            tarjeta = self.posMessage.getCardNumber()
            cuentaLink = self.posMessage.getFromAccount()
            importe = self.posMessage.getAmount()
            monedaTransaccion = self.posMessage.getCurrencyCode()

            #Seteo el Nro. de Tarjeta en el contexto para utilizar los métodos Java
            self.context.setIdTarjeta(tarjeta)
        
            Log.debug(cuentaLink)
            Log.debug(tipoCuenta)
            Log.debug(monedaCuenta.toString())

            #Obtener Saldo por Cuenta Link - Tipo de Cuenta - Moneda Cuenta
            saldo = self.context.getSaldoXPBFMonedaTipoCuenta(cuentaLink, long(tipoCuenta) , long(monedaCuenta))

            self.jtsSaldo=saldo.getJtsOid()

            moneda = self.posMessage.getCross("CurrencyCode", monedaTransaccion)

            operRequest.addParameter("CUENTALINK", cuentaLink) 
            operRequest.addParameter("IMPORTE", Double(importe))
            operRequest.addParameter("MONEDA", Integer(moneda))
            operRequest.addParameter("NROTARJETA", tarjeta)
            operRequest.addParameter("FECHA", self.posMessage.getLocalTransactionDate())
            operRequest.addParameter("REDCAJERO", self.posMessage.getTerminalNetwork())
            operRequest.addParameter("LIMITE_MONTO_MN", self.context.getTarjeta().getLimiteRetirosTarjetaYTipoMN())
            operRequest.addParameter("LIMITE_MONTO_ME", self.context.getTarjeta().getLimiteRetirosTarjetaYTipoME())
            operRequest.addParameter("MONEDA_CUENTA", monedaCuenta)
            operRequest.addParameter("NUMERO_AUTORIZACION", self.getAuthorizationNumber())
            #ret = process();
            retOper = operRequest.process()
            #operRequest = Mensaje0200_Retiro(self.posMessageOrg, self.context)
                
              #else :
            return DummyRequest()
        else :
            return DummyRequest()
        
    #responde afirmativo si se ejecuto la Op y además se grabó el asiento
    def originalRequestEffectivelyProcessed(self, responseToOriginalMessage) :
            return responseToOriginalMessage != None and responseToOriginalMessage.getResponseCode() == "00"

    def createResponse(self, extornResponse):
        self.basicCreateResponse()

        if self.originalRequestEffectivelyProcessed(self.responseToOriginalMessage) :
            codRetorno = extornResponse.getResultCode()
            if codRetorno == None :
                raise POSException(999, "Error al crear la respuesta, el parámetro de salida de la operación (CODRETORNO) es null.")

            self.posMessage.setResponseCode(codRetorno)
            #Cuenta=self.responseToOriginalMessage.getBit121()
            #self.posMessage.setToAccountBIT121(Cuenta)
        
        
        return self.posMessage.getPosMessage()
    
    def createErrorResponse(self, failedService):
        
        self.basicCreateResponse()
        
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))
        #self.posMessage.setResponseCode(0)
        
        return self.posMessage.getPosMessage()
    
    def basicCreateResponse(self):
        tipoMensaje = self.posMessage.getMessageType()
        
        if tipoMensaje == "0421" :
            self.posMessage.setMessageType("0410")
        else :
            self.posMessage.setMessageType("0410")
            
        # Elimino los campos que vienen en el 0200 y que no van en la respuesta
        self.posMessage.removeBodyElement(15) 
        self.posMessage.removeBodyElement(19) 
        self.posMessage.removeBodyElement(22) 
        self.posMessage.removeBodyElement(25) 
        self.posMessage.removeBodyElement(35) 
        self.posMessage.removeBodyElement(42) 
        self.posMessage.removeBodyElement(43) 
        self.posMessage.removeBodyElement(52) 
        
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber
           
        
    
