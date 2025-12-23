# package topsystems.pos.core;

# Java imports
from topsystems.pos.core import POSException
from java.lang import Integer
from java.lang import Long


# jython import

# Hago que se recargue el reloader para reinicar todos los que ya tengo importados
#import topsystems.pos.core.Reloader
#reload(topsystems.pos.core.Reloader)
#Se comenta por excepcion de rafaga de msj por parte de LINK
#from topsystems.pos.core.Reloader import unloadModules
#unloadModules()

from topsystems.pos.core.LINK.PosMessage import PosMessage

from topsystems.pos.core.LINK.Mensaje_Desconocido import Mensaje_Desconocido 
#### MENSAJES 0200 / 0220
from topsystems.pos.core.LINK.Mensaje0200_Consulta import Mensaje0200_Consulta
from topsystems.pos.core.LINK.Mensaje0200_Ult_Mov import Mensaje0200_Ult_Mov
from topsystems.pos.core.LINK.Mensaje0200_Retiro import Mensaje0200_Retiro
from topsystems.pos.core.LINK.Mensaje0200_Deposito import Mensaje0200_Deposito
from topsystems.pos.core.LINK.Mensaje0200_Compras import Mensaje0200_Compras
from topsystems.pos.core.LINK.Mensaje0200_Devoluciones import Mensaje0200_Devoluciones
from topsystems.pos.core.LINK.Mensaje0200_Anulacion import Mensaje0200_Anulacion
from topsystems.pos.core.LINK.Mensaje0200_Cash_Back import Mensaje0200_Cash_Back
from topsystems.pos.core.LINK.Mensaje0200_Pago_Servicio_Aut import Mensaje0200_Pago_Servicio_Aut
from topsystems.pos.core.LINK.Mensaje0200_Pago_Servicio_Dem import Mensaje0200_Pago_Servicio_Dem
from topsystems.pos.core.LINK.Mensaje0200_Pago_Tarjeta import Mensaje0200_Pago_Tarjeta
from topsystems.pos.core.LINK.Mensaje0200_Compras_Cel import Mensaje0200_Compras_Cel
#from topsystems.pos.core.LINK.Mensaje0200_ConsultaPagos import Mensaje0200_ConsultaPagos
from topsystems.pos.core.LINK.Mensaje0200_Tipo_Cambio import Mensaje0200_Tipo_Cambio
from topsystems.pos.core.LINK.Mensaje0200_Transferencias import Mensaje0200_Transferencias
from topsystems.pos.core.LINK.Mensaje0200_Prestamos import Mensaje0200_Prestamos
from topsystems.pos.core.LINK.Mensaje0200_Transferencias_CBU import Mensaje0200_Transferencias_CBU
from topsystems.pos.core.LINK.Mensaje0200_Transferencias_inm_debin import Mensaje0200_Transferencias_inm_debin

from topsystems.pos.core.LINK.Mensaje0200_Consulta_Plazo_Fijo import Mensaje0200_Consulta_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0200_Taza_Plazo_Fijo import Mensaje0200_Taza_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0200_Susp_Renov_Plazo_Fijo import Mensaje0200_Susp_Renov_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0200_Pre_Cancelacion_Plazo_Fijo import Mensaje0200_Pre_Cancelacion_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0200_Constitucion_Plazo_Fijo import Mensaje0200_Constitucion_Plazo_Fijo



