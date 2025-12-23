# -*- coding: latin-1 -*- 

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
from topsystems.pos.service import RelacionTarjetaCuenta
from topsystems.pos.core import AuthorizationNumberGenerator
from topsystems.pos.core import PosUltimosMovimientos
from topsystems.util.log import Log
from topsystems.pos.core.operation import DummyRequest
from java.sql import Timestamp
# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.core.LINK.CrossReferences import BasicCross
from topsystems.pos.core.LINK.PosMessage import Movimiento

class Mensaje0200_Ult_Mov(MessageDefinition):

    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.authorizationNumber = -1
        self.consultaMov = PosUltimosMovimientos()
        #self.jtsSaldo = None

    def getServices(self, services):
        var=1

    def createRequest(self):
        operRequest = OperationRequest(self.context.getOperationMgrSession())
        operRequest.setOperationNumber(8911)
        cuentaLink = self.posMessage.getFromAccount()
        moneda = self.posMessage.getCurrencyCode()
        tipoCuenta = self.posMessage.getDebitAccount()
        monedaCuenta = self.cross.map("AccountCurrency", tipoCuenta)
        var_bin = self.posMessage.getAdquiringInstitutionIdentification()
        #Seteo el Nro. de Tarjeta en el contexto para utilizar los métodos Java
        tarjeta = self.posMessage.getCardNumber()
        self.context.setIdTarjeta(tarjeta)

        #cuentaLink = self.posMessage.getFromAccount()
        #tipoCuenta = self.posMessage.getDebitAccount()
        #monedaCuenta = self.cross.map("AccountCurrency", tipoCuenta)

        ##Obtener Saldo por Cuenta Link - Tipo de Cuenta - Moneda Cuenta
        #saldo = self.context.getSaldoXPBFMonedaTipoCuenta(cuentaLink, long(tipoCuenta) , long(monedaCuenta))
        #self.jtsSaldo=saldo.getJtsOid()
        
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
        operRequest.addParameter("BIN", var_bin)
        
        return operRequest

        
    def createResponse(self, operResponse):
        
        self.basicCreateResponse()
        self.posMessage.setAuthorizationIdentificationResponse(self.getAuthorizationNumber())
        codRetorno = operResponse.getResult("COD_RETORNO")
        if codRetorno == None :
            raise POSException(999, "Error al crear la respuesta, el parámetro de salida de la operación (COD_RETORNO) es null.")
        
        #Obtengo datos retornados de la Operacion 8911
        if codRetorno == 99:
            self.posMessage.setResponseCode(76) #No existe la cuenta
            self.posMessage.setC44("2-00000000000-00000000000")
            self.posMessage.setFechaAlta("00000000")
        else:
            jtsSaldo = operResponse.getResult("JTS_OID")
            estadoCuenta = operResponse.getResult("ESTADO_CUENTA")
            if estadoCuenta == "1":
                self.posMessage.setResponseCode(5)
                self.posMessage.setC44("2-00000000000-00000000000")
                self.posMessage.setFechaAlta("00000000")
            else:
                self.posMessage.setResponseCode(int(codRetorno))
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
                monedaCuenta = operResponse.getResult("MONEDA_CUENTA")
                cuenta = operResponse.getResult("CUENTA")
                fechaAlta = operResponse.getResult("FECHA_APERTURA")
                #Seteamos campos requeridos en CDS - 887
                self.posMessage.setC52("                ")
                self.posMessage.setC90(" ")
                self.posMessage.setC95("000000000000000000000000000000000000000000")
                self.posMessage.setC122("00000000000")
                self.posMessage.setC123("00000000000 ")
                self.posMessage.setFechaAlta(fechaAlta)
                #Obtengo el jts_oid
                jts_oid = long(jtsSaldo)
                #Array de los ultimos 10 mov
                listaMovimientos = self.consultaMov.get(jts_oid,10)
                #tomaAcre = True
                tomaAcre = 1
                movimientos = []
                #Recorro la lista de mov
                for mov in listaMovimientos :
                    movimiento = Movimiento(mov.getConcepto())
                    movimientos.append(movimiento)
                #Sino tiene moviemientos retorno codigo 86
                if len(listaMovimientos) == 0:
                    self.posMessage.setResponseCode(86)
                    codRetorno=86
                else:
                    self.posMessage.setListaUltimosMovimientos(movimientos,saldoContable,saldoDisponible)
        tipoMensaje = self.posMessage.getMessageType()
        #Log.debug(codRetorno)

        if tipoMensaje == "0200" :
            if codRetorno == 0 :
                self.posMessage.setMessageType("0215")
            else :
                self.posMessage.setMessageType("0210")
        else :
            self.posMessage.setMessageType("0230")
        
        #Seteo campos para NBCHSEG-7265
        #self.posMessage.setC122("00000000000")
        #self.posMessage.setC123("00000000000 ")
        return self.posMessage.getPosMessage()
        
    def createErrorResponse(self, failedService):
        
        self.basicCreateResponse()
        
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))
        #self.posMessage.setResponseCode(0)
        
        return self.posMessage.getPosMessage()
        
    def basicCreateResponse(self):
        
        
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
        #self.posMessage.removeBodyElement(38) 
        #self.posMessage.removeBodyElement(48) 
        self.posMessage.removeBodyElement(50) 
        self.posMessage.removeBodyElement(51) 
        #self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(53) 
        self.posMessage.removeBodyElement(62) 
        #self.posMessage.removeBodyElement(90) 
        self.posMessage.removeBodyElement(98) 
        #self.posMessage.removeBodyElement(127) 
        
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber