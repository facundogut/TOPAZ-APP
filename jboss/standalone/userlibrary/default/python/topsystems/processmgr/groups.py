# package  topsystems.processmgr;
# -*- coding: latin-1 -*-
# Java import
from topsystems.processmgr.def import GroupDefinitions
from topsystems.processmgr.def import ProcessDefinitions
from topsystems.processmgr.def import ProcessDefinition
from topsystems.processmgr.def import GroupDefinition

# jython import

# -------------------------------------------------------------------------------------------------------------------- #
# Convenciones que se utilizaran para nombrar los procesos:                                                            #
#          GRL - Procesos Generales                                                                                    #
#          CBL - Contabilidad                                                                                          #
#          CAJ - Caja y Tesoreria                                                                                      #
#          CRE - Creditos                                                                                              #
#          TJD - Tarjeta de Debito                                                                                     #
#          TJC - Tarjeta de Credito                                                                                    #
#          VTA - Cuentas Vista                                                                                         #
#          CLE - Clearing cheques                                                                                      #
#          CLI - Clientes                                                                                              #
#          DPF - Depositos a Plazo Fijo                                                                                #
#          ITF - Interfases que se ejecuten para carga de datos                                                        #
#          RPT - Reportes.                                                                                             #
#          VAL - Valores                                                                                               #
#          PCT - Pago por Cuenta de Terceros                                                                           #
#          RCT - Recaudacion por Cuenta de Terceros                                                                    #
#          BAL - Generacion de Balances                                                                                #
#          EEC - Estados de Cuenta                                                                                     #
#          COM - Pagos a Comercios                                                                                     #
#          DIA - Ejecucion Diaria                                                                                      #
#          MIG - Procesos Post Migracion                                                                               #
#          CVN - Convenios                                                                                             #
# -------------------------------------------------------------------------------------------------------------------- #


# -------------------------------------------------------------------------------------------------------------------- #
#									       		ID de proceso 		       #
#											Para Ctrl M                    #
#	GRUPOS DE PROCESOS					FRENTE			DESDE 	HASTA		       #		
#														       #
#	ITF - Interfases que se ejecuten para carga de datos	INTERFACES		1	400                    #
# 													               #
#	GRL - Procesos Generales                            	GENERALES		401	600                    #
#								SEGURIDAD		401	600                    #
#													               #
#	CLI - Clientes                                      	CLIENTES		601	700                    #
#													               #
#	CBL - Contabilidad                                  	CONTABILIDAD		701	800                    #
#	BAL - Generacion de Balances                        				701	800                    #
#													               #
#	VTA - Cuentas Vista                                 				801	1000                   #
#	TJD - Tarjeta de Debito                             				801	1000                   #
#	TJC - Tarjeta de Credito                            				801	1000                   #
#	CLE - Clearing cheques                              				801	1000                   #
#	DPF - Depositos a Plazo Fijo                        				801	1000                   #
#	EEC - Estados de Cuenta                             				801	1000                   #
#	COF - Cajas de seguridad							801	1000                   #
#													               #
#	PCT - Pago por Cuenta de Terceros                   	OPERACIONES		1001	1200                   #
#	RCT - Recaudacion por Cuenta de Terceros            				1001	1200                   #
#	CVN - Convenios          							1001	1200                   #
#	COM - Pagos a Comercios                             				1001	1200                   #
#														       #
#	RPT - Reportes						RRII/IMPUESTOS/Reportes	1201	1400   		       #
#														       #
#	CRE - Creditos	 		                        ACTIVAS	                1401	1600		       #	
# 														       #
#       CAJ -  Cajas y tesoreria				CAJAS Y TESORERIA	1601	1700                   #
#														       #
#	Cadenas particulares					Otros			1701			       #
#														       #
# Para agregar el id a los procesos se debe agregar  gdef.setExecutionId(id)					       #
# -------------------------------------------------------------------------------------------------------------------- #

# crea todos los grupos que se podran ejecutaran en el Process Manager
def createGroups():
    gdefs = GroupDefinitions()

# ---------------------------------------------------------------------------------------------------------------------- #
#                                              Cadena de Migracion -Validacion'                                             #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("     MIG - Cadena de Migracion - Validacion")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista")
    gdef.registerProcess("CRE - Cancelacion Acuerdos y Sobregiros")
    gdef.registerProcess("CRE - Consumo de Acuerdos y Sobregiros")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente Sin Categoria")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")
    gdef.registerProcess("CRE - Genera IVA Financiado")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE- Crea Comision Desembolso")
    gdef.registerProcess("GRL- DevengamientoComisionDesembolso")
    gdef.registerProcess("GAR - Borrado tabla")
    gdef.registerProcess("GAR - Calculo Afectacion Garantias")
    gdef.registerProcess("GAR - Calculo Afectacion Prestamos sin Garantias")
    gdef.registerProcess("GAR - Contabilizacion Afectacion de Garantias")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Prepara Clasificacion")
    gdef.registerProcess("CRE - Clasificacion Deuda No Refinanciada")
    gdef.registerProcess("CRE - Calificacion Objetiva Deuda Refinanciada")
    gdef.registerProcess("CRE - Actualizacion detalle CENDEU")
    gdef.registerProcess("CRE - Actualizacion CENDEU Nuevos Clientes")
    gdef.registerProcess("CRE - Actualizacion Situacion Sistema Financiero")
    gdef.registerProcess("CRE - Borrado de situacion juridica")
    gdef.registerProcess("CRE - Imputacion situacion juridica")
    gdef.registerProcess("CRE - Borrado de discrepancia")
    gdef.registerProcess("CRE - Actualizacion de Discrepancia")
    gdef.registerProcess("CRE - Actualizacion Situacion Resultante")
    gdef.registerProcess("CRE - Calculo de Prevision")
    gdef.registerProcess("CRE - Contabilizacion Previsiones")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Actulizacion De Cuotas Prestamos")
    gdef.registerProcess("CAJ - Carga Saldos Caja Historico")
    gdef.registerProcess("CAJ - Carga Saldos ATM Historico")
    gdef.registerProcess("DPF - Inmovilizar saldos")
    gdef.registerProcess("DPF - Cancela DPF UVAUVI")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Solo Saldos Diarios")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad")
    gdef.registerProcess("BAL - Generacion de Balance Diario")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)    

# -------------------------------------------------------------------------------------------------------------------- #
#                                                 Procesos Contables                                                   #
# -------------------------------------------------------------------------------------------------------------------- #
    
    gdef = GroupDefinition("CBL - Devengamiento Valores Calculo")     
    gdef.registerProcess("Devengamiento Valores") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("Devengamiento Calculo y Actualizacion")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(703)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Devengamiento Plazo Contabilizacion")
    gdef.registerProcess("Devengamiento Contabilizacion")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(704)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CBL - Devengamiento Plazo Extorno Contabilizacion")
    gdef.registerProcess("Extorno Contabilizacion Devengamiento")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(702)	
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Devengamiento Plazo")
    gdef.registerProcess("CBL - Devengamiento Plazo Extorno Contabilizacion")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")    
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")        
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Exposicion de Sobregiros") 
    gdef.registerProcess("ExposicionSobregiros") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")        
    gdef.setExecutionId(714)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Extorno Exposicion de Sobregiros") 
    gdef.registerProcess("EXTORNO ExposicionSobregiros") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")        
    gdef.setExecutionId(715)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Obtener datos de Ganancias y Perdidas del Ejercicio") 
    gdef.registerProcess("ObtenerGananciasPerdidas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdef.setExecutionId(706)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Actualizar los resultados del ejercicio") 
    gdef.registerProcess("ActualizacionResultadosEjercicio")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Cambio de Rubro por Vencido o Forzado") 
    gdef.registerProcess("Categorizacion Prestamos y DPF Garantia")     
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(705)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable")
    gdef.registerProcess("Procesamiento de la Bandeja contable") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdef.setExecutionId(708)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Calculo Previsiones estadisticas") 
    gdef.registerProcess("Previsiones estadisticas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("CBL - Contabilizacion de Previsiones Especificas") 
    gdef.registerProcess("Previsiones Especificas Contabilidad") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CBL - Previsiones por Categorizacion de Riesgos") 
    gdef.registerProcess("Previsiones Categorizacion Riesgos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CBL - Calculo Prevision de Creditos") 
    gdef.registerProcess("Provision de creditos: Calculo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CBL - Extorno de Asiento Especifico") 
    gdef.registerProcess("Extorno") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("POS - Extorno de asientos") 
    gdef.registerProcess("POS Extorno") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("TLF - Extorno Kettle") 
    gdef.registerProcess("TLF Extorno Kettle")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    #gdef.setExecutionId()
    gdefs.addGroup(gdef)    
    
    gdef = GroupDefinition("TLF - Extorno Desasistida") 
    gdef.registerProcess("TLF Extorno Desasistida")  
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    #gdef.setExecutionId()
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - TLF Conciliacion Extornos desasistidos") 
    gdef.registerProcess("TLF - Extorno Kettle")
    gdef.registerProcess("TLF - Extorno Desasistida")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdef.setExecutionId(513)   
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CBL - Contabilizar Cartera Comprada")
    gdef.registerProcess("Contabilizacion Cartera Pronto")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CBL - Resultados por Tenencia de Moneda Extranjera")
    gdef.registerProcess("Resultados por tenencia de moneda extranjera")
    gdef.setCanBeRootGroup("true")                
    gdef.setSingleton("false")             
    gdef.setExecutionId(712)
    gdefs.addGroup(gdef)  
    
    gdef = GroupDefinition("CBL - Resultados por Operaciones de Cambio")
    gdef.registerProcess("Resultados por operaciones de cambio")
    gdef.setCanBeRootGroup("true")                
    gdef.setSingleton("false")             
    gdef.setExecutionId(713)
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CBL - Procesar Registros Contables")
    gdef.registerProcess("Op 2022 - Proceso de Registros Contables")
    gdef.setCanBeRootGroup("true")                
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    #gdef = GroupDefinition("CBL - Posicion Fin de Mes BCU") 
    #gdef.registerProcess("Posicion Fin de Mes BCU") 
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")     
    #gdefs.addGroup(gdef)    
    
    gdef = GroupDefinition("CBL - Previsiones")
    #gdef.registerProcess("CBL - Calculo Provision de Creditos")
    gdef.registerProcess("CBL - Contabilizacion de Previsiones Especificas")    
    gdef.registerProcess("CBL - Previsiones por Categorizacion de Riesgos")
    gdef.registerProcess("CBL - Calculo Previsiones estadisticas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable MIG")
    gdef.registerProcess("Procesamiento de la Bandeja contable MIG") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable BNR")
    gdef.registerProcess("Procesamiento de la Bandeja contable BNR") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable TCH")
    gdef.registerProcess("Procesamiento de la Bandeja contable TCH") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable CNT")
    gdef.registerProcess("Procesamiento de la Bandeja contable CNT") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable TJD")
    gdef.registerProcess("Procesamiento de la Bandeja contable TJD") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)    
    
    gdef = GroupDefinition("CBL - Ajuste campos ME y MN cuentas resultados") 
    gdef.registerProcess("Ajuste campos ME y MN cuentas resultados") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    # GARANTIAS COMPUTABLES
    gdef = GroupDefinition("CBL - Borrar Garantias Computables") 
    gdef.registerProcess("Borrar Garantias Computables") 
    gdefs.addGroup(gdef)

    # GARANTIAS NO COMPUTABLES
    gdef = GroupDefinition("CBL - Borrar Garantias NO Computables") 
    gdef.registerProcess("Borrar Garantias NO Computables") 
    gdefs.addGroup(gdef)
    
    # DISTRIBUCION DE GARANTIAS NO DEDUCIDAS
    #gdef = GroupDefinition("CBL - Distribucion de Garantias NO Deducidas") 
    #gdef.registerProcess("Distribucion de Garantias No Deducidas")
    #gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CBL - Reporte Control Activo Pasivo")
    gdef.registerProcess("Impresion Control Activo Pasivo") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("CBL - Reporte Saldos Diarios Inconsistentes")
    gdef.registerProcess("Reporte Saldos Diarios Inconsistentes")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("CBL - Reporte Asientos Abiertos")
    gdef.registerProcess("Reporte Asientos Abiertos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)    
    
    gdef = GroupDefinition("CBL - Cambio de Rubro por Vdo o Forzado Garantia") 
    gdef.registerProcess("Categorizacion Prestamos por Garantia")     
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Ajustar Saldos por Previsiones") 
    gdef.registerProcess("Ajuste Saldos Columnas Resultados")     
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    #Agrego definicion para Oper 2072
    gdef = GroupDefinition("CBL - Calculo Impuesto Movimiento Moneda Extranjera")
    gdef.registerProcess("Calculo Impuesto Movimiento Moneda Extranjera")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(717)
    gdefs.addGroup(gdef)

    #Agrego definicion para Oper 2096
    gdef = GroupDefinition("CBL - Cobro sellos Chaco sobregiro CC")
    gdef.registerProcess("Cobro Sellos Chaco Sobregiro CC")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(721)
    gdefs.addGroup(gdef)

# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos Caja y Tesoreria                                                    #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("CAJ - Carga Saldos Caja Historico") 
    gdef.registerProcess("Carga Saldos Caja Historico")
    gdef.registerProcess("NumeroFolioLibroTesoreria")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdef.setExecutionId(1601)	
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CAJ - Carga Saldos ATM Historico")
    gdef.registerProcess("Carga Saldos ATM Historico")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CAJ - Pago a domicilio")
    gdef.registerProcess("Pago sueldo a domicilio")
    gdefs.addGroup(gdef)

# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos Depositos a Plazo                                                   #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("DPF - Pago Periodico de Intereses") 
    gdef.registerProcess("Pago Periodico de Intereses DPF") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")       
    gdef.setExecutionId(812)	
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("DPF - Renovacion o Cancelacion") 
    gdef.registerProcess("Cancelacion DPF") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdef.setExecutionId(813)	
    gdefs.addGroup(gdef)
            
    gdef = GroupDefinition("DPF - Adelanto IRPF anual") 
    gdef.registerProcess("Liquidacion IRPF Anual")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("DPF - Inmovilizar saldos") 
    gdef.registerProcess("Inmovilizar saldos DPF")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(822)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("DPF - Cancela DPF UVAUVI") 
    gdef.registerProcess("Cancela DPF UVAUVI con Estado Atraso U")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(848)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("DPF - Cancela DPF Titulo Valor") 
    gdef.registerProcess("Cancela DPF TV con Estado Atraso T")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(849)
    gdefs.addGroup(gdef)
# -------------------------------------------------------------------------------------------------------------------- #
#                                           Procesos Cuentas Vista                                                     #
# -------------------------------------------------------------------------------------------------------------------- #

    #gdef = GroupDefinition("VTA - Cargos por Exceso Mov. en Caja") 
    #gdef.registerProcess("Cargos Cuentas Vistas Exceso Movs Caja") 
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")        
    #gdef.setExecutionId(811)
    #gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Cargos por Mantenimiento de Paquete") 
    gdef.registerProcess("Cargos Mantenimiento de Paquete") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(810)	
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cargo por Bajo Promedio") 
    gdef.registerProcess("Cargo Bajo Promedio Cuentas Vistas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(809)	
    gdefs.addGroup(gdef)    
    
    gdef = GroupDefinition("VTA - Traspaso Cuentas Inmovilizadas a Tesoro Nacional") 
    gdef.registerProcess("Traspaso Inmovilizadas a Tesoro Nacional") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")  
    gdef.setExecutionId(808)	
    gdefs.addGroup(gdef)    
        
    gdef = GroupDefinition("VTA - Instrucciones de Traspaso entre Cuentas") 
    gdef.registerProcess("Traspaso entre Cuentas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(803)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Cobertura entre Grupos de Cuentas") 
    gdef.registerProcess("Cobertura entre Cuentas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(802)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Intereses Vista Saldo o Promedio Pago")
    gdef.registerProcess("Intereses Vista Saldo o Promedio Pago")
    gdef.setExecutionId(818)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Reversa de letras y cheques") 
    gdef.registerProcess("Reversa de letras y cheques")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(801)	
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Control de Fechas para Cheques denunciados por robo") 
    gdef.registerProcess("Control Fechas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("VTA - Generacion de Vales por Sobregiros")
    gdef.registerProcess("Generacion de vales por sobregiros")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
      
    gdef = GroupDefinition("VTA - Cancelacion de Vales Generados por Sobregiros")
    gdef.registerProcess("Cancelacion de vales")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Bloqueo de Cuentas por Cheques Devueltos") 
    gdef.registerProcess("Bloqueo de cuentas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("VTA - Control de Paquete y Campanias") 
    gdef.registerProcess("Control Campanias") 
    gdef.registerProcess("Control Paquetes")
    gdef.setCanBeRootGroup("true")    
    gdef.setExecutionId(817)
    gdefs.addGroup(gdef)
       
    gdef = GroupDefinition("VTA - Cobranza Cargos Diferidos") 
    gdef.registerProcess("Cobranza Cargos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(806)
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("VTA - Cobranza Cargos Diferidos FUCO") 
    gdef.registerProcess("Cobranza Cargos FUCO") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(854)
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("VTA - Bandeja Entrada Buzones") 
    gdef.registerProcess("Bandeja de entrada Technisegur") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Bandeja Entrada BANRED") 
    gdef.registerProcess("Bandeja de entrada Banred") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
 
    gdef = GroupDefinition("VTA - Cargos Movimientos Cruzados") 
    gdef.registerProcess("Cargos Movimientos Cruzados") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Cobertura entre Cuentas de Grupo especifico") 
    gdef.registerProcess("Cobertura entre Cuentas - Grupo especifico")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")  
    gdef.setExecutionId(804)
    gdefs.addGroup(gdef)
   
    gdef = GroupDefinition("VTA - Control Lineas de Credito Consumo por Acuerdos Sobregiro") 
    gdef.registerProcess("Control Lineas de Credito Consumo : Acuerdos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
  
    gdef = GroupDefinition("VTA - Control Lineas de Credito Consumo por Acuerdos Sobregiro (A Demanda)") 
    gdef.registerProcess("Control Lineas de Credito Consumo : Acuerdos a Demanda") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
    
    #gdef = GroupDefinition("VTA - Cargo Estado de Cuenta LEGAL") 
    #gdef.registerProcess("Cargo Estado de Cuenta LEGAL") 
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")    
    #gdefs.addGroup(gdef) 

    gdef = GroupDefinition("VTA - Cargo Estado de Cuenta ESPECIAL") 
    gdef.registerProcess("Cargo Estado de Cuenta ESPECIAL") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(845)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Alta de Acuerdos y Sobregiros")     
    gdef.registerProcess("Acuerdos y Sobregiros Alta") 
    gdefs.addGroup(gdef)   
    
    gdef = GroupDefinition("VTA - Cancelacion y Renovacion de Acuerdos y Sobregiros")     
    gdef.registerProcess("Acuerdos y Sobregiros Cancelacion y Renovacion") 
    gdefs.addGroup(gdef)       
    
    gdef = GroupDefinition("VTA - Cargo Tasa de Control y CJPB") 
    gdef.registerProcess("Cargo Tasa de Control y CJPB") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cargo Pregiro Clearing") 
    gdef.registerProcess("Cargo Pregiro Clearing") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Calculo Pregiro Clearing")
    gdef.registerProcess("ComisionPregiro")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Calculo Disponible Grupo")
    gdef.registerProcess("CalculoDisponibleGrupo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Cargo Complemento Pregiro")
    gdef.registerProcess("Complemento Pregiro")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Cobro Pregiro")
    gdef.registerProcess("VTA - Calculo Disponible Grupo")
    gdef.registerProcess("VTA - Calculo Pregiro Clearing")
    gdef.registerProcess("VTA - Cargo Pregiro Clearing")
    gdef.setCanBeRootGroup("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Seguro por Sobregiro") 
    gdef.registerProcess("Seguro por Sobregiro") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Comision Mantenimiento de Cuentas Vista") 
    gdef.registerProcess("Comision Mantenimiento Cuentas Vistas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(807)    
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("VTA - Notificacion por Comisiones Pendientes")
    gdef.registerProcess("Notificacion por Cargos Pendientes")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(846)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Comision Mantenimiento Banca Empresa") 
    gdef.registerProcess("Comision Mantenimiento Banca Empresa") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(850)
    gdefs.addGroup(gdef)
    
# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos Clearing Camaras                                                    #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("CLE - Acreditacion de Cheques Recibidos")
    gdef.registerProcess("AcreditacionDeCheques")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(830)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Actualizacion Saldos Pendientes") 
    gdef.registerProcess("ClearingUpdateSaldosPendientes")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(829)
    gdefs.addGroup(gdef)
    
    #gdef = GroupDefinition("CLE - Cambio de Rubro Contabilizacion de Cheques Pendientes") 
    #gdef.registerProcess("ClearingCambioRubro") 
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")        
    #gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Recepcion de Cheques Girados") 
    gdef.registerProcess("ClearingRecibirDeCamara") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdef.setExecutionId(831)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Devolucion de Cheques Girados")
    gdef.registerProcess("ClearingDevolucion")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdef.setExecutionId(834)
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CLE - Envio a Camara Cheques Recibidos (Acumula Bandeja)") 
    gdef.registerProcess("ClearingEnvioCamaraCompensadora") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CLE - Envio a Camara Cheques Recibidos (Limpia Bandeja)") 
    gdef.registerProcess("ClearingEnvioCamaraCompensadoraBorra") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdef.setExecutionId(828)
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("CLE - Recepcion de Cheques Recibidos Devueltos") 
    gdef.registerProcess("ClearingRecepcionChequesDevueltos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdef.setExecutionId(837)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Diferimiento de Firme") 
    gdef.registerProcess("Diferimiento de Camara")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)  

    gdef = GroupDefinition("CLE - Diferimiento de Presentacion a Camara") 
    gdef.registerProcess("Diferimiento de Presentacion a Camara") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("CLE - Contabilizacion del Envio a Camara") 
    gdef.registerProcess("ClearingEnvioCamaraContabilizacion") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")                 
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("CLE - Acreditacion Solicitudes") 
    gdef.registerProcess("Acreditacion Solicitudes Cheques")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")      
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Cambio fecha cheques ATM feriados") 
    gdef.registerProcess("Cheques ATM feriados")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")      
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Grupo Acreditacion Camara") 
    gdef.registerProcess("CLE - Actualizacion Saldos Pendientes")
    gdef.registerProcess("CLE - Recepcion de Cheques Recibidos Devueltos") 
    gdef.registerProcess("CLE - Acreditacion de Cheques Recibidos")
    gdef.registerProcess("CLE - Acreditacion Solicitudes")  
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")                 
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CBL - Cambio de Rubro Vista") 
    gdef.registerProcess("Categorizacion Vista")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(701)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Bloqueo Cuentas Vista inmovilizadas") 
    gdef.registerProcess("Bloqueo inmovilizados Vista")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Genera Nro de aviso") 
    gdef.registerProcess("GeneraNroAviso") 
    gdef.setExecutionId(836)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Control rechazo temporal") 
    gdef.registerProcess("ControlTemporal") 
    gdef.setExecutionId(833)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Control cheques y plazos fijos digitalizados") 
    gdef.registerProcess("ControlChqDigitalizado") 
    gdef.setExecutionId(838)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Control DPF compensables propios confirmados") 
    gdef.registerProcess("ControlDpfConfirmado") 
    gdef.setExecutionId(842)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Cobro de multa con/sin bonificacion")
    gdef.registerProcess("MultasCheques")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(835)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Control DPF Compensables Propios")
    gdef.registerProcess("DPFPropiosValidaciones")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(843)
    gdefs.addGroup(gdef)     
    
    gdef = GroupDefinition("CLE - Rechazos Clearing Digital")
    gdef.registerProcess("RechazoClearingDigital")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(839)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Rechazos DPF Compensable Otro Banco")
    gdef.registerProcess("DPFRechazosOtroBanco")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(841)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Acreditacion DPF Compensable Otro Banco")
    gdef.registerProcess("DPFAcreditacionOtroBanco")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(840)
    gdefs.addGroup(gdef)
# -------------------------------------------------------------------------------------------------------------------- #
#                          Procesos de Recaudaciones por Cuenta de Terceros                                            #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("RCT - Integracion recaudaciones recibidas") 
    gdef.registerProcess("Integracion recaudaciones recibidas") 
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RCT - Debitos Automaticos") 
    gdef.registerProcess("Cobranza Vista") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("RCT - Rendicion de cobranza") 
    gdef.registerProcess("Rendicion de cobranza")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RCT - Actualizacion Fecha Inicio de Cobro") 
    gdef.registerProcess("Actualizacion Fecha Inicio de Cobro")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RCT - Transferencia a Cuentas de Entes Recaudadores") 
    gdef.registerProcess("Transferencia Ctas Entes Recaudadores")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
        
    gdef = GroupDefinition("RCT - Envio de Novedades a Terceros") 
    gdef.registerProcess("Envio de novedades a terceros") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)   
    
    gdef = GroupDefinition("RCT - Recepcion de Informacion de Deuda") 
    gdef.registerProcess("Recepcion de Informacion de Deuda") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RCT - Grupo de Recaudaciones Automaticas")    
    gdef.registerProcess("ITF - Levanta Bandeja Recaudaciones")
    gdef.registerProcess("RCT - Integracion recaudaciones recibidas")
    gdef.registerProcess("RCT - Debitos Automaticos")     
    gdefs.addGroup(gdef)
# -------------------------------------------------------------------------------------------------------------------- #
#                                  Procesos de Pagos por Cuenta de Terceros                                            #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("PCT - Integracion de Pagos Recibidos") 
    gdef.registerProcess("Integracion de Pagos Recibidos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")                
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PCT - Emision de letras") 
    gdef.registerProcess("Emision de letras")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PCT - Numeracion y Renumeracion de Letras") 
    gdef.registerProcess("Numeracion y renumeracion de letras")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("PCT - Anulacion de letras") 
    gdef.registerProcess("Anulacion de letras")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
        
#    gdef = GroupDefinition("PCT - Transferencias a Bancos") 
#    gdef.registerProcess("Transferencias a bancos")
#    gdef.setCanBeRootGroup("true")
#    gdef.setSingleton("false")            
#    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("PCT - Creditos Automaticos") 
    gdef.registerProcess("Creditos Automaticos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("PCT - Impresion Cheques Letras de Cambio") 
    gdef.registerProcess("Impresion Cheques Letras de Cambio") 
    gdef.registerProcess("ImpresionLetrasCambio") 
    gdefs.addGroup(gdef) 
   
    gdef = GroupDefinition("PCT - Pago Sueldos o Proveedores con Credito en Cuenta")    
    gdef.registerProcess("ITF - Levanta Bandeja Pago Terceros")
    gdef.registerProcess("PCT - Integracion de Pagos Recibidos")
    gdef.registerProcess("PCT - Creditos Automaticos")     
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PCT - Pago Sueldos BUXIS - NBC")    
    gdef.registerProcess("ITF - Pagos a Sueldos")
    gdef.registerProcess("PCT - Integracion de Pagos Recibidos")
    gdef.registerProcess("PCT - Creditos Automaticos")     
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PCT - Genera ID Proveedor") 
    gdef.registerProcess("Genera ID Proveedor") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("RCT - Cambio de suscripcion servicio BSE") 
    gdef.registerProcess("RCT - Mapeo de suscripcion servicio BSE") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
# -------------------------------------------------------------------------------------------------------------------- #
#                                            Procesos de Clientes                                                      #
# -------------------------------------------------------------------------------------------------------------------- #
  
    gdef = GroupDefinition("CLI - Procesar Ingreso de Lote")
    gdef.registerProcess("Ingreso de Lote")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLI - Control Perfil de Cliente")
    gdef.registerProcess("Control Perfil Cliente")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
    
    #gdef = GroupDefinition("CLI - Validacion de Clientes en Compra Cartera") 
    #gdef.registerProcess("Validacion Clientes Compra Cartera") 
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")     
    #gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLI - Control de Clientes con duplicacion de integracion") 
    gdef.registerProcess("clientesduplicados")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLI - Baja Base Negativa") 
    gdef.registerProcess("Baja base negativa") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLI - Alta Base Negativa") 
    gdef.registerProcess("Alta base negativa") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLI - Calificacion por atraso en la documentacion") 
    gdef.registerProcess("Calificacion por atraso en la documentacion")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)  

    gdef = GroupDefinition("CLI - Contagio de Calificacion Objetiva") 
    gdef.registerProcess("Calificacion Objetiva - Contagio") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Calificacion Resultante") 
    gdef.registerProcess("Calificacion Resultante") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
        
    gdef = GroupDefinition("CLI - Calificacion Resultante - Contagio") 
    gdef.registerProcess("Calificacion Resultante - Contagio") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLI - Calificacion Cliente-Bcu")     
    gdef.registerProcess("Calificacion Cartera") 
    gdef.registerProcess("Calificacion Cliente-Bcu") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)  
    
    gdef = GroupDefinition("CLI - Calificacion Cliente por Cartera")     
    gdef.registerProcess("Calificacion Cartera") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)      
    
    gdef = GroupDefinition("CLI - Calificacion Cliente Banco Central")     
    gdef.registerProcess("Calificacion Cliente-Bcu") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)  
    
    gdef = GroupDefinition("CLI - Categoria Reestructura") 
    gdef.registerProcess("Categoria Reestructura") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef) 
    
    
    gdef = GroupDefinition("CLI - Suspension Poderes por Infractores de Cheques")
    gdef.registerProcess("Ley Infractores Cheques")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLI - Calificacion Subjetiva CONTAGIO") 
    gdef.registerProcess("Calificacion Subjetiva Contagio") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Grupo Calificacion de Clientes")
    gdef.registerProcess("CLI - Calificacion Cliente por Cartera")
    gdef.registerProcess("CLI - Calificacion Cliente Banco Central")    
    gdef.registerProcess("CLI - Calificacion por atraso en la documentacion")
    gdef.registerProcess("CLI - Categoria Reestructura")
    gdef.registerProcess("CLI - Contagio de Calificacion Objetiva")    
    gdef.registerProcess("CLI - Calificacion Resultante")
    gdef.registerProcess("CLI - Calificacion Resultante - Contagio")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    # AJUSTE DE CONTAGIO POR SUBJETIVA
    gdef = GroupDefinition("CLI - Ajuste de Contagio por Subjetiva") 
    gdef.registerProcess("Procesos Calificacion Resultante de la Persona") 
    gdefs.addGroup(gdef)
    
    # CALIFICACION OBJETIVA - INICIALIZACION
    gdef = GroupDefinition("CLI - Calificacion Objetiva - Inicializacion") 
    gdef.registerProcess("Calificacion Objetiva - Inicializacion")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false") 
    gdefs.addGroup(gdef)
    
    # CALIFICACION OBJETIVA
    gdef = GroupDefinition("CLI - Calificacion Objetiva") 
    gdef.registerProcess("Calificacion Objetiva")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false") 
    gdefs.addGroup(gdef)

    # Alta Masiva por Compra de Cartera 
    gdef = GroupDefinition("CLI - Lotes Alta Masiva x Cartera")
    gdef.registerProcess("Lotes Alta Masiva x Cartera")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    # Proceso Calificacion Mocasist Personas no clientes
    gdef = GroupDefinition("CLI - Calificacion MOCASIST Garantias") 
    gdef.registerProcess("Calificacion MOCASIST de personas en Garantias")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Alta Maestro Fallecido") 
    gdef.registerProcess("Alta Maestro Fallecido") 
    gdef.setExecutionId(605)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Baja Maestro Fallecido") 
    gdef.registerProcess("Baja Maestro Fallecido") 
    gdef.setExecutionId(606)
    gdefs.addGroup(gdef)
	
# -------------------------------------------------------------------------------------------------------------------- #
#                                             Procesos de Creditos                                                     #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("CRE - Actualizacion Segun Tasacion Garantias") 
    gdef.registerProcess("Actualizacion Tasaciones en Dolares")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Cobranza Automatica") 
    gdef.registerProcess("Cobranza Automatica")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdef.setExecutionId(1440)
    gdefs.addGroup(gdef)
    
#    gdef = GroupDefinition("CRE - Recalculo Migracion") 
#    gdef.registerProcess("Recalculo Migracion") 
#    gdef.setCanBeRootGroup("true")    
#    gdef.setSingleton("false")            
#    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - RECALCULO MIGRACION") 
    gdef.registerProcess("RecalculoMigracion")
    gdefs.addGroup(gdef)
    
    #gdef = GroupDefinition("CRE - Extorno Asiento de Garantias Computables")
    #gdef.registerProcess("Extorno de asientos de garantias computables")
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")             
    #gdefs.addGroup(gdef)
    
    #gdef = GroupDefinition("CRE - Deduccion de garantias") 
    #gdef.registerProcess("Deduccion de garantias")
    #gdef.setCanBeRootGroup("true")    
    #gdef.setSingleton("false")                
    #gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Contabilizacion Deduccion de garantias") 
    gdef.registerProcess("Contabilizacion de deduccion")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
        
    #gdef = GroupDefinition("CRE - Distribucion de Garantias No Deducidas") 
    #gdef.registerProcess("Distribucion de Garantias No Deducidas")
    #gdef.setCanBeRootGroup("true")    
    #gdef.setSingleton("false") 
    #gdefs.addGroup(gdef)
           
    gdef = GroupDefinition("CRE - Marcar saldos garantizados") 
    gdef.registerProcess("Marcar saldos garantizados")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
           
    gdef = GroupDefinition("CRE - Depuracion de Solicitudes de Credito Vencidas")
    gdef.registerProcess("Depuracion de solicitudes de credito vencidas")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef) 
 
    gdef = GroupDefinition("CRE - Recepcion Pagos de Cartera Comprada")
    gdef.registerProcess("Recepcion Pagos Pronto")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
        
    gdef = GroupDefinition("CRE - Alta de Credito Compra de Cartera Paso 1")
    gdef.registerProcess("Alta Creditos Compra Cartera Paso 1")
    gdef.setCanBeRootGroup("false")    
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Alta de Credito Compra de Cartera Paso 1(1510)")
    gdef.registerProcess("Alta Creditos Compra Cartera Paso 1(1510)")
    gdef.setCanBeRootGroup("false")    
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Arreglo PRONTO producto 1210->1510") 
    gdef.registerProcess("Arreglo PRONTO producto 1210->1510") 
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("CRE - Alta de Credito Compra Cartera Paso 2")
    gdef.registerProcess("Alta Creditos Compra Cartera Paso 2")
    gdef.setCanBeRootGroup("false")    
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
#    gdef = GroupDefinition("CRE - Recalculo Cartera Comprada") 
#    gdef.registerProcess("Recalculo Compra de Cartera") 
#    gdef.setCanBeRootGroup("true")    
#    gdef.setSingleton("false")         
#    gdefs.addGroup(gdef)
        
    gdef = GroupDefinition("CRE - Validacion Cartera Comprada")
    gdef.registerProcess("Validacion de Creditos Compra de Cartera")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Revision Periodica de Capital")
    gdef.registerProcess("Revision Periodica de Capital")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Cambio Rubro Cartera Comprada")
    gdef.registerProcess("Cambio Rubro Prestamos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
        
    gdef = GroupDefinition("CRE - Calculo de Deudas por Librador") 
    gdef.registerProcess("Truncar tabla CRE_CONCENTRACION_X_LIBRADOR")
    gdef.registerProcess("Calcular descuentos a realizar por librador") 
    gdef.registerProcess("Calcular descuentos realizados por librador") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)   
    
    gdef = GroupDefinition("CRE - Calculo de Concentracion por Librador")
    gdef.registerProcess("Calcular concentracion de libradores") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualiza Detalle de Pagos")
    gdef.registerProcess("Carga Tabla de Detalle de Pagos")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Grupo Alta Creditos Cartera Comprada") 
    gdef.registerProcess("CRE - Arreglo PRONTO producto 1210->1510") 
    gdef.registerProcess("CRE - Alta de Credito Compra de Cartera Paso 1") 
    gdef.registerProcess("CRE - Alta de Credito Compra de Cartera Paso 1(1510)")
