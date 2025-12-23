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
from topsystems.pos.service import PosServiceValidezTarjeta
from topsystems.pos.service import PosServiceValidacionCuentaConOrdinal
from topsystems.pos.service import PosServiceValidacionCuenta
from topsystems.pos.service import RelacionTarjetaCuenta
#from topsystems.pos.service import PosServiceCantidadRetiros
from topsystems.pos.service import PosServiceLimiteOperativas
from topsystems.pos.core import AuthorizationNumberGenerator
from topsystems.pos.core import PosUltimosMovimientos
from topsystems.util.log import Log
from topsystems.pos.core.operation import DummyRequest
from topsystems.pos.core import PosConsultaSaldos
from java.sql import Timestamp
# jython import
from topsystems.pos.core.LINK.PosMessage import PosMessage
from topsystems.pos.core.LINK.CrossReferences import BasicCross
from topsystems.pos.core.LINK.PosMessage import Movimiento

class Mensaje_Ult_Mov(MessageDefinition):

    def __init__(self, isoMessage, context):
        self.context = context        
        self.posMessage = PosMessage(isoMessage, context)
        self.cross = BasicCross()
        self.authorizationNumber = -1
        self.consultaMov = PosUltimosMovimientos()
        self.consultaSaldos = PosConsultaSaldos()

        #tarjeta = self.context.getTarjeta()
        #Log.debug("TARJETA:" + tarjeta)

    def getServices(self, services):
        services.add(PosServiceValidezTarjeta(self.context, self.posMessage.getCardNumber(), self.posMessage.getLocalTransactionDate()))

    def createRequest(self):

        cuentaOrigen = self.posMessage.getFromAccount()
        moneda = self.posMessage.getCurrencyCode()
        monedaCuenta = self.cross.map("CurrencyCode", moneda)
        Log.debug("MONEDA:" + monedaCuenta.toString() + "CUENTA:" + cuentaOrigen)
        #monedaCuenta = 1 
        #jtsOid = self.context.getRelacionTarjetaCuenta().getSaldoJtsOid()
        #Log.debug("JTSSSS:")
        #Log.debug(jtsOid)
        tipoCuenta = self.posMessage.getDebitAccount()
        #tipoCuenta = 0
        cuentasRel = self.context.getRelacionesCuentasTarjeta()
        #cuentasRel = []
        for cue in cuentasRel :
            Log.debug("AAA")
            Log.debug(cue.getSaldo().getCuenta().toString())
        
        #Log.debug(cuentaLink)
        saldo = self.context.getSaldoXTarjetaCuentaMonedaTipoCuenta(long(cuentaOrigen), tipoCuenta , long(monedaCuenta))
        Log.debug("JTSSSS:")
        Log.debug(saldo.getJtsOid())
        request = DummyRequest()
        self.jtsSaldo=saldo.getJtsOid()
        Log.debug("JTSSSS:" + jtsSaldo.toString())
        #self.jtsSaldo=43081 
        return request
 
        
        
    def createResponse(self, operResponse):
        
        self.basicCreateResponse()
        self.posMessage.setAuthorizationIdentificationResponse(self.getAuthorizationNumber())
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", PosReturnCodes.OK))
        #obtengo el jts_oid
        jts_oid=long(self.jtsSaldo)
        #Array de los ultimos 10 mov
        listaMovimientos=self.consultaMov.get(jts_oid,10)
        #tomaAcre = True
        tomaAcre = 1
        #Traigo los disponibles  y contables
        disponibilidad = self.consultaSaldos.getDisponibilidad(int(jts_oid), Timestamp(self.posMessage.getLocalTransactionDate().getTime()), self.context.getTarjeta(), tomaAcre)
        saldoContable   = disponibilidad.getSaldo_contable()
        saldoDisponible = disponibilidad.getSaldo_disponible()
        movimientos = []
        #Recorro la lista de mov
        for mov in listaMovimientos :
            movimiento = Movimiento(mov.getConcepto())
            movimientos.append(movimiento)
        #self.posMessage.setListaUltimosMovimientos(movimientos,0,0)
        self.posMessage.setC44('252-00000000000-00000000000')
        self.posMessage.setC54('0')
        #Sino tiene moviemientos retorno codigo 86
        if len(listaMovimientos) == 0:
            self.posMessage.setResponseCode(86)
        self.posMessage.setListaUltimosMovimientos(movimientos,saldoContable,saldoDisponible)
        
        
        return self.posMessage.getPosMessage()
        
    def createErrorResponse(self, failedService):
        
        self.basicCreateResponse()
        
        self.posMessage.setResponseCode(self.cross.map("ReturnCode", failedService.getErrorCode()))
        #self.posMessage.setResponseCode(0)
        
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
        self.posMessage.removeBodyElement(15) 
        self.posMessage.removeBodyElement(16) 
        self.posMessage.removeBodyElement(17) 
        self.posMessage.removeBodyElement(18) 
        self.posMessage.removeBodyElement(22) 
        self.posMessage.removeBodyElement(24) 
        self.posMessage.removeBodyElement(25) 
        self.posMessage.removeBodyElement(29) 
        self.posMessage.removeBodyElement(31) 
        self.posMessage.removeBodyElement(32) 
        self.posMessage.removeBodyElement(35) 
        self.posMessage.removeBodyElement(37) 
        self.posMessage.removeBodyElement(41) 
        self.posMessage.removeBodyElement(42) 
        self.posMessage.removeBodyElement(43) 
        self.posMessage.removeBodyElement(50) 
        self.posMessage.removeBodyElement(51) 
        self.posMessage.removeBodyElement(52) 
        self.posMessage.removeBodyElement(53) 
        self.posMessage.removeBodyElement(90) 
        self.posMessage.removeBodyElement(98) 
        self.posMessage.removeBodyElement(102)
        self.posMessage.removeBodyElement(103)
    def getAuthorizationNumber(self):
        if self.authorizationNumber == -1 :
            ang = AuthorizationNumberGenerator()
            self.authorizationNumber = ang.getNext()
            
        return self.authorizationNumber