# -*- coding: latin-1 -*-
# package topsystems.pos.core
# Python imports
from topsystems.pos.processor import PosService
from topsystems.pos.core.LINK.PosMessage import PosMessage

class Validacion_Msj_Existente(PosService):



    def __init__(self, msjObtenido):
        self.codret = 0
        self.msjObtenido = msjObtenido
        
        
        #posMessage = PosMessage(msjObtenido,self.context)
        # tipo de mensaje
        #tipoMensaje = posMessage.getMessageType()
        

    def preExecute(self):
    
        if self.msjObtenido != None :
                    self.codret = "00"
                    return 0
       # elif tipoMensaje == "0220" :
        #            self.codret=="00"
         #           return 0
                        
        else :
                    return 1

    def postExecute(self):
        pass
    
    def getErrorCode(self):
        return self.codret
    
    def getServiceName(self):
        return "Validacion_Msj_Existente"