#    gdef.registerProcess("CRE - Recalculo Cartera Comprada") 
    gdef.registerProcess("CRE - Alta de Credito Compra Cartera Paso 2")
    gdef.registerProcess("CBL - Contabilizar Cartera Comprada")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Garantias")
    #gdef.registerProcess("CRE - Extorno Asiento de Garantias Computables")
    #gdef.registerProcess("CRE - Deduccion de garantias")   
    gdef.registerProcess("CRE - Marcar saldos garantizados")    
    #gdef.registerProcess("CRE - Contabilizacion Deduccion de garantias")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Recepcion Pagos por Buzon") 
    gdef.registerProcess("Pago Prestamos por buzon")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Cancelacion Remanentes Capital")
    gdef.registerProcess("Cancelacion Remanente Capital")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)

    # --- Seguro de Vida en Prestamos -- #

    # ASIGNACION CUOTAS SEGUROS
    gdef = GroupDefinition("CRE - Asignacion cuotas seguros")     
    gdef.registerProcess("Asignacion cuotas seguros") 
    gdefs.addGroup(gdef)
        
    # BAJA GASTO SEGURO
    gdef = GroupDefinition("CRE - Baja gasto seguro")     
    gdef.registerProcess("Baja gasto seguro") 
    gdefs.addGroup(gdef)
   
    # CUOTAS VENCIDAS SEGUROS
    gdef = GroupDefinition("CRE - Cuotas vencidas seguros")     
    gdef.registerProcess("Cuotas vencidas seguros") 
    gdefs.addGroup(gdef)
        
    # MIGRACION GASTOS SEGURO
    gdef = GroupDefinition("CRE - Migracion gastos seguro")     
    gdef.registerProcess("Migracion gastos seguro") 
    gdefs.addGroup(gdef) 

    # CRE - Revision Tasas Prepara
    gdef = GroupDefinition("CRE - Revision Tasas Prepara")     
    gdef.registerProcess("Revision Tasas Prepara") 
    gdefs.addGroup(gdef)
    
    # CRE - Revision Tasas Proceso
    gdef = GroupDefinition("CRE - Revision Tasas Proceso")     
    gdef.registerProcess("Revision tasas") 
    gdefs.addGroup(gdef)
	
    # CRE - Revision Tasas Post
    gdef = GroupDefinition("CRE - Revision Tasas Post")     
    gdef.registerProcess("Revision Tasas Post") 
    gdefs.addGroup(gdef)  	

    gdef = GroupDefinition("CRE - Revision tasas")
    gdef.registerProcess("Revision Tasas Prepara") 
    gdef.registerProcess("Revision tasas")
    gdef.registerProcess("Revision Tasas Post")    
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")        
    gdef.setExecutionId(1443)
    gdefs.addGroup(gdef)  

    gdef = GroupDefinition("CRE - Apertura Descuentos Compra Facturas")
    gdef.registerProcess("Apertura Descuento masivo facturas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")        
    gdefs.addGroup(gdef)    
    
    
    # VENTA DE CARTERA    
    gdef = GroupDefinition("CRE - Venta de Cartera") 
    gdef.registerProcess("Venta de Cartera")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Categoria Comercial del Cliente")
    gdef.registerProcess("Actualizar Categoria Comercial del Cliente")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1433)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Categoria Comercial del Cliente Sin Categoria")
    gdef.registerProcess("Actualizar Categoria Comercial del Cliente Sin Categoria")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1434)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualiza Riesgo Dolarizado") 
    gdef.registerProcess("Actualiza Riesgo Dolarizado")
    gdef.setExecutionId(1441)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualiza Cliente Dolarizado") 
    gdef.registerProcess("Actualiza Cliente Dolarizado")
    gdef.setExecutionId(1442)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Cobro Comisiones Garantia Otorgadas")
    gdef.registerProcess("Cobro Comisiones de Garantias Otorgadas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1408)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Aviso de Vencimiento de Garantia")
    gdef.registerProcess("Aviso de Vencimiento de Garantia")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1409)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizar Tam-Empresa") #mz , ajusto el nombre por la �
    gdef.registerProcess("Actualizar Tam-Empresa") #mz , ajusto el nombre por la � tocar lo mismo en el process
    gdef.setExecutionId(1401)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Generacion Memos")
    gdef.registerProcess("Genera memo 04")
    gdef.registerProcess("Genera memo 02")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false") 	
    gdef.setExecutionId(1449)
    gdefs.addGroup(gdef)
 
    gdef = GroupDefinition("CRE - MEMO DETALLE")
    gdef.registerProcess("Genera memo 04")
    gdef.setExecutionId(1453)
    gdefs.addGroup(gdef)
 
    gdef = GroupDefinition("CRE - MEMO CABECERA")
    gdef.registerProcess("Genera memo 02")
    gdef.setExecutionId(1454)
    gdefs.addGroup(gdef)
    
    #Consulta NOSIS para SIC 
    gdef = GroupDefinition("CRE - NOSIS Masivo")
    gdef.registerProcess("Consulta NOSIS SIC")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1451)	
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("CRE - Sistema Interno de Calificacion")
    gdef.registerProcess("Sistema Interno de Calificacion")
    gdef.setExecutionId(1452)	
    gdefs.addGroup(gdef)	
	
    gdef = GroupDefinition("CRE - Generacion Memos Archivos")
    gdef.registerProcess("Genera Memos por fecha")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false") 	
    gdef.setExecutionId(1450)	
    gdefs.addGroup(gdef)	
    
    #Agrego Cobro Reservas Topaz POS 
    gdef = GroupDefinition("CRE - Baja Reserva Topaz POS")
    gdef.registerProcess("Cobro Reserva Topaz POS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1600)    
    gdefs.addGroup(gdef)  

# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos Negocios Rurales                                                    #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("NNR - Pago de Obligaciones con Vendedores") 
    gdef.registerProcess("Pago Obligaciones Rurales Vendedores") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

# -------------------------------------------------------------------------------------------------------------------- #
#                                              Procesos Generales                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("GRL - Actualizacion Diaria Historico de Tipos de Cambio") 
    gdef.registerProcess("HistoricoTiposDeCambio") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdef.setExecutionId(401)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Cambio de Fecha de Proceso")
    gdef.registerProcess("Cambio fecha proceso")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Historico de Saldos Diarios y Mensuales") 
    gdef.registerProcess("HistoricoSaldos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdef.setExecutionId(405)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Historico de Saldos Diarios y Mensuales Feriados") 
    gdef.registerProcess("HistoricoSaldosConFeriados") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)    
       
    gdef = GroupDefinition("GRL - Historico de Saldos Diarios y Mensuales para Intereses") 
    gdef.registerProcess("Historico Saldos e Intereses") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(420)     
    gdefs.addGroup(gdef)
        
    gdef = GroupDefinition("GRL - Aplicacion Movimientos OffLine") 
    gdef.registerProcess("Aplicacion Movimientos OffLine") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(404)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Aplicacion Movimientos OffLine C/P")
    gdef.registerProcess("Aplicacion Movimientos OffLine C/P")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)	

    gdef = GroupDefinition("GRL - Actualizacion de Saldos Diarios por Vales") 
    gdef.registerProcess("Actualizacion de saldos diarios por vales")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Baja de asientos al cierre centralizado") 
    gdef.registerProcess("Baja de asientos al cierre centralizado")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")                 
    gdef.setExecutionId(419)
    gdefs.addGroup(gdef)   
    
    
    gdef = GroupDefinition("GRL - Informacion para Central de Riesgos") 
    gdef.registerProcess("Central de Riesgos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
  
    gdef = GroupDefinition("GRL - Reaplica movimientos fecha valor en Saldos Diarios") 
    gdef.registerProcess("Saldos D y M Reaplicacion de movimientos")  
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(409)         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Regeneracion de Historico de Saldos Diarios y Mensuales") 
    gdef.registerProcess("Saldos D y M Regeneracion") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Recalculo Acumuladores Intereses de Historico de Saldos Diarios")     
    gdef.registerProcess("Saldos D y M Recalculo Acumuladores Intereses") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Topes Regulatorios") 
    gdef.registerProcess("Topes Regulatorios Batch") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Marca Inicio de Cierre") 
    gdef.registerProcess("Marca Inicio de Cierre") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdef.setExecutionId(407)
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("GRL - Marca Fin de Cierre") 
    gdef.registerProcess("Marca Fin de Cierre") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdef.setExecutionId(408)
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("GRL - Fin de Asientos Diferidos") 
    gdef.registerProcess("Fin de Asientos Diferidos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(402)
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("GRL - Cierre Sucursales Virtuales") 
    gdef.registerProcess("ServicioCierre")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Actualizar Estadisticas") 
    gdef.registerProcess("Actualizar Estadisticas BD")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Actualizar Estadisticas Migracion") 
    gdef.registerProcess("Actualizar Estadisticas BD Migracion")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Cambio Fecha de Proceso Sucursal") 
    gdef.registerProcess("Cambio Fecha de Proceso Sucursal")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("GRL - Inicializar Atencion de Caja") 
    gdef.registerProcess("Limpia Bandeja de Cajas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

    # COMENTADO PAOLO MIGRACION 5_5
    # gdef = GroupDefinition("GRL - Numeracion de Facturas") 
    # gdef.registerProcess("Numeracion de Facturas") 
    # gdef.setCanBeRootGroup("true")
    # gdef.setSingleton("false")             
    # gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("GRL - Solo Saldos Diarios") 
    gdef.registerProcess("HistoricoSaldosDiariosSinMensuales") 
    gdef.setExecutionId(410)
    gdefs.addGroup(gdef)        

    gdef = GroupDefinition("GRL - Saldos Diarios y Mensuales sin Promedio") 
    gdef.registerProcess("HistoricoSaldosDiariosSinPromedio") 
    gdefs.addGroup(gdef)  

    gdef = GroupDefinition("GRL - Solo Saldos Diarios para Intereses Vista") 
    gdef.registerProcess("HistoricoSaldosDiariosSolo e Intereses") 
    gdefs.addGroup(gdef)        

    gdef = GroupDefinition("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista") 
    gdef.registerProcess("HistoricoSaldos e Intereses sin promedio")
    gdef.setExecutionId(403)
    gdefs.addGroup(gdef)      
    
    gdef = GroupDefinition("GRL - Promedio mensual Saldos Diarios") 
    gdef.registerProcess("Promedio Mensual SD") 
    gdefs.addGroup(gdef)    
    
    gdef = GroupDefinition("GRL - Generacion de facturas intereses vista")     
    gdef.registerProcess("Generacion de facturas intereses vista") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Generacion de facturas intereses prestamos")     
    gdef.registerProcess("Generacion de facturas intereses prestamos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Generacion de facturas chequeras")     
    gdef.registerProcess("Generacion de facturas chequeras") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Recalculo Operaciones Plazo")     
    gdef.registerProcess("Recalculo") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Actualizar nivel de riesgo de clientes")     
    gdef.registerProcess("Actualizar nivel de riesgo de clientes") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
     
    gdef = GroupDefinition("GRL - Altas antecedentes negativos")     
    gdef.registerProcess("Altas antecedentes negativos") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("GRL - Reporte Detalle de Asientos Diarios")
    gdef.registerProcess("Reporte Detalle de Asientos Diarios")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(413)
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("GRL - Cobranza debitos automaticos")     
    gdef.registerProcess("Cobranza debitos automaticos")                      
    gdef.setExecutionId(416)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Envia Correos Canje Interno") 
    gdef.registerProcess("Envia Correos Canje Interno") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Certificados de Retencion")    
    gdef.registerProcess("Impuestos - Certificados de Retencion")    
    gdef.setExecutionId(424)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - MA Bandeja de entrada - Depuracion")
    gdef.registerProcess("MA Bandeja de entrada - Depuracion")
    gdef.setExecutionId(425)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Proceso de Altas Masivas")
    gdef.registerProcess("Proceso de Altas Masivas")
    gdef.registerProcess("Proceso de Altas Masivas - Reporte")
    gdef.registerProcess("Post-Proceso Altas Masivas DJP ACPRIV")
    gdef.setExecutionId(426)
    gdefs.addGroup(gdef)
    
    #ITF - MEP BANDEJA DEBITOS Y CREDITOS MASIVOS
    gdef = GroupDefinition("ITF - MEP BANDEJA DEBITOS Y CREDITOS MASIVOS")
    gdef.registerProcess("Debitos y Creditos Masivos MonoHilo Multi Asiento")
    gdef.registerProcess("MEP IMPACTO - REPORTE")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(301)
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                     Mini Cadena de Cierre Contabilidad                                                 #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("CBL - Mini Cadena Contabilidad")
    gdef.registerProcess("GRL - Baja de asientos al cierre centralizado")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("CBL - Calculo Impuesto Movimiento Moneda Extranjera")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Operaciones cambio retroactiva")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Reaplica movimientos fecha valor en Saldos Diarios_Procesa todos")
    gdef.registerProcess("CBL - Resultados por Tenencia de Moneda Extranjera")
    gdef.registerProcess("CBL - Resultados por Operaciones de Cambio")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Solo Saldos Diarios")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad Actualizar - Fecha Valor")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad")
    gdef.registerProcess("BAL - Generacion de Balance Diario")
    gdef.registerProcess("CBL - Reporte Saldos Diarios Inconsistentes")
    gdef.registerProcess("CBL - Reporte Asientos Abiertos")
    gdef.registerProcess("CONT - Asientos sin Cierre")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)


# ---------------------------------------------------------------------------------------------------------------------- #
#                                     Mini Cadena Tenencia  y Operaciones de Cambio                                      #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("GRL - Mini Cadena Tenencia  y Operaciones de Cambio")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("GRL - Operaciones cambio retroactiva")
    gdef.registerProcess("GRL - Reaplica movimientos fecha valor en Saldos Diarios")
    gdef.registerProcess("CBL - Resultados por Tenencia de Moneda Extranjera")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Resultados por Operaciones de Cambio")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad Actualizar - Fecha Valor")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)



# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos de Cofres                                                           #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("COF - Renovacion y cobro de Cajas de Seguridad")
    gdef.setExecutionId(815)
    gdef.registerProcess("Renovacion de Cajas de Seguridad")
    gdef.registerProcess("Cobro de Cajas de Seguridad")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    
    gdef = GroupDefinition("COF - Generacion Avisos de Cajas de Seguridad") 
    gdef.registerProcess("8103 - Generacion Pre Aviso Vencimiento") 
    gdef.registerProcess("8104 - Generacion Aviso Mora") 
    gdef.registerProcess("8105 - Generacion Aviso Clearing") 
    gdef.registerProcess("GeneracionAvisosCofres") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdef.setExecutionId(816)
    gdefs.addGroup(gdef)    

# -------------------------------------------------------------------------------------------------------------------- #
#                                       Procesos Generacion de Balances                                                #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("BAL - Generacion de Balance Diario") 
    gdef.registerProcess("Balances Diarios") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdef.setExecutionId(707)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("BAL - Generacion de Balance Mensuales") 
    gdef.registerProcess("Balances Mensuales") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    

    #gdef = GroupDefinition("BAL - Balance Diario Cuatro Columnas") 
    #gdef.registerProcess("Balances Diarios Cuatro Columnas")    
    #gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("BAL - Diferencia de Balance") 
    gdef.registerProcess("Diferencia de Balance") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)

# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos Tarjetas de Debito                                                  #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("TJD - Control suspension de tarjetas") 
    gdef.registerProcess("Control suspension de tarjetas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("TJD - Control entrega de tarjetas") 
    gdef.registerProcess("Control entrega de tarjetas") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("TJD - Cargos Tarjetas Debito Pago Sueldo") 
    gdef.registerProcess("Cargos Tarjetas Debito Pago Sueldo") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")     
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("TJD - Cargos Exceso Mov Banred")
    gdef.registerProcess("Cargos Exceso Mov Banred")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)    
    
    #gdef = GroupDefinition("TJD - Cargos Tarjetas Debito Exceso Mov") 
    #gdef.registerProcess("Cargos Tarjetas Debito Exceso Mov") 
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")         
    #gdefs.addGroup(gdef)

    gdef = GroupDefinition("TJD - Resumen TLF") 
    gdef.registerProcess("TP Conciliacion TLF")
    gdef.setCanBeRootGroup("false")
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("TJD - Generar Bandeja Conciliacion TLF") 
    gdef.registerProcess("Bandeja Conciliacion TLF")
    gdef.setCanBeRootGroup("false")
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("TJD - Conciliacion TopazPos")
    gdef.registerProcess("Conciliacion TopazPos - TLF LINK")
    gdef.setCanBeRootGroup("false")
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("TJD - Movimientos procesar POS") 
    gdef.registerProcess("MovsPosProcesar")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("TJD - Crear Bandeja Contable POS") 
    gdef.registerProcess("PosBandeja")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)    
    
    #Agrego Verificacion TLF en TP_TOPAZPOSCONTROL Topaz POS 
    gdef = GroupDefinition("TJD - Transacciones No Conciliadas")
    gdef.registerProcess("TLF Transacciones No Conciliadas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1660)    
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("TJD - Resumen TLF Conciliacion TopazPos")
    gdef.registerProcess("Resumen TLF para conciliacion de TopazPos")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)
    
    # TJD - Conciliacion TopazPos vs TLF Link     
    gdef = GroupDefinition("TJD - Conciliacion TopazPos vs TLF LINK") 
    gdef.registerProcess("TJD - Procesar TLF LINK") 
    gdef.registerProcess("TJD - Resumen TLF Conciliacion TopazPos")
    gdef.registerProcess("TJD - Conciliacion TopazPos") 
    gdef.registerProcess("TJD - Transacciones No Conciliadas")
    gdef.setCanBeRootGroup("true")	
    gdef.setSingleton("false")
    gdef.setExecutionId(1661) 	
    gdefs.addGroup(gdef)
    
    # TJD - Procesar TLF LINK
    gdef = GroupDefinition("TJD - Procesar TLF LINK") 
    gdef.registerProcess("Archivo TLF - LINK") 
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Cobro Comisiones TJD") 
    gdef.registerProcess("Cobro Comisiones TJD")
    gdef.setExecutionId(54) 
    gdefs.addGroup(gdef)
    