#### Reversas
from topsystems.pos.core.LINK.Mensaje0420_Sospechoza_Retiros import Mensaje0420_Sospechoza_Retiros
from topsystems.pos.core.LINK.Mensaje0420_Consulta import Mensaje0420_Consulta
from topsystems.pos.core.LINK.Mensaje0420_Ult_Mov import Mensaje0420_Ult_Mov
from topsystems.pos.core.LINK.Mensaje0420_Retiros import Mensaje0420_Retiros
from topsystems.pos.core.LINK.Mensaje0420_Deposito import Mensaje0420_Deposito
from topsystems.pos.core.LINK.Mensaje0420_Compras import Mensaje0420_Compras
from topsystems.pos.core.LINK.Mensaje0420_Devoluciones import Mensaje0420_Devoluciones
from topsystems.pos.core.LINK.Mensaje0420_Anulacion import Mensaje0420_Anulacion
from topsystems.pos.core.LINK.Mensaje0420_Cash_Back import Mensaje0420_Cash_Back
from topsystems.pos.core.LINK.Mensaje0420_Pago_Servicio_Aut import Mensaje0420_Pago_Servicio_Aut
from topsystems.pos.core.LINK.Mensaje0420_Pago_Servicio_Dem import Mensaje0420_Pago_Servicio_Dem
from topsystems.pos.core.LINK.Mensaje0420_Pago_Tarjeta import Mensaje0420_Pago_Tarjeta
from topsystems.pos.core.LINK.Mensaje0420_Compras_Cel import Mensaje0420_Compras_Cel
#from topsystems.pos.core.LINK.Mensaje0420_ConsultaPagos import Mensaje0420_Pago_Servicio_Dem
from topsystems.pos.core.LINK.Mensaje0420_Tipo_Cambio import Mensaje0420_Tipo_Cambio
from topsystems.pos.core.LINK.Mensaje0420_Transferencias import Mensaje0420_Transferencias
from topsystems.pos.core.LINK.Mensaje0420_Prestamos import Mensaje0420_Prestamos
from topsystems.pos.core.LINK.Mensaje0420_Transferencias_CBU import Mensaje0420_Transferencias_CBU
from topsystems.pos.core.LINK.Mensaje0420_Transferencias_inm_debin import Mensaje0420_Transferencias_inm_debin

#SPRINT 6
from topsystems.pos.core.LINK.Mensaje0420_Consulta_Plazo_Fijo import Mensaje0420_Consulta_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0420_Taza_Plazo_Fijo import Mensaje0420_Taza_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0420_Susp_Renov_Plazo_Fijo import Mensaje0420_Susp_Renov_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0420_Pre_Cancelacion_Plazo_Fijo import Mensaje0420_Pre_Cancelacion_Plazo_Fijo
from topsystems.pos.core.LINK.Mensaje0420_Constitucion_Plazo_Fijo import Mensaje0420_Constitucion_Plazo_Fijo
#SPRINT 6

from topsystems.util.log import Log

