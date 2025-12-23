# package topsystems.pos.core;

# Java imports
from topsystems.pos.script import PosMessageWrapper;
from topsystems.pos.protocol.base24 import B24Util
from java.lang import Long
from java.lang import Integer
from java.text import SimpleDateFormat

# Python imports
from topsystems.pos.core.LINK.CrossReferences import BasicCross
from topsystems.pos.core.Util import topazUtil
from topsystems.pos.core.Util import isoUtil
#import time

class PosMessage(PosMessageWrapper) :
    
    def __init__(self, posMessage, context):
        PosMessageWrapper.__init__(self, posMessage, context)
        self.cross = BasicCross()
        
    def getHeader(self):
        return self.getPosMessage().getMessageHeader();
    
    # cross references
    def getCross(self, key, fromValue):
        return self.cross.map(key, fromValue)

    # message type
    def getMessageType (self):
        return self.getBodyElement(0) 
    
    def setMessageType (self, messagType):
        self.setBodyElement(0, messagType) 

    # processing code
    def getProcessingCode (self):
        return self.getBodyElement(3)

    # transaction code
    def getTransactionCode (self):
        processingCode = self.getProcessingCode()
        return processingCode[0:2]

    # debit account
    def getDebitAccount (self):
        processingCode = self.getProcessingCode()
        return processingCode[2:4]

    # credit account
    def getCreditAccount (self):
        processingCode = self.getProcessingCode()
        return processingCode[4:6]

    # amount
    def getAmount (self):
        amount = self.getBodyElement(4)
        return amount[:-2] + '.' + amount[-2:]

    # trasmission date and time
    def getTrasmissionDateTime (self):
        return self.getBodyElement(7)
    
    # trasmission date
    def getTrasmissionDate (self):
        dateTime = self.getTrasmissionDateTime()
        return dateTime[0:4]
    
    # trasmission time
    def getTrasmissionTime (self):
        dateTime = self.getTrasmissionDateTime()
        return dateTime[4:10]
    
    # trace number
    def getTraceNumber (self):
        return self.getBodyElement(11)

    # local transaction time
    def getLocalTransactionTime (self):
        return self.getBodyElement(12)

    # local transaction date
    def getLocalTransactionDate (self):
        return B24Util.parseDate(self.getBodyElement(13), self.getTopazProcessDate())

    # settlement date
    def getSettlementDate (self):
        return self.getBodyElement(15)

    # capture date
    def getCaptureDate (self):
        return self.getBodyElement(17)

    # adquiring institution identification
    def getAdquiringInstitutionIdentification (self):
        return self.getBodyElement(32)
        
    # track 2
    def getTrack2 (self):
        return self.getBodyElement(35)
        
    # card number
    def getCardNumber (self):        
        substrings = self.getTrack2().split('=')
        if len(substrings) == 1 :
            substrings = self.getTrack2().split('D')
        return substrings[0]
        
    # card expiration date
    def getCardExpirationDate (self):
        substrings = self.getTrack2().split('=')
        if len(substrings) == 1 :
            substrings = self.getTrack2().split('D')
        dateAndData = substrings[1]
        return dateAndData[0:4]

    # card extra data
    def getCardExtraData (self):
        substrings = self.getTrack2().split('=')
        if len(substrings) == 1 :
            substrings = self.getTrack2().split('D')
        dateAndData = substrings[1]
        return dateAndData[4:]

    # retrieval reference number
    def getRetrievalReferenceNumber (self):
        return self.getBodyElement(37)

    # authorization identification response
    def setAuthorizationIdentificationResponse (self, authorizationIdentificationResponse):
        self.setBodyElement(38, isoUtil.zeropad(topazUtil.formatNumber(authorizationIdentificationResponse), 6))
    
    #Seteo para pasar el C38 en la respuesta 
    def set38 (self, value):
        self.setBodyElement(38, value)

    def getAuthorizationIdentificationResponse (self):
        return self.getBodyElement(38)

    # response code
    def setResponseCode (self, responseCode):
        self.setBodyElement(39, isoUtil.zeropad(Integer.toString(responseCode), 2))
        
    def getResponseCode (self):
        return self.getBodyElement(39)        

    # card acceptor terminal identification
    def getCardAcceptorTerminalIdentification (self):
        return self.getBodyElement(41)
        
    # card acceptor institution identification
    def getCardAcceptorInstitutionIdentification (self):
        return self.getBodyElement(42)
        
    # card acceptor name and place
    def getCardAcceptorNameAndPlace (self):
        return self.getBodyElement(43)
        
    # card acceptor city
    def getCardAcceptorCity (self):
        nameAndPlace = self.getCardAcceptorNameAndPlace()
        return nameAndPlace[35:38]

    # card acceptor country
    def getCardAcceptorCountry (self):
        nameAndPlace = self.getCardAcceptorNameAndPlace()
        return nameAndPlace[38:40]

    def setC44(self, value):
        self.setBodyElement(44, value)

    # accounts position
    def setAccountsPosition (self, signoC, positionCountable, signoA, positionAvailable):
        indicadorUso = "2" # Si se puede, mostrar ambos, si no, mostrar el disponible
        strSaldoContable   = '%(saldo)12s' % {'saldo': topazUtil.formatAmount(positionCountable)} 
        strSaldoDisponible = '%(saldo)12s' % {'saldo': topazUtil.formatAmount(positionAvailable)} 
        strSaldoContableSinSigno = strSaldoContable.replace("-","")
        strSaldoDisponibleSinSigno = strSaldoDisponible.replace("-","")
        strSaldoContableCortado = (strSaldoContableSinSigno[-11:]).replace(" ", "0")
        strSaldoDisponibleCortado = (strSaldoDisponibleSinSigno[-11:]).replace(" ", "0")
        accountsPosition = indicadorUso + signoC + strSaldoContableCortado + signoA + strSaldoDisponibleCortado
        self.setBodyElement(44, accountsPosition)
        
    # los mando en le campo 44. accounts position
    def setTiposCambio (self, tipoCambioCompra, tipoCambioVenta):
        indicadorUso = "3" # Si se puede, mostrar ambos, si no, mostrar el de compra
        strTipoCambioCompra = '%(saldo)12s' % {'saldo': topazUtil.formatAmount(tipoCambioCompra)}
        strTipoCambioVenta  = '%(saldo)12s' % {'saldo': topazUtil.formatAmount(tipoCambioVenta)} 
        tiposCambio = indicadorUso + strTipoCambioCompra + strTipoCambioVenta
        self.setBodyElement(44, tiposCambio)

    # currency code
    def getCurrencyCode (self):
        return self.getBodyElement(49)

    # PIN
    def getPIN (self):
        return self.getBodyElement(52)
    
    #Seteo para pasar el C52 en la respuesta
    def setC52(self, value):
        self.setBodyElement(52, value)
    
    def getElement54 (self):
        return self.getBodyElement(54)

    # Plazo DPF
    def getPlazoDpf(self):
        elemento54 = self.getElement54()
        plazoDpf = elemento54[0:3]
        return plazoDpf

    # Capital DPF
    def getCapitalDpf(self):
        elemento54 = self.getElement54()
        capitalDpf = elemento54[3:13]
        return capitalDpf[:-2] + '.' + capitalDpf[-2:]

    # Tipo DPF
    def getTipoDpf(self):
        elemento54 = self.getElement54()
        tipoDpf = elemento54[15:16]
        return tipoDpf

    # Pagina DPF
    def getPaginaDpf(self):
        elemento54 = self.getElement54()
        paginaDpf = elemento54.strip()
        return paginaDpf

    def getFechaDpf(self):
        elemento54 = self.getElement54()
        fechaDpf = elemento54[16:21].strip()
        return fechaDpf

    def getCertificadoDpf(self):
        elemento54 = self.getElement54()
        certificadoDpf = elemento54[23:31].strip()
        return certificadoDpf

    def getImporteDpf(self):
        elemento54 = self.getElement54()
        importeDpf = elemento54[30:83].strip().replace(".","").replace(",",".").replace("_","")
        return importeDpf

    def getAutoRenovacionDpf(self):
        elemento54 = self.getElement54()
        valAutoRenov = elemento54[14:15].strip()
        return valAutoRenov

    def getTipoRenovacionDpf(self):
        elemento54 = self.getElement54()
        tipoRenov = elemento54[13:14].strip()
        return tipoRenov
    
    # Fecha Alta de la Cuenta (NBCH)
    def setFechaAlta (self, value):
        campo = "            00000000000000000000000000000000000000"+value+"00000000000000000000000000000000000000000000"
        self.setBodyElement(54, campo)
    # Fecha Alta de la Cuenta (NBCH)
    def setC54 (self, value):
        campo = isoUtil.padright(value, 100, '0')
        self.setBodyElement(54, campo)

    def getElement55(self):
        return self.getBodyElement(55)

    def getElement126(self):
        return self.getBodyElement(126)

    def setC55(self, value):
        self.setBodyElement(55, value)
        
    # Identidad DEBIN (NBCH)    
    def getIdentidadDebin (self):
        elemento55=self.getElement55()
        IdentidadDebin=elemento55[0:32].strip()
        return IdentidadDebin
    
    # Concepto (NBCH)    
    def getConcepto (self):
        elemento55=self.getElement55()
        ConceptoTransferencia=elemento55[32:35].strip()
        return ConceptoTransferencia
    
    
    #  Concepto Transf Inmediatas(NBCH)
    def getConceptoInmediata (self):
        elemento55=self.getElement55()
        ConceptoTransferenciaInmediata=elemento55[107:111].strip()
        return ConceptoTransferenciaInmediata

    
    # Banco Comprador (NBCH)    
    def getBancoComprador (self):
        elemento55=self.getElement55()
        BancoComprador=elemento55[35:39]
        return BancoComprador
    
    # CUIT Comprador (NBCH)
    def getCuitComprador (self):
        elemento55=self.getElement55()
        CuitComprador=elemento55[39:50]
        return CuitComprador

    # CBU Comprador (NBCH)
    def getCbuComprador (self):
        elemento55=self.getElement55()
        CbuComprador=elemento55[50:72]
        return CbuComprador        

    # Cuenta Comprador (NBCH)
    def getCuentaComprador (self):
        elemento55=self.getElement55()
        CuentaComprador=elemento55[72:91]
        return CuentaComprador
        
    # Banco Vendedor (NBCH)
    def getBancoVendedor (self):
        elemento55=self.getElement55()
        BancoVendedor=elemento55[91:95]
        return BancoVendedor
    
    # CUIT Vendedor (NBCH) 
    def getCuitVendedor (self):
        elemento55=self.getElement55()
        CuitVendedor=elemento55[95:106]
        return CuitVendedor
    
    # CBU Vendedor (NBCH)
    def getCbuVendedor (self):
        elemento55=self.getElement55()
        CbuVendedor=elemento55[106:128]
        return CbuVendedor
    
    # CuentaVendedor (NBCH)
    def getCuentaVendedor (self):
        elemento55=self.getElement55()
        CuentaVendedor=elemento55[128:147]
        return CuentaVendedor

    # CUIT Comprador Inmediatas NO DEBIN(NBCH)
    def getCuitCompradorInm (self):
        elemento126=self.getElement126()
        if elemento126 == None :
                CuitComprador = "0"
        else :
                idx_q7 = elemento126.index('! Q7')
                CuitComprador= elemento126[idx_q7 + 33: idx_q7 + 44].strip()
        return CuitComprador

    # CUIT Vendedor Inmediatas NO DEBIN(NBCH)
    def getCuitVendedorInm(self):
        elemento126=self.getElement126()
        if elemento126 == None :
                CuitVendedor = "0"
        else :
                idx_pe = elemento126.index('! PE')
                CuitVendedor = elemento126[idx_pe + 27: idx_pe + 38].strip()
        return CuitVendedor

    # Evalulo mismo titular para Transferencia Inmediata (NBCH)
    def getMismoTitularTransfInm (self):
        elemento55=self.getElement55()
        MismoTitular=elemento55[40:41]
        if(MismoTitular=="N"):
            if(self.getCuitCompradorInm() == self.getCuitVendedorInm()):
                MismoTitular="S"
            else:
                MismoTitular="N"
        else:
            MismoTitular="S"
        return MismoTitular

    # Numero de Tarjeta (NBCH)
    def getNumeroTarjeta (self):
        elemento55=self.getElement55()
        NumeroTarjeta=elemento55[147:166]
        return NumeroTarjeta

    #Apellido y Nombre (NBCH)
    def getNombreApellido (self):
        elemento55=self.getElement55()
        NombreApellido=elemento55[166:206]
        return NombreApellido
    
    #Mismo Titular (NBCH)
    def getMismoTitular (self):
        elemento55=self.getElement55()
        MismoTitular=elemento55[206:207]
        if(MismoTitular=="N"):
            if(self.getCuitComprador() == self.getCuitVendedor()):
                MismoTitular="S"
            else:
                MismoTitular="N"
        else:
            MismoTitular="S"

        return MismoTitular
        
    #Debito Pre autorizado (NBCH)
    def getDebitoPreAutorizado (self):
        elemento55=self.getElement55()
        DebitoPreAutorizado=elemento55[207:208]
        return DebitoPreAutorizado
    
    #Origen D=Debin T=Tra (NBCH)
    def getOrigen_D_T (self):
        elemento55=self.getElement55()
        Origen_Debin_Tra=elemento55[208:209]
        return Origen_Debin_Tra
    
    #Scoring (NBCH)
    def getScoring (self):
        elemento55=self.getElement55()
        Scoring=elemento55[209:212]
        return Scoring
    
    #Contra Cargo (NBCH)
    def getID_ContraCargo (self):
        elemento55=self.getElement55()
        Cargo=elemento55[212:215]
        return Cargo
        
    #Motivo Contra Cargo (NBCH)
    def getContraCargo (self):
        elemento55=self.getElement55()
        ContraCargo=elemento55[215:218].strip()
        return ContraCargo        
    # 
    
    def getTerminalNetwork(self):
        terminalData = self.getBodyElement(60)
        if terminalData == None :
            raise POSException(999, "Error al obtener la red del cajero, el campo 60 es null.")
        return terminalData[4:8]
    
    #Traigo campo 62, para Constitución DPF
    def getElement62 (self):
        return self.getBodyElement(62)
    
    #getCondicional para validar si D0
    def getCondicionalCanal (self):
        elemento62=self.getElement62()
        Condicional=elemento62[0:2].strip()
        return Condicional
    
    # PIN offset
    def getNewPIN (self):
        return self.getBodyElement(63)
    
    # Indicador de OAR
    def getOARFlag (self):
        return int(self.getBodyElement(66))
    
    # Indicador de OAR
    def setOARFlag (self, value):
        self.setBodyElement(66, value)

    # Largo del PIN
    def getPINLength(self):
        if self.getBodyElement(67) == None :
            return 0
        else :
            return int(self.getBodyElement(67))

    # exchange rate
    def getExchangeRate (self):
        rate = self.getBodyElement(75)
        return rate[:-2] + '.' + rate[-2:]
    
    def setExchangeRate (self, exchangeRate):
        strExchangeRate = isoUtil.padleft(topazUtil.formatAmount(exchangeRate), 10, '0') 
        self.setBodyElement(75, strExchangeRate)

    # cross currency amount
    def getCrossCurrencyAmount (self):
        amount = self.getBodyElement(83)
        return amount[:-2] + '.' + amount[-2:]
        
    # transaction currency code
    def getTransactionCurrencyCode (self):
        valorCampo = self.getBodyElement(93)
        return valorCampo[:1]
        
    # tipo de deposito
    def getDepositType(self):
        valorCampo = self.getBodyElement(93)
        return valorCampo[3]
    
    # importe efectivamente dispensado (para las reversas)
    def getDispensedAmount(self):
        valorCampo = self.getBodyElement(95)
        if valorCampo == None : 
            return '0.0'
        else :
            return valorCampo[:10] + '.' + valorCampo[10:12] 
    
    # receiving institution code        
    def getReceivingInstitutionCode (self):
        return self.getBodyElement(100)

    # pan
    def getPAN (self):
        return self.getBodyElement(2)

    # from account
    def getFromAccount(self):
        fromAccount = self.getBodyElement(102)
        if fromAccount == None or fromAccount.strip() == "" :
            fromAccount = 0
        else :           
            fromAccount = fromAccount  
        return fromAccount
    
    def setFromAccount(self, accountNumber):
        self.setBodyElement(102, str(accountNumber))
        
    # to account
    def getToAccount(self):
        toAccount = self.getBodyElement(103)
        if toAccount == None or toAccount.strip() == "" :
            toAccount = 0
        else :            
            toAccount = toAccount
        return toAccount

    def setToAccount(self, accountNumber):
        self.setBodyElement(103, str(accountNumber))

    # to account 
    def getToAccountAsString(self):
        return self.getBodyElement(103)
        
    # codigo de compra
    def getBuyingType(self):
        buyingData = self.getToAccountAsString()
        return buyingData[8:10]

    # item comprado
    def getBuyingItem(self):
        buyingData = self.getToAccountAsString()
        return buyingData[0:8]

    # referencia compra
    def getBuyingReference(self):
        buyingData = self.getToAccountAsString()
        return buyingData[10:19]

    # impuestos 
    def getImpuestosData(self):
        return self.getBodyElement(105)
        
    # Importe total por Impuesto y Percepci�n
    def getImpPerc(self):
        ImpPerc = self.getImpuestosData()
        valorImpPerc = ImpPerc[0:12]
        return valorImpPerc[:-2] + '.' + valorImpPerc[-2:] 

    # Tipo Cambio Aplicado (Vendedor)
    def getImpuestoCambio(self):
        ImpuestoCambio = self.getImpuestosData()
        valorImpuestoCambio = ImpuestoCambio[12:19]
        return valorImpuestoCambio[:-2] + '.' + valorImpuestoCambio[-2:] 

    # Porcentaje Total Impuesto-Percepci�n
    def getImpuestoPorcent(self):
        ImpuestoPorcent = self.getImpuestosData()
        valorImpuestoPorcent = ImpuestoPorcent[20:24]
        return valorImpuestoPorcent[:-2] + '.' + valorImpuestoPorcent[-2:] 

    # tipo Cambio 
    def getTipoCambioData(self):
        return self.getBodyElement(127)

    def getElement121(self):
        return self.getBodyElement(121)
        
    # tipo Cambio tipo Solicitud
    def getTipoConsultaTipoCambio(self):
        valAux = self.getTipoCambioData()
        val1 = valAux[0:1]
        return val1

    def setC127(self,value0,value1,value2):
        val1=str(int(value1*1000))
        val2=str(int(value2*1000))
        campo = value0+val1.zfill(8)+val2.zfill(8)+"00000000000000000000000"
        self.setBodyElement(127, campo)

    # TERM-NAME-LOC
    def getTermNameLoc(self):
        return self.getBodyElement(120)
    
    # Si el cajero es del NBC
    def getEsCajeroInterno(self):
        if self.getAdquiringInstitutionIdentification() == "28" : # NBC
            return 1
        else :
            return 0

    def setC90(self, value):
        self.setBodyElement(90, value)

    def setC95(self, value):
        self.setBodyElement(95, value)

    def setC122(self, value):
        self.setBodyElement(122, value)

    def setC123(self, value):
        self.setBodyElement(123, value)

    def setC125(self, value):
        self.setBodyElement(125, value)

    def setC126(self, value):
        self.setBodyElement(126, value)
       
    # Setea el campo 125 con las cuentas de origen y destino en formato Banred    
    def setListaCuentasBanred(self, cuentasOrigen, cuentasDestino):
        cantidadMaximaCuentas = 5
         
        strCuentasOrigen = ""
        yaProcesadas = 0
        # Cuentas de origen
        for c in cuentasOrigen:
            cuenta = '%(num)-19d' % {'num': long(c.cuenta)}
            strCuentasOrigen = strCuentasOrigen + cuenta            
            yaProcesadas = yaProcesadas + 1            
            if yaProcesadas >= cantidadMaximaCuentas:
                break            
        # Si vinieron menos cuentas de las que pueden ir en el campo, completo con blancos
        strCuentasOrigen = strCuentasOrigen.ljust(cantidadMaximaCuentas*19) # isoUtil.padright(strCuentasOrigen, cantidadMaximaCuentas*19, ' ')
        
        strCuentasDestino = ""
        yaProcesadas = 0
        # Cuentas de origen
        for c in cuentasDestino:
            cuenta = '%(num)-19d' % {'num': long(c.cuenta)}
            strCuentasDestino = strCuentasDestino + cuenta            
            yaProcesadas = yaProcesadas + 1            
            if yaProcesadas >= cantidadMaximaCuentas:
                break            
        # Si vinieron menos cuentas de las que pueden ir en el campo, completo con blancos
        strCuentasDestino = strCuentasDestino.ljust(cantidadMaximaCuentas*19) # isoUtil.padright(strCuentasDestino, cantidadMaximaCuentas*19, ' ')
        
        descripcionCuentasOrigen = ""
        yaProcesadas = 0
        # Cuentas de origen
        for c in cuentasOrigen:
            descripcionMoneda = self.getCross("CurrencyDescription", Integer(c.moneda))
            if descripcionMoneda == None :
                #print "No se pudo obtener la descripci�n correspondiente a la moneda '" , c.moneda, "'."
                raise POSException(999, "No se pudo obtener la descripci�n correspondiente a la moneda '" +c.moneda+ "'.")
            descripcionCuenta = '%(descMon)-8s' % {'descMon': descripcionMoneda} # Como descripci�n pongo la descripci�n de la moneda 
            descripcionCuentasOrigen = descripcionCuentasOrigen + descripcionCuenta            
            yaProcesadas = yaProcesadas + 1            
            if yaProcesadas >= cantidadMaximaCuentas:
                break            
        # Si vinieron menos cuentas de las que pueden ir en el campo, completo con blancos
        descripcionCuentasOrigen = isoUtil.padright(descripcionCuentasOrigen, cantidadMaximaCuentas*8, ' ')   
             
        descripcionCuentasDestino = ""
        yaProcesadas = 0
        # Cuentas de origen
        for c in cuentasDestino:
            descripcionMoneda = self.getCross("CurrencyDescription", Integer(c.moneda))
            if descripcionMoneda == None :
                raise POSException(999, "No se pudo obtener la descripci�n correspondiente a la moneda '" +c.moneda+ "'.")
            descripcionCuenta = '%(descMon)-8s' % {'descMon': descripcionMoneda} # Como descripci�n pongo la descripci�n de la moneda
            descripcionCuentasDestino = descripcionCuentasDestino + descripcionCuenta   
            yaProcesadas = yaProcesadas + 1            
            if yaProcesadas >= cantidadMaximaCuentas:
                break            
        # Si vinieron menos cuentas de las que pueden ir en el campo, completo con blancos
        descripcionCuentasDestino = isoUtil.padright(descripcionCuentasDestino, cantidadMaximaCuentas*8, ' ')
        
        resultado = strCuentasOrigen + strCuentasDestino + descripcionCuentasOrigen + descripcionCuentasDestino
        self.setBodyElement(125, resultado)

    # Setea el campo 125 con la informaci�n de la lista de cuentas en formato del Middleware para Acceso Directo 
    def setListaCuentasMiddlewareAD(self, permiso, cuentas):
        cantidadMaximaCuentas = 99
        if len(cuentas) > cantidadMaximaCuentas:
            raise POSException(999, "Error al procesar el campo 125, se exedi� la cantidad m�xima de cuentas")
         
        resultado = ""
        
        resultado = resultado + permiso
        
        cantidadDeCuentas = '%(num)02d' % {'num': len(cuentas)}
        resultado = resultado + cantidadDeCuentas
         
        # Proceso las cuentas de la lista
        for c in cuentas:
            sucursal  = '%(num)03d' % {'num': c.sucursal} 
            producto  = '%(num)05d' % {'num': c.producto} 
            moneda    = '%(num)04d' % {'num': c.moneda}  
            cuenta    = '%(num)012d' % {'num': c.cuenta}
            operacion = '%(num)012d' % {'num': c.operacion} 
            ordinal   = '%(num)03d' % {'num': c.ordinal}
                                          
            infoCuenta = sucursal + producto + moneda + cuenta + operacion + ordinal
            resultado = resultado + infoCuenta

        tipoCliente = "00"
        resultado = resultado + tipoCliente
        
        tipoServicio = "N"
        resultado = resultado + tipoServicio
            
        self.setBodyElement(125, resultado)
        
    # Setea el campo 125 con la informaci�n de la lista de cuentas en formato del Middleware para Banred 
    def setListaCuentasMiddlewareBanred(self, cuentas):
        cantidadMaximaCuentas = 10
        if len(cuentas) > cantidadMaximaCuentas:
            raise POSException(999, "Error al procesar el campo 125, se exedi� la cantidad m�xima de cuetnas")
         
        resultado = ""
        # Proceso las cuentas de la lista
        for c in cuentas:
            dependencia = '%(num)03d' % {'num': c.sucursal} #isoUtil.padleft(Integer.toString(c.sucursal), 3, '0')
            producto    = '%(num)03d' % {'num': c.producto}    #isoUtil.padleft(Integer.toString(c.producto), 3, '0') 
            subproducto = '%(num)03d' % {'num': c.moneda} #isoUtil.padleft(Integer.toString(c.moneda), 3, '0') 
            cuenta      = '%(num)010d' % {'num': c.cuenta}     #isoUtil.padleft(Integer.toString(c.cuenta), 10, '0')
                                          
            infoCuenta = dependencia + producto + subproducto + cuenta
            resultado = resultado + infoCuenta
            
        # Si vinieron menos cuentas de las que pueden ir en el campo, completo con blancos
        resultado = isoUtil.padright(resultado, cantidadMaximaCuentas*19, ' ')
            
        self.setBodyElement(125, resultado)

    # Setea el campo 125 con la informaci�n de la lista de movimientos        
    def setListaUltimosMovimientos(self, movimientos, saldoContable, saldoDisponible):
        # Armo el cabezal
        dateFormatter = SimpleDateFormat("yyMMdd");
        dateFormatter1 = SimpleDateFormat("dd/MM");
        fechaProceso = dateFormatter.format(self.getTopazProcessDate())
        fechaProceso1 = dateFormatter1.format(self.getTopazProcessDate())        
        #strCuenta = str(cuenta).ljust(22) 
        cabezal = '1P' + fechaProceso + '01'+ '30' + 'FECHA CONCEPTO        IMPORTE '
        saldoDisponibleFormateado = '%(saldo).2f' % {'saldo': saldoDisponible}
        pie = 'SDO.AL' + fechaProceso1 +': '+ saldoDisponibleFormateado
        pie30 = pie.rjust(30)
        # Ahora la informaci�n de los movimientos
        cantidadMaximaMovimientos = 10
        if len(movimientos) > cantidadMaximaMovimientos:
            raise POSException(999, "Error al procesar el campo 125, se exedi� la cantidad m�xima de movimientos")
         
        resultado = ""
        # Proceso las cuentas de la lista
        for m in movimientos:
            concepto = m.concepto
            resultado = resultado + concepto
            
        # Si vinieron menos cuentas de las que pueden ir en el campo, completo con blancos
        #resultado = resultado.ljust(cantidadMaximaMovimientos*40)
        
        resultado = cabezal + resultado + pie30
        
        self.setBodyElement(125, resultado)
        
    # Deja solamente mayusculas sin acentos en la descripci�n
    def dejoSoloMayusculas(self, descripcion):
        descripcionSM = ""
        i = 0
        while i < len(descripcion):
            c = descripcion[i]
            if c == '�':
                c = 'a'
            elif c == '�':
                c = 'e'
            elif c == '�':
                c = 'i'
            elif c == '�':
                c = 'o'                
            elif c == '�':
                c = 'u'   
                
            descripcionSM = descripcionSM + c.upper()
            i = i + 1

        return descripcionSM
        
    # Si la tarjeta es VISA
    def esVisa(self) :
        return self.getCardNumber().startswith('4')
        
# Clase 'auxiliar' para manejar la informaci�n de las cuentas
class InfoCuenta:
    
    def __init__(self, sucursal, producto, moneda, cuenta, operacion=0, ordinal=0):
        self.sucursal  = sucursal
        self.producto  = producto
        self.moneda    = moneda
        self.cuenta    = cuenta
        self.operacion = operacion
        self.ordinal   = ordinal
                

# Clase 'auxiliar' para manejar la informacion de los movimientos
class Movimiento:
    
    def __init__(self, concepto):
            self.concepto       = concepto