# -------------------------------------------------------------------------------------------------------------------- #
#                                            Procesos de Interfases                                                    #
# -------------------------------------------------------------------------------------------------------------------- #

    #ITF Procesar Padron  PUCA (BCRA)
    #gdef = GroupDefinition("ITF - Informe Lavado BCU") 
    #gdef.registerProcess("Informe Lavado BCU")
    #gdef.setCanBeRootGroup("true")
    #gdef.setSingleton("false")
    #gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Generico")
    gdef.registerProcess("Kettle - Disparador de Interfaces")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    
    gdef = GroupDefinition("ITF - BCRA Central de Deudores")
    gdef.setExecutionId(20)
    gdef.registerProcess("BCRA CENDEU")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - BCRA Morosos")
    gdef.setExecutionId(21)
    gdef.registerProcess("BCRA MOREXENT")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Levanta Bandeja Pago Terceros") 
    gdef.registerProcess("Levanta Bandeja Pago Terceros")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef) 
    
    gdef = GroupDefinition("ITF - Levanta Bandeja Recaudaciones") 
    gdef.registerProcess("Levanta Bandeja Recaudaciones")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Levanta Bandeja Mocasist") 
    gdef.registerProcess("Levanta Bandeja Mocasist")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Levanta Bandeja Invegest") 
    gdef.registerProcess("Levanta Bandeja Invegest")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Levanta Bandeja Cartera Morosos") 
    gdef.registerProcess("Levanta Bandeja Cartera Morosos SNF")
    gdef.registerProcess("Levanta Bandeja Cartera Morosos SF")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)    
  
    gdef = GroupDefinition("ITF - Genera Bandeja Retiros Tarjetas") 
    gdef.registerProcess("Genera Bandeja Retiros Tarjetas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Genera Bandeja LectoGrabadora") 
    gdef.registerProcess("Genera Bandeja LectoGrabadora")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Recepcion de Cheques desde PRECODATA")
    gdef.registerProcess("Op 3605 - Cheques Recibidos desde PRECODATA")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Embozado tarjetas Debito")
    gdef.registerProcess("Op 2812 - Embozado tarjetas Debito")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Genera Baneja Solicitudes Chequeras") 
    gdef.registerProcess("Genera Baneja Solicitudes Chequeras")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Novedades de Tarjetas Credito")
    gdef.registerProcess("Op 9966 - Procesar Tarjeta de Credito")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Levanta Bandeja ABM Tarjetas de Credito ") 
    gdef.registerProcess("ABM Tarjetas de Credito")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Conciliaciones") 
    gdef.registerProcess("Genera Bandeja Conciliaciones")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Conciliaciones Diferida") 
    gdef.registerProcess("Genera Bandeja Conciliaciones Diferida")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Contable Vertical") 
    gdef.registerProcess("Genera Bandeja Contable Vertical")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Altas Compra Cartera") 
    gdef.registerProcess("Genera Bandeja Altas Compras Cartera")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Cancelaciones Compra Cartera") 
    gdef.registerProcess("Genera Bandeja Cancelaciones Compra Cartera")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Ventas Diarias") 
    gdef.registerProcess("Genera Bandeja Ventas Diarias")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Pagos a Comercios") 
    gdef.registerProcess("Genera Bandeja Pagos a Comercios")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - TLF Banred") 
    gdef.registerProcess("Genera Bandeja TLF-Banred")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Cheques Banred") 
    gdef.registerProcess("Genera Bandeja Cheques Banred")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Relacion Cuenta-Tarjeta ") 
    gdef.registerProcess("CAF- Envio Relacion Cuenta-Tarjeta")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Movimientos de Tarjetas ") 
    gdef.registerProcess("PBF- Envio Movimientos de Tarjetas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Reclasificacion de Tarjetas") 
    gdef.registerProcess("Reclasificacion de Tarjetas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Apertura Capital e Interes") 
    gdef.registerProcess("Apertura Capital e Interes")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Actualizar Intereses de Tarjetas") 
    gdef.registerProcess("Actualizar Intereses de Tarjetas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Extornar Saldos de Tarjetas") 
    gdef.registerProcess("Extornar Saldos de Tarjetas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Cerear Intereses de Tarjetas") 
    gdef.registerProcess("Cerear Intereses de Tarjetas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Conjuntos Economicos") 
    gdef.registerProcess("Conjuntos Economicos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Envio Cheques devueltos a camara (DEVGIR)") 
    gdef.registerProcess("Envio DEVGIR a camara")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Procesar Clientes en Recupero") 
    gdef.registerProcess("Procesar Clientes en Recupero")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Genera Archivo Preventivo") 
    gdef.registerProcess("Genera ITF_RCT_PREVENTIVO")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Switch de bandejas")
    gdef.registerProcess("Switch de bandejas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Informacion Comercios Courier") 
    gdef.registerProcess("Genera Bandeja de Comercios Courier")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Reversas Banred") 
    gdef.registerProcess("Genera Bandeja TLF-Reversas-Banred")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)  
    
    gdef = GroupDefinition("ITF - Pagos a Sueldos") 
    gdef.registerProcess("Genera Bandeja Pagos Sueldos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)    
       
    gdef = GroupDefinition("ITF - Corrige Calificacion Objetiva") 
    gdef.registerProcess("Corrige Calificacion Objetiva")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("ITF - Corrige Calificacion MOCASIST") 
    gdef.registerProcess("Corrige Calificacion MOCASIST")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("ITF - Extorna Saldos Contingencias") 
    gdef.registerProcess("Extorna Saldos Contingencias")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("ITF - Cargar Saldos Contingencias") 
    gdef.registerProcess("Cargar Saldos Contingencias")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Carga de Movimientos de Tarjetas por Bandeja Contable")
    gdef.registerProcess("Movimientos de Tarjetas por Bandeja Contable")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ITF - Actualizar Fechas de Uso de Tarjetas de Debito")
    gdef.registerProcess("Actualizar Fechas de Uso de Tarjetas de Debito")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - Compra Masiva de Facturas")
    gdef.registerProcess("Genera Lista de Documentos Masiva")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
   
    gdef = GroupDefinition("ITF - Recepcion Morosos Alimentarios BCU") 
    gdef.registerProcess("Morosos Alimentarios BCU") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")    
    gdefs.addGroup(gdef)    
        
    # ITF. INAES INHABILITADOS
    gdef = GroupDefinition("ITF - INHABILITADOS INAES CARGA DESDE ARCHIVO TEXTO PLANO")
    gdef.registerProcess("Carga de Tabla Inhabilitados INAES")
    gdef.setExecutionId(4)
    gdefs.addGroup(gdef)
    # 2.14.15 LK UMOZ
    gdef = GroupDefinition("ITF - LK UMOZ")
    gdef.registerProcess("LK UMOZ")
    gdef.setExecutionId(15)
    gdefs.addGroup(gdef)
    # ITF. LEX DOCTOR SALIDA
    gdef = GroupDefinition("ITF - LexDoctor Salida Listado Clientes")
    gdef.setExecutionId(2)
    gdef.registerProcess("LexDoctor Salida Lista Clientes")
    gdefs.addGroup(gdef)

    # ITF. EMERIX ARCHIVOS PLANOS
    gdef = GroupDefinition("ITF - EMERIX Generacion Archivos Planos")
    gdef.registerProcess("ITF EMERIX Archivos Planos")
    gdefs.addGroup(gdef)
    
    # LK RM - 2.14.2
    gdef = GroupDefinition("ITF - LK RM")
    gdef.registerProcess("LK RM")
    gdef.setExecutionId(124)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # LK – RMOUT 2.14.3
    gdef = GroupDefinition("ITF - LK RMOUT")
    gdef.setExecutionId(163)
    gdef.registerProcess("LK RMOUT")
    gdefs.addGroup(gdef)
    
    # ITF. Carga Padron de Convenios
    gdef = GroupDefinition("ITF - Carga Padron de Convenios")
    gdef.registerProcess("Carga Padron Convenios")
    gdefs.addGroup(gdef)
    
    #ITF - BCRA Padron PFPJ
    gdef = GroupDefinition("ITF - BCRA Padron PFPJ")
    gdef.setExecutionId(3)
    gdef.registerProcess("Kettle-BCRA_PADFYJ")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    #ITF - AFIP Padron
    gdef = GroupDefinition("ITF - AFIP Padron")
    gdef.setExecutionId(5)
    gdef.registerProcess("Kettle-AFIP_PUCA")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    #ITF AGIP - PADRON - 2.2.2 -- 
    gdef = GroupDefinition("ITF - AGIP Padron")
    gdef.setExecutionId(135)
    gdef.registerProcess("AGIP Padron")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    # ANSES - NOVEDADES – 2.4.4
    gdef = GroupDefinition("ANSES - NOVEDADES")
    gdef.registerProcess("ANSES NOVEDADES")
    gdef.setExecutionId(174) 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    
    #ITF - AMCO AC 2.3.1
    gdef = GroupDefinition("ITF - AMCO AC")
    gdef.setExecutionId(22);
    gdef.registerProcess("ITF_AMCO_AC")
    gdefs.addGroup(gdef) 


    # 2.6.10 ITF BCRA NOVCHE RV
    gdef = GroupDefinition("ITF - BCRA NOVCHE RV")
    gdef.setExecutionId(31)
    gdef.registerProcess("ITF_BCRA_NOVCHE_RV")
    gdefs.addGroup(gdef)

    #ITF - AMCO CC 2.3.2
    gdef = GroupDefinition("ITF - AMCO CC")
    gdef.setExecutionId(23);
    gdef.registerProcess("ITF_AMCO_CC")
    gdefs.addGroup(gdef)

    #ITF - AMCO ADHESIONES 2.3.7
    gdef = GroupDefinition("ITF - AMCO ADHESIONES")
    gdef.setExecutionId(63);
    gdef.registerProcess("ITF_AMCO_ADHESIONES")
    gdefs.addGroup(gdef)

    #ITF - AMCO RESUMENES AC 2.3.8
    gdef = GroupDefinition("ITF - AMCO RESUMENES AC MENSUAL")
    gdef.setExecutionId(50);
    gdef.registerProcess("ITF_AMCO_RESUMENES_AC_MENSUAL")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - AMCO RESUMENES AC CUATRIMESTRAL")
    gdef.setExecutionId(51);
    gdef.registerProcess("ITF_AMCO_RESUMENES_AC_CUATRIMESTRAL")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - AMCO RESUMENES AC SEMESTRAL")
    gdef.setExecutionId(52);
    gdef.registerProcess("ITF_AMCO_RESUMENES_AC_SEMESTRAL")
    gdefs.addGroup(gdef)

    #ITF - AMCO RESUMENES CC 2.3.8
    gdef = GroupDefinition("ITF - AMCO RESUMENES CC MENSUAL")
    gdef.setExecutionId(53);
    gdef.registerProcess("ITF_AMCO_RESUMENES_CC")
    gdefs.addGroup(gdef)

    #ITF - AMCO ESPECIALES AC 2.3.9
    gdef = GroupDefinition("ITF - AMCO ESPECIALES AC")
    gdef.setExecutionId(24);
    gdef.registerProcess("ITF_AMCO_ESPECIALES_AC")
    gdefs.addGroup(gdef)

    #ITF - AMCO ESPECIALES CC 2.3.10
    gdef = GroupDefinition("ITF - AMCO ESPECIALES CC")
    gdef.setExecutionId(25);
    gdef.registerProcess("ITF_AMCO_ESPECIALES_CC")
    gdefs.addGroup(gdef)
    #ITF - AFIP IGARG830 2.1.4
    gdef = GroupDefinition("ITF - AFIP IGA RG830")
    gdef.setExecutionId(10)
    gdef.registerProcess("ITF_AFIP_IGARG830")
    gdefs.addGroup(gdef)
    
    #ITF AFIP ECOM-SSMPCPR152 2.12.10
    gdef = GroupDefinition("ITF - ECOM-SSMPCPR152")
    gdef.setExecutionId(60);
    gdef.registerProcess("ITF_ECOM_SSMPCPR152")
    gdefs.addGroup(gdef)
    
    #ITF AFIP ECOM-SSMPCPR153 2.12.11
    gdef = GroupDefinition("ITF - ECOM-SSMPCPR153")
    gdef.setExecutionId(62);
    gdef.registerProcess("ITF_ECOM_SSMPCPR153")
    gdefs.addGroup(gdef)
    
    #ITF - AFIP IGARG2681 2.1.3
    gdef = GroupDefinition("ITF - AFIP IGA RG2681")
    gdef.setExecutionId(11)
    gdef.registerProcess("ITF_AFIP_IGARG2681")
    gdefs.addGroup(gdef)

    #ITF - AFIP IVARG18 2.1.7
    gdef = GroupDefinition("ITF - AFIP IVA RG18")
    gdef.setExecutionId(7)
    gdef.registerProcess("ITF_AFIP_IVARG18")
    gdefs.addGroup(gdef)
    
    #ITF - AFIP IVARG17 2.1.6
    gdef = GroupDefinition("ITF - AFIP IVA RG17")
    gdef.setExecutionId(9)
    gdef.registerProcess("ITF_AFIP_IVARG17")
    gdefs.addGroup(gdef)

    #ITF - AFIP CREDEBPAD 2.1.15
    gdef = GroupDefinition("ITF - AFIP CREDEBPAD")
    gdef.setExecutionId(30);
    gdef.registerProcess("ITF_AFIP_CREDEBPAD")
    gdefs.addGroup(gdef)

    #ITF - AFIP CREDEBPAD 2.1.14
    gdef = GroupDefinition("ITF - AFIP CREDEBPAD WS")
    gdef.setExecutionId(61);
    gdef.registerProcess("ITF_AFIP_CREDEBPAD_WS")
    gdefs.addGroup(gdef)

    #ITF - AFIP - IVASICORER - 2.1.13
    gdef = GroupDefinition("AFIP - IVASICORER")
    gdef.registerProcess("AFIP_IVASICORER")
    gdef.setExecutionId(28)
    gdefs.addGroup(gdef)

    # ITF -Adjunto de correo 
    gdef = GroupDefinition("ITF - Adjunto de Correo")
    gdef.registerProcess("Adjunto de Correo")
    gdefs.addGroup(gdef)

    # ITF -Genero Token
    gdef = GroupDefinition("ITF - Genero Token")
    gdef.setExecutionId(1)
    gdef.registerProcess("Genero Token")
    gdefs.addGroup(gdef)
    
    # ITF -Genero Token
    gdef = GroupDefinition("ITF - Genero Token Interno")
    gdef.setExecutionId(136)
    gdef.registerProcess("Genero Token Interno")
    gdefs.addGroup(gdef)
    
    # ITF -Movimientos Conformados
    gdef = GroupDefinition("ITF - Link Movimientos Conformados")
    gdef.registerProcess("Movimientos Conformados")
    gdef.setExecutionId(29)
    gdefs.addGroup(gdef)
    # ITF - Solicitudes Base SOAT
    gdef = GroupDefinition("ITF - Solicitudes Base SOAT")
    gdef.registerProcess("Solicitudes Base SOAT")
    gdefs.addGroup(gdef)

    # IB BASE CUENTAS
    gdef = GroupDefinition("ITF - IB BASECUENTAS")
    gdef.registerProcess("IB BASECUENTAS")
    gdef.setExecutionId(132)
    gdefs.addGroup(gdef)
    
    # ITF - COELSA FERIADOS
    gdef = GroupDefinition("ITF - COELSA FERIADOS")
    gdef.setExecutionId(187)
    gdef.registerProcess("COELSA FERIADOS")
    gdefs.addGroup(gdef)

    # ITF - COELSA DPF DOLARES PRESENTADOS RECIBIDOS
    gdef = GroupDefinition("ITF - COELSA DPF DOLARES Presentados Recibidos")
    gdef.registerProcess("COELSA DPF DOLARES PRESENTADOS RECIBIDOS")
    gdefs.addGroup(gdef)

    # Clearing Validacion Cheques Entrantes
    gdef = GroupDefinition("ITF - Clearing Validacion Cheques Entrantes")
    gdef.setExecutionId(47)
    gdef.registerProcess("Clearing Validacion Cheques Entrantes")
    gdefs.addGroup(gdef)

    # ITF - COELSA CHEQUES RECHAZADOS RECIBIDOS
    gdef = GroupDefinition("ITF - COELSA Cheques Rechazados Recibidos")
    gdef.registerProcess("COELSA CHEQUES RECHAZADOS RECIBIDOS")
    gdefs.addGroup(gdef)

    # ITF - COELSA PLAZO FIJO PRESENTADOS DOLARES
    gdef = GroupDefinition("ITF - COELSA Plazo Fijo Presentados Dolares")
    gdef.registerProcess("COELSA PLAZO FIJO PRESENTADOS DOLARES")
    gdefs.addGroup(gdef)

    # ITF - COELSA PLAZO FIJO RECHAZADOS DOLARES
    gdef = GroupDefinition("ITF - COELSA Plazo Fijo Rechazados Dolares")
    gdef.registerProcess("COELSA PLAZO FIJO RECHAZADOS DOLARES")
    gdefs.addGroup(gdef)

    # ITF - COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS PESOS
    gdef = GroupDefinition("ITF - COELSA Transferencias Minoristas Recibidas Pesos")
    gdef.registerProcess("COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS PESOS")
    gdefs.addGroup(gdef)

    # ITF - COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS DOLARES
    gdef = GroupDefinition("ITF - COELSA Transferencias Minoristas Recibidas Dolares")
    gdef.registerProcess("COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS DOLARES")
    gdefs.addGroup(gdef)

    # ITF - COELSA TRANSFERENCIAS MINORISTAS RECHAZADAS RECIBIDAS
    gdef = GroupDefinition("ITF - COELSA Transferencias Minoristas Rechazadas Recibidas")
    gdef.registerProcess("COELSA TRANSFERENCIAS MINORISTAS RECHAZADAS RECIBIDAS")
    gdefs.addGroup(gdef)
    
    # ITF - COELSA CHEQUES PRESENTADOS ENVIADOS 2.8.22
    gdef = GroupDefinition("ITF - COELSA Cheques Presentados Enviados")
    gdef.setExecutionId(42)
    gdef.registerProcess("ITF COELSA CHEQUES TERCEROS A ENVIAR")
    gdefs.addGroup(gdef)

    # Actualiza Maestro Transferencias Norix - Ndesx
    gdef = GroupDefinition("ITF ACTUALIZA MAESTRO TRANSFERENCIAS NORIX NDESX")
    gdef.setExecutionId(44) # AGREGAR ID DE EJECUCIÓN
    gdef.registerProcess("ACT_MAESTRO_TR_NX")
    gdefs.addGroup(gdef)

    # ITF - AOJ BASE
    gdef = GroupDefinition("ITF - AOJ BASE")
    gdef.setExecutionId(8)
    gdef.registerProcess("AOJ BASE")
    gdefs.addGroup(gdef)

    # ITF COELSA INFORMAR CHEQUES PROPIOS RECHAZADOS
    gdef = GroupDefinition("ITF - COELSA INFORMAR CHEQUES PROPIOS RECHAZADOS")
    gdef.setExecutionId(36)
    gdef.registerProcess("COELSA INFORMAR CHEQUES PROPIOS RECHAZADOS")
    gdefs.addGroup(gdef)

    # ITF COELSA CHEQUES Y DPF TERCEROS RECHAZADOS
    gdef = GroupDefinition("ITF - COELSA CHEQUES Y DPF TERCEROS RECHAZADOS")
    gdef.setExecutionId(38)
    gdef.registerProcess("ITF COELSA CHEQUES Y DPF TERCEROS RECHAZADOS")
    gdefs.addGroup(gdef)
    
    # ITF - COELSA DPFD RECHAZADOS
    gdef = GroupDefinition("ITF - COELSA DPF Dolares rechazados recibidos")
    gdef.setExecutionId(41)
    gdef.registerProcess("ITF COELSA DPFD TERCEROS RECHAZADOS")
    gdefs.addGroup(gdef)

    # ITF COELSA DPF PROPIOS RECHAZADOS A ENVIAR 2.8.5
    gdef = GroupDefinition("ITF - COELSA DPF PROPIOS RECHAZADOS A ENVIAR")
    gdef.setExecutionId(39)
    gdef.registerProcess("COELSA ENVIO DPF PROPIOS RECHAZADOS")
    gdefs.addGroup(gdef)

    # ITF COELSA DPF DOLARES TERCEROS A ENVIAR 2.8.6
    gdef = GroupDefinition("ITF - COELSA ENVIO DPF DOLARES TERCEROS")
    gdef.setExecutionId(40)
    gdef.registerProcess("COELSA ENVIO DPF DOLARES TERCEROS")
    gdefs.addGroup(gdef)

    # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.15
    gdef = GroupDefinition("ITF - COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES")
    gdef.setExecutionId(162)
    gdef.registerProcess("COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES")
    gdefs.addGroup(gdef)

    # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.44
    gdef = GroupDefinition("ITF - COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS")
    gdef.setExecutionId(161)
    gdef.registerProcess("COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS")
    gdefs.addGroup(gdef)

    # ITF DPFD - GENERACION ARCHIVO IMAGENES Y ZIP ENVIADOS 2.8.48 y 2.8.49
    gdef = GroupDefinition("ITF - COELSA DPFD")
    gdef.setExecutionId(45)
    gdef.registerProcess("GENERACION ARCHIVO DPFD PRESENTADOS ENVIADOS")
    gdef.registerProcess("GENERACION ARCHIVO ZIP DPFD PRESENTADOS ENVIADOS")
    gdefs.addGroup(gdef)

    # ITF - 2.8.68 CLS - EC_CANJE
    gdef = GroupDefinition("ITF - CLS EC_CANJE")
    gdef.setExecutionId(450)
    gdef.registerProcess("CLS - EC_CANJE")
    gdefs.addGroup(gdef)
    
    # ITF RCTES PADRON IMPUESTOS 2.21.1
    gdef = GroupDefinition("ITF - Padron impuestos DGR Corrientes")
    gdef.registerProcess("Padron impuestos DGR")
    gdef.setExecutionId(225)
    gdefs.addGroup(gdef)       
    
        
     
    # ITF - CAUSAS JUDICIALES - 2.12.18
    gdef = GroupDefinition("ITF - ECOM - Causas Judiciales Activas")
    gdef.setExecutionId(117)
    gdef.registerProcess("Causas Judiciales Activas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    # ITF - CAUSAS JUDICIALES - 2.12.19 
    gdef = GroupDefinition("ITF - ECOM - Causas Judiciales Inactivas")
    gdef.setExecutionId(118)
    gdef.registerProcess("Causas Judiciales Inactivas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    # ITF - CAUSAS JUDICIALES - 2.12.20 
    gdef = GroupDefinition("ITF - ECOM - Causas Judiciales Transferidas")
    gdef.setExecutionId(119)
    gdef.registerProcess("Causas Judiciales Transferidas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    # ITF - CAUSAS JUDICIALES - 2.12.21 
    gdef = GroupDefinition("ITF - ECOM - Causas Judiciales Padron Completo")
    gdef.setExecutionId(120)
    gdef.registerProcess("Causas Judiciales Padron Completo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    # ITF - CAUSAS JUDICIALES - 2.12.18 - 2.12.19 - 2.12.20 
    gdef = GroupDefinition("ITF - ECOM - Causas Judiciales")
    gdef.setExecutionId(121)
    gdef.registerProcess("Causas Judiciales")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    # ITF ADINTAR DEUDASCTA
    gdef = GroupDefinition("ITF - ADINTAR DEUDASCTA")
    gdef.registerProcess("ADINTAR DEUDASCTA")
    gdef.setExecutionId(16)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    # ITF ADINTAR USUARIOS
    gdef = GroupDefinition("ITF - ADINTAR USUARIOS")
    gdef.registerProcess("ADINTAR USUARIOS")
    gdef.setExecutionId(17)
    gdefs.addGroup(gdef)

    # ITF ADINTAR SALDOS
    gdef = GroupDefinition("ITF - ADINTAR SALDOS")
    gdef.registerProcess("ADINTAR SALDOS")
    gdef.setExecutionId(18)
    gdef.setSingleton("true")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)

    # ITF - ADINTAR AHORA12 1.3.5
    gdef = GroupDefinition("ITF - ADINTAR AHORA12")
    gdef.setExecutionId(90)
    gdef.registerProcess("AHORA 12")
    gdefs.addGroup(gdef)

    # ITF ADINTAR DEUDAS PLASTICOS
    gdef = GroupDefinition("ITF - ADINTAR DEUDAS PLASTICOS")
    gdef.registerProcess("ADINTAR DEUDAS PLASTICOS")
    gdef.setExecutionId(19)
    gdef.setSingleton("true")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)
    
    # ITF ADINTAR CARGOS
    gdef = GroupDefinition("ITF - ADINTAR CARGOS")
    gdef.registerProcess("ADINTAR CARGOS")
    gdef.setExecutionId(48)
    gdefs.addGroup(gdef)  

    # ITF ADINTAR TASAS
    gdef = GroupDefinition("ITF - ADINTAR TASAS")
    gdef.registerProcess("ADINTAR TASAS")
    gdef.setExecutionId(49)
    gdefs.addGroup(gdef)
    
    # ITF - 2.14.9 LK - NORIX
    gdef = GroupDefinition("ITF - LINK ORIGINANTE")
    gdef.setExecutionId(137)
    gdef.registerProcess("LK - NORIX")
    gdefs.addGroup(gdef)

    # ITF - 2.14.10 LK - NDESX
    gdef = GroupDefinition("ITF - LINK DESTINATARIO")
    gdef.setExecutionId(138)
    gdef.registerProcess("LK - NDESX")
    gdefs.addGroup(gdef)

    # ITF - 2.14.11 LK - CLI
    gdef = GroupDefinition("ITF - LINK CLI")
    gdef.setExecutionId(27)
    gdef.registerProcess("LK - CLI")
    gdefs.addGroup(gdef)


    # ITF - 2.12.6 ECOM-SSMALTPR052
    gdef = GroupDefinition("ITF - Altas de Prestamos al SSM 052")
    gdef.setExecutionId(159)
    gdef.registerProcess("Prestamos al SSM 052")
    gdefs.addGroup(gdef)

    # ITF - 2.12.8 ECOM-SSMALTPR053
    gdef = GroupDefinition("ITF - Altas de Prestamos al SSM 053")
    gdef.setExecutionId(160)
    gdef.registerProcess("Prestamos al SSM 053")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Alta Inhabilitacion INAE") 
    gdef.registerProcess("Alta Inhabilitacion INAE") 
    gdefs.addGroup(gdef)

    #ITF BEE - REFTRANSFER 2.7.1
    gdef = GroupDefinition("ITF - BEE REFTRANSFER")
    gdef.setExecutionId(218);
    gdef.registerProcess("BEE REFTRANSFER")
    gdefs.addGroup(gdef)
	
	#ITF - UNTD IMPUESTOS 1.19.8
    gdef = GroupDefinition("ITF - UNTD IMPUESTOS")
    gdef.setExecutionId(219)
    gdef.registerProcess("ITF_UNTD_IMPUESTOS")
    gdefs.addGroup(gdef)
	
	#ITF - SOS IPC 1.16.11
    gdef = GroupDefinition("ITF - SOS IPC")
    gdef.setExecutionId(220)
    gdef.registerProcess("ITF_SOS_IPC")
    gdefs.addGroup(gdef)

    #ITF - 1.29.29
    gdef = GroupDefinition("ITF - SOS IGR")
    gdef.setExecutionId(514)
    gdef.registerProcess("SOS ACTUALIZA RIESGO")
    gdefs.addGroup(gdef)

    #ITF - 2.19.6.2 RP-PADCARESP_SECH
    gdef = GroupDefinition("ITF - CARGA PADRON CONVENIOS SAMEEP SECHEEP")
    gdef.setExecutionId(221)
    gdef.registerProcess("ITF PADRON CONVENIOS SA/SE")
    gdefs.addGroup(gdef)
    
    #ITF - 2.19.6.2 RP-PADCARESP_SECH
    gdef = GroupDefinition("ITF - CARGA PADRON CONVENIOS SECHEEP")
    gdef.setExecutionId(237)
    gdef.registerProcess("ITF PADRON CONVENIOS SACHEEP")
    gdefs.addGroup(gdef)

    #ITF - AFIP SITEROP 2.1.18
    gdef = GroupDefinition("ITF - AFIP SITEROP")
    gdef.setExecutionId(224);
    gdef.registerProcess("ITF AFIP SITEROP")
    gdefs.addGroup(gdef)

    #RRII AFIP SITERDOM 2.1.19
    gdef = GroupDefinition("RPT - AFIP SITERDOM")
    gdef.setExecutionId(228)
    gdef.registerProcess("RPT_AFIP_SITERDOM")
    gdefs.addGroup(gdef)

    #2.1.20 AFIP - SITEREX
    gdef = GroupDefinition("RPT - AFIP SITEREX")
    gdef.setExecutionId(227)
    gdef.registerProcess("ITF SITEREX")
    gdefs.addGroup(gdef)

    # OPERACIONES ACTIVAS
    gdef = GroupDefinition("RPT - RRII Operaciones Activas")
    gdef.setExecutionId(1242)

    gdef.registerProcess("RRII Operaciones Activas")
    gdefs.addGroup(gdef)

    #2.12.15 - 2.12.16 ECOM-SSMREPR15x
    gdef = GroupDefinition("ITF - ECOM RECHAZOS NOVEDADES")
    gdef.setExecutionId(229)
    gdef.registerProcess("ECOM Rechazos Novedades")
    gdefs.addGroup(gdef)

    #2.14.80 LK - TRX Comisiones
    gdef = GroupDefinition("ITF - LK TJD - Cobro Comisiones")
    gdef.setExecutionId(231)
    gdef.registerProcess("LK TRX - Comisiones")
    gdefs.addGroup(gdef)

    # 1.16.13 SOS - Transferencias
    gdef = GroupDefinition("ITF - SOS Transferencias")
    gdef.setExecutionId(234)
    gdef.registerProcess("SOS Transferencias")
    gdefs.addGroup(gdef)

    # 1.16.12 UIF 68/2013 - Agencieros  
    gdef = GroupDefinition("ITF - SOS Agencieros")
    gdef.setExecutionId(235)
    gdef.registerProcess("SOS Agencieros")
    gdefs.addGroup(gdef)

    # 1.16.12 SOS - LAVADOPERDFILDET
    gdef = GroupDefinition("ITF - SOS Lavado Perfil Det")
    gdef.setExecutionId(236)
    gdef.registerProcess("SOS LAVADOPERDFILDET")
    gdefs.addGroup(gdef)

    #ITF - 1.11.14 I2000-IMPUESTOS
    gdef = GroupDefinition("ITF - I2000 IMPUESTOS")
    gdef.setExecutionId(222)
    gdef.registerProcess("ITF I2000 IMPUESTOS")
    gdefs.addGroup(gdef)

    # 1.11.13 I2000 - OPCAM
    gdef = GroupDefinition("ITF - I2000 OPCAM")
    gdef.setExecutionId(250)
    gdef.registerProcess("I2000 OPCAM")
    gdefs.addGroup(gdef)

    #ITF - 1.19.7 UNTD - SYNC PLANCTAS
    gdef = GroupDefinition("ITF - UNTD SYNC PLANCTAS")
    gdef.setExecutionId(223)
    gdef.registerProcess("ITF UNTD SYNC PLANCTAS")
    gdefs.addGroup(gdef)

    # 1.19.9 UNTD OPCAM
    gdef = GroupDefinition("ITF - UNTD OPCAM")
    gdef.setExecutionId(251)
    gdef.registerProcess("UNTD OPCAM")
    gdefs.addGroup(gdef)

    # 1.3.29 AD - OPCAM
    gdef = GroupDefinition("ITF - ADINTAR OPCAM")
    gdef.registerProcess("AD OPCAM")
    gdef.setExecutionId(252)
    gdef.setSingleton("true")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)

# -------------------------------------------------------------------------------------------------------------------- #
#                                    Procesos Generacion de Estados de Cuenta                                          #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("EEC - Generacion de Estados de Cuenta Mensuales") 
    gdef.registerProcess("EstadosdeCuentaM")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")    
    gdefs.addGroup(gdef)
           
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta Parciales") 
    gdef.registerProcess("EstadosdeCuentaP")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta Diarios") 
    gdef.registerProcess("EstadosdeCuentaJ")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta Semanal") 
    gdef.registerProcess("EstadosdeCuentaS")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta Decadarial (10 dias)") 
    gdef.registerProcess("EstadosdeCuentaE")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta Quincenal (15 dias)") 
    gdef.registerProcess("EstadosdeCuentaQ")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("EEC - Generacion Archivo Estados de Cuenta") 
    gdef.registerProcess("Genera Archivos Estado Cuenta")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta Trimestrales") 
    gdef.registerProcess("EstadosdeCuentaT")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta LEGALES - Mensuales") 
    gdef.registerProcess("EstadosdeCuentaLM")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta LEGALES - Trimestral") 
    gdef.registerProcess("EstadosdeCuentaLT")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Generacion Estados de Cuenta LEGALES - Anual") 
    gdef.registerProcess("EstadosdeCuentaLA")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    #Estado de cuenta mensual
    gdef = GroupDefinition("EEC - Estado de cuenta Mensual Datos PA")
    gdef.registerProcess("EstadosdeCuentaKetMDATOSPA")
    gdef.setExecutionId(68)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Estado de cuenta Mensual Reporte PA")
    gdef.registerProcess("EstadosdeCuentaKetMREPPA")
    gdef.setExecutionId(69)
    gdefs.addGroup(gdef)
    #Estado de cuenta Semestral
    gdef = GroupDefinition("EEC - Estado de cuenta Semestral Datos PA")
    gdef.registerProcess("EstadosdeCuentaKetZDATOSPA")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Estado de cuenta Semestral Reporte PA")
    gdef.registerProcess("EstadosdeCuentaKetZREPPA")
    gdefs.addGroup(gdef)
    #Estado de cuenta Cuatrimestral
    gdef = GroupDefinition("EEC - Estado de cuenta Cuatrimestral Datos PA")
    gdef.registerProcess("EstadosdeCuentaKetCDATOSPA")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("EEC - Estado de cuenta Cuatrimestral Reporte PA")
    gdef.registerProcess("EstadosdeCuentaKetCREPPA")
    gdefs.addGroup(gdef)
    
    #Estados de cuenta en Kettle   
    gdef = GroupDefinition("EEC - Estado de cuenta Kettle Mensual")
    gdef.registerProcess("EstadosdeCuentaKetM")
    gdef.setExecutionId(823)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VTA - Cargo cuenta inmovilizada")
    gdef.registerProcess("Cargo cuenta inmovilizada")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(844)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CLE - Rechazo de Canje Interno")
    gdef.registerProcess("Rechazo de cheques sin fondos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(847)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Cheques Rechazados por depositaria")
    gdef.registerProcess("Cheques rechazados por depositaria")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Cobro Solicitudes Canje Interno") 
    gdef.registerProcess("Cobra Solicitudes Canje Interno") 
    gdefs.addGroup(gdef)
    
    
# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos de Valores                                                          #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("VAL - Pago de Cupon") 
    gdef.registerProcess("Valores - Pago de Cupon") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VAL - Cancelacion de Valores")
    gdef.registerProcess("Cancelacion Valores") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef) 

    gdef = GroupDefinition("VAL - Cancelacion de Valores Proyeccion")     
    gdef.registerProcess("Cancelacion Valores Proyeccion") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)  

    gdef = GroupDefinition("VAL - Valuacion Por Cotizacion") 
    gdef.registerProcess("Valuacion Por Cotizacion") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VAL - Proyeccion Valores") 
    gdef.registerProcess("Valores - Proyeccion") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VAL - Traslado Cartera de Ejecutivo")
    gdef.registerProcess("TrasladoCartera")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("VAL - Actualizacion de Titulos")
    gdef.registerProcess("Actualizacion Titulos")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VAL - Valores Incremento Participacion") 
    gdef.registerProcess("Valores Incremento Participacion")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)  
    
    gdef = GroupDefinition("VAL - Amortizacion de Cupon") 
    gdef.registerProcess("Valores - Amortizacion de Cupon") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)
                    
    gdef = GroupDefinition("VAL - Pago y Amortizacion de Cupon") 
    gdef.registerProcess("Valores - Pago y Amortizacion de Cupon") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)    
    
# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos Pagos a Comercios                                                   #
# -------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("COM - Liquidacion de Ventas") 
    gdef.registerProcess("Liquidacion de Ventas") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("COM - Adelanto de Cupones") 
    gdef.registerProcess("Adelanto por cupones") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("COM - Liquidacion de Cupones VISA") 
    gdef.registerProcess("Liquidacion de cupones visa") 
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("COM - Liquidacion de Cupones AX Y AC")    
    gdef.registerProcess("Liquidacion de cupones Amex y Argencard") 
    gdef.setSingleton("false")         	
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("COM - Generacion y Numeracion de Cheques") 
    gdef.registerProcess("Numeracion y renumeracion de cheques") 
    gdefs.addGroup(gdef)  
    
    gdef = GroupDefinition("COM - Impresion Cheques") 
    gdef.registerProcess("ImpresionLetrasCambio") 
    gdefs.addGroup(gdef) 
    
    gdef.registerProcess("ITF - Pagos a Comercios")
    gdef.registerProcess("COM - Liquidacion de Cupones AX Y AC")     
    gdefs.addGroup(gdef)
# -------------------------------------------------------------------------------------------------------------------- #
#                                         Procesos Tarjetas de Credito                                                 #
# -------------------------------------------------------------------------------------------------------------------- #
            
    gdef = GroupDefinition("TJC - Bajar Saldos duplicados")
    gdef.registerProcess("Bajar Saldos duplicados - Tarjetas de Credito") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("TJC - Habilita Bandeja contabilidad TJC")
    gdef.registerProcess("Habilita Bandeja contabilidad TJC") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("TJC - Cobro tarjeta de credito")
    gdef.registerProcess("Cobro tarjeta de credito") 
    gdef.setExecutionId(827)
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                            Grupos de Procesos que ejecutan a Demanda                                                   #
# ---------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("    DIA - Cambio Fecha Sucursales Virtuales")    
    gdef.registerProcess("GRL - Cambio Fecha de Proceso Sucursal")
    gdef.registerProcess("GRL - Cierre Sucursales Virtuales") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - BANRED Procesamiento de Archivos")    
    gdef.registerProcess("ITF - TLF Banred")
    gdef.registerProcess("ITF - Cheques Banred") 
    gdef.registerProcess("VTA - Bandeja Entrada BANRED")     
    gdef.registerProcess("CBL - Procesar Bandeja Contable BNR")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")   
    gdef.registerProcess("CLE - Actualizacion Saldos Pendientes")   
    gdefs.addGroup(gdef)

    #gdef = GroupDefinition("TECNISEGUR - Procesamiento de Archivos")    
    gdef.registerProcess("VTA - Bandeja Entrada Buzones") 
    gdef.registerProcess("CBL - Procesar Bandeja Contable TCH") 
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine") 
    gdef.registerProcess("CRE - Recepcion Pagos por Buzon")
    gdef.registerProcess("CLE - Actualizacion Saldos Pendientes")   
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                             Grupos de Procesos para agregar en las cadenas                                             #
# ---------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("CBL - Procesar Bandeja Vertical")    
    gdef.registerProcess("ITF - Contable Vertical")
    gdef.registerProcess("CBL - Procesar Registros Contables") 
    gdef.setCanBeRootGroup("false")        
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("TJC - Procesar Informacion Tarjetas")    
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")                
    gdef.setCanBeRootGroup("false")        
    gdefs.addGroup(gdef)

# -------------------------------------------------------------------------------------------------------------------- #
#                                            Procesos de Clientes                                                      #
# -------------------------------------------------------------------------------------------------------------------- #
 
    gdef = GroupDefinition("CLI - Servicio Financiero Personas Juridicas")
    gdef.registerProcess("Servicio Financiero Personas Juridicas")
    gdef.setExecutionId(601)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Servicio Financiero Personas Fisicas")
    gdef.registerProcess("Servicio Financiero Personas Fisicas")
    gdef.setExecutionId(602)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Perfil Documental")
    gdef.registerProcess("Perfil Documental")
    gdef.setExecutionId(603)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Asignacion Masiva de Paquetes")
    gdef.registerProcess("Asignacion Masiva de Paquetes a Clientes")
    gdef.setExecutionId(604)
    gdefs.addGroup(gdef)

    
# ---------------------------------------------------------------------------------------------------------------------- #
#                                              Cadena de Cierre de Pasivas                                               #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("     DIA - Procesos de Cierre Pasivas")
    gdef.registerProcess("GRL - Control previo al Cierre Diario")
    gdef.registerProcess("GRL - Marca Inicio de Cierre")
    gdef.registerProcess("GRL - Baja de asientos al cierre centralizado")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio") 
    gdef.registerProcess("CLI - Servicio Financiero Personas Juridicas")
    gdef.registerProcess("CLI - Servicio Financiero Personas Fisicas")
    gdef.registerProcess("CLI - Perfil Documental")
    gdef.registerProcess("ITF - LexDoctor Salida Listado Clientes")
    gdef.registerProcess("VTA - Reversa de letras y cheques")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Cobertura entre Grupos de Cuentas") 
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Reservas Sobre Saldos")
    gdef.registerProcess("VTA - Cobranza Cargos Diferidos")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Comision Mantenimiento de Cuentas Vista")
    gdef.registerProcess("VTA - Comision Mantenimiento Banca Empresa")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Control de Paquete y Campanias")
    gdef.registerProcess("VTA - Cargos por Mantenimiento de Paquete")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Instrucciones de Traspaso entre Cuentas")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista") 
    gdef.registerProcess("VTA - Intereses Vista Saldo o Promedio Pago")
    gdef.registerProcess("VTA - Notificacion por Comisiones Pendientes")
    gdef.registerProcess("VTA - Pago Intereses Vista Saldos Inmovilizados")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Cambio de Rubro Vista") 
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Bloqueo Cuentas Vista inmovilizadas")
    gdef.registerProcess("Proceso - Corrimiento Vencimiento DPF")
    gdef.registerProcess("DPF - Inmovilizar saldos")
    gdef.registerProcess("CBL - Cambio de Rubro por Vencido o Forzado")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Devengamiento Plazo Extorno Contabilizacion")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales") 
    gdef.registerProcess("EEC - Estado de cuenta Kettle Mensual")
    gdef.registerProcess("GRL - Marca Fin de Cierre")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(1701)
    gdef.setSingleton("false")    
    gdefs.addGroup(gdef) 



# ------------------------------------------------------------------------------------------------------------------ #
#                                            Cadena de Apertura de pasivas                                           #
# ------------------------------------------------------------------------------------------------------------------ #
    
    gdef = GroupDefinition("    DIA - Procesos de Apertura")
    gdef.registerProcess("GRL - Cambio de Fecha de Proceso")
    gdef.registerProcess("GRL - Cambio de Fecha de Sucursales")
    gdef.registerProcess("GRL - Marca Comienzo Inicio del dia")
    gdef.registerProcess("DPF - Pago Periodico de Intereses")   
    gdef.registerProcess("DPF - Renovacion o Cancelacion")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("DPF - Acreditacion DPF UVAUVI")
    gdef.registerProcess("VTA - Reserva Cobranza Cargos Diferidos")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("COF - Renovacion de Cajas de Seguridad") 
    gdef.registerProcess("COF - Cobro de Cajas de Seguridad") 
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Fin de Asientos Diferidos")
    gdef.registerProcess("GRL - Marca Fin Inicio del dia")
    gdef.setSingleton("true")         
    gdef.setExecutionId(1703)
    gdefs.addGroup(gdef)    

# ---------------------------------------------------------------------------------------------------------------------- #
#                                              Cadena de Cierre                                                          #
# ---------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("     DIA - Procesos de Cierre")
    gdef.registerProcess("GRL - Control previo al Cierre Diario")
    gdef.registerProcess("GRL - Marca Inicio de Cierre")
    gdef.registerProcess("GRL - Baja de asientos al cierre centralizado")
    gdef.registerProcess("CAJ - Carga Saldos Caja Historico")
    gdef.registerProcess("VTA - Cobro Pregiro")
    gdef.registerProcess("TJD - Cargos Exceso Mov Banred")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("VTA - Instrucciones de Traspaso entre Cuentas")
    gdef.registerProcess("ITF - Levanta Bandeja Recaudaciones")
    gdef.registerProcess("RCT - Integracion recaudaciones recibidas")
    gdef.registerProcess("RCT - Debitos Automaticos")
    gdef.registerProcess("RCT - Rendicion de cobranza")
    gdef.registerProcess("CRE - Cobranza Automatica")
    gdef.registerProcess("VTA - Cobranza Cargos Diferidos")
    gdef.registerProcess("VTA - Cargos Movimientos Cruzados")
    gdef.registerProcess("TJD - Cargos Tarjetas Debito Pago Sueldo")
    gdef.registerProcess("VTA - Cargos por Mantenimiento de Paquete")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Cobertura entre Grupos de Cuentas")
    gdef.registerProcess("GRL - Reaplica movimientos fecha valor en Saldos Diarios")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales para Intereses")
    gdef.registerProcess("VTA - Intereses Vista Saldo o Promedio Pago")
    gdef.registerProcess("CRE - Cambio Rubro Cartera Comprada")
    #gdef.registerProcess("CBL - Cambio de Rubro por Vencido o Forzado")
    # ----- Cambios en los procesos de Garantias -------------------------
    #gdef.registerProcess("CRE - Extorno Asiento de Garantias Computables")
    gdef.registerProcess("CBL - Borrar Garantias Computables")
    gdef.registerProcess("CBL - Borrar Garantias NO Computables")
    #gdef.registerProcess("CRE - Deduccion de garantias")
    #gdef.registerProcess("CBL - Distribucion de Garantias NO Deducidas")    
    gdef.registerProcess("CRE - Marcar saldos garantizados")
    #gdef.registerProcess("CRE - Contabilizacion Deduccion de garantias")        
    gdef.registerProcess("CBL - Cambio de Rubro por Vdo o Forzado Garantia")
   # ----- Cambios por la calificacion de Clientes -----------------------
    gdef.registerProcess("CLI - Calificacion Cliente por Cartera")
    gdef.registerProcess("CLI - Calificacion Cliente Banco Central")
    gdef.registerProcess("CLI - Calificacion MOCASIST Garantias")   
    gdef.registerProcess("CLI - Calificacion Objetiva - Inicializacion")    
    gdef.registerProcess("CLI - Calificacion Objetiva")
    gdef.registerProcess("CLI - Contagio de Calificacion Objetiva")
    gdef.registerProcess("CLI - Calificacion Subjetiva CONTAGIO")
    gdef.registerProcess("CLI - Calificacion Resultante")
    gdef.registerProcess("CLI - Calificacion Resultante - Contagio")
    gdef.registerProcess("CLI - Ajuste de Contagio por Subjetiva")
   # ---------------------------------------------------------------------
    gdef.registerProcess("CBL - Devengamiento Plazo")
    gdef.registerProcess("CBL - Exposicion de Sobregiros")
    gdef.registerProcess("VTA - Control Lineas de Credito Consumo por Acuerdos Sobregiro")
    gdef.registerProcess("VTA - Cancelacion y Renovacion de Acuerdos y Sobregiros")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Resultados por Tenencia de Moneda Extranjera")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Resultados por Operaciones de Cambio")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales")
    gdef.registerProcess("EEC - Generacion Estados de Cuenta Diarios")
    gdef.registerProcess("EEC - Generacion Archivo Estados de Cuenta")
    gdef.registerProcess("TJD - Control suspension de tarjetas")
    gdef.registerProcess("TJD - Control entrega de tarjetas")
    gdef.registerProcess("CLI - Control de Clientes con duplicacion de integracion")
    gdef.registerProcess("CLI - Suspension Poderes por Infractores de Cheques")
    gdef.registerProcess("CLI - Rechazar Solicitud Integrante Juzgado")
    gdef.registerProcess("CLI - Rechazar Solicitud Activar-Inactivar Causa")
    gdef.registerProcess("CONT - Asientos sin Cierre")
    gdef.registerProcess("GRL - Marca Fin de Cierre")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)


# ------------------------------------------------------------------------------------------------------------------ #
#                                            Cadena de Apertura                                                      #
# ------------------------------------------------------------------------------------------------------------------ #
    
    gdef = GroupDefinition("    DIA - Procesos de Apertura")
    gdef.registerProcess("GRL - Inicializar Atencion de Caja")     
    gdef.registerProcess("GRL - Fin de Asientos Diferidos")
    gdef.registerProcess("CLE - Recepcion de Cheques Girados")
    gdef.registerProcess("VTA - Alta de Acuerdos y Sobregiros") 
    gdef.registerProcess("DPF - Pago Periodico de Intereses") 
    gdef.registerProcess("DPF - Renovacion o Cancelacion")
    gdef.registerProcess("ITF - Levanta Bandeja Pago Terceros")
    gdef.registerProcess("PCT - Integracion de Pagos Recibidos")
    gdef.registerProcess("PCT - Creditos Automaticos")
    gdef.registerProcess("CBL - Extorno Exposicion de Sobregiros") 
    gdef.registerProcess("CLE - Contabilizacion del Envio a Camara")  
    #gdef.registerProcess("CLE - Cambio de Rubro Contabilizacion de Cheques Pendientes") 
    gdef.registerProcess("TJC - Procesar Informacion Tarjetas")        
    gdef.setSingleton("true")         
    gdefs.addGroup(gdef)    

# ------------------------------------------------------------------------------------------------------------------ #
#                                   Procesos de seguridad                                                            #
# ------------------------------------------------------------------------------------------------------------------ #
    gdef = GroupDefinition("GRL - Generacion Reporte Excepciones") 
    gdef.registerProcess("Excepcionoperaciones")
    gdef.setCanBeRootGroup("true")        
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
# ------------------------------------------------------------------------------------------------------------------ #
#                                   Grupos Ejecucion Post Migracion                                                  #
# ------------------------------------------------------------------------------------------------------------------ #
    
    gdef = GroupDefinition("    MIG - Procesos Cierre Primer Grupo")
    gdef.registerProcess("CRE - Cambio Rubro Cartera Comprada")
    #gdef.registerProcess("CBL - Cambio de Rubro por Vencido o Forzado") 
    gdef.setCanBeRootGroup("false")          
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("    MIG - Procesos Cierre Segundo Grupo")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales para Intereses")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")     
    gdef.registerProcess("CBL - Exposicion de Sobregiros")     
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales") 
    gdef.registerProcess("GRL - Actualizar Estadisticas")     
    gdef.registerProcess("BAL - Generacion de Balance Diario")     
    gdef.setCanBeRootGroup("false")      
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("    MIG - Procesos de Apertura")
    gdef.registerProcess("GRL - Cambio de Fecha de Proceso") 
    gdef.registerProcess("VTA - Alta de Acuerdos y Sobregiros") 
    gdef.registerProcess("DPF - Pago Periodico de Intereses") 
    gdef.registerProcess("DPF - Renovacion o Cancelacion")  
    gdef.registerProcess("CBL - Extorno Exposicion de Sobregiros") 
    #gdef.registerProcess("CLE - Cambio de Rubro Contabilizacion de Cheques Pendientes")    
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.setCanBeRootGroup("false")      
    gdefs.addGroup(gdef)    


# ------------------------------------------------------------------------------------------------------------------ #   