def getTransactionDefinition (message, context):
    
    posMessage = PosMessage(message, context)

    # tipo de mensaje
    tipoMensaje = posMessage.getMessageType()

    # tipo de accion
    codigoProcesamiento = posMessage.getTransactionCode()
    codigoReversa = posMessage.getResponseCode()

    #Log.debug(tipoMensaje)
    #Log.debug(codigoReversa)
    #Log.debug(codigoProcesamiento)

    if tipoMensaje == "0200" :
        if codigoProcesamiento == "01" :
            transDefinition = Mensaje0200_Retiro(message, context)
        elif codigoProcesamiento == "18" :
            transDefinition = Mensaje0200_Constitucion_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "21" :
            transDefinition = Mensaje0200_Deposito(message, context)
        elif codigoProcesamiento == "28" :
            transDefinition = Mensaje0200_Pre_Cancelacion_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "31" :
            transDefinition = Mensaje0200_Consulta(message, context)
        elif codigoProcesamiento == "37" :
            transDefinition = Mensaje0200_Taza_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "38" :
            transDefinition = Mensaje0200_Consulta_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "68" :
            transDefinition = Mensaje0200_Susp_Renov_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "71" :
            transDefinition = Mensaje0200_Compras(message, context)
        elif codigoProcesamiento == "72" :
            transDefinition = Mensaje0200_Anulacion(message, context)
        elif codigoProcesamiento == "74" :
            transDefinition = Mensaje0200_Devoluciones(message, context)
        elif codigoProcesamiento == "75" :
            transDefinition = Mensaje0200_Anulacion(message, context)
        elif codigoProcesamiento == "76" :
            transDefinition = Mensaje0200_Cash_Back(message, context)
        elif codigoProcesamiento == "77" :
            transDefinition = Mensaje0200_Anulacion(message, context)
        elif codigoProcesamiento == "94" :
            transDefinition = Mensaje0200_Ult_Mov(message, context)
        elif codigoProcesamiento == "17" :
            transDefinition = Mensaje0200_Compras_Cel(message, context)
        #elif codigoProcesamiento == "69" :
        #    transDefinition = Mensaje0200_Consulta_Pagos(message, context)
        elif codigoProcesamiento == "81" :
            transDefinition = Mensaje0200_Pago_Servicio_Aut(message, context)
        elif codigoProcesamiento == "88" :
            transDefinition = Mensaje0200_Pago_Tarjeta(message, context)
        elif codigoProcesamiento == "90" :
            transDefinition = Mensaje0200_Pago_Servicio_Dem(message, context)
        elif codigoProcesamiento == "35" :
            transDefinition = Mensaje0200_Tipo_Cambio(message, context)
        elif codigoProcesamiento == "40" :
            transDefinition = Mensaje0200_Transferencias(message, context)
        elif codigoProcesamiento == "2P" :
            transDefinition = Mensaje0200_Prestamos(message, context)
        elif codigoProcesamiento == "09" or codigoProcesamiento == "29" or codigoProcesamiento == "F3" or codigoProcesamiento == "F4" :
            transDefinition = Mensaje0200_Transferencias_inm_debin(message, context)
        elif codigoProcesamiento == "1B" :
            transDefinition = Mensaje0200_Transferencias_CBU(message, context)
        else :
            transDefinition = Mensaje_Desconocido(message, context) #Log.debug("Mensaje Descononosido 0200")

    elif tipoMensaje == "0220" or tipoMensaje == "0221":
        if codigoProcesamiento == "01" :
            transDefinition = Mensaje0200_Retiro(message, context)
        elif codigoProcesamiento == "21" :
            transDefinition = Mensaje0200_Deposito(message, context)
        #elif codigoProcesamiento == "18" :
        #    transDefinition = Mensaje0200_Constitucion_Plazo_Fijo(message, context)
        #elif codigoProcesamiento == "28" :
        #    transDefinition = Mensaje0200_Pre_Cancelacion_Plazo_Fijo(message, context)
        #elif codigoProcesamiento == "37" :
        #    transDefinition = Mensaje0200_Taza_Plazo_Fijo(message, context)
        #elif codigoProcesamiento == "38" :
        #    transDefinition = Mensaje0200_Consulta_Plazo_Fijo(message, context)
        #elif codigoProcesamiento == "68" :
        #    transDefinition = Mensaje0200_Susp_Renov_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "71" :
            transDefinition = Mensaje0200_Compras(message, context)
        elif codigoProcesamiento == "72" :
            transDefinition = Mensaje0200_Anulacion(message, context)
        elif codigoProcesamiento == "74" :
            transDefinition = Mensaje0200_Devoluciones(message, context)
        elif codigoProcesamiento == "75" :
            transDefinition = Mensaje0200_Anulacion(message, context)
        elif codigoProcesamiento == "76" :
            transDefinition = Mensaje0200_Cash_Back(message, context)
        elif codigoProcesamiento == "77" :
            transDefinition = Mensaje0200_Anulacion(message, context)
        elif codigoProcesamiento == "94" :
            transDefinition = Mensaje0200_Ult_Mov(message, context)
        elif codigoProcesamiento == "17" :
            transDefinition = Mensaje0200_Compras_Cel(message, context)
        #elif codigoProcesamiento == "69" :
        #    transDefinition = Mensaje0200_Consulta_Pagos(message, context)
        elif codigoProcesamiento == "81" :
            transDefinition = Mensaje0200_Pago_Servicio_Aut(message, context)
        elif codigoProcesamiento == "88" :
            transDefinition = Mensaje0200_Pago_Tarjeta(message, context)
        elif codigoProcesamiento == "90" :
            transDefinition = Mensaje0200_Pago_Servicio_Dem(message, context)
        elif codigoProcesamiento == "35" :
            transDefinition = Mensaje0200_Tipo_Cambio(message, context)
        elif codigoProcesamiento == "40" :
            transDefinition = Mensaje0200_Transferencias(message, context)
        elif codigoProcesamiento == "2P" :
            transDefinition = Mensaje0200_Prestamos(message, context)
        elif codigoProcesamiento == "09" or codigoProcesamiento == "29" or codigoProcesamiento == "F3" or codigoProcesamiento == "F4" :
            transDefinition = Mensaje0200_Transferencias_inm_debin(message, context)
        elif codigoProcesamiento == "1B" :
            transDefinition = Mensaje0200_Transferencias_CBU(message, context)
        else :
            transDefinition = Mensaje_Desconocido(message, context) #Log.debug("Mensaje Descononosido 0220")

    elif (tipoMensaje == "0420" or tipoMensaje == "0421") and codigoReversa != "68" :
        if codigoProcesamiento == "01" :
            if codigoReversa == "22":
                transDefinition = Mensaje0420_Sospechoza_Retiros(message, context) # Reversa Sospechoza.
            elif codigoReversa == "32":
                transDefinition = Mensaje0200_Retiro(message, context) # Reversa Parcial.
            else :
                transDefinition = Mensaje0420_Retiros(message, context) # Otras Reversas.
        elif codigoProcesamiento == "18" :
            transDefinition = Mensaje0420_Constitucion_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "21" :
            transDefinition = Mensaje0420_Deposito(message, context)
        elif codigoProcesamiento == "28" :
            transDefinition = Mensaje0420_Pre_Cancelacion_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "31" :
            transDefinition = Mensaje0420_Consulta(message, context)
        elif codigoProcesamiento == "37" :
            transDefinition = Mensaje0420_Taza_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "38" :
            transDefinition = Mensaje0420_Consulta_Plazo_Fijo(message, context)
        elif codigoProcesamiento == "68" :
            transDefinition = Mensaje0420_Susp_Renov_Plazo_Fijo(message, context)   
        elif codigoProcesamiento == "71" :
            transDefinition = Mensaje0420_Compras(message, context)
        elif codigoProcesamiento == "72" :
            transDefinition = Mensaje0420_Anulacion(message, context)
        elif codigoProcesamiento == "74" :
            transDefinition = Mensaje0420_Devoluciones(message, context)
        elif codigoProcesamiento == "75" :
            transDefinition = Mensaje0420_Anulacion(message, context)
        elif codigoProcesamiento == "76" :
            transDefinition = Mensaje0420_Cash_Back(message, context)
        elif codigoProcesamiento == "77" :
            transDefinition = Mensaje0420_Anulacion(message, context)
        elif codigoProcesamiento == "94" :
            transDefinition = Mensaje0420_Ult_Mov(message, context)
        elif codigoProcesamiento == "17" :
            transDefinition = Mensaje0420_Compras_Cel(message, context)
        #elif codigoProcesamiento == "69" :
        #    transDefinition = Mensaje0420_Consulta_Pagos(message, context)
        elif codigoProcesamiento == "81" :
            transDefinition = Mensaje0420_Pago_Servicio_Aut(message, context)
        elif codigoProcesamiento == "88" :
            transDefinition = Mensaje0420_Pago_Tarjeta(message, context)
        elif codigoProcesamiento == "90" :
            transDefinition = Mensaje0420_Pago_Servicio_Dem(message, context)
        elif codigoProcesamiento == "35" :
            transDefinition = Mensaje0420_Tipo_Cambio(message, context)
        elif codigoProcesamiento == "40" :
            transDefinition = Mensaje0420_Transferencias(message, context)
        elif codigoProcesamiento == "2P" :
            transDefinition = Mensaje0420_Prestamos(message, context)
        elif codigoProcesamiento == "09" or codigoProcesamiento == "29" or codigoProcesamiento == "F3" or codigoProcesamiento == "F4" :
            transDefinition = Mensaje0420_Transferencias_inm_debin(message, context)
        elif codigoProcesamiento == "1B" :
            transDefinition = Mensaje0420_Transferencias_CBU(message, context)
            
        else :
            transDefinition = Mensaje_Desconocido(message, context) #Log.debug("Mensaje Descononosido 0420")
    elif (tipoMensaje == "0420" or tipoMensaje == "0421") and codigoReversa == "68" :
        transDefinition = Mensaje0420_Retiros(message, context)
    else:
        transDefinition = Mensaje_Desconocido(message, context)#Log.debug("Mensaje Descononosido")
    
    return transDefinition