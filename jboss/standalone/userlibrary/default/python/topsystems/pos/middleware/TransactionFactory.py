# package topsystems.pos.core;

# Java imports
from topsystems.pos.core import POSException
from java.lang import Integer
from java.lang import Long

# jython import

# Hago que se recargue el reloader para reinicar todos los que ya tengo importados
from topsystems.pos.core.Reloader import unloadModules
unloadModules()

from topsystems.pos.core.PosMessage import PosMessage
from topsystems.pos.middleware.Mensaje0200_Autorizacion import Mensaje0200_Autorizacion
from topsystems.pos.middleware.Mensaje0200_CambioPIN import Mensaje0200_CambioPIN
from topsystems.pos.core.Mensaje_Desconocido import Mensaje_Desconocido

def getTransactionDefinition (message, context):
    
    posMessage = PosMessage(message, context)

    # tipo de mensaje
    tipoMensaje = posMessage.getMessageType()

    # tipo de accion
    codigoProcesamiento = posMessage.getTransactionCode()
    
    if tipoMensaje == "0200" :        
        
        if codigoProcesamiento == "36" :
            transDefinition = Mensaje0200_Autorizacion(message, context)
            
        elif codigoProcesamiento == "33" :            
            transDefinition = Mensaje0200_CambioPIN(message, context)
            
        else:
            transDefinition = Mensaje_Desconocido(message, context)

    else:
        transDefinition = Mensaje_Desconocido(message, context)
    
    return transDefinition