# ------------------------------------------------------------------------------------------------------------------ #
#                                   Grupos Ejecucion Cierre Extendido                                                #
# ------------------------------------------------------------------------------------------------------------------ #

    gdef = GroupDefinition("GRL - Reaplicacion Cierre Extendido") 
    gdef.registerProcess("Reaplicacion Cierre Extendido") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Carga Datos a Cierre Extendido") 
    gdef.registerProcess("Cierre Extendido") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Historico de Saldos Diarios y Mensuales Extendido Recortado") 
    gdef.registerProcess("HistSaldosExtMod") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)    

    gdef = GroupDefinition("GRL - Marcar Saldos a Actualizar") 
    gdef.registerProcess("Marca Saldos Modificados EXT") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false") 
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("     CBL - Cierre Extendido")
    gdef.registerProcess("GRL - Carga Datos a Cierre Extendido") 
    gdef.registerProcess("GRL - Marcar Saldos a Actualizar")    
    gdef.registerProcess("GRL - Reaplicacion Cierre Extendido")
    gdef.registerProcess("GRL - Reaplica movimientos fecha valor en Saldos Diarios")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales Extendido Recortado")
    gdef.registerProcess("BAL - Generacion de Balance Diario") 
    #gdef.registerProcess("BAL - Balance Diario Cuatro Columnas")            
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")        
    gdefs.addGroup(gdef)
    

    gdef = GroupDefinition("     CBL - Preparacion Cierre Extendido")
    gdef.registerProcess("ITF - Apertura Capital e Interes") 
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")    
    gdef.registerProcess("ITF - Actualizar Intereses de Tarjetas")
    gdef.registerProcess("ITF - Corrige Calificacion Objetiva")
    gdef.registerProcess("ITF - Corrige Calificacion MOCASIST")    
    gdef.registerProcess("CLI - Contagio de Calificacion Objetiva")
    gdef.registerProcess("CLI - Calificacion Subjetiva CONTAGIO")
    gdef.registerProcess("CLI - Calificacion Resultante")
    gdef.registerProcess("CLI - Calificacion Resultante - Contagio")
    #gdef.registerProcess("CBL - Calculo Provision de Creditos") 
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")    
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales") 
    gdef.registerProcess("BAL - Generacion de Balance Diario") 
    #gdef.registerProcess("BAL - Balance Diario Cuatro Columnas")    
    gdef.registerProcess("GRL - Informacion para Central de Riesgos")           
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")        
    gdefs.addGroup(gdef)    

    # ------------------------------------------------------------------------------------------------------------------ #   


    gdef = GroupDefinition("      1 - CIERRE DEMO ")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    #gdef.registerProcess("CBL - Cambio de Rubro por Vencido o Forzado")
    gdef.registerProcess("CBL - Devengamiento Plazo")    
    gdef.registerProcess("DPF - Renovacion o Cancelacion")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("GRL - Cambio Fecha DEMO") 
    gdef.registerProcess("Cambio Fecha Demo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")             
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("      0 - CAMBIO FECHA DEMO ")
    gdef.registerProcess("GRL - Cambio de Fecha de Proceso")
    #gdef.registerProcess("GRL - Cambio Fecha DEMO")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    #================================================================
    # -- Actualizacion 5.3.6 --
    #================================================================
    gdef = GroupDefinition("CBL - EXTORNO CONTABLE CATEGORIZACION CARTERA") 
    gdef.registerProcess("EXTORNO CONTABLE CATEGORIZACION CARTERA") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Control Saldo Al Corte") 
    gdef.registerProcess("Control Saldo Al Corte")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Control por Moneda") 
    gdef.registerProcess("Control por Moneda")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Mayor por rubro") 
    gdef.registerProcess("Reporte MayorXRubro")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Inventario de Saldos") 
    gdef.registerProcess("Inventario de Saldos")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Control Saldo Al Corte") 
    gdef.registerProcess("Control Saldo Al Corte")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Control por Asiento") 
    gdef.registerProcess("Control por Asiento")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Pago creditos por Nomina")     
    gdef.registerProcess("Pago creditos por Nomina") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Reservas Sobre Saldos")
    gdef.registerProcess("Reservas Sobre Saldos") 
    gdef.setExecutionId(805)
    gdefs.addGroup(gdef)

    # PROCESO: Depuracin de Historia Vista
    gdef = GroupDefinition("GRL - Depuracion de Historia Vista") 
    gdef.registerProcess("Depuracion de Historia Vista") 
    gdefs.addGroup(gdef)

    # PROCESO: Depuracion de Historia Plazo
    gdef = GroupDefinition("GRL - Depuracion de Historia Plazo") 
    gdef.registerProcess("Depuracion de Historia Plazo") 
    gdefs.addGroup(gdef)

    # PROCESO: Depuracion de Movimientos Contables
    gdef = GroupDefinition("GRL - Depuracion de Movimientos Contables") 
    gdef.registerProcess("Depuracion de Movimientos Contables") 
    gdefs.addGroup(gdef)

    # PROCESO: Depuracion de Asientos
    gdef = GroupDefinition("GRL - Depuracion de Asientos") 
    gdef.registerProcess("Depuracion de Asientos") 
    gdefs.addGroup(gdef)

    # PROCESO: Depuracion de Movimientos
    gdef = GroupDefinition("GRL - Depuracion de Movimientos") 
    gdef.registerProcess("Depuracion de Movimientos") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Saldos Actualizar Equivalente MN") 
    gdef.registerProcess("Saldos actualizar equivalente MN") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cancelacion de Saldos")
    gdef.registerProcess("Cancelacion de Saldos") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Saldos Diarios Contabilidad") 
    gdef.registerProcess("SaldosDiariosContabilidad") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(412)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Saldos Diarios Contabilidad Actualizar - Fecha Valor") 
    gdef.registerProcess("SaldosDiariosContabilidad con movimientos Fecha Valor") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(411)         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Control previo al Cierre Diario") 
    gdef.registerProcess("Control previo al Cierre Diario") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(406)	
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("GRL -  Baja de asientos masiva") 
    gdef.registerProcess("Baja de asientos masiva")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Balancete") 
    gdef.registerProcess("Balancete")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Ajustes Inter Sucursal") 
    gdef.registerProcess("Ajustes Inter Sucursal") 
    gdefs.addGroup(gdef)  

    gdef = GroupDefinition("CBL - Extorno Ajustes Inter Sucursal") 
    gdef.registerProcess("Extorno Ajustes Inter Sucursal") 
    gdefs.addGroup(gdef)

    # Integracion de Remesas con Giros 
    gdef = GroupDefinition("TRF - Integracion de Remesas con Giros")
    gdef.registerProcess("Integracion de Remesas con Giros")
    gdefs.addGroup(gdef)

    # Integracion de Remesas con Anulacion de Giros Contabilizacions
    gdef = GroupDefinition("TRF - Int. de Remesas con Anulacion de Giros Contabilizacion")
    gdef.registerProcess("Integracion de Remesas Anulacion Giros")
    gdefs.addGroup(gdef)

    # Anulacion de Creditos Automaticos por Giros Vencidos.
    gdef = GroupDefinition("TRF - Anulacion de Creditos Automaticos por Giros Venc.")
    gdef.registerProcess("Anulacion de CA por Giros Vencidos")
    gdefs.addGroup(gdef)

    # Pago Remesas
    gdef = GroupDefinition("TRF: Pago Remesas") 
    gdef.registerProcess("Pago Remesas") 
    gdefs.addGroup(gdef)

    # Reporte Movimiento Transportadora
    gdef = GroupDefinition("REM - Reporte Movimiento Transportadora") 
    gdef.registerProcess("Reporte Movimiento Transportadora") 
    gdefs.addGroup(gdef)

    # Reporte Movimiento Tesorero
    gdef = GroupDefinition("REM - Reporte Movimiento Tesorero") 
    gdef.registerProcess("Reporte Movimiento Tesorero") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Devengamiento Saldo Proporcional al Plazo")
    gdef.registerProcess("Devengamiento Saldo Proporcional al Plazo")
    gdef.setExecutionId(716)
    gdefs.addGroup(gdef)

    # Centro de costo
    gdef = GroupDefinition("CBL - Centro de Costos") 
    gdef.registerProcess("Centro de Costos") 
    gdefs.addGroup(gdef)

    #CBL - Activo Fijo - Cierre Ejercicio
    gdef = GroupDefinition("ACF - Activo Fijo - Cierre Ejercicio")
    gdef.registerProcess("Activo Fijo - Cierre Ejercicio")
    gdefs.addGroup(gdef)

    # Ajuste inter sucursal con fecha valor
    gdef = GroupDefinition("CBL - AJUSTE INTERSUCURSAL CON FECHA VALOR") 
    gdef.registerProcess("Ajuste Intersucursal Con Fecha Valor") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cambio de Producto") 
    gdef.registerProcess("Cambio de Producto") 
    gdefs.addGroup(gdef)      
        
    gdef = GroupDefinition("VTA - Cambio de Rubro") 
    gdef.registerProcess("Cambio de Rubro") 
    gdefs.addGroup(gdef)

    #gdef = GroupDefinition("VTA - Actualizacion Fecha Con Saldo Valor Pago")
    #gdef.registerProcess("Actualizacion Fecha Con Saldo Valor Pago")
    #gdefs.addGroup(gdef)



    gdef = GroupDefinition("VTA - Notificacion por Comisiones Pendientes")
    gdef.registerProcess("Notificacion por Cargos Pendientes")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(819)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Cambio Rubro Forzado")
    gdef.registerProcess("Cambio Rubro Forzado")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    # Procesos Actualizacion de cuotas prestamos
    gdef = GroupDefinition("CRE - Actulizacion De Cuotas Prestamos") #mz modifique mayusculas
    gdef.registerProcess("Actualizacion de cuotas prestamos")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - EXTORNO CON HILOS") 
    gdef.registerProcess("Extorno Con Hilos")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Cambio Estado Prestamo")
    gdef.registerProcess("Cambio Estado Prestamo")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)
	
    # Adelanto de Haberes
    
    gdef = GroupDefinition("CRE - Resumen Adelanto Haberes")
    gdef.registerProcess("Resumen de Adelanto Haberes")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Adelanto haberes Proceso")
    gdef.registerProcess("Adelanto haberes") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizo Estado AH") 
    gdef.registerProcess("Actualizo Estado de Adelanto Haberes")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Adelanto haberes")
    gdef.registerProcess("CRE - Resumen Adelanto Haberes")
    gdef.registerProcess("CRE - Adelanto haberes Proceso") 
    gdef.registerProcess("CRE - Actualizo Estado AH") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)	

    #PROCESO DE ANALISIS DE OPERACIONES PLAZO
    gdef = GroupDefinition("CRE - ANALISIS DE OPERACIONES PLAZO")
    gdef.registerProcess("Analisis de Operaciones Plazo")
    gdefs.addGroup(gdef)
    
    #******************************************************************************************************#
    #*Este proceso debe colocarse en el INICIO DEL DIA despues de la caida de movimientos diferidos    *                                                                                                  
    #******************************************************************************************************#
    gdef = GroupDefinition("CON - Extorno Movimientos Diferidos") 
    gdef.registerProcess("Extorno Movimientos Diferidos")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Proceso: Cataloga por Numero")
    gdef.registerProcess("Cataloga por Numero")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CBL - REAPLICCION DE BALANCES")
    gdef.registerProcess("Reaplicacion de Balances")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CBL - Devengamiento Cargos de prestamo")
    gdef.registerProcess("Devengamiento Saldo Cargos Prestamo")
    gdefs.addGroup(gdef)

    # Calculo Prevision Partidas Transitorias
    gdef = GroupDefinition("CBL - Calculo Prevision Partidas Transitorias")
    gdef.registerProcess("Calculo prevision partidas transitorias")
    gdefs.addGroup(gdef)

    # Contabilidad prevision partidas transitorias
    gdef = GroupDefinition("CBL - Contabilidad Prevision Partidas Transitorias")
    gdef.registerProcess("Contabilidad prevision partidas transitorias")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - REVISION PERIODICA DE CAPITAL")
    gdef.registerProcess("Revision Periodica de Capital")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cobro de interes")
    gdef.registerProcess("Cobro de interes")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Truncar CRE_CONCENTRACION_X_LIBRADOR")
    gdef.registerProcess("Truncar tabla CRE_CONCENTRACION_X_LIBRADOR")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("CRE - Calcular descuentos a realizar por librador")
    gdef.registerProcess("Calcular descuentos a realizar por librador")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("CRE - Calcular descuentos realizados por librador")
    gdef.registerProcess("Calcular descuentos realizados por librador")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("CRE - Calcular concentracion de libradores")
    gdef.registerProcess("Calcular concentracion de libradores")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    #Envio mails
    gdef = GroupDefinition("GRL - Grupo Envio Masivo Mails")
    gdef.registerProcess("Envio Masivo Mails")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Importacion Pago por Nomina")     
    gdef.registerProcess("Importacion Pago por Nomina") 
    gdefs.addGroup(gdef)

    # ------------------------------------------------------------------------------------------------------------------ #
    #                                                    ACTIVO FIJO                                                     #
    # ------------------------------------------------------------------------------------------------------------------ #

    gdef = GroupDefinition("ACF - Revaluacion") 
    gdef.registerProcess("Activo Fijo - Revaluacion")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("ACF - Amortizacion") 
    gdef.registerProcess("Activo Fijo - Amortizacion")
    gdefs.addGroup(gdef)
      
    gdef = GroupDefinition("ACF - Fin Amortizacion") 
    gdef.registerProcess("Activo Fijo - Fin Amortizacion")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - PerdidasYGananciasOperacionesCambio")
    gdef.registerProcess("PerdidasYGananciasOperacionesCambio")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PCT - Integracion de Pagos Recibidos")
    gdef.registerProcess("Integracion de Pagos Recibidos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Consumo de Linea de Acuerdo Tipo Plazo")
    gdef.registerProcess("ConsumoLineaAcuerdoSobregirosTipoPlazo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Recupero de lineas Tipo Plazo")
    gdef.registerProcess("Recupero de lineas Tipo Plazo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Devengado de interes Tipo Plazo")
    gdef.registerProcess("Devengado de interes Tipo Plazo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Reservas Sobre Saldos Consumo")
    gdef.registerProcess("Reservas Sobre Saldos Consumo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PROCESO: Busca Rubro Final - Migracion")
    gdef.registerProcess("Busca Rubro Final")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - EXTORNO CONTABLE MULTIPLES PAGOS") 
    gdef.registerProcess("ExtornoMultiplesPagos") 
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - Suplencias Workflow")
    gdef.registerProcess("Notificacion suplencias Workflow")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Cierre Extendido")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("GRL - Carga Datos a Cierre Extendido")
    gdef.registerProcess("GRL - Marcar Saldos a Actualizar")
    gdef.registerProcess("GRL - Reaplicacion Cierre Extendido")
    gdef.registerProcess("CBL - Devengamiento Plazo")
    gdef.registerProcess("CLI - Calificaciones")
    gdef.registerProcess("GAR - Grupo Afectacion de Garantias")
    gdef.registerProcess("PA - Grupo Calculo, Contabilizacion y Extorno Previsiones")
    gdef.registerProcess("GRL - Reaplica movimientos fecha valor en Saldos Diarios")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales")
    gdef.registerProcess("CBL - Resultados por Tenencia de Moneda Extranjera")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Resultados por Operaciones de Cambio")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Historico de Saldos Diarios y Mensuales")
    gdef.registerProcess("BAL - Generacion de Balance Diario")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Carga Datos a Cierre Extendido")
    gdef.registerProcess("Cierre Extendido")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("GRL - Reaplicacion Cierre Extendido")
    gdef.registerProcess("Reaplicacion Cierre Extendido")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("GRL - Reaplica movimientos fecha valor en Saldos Diarios_Procesa todos")
    gdef.registerProcess("Saldos D y M Reaplicacion de movimientos_Procesa todos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    addMoreGroups1(gdefs)
    addMoreGroups2(gdefs)

    return gdefs

def addMoreGroups1(gdefs):

    gdef = GroupDefinition("CBL - Ajuste Inflacion")
    gdef.registerProcess("Borrado tabla CO_HIS_AJUSTE_X_INFLACION")
    gdef.registerProcess("Calculo Ajuste por Inflacion")
    gdef.registerProcess("Contabilizo ajuste por inflacion")
    gdef.registerProcess("Reporte Ajuste por Inlfacion")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Contabilizacion Ajuste por Inflacion")
    gdef.registerProcess("Contabilizo ajuste por inflacion")
    gdef.setExecutionId(719)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Calculo Ajuste por Inflacion")
    gdef.registerProcess("Calculo Ajuste por Inflacion")
    gdef.setExecutionId(718)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Reporte Ajuste por Inflacion")
    gdef.registerProcess("Reporte Ajuste por Inlfacion")
    gdef.setExecutionId(721)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Borrado tabla historica Ajuste por Inflacion")
    gdef.registerProcess("Borrado tabla CO_HIS_AJUSTE_X_INFLACION")
    gdef.setExecutionId(720)
    gdefs.addGroup(gdef)
    
    # ITF - ADINTAR CREDICOM 1.3.1
    gdef = GroupDefinition("ITF - ADINTAR CREDICOM")
    gdef.setExecutionId(97)
    gdef.registerProcess("Adintar Credicom")
    gdef.registerProcess("Creditos Masivos CREDICOM")
    gdef.registerProcess("Debitos Masivos CREDICOM")
    gdef.registerProcess("Adintar Credicom Reporte")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

        
    #ITF AD CONTABI 1.3.2
    gdef = GroupDefinition("ITF - ADINTAR ASIENTOS CONTABLES")
    gdef.setExecutionId(12)
    gdef.registerProcess("ITF ADINTAR ASIENTOS CONTABLES")
    gdef.registerProcess("Procesamiento de la Bandeja contable")
    gdef.registerProcess("ITF ADINTAR ASIENTOS CONTABLES REPORTE")
    gdefs.addGroup(gdef)
    
    #ITF AD CONTABI 1.37.1
    gdef = GroupDefinition("ITF - DEBITIA")
    gdef.setExecutionId(427)
    gdef.registerProcess("ITF DEBITIA")
    gdefs.addGroup(gdef)
    
    #ITF AD CONTABI 1.37.1_A
    gdef = GroupDefinition("ITF - DEBITIA MARCA ESTADO CLIENTE")
    gdef.setExecutionId(428)
    gdef.registerProcess("ITF DEBITIA MARCA ESTADO CLIENTE")
    gdefs.addGroup(gdef) 
    
    
	#ITF TANGO CONTABI 1.18
    gdef = GroupDefinition("ITF - TANGO ASIENTOS CONTABLES")
    gdef.setExecutionId(37);
    gdef.registerProcess("ITF TANGO ASIENTOS CONTABLES")
    gdef.registerProcess("Procesamiento de la Bandeja contable TAC")
    gdef.registerProcess("ITF TANGO ASIENTOS CONTABLES REPORTE")
    gdefs.addGroup(gdef)    
    
    #ITF - INTERBANKING CBU 1.28.1
    gdef = GroupDefinition("ITF - INTERBANKING CBU")
    gdef.setExecutionId(13)
    gdef.registerProcess("IB CBU")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    # 1.28.12 IB - ECHEQ DEPOSITO
    gdef = GroupDefinition("ITF ECHEQ IB EXTRACT DEPOSITO")
    gdef.registerProcess("ECHEQ_IB_EXTRACT_DEPOSITO")
    gdef.setExecutionId(125)
    gdefs.addGroup(gdef)
    #ITF SIRCREB PADRON DEVOLUCIONES
    gdef = GroupDefinition("ITF - SIRCREB PADRON DEVOLUCIONES")
    gdef.setExecutionId(33);
    gdef.registerProcess("SIRCREB PADRON DEVOLUCIONES")
    gdef.registerProcess("Debitos y Creditos  Masivos")
    gdef.registerProcess("SIRCREB PADRON DEVOLUCIONES REPORTE")
    gdefs.addGroup(gdef)   
    
    #ITF DEBITOS DIRECTOS PRSENTADOS EMITIDOS 2.8.8
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS PRESENTADOS EMITIDOS")
    gdef.setExecutionId(114)
    gdef.registerProcess("DEBITOS DIRECTOS PRESENTADOS EMITIDOS")
    gdefs.addGroup(gdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.9
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS PRESENTADOS RECIBIDOS")
    gdef.setExecutionId(110)
    gdef.registerProcess("DEBITOS DIRECTOS PRESENTADOS RECIBIDOS")
    gdefs.addGroup(gdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.10
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS RECHAZADOS RECIBIDOS")
    gdef.setExecutionId(111)
    gdef.registerProcess("DEBITOS DIRECTOS RECHAZADOS RECIBIDOS")
    gdefs.addGroup(gdef)
    
    #ITF COELSA TRANSFERENCIAS REJECTADAS PESOS 2.8.53
    gdef = GroupDefinition("ITF - CLS TRANSFERENCIAS REJECTADAS PESOS")
    gdef.setExecutionId(115)
    gdef.registerProcess("Transf pres en pesos reject")
    gdefs.addGroup(gdef)
    
    #ITF COELSA TRANSFERENCIAS REJECTADAS DOLARES 2.8.54
    gdef = GroupDefinition("ITF - CLS TRANSFERENCIAS REJECTADAS DOLARES")
    gdef.setExecutionId(116)
    gdef.registerProcess("Transf pres en dolares reject")
    gdefs.addGroup(gdef)
    
    #ITF COELSA TRANSFERENCIAS REJECTADAS DOLARES 2.8.57
    gdef = GroupDefinition("ITF - CLS ECHEQ")
    gdef.setExecutionId(142)
    gdef.registerProcess("CLS - ECHEQ")
    gdefs.addGroup(gdef)
    
    #ITF CLS - EC_RECHAZO_CANJE 2.8.69
    gdef = GroupDefinition("ITF - Notificación de canjes internos rechazados")
    gdef.setExecutionId(143)
    gdef.registerProcess("CLS - EC RECHAZO CANJE")
    gdefs.addGroup(gdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.11
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS RECHAZADOS ENVIADOS")
    gdef.setExecutionId(113)
    gdef.registerProcess("DEBITOS DIRECTOS RECHAZADOS ENVIADOS")
    gdefs.addGroup(gdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS EMITIDOS 2.8.8_v2
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS PRESENTADOS EMITIDOS V2")
    gdef.setExecutionId(144)
    gdef.registerProcess("DEBITOS DIRECTOS PRESENTADOS EMITIDOS V2")
    gdefs.addGroup(gdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.9_v2
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS PRESENTADOS RECIBIDOS V2")
    gdef.setExecutionId(145)
    gdef.registerProcess("DEBITOS DIRECTOS PRESENTADOS RECIBIDOS V2")
    gdefs.addGroup(gdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.10_v2
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS RECHAZADOS RECIBIDOS V2")
    gdef.setExecutionId(146)
    gdef.registerProcess("DEBITOS DIRECTOS RECHAZADOS RECIBIDOS V2")
    gdefs.addGroup(gdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.11_v2
    gdef = GroupDefinition("ITF - DEBITOS DIRECTOS RECHAZADOS ENVIADOS V2")
    gdef.setExecutionId(147)
    gdef.registerProcess("DEBITOS DIRECTOS RECHAZADOS ENVIADOS V2")
    gdefs.addGroup(gdef)
    
    # TRANSFERENCIA MINORISTA PRESENTADAS 2.8.13
    gdef = GroupDefinition("ITF - TRANSFERENCIA MINORISTA PRESENTADAS PESOS")
    gdef.setExecutionId(58)
    gdef.registerProcess("TRANSFERENCIA MINORISTA PRESENTADAS PESOS")
    gdefs.addGroup(gdef)
	
    # TRANSFERENCIA MINORISTA RECIBIDAS 2.8.14
    gdef = GroupDefinition("ITF - TRANSFERENCIA MINORISTA RECIBIDAS PESOS")
    gdef.setExecutionId(55)
    gdef.registerProcess("TRANSFERENCIA MINORISTA RECIBIDAS PESOS")
    gdefs.addGroup(gdef)
	
	# TRANSFERENCIA MINORISTA RECIBIDAS 2.8.16
    gdef = GroupDefinition("ITF - TRANSFERENCIA MINORISTA RECIBIDAS DOLARES")
    gdef.setExecutionId(56)
    gdef.registerProcess("TRANSFERENCIA MINORISTA RECIBIDAS DOLARES")
    gdefs.addGroup(gdef)
	
	# SUELDOS PRESENTADOS RECIBIDOS PESOS 2.8.18
    gdef = GroupDefinition("ITF - SUELDOS PRESENTADOS RECIBIDOS PESOS")
    gdef.setExecutionId(57)
    gdef.registerProcess("SUELDOS PRESENTADOS RECIBIDOS PESOS")
    gdefs.addGroup(gdef)
    
# ---------------------------------------------------------------------------------------------------------------------- #
#                                            GRUPO TRANSFERENCIAS MINORISTAS                                             #
# ---------------------------------------------------------------------------------------------------------------------- #

    # Transferencias - Sesion Presentados
    gdef = GroupDefinition("Transferencias - Sesion Presentados")
    gdef.registerProcess("ITF - TRANSFERENCIA MINORISTA PRESENTADAS PESOS")
    gdef.registerProcess("ITF - COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES")
    gdef.setExecutionId(6)
    gdefs.addGroup(gdef)

    # Transferencias - Sesion Rechazadas / Sueldos
    gdef = GroupDefinition("Transferencias - Sesion Rechazadas / Sueldos")
    gdef.registerProcess("ITF - TRANSFERENCIA SUELDOS PRESENTADOS PESOS")
    gdef.registerProcess("ITF - COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS")
    gdef.setExecutionId(65)
    gdefs.addGroup(gdef)

    # Transferencias - Sesion Recibidas
    gdef = GroupDefinition("Transferencias - Sesion Recibidas")
    gdef.registerProcess("ITF - TRANSFERENCIA MINORISTA RECIBIDAS PESOS")
    gdef.registerProcess("ITF - TRANSFERENCIA MINORISTA RECIBIDAS DOLARES")
    gdef.registerProcess("ITF - SUELDOS PRESENTADOS RECIBIDOS PESOS")
    gdef.registerProcess("ITF - TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES")
    gdef.registerProcess("ITF - CLS TRANSFERENCIAS REJECTADAS PESOS")
    gdef.registerProcess("ITF - CLS TRANSFERENCIAS REJECTADAS DOLARES")
    gdef.registerProcess("TRF - Procesar transferencias recibidas")
    gdef.setExecutionId(32)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Cobra si tiene Saldo")
    gdef.registerProcess("Cobra si tiene Saldo")
    gdef.setExecutionId(832)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Extorno Contabilizacion Acuerdos en cuenta no utilizados") #mz modifico , el nombre estaba con tilde
    gdef.registerProcess("Extorno Contabilizacion Acuerdos En Cuentas No Consumidos")
    gdef.setExecutionId(1411)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Consumo de Acuerdos y Sobregiros")
    gdef.registerProcess("Contabilizacion Acuerdos En Cuentas No Consumidos")
    gdef.setExecutionId(1416)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista_mensual") 
    gdef.registerProcess("HistoricoSaldos e Intereses sin promedio")
    gdefs.addGroup(gdef)   

    gdef = GroupDefinition("CRE - Consumo de Acuerdos y Sobregiros_mensual")
    gdef.registerProcess("Contabilizacion Acuerdos En Cuentas No Consumidos")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Cancelacion Acuerdos y Sobregiros")
    gdef.registerProcess("Acuerdos y Sobregiros Cancelacion y Renovacion")
    gdef.setExecutionId(1412)
    gdefs.addGroup(gdef)

    # CRE - Revision Tasas Acuerdos
    gdef = GroupDefinition("VTA - Revision Tasas Acuerdos")     
    gdef.registerProcess("Revision Tasas Acuerdos") 
    gdef.setSingleton("true")
    gdef.setExecutionId(66)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Renovacion Subsidios")
    gdef.registerProcess("Renovacion Subsidios")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1448)
    gdefs.addGroup(gdef)

    #RPT - RRII Datos cuentas Tarjetas de credito
    gdef = GroupDefinition("RPT - RRII Datos cuentas TC")
    gdef.registerProcess("RRII Datos cuentas TC")
    gdefs.addGroup(gdef)

     #RPT - RRII Datos cuentas Tarjetas de credito
    gdef = GroupDefinition("RPT - RRII Datos cuentas TC")
    gdef.registerProcess("RRII Datos cuentas TC")
    gdef.setExecutionId(1243)
    gdefs.addGroup(gdef)
    
    #RPT - RRII Tasas cuentas Tarjetas de credito
    gdef = GroupDefinition("RPT - RRII Tasas cuentas TC")
    gdef.registerProcess("RRII Tasas cuentas TC")
    gdef.setExecutionId(1248)
    gdefs.addGroup(gdef)

    #RPT - RRII Cantidad Tarjetas de credito
    gdef = GroupDefinition("RPT - RRII Cantidad Tarjetas de credito")
    gdef.registerProcess("RRII Cantidad Tarjetas de credito")
    gdef.setExecutionId(1244)
    gdefs.addGroup(gdef)

    #RPT - RRII Tarjetas de credito
    gdef = GroupDefinition("RPT - RRII Informe Tarjetas de credito")
    gdef.registerProcess("RRII Informe tarjetas de credito")
    gdef.setExecutionId(1245)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Regimen de Transparencia - Apartado C")
    gdef.registerProcess("RRII - Regimen de Transparencia - Apartado C")
    gdef.setExecutionId(1246)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Regimen de Transparencia - Apartado A")
    gdef.registerProcess("RRII - Regimen de Transparencia - Apartado A")
    gdef.setExecutionId(1247)
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("VTA - Cancelacion de cuentas")
    gdef.registerProcess("CierreCtaAutomatico")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    # PROCESO: CRE - MIGRACION IOF COMPLEMENTARIO
    gdef = GroupDefinition("CRE - MIGRACION IOF COMPLEMENTARIO")
    gdef.registerProcess("Migracion de saldos al nuevo Modelo IOF Complementario")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Genera IVA Financiado")
    gdef.registerProcess("Genera IVA Financiado")
    gdef.setExecutionId(1410)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Procesar Cheques Descontados")
    gdef.registerProcess("Procesar Cheques Descontados")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1402)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Caida de Cheques Propio al Cobro")
    gdef.registerProcess("Caida de Cheques Propio al Cobro")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1403)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Caida de Cheques al Cobro")
    gdef.registerProcess("Caida de Cheques al Cobro")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1404)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Analisis de devengado en suspenso")
    gdef.registerProcess("Analisis de devengado en suspenso")
    gdef.setExecutionId(1431)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Operaciones cambio retroactiva")
    gdef.registerProcess("AjusteOperCambioRetroactiva")
    gdef.setExecutionId(415)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Cargar Bandejas del Extendido")
    gdef.registerProcess("Cargar bandejas Cierre Extendido")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Calificaciones")
    gdef.registerProcess("Borrado tabla HISTORICO_CALIF_X_SALDO")
    gdef.registerProcess("Genera Historico Calificacion Objetiva")
    gdef.registerProcess("Genera Historico Calificacion Objetiva Refinanciado")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GAR - Grupo Afectacion de Garantias")
    gdef.registerProcess("GAR - Extorno Contabilizacion Afectacion Garantias")
    gdef.registerProcess("GAR - Borrado tabla")
    gdef.registerProcess("GAR - Calculo Afectacion Garantias")
    gdef.registerProcess("GAR - Calculo Afectacion Prestamos sin Garantias")
    gdef.registerProcess("GAR - Contabilizacion Afectacion de Garantias")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Aplicacion de Cierre Extendido")
    gdef.registerProcess("CBL - Extorno y Contabilizacion Fin de Mes")
    gdef.registerProcess("GRL - Copia Tablas de Cierre extendido")
    gdef.registerProcess("CBL - Cargar Bandejas del Extendido")
    gdef.registerProcess("CBL - Procesar Bandeja Contable EXT")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Reaplica movimientos fecha valor en Saldos Diarios")
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("CBL - Extorno y Contabilizacion Fin de Mes")
    gdef.registerProcess("Registro de la Bandeja contable FME")
    gdef.registerProcess("Procesamiento de la Bandeja contable FME")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable FME")
    gdef.registerProcess("Procesamiento de la Bandeja contable FME")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Registro Bandeja Contable FME")
    gdef.registerProcess("Registro de la Bandeja contable FME")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Procesar Bandeja Contable EXT")
    gdef.registerProcess("Procesamiento de la Bandeja contable EXT")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Registro Bandeja Contable EXT")
    gdef.registerProcess("Registro de la Bandeja contable EXT")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Copia Tablas de Cierre extendido")
    gdef.registerProcess("Copia Tablas de Cierre extendido")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Contabilizacion Acuerdos En Cuentas No Consumidos")
    gdef.registerProcess("Extorno Contabilizacion Acuerdos En Cuentas No Consumidos")
    gdef.registerProcess("Contabilizacion Acuerdos En Cuentas No Consumidos")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL- DevengamientoComisionDesembolso")
    gdef.registerProcess("DevengamientoComisionDesembolso")
    gdef.setExecutionId(418)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE- Crea Comision Desembolso")
    gdef.registerProcess("CreaComisionDesembolso")
    gdef.setExecutionId(1415)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PROCESO: NotifyTaskExpired")
    gdef.registerProcess("NotifyTaskExpired")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Devengar diferencia intereses tasa contractual/tasa mercado")
    gdef.registerProcess("Devenga Diferencia Intereses Tasa Efectiva Tasa Mercado")
    gdef.setExecutionId(1435)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Crea Cronograma Devengado Diferente Tasa Interes")
    gdef.registerProcess("Crea Cronograma Devengado Diferente Tasa Interes")
    gdef.setExecutionId(1436)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Calificacion Objetiva Deuda Refinanciada")
    gdef.registerProcess("Genera Historico Calificacion Objetiva Refinanciado")
    gdef.setExecutionId(1430)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Numeracion de movimientos contables")
    gdef.registerProcess("Numeracion de movimientos contables")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(414)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Registro historico fin de mes UVA UVI")
    gdef.registerProcess("Borrado tabla CON_HISTORICO_UVA_UVI");
    gdef.registerProcess("Registro historico fin de mes UVA UVI");
    gdef.setExecutionId(711)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Contabilizacion de ajustes UVA UVI")
    gdef.registerProcess("Extorno Contabilizacion Ajuste UVA y UVI");
    gdef.registerProcess("Contabilizacion de ajustes UVA UVI");
    gdef.setExecutionId(710)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Actualizar Movimientos ajustes UVA UVI")
    gdef.registerProcess("Actualizar Movimientos ajustes UVA UVI");
    gdef.setExecutionId(709)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Extorno Contabilizacion Previsiones")
    gdef.registerProcess("Extorno Contabilizacion Previsiones")
    gdef.setExecutionId(1446)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PA - Grupo Calculo, Contabilizacion y Extorno Previsiones")
    gdef.registerProcess("Calculo de Prevision por categoria, atraso y garantias")
    gdef.registerProcess("Extorno Contabilizacion Previsiones")
    gdef.registerProcess("Contabilizacion de Previsiones")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Contabilizacion Previsiones")
    gdef.registerProcess("Contabilizacion de Previsiones")
    gdef.setExecutionId(1445)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Calculo de Prevision")
    gdef.registerProcess("Calculo de Prevision por categoria, atraso y garantias")
    gdef.setExecutionId(1444)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Clasificacion Deuda No Refinanciada")
    gdef.registerProcess("Borrado tabla HISTORICO_CALIF_X_SALDO")
    gdef.registerProcess("Genera Historico Calificacion Objetiva")
    gdef.setExecutionId(1429)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Pago Intereses Vista Saldos Inmovilizados")
    gdef.registerProcess("Pago Intereses Vista Saldos Inmovilizados")
    gdef.setExecutionId(820)
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("PA - Debitos y Creditos Masivos")
    gdef.registerProcess("Debitos y Creditos  Masivos")
    gdef.setExecutionId(417)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Cobranza Automatica Cuota por Cuota")
    gdef.registerProcess("Cobranza Automatica Cuota por Cuota")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1439)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Cobranza Automatica Preparacion")
    gdef.registerProcess("Cobranza Automatica Preparacion")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1438)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Devengado Intereses Deudores N Acuerdos")
    gdef.registerProcess("Devengado Intereses Deudores N Acuerdos")
    gdef.setExecutionId(824)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cobro Intereses Deudores N Acuerdos")
    gdef.registerProcess("Cobro Intereses Deudores N Acuerdos Todos")
    gdef.setExecutionId(825)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cobro Intereses Deudores N Acuerdos un JTS")
    gdef.registerProcess("Cobro Intereses Deudores N Acuerdos Un Jts_Oid")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GAR - Contabilizacion Afectacion de Garantias")
    gdef.registerProcess("Contabilizacion Afectacion de Garantias")
    gdef.setExecutionId(1407)
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("GAR - Extorno Contabilizacion Afectacion Garantias")
    gdef.registerProcess("Extorno Contabilizacion Afectacion Garantias")
    gdef.setExecutionId(1432)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GAR - Borrado tabla")
    gdef.registerProcess("Borrado tabla CRE_HISTORICO_DEUDA_GARANTIAS")
    gdef.setExecutionId(1413)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GAR - Calculo Afectacion Prestamos sin Garantias")
    gdef.registerProcess("Calculo Afectacion Prestamos sin Garantias")
    gdef.setExecutionId(1406)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GAR - Calculo Afectacion Garantias")
    gdef.registerProcess("Calculo Afectacion Garantias")
    gdef.setExecutionId(1405)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("Proceso - Corrimiento Vencimiento DPF")
    gdef.registerProcess("Corrimiento Vencimiento DPF")
    gdef.setExecutionId(821)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Asignacion de licencias")
    gdef.registerProcess("Asignacion de licencias")
    gdef.setExecutionId(422)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Asignacion temporal de grupos")
    gdef.registerProcess("Asignacion temporal de grupos")
    gdef.setExecutionId(423)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Borrar saldos diarios")
    gdef.registerProcess("Borrar saldos diarios")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    
    gdef = GroupDefinition("PROCESO: Depurar Contadores por Movimiento")
    gdef.registerProcess("Depura Contadores por Movimiento")
    gdefs.addGroup(gdef)

    # Generar Balance de Contabilidad Saldos Diarios
    gdef = GroupDefinition("GRL - Generar Balance de Contabilidad Saldos Diarios")
    gdef.registerProcess("Generar Balance de Contabilidad Saldos Diarios")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Inactivacion de Usuarios")
    gdef.registerProcess("Inactivacion de Usuarios")
    gdef.setExecutionId(421)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Ganancia Intereses Refinanciados")
    gdef.registerProcess("Ganancia Intereses Refinanciados")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PROCESO: Acreditacion Rapida")
    gdef.registerProcess("Acreditacion Rapida")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PROCESO: Enviar Eventos")
    gdef.registerProcess("Enviar Eventos");
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("Proceso: Informar Reservas Judiciales")
    gdef.registerProcess("Informar Reservas Judiciales")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Reserva Cobranza Cargos Diferidos")
    gdef.registerProcess("Reserva Cobranca de tarifas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(814)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Actualizacion Bloqueos")
    gdef.setCanBeRootGroup("true")
    gdef.registerProcess("Activacion Bloqueos")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CON - Extorno Reversas Webservice")
    gdef.registerProcess("Extorno Reversas Webservice")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA: Reservas Para Cobranza Automatica")
    gdef.registerProcess("Reservas Cobranza Automatica")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Cambio de Sucursal Total")
    gdef.registerProcess("Cambio de Sucursal Total")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Cambio de Sucursal Parcial")
    gdef.registerProcess("Cambio de Sucursal Parcial")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLI - Contador Clientes Activos")
    gdef.registerProcess("Contador Clientes Activos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Extorno de un Sub Asiento")
    gdef.registerProcess("ExtornoSubAsiento")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    # Marca Inicio de Cierre
    gdef = GroupDefinition("GRL - Marca Comienzo Inicio del dia")
    gdef.registerProcess("Marca Comienzo Inicio del dia")
    gdefs.addGroup(gdef)
    # Marca Fin de Cierre"
    gdef = GroupDefinition("GRL - Marca Fin Inicio del dia")
    gdef.registerProcess("Marca Fin Inicio del dia")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("PROCESO: Cambio de fecha sucursal virtual")
    gdef.registerProcess("Cambio fecha sucursal virtual")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Apertura de Sucursales")
    gdef.registerProcess("Apertura de Sucursales")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Cambio de Fecha de Sucursales")
    gdef.registerProcess("Cambio de Fecha de Sucursales")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Cierre de Sucursales")
    gdef.registerProcess("Cierre de Sucursales")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cobro IOF Sobregiros")
    gdef.registerProcess("Cobro IOF Sobregiros")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Recupero de Intereses Adeudados")
    gdef.registerProcess("Recupero de Intereses Adeudados")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Cobro Intereses Deudores")
    gdef.registerProcess("Cobro Intereses Deudores")
    gdefs.addGroup(gdef)

    # COMENTADO PAOLO MIGRACION 5_5
    # gdef = GroupDefinition("CBL - XBRL Validar XBRL")
    # gdef.registerProcess("Validar XBRL")
    # gdef.setCanBeRootGroup("true")
    # gdef.setSingleton("false")
    # gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - XBRL GENERAR XBRL")
    gdef.registerProcess("GENERAR XBRL")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("CBL - XBRL GENERAR EXCEL")
    gdef.registerProcess("GENERAR EXCEL")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Grupo Delivery Catalogo Generado")
    gdef.registerProcess("DELIVERY_CATALOGOS_GENERADOS")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Depura Numeradores de Secuencias")
    gdef.registerProcess("Proceso Depuracion de Numeradores")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Aplicacion Movimientos OffLine MultiHilo")
    gdef.registerProcess("Movimientos Offline MultiHilo")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("CBL - Regularizacion Cuenta Previsiones")
    gdef.registerProcess("Regularizacion Cuenta Previsiones")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - Cambio de Fecha de Proceso s/p")
    gdef.registerProcess("Cambio fecha proceso s/p")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII SIRCREB")
    gdef.registerProcess("RRII - SIRCREB")
    gdef.setExecutionId(1203)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII CREDEB")
    gdef.registerProcess("RRII - CREDEB")
    gdef.setExecutionId(1204)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII CREDEB SEMANAL")
    gdef.registerProcess("RRII - CREDEB SEMANAL")
    gdef.setExecutionId(1205)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII CREDEB DEVOLUCIONES")
    gdef.registerProcess("RRII - CREDEB DEVOLUCIONES")
    gdef.setExecutionId(1206)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII CREDEB EXENTOS")
    gdef.registerProcess("RRII - CREDEB EXENTOS")
    gdef.setExecutionId(1211)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII IIBB CORRIENTES DECENAL")
    gdef.registerProcess("RRII - IIBB CORRIENTES DECENAL")
    gdef.setExecutionId(1207)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII IIBB CORRIENTES")
    gdef.registerProcess("RRII - IIBB CORRIENTES")
    gdef.setExecutionId(1208)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII SELLOS CHACO")
    gdef.registerProcess("RRII - SELLOS CHACO")
    gdef.setExecutionId(1209)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII SELLOS CABA")
    gdef.registerProcess("RRII - SELLOS CABA")
    gdef.setExecutionId(1210)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Operaciones Pasivas")
    gdef.registerProcess("Operaciones Pasivas")
    gdef.setExecutionId(1212)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII IVA Ventas")
    gdef.registerProcess("RRII - IVA Ventas")
    gdef.setExecutionId(1201)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII IVA Compras")
    gdef.registerProcess("RRII - IVA Compras")
    gdef.setExecutionId(1202)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - Reporte Cheques Rechazados")
    gdef.registerProcess("Cheques Rechazados y Denunciados")
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("RPT - RRII Balance de Saldos")
    gdef.registerProcess("RRII - Balance de saldos")
    gdef.setExecutionId(1218)
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("RPT - RRII Regimen de supervision A12")
    gdef.registerProcess("RRII - Regimen de supervision anexo 12")
    gdef.setExecutionId(1220)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - Interfaz Contable")
    gdef.registerProcess("RRII - Interfaz Contable")
    gdef.setExecutionId(1221)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Medicion LCR")
    gdef.registerProcess("RRII - Medicion LCR")
    gdef.setExecutionId(1222)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII RATIO LCR")
    gdef.registerProcess("RRII - RATIO LCR")
    gdef.setExecutionId(1223)
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("CLE - Grabado de Cheques Rechazados")
    gdef.registerProcess("Grabado de Cheques Rechazados")
    gdefs.addGroup(gdef)



    gdef = GroupDefinition("RPT - RRII Regimen de supervision A02")
    gdef.registerProcess("RRII - Regimen de supervision anexo 02")
    gdef.setExecutionId(1224)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Regimen de publicacion")
    gdef.registerProcess("RRII - Regimen de publicacion")
    gdef.setExecutionId(1225)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Efectivo Minimo")
    gdef.registerProcess("RRII - EFECTIVO MINIMO")
    gdef.setExecutionId(1226)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Pago de Remuneraciones")
    gdef.registerProcess("RRII - Pago de remuneraciones")
    gdef.setExecutionId(1227)
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("RPT - RRII Padron")
    gdef.registerProcess("RRII - PADRON")
    gdef.setExecutionId(1228)
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("RPT - Reportes Normativos BCRA")
    gdef.registerProcess("Operaciones Pasivas")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - IERIC Mensual")
    gdef.registerProcess("RRII - IERIC Mensual")
    gdef.setExecutionId(1229)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - IERIC Anual")
    gdef.registerProcess("RRII - IERIC Anual")
    gdef.setExecutionId(1230)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - Informe LELIQ")
    gdef.registerProcess("RRII - Informe LELIQ")
    gdef.setExecutionId(1231)
    gdefs.addGroup(gdef)

    
    gdef = GroupDefinition("RPT - Reporte caja forense")
    gdef.registerProcess("Reporte caja forense")
    gdef.setExecutionId(1232)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Kettle CV_TRANSFERENCIA inicial")
    gdef.registerProcess("Kettle Caja forense inicial")
    gdef.setExecutionId(1233)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Kettle CV_TRANSFERENCIA final")
    gdef.registerProcess("Kettle Caja forense final")
    gdef.setExecutionId(1234)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Kettle CV_TRANSFERENCIA reversa")
    gdef.registerProcess("Kettle Caja forense reversa")
    gdef.setExecutionId(1235)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Reporte Cuentas Vista Inmovilizar")
    gdef.registerProcess("Reporte cv inmovilizar")
    gdef.setExecutionId(1236)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Kettle Cuentas Vista Inmovilizar final")
    gdef.registerProcess("Kettle cv inmovilizar final")
    gdef.setExecutionId(1237)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Kettle Cuentas Vista Inmovilizar reversa")
    gdef.registerProcess("Kettle cv inmovilizar reversa")
    gdef.setExecutionId(1238)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Kettle Cuentas Vista Inmovilizar mail")
    gdef.registerProcess("Kettle cv inmovilizar mail")
    gdef.setExecutionId(1239)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - Kettle Cuentas Vista Inmovilizar")
    gdef.registerProcess("Kettle cv inmovilizar")
    gdef.setExecutionId(1240)
    gdefs.addGroup(gdef)
    
    #Kettle Reporte Ley Impuesto_25413
    gdef = GroupDefinition("RPT - Kettle Reporte Ley Impuesto_25413")
    gdef.registerProcess("Kettle Reporte Ley Impuesto_25413")
    gdef.setExecutionId(1241)
    gdefs.addGroup(gdef)



    
# ---------------------------------------------------------------------------------------------------------------------- #
#                                     Cadena de Convenios Recaudaci�n                                                    #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("CVN - Convenios Recaudaci�n")
    gdef.registerProcess("Convenios Recaudacion - Renovacion Baja")
    gdef.registerProcess("Convenios Recaudacion - Baja")
    gdef.registerProcess("Convenios Recaudacion - Inactivacion")
    gdef.registerProcess("Convenios Recaudacion - Activacion Pagos Por Caja")
    gdef.registerProcess("Convenios Recaudacion - Liquidacion Pagos Por Caja")
    gdef.registerProcess("Comision por mantenimiento de Convenios")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                     Cadena de Convenios de Pago                                                        #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("CVN - Convenios de Pago")
    gdef.registerProcess("Convenios Pago - Inactivacion")
    gdef.registerProcess("Convenios Pago - Baja")
    gdef.registerProcess("Convenios Pago - Renovacion Baja")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                     Cadena de Agencieros - Convenios                                                   #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("CVN - Agencieros Convenios")
    gdef.registerProcess("Pasaje Agencieros Debitos")
    gdef.registerProcess("Pasaje Agencieros Creditos")
    gdef.registerProcess("Debitos y Creditos  Masivos")
    gdef.registerProcess("Actualizacion Agencieros")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)


# ---------------------------------------------------------------------------------------------------------------------- #
#                                     Cadena de Debitos Automaticos - Convenios                                                   #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("CVN - Debitos Automaticos - Convenios")
    gdef.registerProcess("Liquidacion Convenios - Debito Automatico")
    gdef.registerProcess("Rendicion Debitos Automaticos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)


# ---------------------------------------------------------------------------------------------------------------------- #

    #CONVENIOS
    gdef = GroupDefinition("CVN - Convenios Recaudacion - Inactivacion")    
    gdef.registerProcess("Convenios Recaudacion - Inactivacion")    
    gdef.setExecutionId(1011)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Convenios Recaudacion - Baja")    
    gdef.registerProcess("Convenios Recaudacion - Baja")    
    gdef.setExecutionId(1001)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Convenios Pago - Inactivacion")    
    gdef.registerProcess("Convenios Pago - Inactivacion")    
    gdef.setExecutionId(1004)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Convenios Pago - Baja")    
    gdef.registerProcess("Convenios Pago - Baja")    
    gdef.setExecutionId(1014)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CVN - Activacion Recaudos Por Caja")    
    gdef.registerProcess("Convenios Recaudacion - Activacion Pagos Por Caja")    
    gdef.setExecutionId(1002)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CVN - Liquidacion Recaudos Por Caja")    
    gdef.registerProcess("Convenios Recaudacion - Liquidacion Pagos Por Caja")    
    gdef.setExecutionId(1003)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Liquidacion Debito Automatico")    
    gdef.registerProcess("Liquidacion Convenios - Debito Automatico")    
    gdef.setExecutionId(1007)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CVN - Convenios Recaudacion - Renovacion Baja")    
    gdef.registerProcess("Convenios Recaudacion - Renovacion Baja")    
    gdef.setExecutionId(1012)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Comision mantenimiento Convenios")    
    gdef.registerProcess("Comision por mantenimiento de Convenios")    
    gdef.setExecutionId(1010)
    gdefs.addGroup(gdef)

    #AGENCIEROS

    gdef = GroupDefinition("CVN - Agencieros Pasaje Debitos")    
    gdef.registerProcess("Pasaje Agencieros Debitos")    
    gdef.setExecutionId(1013)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CVN - Agencieros Pasaje Creditos")
    gdef.registerProcess("Pasaje Agencieros Creditos")
    gdef.setExecutionId(1008)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CVN - Agencieros Actualizacion")    
    gdef.registerProcess("Actualizacion Agencieros")    
    gdef.setExecutionId(1009)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CVN - Rendicion Debitos Automaticos")
    gdef.registerProcess("Rendicion Debitos Automaticos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("Prueba Kettle")    
    gdef.registerProcess("LOAD_CONVENIO")    
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CON - EXTORNO CONTABLE") 
    gdef.registerProcess("Extorno") 
    # gdef.addPermission("705")
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("PRU - Prueba Desatendida Query Externa") 
    gdef.registerProcess("Prueba Desatendida Credito en cuenta") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Convenios Pago - Renovacion Baja")
    gdef.registerProcess("Convenios Pago - Renovacion Baja")
    gdef.setExecutionId(1005)
    gdefs.addGroup(gdef)
 
    gdef = GroupDefinition("CVN - Servicio CV Remunerada")
    gdef.registerProcess("Servicio CV Remunerada")    
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("GRL - MA Bandeja de entrada - Depuracion")    
    gdef.registerProcess("MA Bandeja de entrada - Depuracion")    
    gdef.setExecutionId(425)
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                  Procesos de �rdenes de D�bito Directo                                                 #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("DEB - Procesar debitos directos recibidos")
    gdef.registerProcess("Procesamiento de ordenes recibidas - Debitos Directos")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(303)
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("DEB - Contabilizar debitos directos")
    gdef.registerProcess("Contabilizacion de ordenes - Debitos Directos")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(304)
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                          Procesos de Transferencias                                                    #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("TRF - Procesar transferencias recibidas")
    gdef.registerProcess("Procesamiento de transferencias recibidas - Transferencias")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("TRF - Acreditar transferencias recibidas")
    gdef.registerProcess("Pago de transferencias recibidas - Transferencias")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(289)
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                     CLEARING - Sesion Presentados Terceros                                             #
# ---------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("     CLEARING - Sesion Presentados Terceros")
    gdef.registerProcess("CLE - Actualiza Tipo Reg cheques electronicos")
    gdef.registerProcess("CLE - Procesamiento Cheques Electronicos de Terceros")
    gdef.registerProcess("CLE - Control cheques y plazos fijos digitalizados")
    gdef.registerProcess("CRE - Caida de Cheques al Cobro") # MZ se anexo esta linea
    gdef.registerProcess("CLE - Envio a Camara Cheques Recibidos (Limpia Bandeja)")
    gdef.registerProcess("ITF - COELSA Cheques Presentados Enviados")
    gdef.registerProcess("ITF - COELSA ENVIO DPF DOLARES TERCEROS")
    gdef.registerProcess("ITF - ARCHIVO CONTROL IMAGENES CHEQUES PRESENTADOS")
    gdef.registerProcess("ITF - GENERA ARCHIVO ZIP CHEQUES PRESENTADOS")
    gdef.registerProcess("ITF - GENERA ARCHIVO ZIP TOTAL CHEQUES PRESENTADOS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(290)
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                     CLEARING - Sesion Rechazados  Terceros                                             #
# ---------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("     CLEARING - Sesion Rechazados Terceros")
    gdef.registerProcess("CLE - Actualiza Tipo Reg cheques electronicos")
    gdef.registerProcess("CLE - Actualizacion Saldos Pendientes")
    gdef.registerProcess("ITF - COELSA CHEQUES Y DPF TERCEROS RECHAZADOS")
    gdef.registerProcess("ITF - COELSA DPF Dolares rechazados recibidos")
    gdef.registerProcess("CLE - Recepcion de Cheques Recibidos Devueltos")
    gdef.registerProcess("CLE - Acreditacion de Cheques Recibidos")
    gdef.registerProcess("CRE - Procesar Cheques Descontados") # mz se anexa este proceso
    gdef.registerProcess("CLE - Cheques Rechazados por depositaria")
    gdef.registerProcess("CLE - Rechazos DPF Compensable Otro Banco")
    gdef.registerProcess("CLE - Acreditacion DPF Compensable Otro Banco")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(291)
    gdefs.addGroup(gdef)
# ---------------------------------------------------------------------------------------------------------------------- #
#                                     CLEARING - Sesion Rechazados Propios                                              #
# ---------------------------------------------------------------------------------------------------------------------- #

    gdef = GroupDefinition("     CLEARING - Sesion Rechazados Propios")
    #gdef.registerProcess("CLE - Cobra si tiene Saldo")
    gdef.registerProcess("CLE - Control rechazo temporal")
    gdef.registerProcess("CLE - Control DPF compensables propios confirmados")
    gdef.registerProcess("CLE - Cobro Solicitudes Canje Interno")
    gdef.registerProcess("CLE - Rechazo de Canje Interno")
    gdef.registerProcess("CLE - Rechazos Clearing Digital")
    gdef.registerProcess("CLE - Contabiliza Rechazo Canje Interno")
    gdef.registerProcess("CLE - Cobro de multa con/sin bonificacion")
    gdef.registerProcess("CRE - Procesar Cheques Descontados") # mz se anexa este proceso
    gdef.registerProcess("CLE - Devolucion de Cheques Girados")
    gdef.registerProcess("CLE - Genera Nro de aviso")
    gdef.registerProcess("ITF - COELSA INFORMAR CHEQUES PROPIOS RECHAZADOS")
    gdef.registerProcess("ITF - COELSA DPF PROPIOS RECHAZADOS A ENVIAR")
    gdef.registerProcess("ITF - COELSA DPFD")
    gdef.registerProcess("Cle - Genera Cheques Rechazados - Canje Interno")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(292)
    gdefs.addGroup(gdef)

# ------------------------------------------------------------------------------------------------------------------ #
#                                            Cadena de Apertura Integrada                                           #
# ------------------------------------------------------------------------------------------------------------------ #
    
    gdef = GroupDefinition("    DIA - Procesos de Apertura Integrada")
    gdef.registerProcess("GRL - Marca Comienzo Inicio del dia")
    gdef.registerProcess("GRL - Cambio de Fecha de Proceso s/p")
    gdef.registerProcess("GRL - Cambio de Fecha de Sucursales")
    gdef.registerProcess("ITF - BITACORA RESETEO PARAMETRO")
    gdef.registerProcess("GRL - Apertura de Sucursales")
    gdef.registerProcess("GRL - Fin de Asientos Diferidos")
    gdef.registerProcess("CBL - Extorno Exposicion de Sobregiros")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Reserva Cobranza Cargos Diferidos")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CVN - Activacion Recaudos Por Caja")
    gdef.registerProcess("COF - Generacion Avisos de Cajas de Seguridad")
    gdef.registerProcess("COF - Renovacion y cobro de Cajas de Seguridad")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Asignacion de licencias")
    gdef.registerProcess("GRL - Asignacion temporal de grupos")
    gdef.registerProcess("GRL - Inactivacion de Usuarios")
    gdef.registerProcess("GRL - Generacion Reporte Excepciones")
    gdef.registerProcess("GRL - Marca Fin Inicio del dia")
    gdef.setSingleton("true")
    gdef.setExecutionId(1704)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("DPF - Procesos Apertura") 
    gdef.registerProcess("DPF - Pago Periodico de Intereses")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("DPF - Renovacion o Cancelacion")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("DPF - Acreditacion DPF UVAUVI")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdef.setExecutionId(67)
    gdefs.addGroup(gdef)


    #Agrego definición para Oper 3330
    gdef = GroupDefinition("CLI - Rechazar Solicitud Integrante Juzgado")
    gdef.registerProcess("Rechazar Solicitud Integrante Juzgado")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    #Agrego definición para Oper 3335
    gdef = GroupDefinition("CLI - Rechazar Solicitud Activar-Inactivar Causa")
    gdef.registerProcess("Rechazar Solicitud Activar-Inactivar Causa")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    #Agrego grupo para Reporte 3301
    gdef = GroupDefinition("CONT - Asientos sin Cierre") 
    gdef.registerProcess("3301 - Asientos sin Cierre") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")            
    gdefs.addGroup(gdef)

    #Agrego grupo para Reporte 3327 pdf
    gdef = GroupDefinition("CONT - Libro Diario General")
    gdef.registerProcess("3327 - Libro Diario General")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    #Agrego grupo para Reporte 3327 xls
    gdef = GroupDefinition("CONT - Libro Diario General excel")
    gdef.registerProcess("3327 - Libro Diario General excel")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    #Agrego grupo para Reporte 3325 xls
    gdef = GroupDefinition("CONT - Movimientos de Prestamos")
    gdef.registerProcess("3325 - Movimientos de Prestamos")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    #Agrego grupo para Reporte 3326 xls
    gdef = GroupDefinition("CONT - Movimientos Devengamiento de Intereses")
    gdef.registerProcess("3326 - Devengamiento de Intereses")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    # ITF ARCHIVO CONTROL IMAGENES CHEQUES PRESENTADOS ENVIADOS 2.8.39
    gdef = GroupDefinition("ITF - ARCHIVO CONTROL IMAGENES CHEQUES PRESENTADOS")
    gdef.setExecutionId(43)
    gdef.registerProcess("GENERACION ARCHIVO CHEQUES PRESENTADOS")
    gdefs.addGroup(gdef)

    # ITF GENERACION ARCHIVO ZIP CHEQUES PRESENTADOS ENVIADOS 2.8.40
    gdef = GroupDefinition("ITF - GENERA ARCHIVO ZIP CHEQUES PRESENTADOS")
    gdef.registerProcess("GENERACION ARCHIVO ZIP CHEQUES PRESENTADOS")
    gdefs.addGroup(gdef)

    # ITF GENERACION ARCHIVO ZIP CHEQUES PRESENTADOS ENVIADOS 2.8.40 BIS
    gdef = GroupDefinition("ITF - GENERA ARCHIVO ZIP TOTAL CHEQUES PRESENTADOS")
    gdef.registerProcess("GENERACION ARCHIVO ZIP TOTAL CHEQUES PRESENTADOS")
    gdef.setExecutionId(293)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Caida Automatica de Solicitudes de Asistencias")
    gdef.registerProcess("Caida Automatica de Solicitudes de Asistencias")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1016)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion Situacion Sistema Financiero")
    gdef.registerProcess("Actualizacion Situacion Sistema Financiero")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1419)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion CENDEU Nuevos Clientes")
    gdef.registerProcess("Actualizacion CENDEU Nuevos Clientes")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1418)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Perdida de Credito Adicional")
    gdef.registerProcess("Perdida de Credito Adicional")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Asignacion de Credito Adicional")
    gdef.registerProcess("Asignacion de Credito Adicional")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1447)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Borrado de discrepancia")
    gdef.registerProcess("Borrado de discrepancia")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1426)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion de Discrepancia")
    gdef.registerProcess("Actualizacion de Discrepancia")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1427)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion detalle de Morosos Ex Entidades")
    gdef.registerProcess("Actualizacion detalle de Morosos Ex Entidades")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1421)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion detalle de Morosos Ex Entidades nuevos clientes")
    gdef.registerProcess("Actualizacion detalle de Morosos Ex Entidades nuevos clientes")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1422)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion Situacion Morosos Ex Entidades")
    gdef.registerProcess("Actualizacion Situacion Morosos Ex Entidades")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1423)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion Situacion Resultante")
    gdef.registerProcess("Actualizacion Situacion Resultante")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1420)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Borrado de situacion juridica")
    gdef.registerProcess("Borrado de situacion juridica")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1424)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Imputacion situacion juridica")
    gdef.registerProcess("Imputacion situacion juridica")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdef.setExecutionId(1425)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Actualizacion Situacion Juridica") 
    gdef.registerProcess("CRE - Borrado de situacion juridica") 
    gdef.registerProcess("CRE - Imputacion situacion juridica") 
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")         
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Vencimiento de Fianza")
    gdef.registerProcess("Vencimiento de Fianza")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1437)
    gdefs.addGroup(gdef)
    
    # ITF CENDEU ACTIVAS
    gdef = GroupDefinition("CRE - Actualizacion detalle CENDEU")  #mz quito el tilde
    gdef.registerProcess("BCRA CENDEU ACTIVAS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1417)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - Prepara Clasificacion") 
    gdef.registerProcess("Prepara Clasificacion")
    gdef.setExecutionId(1428)
    gdefs.addGroup(gdef)            
    
    #ITF. BEE cuentas y abonados a Banca Empresa - 2.7.6
    gdef = GroupDefinition("ITF - BEE CUENTAS")
    gdef.setExecutionId(134)
    gdef.registerProcess("BEE CUENTAS")
    gdefs.addGroup(gdef)

    #Agrego Cliente Novedad Demo
    gdef = GroupDefinition("CLI - Cliente Novedad Demo")
    gdef.registerProcess("Cliente Novedad Demo") 
    gdefs.addGroup(gdef)
    #ITF - CAUSAS JUDICIALES - 2.12.17
    gdef = GroupDefinition("ITF - ECOM - Causas Judiciales - Alta de cuentas")
    gdef.registerProcess("Causas Judiciales - Validacion de registros")
    gdef.registerProcess("Causas Judiciales - Alta de cuentas")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(122)
    gdefs.addGroup(gdef)
    # ITF COBROS TUYA
    gdef = GroupDefinition("ITF - RECEPCION PAGOS TUYA")
    gdef.registerProcess("ITF PAGOS TUYA")
    gdef.setExecutionId(123)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Seguro Saldo Deudor")
    gdef.registerProcess("SP Seguro sobre saldo deudor")
    gdef.registerProcess("Seguro Saldo Deudor")
    gdef.setExecutionId(826)
    gdefs.addGroup(gdef)
    #2.14.1 LK TRX
    gdef = GroupDefinition("ITF - LK TRX")
    gdef.setExecutionId(126)
    gdef.registerProcess("LK TRX")
    gdef.registerProcess("Actualiza numerador Tarjeta Raiz")
    gdefs.addGroup(gdef)
    #Operacion 2825
    gdef = GroupDefinition("ITF - Link Maestro Tarjeta Debito")
    gdef.registerProcess("Link Maestro Tarjeta Debito")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    #ITF COMARB - PADRON - 2.9.1
    gdef = GroupDefinition("ITF - COMARB Padron")
    gdef.setExecutionId(129)
    gdef.registerProcess("COMARB Padron")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    #ITF TANGO IVA DIGITAL COMPRAS ALICUOTAS 1.18.5
    gdef = GroupDefinition("ITF - TANGO IVA DIGITAL COMPRAS ALICUOTAS")
    gdef.setExecutionId(130)
    gdef.registerProcess("Tango iva digital compras alicuotas")
    gdefs.addGroup(gdef)
    #ITF TANGO IVA DIGITAL COMPRAS COMPROBANTE 1.18.6
    gdef = GroupDefinition("ITF - TANGO IVA DIGITAL COMPRAS COMPROBANTE")
    gdef.setExecutionId(133)
    gdef.registerProcess("Tango iva digital compras comprobante")
    gdefs.addGroup(gdef)
    #CRE - Analisis de graduacion y grandes exposiciones
    gdef = GroupDefinition("CRE - Analisis de graduacion y grandes exposiciones")
    gdef.registerProcess("Analisis de graduacion y grandes exposiciones")
    gdef.setExecutionId(140)
    gdefs.addGroup(gdef)
    # ITF. BEE Movimientos conformados - 2.7.7
    gdef = GroupDefinition("ITF - BEE TENENCIA PF")
    gdef.setExecutionId(139)
    gdef.registerProcess("BEE TENENCIA PF")
    gdefs.addGroup(gdef)
    # ---------------------------------------------------------------------------------------------------------------------- #
#                          CLEARING - Sesion Presentados Propios (Se debe integran en apertura)                          #
# ---------------------------------------------------------------------------------------------------------------------- #
    # *** Procesos individuales del Grupo 1 INICIO ***
    # ITF - COELSA Cheques y Ajustes y Archivo de control de imagenes Cheques y Ajustes Persentados Recibidos - 2.8.2 - 2.8.41 - 2.8.42
    gdef = GroupDefinition("ITF - COELSA Cheques y Ajustes Presentados Recibidos CP0 VCP VIP")
    gdef.registerProcess("ACOELSA CHEQUES Y AJUSTES PROPIOS RECIBIDOS CP0")
    gdef.registerProcess("BCHEQUES PRESENTADOS RECIBIDOS IMG VCP")
    gdef.registerProcess("CCHEQUES PROPIOS RECIBIDOS ZIP CONTROL VIP")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    
    # ITF - COELSA DPFD y Archivo de control de imagenes DPFD y Ajustes Presentados Recibidos - 2.8.4 - 2.8.50 - 2.8.51
    gdef = GroupDefinition("ITF - COELSA DPFD y Ajustes Presentados Recibidos CP1 VCD VID")
    gdef.registerProcess("DCOELSA DPF Y AJUSTES PROPIOS RECIBIDOS CP1")
    gdef.registerProcess("EDPFD PRESENTADOS RECIBIDOS IMG VCD")
    gdef.registerProcess("FDPFD PRESENTADOS RECIBIDOS ZIP CONTROL VID")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # *** Procesos individuales del Grupo 1 FIN ***
    
    # *** Procesos individuales del Grupo 2 INICIO ***
    # ITF - COELSA Importacion Final Cheques y Ajustes Sesion Presentados Propios
    gdef = GroupDefinition("ITF - COELSA Importacion Final Cheques y Ajustes Sesion Presentados Propios")
    gdef.registerProcess("COELSA IMPORTACION FINAL CHEQUES Y AJUSTES SESION PRESENTADOS PROPIOS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    
    # ITF - COELSA Importacion Final DPFD Sesion Presentados Propios
    gdef = GroupDefinition("ITF - COELSA Importacion Final DPFD Sesion Presentados Propios")
    gdef.registerProcess("COELSA IMPORTACION FINAL DPFD SESION PRESENTADOS PROPIOS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # *** Procesos individuales del Grupo 2 FIN ***

    # *** Grupo de ejecucion 1 INICIO ***
    #Interfaz que levanta los archivos a tablas intermedias. Soporta Reproceso
    gdef = GroupDefinition("     CLEARING - Sesion Presentados Propios ITF")
    gdef.registerProcess("ITF - COELSA Cheques y Ajustes Presentados Recibidos CP0 VCP VIP")
    gdef.registerProcess("ITF - COELSA DPFD y Ajustes Presentados Recibidos CP1 VCD VID")
    gdef.setExecutionId(127)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # *** Grupo de ejecucion 1 FIN ***
    
    #Interfaz que importa los Cheques, Ajustes y Depositos desde las tablas intermedias. NO tiene vuelta Atras
    gdef = GroupDefinition("     CLEARING - Sesion Presentados Propios")
    gdef.registerProcess("CRE - Caida de Cheques Propio al Cobro") # mz se anexa este proceso
    gdef.registerProcess("ITF - COELSA Importacion Final Cheques y Ajustes Sesion Presentados Propios")
    gdef.registerProcess("ITF - COELSA Importacion Final DPFD Sesion Presentados Propios")
    gdef.registerProcess("ITF - Clearing Validacion Cheques Entrantes")
    gdef.registerProcess("CLE - Recepcion de Cheques Girados")
    gdef.registerProcess("CLE - Control DPF Compensables Propios")
    gdef.registerProcess("CLE - Procesamiento Cheques Electronicos Propios")
    gdef.setExecutionId(128)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("CRE - Migracion Detalle Calculo IOF Complementario")
    gdef.registerProcess("Migracion Detalle Calculo IOF Complementario")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)
    gdef = GroupDefinition("Regeneracion de Saldos Diarios Contabilidad")
    gdef.registerProcess("Rehacer Saldos Diarios Contabilidad")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)
    # ITF. BEE Movimientos conformados - 2.7.4
    gdef = GroupDefinition("ITF - BEE - MOVIMIENTOS")
    gdef.setExecutionId(165)
    gdef.registerProcess("BEE MOVIMIENTOS CONFORMADOS")
    gdefs.addGroup(gdef)

    #ITF BEE - EXTTRANSFER 2.7.5
    gdef = GroupDefinition("ITF - BEE EXTTRANSFER")
    gdef.setExecutionId(26)
    gdef.registerProcess("BEE EXTTRANSFER")
    gdefs.addGroup(gdef)

    #ITF BEE - CURSA TRANSFERENCIAS 2.7.1 - 2.7.5
    gdef = GroupDefinition("ITF - BEE CURSA TRANSFERENCIAS")
    gdef.setExecutionId(64)
    gdef.registerProcess("BEE CURSA TRANSFERENCIAS")
    gdefs.addGroup(gdef)


    # ITF. BEE Movimientos diferidos - 2.7.3
    gdef = GroupDefinition("ITF - BEE - MOVIMIENTOS DIFERIDOS")
    gdef.setExecutionId(166)
    gdef.registerProcess("BEE MOVIMIENTOS DIFERIDOS")
    gdefs.addGroup(gdef)
    # ITF. BEE SALDOS- 2.7.2
    gdef = GroupDefinition("ITF - BEE - SALDOS")
    gdef.setExecutionId(167)
    gdef.registerProcess("BEE SALDOS")
    gdefs.addGroup(gdef)
	
    gdef = GroupDefinition("CRE - Recategorizacion")
    gdef.registerProcess("Proceso de recategorizacion")
    gdef.setCanBeRootGroup("true")    
    gdef.setSingleton("false")        
    gdefs.addGroup(gdef)
	#Crear archivo PBF 
    gdef = GroupDefinition("POS - Genera PBF")
    gdef.registerProcess("Genera PBF POS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(288)
    gdefs.addGroup(gdef) 
    # CLS CBU Master 2.8.20
    gdef = GroupDefinition("CLS - CBU MASTER")
    gdef.registerProcess("CLS CBU MASTER")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdef.setExecutionId(164)
    gdefs.addGroup(gdef)
    # 2.14.35 LK – CBU OUT
    gdef = GroupDefinition("LK - LINK CBU OUT")
    gdef.registerProcess("LK CBU OUT")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdef.setExecutionId(168)
    gdefs.addGroup(gdef)
    # 2.14.36 LK –ECHEQ EXTRACT
    gdef = GroupDefinition("ITF ECHEQ LINK EXTRACT")
    gdef.registerProcess("ECHEQ_LINK_EXTRACT")
    gdef.setExecutionId(108)
    gdefs.addGroup(gdef)
    
# 1.31.13 NBCH24 - ECHEQ Deposito
    gdef = GroupDefinition("ITF ECHEQ NBCH24 EXTRACT DEPOSITO")
    gdef.registerProcess("ECHEQ_NBCH24_EXTRACT_DEPOSITO")
    gdef.setExecutionId(109)
    gdefs.addGroup(gdef)
        
    # TRANSFERENCIA SUELDOS PRESENTADOS 2.8.17
    gdef = GroupDefinition("ITF - TRANSFERENCIA SUELDOS PRESENTADOS PESOS")
    gdef.setExecutionId(566)
    gdef.registerProcess("TRANSFERENCIA SUELDOS PRESENTADOS PESOS")
    gdefs.addGroup(gdef)
    
    #TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES 2.8.19
    gdef = GroupDefinition("ITF - TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES")
    gdef.setExecutionId(59)
    gdef.registerProcess("TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES")
    gdefs.addGroup(gdef)
    # LK CBUG 2.14.12
    gdef = GroupDefinition("ITF - LK CBUG")
    gdef.registerProcess("LK CBUG")
    gdef.setExecutionId(232)
    gdefs.addGroup(gdef)
    # LK CBU Master 2.14.13
    gdef = GroupDefinition("LK - CBU MASTER")
    gdef.registerProcess("LK CBU MASTER")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdef.setExecutionId(169)
    gdefs.addGroup(gdef)

    # ITF: 2.28.1 ITF - INS - CPRESTAM
    gdef = GroupDefinition("ITF - INS - CPRESTAM")
    gdef.setExecutionId(226);
    gdef.registerProcess("INS CPRESTAM")
    gdefs.addGroup(gdef)

    # 1.11.8 I2000 - Contabilidad
    gdef = GroupDefinition("ITF - I2000 Contabilidad")
    gdef.setExecutionId(171)
    gdef.registerProcess("I2000 Contabilidad")
    gdef.registerProcess("Procesamiento de la Bandeja contable")
    gdef.registerProcess("I2000 ASIENTOS CONTABLES REPORTE")
    gdefs.addGroup(gdef)

    #ITF I2000 - PGC 1.11.15
    gdef = GroupDefinition("ITF - I2000 POSICION GENERAL DE CAMBIO")
    gdef.setExecutionId(14)
    gdef.registerProcess("I2000 POSICION GENERAL DE CAMBIO")
    gdefs.addGroup(gdef)

    # 1.19.6 UNITRADE - Contabilidad
    gdef = GroupDefinition("ITF - UNITRADE Contabilidad")
    gdef.setExecutionId(172)
    gdef.registerProcess("UNITRADE Contabilidad")
    gdef.registerProcess("Procesamiento de la Bandeja contable UNT")
    gdef.registerProcess("UNITRADE ASIENTOS CONTABLES REPORTE")
    gdefs.addGroup(gdef)
    # 1.18.8 TNG - AJUSTE
    gdef = GroupDefinition("ITF - TNG - AJUSTE Contabilidad")
    gdef.setExecutionId(173)
    gdef.registerProcess("TNG AJUSTE Contabilidad")
    gdef.registerProcess("Procesamiento de la Bandeja contable TNA")
    gdef.registerProcess("TNG AJUSTE ASIENTOS CONTABLES REPORTE")
    gdef.registerProcess("Aplicacion Movimientos OffLine")
    gdefs.addGroup(gdef)
    # 1.18.7 TNG - BU
    gdef = GroupDefinition("ITF - TNG - BU Contabilidad")
    gdef.setExecutionId(170)
    gdef.registerProcess("TNG BU Contabilidad")
    gdef.registerProcess("Procesamiento de la Bandeja contable TNB")
    gdef.registerProcess("TNG BU ASIENTOS CONTABLES REPORTE")
    gdefs.addGroup(gdef)
    # ITF COELSA DEB DIR EMPRESAS HOMOLOGADAS 2.8.12
    gdef = GroupDefinition("ITF - CLS DEBITOS DIRECTOS PADRON EMPRESAS HOMOLOGADAS")
    gdef.setExecutionId(176)
    gdef.registerProcess("CLS DEBITOS DIRECTOS PADRON EMPRESAS HOMOLOGADAS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # ANSES FALLECIDOS
    gdef = GroupDefinition("ANSES - FALLECIDOS")
    gdef.registerProcess("ANSES FALLECIDOS")
    gdef.setExecutionId(177)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # LK ADH - 2.14.18
    gdef = GroupDefinition("LK - ADH")
    gdef.registerProcess("LK ADH")
    gdef.setExecutionId(178)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    # 1.16.2 SOS - Operaciones
    gdef = GroupDefinition("ITF - SOS Operaciones")
    gdef.setExecutionId(175)
    gdef.registerProcess("SOS Operaciones")
    gdefs.addGroup(gdef)

    # CRM NOVEDADES DOMICILIOS 1.9.2
    gdef = GroupDefinition("CRM - NOVEDADES DOMICILIOS")
    gdef.setExecutionId(179)
    gdef.registerProcess("CRM NOVEDADES DOMICILIOS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

# Apertura Carga Fecha TOPAZ en CONTROL-M
    gdef = GroupDefinition("Apertura - Carga fecha TOPAZ en CONTROL-M")
    gdef.registerProcess("Carga fecha TOPAZ en CONTROL-M")
    gdef.setExecutionId(180)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # 1.18.9 TNG - BAJA
    gdef = GroupDefinition("ITF TNG BAJA")
    gdef.setExecutionId(181)
    gdef.registerProcess("TNG BAJA")
    gdefs.addGroup(gdef)


    # 1.18.4 TNG - Impactos
    gdef = GroupDefinition("ITF TNG IMPACTOS")
    gdef.setExecutionId(182)
    gdef.registerProcess("TNG IMPACTOS")
    gdefs.addGroup(gdef)    

    
    gdef = GroupDefinition("ITF - BITACORA RESETEO PARAMETRO") 
    gdef.registerProcess("BitacoraReseteoParametro") 
    gdef.setExecutionId(184)
    gdefs.addGroup(gdef)

   # AGIP RENDICION 2.2.4
    gdef = GroupDefinition("ITF - AGIP RENDICION") 
    gdef.registerProcess("ITF_AGIP_RENDICION") 
    gdef.setExecutionId(311)
    gdefs.addGroup(gdef)

   # LK RESTJDINAHB - 2.14.78
    gdef = GroupDefinition("LK - Respuesta Inhabilitacion TJD")
    gdef.registerProcess("LK RESTJDINAHB")
    gdef.setExecutionId(186)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

   # LK RESTJDINAHB - 2.14.79
    gdef = GroupDefinition("ITF ECHEQ LINK EXTRACT EMISION")
    gdef.registerProcess("ECHEQ_LINK_EXTRACT_EMISION")
    gdef.setExecutionId(230)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    # 1.31.5 NBCH24 - EXTRACT EMISION ECHEQ
    gdef = GroupDefinition("ITF ECHEQ NBCH24 EXTRACT EMISION")
    gdef.registerProcess("ECHEQ_NBCH24_EXTRACT_EMISION")
    gdef.setExecutionId(233)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    
    # LK TJDINAHB - 2.14.76
    gdef = GroupDefinition("LK - Inhabilitacion TJD")
    gdef.registerProcess("LK TJDINAHB")
    gdef.setExecutionId(185)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # UNITD-INTERVINIENTES 1.19.10
    gdef = GroupDefinition("ITF - UNITRADE INTERVINIENTES")
    gdef.registerProcess("UNITRADE INTERVINIENTES")
    gdef.setExecutionId(183)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    # CRM NOVEDADES CLIENTES 1.9.1
    gdef = GroupDefinition("CRM - NOVEDADES CLIENTES")
    gdef.setExecutionId(188)
    gdef.registerProcess("CRM NOVEDADES CLIENTES")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    # 1.16.4 SOS - Cuentas
    gdef = GroupDefinition("ITF - SOS Cuentas")
    gdef.setExecutionId(189)
    gdef.registerProcess("SOS Cuentas")
    gdefs.addGroup(gdef)

    # 1.16.9 SOS - CuentasCont
    gdef = GroupDefinition("ITF - SOS Cuentas Mensual")
    gdef.setExecutionId(190)
    gdef.registerProcess("SOS Cuentas Mensual")
    gdefs.addGroup(gdef)

    # 1.16.1 SOS - Clientes
    gdef = GroupDefinition("ITF - SOS Clientes")
    gdef.setExecutionId(191)
    gdef.registerProcess("SOS Clientes")
    gdefs.addGroup(gdef)

    # 1.16.3 SOS - Vinculacion
    gdef = GroupDefinition("ITF - SOS Vinculacion")
    gdef.setExecutionId(192)
    gdef.registerProcess("SOS Vinculacion")
    gdefs.addGroup(gdef)

    # 1.16.5 SOS - ClientesSinMov
    gdef = GroupDefinition("ITF - SOS Clientes Sin Movimiento")
    gdef.setExecutionId(196)
    gdef.registerProcess("SOS ClientesSinMov")
    gdefs.addGroup(gdef)

    # 1.11.10 I2000 - PLD_Cuentas
    gdef = GroupDefinition("ITF - I2000 Cuentas")
    gdef.setExecutionId(197)
    gdef.registerProcess("I2000 Cuentas")
    gdefs.addGroup(gdef)

    # 1.11.9 I2000 - PLD_Clientes
    gdef = GroupDefinition("ITF - I2000 Clientes")
    gdef.setExecutionId(198)
    gdef.registerProcess("I2000 Clientes")
    gdefs.addGroup(gdef)

    # 1.11.11 I2000 - PLD_Movimientos
    gdef = GroupDefinition("ITF - I2000 Movimientos")
    gdef.setExecutionId(200)
    gdef.registerProcess("I2000 Movimientos")
    gdefs.addGroup(gdef)
    
    # 1.16 ITF - SOS
    gdef = GroupDefinition("ITF - SOS")
    gdef.setExecutionId(193)
    gdef.registerProcess("SOS Operaciones")
    gdef.registerProcess("SOS Vinculacion")
    gdef.registerProcess("SOS Clientes")
    gdef.registerProcess("SOS Cuentas")
    gdef.registerProcess("SOS ClientesSinMov")
    gdefs.addGroup(gdef)

    # 1.16.7 SOS - ClientesCont
    gdef = GroupDefinition("ITF - SOS Clientes Mensual")
    gdef.setExecutionId(194)
    gdef.registerProcess("SOS Clientes Mensual")
    gdefs.addGroup(gdef)

    # 1.16.8 SOS - VinCont
    gdef = GroupDefinition("ITF - SOS Vinculacion Mensual")
    gdef.setExecutionId(201)
    gdef.registerProcess("SOS Vinculacion Mensual")
    gdefs.addGroup(gdef)

    # 1.3.28 AD - IMPACTOS
    gdef = GroupDefinition("ITF AD IMPACTOS")
    gdef.setExecutionId(202)
    gdef.registerProcess("AD IMPACTOS")
    gdefs.addGroup(gdef)


    #LK CAF 2.14.77
    gdef = GroupDefinition("ITF - LK CAF")
    gdef.registerProcess("LK CAF")
    gdef.setExecutionId(141)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    #ITF I2000 - PGC 1.11.12
    gdef = GroupDefinition("ITF - I2000 COD MOVIMIENTOS")
    gdef.setExecutionId(195)
    gdef.registerProcess("I2000 COD MOVIMIENTOS")
    gdefs.addGroup(gdef)
    # 1.29.3 DJP ACPRIV
    gdef = GroupDefinition("ITF - DJP ACPRIV")
    gdef.setExecutionId(199)
    gdef.registerProcess("DJP ACPRIV")
    gdefs.addGroup(gdef)
    # 2.4.1 ANSES - APERTURA
    gdef = GroupDefinition("ITF - ANSES APERTURA")
    gdef.setExecutionId(203)
    gdef.registerProcess("ANSES APERTURA")
    gdefs.addGroup(gdef)

    # 1.16.6 SOS - PerfilDoc
    gdef = GroupDefinition("ITF - SOS PerfilDoc Diario")
    gdef.setExecutionId(204)
    gdef.registerProcess("SOS PerfilDoc Diario")
    gdefs.addGroup(gdef)

    # 1.16.6 SOS - PerfilDoc
    gdef = GroupDefinition("ITF - SOS PerfilDoc Mensual")
    gdef.setExecutionId(205)
    gdef.registerProcess("SOS PerfilDoc Mensual")
    gdefs.addGroup(gdef)

    # 1.16.10 SOS - Actualización de datos de Perfil Documental
    gdef = GroupDefinition("ITF - SOS Actualiza Perfil Doc")
    gdef.setExecutionId(206)
    gdef.registerProcess("SOS Actualiza Perfil Doc")
    gdefs.addGroup(gdef)

    # 2.33.1 MiPyME - Padrón
    gdef = GroupDefinition("ITF - MIPYME PADRON")
    gdef.setExecutionId(207)
    gdef.registerProcess("MiPyME Padron")
    gdefs.addGroup(gdef)

def addMoreGroups2(gdefs):

    gdef = GroupDefinition("CBL - Contabilizacion Ajuste por Inflacion por fecha")
    gdef.registerProcess("Borrado tabla CO_HIS_AJUSTE_X_INFLACION por fecha")
    gdef.registerProcess("Calculo Ajuste por Inflacion por fecha")
    gdef.registerProcess("Contabilizo ajuste por inflacion por fecha")
    gdef.setExecutionId(72)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Calculo Ajuste por Inflacion por fecha")
    gdef.registerProcess("Calculo Ajuste por Inflacion por fecha")
    gdef.setExecutionId(71)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Borrado tabla historica Ajuste por Inflacion por fecha")
    gdef.registerProcess("Borrado tabla CO_HIS_AJUSTE_X_INFLACION por fecha")
    gdef.setExecutionId(70)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CBL - Devengamiento Unificado")
    gdef.registerProcess("DevengamientoPlazo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Transferencia entre Cuentas Reintento")
    gdef.registerProcess("Transferencias de fondos Reintento")
    gdef.registerProcess("Evento Generico transferencia fallida")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Transferencia entre Cuentas Periodica")
    gdef.registerProcess("Transferencias de fondos Periodica")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RCT - Transferencia Cobranzas a Convenios")
    gdef.registerProcess("Transferencia Cobranzas a Convenios")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RCT - Debitos Automaticos Multihilo")
    gdef.registerProcess("RCT - Cobranza Vista Multihilo")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("RCT - Transferencia Cobranzas a Convenios")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RCT - Cobranza Vista Multihilo")
    gdef.registerProcess("Cobranza Vista Multihilo")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                              Cadena de Cierre Integrada                                               #
# ---------------------------------------------------------------------------------------------------------------------- #


    gdef = GroupDefinition("     DIA - Procesos de Cierre Integrada ")
    gdef.registerProcess("GRL - Baja de asientos al cierre centralizado")
    gdef.registerProcess("PROCESO: Cambio de fecha sucursal virtual")
    gdef.registerProcess("GRL - Cierre de Sucursales")
    gdef.registerProcess("GRL - Marca Inicio de Cierre")
    gdef.registerProcess("CAJ - Carga Saldos Caja Historico")
    gdef.registerProcess("CAJ - Carga Saldos ATM Historico")
    gdef.registerProcess("REM - Reporte Movimiento Transportadora")
    gdef.registerProcess("REM - Reporte Movimiento Tesorero")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("CLI - Servicio Financiero Personas Juridicas")
    gdef.registerProcess("CLI - Servicio Financiero Personas Fisicas")
    gdef.registerProcess("CLI - Perfil Documental")
    gdef.registerProcess("CLI - Rechazar Solicitud Integrante Juzgado")
    gdef.registerProcess("CLI - Rechazar Solicitud Activar-Inactivar Causa")
    gdef.registerProcess("CVN - Convenios Pago - Inactivacion")
    gdef.registerProcess("CVN - Convenios Recaudacion - Inactivacion")
    gdef.registerProcess("CVN - Convenios Pago - Baja")
    gdef.registerProcess("CVN - Convenios Pago - Renovacion Baja")
    gdef.registerProcess("CVN - Convenios Recaudacion - Baja")
    gdef.registerProcess("CVN - Convenios Recaudacion - Renovacion Baja")
    gdef.registerProcess("CVN - Liquidacion Debito Automatico")
    gdef.registerProcess("CVN - Rendicion Debitos Automaticos")
    gdef.registerProcess("CVN - Servicio CV Remunerada")
    gdef.registerProcess("VTA - Analiza Cuentas Remuneradas")
    gdef.registerProcess("CVN - Comision mantenimiento Convenios")
    gdef.registerProcess("CVN - Liquidacion Recaudos Por Caja")
    gdef.registerProcess("VTA - Reversa de letras y cheques")
    gdef.registerProcess("VTA - Cobertura entre Grupos de Cuentas")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Bitacora Credeb para nuevas cuentas")
    gdef.registerProcess("VTA - Reservas Sobre Saldos")
    gdef.registerProcess("VTA - Cobranza Cargos Diferidos")
    gdef.registerProcess("VTA - Cobranza Cargos Diferidos FUCO")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Comision Mantenimiento de Cuentas Vista")
    gdef.registerProcess("VTA - Comision Mantenimiento Banca Empresa")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Control de Paquete y Campanias")
    gdef.registerProcess("VTA - Cargos por Mantenimiento de Paquete")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Instrucciones de Traspaso entre Cuentas")
    gdef.registerProcess("VTA - Cargo Estado de Cuenta ESPECIAL")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Cobranza Automatica Preparacion")
    gdef.registerProcess("CRE - Cobranza Automatica Cuota por Cuota")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Cobranza Automatica")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA: Reservas Para Cobranza Automatica")
    gdef.registerProcess("CRE - Adelanto haberes")
    gdef.registerProcess("CRE - Baja Pendientes Topaz POS")
    gdef.registerProcess("CRE - Baja Reserva Topaz POS")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Cobro Comisiones Garantia Otorgadas")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Seguro Saldo Deudor")
    gdef.registerProcess("CRE - Vencimiento de Fianza")
    gdef.registerProcess("CRE - Aviso de Vencimiento de Garantia")
    gdef.registerProcess("CBL - Cambio de Rubro Vista")
    gdef.registerProcess("VTA - Cargo cuenta inmovilizada")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Bloqueo Cuentas Vista inmovilizadas")
    gdef.registerProcess("VTA - Cancelacion de cuentas")
    gdef.registerProcess("Proceso - Corrimiento Vencimiento DPF")
    gdef.registerProcess("DPF - Inmovilizar saldos")
    gdef.registerProcess("DPF - Cancela DPF UVAUVI")
    gdef.registerProcess("DPF - Cancela DPF Titulo Valor")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista")
    gdef.registerProcess("VTA - Intereses Vista Saldo o Promedio Pago")
    gdef.registerProcess("CRE - Caida Automatica de Solicitudes de Asistencias")
    gdef.registerProcess("CRE - Crea Cronograma Devengado Diferente Tasa Interes")
    gdef.registerProcess("CRE - Devengar diferencia intereses tasa contractual/tasa mercado")
    gdef.registerProcess("CRE- Crea Comision Desembolso")
    gdef.registerProcess("GRL- DevengamientoComisionDesembolso")
    gdef.registerProcess("CRE - Renovacion Subsidios")
    gdef.registerProcess("CRE - Actualiza Riesgo Dolarizado")
    gdef.registerProcess("CRE - Actualiza Cliente Dolarizado")
    gdef.registerProcess("CRE - Asignacion de Credito Adicional")
    gdef.registerProcess("CRE - Cancelacion Acuerdos y Sobregiros")
    gdef.registerProcess("CRE - Extorno Contabilizacion Acuerdos en cuenta no utilizados")
    gdef.registerProcess("CRE - Consumo de Acuerdos y Sobregiros")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Devengado Intereses Deudores N Acuerdos")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("VTA - Cobro Intereses Deudores N Acuerdos")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Actualizar Tam-Empresa")
    gdef.registerProcess("CRE - Recategorizacion")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente Sin Categoria")
    gdef.registerProcess("CBL - Devengamiento Saldo Proporcional al Plazo")
    gdef.registerProcess("CRE - Analisis de devengado en suspenso")
    gdef.registerProcess("CBL - Cambio de Rubro por Vencido o Forzado")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Devengamiento Plazo Extorno Contabilizacion")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Genera IVA Financiado")
    gdef.registerProcess("GRL - Certificados de Retencion")
    gdef.registerProcess("GAR - Borrado tabla")
    gdef.registerProcess("GAR - Calculo Afectacion Garantias")
    gdef.registerProcess("GAR - Calculo Afectacion Prestamos sin Garantias")
    gdef.registerProcess("GAR - Extorno Contabilizacion Afectacion Garantias")
    gdef.registerProcess("GAR - Contabilizacion Afectacion de Garantias")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Prepara Clasificacion")
    gdef.registerProcess("CRE - Clasificacion Deuda No Refinanciada")
    gdef.registerProcess("CRE - Calificacion Objetiva Deuda Refinanciada")
    gdef.registerProcess("CRE - Actualizacion detalle CENDEU")
    gdef.registerProcess("CRE - Actualizacion CENDEU Nuevos Clientes")
    gdef.registerProcess("CRE - Actualizacion Situacion Sistema Financiero")
    gdef.registerProcess("CRE - Actualizacion detalle de Morosos Ex Entidades")
    gdef.registerProcess("CRE - Actualizacion detalle de Morosos Ex Entidades nuevos clientes")
    gdef.registerProcess("CRE - Actualizacion Situacion Morosos Ex Entidades")
    gdef.registerProcess("CRE - Borrado de situacion juridica")
    gdef.registerProcess("CRE - Imputacion situacion juridica")
    gdef.registerProcess("CRE - Borrado de discrepancia")
    gdef.registerProcess("CRE - Actualizacion de Discrepancia")
    gdef.registerProcess("CRE - Actualizacion Situacion Resultante")
    gdef.registerProcess("CBL - Exposicion de Sobregiros")
    gdef.registerProcess("CRE - Calculo de Prevision")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Actulizacion De Cuotas Prestamos")
    gdef.registerProcess("CRE - Sistema Interno de Calificacion")
    gdef.registerProcess("CBL - Actualizar Movimientos ajustes UVA UVI")
    gdef.registerProcess("CBL - Contabilizacion de ajustes UVA UVI")
    gdef.registerProcess("CBL - Registro historico fin de mes UVA UVI")
    gdef.registerProcess("CBL - Calculo Impuesto Movimiento Moneda Extranjera")
    gdef.registerProcess("GRL - Operaciones cambio retroactiva")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Resultados por Tenencia de Moneda Extranjera")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Resultados por Operaciones de Cambio")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Reaplica movimientos fecha valor en Saldos Diarios_Procesa todos")
    gdef.registerProcess("GRL - Solo Saldos Diarios")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad Actualizar - Fecha Valor")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad")
    gdef.registerProcess("BAL - Generacion de Balance Diario")
    gdef.registerProcess("CBL - Reporte Saldos Diarios Inconsistentes")
    gdef.registerProcess("CBL - Reporte Asientos Abiertos")
    gdef.registerProcess("GRL - Marca Fin de Cierre")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(1702)
    gdef.setSingleton("true")    
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("PROCESO: Extorno con Sucursal")
    gdef.registerProcess("Extorno con Sucursal")
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                              Cadena de Migracion - DIA 0                                             #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("MIG - Cadena de Migracion - DIA Cero")
    gdef.registerProcess("MIG - Grabo SALDOS_PRE_CADENA")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista")
    gdef.registerProcess("VTA - Bitacora Credeb para nuevas cuentas")
    gdef.registerProcess("CRE - Cancelacion Acuerdos y Sobregiros")
    gdef.registerProcess("CRE - Consumo de Acuerdos y Sobregiros")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")
    gdef.registerProcess("CRE - Genera IVA Financiado")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("MIG - Ejecucion GrupoCreaComision")
    gdef.registerProcess("GAR - Borrado tabla")
    gdef.registerProcess("GAR - Calculo Afectacion Garantias")
    gdef.registerProcess("GAR - Calculo Afectacion Prestamos sin Garantias")
    gdef.registerProcess("GAR - Contabilizacion Afectacion de Garantias")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Recategorizacion")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente Sin Categoria")
    gdef.registerProcess("CRE - Actualizacion detalle CENDEU")
    gdef.registerProcess("CRE - Actualizacion CENDEU Nuevos Clientes")
    gdef.registerProcess("CBL - Exposicion de Sobregiros")
    gdef.registerProcess("CRE - Calculo de Prevision")
    gdef.registerProcess("CRE - Contabilizacion Previsiones")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Actulizacion De Cuotas Prestamos")
    gdef.registerProcess("CAJ - Carga Saldos Caja Historico")
    gdef.registerProcess("CAJ - Carga Saldos ATM Historico")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Solo Saldos Diarios")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad")
    gdef.registerProcess("BAL - Generacion de Balance Diario")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("PROCESO: Cambio de fecha sucursal virtual")
    gdef.registerProcess("MIG - Grabo SALDOS_POST_CADENA")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

# ---------------------------------------------------------------------------------------------------------------------- #
#                                              Cadena de Migracion -Validacion'                                             #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("     MIG - Cadena de Migracion - Validacion")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista")
    gdef.registerProcess("CRE - Cancelacion Acuerdos y Sobregiros")
    gdef.registerProcess("CRE - Consumo de Acuerdos y Sobregiros")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente Sin Categoria")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")
    gdef.registerProcess("CRE - Genera IVA Financiado")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GAR - Borrado tabla")
    gdef.registerProcess("GAR - Calculo Afectacion Garantias")
    gdef.registerProcess("GAR - Calculo Afectacion Prestamos sin Garantias")
    gdef.registerProcess("GAR - Contabilizacion Afectacion de Garantias")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Prepara Clasificacion")
    gdef.registerProcess("CRE - Clasificacion Deuda No Refinanciada")
    gdef.registerProcess("CRE - Calificacion Objetiva Deuda Refinanciada")
    gdef.registerProcess("CRE - Actualizacion detalle CENDEU")
    gdef.registerProcess("CRE - Actualizacion CENDEU Nuevos Clientes")
    gdef.registerProcess("CRE - Actualizacion Situacion Sistema Financiero")
    gdef.registerProcess("CRE - Borrado de situacion juridica")
    gdef.registerProcess("CRE - Imputacion situacion juridica")
    gdef.registerProcess("CRE - Borrado de discrepancia")
    gdef.registerProcess("CRE - Actualizacion de Discrepancia")
    gdef.registerProcess("CRE - Actualizacion Situacion Resultante")
    gdef.registerProcess("CRE - Calculo de Prevision")
    gdef.registerProcess("CRE - Contabilizacion Previsiones")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Actulizacion De Cuotas Prestamos")
    gdef.registerProcess("CAJ - Carga Saldos Caja Historico")
    gdef.registerProcess("CAJ - Carga Saldos ATM Historico")
    gdef.registerProcess("DPF - Inmovilizar saldos")
    gdef.registerProcess("DPF - Cancela DPF UVAUVI")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("GRL - Solo Saldos Diarios")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad")
    gdef.registerProcess("BAL - Generacion de Balance Diario")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Canales - Reversa Cargos Especificos")
    gdef.registerProcess("Canales - Reversa Cargos Especificos")
    gdef.setExecutionId(1015)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CVN - Agencieros - Reversa REC_agencieros")
    gdef.registerProcess("Agencieros - Reversa REC_agencieros")
    gdef.setExecutionId(1016)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("DPF - Acreditacion DPF UVAUVI") 
    gdef.registerProcess("Traspaso acreditacion DPF UVA") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")    
    gdef.setExecutionId(851)
    gdefs.addGroup(gdef)

    #Mig Carga Devengado
    gdef = GroupDefinition("MIG - Carga Devengado")
    gdef.registerProcess("Mig Carga Devengado")
    gdefs.addGroup(gdef)

    #MIG_AJUSTE_RECALCULO y #MIG_ACTUALIZO_BS_HISTORIA_PLAZO
    gdef = GroupDefinition("MIG - Ajuste Recalculo")
    gdef.registerProcess("Mig Ajuste Recalculo") 
    gdefs.addGroup(gdef)
    # MIG - ITF ADINTAR USUARIOS - DG - MIGNBCAR-2459 - 13/05/2024
    gdef = GroupDefinition("MIG - ITF - ADINTAR USUARIOS")
    gdef.registerProcess("MIG - ADINTAR USUARIOS")
    gdefs.addGroup(gdef)

    # MIG_CASTIGADORTARJETERO
    gdef = GroupDefinition("MIG - Castigador Tarjetero") 
    gdef.registerProcess("MIG Castigador Tarjetero") 
    gdefs.addGroup(gdef) 

    # MIG - ITF ADINTAR SALDOS
    gdef = GroupDefinition("MIG - ITF - ADINTAR SALDOS")
    gdef.registerProcess("MIG - ADINTAR SALDOS")
    gdefs.addGroup(gdef)
    #MIG_AJUSTO_INVENTARIO
    gdef = GroupDefinition("MIG - Ajusto Inventario") 
    gdef.registerProcess("Mig Ajusto Inventario") 
    gdefs.addGroup(gdef)
    # MIG_ACTUALIZO_BS_HISTORIA_PLAZO
    gdef = GroupDefinition("MIG - Actualizo BS Historia Plazo") 
    gdef.registerProcess("Mig Actualizo BS Historia Plazo") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("EEC - Estado de cuenta Kettle Cuatrimestral")
    gdef.registerProcess("EstadosdeCuentaKetC")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("EEC - Estado de cuenta Kettle Semestral")
    gdef.registerProcess("EstadosdeCuentaKetZ")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Bitacora Credeb para nuevas cuentas") 
    gdef.registerProcess("Bitacora Credeb para nuevas cuentas") 
    gdef.setExecutionId(853)
    gdefs.addGroup(gdef)
	
    #Agrego Cobro Pendientes Topaz POS 
    gdef = GroupDefinition("CRE - Baja Pendientes Topaz POS")
    gdef.registerProcess("Cobro Pendientes Topaz POS")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(1650)    
    gdefs.addGroup(gdef)	
    
	#Agrego definicion para Oper 3404
    gdef = GroupDefinition("CLE - Contabiliza Rechazo Canje Interno")
    gdef.registerProcess("Contabiliza Rechazo Canje Interno")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(852)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Procesamiento Cheques Electronicos Propios") 
    gdef.registerProcess("Solicitudes Cheques Electronicos Propios") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Procesamiento Cheques Electronicos de Terceros") 
    gdef.registerProcess("Solicitudes Cheques Electronicos Terceros") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CLE - Actualiza Tipo Reg cheques electronicos") 
    gdef.registerProcess("Actualiza Tipo Reg Cheques Propios") 
    gdef.registerProcess("Actualiza Tipo Reg Cheques Terceros") 
    gdef.setExecutionId(860)
    gdefs.addGroup(gdef)

    # CON_TJC - Deuda Tarjetas de Credito
    gdef = GroupDefinition("TJC - Deuda Tarjetas de Credito") 
    gdef.registerProcess("TJC - Datos Deuda Tarjetas de Credito") 
    gdef.registerProcess("TJC - Contabilidad Deuda Tarjetas de Credito") 
    gdefs.addGroup(gdef)

    # CON_TJC - Extorno Deuda Tarjetas de Credito
    gdef = GroupDefinition("TJC - Extorno Saldos Tarjetas de Credito") 
    gdef.registerProcess("TJC - Extorno Saldos No Utilizados Tarjetas de Credito") 
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CON - Generacion estructura balance") 
    gdef.registerProcess("Generacion estructura balance") 
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Cheques Rechazados Datos")
    gdef.registerProcess("Cheques Rechazados")
    gdef.setExecutionId(1213)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Cheques Rechazados BCRA")
    gdef.registerProcess("Cheques Rechazados y Denunciados")
    gdef.setExecutionId(1214)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII Cheques Rechazados")
    gdef.registerProcess("CLE - Genera Nro de aviso")
    gdef.registerProcess("RPT - RRII Cheques Rechazados Datos")
    gdef.registerProcess("RPT - RRII Cheques Rechazados BCRA")
    gdef.setExecutionId(1200)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII DEUDORES SF TXT")
    gdef.registerProcess("DEUDORES_SF_TXT")
    gdef.setExecutionId(1216)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII DEUDORES SF DATOS")
    gdef.registerProcess("DEUDORES_SF_DATOS")
    gdef.setExecutionId(1217)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("RPT - RRII DEUDORES SF TXT - COMPLEMENTARIO")
    gdef.registerProcess("DEUDORES_SF_COMP_TXT")
    gdef.setExecutionId(1249)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("RPT - RRII DEUDORES SF DATOS - COMPLEMENTARIO")
    gdef.registerProcess("DEUDORES_SF_COMP_DATOS")
    gdef.setExecutionId(1248)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - ACTUALIZACION CADUCIDAD CHEQUES ELECTRONICOS")
    gdef.registerProcess("VTA - Actualiza estado cheques electronicos")
    gdef.setExecutionId(854)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("VTA - Analiza Cuentas Remuneradas")    
    gdef.registerProcess("Analiza Cuentas Remuneradas")    
    gdef.setExecutionId(855)
    gdefs.addGroup(gdef)

    #2.6.8 BCRA - OPCAM
    gdef = GroupDefinition("RPT - RRII OPCAM")
    gdef.registerProcess("BCRA OPCAM")
    gdef.setExecutionId(1215)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    #1.22.3 EPAGO - SOPORTE (Acreditacion Masiva)
    gdef = GroupDefinition("ITF - EPAGO Debitos y Creditos Masivos")
    gdef.registerProcess("Debitos y Creditos Masivos MonoHilo Un Asiento")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)

    # Asientos Varios VSAC SUPERPOWERS (IMPORTACION)
    gdef = GroupDefinition("ITF - AsientosVarios Importa VSAC")
    gdef.registerProcess("AsientosVarios_ImportaVSAC")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(298)
    gdefs.addGroup(gdef)
    # Asientos Varios VSAC SUPERPOWERS (IMPACTO)
    gdef = GroupDefinition("ITF - AsientosVarios Carga Bandeja")
    gdef.registerProcess("AsientosVarios_CargaBandeja")
    gdef.registerProcess("Debitos y Creditos Masivos MonoHilo Un Asiento")
    gdef.registerProcess("AsientosVarios_Respuesta")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdef.setExecutionId(299)
    gdefs.addGroup(gdef)

# 2.14.82 LK - Comisiones x Uso Cajero
    gdef = GroupDefinition("ITF - LK Cobro Comisiones ATM")
    gdef.registerProcess("LK Cobro Comisiones ATM")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(253)
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

# Bolsa Con Movimientos Pendientes de Impactar
    gdef = GroupDefinition("PA - Bolsa Con Movimientos SBCMPI")
    gdef.registerProcess("SBCMPI")
    gdef.registerProcess("SBCMPI - Debitos y Creditos Masivos")
    gdef.registerProcess("SBCMPI Resultado")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(254)
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
# BEE Banca Electr�nica de Empresas Cobro de Comisiones por Mantenimiento de Servicio
    gdef = GroupDefinition("ITF - BEE Cobro Comisiones")
    gdef.registerProcess("BEE Cobro Comisiones")
    gdef.setCanBeRootGroup("true")
    gdef.setExecutionId(255)
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

# 1.31.23 NBCH24 - ECHEQ DEPOGEN
    gdef = GroupDefinition("ITF ECHEQ NBCH24 DEPOGEN")
    gdef.setExecutionId(295)
    gdef.registerProcess("NBCH24_ECHEQ_DEPOGEN")
    gdefs.addGroup(gdef)

# 1.31.24 NBCH24 - ECHEQ GENEMISION
    gdef = GroupDefinition("ITF ECHEQ NBCH24 GENEMISION")
    gdef.setExecutionId(296)
    gdef.registerProcess("NBCH24_ECHEQ_GENEMISION")
    gdefs.addGroup(gdef)
    
    # Reporte Aseguradoras
    gdef = GroupDefinition("CRE - REPORTE ASEGURADORAS")
    gdef.registerProcess("Genera Datos Clientes")
    gdef.registerProcess("Genera Datos Productos")
    gdef.registerProcess("Genera rendicion Aseguradoras")    
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdef.setExecutionId(73)
    gdefs.addGroup(gdef)
	
    gdef = GroupDefinition("CRE - REPORTE ASEGURADORAS CLIENTES")
    gdef.registerProcess("Genera Datos Clientes")
    gdef.setExecutionId(74)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("CRE - REPORTE ASEGURADORAS PRODUCTOS")
    gdef.registerProcess("Genera Datos Productos")
    gdef.setExecutionId(75)
    gdefs.addGroup(gdef)
    
    gdef = GroupDefinition("CRE - REPORTE RENDICION ASEGURADORAS")
    gdef.registerProcess("Genera rendicion Aseguradoras")
    gdef.setExecutionId(76)
    gdefs.addGroup(gdef)    

#------------------------------------MIGRACION---------------------------------------#
#------------------------------------------------------------------------------------#
    # MIG Actualizo BS_HISTORIA_PLAZO
    gdef = GroupDefinition("MIG - Actualizo BS") 
    gdef.registerProcess("MIG Actualizo BS_HISTORIA_PLAZO") 
    gdefs.addGroup(gdef)

#----------------------------------------------------#
#------------Nuevos----------------------------------#
#----------------------------------------------------#

    # MIG_PREV_CON_DES
    gdef = GroupDefinition("MIG - PREVIO CONV DESEMBOLSO") 
    gdef.registerProcess("MIG PREVIO CONV DESEMBOLSO") 
    gdefs.addGroup(gdef)

    # MIG_POST_CON_DES
    gdef = GroupDefinition("MIG - POSTERIOR CONV DESEMBOLSO") 
    gdef.registerProcess("MIG POSTERIOR CONV DESEMBOLSO") 
    gdefs.addGroup(gdef)

    # MIG_GRABO_SALDOS
    gdef = GroupDefinition("MIG - Grabo Saldos") 
    gdef.registerProcess("MIG Grabo Saldos") 
    gdefs.addGroup(gdef)

    # MIG_ACTUALIZA_FECHAS
    gdef = GroupDefinition("MIG - Actualiza Fechas") 
    gdef.registerProcess("MIG Actualiza Fechas") 
    gdefs.addGroup(gdef)

    #MIG Grabo SALDOS_POST_RECALCULO
    gdef = GroupDefinition("MIG - Grabo SALDOS_POST_RECALCULO") 
    gdef.registerProcess("MIG Grabo SALDOS_POST_RECALCULO") 
    gdefs.addGroup(gdef)

    #MIG Grabo SALDOS_PRE_AJUSTE
    gdef = GroupDefinition("MIG - Grabo SALDOS_PRE_AJUSTE") 
    gdef.registerProcess("MIG Grabo SALDOS_PRE_AJUSTE") 
    gdefs.addGroup(gdef)

    #MIG Grabo SALDOS_PRE_CADENA
    gdef = GroupDefinition("MIG - Grabo SALDOS_PRE_CADENA") 
    gdef.registerProcess("MIG Grabo SALDOS_PRE_CADENA") 
    gdefs.addGroup(gdef)
 
    #MIG Grabo SALDOS_POST_CADENA
    gdef = GroupDefinition("MIG - Grabo SALDOS_POST_CADENA") 
    gdef.registerProcess("MIG Grabo SALDOS_POST_CADENA") 
    gdefs.addGroup(gdef) 
 
    #PRECADENA - Procesamiento de la Bandeja contable
    gdef = GroupDefinition("PRECADENA - Procesamiento de la Bandeja contable")
    gdef.registerProcess("PRECADENA Procesamiento de la Bandeja contable") 
    gdefs.addGroup(gdef)

    # MIG_ACTUALIZA_DPF_INMOV
    gdef = GroupDefinition("Mig - Actualiza DPF_Inmov") 
    gdef.registerProcess("Mig Actualiza DPF Inmov") 
    gdefs.addGroup(gdef) 

    # Mig_INT_CHE0006
    gdef = GroupDefinition("Mig - INT_CHE0006") 
    gdef.registerProcess("Mig INT_CHE0006") 
    gdefs.addGroup(gdef) 


# ---------------------------------------------------------------------------------------------------------------------- #
#           Ejecucion PRECadena de Migracion                                             #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("MIG - Ejecucion PRECadena")
    gdef.registerProcess("Mig - Actualiza DPF_Inmov")
    gdef.registerProcess("MIG - Grabo SALDOS_POST_RECALCULO") 
    gdef.registerProcess("PRECADENA - Procesamiento de la Bandeja contable") 
    gdef.registerProcess("MIG - Actualizo BS") 
    gdef.registerProcess("MIG - Ajuste Recalculo") 
    gdef.registerProcess("MIG - Grabo SALDOS_PRE_AJUSTE")
    gdef.registerProcess("MIG - Ajusto Inventario")
    gdefs.addGroup(gdef) 
# ---------------------------------------------------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------------------------------------------------- #
#           Ejecucion Grupo Adintar de Migracion                                             #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("MIG - Ejecucion GrupoAdintar") 
    gdef.registerProcess("MIG - ITF - ADINTAR USUARIOS")  #Nombre del archivo: ARCHUSUM.DAT
    gdef.registerProcess("MIG - ITF - ADINTAR SALDOS") #Nombre del archivo: SALDOSD.TXT
    gdef.registerProcess("MIG - Castigador Tarjetero") 
    gdefs.addGroup(gdef) 
# ---------------------------------------------------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------------------------------------------------- #
#           Ejecucion GrupoCreaComision                                             #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("MIG - Ejecucion GrupoCreaComision") 
    gdef.registerProcess("MIG - PREVIO CONV DESEMBOLSO") 
    gdef.registerProcess("CRE- Crea Comision Desembolso") 
    gdef.registerProcess("GRL- DevengamientoComisionDesembolso") 
    gdef.registerProcess("MIG - POSTERIOR CONV DESEMBOLSO") 
    gdefs.addGroup(gdef) 
# ---------------------------------------------------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------------------------------------------------- #
#           Ejecucion GrupoITF                                             #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("MIG - Ejecucion GrupoITF") 
    gdef.registerProcess("MIG - ITF LK TRX") #Nombre del archivo: RM.DAT
    gdef.registerProcess("MIG - ITF AFIP Padrones") #Nombre del archivo: PUCA.TMP
    gdef.registerProcess("MIG - ITF BCRA Padron PFPJ") #Nombre del archivo: PADFYJ.TXT
    gdefs.addGroup(gdef) 
# ---------------------------------------------------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------------------------------------------------- #
#                                              Cadena de Migracion - DIA 0                                               #
# ---------------------------------------------------------------------------------------------------------------------- #
    gdef = GroupDefinition("MIG - Cadena de Migracion - DIA Cero")
    gdef.registerProcess("MIG - Grabo SALDOS_PRE_CADENA")
    gdef.registerProcess("GRL - Actualizacion Diaria Historico de Tipos de Cambio")
    gdef.registerProcess("GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista")
    gdef.registerProcess("VTA - Bitacora Credeb para nuevas cuentas")
    gdef.registerProcess("CRE - Cancelacion Acuerdos y Sobregiros")
    gdef.registerProcess("CRE - Consumo de Acuerdos y Sobregiros")
    gdef.registerProcess("CBL - Devengamiento Plazo Calculo")
    gdef.registerProcess("CBL - Devengamiento Plazo Contabilizacion")
    gdef.registerProcess("CRE - Genera IVA Financiado")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("MIG - Ejecucion GrupoCreaComision")
    gdef.registerProcess("GAR - Borrado tabla")
    gdef.registerProcess("GAR - Calculo Afectacion Garantias")
    gdef.registerProcess("GAR - Calculo Afectacion Prestamos sin Garantias")
    gdef.registerProcess("GAR - Contabilizacion Afectacion de Garantias")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Recategorizacion")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente")
    gdef.registerProcess("CRE - Categoria Comercial del Cliente Sin Categoria")
    gdef.registerProcess("CRE - Actualizacion detalle CENDEU")
    gdef.registerProcess("CRE - Actualizacion CENDEU Nuevos Clientes")
    gdef.registerProcess("CBL - Exposicion de Sobregiros")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CRE - Actulizacion De Cuotas Prestamos")
    gdef.registerProcess("CAJ - Carga Saldos Caja Historico")
    gdef.registerProcess("CAJ - Carga Saldos ATM Historico")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")
    gdef.registerProcess("CBL - Contabilizacion de ajustes UVA UVI")
    gdef.registerProcess("GRL - Aplicacion Movimientos OffLine")	
    gdef.registerProcess("GRL - Solo Saldos Diarios")
    gdef.registerProcess("GRL - Saldos Diarios Contabilidad")
    gdef.registerProcess("BAL - Generacion de Balance Diario")
    gdef.registerProcess("PROCESO: Cambio de fecha sucursal virtual")
    gdef.registerProcess("MIG - Grabo SALDOS_POST_CADENA")
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("false")
    gdefs.addGroup(gdef)

    # 2.18.2 NCF - RESCATE
    gdef = GroupDefinition("NCF RESCATE")
    gdef.registerProcess("NCF_RESCATE")
    gdef.setExecutionId(300)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF - RML BANDAS")
    gdef.registerProcess("ITF RML BANDAS")
    gdef.setExecutionId(1250)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition(" ITF - RML BANDAS DISMINUCIONES")
    gdef.registerProcess("RML BANDAS DISMINUCIONES")
    gdef.setExecutionId(1250)
    gdefs.addGroup(gdef)

    #Conciliación TLF
    gdef = GroupDefinition("TJD - Conciliacion TopazPos")
    gdef.registerProcess("Conciliacion TopazPos - TLF LINK")
    gdef.setCanBeRootGroup("true")
    gdefs.addGroup(gdef)

    gdef = GroupDefinition(" ITF - RML BANDAS DISMINUCIONES")
    gdef.registerProcess("RML BANDAS DISMINUCIONES")
    gdef.setExecutionId(1250)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF ALTA DIARIA ECHEQ COELSA")
    gdef.registerProcess("ALTA_DIARIA_ECHEQ_COELSA")
    gdef.setExecutionId(46)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)


    gdef = GroupDefinition("Cle - Genera Cheques Rechazados - Canje Interno") 
    gdef.registerProcess("GeneraChequesRechazadosCanjeInterno") 
    gdef.setExecutionId(900)
    gdefs.addGroup(gdef)

    gdef = GroupDefinition("ITF DEPOSITO DIARIO ECHEQ NEGOCIADOS")
    gdef.registerProcess("ITF_DEPOSITO_DIARIO_ECHEQ_NEGOCIADOS")
    gdef.setExecutionId(208)
    gdef.setCanBeRootGroup("true")
    gdef.setSingleton("true")
    gdefs.addGroup(gdef)
    
   # TRANSFERENCIA MINORISTA PRESENTADAS 2.8.13_V2
    gdef = GroupDefinition("ITF - TRANSFERENCIA MINORISTA PRESENTADAS PESOS V2")
    gdef.setExecutionId(500)
    gdef.registerProcess("TRANSFERENCIA MINORISTA PRESENTADAS PESOS V2")
    gdefs.addGroup(gdef)

    # TRANSFERENCIA MINORISTA RECIBIDAS 2.8.14_V2
    gdef = GroupDefinition("ITF - TRANSFERENCIA MINORISTA RECIBIDAS PESOS V2")
    gdef.setExecutionId(501)
    gdef.registerProcess("TRANSFERENCIA MINORISTA RECIBIDAS PESOS V2")
    gdefs.addGroup(gdef)

    # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.15_V2
    gdef = GroupDefinition("ITF - COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES V2")
    gdef.setExecutionId(502)
    gdef.registerProcess("COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES V2")
    gdefs.addGroup(gdef)

	# TRANSFERENCIA MINORISTA RECIBIDAS 2.8.16_V2
    gdef = GroupDefinition("ITF - TRANSFERENCIA MINORISTA RECIBIDAS DOLARES V2")
    gdef.setExecutionId(503)
    gdef.registerProcess("TRANSFERENCIA MINORISTA RECIBIDAS DOLARES V2")
    gdefs.addGroup(gdef)

    # TRANSFERENCIA SUELDOS PRESENTADOS 2.8.17_V2
    gdef = GroupDefinition("ITF - TRANSFERENCIA SUELDOS PRESENTADOS PESOS V2")
    gdef.setExecutionId(504)
    gdef.registerProcess("TRANSFERENCIA SUELDOS PRESENTADOS PESOS V2")
    gdefs.addGroup(gdef)

	# SUELDOS PRESENTADOS RECIBIDOS PESOS 2.8.18_V2
    gdef = GroupDefinition("ITF - SUELDOS PRESENTADOS RECIBIDOS PESOS V2")
    gdef.setExecutionId(505)
    gdef.registerProcess("SUELDOS PRESENTADOS RECIBIDOS PESOS V2")
    gdefs.addGroup(gdef)

    #TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES 2.8.19_V2
    gdef = GroupDefinition("ITF - TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES V2")
    gdef.setExecutionId(506)
    gdef.registerProcess("TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES V2")
    gdefs.addGroup(gdef)

    # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.44_V2
    gdef = GroupDefinition("ITF - COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS V2")
    gdef.setExecutionId(507)
    gdef.registerProcess("COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS V2")
    gdefs.addGroup(gdef)

    #ITF COELSA TRANSFERENCIAS REJECTADAS PESOS 2.8.53_V2
    gdef = GroupDefinition("ITF - CLS TRANSFERENCIAS REJECTADAS PESOS V2")
    gdef.setExecutionId(508)
    gdef.registerProcess("Transf pres en pesos reject V2")
    gdefs.addGroup(gdef)

    #ITF COELSA TRANSFERENCIAS REJECTADAS DOLARES 2.8.54_V2
    gdef = GroupDefinition("ITF - CLS TRANSFERENCIAS REJECTADAS DOLARES V2")
    gdef.setExecutionId(509)
    gdef.registerProcess("Transf pres en dolares reject V2")
    gdefs.addGroup(gdef)

    # ---------------------------------------------------------------------------------------------------------------------- #
#                                            GRUPO TRANSFERENCIAS MINORISTAS V2                                            #
# ---------------------------------------------------------------------------------------------------------------------- #

    # Transferencias - Sesion Presentados
    gdef = GroupDefinition("Transferencias - Sesion Presentados V2")
    gdef.registerProcess("ITF - TRANSFERENCIA MINORISTA PRESENTADAS PESOS V2")
    gdef.registerProcess("ITF - COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES V2")
    gdef.setExecutionId(510)
    gdefs.addGroup(gdef)

    # Transferencias - Sesion Rechazadas / Sueldos
    gdef = GroupDefinition("Transferencias - Sesion Rechazadas / Sueldos V2")
    gdef.registerProcess("ITF - TRANSFERENCIA SUELDOS PRESENTADOS PESOS V2")
    gdef.registerProcess("ITF - COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS V2")
    gdef.setExecutionId(511)
    gdefs.addGroup(gdef)

    # Transferencias - Sesion Recibidas
    gdef = GroupDefinition("Transferencias - Sesion Recibidas V2")
    gdef.registerProcess("ITF - TRANSFERENCIA MINORISTA RECIBIDAS PESOS V2")
    gdef.registerProcess("ITF - TRANSFERENCIA MINORISTA RECIBIDAS DOLARES V2")
    gdef.registerProcess("ITF - SUELDOS PRESENTADOS RECIBIDOS PESOS V2")
    gdef.registerProcess("ITF - TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES V2")
    gdef.registerProcess("ITF - CLS TRANSFERENCIAS REJECTADAS PESOS V2")
    gdef.registerProcess("ITF - CLS TRANSFERENCIAS REJECTADAS DOLARES V2")
    gdef.registerProcess("TRF - Procesar transferencias recibidas")
    gdef.setExecutionId(512)
    gdefs.addGroup(gdef)
