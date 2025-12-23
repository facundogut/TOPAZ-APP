# package  topsystems.processmgr;
# -*- coding: latin-1 -*-
# Java import
from topsystems.processmgr.def import ProcessDefinitions
from topsystems.processmgr.def import ProcessDefinition
# jython import
# crea todos los grupos que se podran ejecutaran en el Process Manager
def createProcesses():

    pdefs = ProcessDefinitions()
    
    pdef = ProcessDefinition("Categorizacion", "topsystems.automaticprocess.categorizacion.CategorizacionCartera")
    pdefs.addProcess(pdef)
    # Clearing: Actualizacion de saldos pendientes
    pdef = ProcessDefinition("ClearingUpdateSaldosPendientes", "topsystems.automaticprocess.clearing.updatesaldospendientes.ProcesoUpdateSaldosPendPorClearing")
    #pdef.addParameter("CODIGO_CAMARA",1,"true");
    pdefs.addProcess(pdef) 
    # Recalculo
    pdef = ProcessDefinition("Carga Tabla de Detalle de Pagos", "topsystems.automaticprocess.recalculo.ProcesoGenerarDetallePagos")
    pdefs.addProcess(pdef)
    # Pago Periodico de Intereses de DPF
    pdef = ProcessDefinition("Pago Periodico de Intereses DPF", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPagoPeriodicoInteresesDPFDefault");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPagoPeriodicoInteresesDPFDefault");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerPagoPeriodicoInteresesDPFDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","2");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("pivotsCamposDeSaldo","34096,34096;");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("identificacionDeposito","operacion");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)
    # Cancelacion de DPF
    pdef = ProcessDefinition("Cancelacion DPF", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCancelacionDPFDefault");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCancelacionDPFDefault");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCancelacionDPFDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("campoFechaVigencia","1660");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("Renueva en saldo distinto", "false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("campoDiasCalculoInteres" ,"50019");
    pdef.addConstant("identificacionDeposito","operacion");
    pdef.addConstant("Contabiliza Capital e Interes separado","false");
    pdef.addConstant("CAMPO_SALDO_JTS_OID_ORIGEN","SALDO_JTS_OID_ORIGEN");
    pdef.addConstant("pivotsCamposDeSaldo","1659,1659;34096,34096;");
    pdef.addConstant("Acredita en Producto de Cuenta Corriente por Reserva Judicial","false");
    pdef.addConstant("CamposParaFacturas","");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)
    # PROCESO: CONTROL CAMPANIAS
    pdef = ProcessDefinition("Control Campanias", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_ACTUASALDOSCAMPANIA")
    pdefs.addProcess(pdef)
    # PROCESO: CONTROL PAQUETE
    pdef = ProcessDefinition("Control Paquetes", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_ACTUASALDOSPAQUETE")
    pdefs.addProcess(pdef)  
    # PROCESO: Cambio de Rubro
    pdef = ProcessDefinition("Cambio de Rubro","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCambioProductoRubro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCambioRubro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("MODALIDAD","R");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Exposicion de Sobregiros
    pdef = ProcessDefinition("ExposicionSobregiros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExposicionSobregiros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExposicionSobregiros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerExposicionSobregiros");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("nroCampoNroAutorizacion","1510");
    pdef.addConstant("nroCampoJtsOidSaldo","2504");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ExposicionSobregiros");
    pdefs.addProcess(pdef)
    # Cargo Bajo Promedio Cuentas Vistas
    pdef = ProcessDefinition("Cargo Bajo Promedio Cuentas Vistas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","212");
    pdef.addConstant("eventList","1100");
    pdef.addConstant("jtsOidFieldNumber","9461");
    pdef.addConstant("monedaFieldNumber","9467");
    pdef.addConstant("saldoActualFieldNumber","9469");
    pdef.addConstant("nroOperacion","8631");
    pdef.addConstant("descripcion","Cargo Bajo Promedio Cuentas Vistas");
    pdef.addConstant("reports","500");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Comision Mantenimiento Cuentas Vistas
    pdef = ProcessDefinition("Comision Mantenimiento Cuentas Vistas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","293");
    pdef.addConstant("eventList","1100");
    pdef.addConstant("jtsOidFieldNumber","9536");
    pdef.addConstant("monedaFieldNumber","9538");
    pdef.addConstant("saldoActualFieldNumber","9539");
    pdef.addConstant("nroOperacion","8663");
    pdef.addConstant("descripcion","Comision Mantenimiento Cuentas Vistas");
    pdef.addConstant("reports","500");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("readCliente","true");
    pdefs.addProcess(pdef)
    # Cargos Cuentas Vistas Exceso Movs Caja
    #pdef = ProcessDefinition("Cargos Cuentas Vistas Exceso Movs Caja", "topsystems.automaticprocess.processmanager.WorkManager")
    #pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    #pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    #pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    #pdef.addConstant("rangoCommit","500");
    #pdef.addConstant("cantidadHilos","15");
    #pdef.addConstant("isStopable","true");
    #pdef.addConstant("applySchemes","true");
    #pdef.addConstant("isSumarizable","false");
    #pdef.addConstant("offLine","true");
    #pdef.addConstant("enqueue","false");
    #pdef.addConstant("descriptor","262");
    #pdef.addConstant("eventList","1200");
    #pdef.addConstant("jtsOidFieldNumber","1565");
    #pdef.addConstant("monedaFieldNumber","1389");
    #pdef.addConstant("saldoActualFieldNumber","1397");
    #pdef.addConstant("nroOperacion","8639");
    #pdef.addConstant("descripcion","Cargos Cuentas Vistas Exceso Movs Caja");
    #pdef.addConstant("reports","500");
    #pdef.addConstant("canal","xxxxxx");
    #pdef.addConstant("generaAsientoContable","true");
    #pdefs.addProcess(pdef)  
    # Cargos Mantenimiento de Paquete
    pdef = ProcessDefinition("Cargos Mantenimiento de Paquete", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","220");
    pdef.addConstant("eventList","1000");
    pdef.addConstant("jtsOidFieldNumber","6635");
    pdef.addConstant("monedaFieldNumber","6633");
    pdef.addConstant("saldoActualFieldNumber","6636");
    pdef.addConstant("nroOperacion","8633");
    pdef.addConstant("descripcion","Cargos Mantenimiento de Paquete");
    pdef.addConstant("reports","500");
    pdef.addConstant("generaAsientoContable","true");	
    pdefs.addProcess(pdef)
    # Traspaso Cuentas Inmovilizadas a Tesoro Nacional
    pdef = ProcessDefinition("Traspaso Inmovilizadas a Tesoro Nacional", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorViewAndResume");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerViewAndResume");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","200");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","306");
    pdef.addConstant("eventList","1900");
    pdef.addConstant("condition","");
    pdef.addConstant("jtsOidFieldNumber","4577");
    pdef.addConstant("monedaFieldNumber","4573");
    pdef.addConstant("saldoActualFieldNumber","4578");
    pdef.addConstant("nroOperacion","8683");
    pdef.addConstant("descripcion","Trasp. Ctas. Inmov. a Tesoro");
    pdef.addConstant("reports","500");  
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    #Categorizacion de Cuentas Vista (cambio rubro)
    pdef = ProcessDefinition("Categorizacion Vista", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCategorizacionDeCartera");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCategorizacionDeCartera");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCategorizacionDeCartera");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");    
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("usaDobleCronograma","false");
    pdef.addConstant("consideraMoneda","false");
    pdef.addConstant("query","query.vo_clientesCategorizarVista"); 
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)
    # Bloqueo de Cuentas Vistas inmovilizadas
    pdef = ProcessDefinition("Bloqueo inmovilizados Vista", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_BLOQUEAR_INMOVILIZADOS_VISTA")
    pdefs.addProcess(pdef)
    # Clearing Recibir De Camara
    pdef = ProcessDefinition("ClearingRecibirDeCamara", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorClearingRecibirDeCamara");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerClearingRecibirDeCamara");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    #pdef.addParameter("CODIGO_CAMARA",1,"",0);
    #pdef.addParameter("CODIGO_CAMARA",1,"",1);
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoNumeroCheque","1090");
    pdef.addConstant("isSerialNumber","true");
    pdef.addConstant("campoBancoDepositante","2029");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("campoEstado","58406");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)
    # ClearingDevolucion
    pdef = ProcessDefinition("ClearingDevolucion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorClearingDevolucion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerClearingDevolucion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    #pdef.addParameter("CODIGO_CAMARA",1,"false");
    #pdef.addParameter("CODIGO_CAMARA",1,"",0);
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoMotivoDevolucion","4592");
    pdef.addConstant("campoBancoDepositante","4537");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)
    # ClearingEnvioCamaraCompensadora
    pdef = ProcessDefinition("ClearingEnvioCamaraCompensadora", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorEnvioCamaraCompensadora");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerEnvioCamaraCompensadora");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    #pdef.addParameter("CODIGO_CAMARA",1,"true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("contabilizar","false");
    pdef.addConstant("borraBandeja","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)  
    # ClearingEnvioCamaraCompensadora
    pdef = ProcessDefinition("ClearingEnvioCamaraCompensadoraBorra", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorEnvioCamaraCompensadora");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerEnvioCamaraCompensadora");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    #pdef.addParameter("CODIGO_CAMARA",1,"true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("contabilizar","false");
    pdef.addConstant("borraBandeja","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)  
    
    # Generacion Nro de aviso cheques rechazados
    pdef = ProcessDefinition("GeneraNroAviso","topsystems.automaticprocess.storedprocedures.SpBasicParameters") 
    pdef.addConstant("StoreName", "SP_GENERA_NRO_AVISO");
    pdefs.addProcess(pdef)

    # Control de cheques con motivo de rechazo temporal
    pdef = ProcessDefinition("ControlTemporal","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "PA_CONTROL_TEMPORALES");
    pdefs.addProcess(pdef)
    
    # Control de cheques sin digitalizar
    pdef = ProcessDefinition("ControlChqDigitalizado","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "PA_CONTROL_CH_DIGITALIZACION");
    pdefs.addProcess(pdef)
    
    # Control de DPF compensables propios aceptados por controles, pero sin confirmar por operación manual
    pdef = ProcessDefinition("ControlDpfConfirmado","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "SP_CONTROL_DPF_CONFIRMADOS");
    pdefs.addProcess(pdef)
    
    
    # Cobro de multas de cheques rechazados con/sin bonificación
    pdef = ProcessDefinition("MultasCheques", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.rechazoClearingDigitalMultas");
    pdefs.addProcess(pdef)
    
    # Operación de validación de DPF compensables propios
    pdef = ProcessDefinition("DPFPropiosValidaciones","topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(3710);
    pdefs.addProcess(pdef)
    
    # Operación de rechazo de DPF compensables Otro Banco
    pdef = ProcessDefinition("DPFRechazosOtroBanco","topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(3702);
    pdefs.addProcess(pdef)
    
    # Operación de acreditacion de DPF compensables Otro Banco
    pdef = ProcessDefinition("DPFAcreditacionOtroBanco","topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(3703);
    pdefs.addProcess(pdef)
    
    # Contabilidad cheques rechazados por clearing digital
    # Contabilidad cheques rechazados por clearing digital
    pdef = ProcessDefinition("RechazoClearingDigital", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.rechazoClearingDigital");
    pdefs.addProcess(pdef)

    # Proceso Envia Correo Canje interno 
    pdef = ProcessDefinition("Envia Correos Canje Interno", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.correosCanjeInterno");
    pdefs.addProcess(pdef)

    # Proceso Cobra Solicitudes de Canje interno 
    pdef = ProcessDefinition("Cobra Solicitudes Canje Interno", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.solicitudesCanjeInterno");
    pdefs.addProcess(pdef)

    # Proceso TJD Cobro Comisiones 
    pdef = ProcessDefinition("Cobro Comisiones TJD", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.tjdCobroComisiones");
    pdefs.addProcess(pdef)

    # Cobertura y Traspaso entre Cuentas
    pdef = ProcessDefinition("Traspaso entre Cuentas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorFundsTransfer");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerFundsTransfer");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerFundsTransfer");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("usaClienteEnComisiones","true");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdef.addConstant("permiteTransferenciaParcial","false");
    pdef.addConstant("activarBitacora","false");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("productosCodigoDiferente","80");
    pdef.addConstant("campoCargarProductoSaldoDebito","35690");
    pdef.addConstant("QUERY_NAME","query.FundsTransfer");
    pdef.addConstant("applyInstalationFields","true");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("Cobertura entre Cuentas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorFundsCoverage");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerFundsCoverage");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerFundsCoverage");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("orden","2");
    pdef.addConstant("usaClienteEnComisiones","true");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdef.addConstant("activarBitacora","false");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)
    #Intereses Vista Saldo o Promedio Pago
    pdef = ProcessDefinition("Intereses Vista Saldo o Promedio Pago", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDPagoIVSegunPromedioOSaldo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWPagoIVSegunPromedioOSaldo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","30");
    pdef.addConstant("usarSaldosRecortado","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("changeFrozenDate","false");
    pdef.addConstant("enFinMesDevengaHastaFinMes","true");
    pdef.addConstant("aplicaFechaValorFeriado","true");
    pdef.addParameter("JTS_OID",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("fieldDiasPromedio","50020");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("publicarTablasCargos","");
    pdef.addConstant("conceptoFieldCuenta","C50033");
    pdef.addConstant("usaClienteEnComisiones","true");
    pdefs.addProcess(pdef)
    # Cobranza Vista
    pdef = ProcessDefinition("Cobranza Vista", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCobranzaVistaDefault");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaVistaDefault");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCobranzaVistaDefault");	
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("priorityType", "topsystems:service:RequestSorting.ComisionExterna");
    pdef.addConstant("transactionByRequest", "false");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCobranzaVistaGestion");
    pdef.addConstant("fechaVencimiento","50027");
    pdef.addConstant("diasAtraso","50026");
    pdef.addConstant("mesesAtraso","50025");
    pdef.addConstant("deuda","50024");
    pdef.addConstant("mora","50023");
    pdef.addConstant("campoNombreConvenio","50022");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef) 
    # Clearing Recepcion de cheques Devueltos
    pdef = ProcessDefinition("ClearingRecepcionChequesDevueltos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRecepcionChequesDevueltos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRecepcionChequesDevueltos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    #pdef.addParameter("CODIGO_CAMARA",1,"",0);
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoNumeroCheque","7003");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("utilizarQuery","query.vo_BusquedaPorClaveExtendida");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Actualizacion diaria tipos de cambio - Historico
    pdef = ProcessDefinition("HistoricoTiposDeCambio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoTiposCambio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoTiposCambio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerHistoricoTiposCambio");
    pdef.addConstant("queryTipoCambioFeriados","INSERT INTO HISTORICOTIPOSCAMBIO (TZ_LOCK,CODIGO_TIPO_CAMBIO,MONEDA,FECHA_COTIZACION,TIPO_CAMBIO_COMPRA,TIPO_CAMBIO_VENTA,ARBITRAJE_COMPRA,ARBITRAJE_VENTA,TIPO_CAMBIO_OFICIAL,ARBITRAJE_CIERRE_OFICIAL) SELECT TZ_LOCK,CODIGO_TIPO_CAMBIO,MONEDA,?,TIPO_CAMBIO_COMPRA,TIPO_CAMBIO_VENTA,ARBITRAJE_COMPRA,ARBITRAJE_VENTA,TIPO_CAMBIO_OFICIAL,ARBITRAJE_CIERRE_OFICIAL FROM HISTORICOTIPOSCAMBIO WHERE FECHA_COTIZACION = ? AND CODIGO_TIPO_CAMBIO = ? AND MONEDA = ?");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("PROCESA_FERIADOS","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Cambio de Fecha de proceso
    pdef = ProcessDefinition("Cambio fecha proceso", "topsystems.processmgr.process.ChangeProcessDate")
    pdefs.addProcess(pdef)
   # Categorizacion de Prestamos y DPF Garantia
    pdef = ProcessDefinition("Categorizacion Prestamos y DPF Garantia", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCategorizacionDeCartera");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCategorizacionDeCartera");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCategorizacionDeCartera");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");    
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("criterioVtoFeriado","M");
    pdef.addConstant("estadoAtrasoAProcesar","V");
    pdef.addConstant("usaDobleCronograma","false");
    pdef.addConstant("consideraMoneda","false");
    pdef.addConstant("query","query.vo_clientesCategorizar");
    pdef.addConstant("pivotsCamposDeSaldo","1685,8358;1726,8359");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("generaAsientoContable","false");
    pdefs.addProcess(pdef)
    # CON - Categorizacion de Cartera - Prestamos
    pdef = ProcessDefinition("Categorizacion de Cartera - Prestamos", "topsystems.automaticprocess.processmanager.WorkManager")                                                                                    
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCategorizacionDeCartera");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCategorizacionDeCartera");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCategorizacionDeCartera");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("usaDobleCronograma","true");      
    pdef.addConstant("query","query.vo_saldosACategorizar");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("applyCodigoTransaccion","true"); 
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("pivotsCamposDeSaldo","1685,8358;1726,8359");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    
    # Genera los reportes en el formato indicado en la tabla reportes.
    pdef = ProcessDefinition("Reportes", "topsystems.automaticprocess.report.ReportOutProcessGenerator")
    pdef.addConstant("STORE_DISC","false");
    pdef.addConstant("STORE_BASE","true");
    pdef.addConstant("FILE_PATH","c:\\temp\\");
    pdefs.addProcess(pdef)
    # Proceso de reaplicacion de movimienos en cierre extendido
    pdef = ProcessDefinition("Reaplicacion Cierre Extendido", "topsystems.automaticprocess.newreaplicacion.ExtendedRepplayProcess")
    pdefs.addProcess(pdef)
    # Proceso de reaplicacion de movimienos generico
    pdef = ProcessDefinition("Reaplicacion de Movimientos", "topsystems.automaticprocess.newreaplicacion.ReplayProcess")
    pdefs.addProcess(pdef)
    # PROCESO: Prevision de saldos mensual
    pdef = ProcessDefinition("ResultadoPorValuacionDeActivosPasivosUF", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorResultadoPorValuacionUF");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerResultadoPorValuacionUF");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerResultadoPorValuacionUF");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Diferimiento de Camara
    pdef = ProcessDefinition("Diferimiento de Camara", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorClearingHouseDeferral");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerClearingHouseDeferral");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("SUCURSAL_DE_INGRESO",1,"",0);
    pdef.addParameter("FECHA_ALTA",4,"",1);
    pdef.addParameter("MONEDA",1,"",0);
    pdef.addParameter("BANCO_GIRADO",1,"",0);
    #pdef.addParameter("CODIGO_CAMARA",1,"",0);
    pdef.addParameter("SUCURSAL_BANCO_GIRADO",1,"",0);
    pdef.addParameter("FECHA_ACREDITACION",4,"",1);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 

    # PROCESO: Historico - Calculo de Saldos diarios y mensuales e InteresesVista
    pdef = ProcessDefinition("Historico Saldos e Intereses", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("usarSaldosRecortado","true");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("PROCESA_INTERESES","true");
    pdef.addConstant("CONDICION_SALDOS"," SAL_TIPO_PRODUCTO in (2, 3)");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("TIPOS_DE_PRODUCTO_INTERESES","1,2,3");
    pdefs.addProcess(pdef)
    # Pagos Automaticos
    pdef = ProcessDefinition("Pagos Automaticos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPagosAutomaticos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPagosAutomaticos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerPagosAutomaticos");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("paymentType","0");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Verificacion de cobro de las letras y cheques certificados
    pdef = ProcessDefinition("Reversa de letras y cheques", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorReversoChequesyLetras");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerReversoChequesyLetras");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef) 

    pdef = ProcessDefinition("Impuestos - Certificados de Retencion", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "PA_CERTIFICADOS_RETENCION");
    pdefs.addProcess(pdef)

   #Proceso depuración bandeja entrada altas masivas
    pdef = ProcessDefinition("MA Bandeja de entrada - Depuracion", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_MA_DEPURAR_BANDEJA_ENTRADA");
    pdefs.addProcess(pdef)

   #PROCESO: Proceso Altas Masivas
    pdef = ProcessDefinition("Proceso de Altas Masivas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("utilizaParametrosEntrada","true");
    pdef.addParameter("grupo_operacion",1)
   #pdef.addConstant("grupo_operacion","1");
    pdef.addConstant("QUERY_NAME","query.altas_masivas");
    pdefs.addProcess(pdef)

    # Cobranza Cargos sin FUCO
    pdef = ProcessDefinition("Cobranza Cargos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCobranzaCargos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaCargos");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("changeFrozenDate","false");
    pdef.addConstant("fieldReference","0000");
    pdef.addConstant("fieldConcept","0000");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("readCliente","true");
    pdef.addConstant("disminuirReservaEnCobro","false");
    pdef.addConstant("disponibilidadConReservasMayorPrioridad","false");
    pdef.addConstant("QUERY_NAME","query.vo_SolicitudCargos");
    pdefs.addProcess(pdef)
    # Cobranza Cargos FUCO
    pdef = ProcessDefinition("Cobranza Cargos FUCO", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCobranzaCargos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaCargos");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("changeFrozenDate","false");
    pdef.addConstant("fieldReference","0000");
    pdef.addConstant("fieldConcept","0000");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("readCliente","true");
    pdef.addConstant("disminuirReservaEnCobro","false");
    pdef.addConstant("disponibilidadConReservasMayorPrioridad","false");
    pdef.addConstant("QUERY_NAME","query.vo_SolicitudCargosFUCO");
    pdefs.addProcess(pdef)
    # PROCESO: Balances Diarios
    pdef = ProcessDefinition("Balances Diarios", "topsystems.automaticprocess.balance.GenerarBalance")
    pdef.addParameter("Fecha",4,"dd/MM/yyyy",0);
    pdef.addParameter("Nro. Balance",1,"",0);
    pdef.addConstant("generacion","D");
    pdef.addConstant("printBalance","true");
    pdefs.addProcess(pdef)
    # PROCESO: Balances Mensuales
    pdef = ProcessDefinition("Balances Mensuales", "topsystems.automaticprocess.balance.GenerarBalance")
    pdef.addParameter("Fecha",4,"dd/MM/yyyy",0);
    pdef.addParameter("Nro. Balance",1,"",0);
    pdef.addConstant("generacion","M");
    pdef.addConstant("printBalance","true");
    pdefs.addProcess(pdef)
    # PROCESO: RESULTADOS: Reproceso por operaciones de cambio
    pdef = ProcessDefinition("Reproceso de res. X op de cambio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorResultadoPorTenenciaYCambio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerResultadoPorTenenciaYCambio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerResultadoPorTenenciaYCambio");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("reproceso","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # CONTROL DE SUCURSALES CERRADAS
    pdef = ProcessDefinition("Control previo al Cierre Diario/Mensual", "topsystems.automaticprocess.control.CloseControlProcess")
    pdefs.addProcess(pdef)
    # Control Fechas
    pdef = ProcessDefinition("Control Fechas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorClearingControlFechas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerClearingControlFechas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerClearingControlFechas");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Diferimiento Presentacion a Camara
    pdef = ProcessDefinition("Diferimiento de Presentacion a Camara","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDiferimientoPresentacionACamara");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDiferimientoPresentacionACamara");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDiferimientoPresentacionACamara");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("SUCURSAL_DE_INGRESO",1,"",0);
    pdef.addParameter("MONEDA",1,"",0);
    #pdef.addParameter("CODIGO_CAMARA",1,"",0);
    pdef.addParameter("SUCURSAL_BANCO_GIRADO",1,"",0);
    pdef.addParameter("FECHA_ENVIO_CAMARA",4,"",1);       
    pdef.addParameter("NUEVA_FECHA_ENVIO_CAMARA",4,"",1);    
    pdef.addParameter("NUEVA_FECHA_ACREDITACION",4,"",1);   
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Provision de creditos
    pdef = ProcessDefinition("Generacion de vales por sobregiros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorValesPorSobregiros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerValesPorSobregiros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerValesPorSobregiros");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    #-->CAMBIA A FALSE:
    pdef.addConstant("SUBC1_C1040","false"); 
    #--> SE AGREGA CTE APERTURAxPLAZO:
    pdef.addConstant("APERTURAxPLAZO","false");
    pdef.addConstant("EVALUA_PLAZO","true");
    pdef.addConstant("EVALUA_RPN","false");
    pdef.addConstant("EVALUA_SOBREGIRO_AUTORIZADO","false");
    pdef.addConstant("SAL_CODACTIVIDADCIIU","1723");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Historico - Actualizacion de saldos diarios por vales
    pdef = ProcessDefinition("Actualizacion de saldos diarios por vales", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoClienteQuery");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("QUERY_NAME","query.vo_saldosDiariosVales");
    pdef.addConstant("PROCESA_INTERESES","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Liquidacion IRPF Anual
    pdef = ProcessDefinition("Liquidacion IRPF Anual", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorImpuestoALaGanancia");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerImpuestoALaGanancia");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");    
    pdef.addConstant("descriptor","213");
    pdef.addConstant("eventList","8621");
    pdef.addConstant("condition","");
    pdef.addConstant("jtsOidFieldNumber","4625");
    pdef.addConstant("saldoActualFieldNumber","4626");
    pdef.addConstant("monedaFieldNumber","4627");    
    pdef.addConstant("nroOperacion","8686");
    pdef.addConstant("descripcion","Liquidacion IRPF anual");
    pdef.addConstant("isResumable","true");
    pdef.addConstant("reports","500");    
    pdef.addConstant("readCliente","true");     
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Cancelacion de vales
    pdef = ProcessDefinition("Cancelacion de vales","topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCancelacionDeVales");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCancelacionDeVales");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCancelacionDeVales");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Bloqueo de cuentas
    pdef = ProcessDefinition("Bloqueo de cuentas","topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorClearingBloqueoDeCuentas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerClearingBloqueoDeCuentas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerClearingBloqueoDeCuentas");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    #pdef.addParameter("CLEARING_RANGO_CTA_BLOQ",4,"true");
    pdef.addParameter("CLEARING_RANGO_CTA_BLOQ",4,"dd/MM/yyyy");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Emision de letras 
    pdef = ProcessDefinition("Emision de letras", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorLetrasDeCambio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerLetrasDeCambio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");    
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("NUMERO_LOTE",1,"",0);
    pdef.addParameter("FECHA_ACREDITACION",4,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Transferencias a bancos 
    pdef = ProcessDefinition("Transferencias a bancos", "topsystems.automaticprocess.processmanager.WorkManager")    
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorTransferenciasABancos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerTransferenciasABancos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("NUMERADOR","7801");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("NUMERO_LOTE",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Numeracion y renumeracion de letras
    pdef = ProcessDefinition("Numeracion y renumeracion de letras", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRenumeracionLetras");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRenumeracionLetras");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ESTADO_ALTA_CHEQUE","L");
    pdef.addParameter("NRO_LETRA_DESDE",1,"",1);
    pdef.addParameter("NRO_LETRA_HASTA",1,"",0);
    pdef.addParameter("CHEQUE_SERIE",3,"",1);
    pdef.addParameter("NUEVO_NRO_DESDE",1,"",0);
    pdef.addParameter("NUEVO_NRO_HASTA",1,"",0);
    pdef.addParameter("NUEVA_SERIE",3,"",0);
    pdef.addParameter("A_PAGAR_LOTE",1,"",0);
    pdef.addParameter("A_PAGAR_MONEDA",1,"",0)
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Creditos Automaticos
    pdef = ProcessDefinition("Creditos Automaticos","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAutomaticCredit");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAutomaticCredit");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("LOTE_A_PROCESAR",1,"",0);
    pdef.addParameter("PROCESAMIENTO_INMEDIATO",1,"",0); 
    #pdef.addConstant("NUMERADOR","xxxx");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.QueryCreditosAutomaticos");
    pdefs.addProcess(pdef) 
    # PROCESO: Anulacion de letras
    pdef = ProcessDefinition("Anulacion de letras", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRenumeracionLetras");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRenumeracionLetras");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ESTADO_ALTA_CHEQUE","L");
    pdef.addConstant("ESTADO_ANULADO_CHEQUE","D");
    pdef.addConstant("ESTADO_ANULADO_LETRA","3");
    pdef.addParameter("NRO_LETRA_DESDE",1,"",1);
    pdef.addParameter("NRO_LETRA_HASTA",1,"",1);
    pdef.addParameter("CHEQUE_SERIE",3,"",1);
    pdef.addParameter("NUEVO_NRO_DESDE",1,"",0);
    pdef.addParameter("NUEVO_NRO_HASTA",1,"",0);
    pdef.addParameter("NUEVA_SERIE",3,"",0);
    pdef.addConstant("ANULACION","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Renovacion de cofres
    pdef = ProcessDefinition("Renovacion de Cajas de Seguridad", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRenovacionDeCofres");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRenovacionDeCofres");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerRenovacionDeCofres");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("reports","500"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Cobro de cofres
    pdef = ProcessDefinition("Cobro de Cajas de Seguridad", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.CobroCajaSeguridad");
    pdefs.addProcess(pdef)

    # PROCESO: GENERACION AVISOS COFRES
    pdef = ProcessDefinition("8103 - Generacion Pre Aviso Vencimiento","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","8103");
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("8104 - Generacion Aviso Mora", "topsystems.automaticprocess.basicreport.ReportProcess	")
    pdef.addConstant("REPORT","8104");
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef) 

    pdef = ProcessDefinition("8105 - Generacion Aviso Clearing","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","8105");
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef) 
    pdef = ProcessDefinition("GeneracionAvisosCofres", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_GENERACIONAVISOSCOFRES")    
    pdefs.addProcess(pdef)    
    # Cobranza Automatica
    pdef = ProcessDefinition("Cobranza Automatica", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCobranzaAutomatica");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaAutomatica");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","30");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("Campo capital restructurado","1685");
    pdef.addConstant("Campo interes restructurado","1726");
    pdef.addConstant("Pivot capital restructurado","733");
    pdef.addConstant("Pivot interes restructurado","734");
    pdef.addConstant("CAMPO_DEV_IVA_INTERES","0737");
    pdef.addConstant("consideraSobregiro","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("cobraOrdenadoPorCuota","TODAS");
    pdef.addConstant("disminuirReservaEnCobro","false");
    pdef.addConstant("disponibilidadConReservasMayorPrioridad","false");
    pdefs.addProcess(pdef)
    # Cobranza Automatica
    pdef = ProcessDefinition("Cobranza Automatica Online", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCobranzaAutomatica");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaAutomatica");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("disminuirReservaEnCobro","false");
    pdef.addConstant("disponibilidadConReservasMayorPrioridad","false");
    pdefs.addProcess(pdef)
    # PROCESO: Rendicion de cobranza 
    pdef = ProcessDefinition("Rendicion de cobranza", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRendicionCobranza");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRendicionCobranza");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerRendicionCobranza");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Actualizacion Fecha Inicio de Cobro (Recaudaciones cta Terceros)
    pdef = ProcessDefinition("Actualizacion Fecha Inicio de Cobro", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorActualizacionFechaCobro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerActualizacionFechaCobro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("FECHA_COBRO",4,"dd/MM/yyyy",0);
    pdef.addParameter("ID_CONVENIO",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Integracion de Pagos Recibidos
    # PROCESO: Integracion de Pagos Recibidos
    pdef = ProcessDefinition("Integracion de Pagos Recibidos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorIntegracionPagosRecibidos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerIntegracionPagosRecibidos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("numeradorLotes","50113");
    pdef.addConstant("numeroInicialAsiento","8000");
    pdefs.addProcess(pdef)
    # Integracion Recaudaciones Recibidas
    pdef = ProcessDefinition("Integracion recaudaciones recibidas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorIntegracionRecaudacionesRecibidas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerIntegracionRecaudacionesRecibidas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)  

    # PROCESO: Recalculo
    pdef = ProcessDefinition("Recalculo","topsystems.automaticprocess.recalculo.ProcesoRecalculo")
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("MA Bandeja de entrada - Depuracion", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_MA_DEPURAR_BANDEJA_ENTRADA");
    pdefs.addProcess(pdef)


    # GRL: RECALCULO NUEVO
    pdef = ProcessDefinition("RecalculoMigracion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesoRecalculoMigracion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesoRecalculoMigracion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesoRecalculoMigracion");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("JTS_OID_INICIO",1,"",1);
    pdef.addParameter("JTS_OID_FIN",1,"",1);
    pdef.addParameter("CONDITION_OQL",3,"",0);
    pdef.addParameter("ASIENTO_MADURACION",3,"",0);
    pdef.addParameter("LOG_CUOTAS_EVENTO",3,"",0);
    pdef.addParameter("CONDITION_SQL",3,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdef.addParameter("RESPETA_VENCIMIENTOS",3,"",0);
    pdefs.addProcess(pdef)
    # PROCESO: Transferencia a cuentas de Entes Recaudadores 
    pdef = ProcessDefinition("Transferencia Ctas Entes Recaudadores","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorTransferenciaEntes");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerTransferenciaEntes");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("idConvenio","50299");
    pdefs.addProcess(pdef) 
    # PROCESO: Balances Ejercicio
    pdef = ProcessDefinition("Balances Ejercicio", "topsystems.automaticprocess.balance.GenerarBalance")
    pdef.addParameter("Fecha",4,"dd/MM/yyyy",0);
    pdef.addParameter("Nro. Balance",1,"",0);
    pdef.addConstant("generacion","A");
    pdef.addConstant("printBalance","true");
    pdefs.addProcess(pdef)
    # Integracion Recepcion de Informacion de Deuda
    pdef = ProcessDefinition("Recepcion de Informacion de Deuda", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRecepcionDeudaInformada");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRecepcionDeudaInformada");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)  
    # PROCESO: Baja de asientos al cierre.
    pdef = ProcessDefinition("Baja de asientos al cierre centralizado","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDeletePostings");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDeletePostings");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)     
    # PROCESO: Baja de asientos al cierre casa central.
    pdef = ProcessDefinition("Baja de asientos al cierre por sucursal","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDeletePostings");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDeletePostings");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("SUCURSAL",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)    
    # ClearingEnvioCamaraContabilizacion
    pdef = ProcessDefinition("ClearingEnvioCamaraContabilizacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorEnvioCamaraContabilizacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerEnvioCamaraContabilizacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #pdef.addParameter("CODIGO_CAMARA",1,"",0);
    pdef.addParameter("FECHA_ENVIADO",4,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Proceso de activacion masiva de tarjetas
    pdef = ProcessDefinition("Activacion tarjetas de debito por bandeja", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_TJD_CAMBIO_ESTADO");
    pdef.addConstant("ParamtersPositions", "CancelaOtras,C;");
    pdef.addConstant("CancelaOtras","SI");
    pdefs.addProcess(pdef)
    # Proceso de cambio de estado masivo de tarjetas
    pdef = ProcessDefinition("Cambio estado tarjetas de debito por bandeja", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_TJD_CAMBIO_ESTADO");
    pdef.addConstant("ParamtersPositions", "CancelaOtras,C;");
    pdef.addConstant("CancelaOtras","NO");
    pdefs.addProcess(pdef)
    # Proceso de control de suspension de tarjetas
    pdef = ProcessDefinition("Control suspension de tarjetas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCardControl");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCardControl");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ESTADO_TARJETA","B"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Proceso de control de entrega de tarjetas 
    pdef = ProcessDefinition("Control entrega de tarjetas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCardControl");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCardControl");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ESTADO_TARJETA","Z");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Calificacion por atraso de la informacion
    pdef = ProcessDefinition("Calificacion por atraso en la documentacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPorAtrasoDocumentacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPorAtrasoDocumentacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerPorAtrasoDocumentacion");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Contabilizacion de deduccion de garantias
    pdef = ProcessDefinition("Contabilizacion de deduccion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorContabilizarDeduccion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerContabilizarDeduccion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerContabilizarDeduccion");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso Previsiones Especificas Contabilidad
    pdef = ProcessDefinition("Previsiones Especificas Contabilidad", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPrevisionesEspecificas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPrevisionesEspecificas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdefs.addProcess(pdef)
    # Proceso de Contagio de Calificacion Objetiva
    pdef = ProcessDefinition("Calificacion Objetiva - Contagio","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionObjetivaContagio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionObjetivaContagio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalificacionObjetivaContagio");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","4");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");    
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Comisiones Periodicas
    pdef = ProcessDefinition("Previsiones estadisticas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPrevisionesEstadisticas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPrevisionesEstadisticas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerPrevisionesEstadisticas");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso de Calificacion Resultante
    pdef = ProcessDefinition("Calificacion Resultante","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionResultante");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionResultante");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","20");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("categoriaAnterior","CATEGORIAANTERIOR");   
    pdef.addConstant("fechaCambioCategoria","FECHACAMBIOCATEGORIA"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Categoria Reestructura
    pdef = ProcessDefinition("Categoria Reestructura", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCategoriaReestructura");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCategoriaReestructura");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCategoriaReestructura");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso de Calificacion CLIENTE-BCU
    pdef = ProcessDefinition("Calificacion Cliente-Bcu","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionClienteBcu");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionClienteBcu");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso de Contagio de Calificacion resultante
    pdef = ProcessDefinition("Calificacion Resultante - Contagio","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionResultanteContagio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionResultanteContagio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","4");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso Previsiones Categorizacion Riesgos
    pdef = ProcessDefinition("Previsiones Categorizacion Riesgos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCategorizacionRiesgo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCategorizacionRiesgo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Categorizacion de Prestamos Vencidos Solo Migracion
    pdef = ProcessDefinition("Categorizacion Prestamos Vencidos Solo Migracion", "topsystems.automaticprocess.processmanager.WorkManager")                                                                                    
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCategorizacionDeCartera");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCategorizacionDeCartera");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCategorizacionDeCartera");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("criterioVtoFeriado","M");
    pdef.addConstant("estadoAtrasoAProcesar","V");
    pdef.addConstant("usaDobleCronograma","true");  
    pdef.addConstant("contabilizarRubros","false");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Recaudacion - Envio de novedades a terceros
    pdef = ProcessDefinition("Envio de novedades a terceros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorNovedadesTerceros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerNovedadesTerceros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)   
    # PROCESO: Calculo de Provision de creditos 
    pdef = ProcessDefinition("Provision de creditos: Calculo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalculoPrevision");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalculoPrevision");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalculoPrevision");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)
    # Proceso de Calificacion Cartera
    pdef = ProcessDefinition("Calificacion Cartera","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionCartera");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionCartera");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso llamado a servicion CV Remunerada
    pdef = ProcessDefinition("Servicio CV Remunerada", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ConsultaCVRemunerada");
    pdefs.addProcess(pdef)
    # Proceso de Categoria Comercial del Cliente
    pdef = ProcessDefinition("Actualizar Categoria Comercial del Cliente", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_CATEGORIZACION");
    pdefs.addProcess(pdef)
    # Proceso de Categoria Comercial del Cliente Sin Categoria
    pdef = ProcessDefinition("Actualizar Categoria Comercial del Cliente Sin Categoria", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_CATEGORIZACION_SINCAT");
    pdefs.addProcess(pdef)
    # INTERFASES: Levanta Bandeja Pago Terceros
    pdef = ProcessDefinition("Levanta Bandeja Pago Terceros", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "ITF_BandejaPagoTerceros")    
    pdefs.addProcess(pdef) 
    # INTERFASES: Levanta Bandeja Recaudaciones
    pdef = ProcessDefinition("Levanta Bandeja Recaudaciones", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_Recaudaciones")    
    pdefs.addProcess(pdef)
    #ITF Procesar Archivo CENDEU
    pdef = ProcessDefinition("BCRA CENDEU", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "60");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    pdefs.addProcess(pdef)
    #ITF Procesar CENDEU ACTIVAS
    pdef = ProcessDefinition("BCRA CENDEU ACTIVAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "61");   
    pdefs.addProcess(pdef)
    #ITF Procesar Archivo CREDEB MIPYME
    pdef = ProcessDefinition("BCRA CREDEB MIPYME", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BCRA_CREDEB_MIPYME.kjb");    
    pdef.addParameter("NOMBREARCHIVO",3);
    pdefs.addProcess(pdef)
    #ITF Procesar Archivo MOREXENT
    pdef = ProcessDefinition("BCRA MOREXENT", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BCRA_MOROSOS.kjb");    
    pdef.addParameter("archivo",3);
    pdefs.addProcess(pdef)
    #  Central de Riesgos
    pdef = ProcessDefinition("Central de Riesgos", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_CENTRAL_DE_RIESGOS.PROC_PROCESAR_SALDOS")
    pdefs.addProcess(pdef)   
    #  Operacion 1501 - Altas masivas
    pdef = ProcessDefinition("Altas Masivas - Procesar", "topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(1501);    
    pdefs.addProcess(pdef)    
    #  Operacion 5802 - Ingreso de Lote
    pdef = ProcessDefinition("Ingreso de Lote", "topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(5802);
    pdef.addParameter("NUMERO_LOTE",1);
    pdef.addParameter("CODIGOCLIENTE",1);
    pdefs.addProcess(pdef) 

    # PROCESO: Historicos Saldos Diarios y Mensuales - Reaplicacion de movimientos
    # PROCESO: Historicos Saldos Diarios y Mensuales - Reaplicacion de movimientos
    pdef = ProcessDefinition("Saldos D y M Reaplicacion de movimientos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorSaldosDyMReaplicacionMov");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerSaldosDyMReaplicacionMov");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerSaldosDyMReaplicacionMov");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("tipoproductosvista","2,3");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("corregirSaldoAjustadoMN","false");
    pdef.addConstant("GENERA_SALDO_MENSUAL","false");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","false");
    pdef.addConstant("PROCESA_SOLO_FECHA_PROCESO","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("GENERA_FERIADOS","true");
    pdef.addConstant("generaPromedioDiario","true");
    pdefs.addProcess(pdef) 
    
    # PROCESO: Historico: Saldos Diarios y Mensuales - Regeneracion
    pdef = ProcessDefinition("Saldos D y M Regeneracion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRehacerSaldosDiarios");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRehacerSaldosDiarios");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","10");
    pdef.addConstant("cantidadHilos","3");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("SAVE_ON_ERROR",1,"",0);
    pdef.addParameter("JTS_OID_FINAL",1,"",0);
    pdef.addParameter("JTS_OID",1,"",0);
    pdef.addParameter("FECHA_INICIO",4,"dd/MM/yyyy",1);
    pdef.addParameter("FECHA_FIN",4,"dd/MM/yyyy",0);
    pdef.addParameter("CONTROLA_EQUIVALENTE",1,"",0);
    pdef.addConstant("GENERA_SALDO_MENSUAL","false");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","true");
    pdef.addParameter("CONTROLA_MONEDA_NACIONAL",1,"",0);
    pdef.addConstant("CORREGIR_SALDO_MN","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addParameter("TABLA_FILTRO_JTS",1,"",0);
    pdefs.addProcess(pdef)   
    # INTERFASES: Levanta Bandeja Mocasist
    pdef = ProcessDefinition("Levanta Bandeja Mocasist", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_Mocasist")
    pdefs.addProcess(pdef)
    # INTERFASES: Levanta Bandeja Invegest
    pdef = ProcessDefinition("Levanta Bandeja Invegest", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_Invegest")
    pdefs.addProcess(pdef)
    # INTERFASES: Levanta Bandeja Cartera Morosos SNF
    pdef = ProcessDefinition("Levanta Bandeja Cartera Morosos SNF", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_Cartera")
    pdefs.addProcess(pdef)
    # INTERFASES: Levanta Bandeja Cartera Morosos SF
    pdef = ProcessDefinition("Levanta Bandeja Cartera Morosos SF", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_CarteraSF")    
    pdefs.addProcess(pdef)
    # Control de Clientes con integracion duplicada
    pdef = ProcessDefinition("clientesduplicados","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "clientesduplicados");
    pdefs.addProcess(pdef) 
    # Generacion Estados de Cuenta Mensuales (Cierre fin de Mes)
    pdef = ProcessDefinition("EstadosdeCuentaM","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", " ");
    pdef.addConstant("Periodicidad", "M");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef) 
    # Generacion Estados de Cuenta Parcial 
    pdef = ProcessDefinition("EstadosdeCuentaP","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", " ");
    pdef.addConstant("Periodicidad", "P");
    pdef.addParameter("FechaDesde",4,"dd/MM/yyyy",0);
    pdef.addParameter("FechaHasta",4,"dd/MM/yyyy",0);
    pdef.addParameter("SaldoJTSOID",1);
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,P;FechaHasta,P;SaldoJTSOID,P;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Diarios (Fin del Dia)
    pdef = ProcessDefinition("EstadosdeCuentaJ","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", " ");
    pdef.addConstant("Periodicidad", "J");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Semanal (Viernes)
    pdef = ProcessDefinition("EstadosdeCuentaS","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", " ");
    pdef.addConstant("Periodicidad", "S");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Decadarial (Cada 10 dias)
    pdef = ProcessDefinition("EstadosdeCuentaE","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", " ");
    pdef.addConstant("Periodicidad", "E");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Quincenal (Cada 15 dias)
    pdef = ProcessDefinition("EstadosdeCuentaQ","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", " ");
    pdef.addConstant("Periodicidad", "Q");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef)
    
    # Generacion Estados de Cuenta mensual
    pdef = ProcessDefinition("EstadosdeCuentaKetM","topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA.kjb")
    pdef.addConstant("Periodicidad", "M");
    pdef.addConstant("ParamtersPositions", "Periodicidad,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta mensual - Datos
    pdef = ProcessDefinition("EstadosdeCuentaKetMDATOSPA","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA_DATOS_PA.kjb")
    pdef.addConstant("Periodicidad", "M");
    pdef.addConstant("ParamtersPositions", "Periodicidad,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta mensual - Reporte
    pdef = ProcessDefinition("EstadosdeCuentaKetMREPPA","topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA_REP_PA.kjb")
    pdef.addConstant("Periodicidad", "M");
    pdef.addConstant("ParamtersPositions", "Periodicidad,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Semestral - Datos
    pdef = ProcessDefinition("EstadosdeCuentaKetZDATOSPA","topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA_DATOS_PA.kjb")
    pdef.addConstant("Periodicidad", "Z");
    pdef.addConstant("ParamtersPositions", "Periodicidad,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Semestral - Reporte
    pdef = ProcessDefinition("EstadosdeCuentaKetZREPPA","topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA_REP_PA.kjb")
    pdef.addConstant("Periodicidad", "Z");
    pdef.addConstant("ParamtersPositions", "Periodicidad,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Cuatrimestral - Datos
    pdef = ProcessDefinition("EstadosdeCuentaKetCDATOSPA","topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA_DATOS_PA.kjb")
    pdef.addConstant("Periodicidad", "C");
    pdef.addConstant("ParamtersPositions", "Periodicidad,C;");
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Cuatrimestral - Reporte
    pdef = ProcessDefinition("EstadosdeCuentaKetCREPPA","topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA_REP_PA.kjb")
    pdef.addConstant("Periodicidad", "C");
    pdef.addConstant("ParamtersPositions", "Periodicidad,C;");
    pdefs.addProcess(pdef)
    # Generacion Reporte Excepciones Seguridad
    pdef = ProcessDefinition("Excepcionoperaciones","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "PA_BITACORA_EXCEPCIONES");
    pdefs.addProcess(pdef)
    # PROCESO: Extorno Asiento
    pdef = ProcessDefinition("Extorno", "topsystems.automaticprocess.extorno.ExtornProcess")
    pdef.addParameter("FECHA_VALOR",4,"dd/MM/yyyy",0);
    pdef.addParameter("esAjusteParam",3,"",0);
    pdef.addParameter("WHERE_SENTENCIA",3,"",1);
    pdef.addParameter("CANTIDAD_REGISTROS",1,"",1);
    pdef.addConstant("validaExtornoSobregiro","true");
    #pdef.addParameter("esAjusteParam",3,"",0);
    #pdef.addParameter("tipoAjuste",1,"",0);
	# PROCESO: Reporte Detalle de Asientos Diarios
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("Reporte Detalle de Asientos Diarios", "topsystems.reports.reportesbasicos.ReporteGenerico")
    pdef.addConstant("FILE_NAME","RepAsientosDiarios");
    pdef.addConstant("OUPUT_TYPE","5");
    #pdef.addConstant("OUTPUT_PATH","C:\\Users\fabio\Documents\");
    pdefs.addProcess(pdef)
    # INTERFASES: Genera Bandeja Retiros Tarjetas
    pdef = ProcessDefinition("Genera Bandeja Retiros Tarjetas", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_Retiros_Tarj")
    pdefs.addProcess(pdef)
    # INTERFASES: Genera Bandeja LectoGrabadora
    pdef = ProcessDefinition("Genera Bandeja LectoGrabadora", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_LECTOGRABADORADP500")
    pdefs.addProcess(pdef)
    # INTERFASES: Recepcion de Cheques desde PRECODATA
    pdef = ProcessDefinition("Op 3605 - Cheques Recibidos desde PRECODATA", "topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(3605);
    pdefs.addProcess(pdef)
    # INTERFASES: Reclasificacion de Tarjetas
    pdef = ProcessDefinition("Reclasificacion de Tarjetas", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_CENTRAL_RIESGO_MARCA")
    pdefs.addProcess(pdef)
    # INTERFASES: Apertura Capital e Interes
    pdef = ProcessDefinition("Apertura Capital e Interes", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_CENTRAL_RIESGO_MOVS")
    pdefs.addProcess(pdef)
    # INTERFASES: Actualizar Intereses de Tarjetas
    pdef = ProcessDefinition("Actualizar Intereses de Tarjetas", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_CENTRAL_RIESGO_MOVS_1")
    pdefs.addProcess(pdef)
    # INTERFASES: Extornar Saldos de Tarjetas
    pdef = ProcessDefinition("Extornar Saldos de Tarjetas", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_EXTORNO_CRIESGO")
    pdefs.addProcess(pdef)
    # INTERFASES: Cerear Intereses de Tarjetas
    pdef = ProcessDefinition("Cerear Intereses de Tarjetas", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_EXTORNO_CRIESGO_1")
    pdefs.addProcess(pdef)
    # Generacion Itf_rct_preventivo
    pdef = ProcessDefinition("Genera ITF_RCT_PREVENTIVO", "topsystems.automaticprocess.sp.SpGeneracionRCTPreventivo")
    pdefs.addProcess(pdef) 
    # PROCESO: Valores - Pago de Cupon
    pdef = ProcessDefinition("Valores - Pago de Cupon", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPagoCupon");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPagoCupon");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerGenerarImportesValores");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CODIGO_TITULO",1,"",1);
    pdef.addParameter("NUMERO_CUPON",1,"",1);
    pdef.addConstant("FUNCIONALIDAD","P");
    pdef.addParameter("FECHA_DE_CALCULO",4,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Proceso de Cancelacion Valores
    pdef = ProcessDefinition("Cancelacion Valores","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCancelacionValores");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCancelacionValores");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ID_TITULO",1,"",0);
    pdef.addParameter("FECHA_VENCIMIENTO",4,"",0); 
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addParameter("CUPON",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso de Cancelacion Valores Proyeccion
    pdef = ProcessDefinition("Cancelacion Valores Proyeccion","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCancelacionValores");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCancelacionValores");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ID_TITULO",1,"",0);
    pdef.addParameter("FECHA_VENCIMIENTO",4,"",0);
    pdef.addConstant("CONTABILIZA","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)   
    # INTERFASES: Embozado tarjetas Debito
    pdef = ProcessDefinition("Op 2812 - Embozado tarjetas Debito", "topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(2812);
    pdefs.addProcess(pdef)    
    # INTERFASES: Genera Baneja Solicitudes Chequeras
    pdef = ProcessDefinition("Genera Baneja Solicitudes Chequeras", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_ENVIO_PRECODATA")
    pdefs.addProcess(pdef)
    # INTERFASES: Novedades de Tarjetas Credito
    pdef = ProcessDefinition("Op 9966 - Procesar Tarjeta de Credito", "topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(9966);
    pdefs.addProcess(pdef)
    # INTERFASES: Relacion Cuenta-Tarjeta
    pdef = ProcessDefinition("CAF- Envio Relacion Cuenta-Tarjeta", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_Itf_envio_CAF");
    pdefs.addProcess(pdef)
    # INTERFASES: Movimientos de Tarjetas
    pdef = ProcessDefinition("PBF- Envio Movimientos de Tarjetas", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_Itf_envio_PBF");
    pdefs.addProcess(pdef)
    # PROCESO: Valores - Generacion de importes
    pdef = ProcessDefinition("Valores - Proyeccion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorGenerarImportesValores");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerGenerarImportesValores");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerGenerarImportesValores");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CODIGO_TITULO",1,"",1);
    pdef.addParameter("NUMERO_CUPON",1,"",1);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Proceso de Cancelacion Valores Proyeccion
    pdef = ProcessDefinition("Cancelacion Valores Proyeccion","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCancelacionValores");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCancelacionValores");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ID_TITULO",1,"",0);
    pdef.addParameter("FECHA_VENCIMIENTO",4,"",0);
    pdef.addConstant("CONTABILIZA","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso de Cancelacion Valores
    pdef = ProcessDefinition("Cancelacion Valores","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCancelacionValores");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCancelacionValores");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ID_TITULO",1,"",0);
    pdef.addParameter("FECHA_VENCIMIENTO",4,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Valores - Pago de Cupon
    pdef = ProcessDefinition("Valores - Pago de Cupon", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPagoCupon");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPagoCupon");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerGenerarImportesValores");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CODIGO_TITULO",1,"",1);
    pdef.addParameter("NUMERO_CUPON",1,"",1);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)    
    # PROCESO: Valuacion Por Cotizacion
    pdef = ProcessDefinition("Valuacion Por Cotizacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorValuacionPorCotizacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerValuacionPorCotizacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false"); 
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("TIPO_EVALUACION","EVALUACION_DISTINTO_SALDOXCONTRASIENTO");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("VTO_EMISION_POR_DEFECTO","1800-02-01 00:00:00");
    pdefs.addProcess(pdef)
    # Proceso de Devengamiento Valores  
    pdef = ProcessDefinition("Devengamiento Valores","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDevengamiento");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDevengamiento");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso para todas las solicitudes asociadas con cheques
    pdef = ProcessDefinition("Acreditacion Solicitudes Cheques", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #pdef.addParameter("grupo_operacion",1);
    pdef.addConstant("grupo_operacion","1");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # INTERFASES: Genera Archivos Estado de Cuenta
    pdef = ProcessDefinition("Genera Archivos Estado Cuenta", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_ITF_ESTADO_CUENTA.itf_genestadocuenta");    
    pdefs.addProcess(pdef)
    # PROCESO: TRASLADOCARTERA
    pdef = ProcessDefinition("TrasladoCartera", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_TRASLADOCARTERA");
    pdef.addConstant("ParamtersPositions", "OficialOrigen,P;OficialDestino,P;");
    pdef.addParameter("OficialOrigen",3,"",1);
    pdef.addParameter("OficialDestino",3,"",1);
    pdefs.addProcess(pdef) 
    # PROCESO: Procesamiento de la bandeja de entrada
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",1);
    #pdef.addConstant("ORIGEN_A_PROCESAR_CTE","XXX");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: CONTROL PERFIL CLIENTE
    pdef = ProcessDefinition("Control Perfil Cliente", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_CONTROLPERFILCLIENTE")    
    pdefs.addProcess(pdef)
    # Validacion de clientes para compra de cartera
    #pdef = ProcessDefinition("Validacion Clientes Compra Cartera", "topsystems.automaticprocess.interfaces.compraCartera.SpValidacionClientesCompraCartera")
    #pdefs.addProcess(pdef)
    # Liquidacion de Ventas Diarias para Visa
    pdef = ProcessDefinition("Liquidacion de Ventas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorLiquidacionVentas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerLiquidacionVentas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerLiquidacionVentas");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Adelanto de efectivo por cupones
    pdef = ProcessDefinition("Adelanto por cupones", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAdelantoCupones");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAdelantoCupones");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerAdelantoCupones");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # INTERFASES: Conciliaciones
    pdef = ProcessDefinition("Genera Bandeja Conciliaciones", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_CONCILIACIONES");
    pdefs.addProcess(pdef)
    # INTERFASES: Conciliaciones diferido
    pdef = ProcessDefinition("Genera Bandeja Conciliaciones Diferida", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_CONCILIACIONES");
    pdef.addConstant("ParamtersPositions", "FechaDiferida,P;");
    pdef.addParameter("FechaDiferida",4,"dd/mm/yyyy",1);
    pdefs.addProcess(pdef)
    # INTERFASES: Contable Vertical
    pdef = ProcessDefinition("Genera Bandeja Contable Vertical", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_BandejaContableVertical");
    pdefs.addProcess(pdef)
    # INTERFASES: Altas Compras Cartera
    pdef = ProcessDefinition("Genera Bandeja Altas Compras Cartera", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_AltasCompraManentia");
    pdefs.addProcess(pdef)
    # INTERFASES: Cancelaciones Compras Cartera
    pdef = ProcessDefinition("Genera Bandeja Cancelaciones Compra Cartera", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_AltasPagosManentia");    
    pdefs.addProcess(pdef)
    # INTERFASES: Ventas Diarias
    pdef = ProcessDefinition("Genera Bandeja Ventas Diarias", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_VENTASDIARIAS");
    pdefs.addProcess(pdef)
    # INTERFASES: Pagos a Comercios
    pdef = ProcessDefinition("Genera Bandeja Pagos a Comercios", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_PAGOSCOMERCIOS");
    pdefs.addProcess(pdef)
    # INTERFASES: Pagos a Sueldos    
    pdef = ProcessDefinition("Genera Bandeja Pagos Sueldos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_BandejaPagoSueldos");
    pdefs.addProcess(pdef)
    # INTERFASES: TLF Efectivo Banred
    pdef = ProcessDefinition("Genera Bandeja TLF-Banred", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_TLFBANRED");
    pdefs.addProcess(pdef)
    # INTERFASES: Cheques Banred
    pdef = ProcessDefinition("Genera Bandeja Cheques Banred", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_ChequesBANRED");    
    pdefs.addProcess(pdef)
    # INTERFASES: INHABILITADOS INAES
    pdef = ProcessDefinition("Carga de Tabla Inhabilitados INAES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "78");    
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_INAES.kjb");    
    pdef.addParameter("NOMBRE",3,"Nombre archivo con extension",1);
    pdefs.addProcess(pdef)
    # LK RM - 2.14.2
    pdef = ProcessDefinition("LK RM", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_RM.kjb")
    pdefs.addProcess(pdef)
    # LK RMOUT - 2.14.3
    pdef = ProcessDefinition("LK RMOUT", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_RMOUT.kjb");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdefs.addProcess(pdef)
    # 2.14.15 LK UMOZ
    pdef = ProcessDefinition("LK UMOZ", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_UMOZ.kjb")
    pdefs.addProcess(pdef)
    # INTERFASES: EMERIX ARCHIVOS PLANOS
    pdef = ProcessDefinition("ITF EMERIX Archivos Planos", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_EMERIX_ARCHIVOS.kjb");
    pdefs.addProcess(pdef)
    # ITF ADINTAR DEUDASCTA
    pdef = ProcessDefinition("ADINTAR DEUDASCTA", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AD_DEUDACTAS.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "Adintar Deudas Cuentas");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdefs.addProcess(pdef)
    # ITF ADINTAR USUARIOS 1.3.6
    pdef = ProcessDefinition("ADINTAR USUARIOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("NOMBRE_INTERFASE", "Adintar Usuarios");
    pdef.addConstant("ID_MASTER", "39");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdefs.addProcess(pdef)
    # ITF ADINTAR SALDOS 1.3.7
    pdef = ProcessDefinition("ADINTAR SALDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TC_AD_SALDOS.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "Adintar Saldos");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdefs.addProcess(pdef)

    # ITF ADINTAR DEUDAS PLASTICOS
    pdef = ProcessDefinition("ADINTAR DEUDAS PLASTICOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("NOMBRE_INTERFASE", "Adintar Deudas Plasticos");
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TC_AD_DEUDAPLAS.kjb");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdefs.addProcess(pdef)
    # ITF ADINTAR AHORA12
    pdef = ProcessDefinition("AHORA 12", "topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("ID_MASTER", "108") 
    pdef.addParameter("NOMBREARCHIVO", 3, "ARCHIVO.EXTENSION") 
    pdef.addParameter("PERIODOPROCESO", 3, "AAAAMMDD") 
    pdefs.addProcess(pdef)
    #ITF CAUSAS JUDICIALES - 2.12.18 
    pdef = ProcessDefinition("Causas Judiciales Activas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CAUSAJUDICIALES_A.kjb")
    pdef.addConstant("ID_MASTER", "113")
    pdef.addParameter("FECHA_DESDE",3,"Fecha (ddMMyyyy)",1)
    pdef.addParameter("FECHA_HASTA",3,"Fecha (ddMMyyyy)",1)
    pdefs.addProcess(pdef)
    #ITF CAUSAS JUDICIALES - 2.12.19 
    pdef = ProcessDefinition("Causas Judiciales Inactivas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CAUSAJUDICIALES_I.kjb")
    pdef.addConstant("ID_MASTER", "114")
    pdef.addParameter("FECHA_DESDE",3,"Fecha (ddMMyyyy)",1)
    pdef.addParameter("FECHA_HASTA",3,"Fecha (ddMMyyyy)",1)
    pdefs.addProcess(pdef)
    #ITF CAUSAS JUDICIALES - 2.12.20
    pdef = ProcessDefinition("Causas Judiciales Transferidas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CAUSAJUDICIALES_T.kjb")
    pdef.addConstant("ID_MASTER", "115")
    pdef.addParameter("FECHA_DESDE",3,"Fecha (ddMMyyyy)",1)
    pdef.addParameter("FECHA_HASTA",3,"Fecha (ddMMyyyy)",1)
    pdefs.addProcess(pdef)
    #ITF CAUSAS JUDICIALES - 2.12.21 
    pdef = ProcessDefinition("Causas Judiciales Padron Completo", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CAUSAJUDICIALES_U.kjb")
    pdef.addConstant("ID_MASTER", "116")
    pdef.addParameter("FECHA_DESDE",3,"Fecha (ddMMyyyy)",0)
    pdef.addParameter("FECHA_HASTA",3,"Fecha (ddMMyyyy)",0)
    pdefs.addProcess(pdef)
    #ITF CAUSAS JUDICIALES - 2.12.18 - 2.12.19 - 2.12.20 
    pdef = ProcessDefinition("Causas Judiciales", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CAUSAJUDICIALES_MASTER.kjb")
    pdef.addConstant("ID_MASTER", "117")
    pdef.addParameter("FECHA_DESDE",3,"Fecha (ddMMyyyy)",1)
    pdef.addParameter("FECHA_HASTA",3,"Fecha (ddMMyyyy)",1)
    pdefs.addProcess(pdef)
    # INTERFACES: ADINTAR CARGOS
    pdef = ProcessDefinition("ADINTAR CARGOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ADINTAR_CARGOS.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "ADINTAR CARGOS");
    pdef.addConstant("ID_MASTER", "64");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdef.addParameter("fechaprocesar",3,"Ingresar Periodo con formato YYYYMMDD",1);
    pdefs.addProcess(pdef)
    # INTERFACES: ADINTAR TASAS
    pdef = ProcessDefinition("ADINTAR TASAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ADINTAR_TASAS.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "ADINTAR TASAS");
    pdef.addConstant("ID_MASTER", "65");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdef.addParameter("fechaprocesar",3,"Ingresar Periodo con formato YYYYMMDD",1);
    pdefs.addProcess(pdef)
    # INTERFACES: LEX DOCTOR SALIDA
    pdef = ProcessDefinition("LexDoctor Salida Lista Clientes", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LEXDOCTOR_SALIDA.kjb");
    pdef.addParameter("fecha",3,"AAAAMMDD",1);
    pdefs.addProcess(pdef)
    
    # INTERFACES: Carga Padron Convenios
    pdef = ProcessDefinition("Carga Padron Convenios", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PADRON_CONVENIOS.KJB");
    pdef.addConstant("NOMBRE_INTERFASE", "Padron Convenios");
    pdef.addParameter("archivo",3,"Nombre archivo con extension",1);
    pdef.addParameter("TICKET",1,"",0);
    pdefs.addProcess(pdef)
    # INTERFASES: Generacion Informe lavado BCU
    #pdef = ProcessDefinition("Informe Lavado BCU","topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    #pdef.addConstant("StoreName", "PKG_ITF_ARCH_MENS_OPES.ITF_SP_GEN_ARCH");
    #pdef.addParameter("MesDesde",4,"dd/mm/yyyy",1);
    #pdef.addConstant("ParamtersPositions", "MesDesde,P;");
    #pdefs.addProcess(pdef)
    #  Operacion 2022 - Proceso de Registros Contables
    pdef = ProcessDefinition("Op 2022 - Proceso de Registros Contables", "topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(2022);
    pdefs.addProcess(pdef)  
    # Procesamiento de la bandeja de entrada de Technisegur
    pdef = ProcessDefinition("Bandeja de entrada Technisegur", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBuzonTechnisegur");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBuzonTechnisegur");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerBuzonTechnisegur");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Procesamiento de la bandeja de entrada de Banred
    pdef = ProcessDefinition("Bandeja de entrada Banred", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBuzonBanred");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBuzonBanred");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerBuzonBanred");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Procesamiento de la bandeja de entrada de Banred
    pdef = ProcessDefinition("Bandeja de entrada Banred", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBuzonBanred");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBuzonBanred");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerBuzonBanred");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Baja base negativa
    pdef = ProcessDefinition("Baja base negativa", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_BASE_NEGATIVA.PROC_BAJA_AUTOMATICA")
    pdefs.addProcess(pdef)  
    #  PROCESO: Alta base negativa
    pdef = ProcessDefinition("Alta base negativa", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_BASE_NEGATIVA.PROC_ALTA_AUTOMATICA")
    pdefs.addProcess(pdef)   
    pdef = ProcessDefinition("8103 - Generacion Pre Aviso Vencimiento","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","8103");
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("8104 - Generacion Aviso Mora","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","8104");
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef) 
    pdef = ProcessDefinition("8105 - Generacion Aviso Clearing","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","8105");
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef) 
    pdef = ProcessDefinition("GeneracionAvisosCofres", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_GENERACIONAVISOSCOFRES")    
    pdefs.addProcess(pdef)    
    # Topes Regulatorios 
    pdef = ProcessDefinition("Topes Regulatorios Batch", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_TOPES_REGULATORIOS.PROC_REGULATORIOS_BATCH")
    pdefs.addProcess(pdef)  
    # Liquidacion de cupones visa
    pdef = ProcessDefinition("Liquidacion de cupones Amex y Argencard", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorLiquidacionCuponesAmexArgencard");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerLiquidacionCuponesAmexArgencard");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerLiquidacionCuponesAmexArgencard");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Liquidacion de cupones visa
    pdef = ProcessDefinition("Liquidacion de cupones visa", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorLiquidacionCupones");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerLiquidacionCupones");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerLiquidacionCupones");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Numeracion de cheques a partir de los pagos
    pdef = ProcessDefinition("Numeracion y renumeracion de cheques", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorEmisionCheques");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerEmisionCheques");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerEmisionCheques");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ESTADO_ALTA_CHEQUE","L");
    pdef.addParameter("NRO_CHEQUE_DESDE_ACTUAL",1,"",1);
    pdef.addParameter("NRO_CHEQUE_HASTA_ACTUAL",1,"",1);
    pdef.addParameter("SERIE_ACTUAL_CHEQUES",3,"",1);
    pdef.addParameter("NRO_CHEQUE_DESDE_NUEVO",1,"",0);
    pdef.addParameter("NRO_CHEQUE_HASTA_NUEVO",1,"",0);
    pdef.addParameter("SERIE_NUEVA_CHEQUES",3,"",0);
    pdef.addParameter("MARCA_A_TRATAR",3,"",1);
    pdef.addParameter("MONEDA_A_TRATAR",1,"",1); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Depuracion de solicitudes de credito vencidas
    pdef = ProcessDefinition("Depuracion de solicitudes de credito vencidas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDepuracionSolicitudes");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDepuracionSolicitudes");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("NUMERADOR","1139");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)  
    # Comisiones Periodicas
    pdef = ProcessDefinition("Previsiones estadisticas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPrevisionesEstadisticas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPrevisionesEstadisticas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerPrevisionesEstadisticas");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Recepcion pagos pronto
    pdef = ProcessDefinition("Recepcion Pagos Pronto", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRecepcionPagosPronto");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRecepcionPagosPronto");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerRecepcionPagosPronto");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("controlTotalPronto","0.02");
    pdef.addConstant("controlTopazPronto","10");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("aceptaSobregiro","true"); 
    pdef.addParameter("id_lote",3,"",1);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: ALTA CREDITOS COMPRA DE CARTERA paso 1
    pdef = ProcessDefinition("Alta Creditos Compra Cartera Paso 1","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("ParamtersPositions", "p_Lote,P;");
    pdef.addParameter("p_Lote",1,"",1);
    pdef.addConstant("StoreName", "ITF_CRE_COMPRA_CARTERA_1");
    pdefs.addProcess(pdef) 
    # PROCESO: ALTA CREDITOS COMPRA DE CARTERA paso 2 nuevo producto prestamo 1510
    pdef = ProcessDefinition("Alta Creditos Compra Cartera Paso 1(1510)","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("ParamtersPositions", "p_Lote,P;");
    pdef.addParameter("p_Lote",1,"",1);
    pdef.addConstant("StoreName", "ITF_CRE_COMPRA_CARTERA_1_1510");
    pdefs.addProcess(pdef) 
    # PROCESO: el paso de validacion de cartera le pone a fuego el 1210, se corrije con este sp
    pdef = ProcessDefinition("Arreglo PRONTO producto 1210->1510","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("ParamtersPositions", "p_Lote,P;");
    pdef.addParameter("p_Lote",1,"",1);
    pdef.addConstant("StoreName", "SP_ARREGLO_PROD_PRONTO");
    pdefs.addProcess(pdef) 
    # PROCESO: Recalculo Compra de Cartera
    #    pdef = ProcessDefinition("Recalculo Compra de Cartera", "topsystems.automaticprocess.recalculo.ProcesoRecalculoMigracionConst")
    #    pdef.addConstant("JTS_OID_INICIO","0");
    #    pdef.addConstant("JTS_OID_FIN","0");
    #    pdef.addConstant("LOG_CUOTAS_EVENTO","false");
    #    pdef.addConstant("ASIENTO_AJUSTE","false");
    #    pdef.addConstant("CONDITION_OQL","C1682=1");
    #    pdef.addConstant("RESPETA_VENCIMIENTOS","false");
    #    pdefs.addProcess(pdef)
    # PROCESO: ALTA CREDITOS COMPRA DE CARTERA paso 2
    pdef = ProcessDefinition("Alta Creditos Compra Cartera Paso 2","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ITF_CRE_COMPRA_CARTERA_2");
    pdefs.addProcess(pdef) 
    # Validacion de Creditos Compra de Cartera
    pdef = ProcessDefinition("Validacion de Creditos Compra de Cartera", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorValidacionCreditos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerValidacionCreditos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerValidacionCreditos");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("campoNumerador","163");
    pdef.addParameter("id_lote",3,"",1);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Marca Inicio de Cierre
    pdef = ProcessDefinition("Marca Inicio de Cierre", "topsystems.processmgr.process.EndOfDayProcess")
    pdef.addConstant("EOD","1");
    pdefs.addProcess(pdef)
    # Marca Fin de Cierre
    pdef = ProcessDefinition("Marca Fin de Cierre", "topsystems.processmgr.process.EndOfDayProcess")
    pdef.addConstant("enqueue","false");
    pdef.addConstant("EOD","2");
    pdefs.addProcess(pdef)
    #CONTROL DE SUCURSALES CERRADAS (processes.py)
    pdef = ProcessDefinition("Control previo al Cierre Diario", "topsystems.automaticprocess.control.CloseControlProcess")
    pdefs.addProcess(pdef)
    # Cambio Rubro Prestamos
    pdef = ProcessDefinition("Cambio Rubro Prestamos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCambioRubro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCambioRubro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCambioRubro");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Historico - Saldos Diarios para el Balance
    pdef = ProcessDefinition("HistoricoSaldos", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("usarSaldosRecortado","true");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaPromedioDiario","true");
    pdef.addConstant("PROCESA_INTERESES","true");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");
    pdef.addConstant("CONDICION_SALDOS"," SAL_TIPO_PRODUCTO not in (0, 1)  or (SAL_TIPO_PRODUCTO in (0, 1) and SAL_SALDO_ACTUAL <> 0.0) ");    
    pdef.addConstant("GENERA_SALDO_MENSUAL","false");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("TIPOS_DE_PRODUCTO_INTERESES","1,2,3");
    pdefs.addProcess(pdef) 
    # PROCESO: Historico Saldos Diarios con feriados
    pdef = ProcessDefinition("HistoricoSaldosConFeriados", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("usarSaldosRecortado","true");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # INTERFASES: CONJUNTOS ECONOMICOS   
    pdef = ProcessDefinition("Conjuntos Economicos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_CONJUNTOSECONOMICOS");    
    pdefs.addProcess(pdef)
    # PROCESO: Cierre 
    pdef = ProcessDefinition("ServicioCierre", "topsystems.automaticprocess.cierre.CierreSucursal")
    pdef.addConstant("PROTOCOLO","LINK");
    pdefs.addProcess(pdef)
    # Resultados por operaciones de cambio
    pdef = ProcessDefinition("Resultados por operaciones de cambio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorResOperacionesDeCambio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerResOperacionesDeCambio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerResOperacionesDeCambio");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)   
    # Revision Periodica de Capital
    pdef = ProcessDefinition("Revision Periodica de Capital", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRevisionCapital");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRevisionCapital");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerRevisionCapital");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("CAMPO_ANIOMES_REVISION_CAPITAL","11042");
    pdef.addParameter("PRODUCTO_REVISION_CAPITAL",1,"",1);
    pdef.addParameter("COD_CAMPANIA_REVISION_CAPITAL",1,"",1);
    pdefs.addProcess(pdef)
    # Cargos Movimientos Cruzados
    pdef = ProcessDefinition("Cargos Movimientos Cruzados", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","310");
    pdef.addConstant("eventList","1700");
    pdef.addConstant("jtsOidFieldNumber","8530");
    pdef.addConstant("monedaFieldNumber","8532");
    pdef.addConstant("saldoActualFieldNumber","8531");
    pdef.addConstant("nroOperacion","8637");
    pdef.addConstant("descripcion","Cargos Movimientos Cruzados");
    pdef.addConstant("reports","500");  
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("Contabilizacion Cartera Pronto", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorContabilizacionCarteraPronto");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerContabilizacionCarteraPronto");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerContabilizacionCarteraPronto");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    addMoreProcesses1(pdefs)
    addMoreProcesses2(pdefs)

    addMoreProcesses3(pdefs)
    addMoreProcesses4(pdefs)

    addMoreProcesses5(pdefs)

    return pdefs

def addMoreProcesses1(pdefs):
   #pdefs = ProcessDefinitions()
    
   # PROCESO:  Carga de Movimientos de Tarjetas por Bandeja Contable
    pdef = ProcessDefinition("Movimientos de Tarjetas por Bandeja Contable", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_BANDEJA_TARJETAS")
    pdefs.addProcess(pdef)
    
    #PROCESO:  Actualizacion de Fechas de Primer Uso y Ultimo Uso de Tarjetas de Debito
    pdef = ProcessDefinition("Actualizar Fechas de Uso de Tarjetas de Debito", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_ACTUALIZO_FECHAUSO_TJD ")
    pdefs.addProcess(pdef)
    
    # Cargo Generacion Estado de Cuenta LEGAL
    #pdef = ProcessDefinition("Cargo Estado de Cuenta LEGAL", "topsystems.automaticprocess.processmanager.WorkManager")
    #pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    #pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    #pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    #pdef.addConstant("rangoCommit","500");
    #pdef.addConstant("cantidadHilos","15");
    #pdef.addConstant("isStopable","true");
    #pdef.addConstant("applySchemes","true");
    #pdef.addConstant("isSumarizable","false");
    #pdef.addConstant("offLine","true");
    #pdef.addConstant("enqueue","false");
    #pdef.addConstant("descriptor","303");
    #pdef.addConstant("eventList","1460");
    #pdef.addConstant("jtsOidFieldNumber","7241");
    #pdef.addConstant("monedaFieldNumber","7239");
    #pdef.addConstant("saldoActualFieldNumber","29");
    #pdef.addConstant("nroOperacion","8649");
    #pdef.addConstant("descripcion","Gasto Emision Estado de Cuenta Anterior Legal");
    #pdef.addConstant("reports","500");
    #pdef.addConstant("canal","3");
    #pdef.addConstant("generaAsientoContable","true");
    #pdefs.addProcess(pdef)
    # Cargo Generacion Estado de Cuenta ESPECIAL
    pdef = ProcessDefinition("Cargo Estado de Cuenta ESPECIAL", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","3470");
    pdef.addConstant("eventList","1220");
    pdef.addConstant("jtsOidFieldNumber","34701");
    pdef.addConstant("monedaFieldNumber","34703");
    pdef.addConstant("saldoActualFieldNumber","34708");
    pdef.addConstant("nroOperacion","8664");
    pdef.addConstant("descripcion","Gasto Emision Estado de Cuenta Anterior Especial");
    pdef.addConstant("reports","500");
    pdef.addConstant("canal","3");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("readCliente","true");
    pdefs.addProcess(pdef)

    # Cargo Cuenta inmovilizada
    pdef = ProcessDefinition("Cargo cuenta inmovilizada", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","3480");
    pdef.addConstant("eventList","1230");
    pdef.addConstant("jtsOidFieldNumber","34801");
    pdef.addConstant("monedaFieldNumber","34802");
    pdef.addConstant("saldoActualFieldNumber","34803");
    pdef.addConstant("nroOperacion","8690");
    pdef.addConstant("descripcion","Cargo cuenta inmovilizada");
    pdef.addConstant("readCliente","true");
    pdef.addConstant("reports","500");
    pdef.addConstant("canal","3");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Calculo Disponible Grupo
    pdef = ProcessDefinition("ComisionPregiro", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorComisionPregiro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerComisionPregiro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","10");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CAMARA_COMPENSADORA",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Calculo Disponible Grupo
    pdef = ProcessDefinition("CalculoDisponibleGrupo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalculoDisponibleGrupo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalculoDisponibleGrupo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","10");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Acuerdos y Sobregiros Alta
    pdef = ProcessDefinition("Acuerdos y Sobregiros Alta", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAltaAcuerdosySobregiros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAltaAcuerdosySobregiros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverDraftAgreements");
    pdef.addConstant("rangoCommit","10");
    pdef.addConstant("cantidadHilos","2");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Acuerdos y Sobregiros Cancelacion y Renovacion
    pdef = ProcessDefinition("Acuerdos y Sobregiros Cancelacion y Renovacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBajaRenovAcuerdosySobregiros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBajaRenovAcuerdosySobregiros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverDraftAgreements");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabilizaContingencia","false");
    pdefs.addProcess(pdef)    
    # Cargo PreGiro
    pdef = ProcessDefinition("Cargo Pregiro Clearing", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","302");
    pdef.addConstant("eventList","8600");
    pdef.addConstant("jtsOidFieldNumber","6668");
    pdef.addConstant("monedaFieldNumber","6671");
    pdef.addConstant("saldoActualFieldNumber","7240");
    pdef.addConstant("nroOperacion","8648");
    pdef.addConstant("descripcion","Cargo Pregiro Clearing");
    pdef.addConstant("reports","500");
    pdef.addConstant("canal","3");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    # Calculo pregiro
    pdef = ProcessDefinition("ComisionPregiro", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorComisionPregiro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerComisionPregiro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","10");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CAMARA_COMPENSADORA",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Calculo Disponible Grupo
    pdef = ProcessDefinition("CalculoDisponibleGrupo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalculoDisponibleGrupo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalculoDisponibleGrupo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","10");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Bajar Saldos duplicados de Tarjetas de Credito
    pdef = ProcessDefinition("Bajar Saldos duplicados - Tarjetas de Credito", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBajarSaldoTarjetas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBajarSaldoTarjetas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerBajarSaldoTarjetas");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("rangoCommit","10");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Resetear estado rechazos preventivo por falta de fondos
    pdef = ProcessDefinition("Reintentar rechazos preventivo tarjetas de credito", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_TARJ_REINTENTO_PREV");
    pdefs.addProcess(pdef)
    # PROCESO:Revision tasas
    pdef = ProcessDefinition("Revision tasas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRevisionTasas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRevisionTasas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","20");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("fieldFactorMora","FACTOR_IC_MORA");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("fieldFactorICMora","C1709");
    pdefs.addProcess(pdef)
    # Proceso de revisión de Tasas PREPARA
    pdef = ProcessDefinition("Revision Tasas Prepara","topsystems.automaticprocess.storedprocedures.SpBasicParameters") 
    pdef.addConstant("StoreName", "SP_PA_REVISION_DE_TASAS_PREPARA");
    pdefs.addProcess(pdef)
    # Proceso de revisión de Tasas POST
    pdef = ProcessDefinition("Revision Tasas Post","topsystems.automaticprocess.storedprocedures.SpBasicParameters") 
    pdef.addConstant("StoreName", "SP_PA_REVISION_DE_TASAS_POST");
    pdefs.addProcess(pdef) 

    # PROCESO: Ajuste campos ME y MN cuentas resultados
    pdef = ProcessDefinition("Ajuste campos ME y MN cuentas resultados", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_AJU_ME_MN_RESULTADOS.proc_aju_me_mn_res") ;
    pdefs.addProcess(pdef) 
    # Complemento Pregiro
    pdef = ProcessDefinition("Complemento Pregiro", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","301");
    pdef.addConstant("eventList","7768");
    pdef.addConstant("jtsOidFieldNumber","3753");
    pdef.addConstant("monedaFieldNumber","3752");
    pdef.addConstant("saldoActualFieldNumber","3755");
    pdef.addConstant("nroOperacion","8656");
    pdef.addConstant("descripcion","Complemento Pregiro");
    pdef.addConstant("reports","500");  
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # ASIGNACION CUOTAS SEGUROS
    pdef = ProcessDefinition("Asignacion cuotas seguros", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ASIGNACION_CUOTAS_SEGUROS")
    pdef.addConstant("jts","0");
    pdef.addConstant("ParamtersPositions", "jts,C;");
    pdefs.addProcess(pdef)
    # BAJA GASTO SEGURO
    pdef = ProcessDefinition("Baja gasto seguro", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_BAJA_GASTO_SEGURO")
    pdef.addConstant("jts","0");
    pdef.addConstant("ParamtersPositions", "jts,C;");
    pdefs.addProcess(pdef)
    # CUOTAS VENCIDAS SEGUROS
    pdef = ProcessDefinition("Cuotas vencidas seguros", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_CUOTAS_VENCIDAS_SEGUROS")
    pdefs.addProcess(pdef)
    # MIGRACION GASTOS SEGURO
    pdef = ProcessDefinition("Migracion gastos seguro", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_MIGRACION_GASTOS_SEGURO")
    pdef.addConstant("ParamtersPositions", "tasa,P;");
    pdef.addParameter("tasa",2,"#00.00",1);
    pdefs.addProcess(pdef)
    # Movimientos POS Redes a Procesar
    pdef = ProcessDefinition("MovsPosProcesar", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_POS_MOVS_PROCESAR");
    pdef.addConstant("ParamtersPositions", "CodRed,C;");
    pdef.addConstant("CodRed","CEIBO CU");
    pdefs.addProcess(pdef)
    # Generacion bandeja contable con movimientos POS
    pdef = ProcessDefinition("PosBandeja", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_POS_BANDEJA_CONTABLE");
    pdef.addConstant("ParamtersPositions", "CodRed,C;Origen,C;");
    pdef.addConstant("CodRed","CEIBO CU");
    pdef.addConstant("Origen","TJD");
    pdefs.addProcess(pdef)
    # INTERFAZ: Generacion ID Proveedor
    pdef = ProcessDefinition("Genera ID Proveedor", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_GEN_ID_PROVEED");
    pdefs.addProcess(pdef)  
    # GARANTIAS COMPUTABLES
    pdef = ProcessDefinition("Borrar Garantias Computables", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_BORRADO_DEDUCCIONES_GTIAS.proc_borrar_gtias_computables")
    pdefs.addProcess(pdef)    
    # GARANTIAS NO COMPUTABLES
    pdef = ProcessDefinition("Borrar Garantias NO Computables", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_BORRADO_DEDUCCIONES_GTIAS.proc_borrar_gtias_no_comp")
    pdefs.addProcess(pdef)
    # AJUSTE DE CONTAGIO POR SUBJETIVA
    pdef = ProcessDefinition("Procesos Calificacion Resultante de la Persona", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_RESULTANTE_PERSONA.PROC_RESULTANTE_PERSONA")
    pdefs.addProcess(pdef)
    # INTERFASES: Compra Masiva de Facturas
    pdef = ProcessDefinition("Genera Lista de Documentos Masiva", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_COMPRA_MASIVA_FACTURAS");
    pdefs.addProcess(pdef)
    # INTERFASES: CARGA RCT_SUSCRIPCION_SERVICIO
    pdef = ProcessDefinition("RCT - Mapeo de suscripcion servicio BSE", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "NBC_P_CAMBIO_SUSCRIPCION");
    pdefs.addProcess(pdef)
    # Impresion reporte Control Activo y Pasivo
    pdef = ProcessDefinition("Impresion Control Activo Pasivo","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","2025");
    pdef.addParameter("Fecha",4,"",1);
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef)
    # Impresion reporte Saldos Diarios Inconsistentes
    pdef = ProcessDefinition("Reporte Saldos Diarios Inconsistentes","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","2024");
    #pdef.addParameter("Fecha",4,"",1);
    pdef.addConstant("DESTINY","7");
    pdefs.addProcess(pdef)
    # Impresion reporte Asientos Abiertos
    pdef = ProcessDefinition("Reporte Asientos Abiertos","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","3301");
    pdef.addParameter("Fecha",4,"",1);
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef)
    # Ajuste de Saldos tarjeta de acuerdo al inventario
    pdef = ProcessDefinition("Ajustes Saldo por Inventario", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_PL_AJUSTE_SALDOS")
    pdef.addConstant("ParamtersPositions", "modo,P;");
    pdef.addParameter("modo",3,"",1);
    pdefs.addProcess(pdef)
    # Automatizacion carga bandeja contabilidad tarjetas
    pdef = ProcessDefinition("Habilita Bandeja contabilidad TJC", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_PL_HABILITA_CONTABILIDAD")
    pdef.addConstant("ParamtersPositions", "modo,P;");
    pdef.addParameter("modo",2,"",1);
    pdefs.addProcess(pdef)
    # Cobro Tarjeta de credito
    pdef = ProcessDefinition("Cobro tarjeta de credito", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.PagoTJC");
    #pdef.addConstant("maximaCantidadErrores","1");
    pdefs.addProcess(pdef)
    # Proceso para compra masiva de facturas
    pdef = ProcessDefinition("Apertura Descuento masivo facturas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("grupo_operacion","6");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso para venta de cartera
    pdef = ProcessDefinition("Venta de Cartera", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("grupo_operacion","7");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # CHEQUES: Completar Libro de Cheques Devueltos
    pdef = ProcessDefinition("CLE - Completar Libro de Cheques", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_COMPLETAR_CHEQ_DEV");    
    pdefs.addProcess(pdef) 
    # Seguro por Sobregiro
    pdef = ProcessDefinition("Seguro por Sobregiro", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","298");
    pdef.addConstant("eventList","1820");
    pdef.addConstant("jtsOidFieldNumber","7480");
    pdef.addConstant("monedaFieldNumber","7481");
    pdef.addConstant("saldoActualFieldNumber","7482");
    pdef.addConstant("nroOperacion","8665");
    pdef.addConstant("descripcion","Seguro por Sobregiro");
    pdef.addConstant("reports","500");  
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Ejecucion conciliacion BANRED (TLF)
    pdef = ProcessDefinition("TP Conciliacion TLF", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_TP_TLF_SUMMARY_NEW")
    pdefs.addProcess(pdef)
    # Ejecucion Bandeja conciliacion BANRED (TLF)
    pdef = ProcessDefinition("Bandeja Conciliacion TLF", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_PA_BANDEJA_CONCILIACION_TLF")
    pdefs.addProcess(pdef)
    # Categorizacion de Prestamos Garantias
    pdef = ProcessDefinition("Categorizacion Prestamos por Garantia", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCategorizacionDeCartera");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCategorizacionDeCartera");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCategorizacionDeCartera");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");    
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("criterioVtoFeriado","M");
    pdef.addConstant("estadoAtrasoAProcesar","V");
    pdef.addConstant("usaDobleCronograma","false");
    pdef.addConstant("consideraMoneda","false");
    pdef.addConstant("query","query.vo_clientesCategorizar"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Cargos Tarjetas Debito Exceso Movimientos Banred
    pdef = ProcessDefinition("Cargos Exceso Mov Banred", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","304");
    pdef.addConstant("eventList","6100");
    pdef.addConstant("jtsOidFieldNumber","1676");
    pdef.addConstant("monedaFieldNumber","1700");
    pdef.addConstant("saldoActualFieldNumber","1697");
    pdef.addConstant("nroOperacion","8647");
    pdef.addConstant("descripcion","Cargos Exceso Mov Banred");
    pdef.addConstant("reports","500");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso de Calificacion Objetiva
    pdef = ProcessDefinition("Calificacion Objetiva","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionObjetiva");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionObjetiva");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Historico - Saldos Diarios para el Balance Extendido recortado
    pdef = ProcessDefinition("HistSaldosExtMod", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("usarSaldosRecortado","true");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");
    pdef.addConstant("CONDICION_SALDOS"," SAL_MARCA_ACTUALIZAR = \"1\" ");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Marca saldos actualizados en el extendido
    pdef = ProcessDefinition("Marca Saldos Modificados EXT", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_ACTUALIZAR_RES_SALDOS")
    pdefs.addProcess(pdef)  
    # PROCESO: LOTES ALTA MASIVA X CARTERA 
    pdef = ProcessDefinition("Lotes Alta Masiva x Cartera", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "SP_ALTA_MASIVA_COMPRA_CARTERA");
    pdef.addConstant("ParamtersPositions", "Lote,P;");
    pdef.addParameter("Lote",1,"",1);
    pdefs.addProcess(pdef)
    # Calificacion MOCASIST de personas en Garantias que no pertenecen a un Cliente.
    pdef = ProcessDefinition("Calificacion MOCASIST de personas en Garantias", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_CALIFICACION_MOCASIST.PROC_CALIFICACION_MOCASIST")
    pdefs.addProcess(pdef)
    # CLI- Asignacion masiva de Paquetes a Clientes (Ope 177)
    pdef = ProcessDefinition("Asignacion Masiva de Paquetes a Clientes", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_CLI_ASIGNACION_MASIVA_PAQUETES")
    pdef.addConstant("ParamtersPositions", "Paquete_anterior,P;Paquete_nuevo,P;Concat_clientes,P;");
    pdef.addParameter("Paquete_anterior",1,"",1);
    pdef.addParameter("Paquete_nuevo",1,"",1);
    pdef.addParameter("Concat_clientes",3,"",1);
    pdefs.addProcess(pdef)
    # Ajuste columnas Resultados de Saldos para asientos que vienen del Extendido
    pdef = ProcessDefinition("Ajuste Saldos Columnas Resultados", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_PA_AJUSTE_PG_BCONT")
    pdef.addConstant("ParamtersPositions", "FechaAsiento,P;AsientoDesde,P;AsientoHasta,P;SucursalAsiento,P");
    pdef.addParameter("FechaAsiento",4,"",1);
    pdef.addParameter("AsientoDesde",1,"",1);
    pdef.addParameter("AsientoHasta",1,"",1);
    pdef.addParameter("SucursalAsiento",1,"",1);
    pdefs.addProcess(pdef)
    # Recepcion archivo morosos alimentarios BCU
    pdef = ProcessDefinition("Morosos Alimentarios BCU", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_ALTA_MOROSOSALIMEN")
    pdefs.addProcess(pdef)
    # Modificacion fecha_envio_compensacion cheques BANRED en feriados
    pdef = ProcessDefinition("Cheques ATM feriados", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_PA_CHE_BNR_FERIADO")
    pdefs.addProcess(pdef)	
    # Cambio fecha de proceso
    pdef = ProcessDefinition("Cambio Fecha Demo","topsystems.automaticprocess.sucursales.CambioFechaSucursal")
    pdef.addConstant("enqueue","false");
    pdef.addConstant("BRANCH","1");
    pdefs.addProcess(pdef) 
    #================================================================
    # PROCESO: Caja y Tesoreria
    pdef = ProcessDefinition("Carga Saldos Caja Historico", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_SALDOSCAJA_HISTORICO")
    pdefs.addProcess(pdef)
    # PROCESO: Historico SALDOS ATM
    pdef = ProcessDefinition("Carga Saldos ATM Historico", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_SALDOSATM_HISTORICO")
    pdefs.addProcess(pdef)
    # PAGO SUELDO A DOMICILIO
    pdef = ProcessDefinition("Pago sueldo a domicilio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.PagoADomicilio");
    pdefs.addProcess(pdef)
    #================================================================
    # PROCESO: Extorno Contabilizacion Categorizacion de Cartera
    pdef = ProcessDefinition("EXTORNO CONTABLE CATEGORIZACION CARTERA","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("marcaAjuste","0");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoCategorizacionCartera");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("UTILIZA_CAMBIO_DEL_DIA","true");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)
    
    # Ajuste por inflacion

    # PROCESO: Carga de la tabla de resumen del TLF que sirve como input para la conciliacion.
    pdef = ProcessDefinition("Resumen TLF para conciliacion de TopazPos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_TP_TLF_SUMMARY");
    pdefs.addProcess(pdef)
    # Proceso ARCHIVO TLF LINK
    pdef = ProcessDefinition("Archivo TLF - LINK", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TLF_POS.kjb")
    pdef.addParameter("archivo",3,"Nombre del Archivo",1)
    pdefs.addProcess(pdef)
    # PROCESO: Control Saldo al Corte
    pdef = ProcessDefinition("Control Saldo Al Corte", "topsystems.reports.reportesbasicos.ControlSaldoAlCorte")
    pdef.addConstant("QUERY_NAME","query.vo_ControlSaldoAlCorteQuery");
    pdef.addConstant("FILE_NAME","ControlSaldoAlCorte");
    pdef.addConstant("OUPUT_TYPE","1");
    pdefs.addProcess(pdef)
    # PROCESO: Control por moneda
    pdef = ProcessDefinition("Control por Moneda", "topsystems.reports.reportesbasicos.ControlPorMoneda")
    pdef.addConstant("QUERY_NAME","query.vo_ControlPorMonedaQuery");
    pdef.addConstant("FILE_NAME","ControlPorMoneda");
    pdef.addConstant("OUPUT_TYPE","1");
    pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    # PROCESO: Mayor por rubro
    pdef = ProcessDefinition("Reporte MayorXRubro", "topsystems.reports.reportesbasicos.MayorXRubro")
    pdef.addConstant("QUERY_NAME","query.vo_MayorXRubro");
    pdef.addConstant("OUPUT_TYPE","1");
    pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    # PROCESO: Inventario de saldos
    pdef = ProcessDefinition("Inventario de Saldos", "topsystems.reports.reportesbasicos.InventarioDeSaldos")
    pdef.addConstant("QUERY_NAME","query.vo_InventarioDeSaldosQuery");
    pdef.addConstant("FILE_NAME","InventarioDeSaldos");
    pdef.addConstant("OUPUT_TYPE","1");
    pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    # PROCESO: Control Saldo al Corte
    pdef = ProcessDefinition("Control Saldo Al Corte", "topsystems.reports.reportesbasicos.ControlSaldoAlCorte")
    pdef.addConstant("QUERY_NAME","query.vo_ControlSaldoAlCorteQuery");
    pdef.addConstant("FILE_NAME","ControlSaldoAlCorte");
    pdef.addConstant("OUPUT_TYPE","1");
    pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    # PROCESO: Control por asiento
    pdef = ProcessDefinition("Control por Asiento", "topsystems.reports.reportesbasicos.ControlPorAsiento")
    pdef.addConstant("QUERY_NAME","query.vo_ControlPorAsientoQuery");
    pdef.addConstant("FILE_NAME","ControlPorAsiento");
    pdef.addConstant("OUTPUT_PATH","E:\\JasperReport\\reportes\\out\\");
    pdef.addConstant("OUPUT_TYPE","1");
    pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    # Pago de creditos por nomina
    pdef = ProcessDefinition("Pago creditos por Nomina", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPagoPorNomina");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPagoPorNomina");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerImportacionPagoNomina");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Reservas Sobre Saldos
    pdef = ProcessDefinition("Reservas Sobre Saldos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorReservaSaldos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerReservaSaldos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerReservaSaldos");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","30");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");	
    pdef.addConstant("QUERY_NAME","query.QueryReservaSobreSaldos");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("Devengamiento Contabilizacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorContabilizacionDevengamiento");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerContabilizacionDevengamiento");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerContabilizacionDevengamiento");
    pdef.addConstant("MetodoContabilizacion","Extorno");
    pdef.addConstant("rangoCommit","20000");
    pdef.addConstant("cantidadHilos","30");
    pdef.addConstant("rangoSumarizaInstrGeneradasPorEsquema","2000");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    # PROCESO: Depuracion de Historia Vista
    pdef = ProcessDefinition("Depuracion de Historia Vista", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_HISTORICO.PROC_HIS_VISTA")
    pdef.addConstant("ParamtersPositions", "rangoCommit,C;modo,P;");
    pdef.addConstant("rangoCommit","500");
    pdef.addParameter("modo",3,"",1);
    pdefs.addProcess(pdef)
    # PROCESO: Depuracion de Historia Plazo
    pdef = ProcessDefinition("Depuracion de Historia Plazo", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_HISTORICO.PROC_HIS_PLAZO")
    pdef.addConstant("ParamtersPositions", "rangoCommit,C;modo,P;");
    pdef.addConstant("rangoCommit","500");
    pdef.addParameter("modo",3,"",1);
    pdefs.addProcess(pdef)
    # PROCESO: Depuracion de Movimientos Contables
    pdef = ProcessDefinition("Depuracion de Movimientos Contables", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_HISTORICO.PROC_HIS_MOV_CONTABLES")
    pdef.addConstant("ParamtersPositions", "rangoCommit,C;modo,P;");
    pdef.addConstant("rangoCommit","500");
    pdef.addParameter("modo",3,"",1);
    pdefs.addProcess(pdef)
    # PROCESO: Depuracion de Asientos
    pdef = ProcessDefinition("Depuracion de Asientos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_HISTORICO.PROC_ASIENTOS")
    pdef.addConstant("ParamtersPositions", "rangoCommit,C;modo,P;");
    pdef.addConstant("rangoCommit","500");
    pdef.addParameter("modo",3,"",1);
    pdefs.addProcess(pdef)
    # PROCESO: Depuracion de Movimientos
    pdef = ProcessDefinition("Depuracion de Movimientos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_HISTORICO.PROC_MOVIMIENTOS")
    pdef.addConstant("ParamtersPositions", "rangoCommit,C;modo,P;");
    pdef.addConstant("rangoCommit","500");
    pdef.addParameter("modo",1,"",1);
    pdefs.addProcess(pdef)
    # PROCESO: Actualizar el equivalente en moneda nacional de Saldos	
    pdef = ProcessDefinition("Saldos actualizar equivalente MN", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorSaldosActualizarEqMN");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerSaldosActualizarEqMN");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Cancelacion de Saldos
    pdef = ProcessDefinition("Cancelacion de Saldos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCancelacionSaldos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCancelacionSaldos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCancelacionSaldos");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Saldos Diarios Contabilidad
    pdef = ProcessDefinition("SaldosDiariosContabilidad", "topsystems.automaticprocess.historico.saldosdiarios.LoadSDContabilidadProcess");
    pdef.addConstant("deleteSaldosDiariosContabilidad","delete from con_saldos_diarios where fecha = ?");
    pdef.addConstant("insertSaldosDiariosContabilidad","insert into con_saldos_diarios (FECHA,TZ_LOCK,RUBRO,SUCURSAL,MONEDA,CENTROCOSTO,EMPRESA,TIPOLIBRO,SALDO_AL_CORTE,SALDO_AL_CORTE_MN,SALDO_AJUSTADO,SALDO_AJUSTADO_MN,SALDO_FECHA_VALOR,SALDO_FECHA_VALOR_MN,DEBITOS,CREDITOS,DEBITOS_MN,CREDITOS_MN,DEBITOS_FECHAVALOR,DEBITOS_FECHAVALOR_MN,DEBITOS_AJUSTE,DEBITOS_AJUSTE_MN,CREDITOS_FECHAVALOR,CREDITOS_FECHAVALOR_MN,CREDITOS_AJUSTE,CREDITOS_AJUSTE_MN) select ? AS FECHA,0 as Tz_Lock,RUBRO,SUCURSAL,MONEDA,CENTROCOSTO,EMPRESA,TIPOLIBRO,SUM(SALDO_AL_CORTE) AS SALDO_AL_CORTE,SUM(SALDO_AL_CORTE_MN) AS SALDO_AL_CORTE_MN,SUM(SALDO_AJUSTADO) AS SALDO_AJUSTADO,SUM(SAL_AJUSTADO_MN) AS SAL_AJUSTADO_MN,SUM(SALDO_FECHA_VALOR) AS SALDO_FECHA_VALOR,SUM(SALDO_FECHA_VALOR_MN) AS SALDO_FECHA_VALOR_MN,SUM(DEBITOS) AS DEBITOS,SUM(CREDITOS) AS CREDITOS,SUM(DEBITOS_MN) AS DEBITOS_MN,SUM(CREDITOS_MN) AS CREDITOS_MN,0 AS DEBITOS_FECHAVALOR,0 AS DEBITOS_FECHAVALOR_MN,0 AS DEBITOS_AJUSTE,0 AS DEBITOS_AJUSTE_MN,0 AS CREDITOS_FECHAVALOR,0 AS CREDITOS_FECHAVALOR_MN,0 AS CREDITOS_AJUSTE,0 AS CREDITOS_AJUSTE_MN from ((select SUCURSAL_CUENTA SUCURSAL,MONEDA,1 as TIPOLIBRO,'0' as CentroCosto,0 as SALDO_AL_CORTE,0 as SALDO_AL_CORTE_MN,0 as SALDO_AJUSTADO,0 as SAL_AJUSTADO_MN,0 as SALDO_FECHA_VALOR,0 as SALDO_FECHA_VALOR_MN,SUM(CASE WHEN (M.DEBITOCREDITO = 'D') THEN ROUND(M.CAPITALREALIZADO, 2) ELSE 0 END) as DEBITOS,SUM(CASE WHEN (M.DEBITOCREDITO = 'C') THEN ROUND(M.CAPITALREALIZADO, 2) ELSE 0 END) as CREDITOS,SUM(CASE WHEN (M.DEBITOCREDITO = 'D') THEN ROUND(M.EQUIVALENTEMN, 2) ELSE 0 END) as DEBITOS_MN,SUM(CASE WHEN (M.DEBITOCREDITO = 'C') THEN ROUND(M.EQUIVALENTEMN, 2) ELSE 0 END) as CREDITOS_MN,RUBROCONTABLE RUBRO,0 TZ_LOCK,0 AS EMPRESA FROM MOVIMIENTOS_CONTABLES M INNER JOIN ASIENTOS A ON A.FECHAPROCESO = ? AND M.FECHAPROCESO = A.FECHAPROCESO AND M.SUCURSAL = A.SUCURSAL AND M.ASIENTO = A.ASIENTO AND A.ESTADO = 77 GROUP BY M.RUBROCONTABLE,M.SUCURSAL_CUENTA,M.MONEDA,M.CENTROCOSTO) UNION (select SUCURSAL,MONEDA,1 as TIPOLIBRO,'0' as CentroCosto,sum(C1604) as SALDO_AL_CORTE,sum(C3958) as SALDO_AL_CORTE_MN,sum(C1604) as SALDO_AJUSTADO,sum(C3958) as SAL_AJUSTADO_MN,sum(C1604) as SALDO_FECHA_VALOR,sum(C3958) as SALDO_FECHA_VALOR_MN,0 DEBITOS,0 CREDITOS,0 DEBITOS_MN,0 CREDITOS_MN,C1730 as RUBRO,0 TZ_LOCK,0 AS EMPRESA FROM SALDOS S WHERE S.TZ_LOCK = 0 GROUP BY C1730,SUCURSAL,MONEDA,EMPRESA)) D GROUP BY RUBRO,SUCURSAL,MONEDA,CENTROCOSTO,EMPRESA,TIPOLIBRO");
    pdefs.addProcess(pdef) 
    # PROCESO: Actualizar Saldos Diarios Contabilidad con movimientos fecha valor
    pdef = ProcessDefinition("SaldosDiariosContabilidad con movimientos Fecha Valor", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorSDContabilidadActualizar");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerSDContabilidadActualizar");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerSaldosDyMReaplicacionMov");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("corregirSaldoAjustadoMN","false");
    pdef.addConstant("corregirSaldoAjustadoME","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("GENERA_FERIADOS","true");
    pdefs.addProcess(pdef)
    # PROCESO: DEVENGAMIENTO ETAPA 1
    # CALCULO Y GENERACION DE HISTORICO - ETAPA 1
    pdef = ProcessDefinition("Devengamiento Calculo y Actualizacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalculoDevengamiento");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalculoDevengamiento");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalculoDevengamiento");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","30");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("Mueve a Suspenso Intereses Devengados en Vigente","False");
    pdef.addConstant("Mueve a Vencidos Intereses Devengados en Vigente","False");
    pdef.addConstant("Mueve a Suspenso Mora Devengada en Vigente","False");
    pdef.addConstant("Mueve a Vencidos Mora Devengada en Vigente","False");
    pdef.addConstant("Contabiliza Devengado No Pagado","True");
    pdef.addConstant("MetodoContabilizacion","Extorno");
    pdef.addConstant("Pasa a Suspenso en Feriado","False");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("Pasa a Vencido en Feriado","True");
    pdef.addConstant("Cierre extendido","True");
    pdefs.addProcess(pdef)
    #PROCESO: Baja de asientos masiva
    pdef = ProcessDefinition("Baja de asientos masiva", "topsystems.automaticprocess.bajamasivaasientos.BajaMasivaAsientosProcess")
    pdefs.addProcess(pdef)
    # PROCESO: Reporte Balancete 
    pdef = ProcessDefinition("Balancete", "topsystems.reports.reportesbasicos.BalanceteContable")
    pdef.addConstant("QUERY_NAME","query.Balancete");
    pdef.addConstant("FILE_NAME","BalanceteContable");
    pdef.addConstant("OUPUT_TYPE","1");
    pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    # Ajustes Inter Sucursal
    pdef = ProcessDefinition("Ajustes Inter Sucursal", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAjustesInterSucursal");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAjustesInterSucursal");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyCodigoTransaccion","true"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    # Extorno Ajustes Inter Sucursal
    pdef = ProcessDefinition("Extorno Ajustes Inter Sucursal","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("marcaAjuste","0");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoAjustesInterSucursal");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdef.addConstant("UTILIZA_CAMBIO_DEL_DIA","true");
    pdefs.addProcess(pdef)

    # Integracion de Remesas con Giros
    pdef = ProcessDefinition("Integracion de Remesas con Giros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDIntegracionRemesasGiro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWIntegracionRemesasGiro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("NUMERADOR_ORDEN_REMESA","8065");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Integracion de Remesas con Anulaciones de Giro Contabilizacion
    pdef = ProcessDefinition("Integracion de Remesas Anulacion Giros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDIntegracionAnulacionGiros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWIntegracionAnulacionGiros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","2");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Pago Remesas
    pdef = ProcessDefinition("Pago Remesas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDPagoRemesas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWPagoRemesas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Reporte Movimiento Transportadora
    pdef = ProcessDefinition("Reporte Movimiento Transportadora", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.Reporte_Movimiento_Transportadora");
    pdefs.addProcess(pdef)
    # Reporte Movimiento Tesorero
    pdef = ProcessDefinition("Reporte Movimiento Tesorero", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.Reporte_Movimiento_Tesorero");
    pdefs.addProcess(pdef)
    # Anulacion de Creditos Automaticos por Giros Vencidos.
    pdef = ProcessDefinition("Anulacion de CA por Giros Vencidos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDAnulacionRemesasGiro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWAnulacionRemesasGiro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("Generacion de vales por sobregiros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorValesPorSobregiros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerValesPorSobregiros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerValesPorSobregiros");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("SUBC1_C1040","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Devengamiento Saldo Proporcional al Plazo
    pdef = ProcessDefinition("Devengamiento Saldo Proporcional al Plazo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDevengaProporcionalPlazo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDevengaProporcionalPlazo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Centro de Costos
    pdef = ProcessDefinition("Centro de Costos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCentroCostos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCentroCostos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","40");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    # pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",1);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso de Cambio de Estado de canal X (conciliando)
    pdef = ProcessDefinition("Cambio de Estado canal X", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCambioEstadoCanal");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCambioEstadoCanal"); 
    pdef.addConstant("nombre","X");
    pdef.addConstant("estado","S");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Proceso de Cambio de Estado de canal X (abierto)
    pdef = ProcessDefinition("Cambio de Estado canal X", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCambioEstadoCanal");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCambioEstadoCanal");
    pdef.addConstant("nombre","X");    
    pdef.addConstant("estado","A");
    pdef.addConstant("generaAsientoContable","true");    
    pdefs.addProcess(pdef)
    # ACTIVO FIJO: Cierre Ejercicio
    pdef = ProcessDefinition("Activo Fijo - Cierre Ejercicio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCierreEjercicio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCierreEjercicio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCierreEjercicio");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Ajuste inter sucursal con fecha valor
    pdef = ProcessDefinition("Ajuste Intersucursal Con Fecha Valor", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAjustesInterSucursalConFechaValor");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAjustesInterSucursalConFechaValor");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Cambio de Producto
    pdef = ProcessDefinition("Cambio de Producto","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCambioProductoRubro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCambioProducto");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("MODALIDAD","P");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("changeFrozenDate","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Actualizacion saldo con fecha valor pago saldos diarios.
    #pdef = ProcessDefinition("Actualizacion Fecha Con Saldo Valor Pago", "topsystems.automaticprocess.interesesvistasaldoopromedio.ActualizacionSaldoFechaValorPago")
    #pdef.addConstant("tipoProductoVista","2,3");
    #pdefs.addProcess(pdef)
    # Intereses Vista Saldo o Premedio Pago

    #  Cambio Rubro Forzado
    pdef = ProcessDefinition("Cambio Rubro Forzado", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCambioRubroForzado");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCambioRubroForzado");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("conceptoEstadoAtraso","696");
    pdef.addConstant("conceptoEstado","697");
    pdefs.addProcess(pdef)
    # Proceso Actualizacion de cuotas prestamos
    pdef = ProcessDefinition("Actualizacion de cuotas prestamos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorActualizacionDiasAtraso");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerActualizacionDiasAtraso");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: EXTORNO CON HILOS
    pdef = ProcessDefinition("Extorno Con Hilos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoXXXXXX");
    pdef.addConstant("queryFechaValor","query.vo_extornoYYYYYY");
    pdef.addConstant("condicion","CNNNN=nn");
    pdefs.addProcess(pdef)
    
    
    return
def addMoreProcesses2(pdefs):
    # Generacion estructura balance
    pdef = ProcessDefinition("Generacion estructura balance", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBalanceEstructura");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBalanceEstructura");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ID_BCE",1,"",1);
    pdef.addParameter("Borra_Estructura",1,"",0);
    pdef.addParameter("Tipo_Balance",3,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdef.addParameter("ID_BCE_NIVEL",1,"",1);
    pdefs.addProcess(pdef)
    #Cambio Estado Prestamo
    pdef = ProcessDefinition("Cambio Estado Prestamo","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCambioEstadoPrestamo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCambioEstadoPrestamo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: CatalogByNumberProcess
    pdef = ProcessDefinition("Cataloga por Numero", "topsystems.toolsserver.reportsadministrator.process.CatalogByNumberProcess")
    pdef.addParameter("NRO_CATALOGO",1);
    pdefs.addProcess(pdef)
    # PROCESO: Procesamiento de la bandeja de entrada
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable TCH", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR_CTE","TCH");
    pdef.addConstant("productosAplicaOffLine","273;4101;4102;4103;4104;4105;4106;4107;4108;4109;4201;4203;4204;4205;4206;4207;4208;4209;4301;4302;4303;4304;4305;4306;4307;4308;4309");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Procesamiento de la bandeja de entrada
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable BNR", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR_CTE","BNR");
    pdef.addConstant("productosAplicaOffLine","273;4101;4102;4103;4104;4105;4106;4107;4108;4109;4201;4203;4204;4205;4206;4207;4208;4209;4301;4302;4303;4304;4305;4306;4307;4308;4309");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Procesamiento de la bandeja de entrada
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable CNT", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR_CTE","CNT");
    pdef.addConstant("productosAplicaOffLine","273;4101;4102;4103;4104;4105;4106;4107;4108;4109;4201;4203;4204;4205;4206;4207;4208;4209;4301;4302;4303;4304;4305;4306;4307;4308;4309");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Procesamiento de la bandeja de entrada
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable TJD", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR_CTE","TJD");
    pdef.addConstant("productosAplicaOffLine","273;4101;4102;4103;4104;4105;4106;4107;4108;4109;4201;4203;4204;4205;4206;4207;4208;4209;4301;4302;4303;4304;4305;4306;4307;4308;4309");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","false"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso para pago de obligaciones rurales
    pdef = ProcessDefinition("Pago Obligaciones Rurales Vendedores", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("grupo_operacion","2");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Proceso para tomar pagos de prestamos efectuados por buzon
    pdef = ProcessDefinition("Pago Prestamos por buzon", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("grupo_operacion","4");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Balances Diarios Cuatro Columnas
    #pdef = ProcessDefinition("Balances Diarios Cuatro Columnas", "topsystems.automaticprocess.balance.GenerarBalanceMonedaConvertida")
    #pdef.addParameter("Fecha",4,"dd/MM/yyyy",0);
    #pdef.addParameter("Nro. Balance",1,"",0);
    #pdef.addConstant("generacion","D");
    #pdef.addConstant("printBalance","true");
    #pdefs.addProcess(pdef)
    #  Calificacion Subjetiva Contagio
    pdef = ProcessDefinition("Calificacion Subjetiva Contagio", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_ACTUALIZACION_CONTAGIO.PROC_CALIF_SUBJ_CONTAGIO")
    pdefs.addProcess(pdef)  
    # Cierre Extendido 
    pdef = ProcessDefinition("Cierre Extendido", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_CIERRE_EXTENDIDO$PROC_PASAJE_CIERRE_EXTENDIDO")
    pdefs.addProcess(pdef)

    # Proceso de reaplicacion de movimienos en cierre extendido
    pdef = ProcessDefinition("Reaplicacion Cierre Extendido", "topsystems.automaticprocess.newreaplicacion.ExtendedRepplayProcess")
    pdefs.addProcess(pdef)
    # Saldos D y M Reaplicacion de movimientos_Procesa todos
    # Saldos D y M Reaplicacion de movimientos_Procesa todos
    pdef = ProcessDefinition("Saldos D y M Reaplicacion de movimientos_Procesa todos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorSaldosDyMReaplicacionMov");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerSaldosDyMReaplicacionMov");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerSaldosDyMReaplicacionMov");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("tipoproductosvista","2,3");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("corregirSaldoAjustadoMN","false");
    pdef.addConstant("GENERA_SALDO_MENSUAL","false");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","false");
    pdef.addConstant("PROCESA_SOLO_FECHA_PROCESO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("generaPromedioDiario","true");
    pdefs.addProcess(pdef)

    # Proceso para cancelar remanentes de capital en creditos
    pdef = ProcessDefinition("Cancelacion Remanente Capital", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("grupo_operacion","5");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Conciliacion pazPos vs. TLF Banred
    pdef = ProcessDefinition("Conciliacion TopazPos - TLF LINK", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorConciliacionTransacciones");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerConciliacionTransacciones");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","20");
    pdef.addConstant("isStopable","true");
    pdef.addParameter("FECHA_CAPTURA",4,"dd/MM/yyyy",1); # 
    pdef.addParameter("CORRECCION_AUTOMATICA",3,"true/false",1); #
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Se encarga de verificar si hay algun registro en la tabla TJD_TLF_SUMMARY y no en TOPAZPOS.
    pdef = ProcessDefinition("TLF Transacciones No Conciliadas", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_TLF_MOVIMIENTOS_NO_CONCILIADOS");
    pdefs.addProcess(pdef)
    # Extendido: Correccion Categoria Objetiva
    pdef = ProcessDefinition("Corrige Calificacion Objetiva", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PG_CORRIGE_CATEGOBJ");
    pdefs.addProcess(pdef)
    # Extendido: Correccion Categoria Mocasist
    pdef = ProcessDefinition("Corrige Calificacion MOCASIST", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PG_CORRIGE_CATEGMOCA");
    pdefs.addProcess(pdef)
    # Cargo Tasa de Control y CJPB
    pdef = ProcessDefinition("Cargo Tasa de Control y CJPB", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","318");
    pdef.addConstant("eventList","2900");
    pdef.addConstant("jtsOidFieldNumber","8352");
    pdef.addConstant("monedaFieldNumber","8354");
    pdef.addConstant("saldoActualFieldNumber","8351");
    pdef.addConstant("nroOperacion","8654");
    pdef.addConstant("descripcion","Impuesto Marzo-Abril-Mayo-Junio 2010");
    pdef.addConstant("reports","500");  
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Extornar los saldos de Contingencia
    pdef = ProcessDefinition("Extorna Saldos Contingencias", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_EXTORNO_SALDOS_CONTING");
    pdefs.addProcess(pdef)
    # Cargar bandeja de Contingencia
    pdef = ProcessDefinition("Cargar Saldos Contingencias", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_CARGO_SALDOS_CONTING");
    pdefs.addProcess(pdef)
    #Numeracion de Facturas
    # COMENTADO PAOLO MIGRACION 5_5
    #pdef = ProcessDefinition("Numeracion de Facturas", "topsystems.numeradoresfactura.process.NumeradoresFacturaProcess")
    #pdefs.addProcess(pdef)
    # PROCESO: Diferencia de Balance   
    pdef = ProcessDefinition("Diferencia de Balance", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_BALANCE");    
    pdefs.addProcess(pdef)
    # PROCESO: Historico - Saldos Diarios sin mensuales para el Balance 
    pdef = ProcessDefinition("HistoricoSaldosDiariosSinMensuales", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","30");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("usarSaldosRecortado","true");    
    pdef.addConstant("generaPromedioDiario","true");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");   
    pdef.addConstant("CONDICION_SALDOS","SAL_PRODUCTO_SALDOS not in (72001, 72002, 72003, 72008) and (SAL_SALDO_ACTUAL <> 0.0 or SAL_TIPO_PRODUCTO not in (4,5,6))");
    pdef.addConstant("GENERA_SALDO_MENSUAL","false");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Historico - Saldos Diarios sin promedio para el Balance 
    pdef = ProcessDefinition("HistoricoSaldosDiariosSinPromedio", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("usarSaldosRecortado","true");    
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");   
    pdef.addConstant("GENERA_SALDO_MENSUAL","true");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","false"); 
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)         
    # PROCESO: Historico - Calculo de Saldos diarios (Solo) para Intereses Vista
    pdef = ProcessDefinition("HistoricoSaldosDiariosSolo e Intereses", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("usarSaldosRecortado","true");    
    pdef.addConstant("PROCESA_INTERESES","true");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");
    pdef.addConstant("CONDICION_SALDOS","SAL_TIPO_PRODUCTO in (2, 3)");
    pdef.addConstant("GENERA_SALDO_MENSUAL","true");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)         
    # PROCESO: Historico - Calculo de Saldos diarios y mensuales sin promedio para Intereses Vista
    pdef = ProcessDefinition("HistoricoSaldos e Intereses sin promedio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorHistoricoCliente");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerHistoricoCliente");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","30");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("usarSaldosRecortado","true");    
    pdef.addConstant("PROCESA_INTERESES","true");
    pdef.addConstant("PROCESA_FECHA_PROCESO","false");
    pdef.addConstant("CONDICION_SALDOS","SAL_TIPO_PRODUCTO in (2, 3)");
    pdef.addConstant("GENERA_SALDO_MENSUAL","true");
    pdef.addConstant("GENERA_PROMEDIO_MENSUAL","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("TIPOS_DE_PRODUCTO_INTERESES","1,2,3");
    pdefs.addProcess(pdef) 
    # PROCESO: Generacion de promedios mensuales sobre saldos diarios
    pdef = ProcessDefinition("Promedio Mensual SD", "topsystems.automaticprocess.historicocliente.calculodiario.SpPromediosMensuales")
    pdef.addConstant("APERTURA_CIERRE", "A");
    pdefs.addProcess(pdef)
    # PROCESO: Actualizar nivel de riesgo de clientes
    pdef = ProcessDefinition("Actualizar nivel de riesgo de clientes", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")    
    pdef.addConstant("StoreName", "SP_ITF_NIVELRIESGO")
    pdefs.addProcess(pdef)       
    # PROCESO: Generacion de facturas intereses vista
    pdef = ProcessDefinition("Generacion de facturas intereses vista", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")    
    pdef.addConstant("StoreName", "SP_GEN_FACTURAS_INT_VISTA")
    pdefs.addProcess(pdef)   
    # PROCESO: Generacion de facturas intereses prestamos
    pdef = ProcessDefinition("Generacion de facturas intereses prestamos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_FACTURAS.PROC_GENERACION_FACTURAS")
    pdef.addConstant("ParamtersPositions", "rangoCommit,C;fecha_inicio,P;fecha_fin,P;");
    pdef.addConstant("rangoCommit","5000");
    pdef.addParameter("fecha_inicio",4,"",1);
    pdef.addParameter("fecha_fin",4,"",1);
    pdefs.addProcess(pdef)
    # PROCESO: Generacion de facturas chequeras
    pdef = ProcessDefinition("Generacion de facturas chequeras", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")    
    pdef.addConstant("StoreName", "SP_GEN_FACTURAS_CHEQUERAS")
    pdefs.addProcess(pdef)   
    # PROCESO: Inicializacion de la calificacion objetiva
    pdef = ProcessDefinition("Calificacion Objetiva - Inicializacion", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_CALIF_OBJ_INI.proc_ini_calif_objetiva")
    pdefs.addProcess(pdef)
    # PROCESO: Altas antecedentes negativos
    pdef = ProcessDefinition("Altas antecedentes negativos", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")    
    pdef.addConstant("StoreName", "SP_ITF_ANTECEDENTESNEG")
    pdefs.addProcess(pdef)     
    # PROCESO: Balances Mensuales Reaplicacion
    pdef = ProcessDefinition("Reaplicacion de Balances", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDGenerarBalanceReaplicacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWGenerarBalanceReaplicacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("balancesaReaplicar","1,D;");
    pdefs.addProcess(pdef)
    
    # PROCESO - Extorno Asiento Multiples Pagos
    pdef = ProcessDefinition("ExtornoMultiplesPagos", "topsystems.automaticprocess.extorno.ExtornProcessMultiplesPagos")
    pdef.addParameter("CANTIDAD_PAGOS",1,"",1);
    pdef.addParameter("JTS_OID_SALDO",1,"",1);
    pdef.addParameter("JTS_OID_HISTORIA",1,"",1);
    pdef.addParameter("esAjusteParam",3,"",0);
    pdefs.addProcess(pdef)
    
    #PROCESO DE ANALISIS DE OPERACIONES PLAZO
    pdef = ProcessDefinition("Analisis de Operaciones Plazo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAnalizadorOperacionesPlazo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAnalizadorOperacionesPlazo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("JTS_OID",1,"",1);
    pdef.addParameter("HP_JTS_OID",1,"",0);
    pdefs.addProcess(pdef)
    
    # Importacion pago por nomina
    pdef = ProcessDefinition("Importacion Pago por Nomina", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorImportacionPagoNomina");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerImportacionPagoNomina");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerImportacionPagoNomina");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    ####################################################
    ################  ACTIVO FIJO  #####################
    ####################################################

    # ACTIVO FIJO: Revaluacion
    pdef = ProcessDefinition("Activo Fijo - Revaluacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRevaluacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRevaluacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerRevaluacion");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)
    
    # ACTIVO FIJO: Amortizacion
    pdef = ProcessDefinition("Activo Fijo - Amortizacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAmortizacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAmortizacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerAmortizacion");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)
   
    # ACTIVO FIJO: Fin Amortizacion
    pdef = ProcessDefinition("Activo Fijo - Fin Amortizacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorTotalmenteAmortizado");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerTotalmenteAmortizado");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerTotalmenteAmortizado");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)
    #PROCESO: Baja de asientos al cierre.
    pdef = ProcessDefinition("Baja de asientos al cierre centralizado","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDeletePostings");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDeletePostings");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Proceso Fin de Asientos Diferidos
    pdef = ProcessDefinition("Fin de Asientos Diferidos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorFinishDeferredPostings");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerFinishDeferredPostings");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","50");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    #pdef.addParameter("FECHA_PROCESO",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    
    # Devengamiento Cargos de Prestamo
    pdef = ProcessDefinition("Devengamiento Saldo Cargos Prestamo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDevengadoCargosPrestamo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDevengadoCargosPrestamo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","20");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    # Proceso Calculo prevision partidas transitorias
    pdef = ProcessDefinition("Calculo prevision partidas transitorias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalcPrevPartidasTransit");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalcPrevPartidasTransit");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    # Proceso Contabilidad prevision partidas transitorias
    pdef = ProcessDefinition("Contabilidad prevision partidas transitorias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorContPrevPartidasTransit");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerContPrevPartidasTransit");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    # PROCESO: Deducciones de garantias morosas
    #pdef = ProcessDefinition("Deduccion de garantias", "topsystems.automaticprocess.deducciongarantias.calculo.DeduccionDeGarantias")
    #pdefs.addProcess(pdef)

    #PROCESO: Distribucion de Garantias No Deducidas
    #pdef = ProcessDefinition("Distribucion de Garantias No Deducidas", "topsystems.automaticprocess.deducciongarantias.calculo.DistribucionDeGarantiasNoDeducidas")
    #pdefs.addProcess(pdef)

    # PROCESO: Extorno de la deudccion de garantias
    pdef = ProcessDefinition("Extorno de asientos de garantias computables", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoDeduccionesGarantias");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)
    
    # PROCESO: actualizacion de garantias en pesos con tasacion en dolares (hipotecas y prendas)
    pdef = ProcessDefinition("Actualizacion Tasaciones en Dolares", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_ACT_GARA_USD_TASACION");
    pdefs.addProcess(pdef)

    #Proceso = Intereses Vista Cobro de intereses
    pdef = ProcessDefinition("Cobro de interes", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("JTS_OID",1,"",0);
    pdef.addConstant("campoNroAutorizacion","1510");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdefs.addProcess(pdef)

    # ENVIO MASIVO MAIL
    pdef = ProcessDefinition("Envio Masivo Mails", "topsystems.automaticprocess.enviomasivomails.EnvioMasivoMails")
    pdef.addConstant("ipMailServer","smtp.nbch.com.ar");
    pdef.addConstant("puertoMailServer","25");
    pdef.addConstant("mailFrom","alpha@localhost.com");
    pdef.addConstant("intentos", "5");
    pdef.addConstant("pathHtmls","mails/html");
    pdef.addConstant("pathAttachments","mails/attach");
    pdef.addConstant("pathImagenes","mails/imagen");
    pdef.addConstant("pie","mails/pie.html");
    pdef.addConstant("sleepTime","0");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("PerdidasYGananciasOperacionesCambio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPerdidasYGananciasOperacionesCambio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPerdidasYGananciasOperacionesCambio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","3");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #numero de campo Rubro_Ganancias_Exp en la tabla MONEDAS
    pdef.addConstant("numeroCampoRubroGananciasExp","50109");
    #numero de campo Cta_Ganancias_Exp en la tabla MONEDAS
    pdef.addConstant("numeroCtaGananciasExp","50110");
    #numero de campo Rubro_Perdidas_Exp en la tabla MONEDAS
    pdef.addConstant("numeroCampoRubroPerdidasExp","50111");
    #numero de campo Cta_Perdidas_Exp en la tabla MONEDAS
    pdef.addConstant("numeroCtaPerdidasExp","50112");
    pdef.addConstant("ResultadoRubroOrigen","false");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("ConsumoLineaAcuerdoSobregirosTipoPlazo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDConsumoLineasAcuerdoSobregiroTipoPlazo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWConsumoLineasAcuerdoSobregiroTipoPlazo");
    pdef.addConstant("campoNroAutorizacion","81011");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("campoTipoAutorizacion","81015");
    pdef.addConstant("campoOrdinal","81020");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Recupero de lineas Tipo Plazo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDRecuperoLineaTipoPlazo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWRecuperoLineaTipoPlazo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("campoTipoProducto","23121");
    pdef.addConstant("campoNroAutorizacion","81011");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("campoOrdinal","81020");
    pdef.addConstant("utilizaMultiCuentas","true");
    pdef.addConstant("query","query.QueryRecuperoLineaTipoPlazo");
    pdefs.addProcess(pdef)

    #Proceso = Intereses Vista devengado de intereses
    pdef = ProcessDefinition("Devengado de interes Tipo Plazo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobroTipoPlazo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobroTipoPlazo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("JTS_OID",1,"",0);
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Reservas Sobre Saldos Consumo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDGenerarReservasTipoPlazo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWGenerarReservasTipoPlazo");
    pdef.addConstant("rangoCommit","50");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    # PROCESO: Borrado de Historico de Previsiones
    pdef = ProcessDefinition("Borrado de Historico de Previsiones", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "DEP_HISTORICO_PREVISIONES.proc_dep_hist_previsiones");
    pdefs.addProcess(pdef)

    #Busca Rubro Final
    pdef = ProcessDefinition("Busca Rubro Final", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBuscaRubroFinal");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBuscaRubroFinal");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    # PROCESO: Extorno Contabilizacion Devengamiento
    pdef = ProcessDefinition("Extorno Contabilizacion Devengamiento","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("marcaAjuste","0");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoDevPlazoAsientos");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)
    
    # PROCESO: Extorno Movimientos Diferidos
    pdef = ProcessDefinition("Extorno Movimientos Diferidos","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("marcaAjuste","0");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoMovDiferidos");
    pdef.addConstant("queryFechaValor","");
    pdef.addConstant("condicion","");
    pdef.addConstant("UTILIZA_CAMBIO_DEL_DIA","true");
    pdefs.addProcess(pdef)

    # PROCESO: Extorno Exposicion de Sobregiros
    pdef = ProcessDefinition("EXTORNO ExposicionSobregiros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoExposicionSobregiros");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Notificacion suplencias Workflow", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorSubstitutionNotification");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerSubstitutionNotification");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef);
    ##Cambio nueva version de Jython
    pdef = ProcessDefinition("Cobertura entre Cuentas - Grupo especifico", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorFundsCoverage");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerFundsCoverage");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerFundsCoverage");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("Grupo a tratar",1,"",0);
    pdef.addConstant("orden","2");
    pdef.addConstant("usaClienteEnComisiones","true");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    # Generacion Estados de Cuenta Trimestrales
    pdef = ProcessDefinition("EstadosdeCuentaT","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", " ");
    pdef.addConstant("Periodicidad", "T");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef) 
    # Generacion Estados de Cuenta LEGALES Mensual
    pdef = ProcessDefinition("EstadosdeCuentaLM","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", "L");
    pdef.addConstant("Periodicidad", "M");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef) 
    # Generacion Estados de Cuenta LEGALES Trimestral
    pdef = ProcessDefinition("EstadosdeCuentaLT","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", "L");
    pdef.addConstant("Periodicidad", "T");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef) 
    # Generacion Estados de Cuenta LEGALES Anual
    pdef = ProcessDefinition("EstadosdeCuentaLA","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "ESTADOCUENTA");
    pdef.addConstant("Legal", "L");
    pdef.addConstant("Periodicidad", "A");
    pdef.addConstant("FechaDesde", "");
    pdef.addConstant("FechaHasta", "");
    pdef.addConstant("SaldoJTSOID", "");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;FechaDesde,C;FechaHasta,C;SaldoJTSOID,C;");
    pdefs.addProcess(pdef) 
    # INTERFASES: Relacion Cuenta-Tarjeta
    pdef = ProcessDefinition("ABM Tarjetas de Credito", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_ABM_TARJCRED");
    pdefs.addProcess(pdef)
    # PROCESO: ACTUALIZACION TITULOS
    pdef = ProcessDefinition("Actualizacion Titulos", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_ACTUALIZACION_TITULOS")
    pdefs.addProcess(pdef)
    # PROCESO: LEY INFRACTORES CHEQUES
    pdef = ProcessDefinition("Ley Infractores Cheques", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_LEY_INFRACTORES_CHEQUES");
    pdefs.addProcess(pdef)
    # Cambio Rubro Prestamos por Compra de Cartera
    pdef = ProcessDefinition("Cambio Rubro Prestamos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCambioRubro");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCambioRubro");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCambioRubro");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # IncrementoParticipacion
    pdef = ProcessDefinition("Valores Incremento Participacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorIncrementoParticipacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerIncrementoParticipacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerIncrementoParticipacion");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CODIGO_TITULO",1,"",0);
    pdef.addParameter("Monto a Capitalizar",2,"0.00",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Valores - Amortizacion de Cupon
    pdef = ProcessDefinition("Valores - Amortizacion de Cupon", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPagoCupon");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPagoCupon");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerPagoCupon");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CODIGO_TITULO",1,"",1);
    pdef.addParameter("NUMERO_CUPON",1,"",1);
    pdef.addConstant("FUNCIONALIDAD","A");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # PROCESO: Valores - Pago y Amortizacion de Cupon
    pdef = ProcessDefinition("Valores - Pago y Amortizacion de Cupon", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorPagoCupon");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerPagoCupon");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerPagoCupon");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("CODIGO_TITULO",1,"",1);
    pdef.addParameter("NUMERO_CUPON",1,"",1);
    pdef.addConstant("FUNCIONALIDAD","S");
    pdef.addParameter("FECHA_DE_CALCULO",4,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    # Calculo de la concentracion de libradores
    pdef = ProcessDefinition("Calcular concentracion de libradores", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalcularConcentracion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalcularConcentracion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalcularConcentracion");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)
    # Calculo de los descuentos a realizar por librador
    pdef = ProcessDefinition("Calcular descuentos a realizar por librador", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalcularDeudasPorDescontar");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalcularDeudasPorDescontar");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalcularDeudasPorDescontar");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)
    # Calculo de los descuentos realizados por librador
    pdef = ProcessDefinition("Calcular descuentos realizados por librador", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalcularDeudasDescontados");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalcularDeudasDescontados");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalcularDeudasDescontados");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)
    # Calculo de los descuentos a realizar por librador
    pdef = ProcessDefinition("Calcular descuentos a realizar por librador", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalcularDeudasPorDescontar");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalcularDeudasPorDescontar");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalcularDeudasPorDescontar");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)    
    # Calculo de los descuentos realizados por librador
    pdef = ProcessDefinition("Calcular descuentos realizados por librador", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalcularDeudasDescontados");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalcularDeudasDescontados");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCalcularDeudasDescontados");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)        
    # Trunca la tabla de CRE_CONCENTRACION_X_LIBRADOR
    pdef = ProcessDefinition("Truncar tabla CRE_CONCENTRACION_X_LIBRADOR", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_CONCENTRACION_X_LIBRADOR.TRUNC_CONC_X_LIBRADOR");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("ImpresionLetrasCambio", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_IMPRESIONLETRASCAMBIO");
    pdef.addConstant("ParamtersPositions", "LetraDesde,P;LetraHasta,P;Serie,P;");
    pdef.addParameter("LetraDesde",1,"",1);
    pdef.addParameter("LetraHasta",1,"",1);
    pdef.addParameter("Serie",3,"",1);
    pdefs.addProcess(pdef)
    # PROCESO: Control Lineas de Credito Consumo
    pdef = ProcessDefinition("Control Lineas de Credito Consumo : Acuerdos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorControlDeAcuerdos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerControlDeAcuerdos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Control Lineas de Credito Consumo
    pdef = ProcessDefinition("Control Lineas de Credito Consumo : Acuerdos a Demanda", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorControlDeAcuerdosADemanda");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerControlDeAcuerdos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("SUCURSAL",1,"",0);
    pdef.addParameter("SEGMENTO",1,"",0);
    pdef.addParameter("DIAS_PREVIOS_VENC",1,"",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Resultados por tenencia de moneda extranjera
    pdef = ProcessDefinition("Resultados por tenencia de moneda extranjera", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorResTenenciaDeMonExtranjera");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerResTenenciaDeMonExtranjera");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerResTenenciaDeMonExtranjera");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # INTERFASES: Envio Cheques devueltos(DEVGIR) a camara
    pdef = ProcessDefinition("Envio DEVGIR a camara", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_DEVGIR")
    pdefs.addProcess(pdef)    
    # PROCESO: Cierre 
    pdef = ProcessDefinition("ObtenerGananciasPerdidas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorObtenerGananciasPerdidas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerObtenerGananciasPerdidas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerObtenerGananciasPerdidas");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("GRUPO BALANCE PERDIDAS","8");
    pdef.addConstant("GRUPO BALANCE GANANCIA","9");    
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("USAR PROXIMO DIA HABIL","false");
    pdef.addConstant("applyCodigoTransaccion","false");
    pdefs.addProcess(pdef) 
    # PROCESO: Cierre 
    pdef = ProcessDefinition("ActualizacionResultadosEjercicio", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAplicarInstrucciones");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAplicarInstrucciones");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerAplicarInstrucciones");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ACTUALIZA FECHAS","true");
    pdef.addConstant("USAR PROXIMO DIA HABIL","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)     
    #Posicion Fin de Mes BCU
    #pdef = ProcessDefinition("Posicion Fin de Mes BCU", "topsystems.automaticprocess.interfaces.posicionfinmes.SpPosicionFinDeMesBCU")
    #pdefs.addProcess(pdef)
    # PROCESO: Historico: Saldos Diarios y Mensuales - Recalculo Acumuladores Intereses
    pdef = ProcessDefinition("Saldos D y M Recalculo Acumuladores Intereses", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRecalculoHistoricoIntereses");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRecalculoHistoricoIntereses");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("JTS_OID_FINAL",1,"",0);
    pdef.addParameter("JTS_OID",1,"",0);
    pdef.addParameter("FECHA_INICIO",4,"dd/MM/yyyy",0);
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # PROCESO: Marcar saldos garantizados
    pdef = ProcessDefinition("Marcar saldos garantizados", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorMarcarSaldosGarantizados");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerMarcarSaldosGarantizados");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerMarcarSaldosGarantizados");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","4");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Cargos Tarjetas Debito Pago Sueldo
    pdef = ProcessDefinition("Cargos Tarjetas Debito Pago Sueldo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","250");
    pdef.addConstant("eventList","6000");
    pdef.addConstant("jtsOidFieldNumber","9893");
    pdef.addConstant("monedaFieldNumber","9894");
    pdef.addConstant("saldoActualFieldNumber","9892");
    pdef.addConstant("nroOperacion","8638");
    pdef.addConstant("descripcion","Cargos Tarjetas Debito Mayo");
    pdef.addConstant("reports","500");  
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
    # Cargos Tarjetas Debito Exceso Movimientos
    #pdef = ProcessDefinition("Cargos Tarjetas Debito Exceso Mov", "topsystems.automaticprocess.processmanager.WorkManager")
    #pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    #pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    #pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    #pdef.addConstant("rangoCommit","500");
    #pdef.addConstant("cantidadHilos","15");
    #pdef.addConstant("isStopable","true");
    #pdef.addConstant("applySchemes","true");
    #pdef.addConstant("isSumarizable","false");
    #pdef.addConstant("offLine","true");
    #pdef.addConstant("enqueue","false");
    #pdef.addConstant("descriptor","309");
    #pdef.addConstant("eventList","6100");
    #pdef.addConstant("jtsOidFieldNumber","4966");
    #pdef.addConstant("monedaFieldNumber","8551");
    #pdef.addConstant("saldoActualFieldNumber","4967");
    #pdef.addConstant("nroOperacion","8636");
    #pdef.addConstant("descripcion","Cargos Tarjetas Debito");
    #pdef.addConstant("reports","500");  
    #pdef.addConstant("generaAsientoContable","true");
    #pdefs.addProcess(pdef)
    # Acreditacion de cheques
    pdef = ProcessDefinition("AcreditacionDeCheques", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAcreditacionCheques");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAcreditacionCheques");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerAcreditacionCheques");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    #pdef.addParameter("CODIGO_CAMARA",1,"true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("strategy","0");
    pdef.addConstant("campoCodigoCamara","7007");
    pdef.addConstant("campoBancoGirado","7004");
    pdef.addConstant("campoSucursalBancoGirado","7005");
    pdef.addConstant("campoCodigoPlaza","7006");
    pdef.addConstant("campoNumeroCheque","7003");
    pdef.addConstant("campoNumericoCuentaGiradora","7011");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addConstant("campoEstado","58700");
    pdef.addConstant("campoCodigoRechazo","3289");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)
    
    # PROCESAR ITF_CLIENTESRECUPERO
    pdef = ProcessDefinition("Procesar Clientes en Recupero", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_CLIENTES_RECUPERO")
    pdefs.addProcess(pdef)
    # Generales
    pdef = ProcessDefinition("Actualizar Estadisticas BD", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_ITF_STATISTICS.SP_ITF_STATS_NUCLEO")
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("Actualizar Estadisticas BD Migracion", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PKG_ITF_STATISTICS.SP_ITF_STATS_MIGRA")
    pdefs.addProcess(pdef)
    # Cambio fecha de proceso
    pdef = ProcessDefinition("Cambio Fecha de Proceso Sucursal","topsystems.automaticprocess.sucursales.CambioFechaSucursal")
    pdef.addConstant("enqueue","false");
    pdef.addConstant("BRANCH","82");
    pdefs.addProcess(pdef)    
    # INTERFASES: Levanta Bandeja Comercios Courier
    pdef = ProcessDefinition("Genera Bandeja de Comercios Courier", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_CARGOCOMERCIOS");    
    pdefs.addProcess(pdef)
    # INTERFASES: Switch de bandejas
    pdef = ProcessDefinition("Switch de bandejas", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_SWITCHBANDEJA")
    pdef.addConstant("ParamtersPositions", "IDREGISTRO,P;");
    pdef.addParameter("IDREGISTRO",1);
    pdefs.addProcess(pdef);
    pdef = ProcessDefinition("Limpia Bandeja de Cajas", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ITF_TRUNCATE_SER_SOLIC_CAJA")
    pdefs.addProcess(pdef)
    # INTERFASES: TLF Reversas Efectivo Banred
    pdef = ProcessDefinition("Genera Bandeja TLF-Reversas-Banred", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ITF_RETIROSBANRED_REVERSA");
    pdefs.addProcess(pdef)
	# INMOVILIZAR SALDOS DPF
    pdef = ProcessDefinition("Inmovilizar saldos DPF", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_INMOVILIZAR_SALDOS_DPF");
    pdefs.addProcess(pdef)
    # PROCESO: Procesamiento de la bandeja de entrada
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable MIG", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR_CTE","MIG");
    pdef.addConstant("productosAplicaOffLine","273;4101;4102;4103;4104;4105;4106;4107;4108;4109;4201;4203;4204;4205;4206;4207;4208;4209;4301;4302;4303;4304;4305;4306;4307;4308;4309");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Impresion Cheques Letras de Cambio","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","9307");
    pdef.addParameter("Nro. Letra Cbio_1",1);
    pdef.addParameter("Nro. Letra Cbio_2",1);
    pdef.addParameter("Serie Letra",3);
    pdef.addConstant("DESTINY","1");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("Impresion Cheques Diferidos","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","8043");
    pdef.addParameter("Nro. Letra Cbio_1",1);
    pdef.addParameter("Nro. Letra Cbio_2",1);
    pdef.addParameter("Serie Letra",3);
    pdef.addConstant("DESTINY","1");
    pdefs.addProcess(pdef)
    
    
    return
 
def addMoreProcesses3(pdefs):
    # PROCESO: Caida de Cheques al Cobro
    pdef = ProcessDefinition("Caida de Cheques al Cobro", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.caidaChequesAlCobro");
    pdefs.addProcess(pdef)

    # Proceso de Analisis de devengado en suspenso
    pdef = ProcessDefinition("Analisis de devengado en suspenso", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_DEVENGA_SUSPENSO");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("AjusteOperCambioRetroactiva", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDAjusteOperCambio");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWAjusteOperCambio");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("offLine","false");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cargar bandejas Cierre Extendido", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCopiaBandejasCierreExtend");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCopiaBandejasCierreExtend");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdefs.addProcess(pdef)

    # Procesamiento de la Bandeja contable FME
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable FME", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR_CTE","FME");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    # Registro de la Bandeja contable FME
    pdef = ProcessDefinition("Registro de la Bandeja contable FME", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDBandejaContCierreExtend");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWBandejaContCierreExtend");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ORIGEN_A_PROCESAR","FME");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("queryName","query.QueryBandejaProduccion");
    pdef.addConstant("AmbienteProduccion","true");
    pdefs.addProcess(pdef)
	# PROCESO: Adelanto haberes
    
    #Store Procedure Resumen de Adelantos
    pdef = ProcessDefinition("Resumen de Adelanto Haberes", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_GENERO_RESUMEN_AH")
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Adelanto haberes", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.AdelantoHaberes");
    pdefs.addProcess(pdef)
    
    #Store Procedure Actualizo Estado de Adelantos
    pdef = ProcessDefinition("Actualizo Estado de Adelanto Haberes", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZO_ESTADO_ADELANTO")
    pdefs.addProcess(pdef)
    # Memo 02
    pdef = ProcessDefinition("Genera memo 02", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_MEMOS_CABECERA")
    pdefs.addProcess(pdef)
    # Memo 04
    pdef = ProcessDefinition("Genera memo 04", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_MEMOS_DETALLE")
    pdefs.addProcess(pdef)
    # REPORTE SEGUROS - DATOS CLIENTES
    pdef = ProcessDefinition("Genera Datos Clientes", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_SEGURO_SALDO_DEUDOR_CLIENTES")
    pdef.addParameter("FECHA_A_PROCESAR",4,"dd/MM/yyyy",1)
    pdef.addConstant("ParamtersPositions", "FECHA_A_PROCESAR,P;");
    pdefs.addProcess(pdef)
    # REPORTE SEGUROS - DATOS PRODUCTOS
    pdef = ProcessDefinition("Genera Datos Productos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_SEGURO_SALDO_DEUDOR_PRODUCTOS")
    pdef.addParameter("FECHA_A_PROCESAR",4,"dd/MM/yyyy",1)
    pdef.addConstant("ParamtersPositions", "FECHA_A_PROCESAR,P;");	
    pdefs.addProcess(pdef)
    #REPORTE SEGUROS - RENDICION ASEGURADORAS
    pdef = ProcessDefinition("Genera rendicion Aseguradoras", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "CRE_SEGURO_SALDO_DEUDOR.kjb")
    pdef.addParameter("fecha",4,"dd/MM/yyyy",1)
    pdef.addConstant("ParamtersPositions", "fecha,P;");
    pdefs.addProcess(pdef)    
    # Procesamiento de la Bandeja contable EXT
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable EXT", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR_CTE","EXT");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    # Registro de la Bandeja contable EXT
    pdef = ProcessDefinition("Registro de la Bandeja contable EXT", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDBandejaContCierreExtend");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWBandejaContCierreExtend");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ORIGEN_A_PROCESAR","EXT");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("queryName","query.QueryBandejaCierreExtendido");
    pdef.addConstant("AmbienteProduccion","false");
    pdefs.addProcess(pdef)
    # Procesamiento de la Bandeja contable TNB 1.18.7
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable TNB", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR","TNB");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    # Procesamiento de la Bandeja contable TAC 1.18
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable TAC", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR","TAC");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)
	
    # Procesamiento de la Bandeja contable TNB 1.18.8
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable TNA", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR","TNA");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    # Procesamiento de la Bandeja contable TNB 1.19.6
    pdef = ProcessDefinition("Procesamiento de la Bandeja contable UNT", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #pdef.addParameter("ORIGEN_A_PROCESAR",3,"",0);
    pdef.addConstant("ORIGEN_A_PROCESAR","UNT");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Copia Tablas de Cierre extendido", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PKG_ACT_TABLAS_CIERRE_EXT");
    pdef.addConstant("ParamtersPositions", "FechaCierre,P;");
    pdef.addParameter("FechaCierre",4,"dd/mm/yyyy",1);
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Contabilizacion Acuerdos En Cuentas No Consumidos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDContabilizacionAcuerdosEnCuentasNoConsumidos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWContabilizacionAcuerdosEnCuentasNoConsumidos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("offLine","true");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Extorno Contabilizacion Acuerdos En Cuentas No Consumidos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("queryAsientosExtornar","query.extornoAcuerdosSobregiros");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("DevengamientoComisionDesembolso", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDevengaCronogramaComisionDiferida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDevengaCronogramaComisionDiferida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("CreaComisionDesembolso", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCreaCronogramaComisionDiferida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCreaCronogramaComisionDiferida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("NotifyTaskExpired", "topsystems.bpm.server.automaticprocess.timeexpired.NotifyTimeExpiredProcess")
    pdef.addConstant("subject","[Workflow] ${cant} Tareas Atrasadas del usuario: ${userName}.");
    pdef.addConstant("body","Estimado ${userName}. Ud posee ${cant} tareas atrasadas.");
    pdef.addConstant("subjectSuperior","[Workflow] ${cant} Tareas Atrasadas del usuario: ${userName}.");
    pdef.addConstant("bodySuperior","Estimado ${superiorName}. El usuario ${userName} posee ${cant} tareas atrasadas.");
    pdef.addConstant("from","info@notifalertas.com");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Genera Historico Calificacion Objetiva Refinanciado", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionObjetivaDeudaRefinanciado");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionObjetivaDeudaRefinanciado");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    # Proceso para numerar los movimientos contables segun rango de fechas
    # Proceso para numerar los movimientos contables segun rango de fechas
    pdef = ProcessDefinition("Numeracion de movimientos contables", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorNumeradorMovimientosContables");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerNumeradorMovimientosContables");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addParameter("FECHA_DESDE",4,"dd/MM/yyyy",1);
    pdef.addParameter("FECHA_HASTA",4,"dd/MM/yyyy",1);
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Borrado tabla CON_HISTORICO_UVA_UVI", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBorradoDatosPorVO");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBorradoDatosPorVO");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("queryTablaDepurar","query.BorradoHistoricoFinMesUVAyUVI");
    pdef.addConstant("VoName","core.vo_ConHistoricoFinDeMesUvaUvi");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Registro historico fin de mes UVA UVI", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorGrabarSaldosUVAyUVIFinDeMes");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerGrabarSaldosUVAyUVIFinDeMes");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Actualizar Movimientos ajustes UVA UVI", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAjustesSaldosUVAyUVI");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAjustesSaldosUVAyUVI");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","false");
    pdefs.addProcess(pdef)

    # PROCESO: Extorno Contabilizacion Ajuste UVA y UVI
    # PROCESO: Extorno Contabilizacion Ajuste UVA y UVI
    pdef = ProcessDefinition("Extorno Contabilizacion Ajuste UVA y UVI","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("respetaOfflineOrginal","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("marcaAjuste","0");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoContabAjusteUVAyUVI");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdef.addConstant("UTILIZA_CAMBIO_DEL_DIA","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Contabilizacion de ajustes UVA UVI", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDContabilidadAjustesUVAyUVI");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWContabilidadAjustesUVAyUVI");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("offLine","false");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Extorno Contabilizacion Previsiones", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoPrevisiones");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Contabilizacion de Previsiones", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDContabilizacionPrevisiones");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWContabilizacionPrevisiones");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("isSumarizable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Calculo de Prevision por categoria, atraso y garantias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCalculoDePrevisiones");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCalculoDePrevisiones");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","5");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Genera Historico Calificacion Objetiva", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCalificacionObjetivaDeudaNoRefinanciado");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCalificacionObjetivaDeudaNoRefinanciado");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Borrado tabla HISTORICO_CALIF_X_SALDO", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBorradoDatosPorVO");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBorradoDatosPorVO");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("queryTablaDepurar","query.HistoricoCalificacionObjetivaNoRefinaciada");
    pdef.addConstant("VoName","vo.HistoricoCalificacionObjetivaNoRefinaciada");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Pago Intereses Vista Saldos Inmovilizados", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDPagoInteresesVistaSaldosInmovilizados");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWPagoInteresesVistaSaldosInmovilizados");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("usarSaldosRecortado","true");
    pdef.addConstant("usaClienteEnComisiones","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Generar Reserva Cobranza Vista", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorReservaCobranzaVista");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerReservaCobranzaVista");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("fechaVencimiento",'1');
    pdef.addConstant("diasAtraso",'1');
    pdef.addConstant("mesesAtraso",'1');
    pdef.addConstant("deuda",'1');
    pdef.addConstant("mora",'1');
    pdef.addConstant("campoNombreConvenio",'1');
    pdefs.addProcess(pdef)
    
    #Bandeja de Acreditaciones Masivas Default (GENERICO)
    pdef = ProcessDefinition("Debitos y Creditos  Masivos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"",0);
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Bandeja Acreditaciones Masivas UN HILO UN ASIENTO Corte en 1000 (GENERICO)
    pdef = ProcessDefinition("Debitos y Creditos Masivos MonoHilo Un Asiento", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"",0);
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Bandeja de Acreditaciones Masivas UN HILO MULTI ASIENTO Corte en 1 (GENERICO)
    pdef = ProcessDefinition("Debitos y Creditos Masivos MonoHilo Multi Asiento", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"",0);
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Creditos Masivos UN HILO UN ASIENTO Corte en 1000 (GENERICO)
    pdef = ProcessDefinition("Creditos Masivos MonoHilo Un Asiento", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"",1);
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Creditos Masivos UN HILO MULTI ASIENTO Corte en 1 (GENERICO)
    pdef = ProcessDefinition("Creditos Masivos MonoHilo Multi Asiento", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"",1);
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Debitos Masivos UN HILO UN ASIENTO Corte en 1000 (GENERICO)
    pdef = ProcessDefinition("Debitos Masivos MonoHilo Un Asiento", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"",1);
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Debitos Masivos UN HILO MULTI ASIENTO Corte en 1 (GENERICO)
    pdef = ProcessDefinition("Debitos Masivos MonoHilo Multi Asiento", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"",1);
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Creditos Masivos CREDICOM
    pdef = ProcessDefinition("Creditos Masivos CREDICOM", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"ACREDCOM_CRED (Presione Aceptar)",0,"ACREDCOM_CRED");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    #Debitos Masivos CREDICOM
    pdef = ProcessDefinition("Debitos Masivos CREDICOM", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"ACREDCOM_DEB (Presione Aceptar)",0,"ACREDCOM_DEB");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdefs.addProcess(pdef)
    
    # Cobranza Automatica Cuota por Cuota
    pdef = ProcessDefinition("Cobranza Automatica Cuota por Cuota", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCobranzaAutomatica");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaAutomatica");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","50");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("Campo capital restructurado","1685");
    pdef.addConstant("Campo interes restructurado","1726");
    pdef.addConstant("Pivot capital restructurado","733");
    pdef.addConstant("Pivot interes restructurado","734");
    pdef.addConstant("CAMPO_DEV_IVA_INTERES","0737");
    pdef.addConstant("consideraSobregiro","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("ordenaPorClienteVcto","true");
    pdef.addConstant("cobraOrdenadoPorCuota","PORCUOTA");
    pdef.addConstant("disminuirReservaEnCobro","false");
    pdef.addConstant("disponibilidadConReservasMayorPrioridad","false");
    pdef.addConstant("camposDeSaldoParaCargos","1591,44054");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Devengado Intereses Deudores N Acuerdos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("CAMPO_DEVENGADO_59_DIAS","C1806");
    pdef.addConstant("ES_COBRO","False");
    pdef.addConstant("Cobro Intereses Por Cargo","False");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Extorno Contabilizacion Afectacion Garantias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("queryAsientosExtornar","query.vo_extornoAfectacionGarantias");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Contabilizacion Afectacion de Garantias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDContabilizacionAfectacionGarantias");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWContabilizacionAfectacionGarantias");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("offLine","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Borrado tabla CRE_HISTORICO_DEUDA_GARANTIAS", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorBorradoDatosPorVO");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBorradoDatosPorVO");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("queryTablaDepurar","query.HistoricoDeudaGarantias");
    pdef.addConstant("VoName","vo.HistoricoDeudaGarantias");
    pdefs.addProcess(pdef)

    # PROCESO: Calculo Afectacion Prestamos sin Garantias
    pdef = ProcessDefinition("Calculo Afectacion Prestamos sin Garantias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCalculoAfectacionPrestamosSinGarantias");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCalculoAfectacionPrestamosSinGarantias");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Calculo Afectacion Garantias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCalculoAfectacionGarantia");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCalculoAfectacionGarantia");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Corrimiento Vencimiento DPF", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCorrimientoVencimientoDPF");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCorrimientoVencimientoDPF");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Asignacion de licencias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDAsignacionTemporalLicencias");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWAsignacionTemporalLicencias");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","20");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Asignacion temporal de grupos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDAsignacionTemporalGrupo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWAsignacionTemporalGrupo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","20");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Borrar saldos diarios", "topsystems.automaticprocess.saldosdiarios.BorrarSaldosDiarios")
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Servicio Financiero Personas Juridicas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDSrvFinancieroJuridicas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWSrvFinancieroJuridicas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Servicio Financiero Personas Fisicas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDSrvFinancieroFisicas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWSrvFinancieroFisicas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Perfil Documental", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDPerfilDocumental");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWPerfilDocumental");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Depura Contadores por Movimiento", "topsystems.automaticprocess.depurarcontadores.DepurarContadoresMovimientos")
    pdefs.addProcess(pdef)

    # Cobranza Automatica Preparacion
    # Cobranza Automatica Preparacion
    pdef = ProcessDefinition("Cobranza Automatica Preparacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCobranzaAutomaticaPreparacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaAutomaticaPreparacion");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    # Generar Balance de Contabilidad Saldos Diarios
    pdef = ProcessDefinition("Generar Balance de Contabilidad Saldos Diarios", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorSDContabilidadBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerSDContabilidadBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("FECHA_A_PROCESAR",4,"dd/MM/yyyy",1);
    pdef.addConstant("LARGO_RUBROS", "15");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Inactivacion de Usuarios", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDUsuariosInactivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWUsuariosInactivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","20");
    pdefs.addProcess(pdef)

    # Ganancia Intereses Refinanciados
    pdef = ProcessDefinition("Ganancia Intereses Refinanciados", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDGananciasIntRefinanciados");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWGananciasIntRefinanciados");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Acreditacion Rapida", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAcreditacionRapida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAcreditacionRapida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","20");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Enviar Eventos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorEnviarEventos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerEnviarEventos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    # PROCESO: Generacion de Reservas para Cobranza Auotmatica de Prestamos
    pdef = ProcessDefinition("Informar Reservas Judiciales", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorInformarReservasJudiciales");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerInformarReservasJudiciales");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("CAMPO_RESERVA_FECHA_ENVIADO","FECHA_ENVIADO");
    pdef.addConstant("CAMPO_RESERVA_ESTADO_ENVIADO","ESTADO_ENVIADO");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Reserva Cobranca de tarifas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorReservaCobranzaCargos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerReservaCobranzaCargos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("readCliente","false");
    pdefs.addProcess(pdef)

    # Activacion Bloqueos
    pdef = ProcessDefinition("Activacion Bloqueos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorActivacionBloqueos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerActivacionBloqueos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)

    #Extorno Reversas Webservice
    pdef = ProcessDefinition("Extorno Reversas Webservice", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    #pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("queryAsientosExtornar","query.vo_ReversaWebservice");
    pdef.addConstant("queryFechaValor","query.vo_extornofechaValorHoy");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)

    # PROCESO: Generacion de Reservas para Cobranza Auotmatica de Prestamos
    pdef = ProcessDefinition("Reservas Cobranza Automatica", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDGenerarReservasCobranzaAutomatica");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWGenerarReservasCobranzaAutomatica");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","50");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("QUERY_NAME","query.vo_ReservaCobranzaAutomatica");
    pdefs.addProcess(pdef)

    # Cambio de Sucursal
    pdef = ProcessDefinition("Cambio de Sucursal Total", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCambioSucursal");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCambioSucursal");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("IGNORAR_TIPO_PRODUCTO","");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("query","query.BandejaCambioSucursalTotalSinMultiEmpresa");
    pdef.addConstant("TIPO","TOTAL");
    pdefs.addProcess(pdef)

    # Cambio de Sucursal
    pdef = ProcessDefinition("Cambio de Sucursal Parcial", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCambioSucursal");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCambioSucursal");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("IGNORAR_TIPO_PRODUCTO","");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("query","query.BandejaCambioSucursalParcialSinMultiEmpresa");
    pdef.addConstant("TIPO","PARCIAL");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Aplicacion Movimientos OffLine", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDOfflineMovementApplication");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWOfflineMovementApplication");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerMovimientosOffline");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","15");
    pdefs.addProcess(pdef)

    # PROCESO: "CLI - Contador Clientes Activos"
    pdef = ProcessDefinition("Contador Clientes Activos","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorContadorClientesActivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerContadorClientesActivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    # PROCESO: Extorno Sub Asiento
    pdef = ProcessDefinition("ExtornoSubAsiento", "topsystems.automaticprocess.extorno.ExtornSubAsientoProcess")
    pdef.addParameter("FECHA_VALOR",4,"dd/MM/yyyy",0);
    pdef.addParameter("esAjusteParam",3,"",0);
    pdef.addParameter("SUB_ASIENTO",1,"",1);
    pdefs.addProcess(pdef)

    # Marca Comienzo Inicio del dia
    pdef = ProcessDefinition("Marca Comienzo Inicio del dia", "topsystems.processmgr.process.StartOfDayProcess")
    pdef.addConstant("SOD","1");
    pdefs.addProcess(pdef)
    # Marca Fin de Cierre
    pdef = ProcessDefinition("Marca Fin Inicio del dia", "topsystems.processmgr.process.StartOfDayProcess")
    pdef.addConstant("SOD","2");
    pdefs.addProcess(pdef)

    # PROCESO CAMBIO FECHA SUCURSAL VIRTUAL X CANAL
    pdef = ProcessDefinition("Cambio fecha sucursal virtual", "topsystems.automaticprocess.cambiofechasucvirtual.CambioFechaSucursalVirtual")
    pdef.addConstant("EMPRESA","-1");
    pdef.addParameter("CANALES",3,"",0)
    pdefs.addProcess(pdef)

    # PROCESO: "GRL - Apertura Sucursales"
    pdef = ProcessDefinition("Apertura de Sucursales","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorAperturaSucursales");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerAperturaSucursales");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","40");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    # PROCESO: "GRL - Cambio de Fecha de Sucursales"
    pdef = ProcessDefinition("Cambio de Fecha de Sucursales","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCambioFechaSucursales");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCambioFechaSucursales");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","40");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    # PROCESO: "GRL - Cierre de Sucursales"
    pdef = ProcessDefinition("Cierre de Sucursales","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCierreSucursales");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCierreSucursales");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","40");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cobro IOF Sobregiros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCobroIOFSobregiros");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCobroIOFSobregiros");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("enqueue","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Recupero de Intereses Adeudados", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCobroInteresesAdeudados");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCobroInteresesAdeudados");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("enqueue","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cobro Intereses Deudores", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobroDeudores");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobroDeudores");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("enqueue","true");
    pdef.addConstant("CAMPO_DEVENGADO_59_DIAS","C1806");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Proceso Unificado XBRL", "topsystems.automaticprocess.xbrl.procesounificado.ProcesoUnificadoGeneracionXbrl")
    pdef.addConstant("queryRutaJSON", "SELECT VALOR FROM XBRL_PARAMETROS WHERE FUNCIONALIDAD='JSON MAPPING' AND PARAMETRO='file'");
    pdef.addConstant("buscarConceptosPorNombre", "true");
    pdefs.addProcess(pdef)

    # COMENTADO PAOLO MIGRACION 5_5
    # pdef = ProcessDefinition("Validar XBRL", "topsystems.automaticprocess.xbrl.validacion.ProcesoValidarXbrl")
    # pdef.addParameter("entryPoint",3,"",1);
    # pdef.addParameter("version",3,"",1);
    # pdef.addParameter("fecha",3,"",1);
    # pdef.addParameter("nombreArchivo",3,"",1);
    # pdefs.addProcess(pdef)

    pdef = ProcessDefinition("GENERAR XBRL", "topsystems.automaticprocess.xbrl.generacion.ProcesoGenerarXbrl")
    pdef.addParameter("rutaJSON",3,"",1);
    pdef.addParameter("rutaSalidaXBRL",3,"",1);
    pdef.addParameter("fechaFiltro",3,"",1);
    pdef.addConstant("queryRutaJSON", "SELECT VALOR FROM XBRL_PARAMETROS WHERE FUNCIONALIDAD='JSON MAPPING' AND PARAMETRO='file'");
    pdef.addConstant("buscarConceptosPorNombre", "true");
    pdefs.addProcess(pdef)
    pdef = ProcessDefinition("GENERAR EXCEL", "topsystems.automaticprocess.xbrl.generacion.ProcesoGenerarExcel")
    pdef.addParameter("entryPoint",3,"",1);
    pdef.addParameter("version",3,"",1);
    pdef.addParameter("fecha",3,"",1);
    pdef.addParameter("nombreArchivo",3,"",1);
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("DELIVERY_CATALOGOS_GENERADOS", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDeliveryCatalogoGenerado");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDeliveryCatalogoGenerado");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("numCatalogo","1");
    pdef.addConstant("subjet","Soy un delivery, soy un delivery");
    pdef.addConstant("mailFrom","hdiaz@topsystemscorp.com");
    pdef.addConstant("html","html1.html");
    pdef.addConstant("sleepTime","0");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Proceso Depuracion de Numeradores", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDepuraSecuenciadores");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDepuraSecuenciadores");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("PERIODOS_A_DEPURAR","1");
    pdef.addConstant("cantidadHilos","10");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Movimientos Offline MultiHilo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDOfflineMovementApplication");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWOfflineMovementApplication");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerMovimientosOffline");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addParameter("FechaProceso",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)
    
    # CONVENIOS
    pdef = ProcessDefinition("Convenios Recaudacion - Inactivacion", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "PA_CONV_REC_INACT");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Convenios Recaudacion - Baja", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "PA_CONV_REC_BAJA");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Convenios Pago - Inactivacion", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "PA_CONV_PAGO_INACT");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Convenios Pago - Baja", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "PA_CONV_PAGO_BAJA");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Liquidacion Convenios - Debito Automatico", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "PA_LIQ_CONV_DEB_AUTOMATICO");
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Convenios Recaudacion - Activacion Pagos Por Caja", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_CONV_REC_CAJAS_ALTA_CAB");
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Convenios Recaudacion - Liquidacion Pagos Por Caja", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_CONV_REC_CAJAS_LIQ");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Convenios Recaudacion - Renovacion Baja", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_CONV_RENOV_BAJA");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Convenios Pago - Renovacion Baja", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_CONV_PAG_RENOV_BAJA");
    pdefs.addProcess(pdef)


    # Comision Mantenimiento de Convenios recaudaciones y pagos
    pdef = ProcessDefinition("Comision por mantenimiento de Convenios", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","4524");
    pdef.addConstant("eventList","2601");
    pdef.addConstant("condition","");
    pdef.addConstant("jtsOidFieldNumber","45244");
    pdef.addConstant("monedaFieldNumber","45246");
    pdef.addConstant("saldoActualFieldNumber","45243");
    pdef.addConstant("nroOperacion","8634");
    pdef.addConstant("descripcion","Comision Mantenimiento Convenios");
    pdef.addConstant("reports","500");
    pdef.addConstant("readCliente","true");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    #AGENCIEROS

    pdef = ProcessDefinition("Pasaje Agencieros Debitos", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_AGENCIEROS_PASAJE_DEBITOS");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Pasaje Agencieros Creditos", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_AGENCIEROS_PASAJE_CREDITOS");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Actualizacion Agencieros", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_AGENCIEROS_ACTUALIZACION");
    pdefs.addProcess(pdef)

    #PROCESO: Rendicion Debitos Automaticos
    pdef = ProcessDefinition("Rendicion Debitos Automaticos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.RindoDebitosAutomaticos");
    pdefs.addProcess(pdef)

    #DÉBITOS DIRECTOS
    pdef = ProcessDefinition("Procesamiento de ordenes recibidas - Debitos Directos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ProcesoDebitosDirectos");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Contabilizacion de ordenes - Debitos Directos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ContabilizacionDebitosDirectos");
    pdefs.addProcess(pdef)

    #TRANSFERENCIAS
    pdef = ProcessDefinition("Procesamiento de transferencias recibidas - Transferencias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ProcesoTransferencias");
    pdefs.addProcess(pdef)

    #PROCESO: Calculo Impuesto Movimiento Moneda Extranjera
    pdef = ProcessDefinition("Calculo Impuesto Movimiento Moneda Extranjera", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ImpuestosMonedaExtranjera");
    pdefs.addProcess(pdef)

    # PROCESO: Cobro Sellos Chaco CC
    pdef = ProcessDefinition("Cobro Sellos Chaco Sobregiro CC", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.CobroSellosChacoCC");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Pago de transferencias recibidas - Transferencias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.PagoTransferencias");
    pdefs.addProcess(pdef)

    # PROCESO: Regularizacion Cuenta Previsiones
    pdef = ProcessDefinition("Regularizacion Cuenta Previsiones", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRegularizacionCuentaPrevisiones");
    pdef.addConstant("businessWorkName","topsystems:proces           nager:BusinessWorker=BusinessWorkerRegularizacionCuentaPrevisiones");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Aplicacion Movimientos OffLine C/P", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDOfflineMovementApplication");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWOfflineMovementApplication");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerMovimientosOffline");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addParameter("FechaProceso",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cambio fecha proceso s/p", "topsystems.processmgr.process.ChangeProcessDateWrapper")
    pdefs.addProcess(pdef)
    
    #Proceso para RRII Balance de Saldos
    #Proceso para RRII Balance de Saldos
    pdef = ProcessDefinition("RRII - Balance de saldos", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_BALANCE_SALDOS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdef.addParameter("rectificativa",3,"N/R")
    pdefs.addProcess(pdef)

 
    #Proceso para RRII  Regimen de supervision Anexo 12
    pdef = ProcessDefinition("RRII - Regimen de supervision anexo 12", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_REGIMEN_SUPERVISION_ANEXO12.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)
    
    # RRII - Interface contable
    pdef = ProcessDefinition("RRII - Interface Contable", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_INTERFAZ_CONTABLE.ktr")
    pdefs.addProcess(pdef)

    #Proceso para GAP31  Reportes Normativos BCRA Operaciones Pasivas
    #Proceso para GAP31  Reportes Normativos BCRA Operaciones Pasivas
    #Proceso para GAP31  Reportes Normativos BCRA Operaciones Pasivas
    pdef = ProcessDefinition("Operaciones Pasivas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "Operaciones_Pasivas.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)



    #Proceso para RRII Efectivo Minimo
    pdef = ProcessDefinition("RRII - EFECTIVO MINIMO", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_EFECTIVO_MINIMO.ktr")
    pdef.addParameter("fecha",3,"yyyy-MM-dd")
    pdefs.addProcess(pdef)
	
    #Proceso para RRII Padrón
    #Proceso para RRII Padrón
    pdef = ProcessDefinition("RRII - PADRON", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_PADRON_1.kjb")
    pdef.addParameter("mesAnio",3,"MM/yyyy")
    pdef.addParameter("rectificativa",3,"N/R")
    pdefs.addProcess(pdef)

	
    #Proceso para RRII Pago de Remuneraciones
    #Proceso para RRII Pago de Remuneraciones
    #Proceso para RRII Pago de Remuneraciones
    pdef = ProcessDefinition("RRII - Pago de remuneraciones", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_PAGO_REMUNERACIONES.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdef.addParameter("rectificativa",3,"N/R")
    pdefs.addProcess(pdef)


	
    #Proceso para GAP31  Reportes Normativos BCRA Operaciones Pasivas
    pdef = ProcessDefinition("Operaciones Pasivas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_OPERACIONES_PASIVAS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)



    #Proceso para RRII Reportes de ESTADO
    pdef = ProcessDefinition("RRII - Regimen de publicacion", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_ESTADOS.kjb")
    pdef.addParameter("fecha",3,"yyyy-MM-dd")
    pdefs.addProcess(pdef)

    #Proceso para RRII  Regimen de supervision
    pdef = ProcessDefinition("RRII - Regimen de supervision anexo 02", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_REGIMEN_SUPERVISION_ANEXO2.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #Proceso para Grabado de RRII_CHE_RECHAZADOS
    #Proceso para Grabado de RRII_CHE_RECHAZADOS
    pdef = ProcessDefinition("Grabado de Cheques Rechazados", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_Grabo_Cheques_Rechazados.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)


   #Proceso Gap 01 Reporte de Cheques Rechazados y Denunciados
    #Proceso Gap 01 Reporte de Cheques Rechazados y Denunciados
    pdef = ProcessDefinition("Cheques Rechazados y Denunciados", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_Cheques_Rechazados.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cheques Rechazados", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_CHE_RECHAZADOS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

#PROCESO DEUDORES_SF TXT
    pdef = ProcessDefinition("DEUDORES_SF_TXT", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_DEUDORES_SF_2.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)
    #PROCESO DEUDORES_SF DATOS 
    pdef = ProcessDefinition("DEUDORES_SF_DATOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_DEUDORES_SF_DATOS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)
    #PROCESO DEUDORES_SF COMP TXT
    pdef = ProcessDefinition("DEUDORES_SF_COMP_TXT", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_DEUDORES_SF_COMP_TXT.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)
    #PROCESO DEUDORES_SF COMP DATOS 
    pdef = ProcessDefinition("DEUDORES_SF_COMP_DATOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_DEUDORES_SF_COMP.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #Proceso RRII_IERIC_MENSUAL
    #Proceso RRII_IERIC_MENSUAL
    #Proceso RRII_IERIC_MENSUAL
    pdef = ProcessDefinition("RRII - IERIC Mensual", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_IERIC_MENSUAL.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)
    
    #Proceso RRII_IERIC_ANUAL
    #Proceso RRII_IERIC_ANUAL
    pdef = ProcessDefinition("RRII - IERIC Anual", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_IERIC_ANUAL.ktr")
    pdef.addParameter("anio",3,"yyyy")
    pdefs.addProcess(pdef)

    
    #Proceso RRII_INFORME_LELIQ
    #Proceso RRII_INFORME_LELIQ
    pdef = ProcessDefinition("RRII - Informe LELIQ", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_INFORME_LELIQ.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    
    
    # PROCESO: Caja Forense
    pdef = ProcessDefinition("Reporte caja forense", "topsystems.reports.reportesbasicos.ReporteGenerico")
    pdef.addConstant("FILE_NAME","RepCajaForense");
    pdef.addConstant("OUPUT_TYPE","5");
    #pdef.addConstant("OUTPUT_PATH","C:\\Users\\nahuel\\Documents\\");
    pdefs.addProcess(pdef)   
    
    pdef = ProcessDefinition("Kettle Caja forense inicial", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "CAJA_FORENSE.ktr")
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Kettle Caja forense final", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "CAJA_FORENSE2.ktr")
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Kettle Caja forense reversa", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "CAJA_FORENSE_REVERSA.ktr")
    pdefs.addProcess(pdef)

    # Proceso: Reporte cuentas vista a inmovilizar
    pdef = ProcessDefinition("Reporte cv inmovilizar", "topsystems.reports.reportesbasicos.ReporteGenerico")
    pdef.addConstant("FILE_NAME","RepCuentasVistasAInmovilizar");
    pdef.addConstant("OUPUT_TYPE","5");
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Kettle cv inmovilizar", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "VTA_SALDO_A_INMOVILIZAR.ktr")
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Kettle cv inmovilizar final", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "VTA_SALDO_INMOVILIZAR_FINAL.ktr")
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Kettle cv inmovilizar reversa", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "VTA_SALDO_INMOVILIZAR_REVERSA.ktr")
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Kettle cv inmovilizar mail", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "VTA_SALDO_INMOVILIZAR_MAIL.ktr")
    pdefs.addProcess(pdef)
    
    # Proceso: Reporte Ley Impuesto_25413
    pdef = ProcessDefinition("Kettle Reporte Ley Impuesto_25413", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "Ley_Impuesto_25413.kjb")
    pdef.addParameter("TipoCuenta",3);
    pdef.addParameter("FechaDesde",3,"M/dd/yyyy");
    pdef.addParameter("FechaHasta",3,"M/dd/yyyy");
    pdefs.addProcess(pdef)

    # Proceso: SP Mail por cargos pendientes - CORREOS_A_ENVIAR a partir de CI_SOLICITUD
    pdef = ProcessDefinition("Notificacion por Cargos Pendientes", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_MAILS_CARGOS_PENDIENTES");
    pdefs.addProcess(pdef)

    # Comision Mantenimiento Banca Empresa
    pdef = ProcessDefinition("Comision Mantenimiento Banca Empresa", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","4570");
    pdef.addConstant("eventList","1101");
    pdef.addConstant("jtsOidFieldNumber","45700");
    pdef.addConstant("monedaFieldNumber","45701");
    pdef.addConstant("saldoActualFieldNumber","45702");
    pdef.addConstant("nroOperacion","8668");
    pdef.addConstant("descripcion","Comision Mantenimiento Banca Empresa");
    pdef.addConstant("reports","500");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("readCliente","true");
    pdefs.addProcess(pdef)
    
    # Pos Extorno
    pdef = ProcessDefinition("POS Extorno", "topsystems.automaticprocess.extorno.ExtornProcess")
    pdef.addParameter("FECHA_VALOR",4,"dd/MM/yyyy",0);
    pdef.addParameter("esAjusteParam",3,"",0);
    pdef.addParameter("WHERE_SENTENCIA",3,"",1);
    pdef.addParameter("CANTIDAD_REGISTROS",1,"",1);
    pdef.addParameter("sucursalProceso",1,"",0);
    pdef.addConstant("validaExtornoSobregiro","false");
    pdefs.addProcess(pdef)
    
    # tlf Extorno - Kettle
    pdef = ProcessDefinition("TLF Extorno Kettle", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_EXTORNOS_TLF.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
    
    # tlf Extorno - Desasistida
    pdef = ProcessDefinition("TLF Extorno Desasistida", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.tlfExtornosConciliacion");
    pdefs.addProcess(pdef)

    # Proceso: ITF_PRACTICO1
    pdef = ProcessDefinition("Kettle_ITF_PRACTICO1", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PRACTICO1.ktr")
    pdefs.addProcess(pdef)

    # Proceso: ITF_PRACTICO2
    pdef = ProcessDefinition("Kettle_ITF_PRACTICO2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PRACTICO2.ktr")
    pdefs.addProcess(pdef)

    # Proceso: ITF_PRACTICO3
    pdef = ProcessDefinition("Kettle_ITF_PRACTICO3", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PRACTICO3_ClienteTipoN.ktr")
    pdefs.addProcess(pdef)

    #  Operacion 1501 - Altas masivas
    pdef = ProcessDefinition("Rechazo de cheques sin fondos", "topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(3684);    
    pdefs.addProcess(pdef)    

    return


def addMoreProcesses4(pdefs):
    pdef = ProcessDefinition("Migracion Detalle Calculo IOF Complementario","topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorMigracionDetalleCalculoIofComplementario");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerMigracionCalculoIofComplementario");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdefs.addProcess(pdef)

    # PROCESO: Rehacer Saldos Diarios Contabilidad
    pdef = ProcessDefinition("Rehacer Saldos Diarios Contabilidad", "topsystems.automaticprocess.processmanager.WorkManager");
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorRehacerConSaldosDiarios");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerRehacerConSaldosDiarios");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","200");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("deleteSentence","DELETE FROM CON_SALDOS_DIARIOS WHERE FECHA BETWEEN ? AND ? AND RUBRO = ? AND SUCURSAL = ? AND MONEDA = ? AND CENTROCOSTO = ? AND EMPRESA = ? AND (SUCURSAL_EMPRESA = ? OR ? = -1 ) AND TIPOLIBRO = ?");
    pdef.addConstant("guardarConError","false");
    pdef.addConstant("GENERA_FERIADOS","false");
    pdef.addConstant("corregirSaldoAjustadoMN","false");
    pdef.addParameter("fechaInicio",4,"dd/MM/yyyy",1);
    pdef.addParameter("fechaFin",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)

    # Ajuste por inflacion solo calculo
    # Ajuste por inflacion solo calculo
    pdef = ProcessDefinition("Contabilizo ajuste por inflacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDContabAjPorInflacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWContabAjPorInflacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=RHContabAjPorInflacion");
    pdef.addConstant("rangoCommit","200");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("campoAjusteInflacion","ajusteinflacion");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("INDICEACTUAL","MES_ACTUAL");
    pdefs.addProcess(pdef)


    # Ajuste por inflacion solo calculo
    # Ajuste por inflacion solo calculo
    pdef = ProcessDefinition("Calculo Ajuste por Inflacion", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCalculoAjustePorInflacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCalculoAjustePorInflacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=RHCalculoAjustePorInflacion");
    pdef.addConstant("rangoCommit","200");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("INDICEACTUAL","MES_ACTUAL");
    pdefs.addProcess(pdef)

    # Ajuste por inflacion reporte 
    pdef = ProcessDefinition("Reporte Ajuste por Inlfacion","topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_CO_REPO_HIS_AJUSTE_X_INFLACION");
    pdef.addConstant("ParamtersPositions", "FechaParametro,P;");
    pdef.addParameter("FechaParametro",4,"dd/MM/yyyy",0);
    pdef = ProcessDefinition("Reporte Ajuste por Inlfacion","topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_CO_REPO_HIS_AJUSTE_X_INFLACION");
    pdef.addConstant("ParamtersPositions", "FechaParametro,P;");
    pdef.addParameter("FechaParametro",4,"dd/MM/yyyy",0);
    pdefs.addProcess(pdef)

    # Borrado tabla historico ajuste
    pdef = ProcessDefinition("Borrado tabla CO_HIS_AJUSTE_X_INFLACION", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDBorradoDatosAjustePorInflacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBorradoDatosPorVO");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("queryTablaDepurar","query.HistoricoAjusteXInflacion");
    pdef.addConstant("VoName","core.vo_HistoricoAjustes");
    pdefs.addProcess(pdef)
  
    # ITF IB BASECUENTA
    pdef = ProcessDefinition("IB BASECUENTAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_IB_BASECUENTAS.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3)
    pdef.addConstant("ID_MASTER", "119");
    pdefs.addProcess(pdef)
    
    # Adintar Credicom 1.3.1
    pdef = ProcessDefinition("Adintar Credicom", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "109");
    pdef.addParameter("archivo",3,"NombreArchivo.Extension",1);
    pdefs.addProcess(pdef)
    
    # Adintar Credicom Reporte
    pdef = ProcessDefinition("Adintar Credicom Reporte", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "110");
    pdefs.addProcess(pdef)


    # ITF COELSA Cheques Presentados Enviados 2.8.22
    pdef = ProcessDefinition("ITF COELSA CHEQUES TERCEROS A ENVIAR", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "87")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CHEQUES_TERCEROS_SALIDA.kjb")
    pdefs.addProcess(pdef)
    
    # Actualiza Maestro Transferencias Norix - Ndesx

    pdef = ProcessDefinition("ACT_MAESTRO_TR_NX", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_NORIX_DESX_MAESTRO_TR.kjb")
    pdef.addParameter("PERIODO", 4, "Ingrese fecha para obtener novedades de transferencias", 1)
    pdefs.addProcess(pdef)

    # ITF ARCHIVO CONTROL IMAGENES CHEQUES PRESENTADOS - 2.8.39
    pdef = ProcessDefinition("GENERACION ARCHIVO CHEQUES PRESENTADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLE_GENERACIONARCHIVOIMG.kjb")
    pdef.addConstant("ID_MASTER", "84");
    pdefs.addProcess(pdef)
    
    # ITF GENERACION ARCHIVO ZIP CHEQUES PRESENTADOS - 2.8.40
    pdef = ProcessDefinition("GENERACION ARCHIVO ZIP CHEQUES PRESENTADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLE_GENEROZIPIMG.kjb")
    pdef.addConstant("ID_MASTER", "85");
    pdefs.addProcess(pdef)
    
    # ITF GENERACION ARCHIVO ZIP CHEQUES PRESENTADOS - 2.8.40_BIS
    pdef = ProcessDefinition("GENERACION ARCHIVO ZIP TOTAL CHEQUES PRESENTADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLE_GENEROZIPIMG_TOTAL.kjb")
    pdef.addConstant("ID_MASTER", "333");
    pdefs.addProcess(pdef)

    # 2.8.68 CLS - EC_CANJE
    pdef = ProcessDefinition("CLS - EC_CANJE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ECHEQ_CANJE.kjb")
    pdef.addConstant("ID_MASTER", "303")
    pdefs.addProcess(pdef)
    
	#ITF TANGO CONTABI 1.18
    pdef = ProcessDefinition("ITF TANGO ASIENTOS CONTABLES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "163");
    pdef.addParameter("archivo",3,"Nombre del Archivo",1);
    pdefs.addProcess(pdef)
	
	#ITF TANGO CONTABI 1.18 reporte
    pdef = ProcessDefinition("ITF TANGO ASIENTOS CONTABLES REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "164");
    pdefs.addProcess(pdef)
    
    #ITF AD CONTABI 1.3.2
    pdef = ProcessDefinition("ITF ADINTAR ASIENTOS CONTABLES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "145");
    pdef.addParameter("archivo",3,"Nombre del Archivo",1);
    pdefs.addProcess(pdef)
	
	#ITF AD CONTABI 1.3.2 reporte
    pdef = ProcessDefinition("ITF ADINTAR ASIENTOS CONTABLES REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "149");
    pdefs.addProcess(pdef)
    
	#ITF AD CONTABI 1.37.1
    pdef = ProcessDefinition("ITF DEBITIA", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "317");
    pdefs.addProcess(pdef)
    
	#ITF AD CONTABI 1.37.1_A
    pdef = ProcessDefinition("ITF DEBITIA MARCA ESTADO CLIENTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "320");
    pdefs.addProcess(pdef)
    
    #ITF INTERBANKING CBU 1.28.1
    pdef = ProcessDefinition("IB CBU", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_IB_CBU.kjb");
    pdef.addParameter("REFRESH_TOTAL", 3, "Ingrese 'S' para full refresh o 'N' para update", 1)
    pdefs.addProcess(pdef)

    # 1.28.12 IB –ECHEQ DEPOSITO
    pdef = ProcessDefinition("ECHEQ_IB_EXTRACT_DEPOSITO", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ECHEQ_EXTRACT_DEPOSITO_IB.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    
    #ITF SIRCREB PADRON DEVOLUCIONES
    pdef = ProcessDefinition("SIRCREB PADRON DEVOLUCIONES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "156");
    pdef.addParameter("archivo",3,"Nombre archivo",1);
    pdefs.addProcess(pdef)
	
    #SIRCREB PADRON DEVOLUCIONES REPORTE
    pdef = ProcessDefinition("SIRCREB PADRON DEVOLUCIONES REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "157");
    pdefs.addProcess(pdef)
    
	#ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.8
    pdef = ProcessDefinition("DEBITOS DIRECTOS PRESENTADOS EMITIDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DEB_DIRECTOS_PRESENTADOS_EMITIDOS.kjb");
    pdef.addConstant("ID_MASTER", "128");
    pdefs.addProcess(pdef)

    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.9
    pdef = ProcessDefinition("DEBITOS DIRECTOS PRESENTADOS RECIBIDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DEB_DIRECTOS_PRESENTADOS_RECIBIDOS.kjb");
    pdef.addConstant("ID_MASTER", "104");
    pdef.addParameter("NOMBREARCHIVO",3,"",1);
    pdefs.addProcess(pdef)

    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.10
    pdef = ProcessDefinition("DEBITOS DIRECTOS RECHAZADOS RECIBIDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DEB_DIRECTOS_RECHAZADOS_RECIBIDOS.kjb");
    pdef.addConstant("ID_MASTER", "105");
    pdef.addParameter("NOMBREARCHIVO",3,"",1);
    pdefs.addProcess(pdef)
    
    # ITF COELSA TRANSFERENCIAS REJECTADAS PESOS 2.8.53
    pdef = ProcessDefinition("Transf pres en pesos reject", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_TRANSF_PRESENTADAS_REJECT_PESOS.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre del archivo con extension", 1)
    pdef.addConstant("ID_MASTER", "112");
    pdefs.addProcess(pdef)

    # ITF COELSA TRANSFERENCIAS REJECTADAS DOLARES 2.8.54
    pdef = ProcessDefinition("Transf pres en dolares reject", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_TRANSF_PRESENTADAS_REJECT_PESOS.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre del archivo con extension", 1)
    pdef.addConstant("ID_MASTER", "112");
    pdefs.addProcess(pdef)
    
    #ITF DEBITOS DIRECTOS RECHAZADOS ENVIADOS 2.8.11
    pdef = ProcessDefinition("DEBITOS DIRECTOS RECHAZADOS ENVIADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_DRP.kjb");
    pdef.addConstant("ID_MASTER", "107");
    pdefs.addProcess(pdef)
    
    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.8_V2
    pdef = ProcessDefinition("DEBITOS DIRECTOS PRESENTADOS EMITIDOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DEB_DIRECTOS_PRESENTADOS_EMITIDOS_V2.kjb");
    pdef.addConstant("ID_MASTER", "329");
    pdefs.addProcess(pdef)

    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.9_V2
    pdef = ProcessDefinition("DEBITOS DIRECTOS PRESENTADOS RECIBIDOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DEB_DIRECTOS_PRESENTADOS_RECIBIDOS_v2.kjb");
    pdef.addConstant("ID_MASTER", "330");
    pdef.addParameter("NOMBREARCHIVO",3,"",1);
    pdefs.addProcess(pdef)

    #ITF DEBITOS DIRECTOS PRSENTADOS RECIBIDOS 2.8.10_V2
    pdef = ProcessDefinition("DEBITOS DIRECTOS RECHAZADOS RECIBIDOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DEB_DIRECTOS_RECHAZADOS_RECIBIDOS_v2.kjb");
    pdef.addConstant("ID_MASTER", "331");
    pdef.addParameter("NOMBREARCHIVO",3,"",1);
    pdefs.addProcess(pdef)
    
    #ITF DEBITOS DIRECTOS RECHAZADOS ENVIADOS 2.8.11_V2
    pdef = ProcessDefinition("DEBITOS DIRECTOS RECHAZADOS ENVIADOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_DRP_v2.kjb");
    pdef.addConstant("ID_MASTER", "332");
    pdefs.addProcess(pdef)
    
    # TRANSFERENCIA MINORISTA RECIBIDAS 2.8.14
    pdef = ProcessDefinition("TRANSFERENCIA MINORISTA RECIBIDAS PESOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS.kjb")
    pdef.addConstant("ID_MASTER", "222");
    pdef.addConstant("MONEDA_IN", "0");
    pdef.addConstant("CODREGISTRO_IN", "CTX");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# SUELDOS PRESENTADOS RECIBIDOS PESOS 2.8.18
    pdef = ProcessDefinition("SUELDOS PRESENTADOS RECIBIDOS PESOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS.kjb")
    pdef.addConstant("ID_MASTER", "222");
    pdef.addConstant("MONEDA_IN", "0");
    pdef.addConstant("CODREGISTRO_IN", "CCD");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# TRANSFERENCIA MINORISTA PRESENTADAS 2.8.13
    pdef = ProcessDefinition("TRANSFERENCIA MINORISTA PRESENTADAS PESOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_PRESENTADAS.kjb")
    pdef.addConstant("ID_MASTER", "224");
    pdefs.addProcess(pdef)
	
	# TRANSFERENCIA MINORISTA RECIBIDAS 2.8.16
    pdef = ProcessDefinition("TRANSFERENCIA MINORISTA RECIBIDAS DOLARES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS.kjb")
    pdef.addConstant("ID_MASTER", "222");
    pdef.addConstant("MONEDA_IN", "1");
    pdef.addConstant("CODREGISTRO_IN", "CTX");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
    
    # Proceso Cobra si tiene saldo
    pdef = ProcessDefinition("Cobra si tiene Saldo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.cobraSiTieneSaldo");
    pdefs.addProcess(pdef)

    # Proceso de Renovacion Subsidios
    pdef = ProcessDefinition("Renovacion Subsidios",     "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_SUB_RENOVACION");
    pdefs.addProcess(pdef)

    # RRII - Interfaz contable
    pdef = ProcessDefinition("RRII - Interfaz Contable", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_INTERFAZ_CONTABLE.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

	# RRII - Medicion LCR
    pdef = ProcessDefinition("RRII - Medicion LCR", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_MEDICION_LCR_JOB.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    # RRII - Ratio LCR
    pdef = ProcessDefinition("RRII - RATIO LCR", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_RATIO_LIQ.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII Datos cuentas TC
    pdef = ProcessDefinition("RRII Datos cuentas TC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_DATOSTC_EMITIDAS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdef.addParameter("rectificativa",3,"N/R")
    pdefs.addProcess(pdef)
    
    #RRII Tasas cuentas TC
    pdef = ProcessDefinition("RRII Tasas cuentas TC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_TASASTC_EMITIDAS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdef.addParameter("rectificativa",3,"N/R")
    pdefs.addProcess(pdef)

    #RRII Cantidad de tarjetas de credito
    pdef = ProcessDefinition("RRII Cantidad Tarjetas de credito", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_CANTIDADTC_EMITIDAS.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdef.addParameter("rectificativa",3,"N/R")
    pdefs.addProcess(pdef)

    #RRII SIRCREB
    #RRII SIRCREB
    pdef = ProcessDefinition("RRII - SIRCREB", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_SIRCREB.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdef.addParameter("procesaExclusiones",3,"S/N")
    pdefs.addProcess(pdef)

    #RRII CREDEB
    #RRII CREDEB
    pdef = ProcessDefinition("RRII - CREDEB", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_CREDEB.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII IIBB CORRIENTES DECENAL
    pdef = ProcessDefinition("RRII - IIBB CORRIENTES DECENAL", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_IIBB_CORRIENTES_DECENAL.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII IIBB CORRIENTES MENSUAL
    pdef = ProcessDefinition("RRII - IIBB CORRIENTES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_IIBB_CORRIENTES.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII SELLOS CHACO
    pdef = ProcessDefinition("RRII - SELLOS CHACO", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_SELLOS_CHACO.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII SELLOS CABA
    pdef = ProcessDefinition("RRII - SELLOS CABA", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_SELLOS_CABA.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII CREDEB SEMANAL
    #RRII CREDEB SEMANAL
    pdef = ProcessDefinition("RRII - CREDEB SEMANAL", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_CREDEB_SEMANAL.kjb")
    pdef.addParameter("fechaDesde",3,"dd/MM/yyyy")
    pdef.addParameter("fechaHasta",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII CREDEB DEVOLUCIONES
    #RRII CREDEB DEVOLUCIONES
    pdef = ProcessDefinition("RRII - CREDEB DEVOLUCIONES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_CREDEB_DEV.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII CREDEB EXENTOS
    #RRII CREDEB EXENTOS
    pdef = ProcessDefinition("RRII - CREDEB EXENTOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_CREDEB_EXENTOS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII IVA VENTAS
    pdef = ProcessDefinition("RRII - IVA Ventas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_IVA_VENTAS.kjb")
    pdef.addParameter("fechaDesde",3,"dd/MM/yyyy")
    pdef.addParameter("fechaHasta",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII IVA COMPRAS
    pdef = ProcessDefinition("RRII - IVA Compras", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_IVA_COMPRAS.kjb")
    pdef.addParameter("fechaDesde",3,"dd/MM/yyyy")
    pdef.addParameter("fechaHasta",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #RRII Informe tarjetas de credito
    pdef = ProcessDefinition("RRII Informe tarjetas de credito", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_TARJETAS_EMIT.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #Proceso Gap 08 RRII Regimen de Transparencia
    pdef = ProcessDefinition("RRII - Regimen de Transparencia - Apartado C", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_REGIMEN_TRANSPARENCIA_C.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    #Proceso Gap 08 RRII Regimen de Transparencia
    pdef = ProcessDefinition("RRII - Regimen de Transparencia - Apartado A", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_REGIMEN_TRANSPARENCIA_A.ktr")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)

    # Cierre de cuentas automático
    pdef = ProcessDefinition("CierreCtaAutomatico","topsystems.processmgr.operation.OperationProcess")
    pdef.addOperationNumber(3440);
    pdefs.addProcess(pdef)

    # MIG_CASTIGADORTARJETERO
    pdef = ProcessDefinition("MIG Castigador Tarjetero", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_CASTIGADORTARJETERO")
    pdefs.addProcess(pdef)
    

    # PROCESO: CRE - MIGRACION IOF COMPLEMENTARIO
    pdef = ProcessDefinition("Migracion de saldos al nuevo Modelo IOF Complementario", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorMigracionIofComplementario");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerMigracionIofComplementario");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addParameter("SALDO_JTS_OID",2,"",0);
    pdefs.addProcess(pdef)

    #Proceso para RRII Padrón Modificaciones
    pdef = ProcessDefinition("RRII - PADRON - MODIFICADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RRII_PADRON_modificados.ktr")
    pdef.addParameter("mesAnio",3,"MM/yyyy")
    pdef.addParameter("rectificativa",3,"N/R")
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Genera IVA Financiado", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorGeneracionIVAFinanciado");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerGeneracionIVAFinanciado");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    # PROCESO: Procesar Cheques Descontados
    pdef = ProcessDefinition("Procesar Cheques Descontados", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("grupo_operacion","1");
    pdefs.addProcess(pdef)

    # PROCESO: Caida de Cheques Propios al Cobro
    pdef = ProcessDefinition("Caida de Cheques Propio al Cobro", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.caidaChequesPropiosAlCobro");
    pdefs.addProcess(pdef)

# -------------------------------------------------------------------------------------------------------------------- #
    
#                                                 PROCESOS INTERFACES                                                         #
    
# -------------------------------------------------------------------------------------------------------------------- #
    # Disparador Interfaces Kettle
    pdef = ProcessDefinition("Kettle - Disparador de Interfaces", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "ITF_TRIGGER.kjb");
    pdef.addParameter("PTICKET",1,"",1);
    pdefs.addProcess(pdef)


    #ITF Procesar Padron PADFYJ (BCRA)
    pdef = ProcessDefinition("Kettle-BCRA_PADFYJ", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BCRA_PADFYJ.kjb")
    pdef.addParameter("NOMBREARCHIVO",3,"ARCHIVO.EXTENSION",1)
    pdefs.addProcess(pdef)
    
    #ITF Procesar Padron  PUCA (AFIP)
    pdef = ProcessDefinition("Kettle-AFIP_PUCA", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "24");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    pdefs.addProcess(pdef)
    
    # ANSES NOVEDADES – 2.4.4
    pdef = ProcessDefinition("ANSES NOVEDADES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ANSES_NOVEDADES_MAIN_JOB.kjb")
    pdef.addParameter("NOMBRE_ARCHIVO", 3, "Nombre del Archivo a procesar con extension", 1)
    pdefs.addProcess(pdef)

    # 2.6.10 ITF BCRA NOVCHE RV
    pdef = ProcessDefinition("ITF_BCRA_NOVCHE_RV", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "13");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    pdefs.addProcess(pdef)  
    
    #ITF AGIP - PADRON - 2.2.2
    pdef = ProcessDefinition("AGIP Padron", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AGIP_PADRON.kjb")
    pdef.addConstant("ID_MASTER", "122")
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    # pdef.addParameter("PERIODO",3,"Periodo a procesar (MMAAAA)",1)
    # pdef.addParameter("REPROCESO",3,"Reproceso (S/N)",1)
    pdefs.addProcess(pdef)
    
    #ITF - AMCO AC 2.3.1
    pdef = ProcessDefinition("ITF_AMCO_AC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "233");
    pdefs.addProcess(pdef)

    #ITF - AMCO CC 2.3.2
    pdef = ProcessDefinition("ITF_AMCO_CC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "234");
    pdefs.addProcess(pdef)

    #ITF - AMCO ADHESIONES 2.3.7
    pdef = ProcessDefinition("ITF_AMCO_ADHESIONES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "243");
    pdefs.addProcess(pdef)

    #ITF - AMCO RESUMENES AC 2.3.8
    pdef = ProcessDefinition("ITF_AMCO_RESUMENES_AC_MENSUAL", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "240");
    pdef.addConstant("PERIODO", "M");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("ITF_AMCO_RESUMENES_AC_CUATRIMESTRAL", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "240");
    pdef.addConstant("PERIODO", "C");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("ITF_AMCO_RESUMENES_AC_SEMESTRAL", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "240");
    pdef.addConstant("PERIODO", "Z");
    pdefs.addProcess(pdef)

    #ITF - AMCO RESUMENES CC 2.3.8
    pdef = ProcessDefinition("ITF_AMCO_RESUMENES_CC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "241");    
    pdef.addConstant("PERIODO", "M");
    pdefs.addProcess(pdef)

    #ITF - AMCO ESPECIALES AC 2.3.9
    pdef = ProcessDefinition("ITF_AMCO_ESPECIALES_AC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "235");
    pdefs.addProcess(pdef)

    #ITF - AMCO ESPECIALES CC 2.3.10
    pdef = ProcessDefinition("ITF_AMCO_ESPECIALES_CC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "236");
    pdefs.addProcess(pdef)
	#ITF AFIP IGARG830 2.1.4
    pdef = ProcessDefinition("ITF_AFIP_IGARG830", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "139");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    #pdef.addParameter("PERIODO",4,"Periodo a procesar",1);
    #pdef.addParameter("REPROCESO",3,"Reproceso N/S",1);
    pdefs.addProcess(pdef)
    
    #ITF AFIP ECOM-SSMPCPR152 2.12.10
    pdef = ProcessDefinition("ITF_ECOM_SSMPCPR152", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "225");
    pdefs.addProcess(pdef)
    
    #ITF AFIP ECOM-SSMPCPR153 2.12.11
    pdef = ProcessDefinition("ITF_ECOM_SSMPCPR153", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "231");
    pdefs.addProcess(pdef)
    
    #ITF AFIP IGARG2681 2.1.3
    pdef = ProcessDefinition("ITF_AFIP_IGARG2681", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "143");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    #pdef.addParameter("REPROCESO",3,"Reproceso N/S",1);
    pdefs.addProcess(pdef)
    
    #ITF AFIP IVARG18 2.1.7
    pdef = ProcessDefinition("ITF_AFIP_IVARG18", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "130");
    pdef.addParameter("archivo",3,"Nombre del Archivo",1);
    pdefs.addProcess(pdef)   

	#ITF AFIP IVARG17 2.1.6
    pdef = ProcessDefinition("ITF_AFIP_IVARG17", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "132");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    #pdef.addParameter("PERIODO",4,"Periodo a procesar",1);    
    pdefs.addProcess(pdef)    

    #ITF - AGIP RENDICION 2.2.4
    pdef = ProcessDefinition("ITF_AGIP_RENDICION", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AGIP_RENDICION.kjb")
    pdef.addParameter("Periodo",3,"Periodo YYYYMM",1);
    pdef.addParameter("Reproceso",3,"Reproceso N/S",1);
    pdefs.addProcess(pdef)

    #ITF - AFIP CREDEBPAD 2.1.15
    pdef = ProcessDefinition("ITF_AFIP_CREDEBPAD", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "223");
    pdef.addParameter("ARCHIVO",3,"Nombre del Archivo",1);
    pdef.addParameter("FORZADO",3,"Forzado N/S",1);
    pdefs.addProcess(pdef)

    #ITF - AFIP CREDEBPAD 2.1.14
    pdef = ProcessDefinition("ITF_AFIP_CREDEBPAD_WS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "230");
    pdefs.addProcess(pdef)

    # ITF AFIP - IVASICORER 2.1.13
    pdef = ProcessDefinition("AFIP_IVASICORER", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AFIP_IVASICORER.kjb")
    pdef.addConstant("ID_MASTER", "12")
    pdef.addParameter("fechaDesde",3,"DD/MM/YYYY")
    pdef.addParameter("fechaHasta",3,"DD/MM/YYYY") 
    pdefs.addProcess(pdef)

   #ITF Movemos reportes PDF al attach del email
    pdef = ProcessDefinition("Adjunto de Correo", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_GENERA_ADJUNTO_MAIL.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
   #GRL Movemos reportes PDF al attach del email
    pdef = ProcessDefinition("Mueve Adjunto de Correo", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "GRL_MUEVE_ADJUNTO_MAIL.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
    #ITF Link Movimientos Conformados 
    pdef = ProcessDefinition("Movimientos Conformados", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LINK_MOVCONFORMADOS.kjb")
    pdef.addParameter("fecha",3,"yyyy-MM-dd")
    pdefs.addProcess(pdef)
    #ITF Link Solicitudes de actualizacion de Base SOAT
    pdef = ProcessDefinition("Solicitudes Base SOAT", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOLICITUDES_LINK.kjb")
    pdef.addParameter("fecha",3,"yyyy-MM-dd")
    pdefs.addProcess(pdef)    
    #ITF Generamos Token para los WS
    pdef = ProcessDefinition("Genero Token", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AUTH.ktr")
    pdefs.addProcess(pdef)
    #ITF Generamos Token para los WS internos
    pdef = ProcessDefinition("Genero Token Interno", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AUTH_INTERNO.kjb")
    pdefs.addProcess(pdef)
    #ITF Prueba kettle
    pdef = ProcessDefinition("LOAD_CONVENIO", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LOAD_CONVENIO.kjb")
    pdef.addParameter("PATH",3,"T:/Bibliotecas/Desarrollo/NBCH_SQL/KETTLE/FILE_INPUT",1);
    pdefs.addProcess(pdef)

    #ITF LINK TRK FULL - REFRESH
    pdef = ProcessDefinition("ITF LINK TRK FULL O REFRESH", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LINK_TRK.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdef.addParameter("TIPO",3)
    pdef.addParameter("TICKET", 1)
    pdefs.addProcess(pdef)

    # ITF COELSA FERIADOS
    pdef = ProcessDefinition("COELSA FERIADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_FERIADOS.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# ITF COELSA DPF DOLARES PRESENTADOS RECIBIDOS
    pdef = ProcessDefinition("COELSA DPF DOLARES PRESENTADOS RECIBIDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DPF_DOLARES_PROPIOS_RECIBIDOS.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdef.addParameter("TICKET",1)
    pdefs.addProcess(pdef)

	# ITF COELSA CHEQUES RECHAZADOS RECIBIDOS
    pdef = ProcessDefinition("COELSA CHEQUES RECHAZADOS RECIBIDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CHEQUES_RECHAZADOS_RECIBIDOS.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# ITF COELSA PLAZO FIJO PRESENTADOS DOLARES
    pdef = ProcessDefinition("COELSA PLAZO FIJO PRESENTADOS DOLARES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_PLAZO_FIJO_PRESENTADOS_DOLARES.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# ITF COELSA PLAZO FIJO RECHAZADOS DOLARES
    pdef = ProcessDefinition("COELSA PLAZO FIJO RECHAZADOS DOLARES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_PLAZO_FIJO_RECHAZADOS_DOLARES.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# ITF COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS PESOS
    pdef = ProcessDefinition("COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS PESOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_TRANS_MINORIST_RECIB_PESOS.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# ITF COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS DOLARES
    pdef = ProcessDefinition("COELSA TRANSFERENCIAS MINORISTAS RECIBIDAS DOLARES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_TRANS_MINORIST_RECIB_DOLARES.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
	# ITF COELSA TRANSFERENCIAS MINORISTAS RECHAZADAS RECIBIDAS
    pdef = ProcessDefinition("COELSA TRANSFERENCIAS MINORISTAS RECHAZADAS RECIBIDAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_TRANS_MINORIST_RECHAZ_RECIB.kjb")
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cheques rechazados por depositaria", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ChequeRechazadoDepositaria");
    pdefs.addProcess(pdef)

    # Clearing Validacion Cheques Entrantes
    pdef = ProcessDefinition("Clearing Validacion Cheques Entrantes", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CHEQUES_VALIDACION.kjb")
    pdef.addConstant("ID_MASTER", "99");
    pdefs.addProcess(pdef)
    
    # ITF AOJ BASE
    pdef = ProcessDefinition("AOJ BASE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AOJ_BASE.kjb")
    pdef.addParameter("Fecha",4,"dd/MM/yyyy",0)
    pdefs.addProcess(pdef)
    
    # ITF COELSA CHEQUES PROPIOS RECHAZADOS A ENVIAR 2.8.5
    pdef = ProcessDefinition("COELSA INFORMAR CHEQUES PROPIOS RECHAZADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CHEQUES_PROPIOS_RECHAZADOS.kjb")
    pdef.addConstant("ID_MASTER", "101");
    pdefs.addProcess(pdef)

    # ITF COELSA CHEQUES Y DPF TERCEROS RECHAZADOS 2.8.3
    pdef = ProcessDefinition("ITF COELSA CHEQUES Y DPF TERCEROS RECHAZADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CHEQUES_DPF_TERCEROS_RECHAZADOS.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3)
    pdef.addConstant("ID_MASTER", "96");
    pdefs.addProcess(pdef)
    
	# ITF COELSA DPF DOLARES TERCEROS RECHAZADOS
    pdef = ProcessDefinition("ITF COELSA DPFD TERCEROS RECHAZADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DPFD_RECHAZADOS_RECIBIDOS.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3)
    pdef.addConstant("ID_MASTER", "95");
    pdefs.addProcess(pdef)

    # ITF COELSA DPF PROPIOS RECHAZADOS A ENVIAR 2.8.5
    pdef = ProcessDefinition("COELSA ENVIO DPF PROPIOS RECHAZADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DPF_PROPIOS_RECHAZADOS.kjb")
    pdef.addConstant("ID_MASTER", "100");
    pdefs.addProcess(pdef)

    # ITF COELSA DPF DOLARES TERCEROS A INFORMAR 2.8.6
    pdef = ProcessDefinition("COELSA ENVIO DPF DOLARES TERCEROS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_DPF_DOLARES_TERCEROS_A_INFORMAR.kjb")
    pdef.addConstant("ID_MASTER", "98");
    pdefs.addProcess(pdef)

    # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.15
    pdef = ProcessDefinition("COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_TRANSFERENCIAS_MPD.kjb")
    pdef.addConstant("ID_MASTER", "220");
    pdefs.addProcess(pdef)

   # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.44
    pdef = ProcessDefinition("COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_TRAN_RECH_ENVIADAS.kjb")
    pdef.addConstant("ID_MASTER", "219");
    pdefs.addProcess(pdef)

    # ITF DPFD - Archivo de control de Imágenes Presentados Enviados - 2.8.48
    pdef = ProcessDefinition("GENERACION ARCHIVO DPFD PRESENTADOS ENVIADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLE_DPFD_ARCHIVOIMG.kjb")
    pdef.addConstant("ID_MASTER", "88");
    pdefs.addProcess(pdef)

    # ITF DPFD - Archivo de Imágenes Presentados Enviados - 2.8.49
    pdef = ProcessDefinition("GENERACION ARCHIVO ZIP DPFD PRESENTADOS ENVIADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLE_DPFD_ZIPIMG.kjb")
    pdef.addConstant("ID_MASTER", "89");
    pdefs.addProcess(pdef)
    
    # ITF RCTES PADRON IMPUESTOS 2.21.1
    pdef = ProcessDefinition("Padron impuestos DGR", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_RCTES_PADRON_IMPUESTOS.kjb")
    pdef.addParameter("archivo", 3, "Nombre del archivo con extension", 1)
    # pdef.addParameter("periodo", 3, "Periodo a procesar (MMAAAA)", 1)
    # pdef.addParameter("reproceso", 3,"Reproceso? S/N",1)
    pdef.addConstant("ID_MASTER", "123");
    pdefs.addProcess(pdef)
    

    pdef = ProcessDefinition("Devenga Diferencia Intereses Tasa Efectiva Tasa Mercado", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDevengaDiferenciaIntereses");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDevengaDiferenciaIntereses");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Crea Cronograma Devengado Diferente Tasa Interes", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorCreaCronogramaDevengadoDiferenteTasaInteres");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCreaCronogramaDevengadoDiferenteTasaInteres");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","50");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("campoIntMercado","43581");
    pdefs.addProcess(pdef)
    
    pdef = ProcessDefinition("Actualizar Tam-Empresa", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "ACTUALIZAR_TAMANO_EMPRESA");
    pdefs.addProcess(pdef)

    # Comision Saldos Inmovilizados DPF


    pdef = ProcessDefinition("Cancela DPF UVAUVI con Estado Atraso U", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.CancelarDPFUVAUVI");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cancela DPF TV con Estado Atraso T", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.CancelarDPFTV");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Prueba Desatendida Credito en cuenta", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.prueba");
    pdefs.addProcess(pdef)

    # COBRANZA DEBITOS AUTOMATICOS
    pdef = ProcessDefinition("Cobranza debitos automaticos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.cobranzaDebitoAutomatico");
    pdefs.addProcess(pdef)

    # Proceso Alta Inhabilitacion INAE
    pdef = ProcessDefinition("Alta Inhabilitacion INAE", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.altaInhabilitacionInae");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Alta Maestro Fallecido", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.altaMaestroFallecido");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Baja Maestro Fallecido", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.bajaMaestroFallecido");
    pdefs.addProcess(pdef)

    # PROCESO: Actualiza Riesgo Dolarizado
    pdef = ProcessDefinition("Actualiza Riesgo Dolarizado", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_RIESGOSENDOL")
    pdefs.addProcess(pdef)

    # PROCESO: Actualiza Cliente Dolarizado
    pdef = ProcessDefinition("Actualiza Cliente Dolarizado", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_RIESGOCLIENTEENDOL")
    pdefs.addProcess(pdef)

    # PROCESO: Cobro Comisiones de Garantias Otorgadas
    pdef = ProcessDefinition("Cobro Comisiones de Garantias Otorgadas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.cobroGarantiasOtorgadas");
    pdefs.addProcess(pdef)

    # PROCESO: Aviso de Vencimiento de Garantia
    pdef = ProcessDefinition("Aviso de Vencimiento de Garantia", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.avisoVencimientoGarantia");
    pdefs.addProcess(pdef)
    
    # PROCESO: Vencimiento de Fianza
    pdef = ProcessDefinition("Vencimiento de Fianza", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.cancelacionPrenda");
    pdefs.addProcess(pdef)
    
    # PROCESO: Caida Automatica de Solicitudes de Asistencias
    pdef = ProcessDefinition("Caida Automatica de Solicitudes de Asistencias", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.bajaSolicitudes");
    pdefs.addProcess(pdef)
    
    # Proceso de Actualizacion Situacion Sistema Financiero
    pdef = ProcessDefinition("Actualizacion Situacion Sistema Financiero", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_SITUACION_BCRA");
    pdefs.addProcess(pdef)
    
    # Proceso de Actualizacion CENDEU Nuevos Clientes
    pdef = ProcessDefinition("Actualizacion CENDEU Nuevos Clientes", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_BCRA");
    pdefs.addProcess(pdef)    
    
    # Proceso de Perdida de Credito Adicional
    pdef = ProcessDefinition("Perdida de Credito Adicional", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_DESESTIMA_CREDITO_ADICIONAL");
    pdefs.addProcess(pdef)
    
    # Proceso de Asignacion de Credito Adicional
    pdef = ProcessDefinition("Asignacion de Credito Adicional", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_MARCA_CREDITO_ADICIONAL");
    pdefs.addProcess(pdef)
    
    # Proceso de Borrado de discrepancia
    pdef = ProcessDefinition("Borrado de discrepancia", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_LIMPIA_DISCREPANCIA");
    pdefs.addProcess(pdef)
    
    # Proceso de Actualizacion de Discrepancia
    pdef = ProcessDefinition("Actualizacion de Discrepancia", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_DISCREPANCIA");
    pdefs.addProcess(pdef)
    
    # Proceso de Actualizacion detalle de Morosos Ex Entidades
    pdef = ProcessDefinition("Actualizacion detalle de Morosos Ex Entidades", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_MOROSOS");
    pdefs.addProcess(pdef)
    
    # Proceso de Actualizacion detalle de Morosos Ex Entidades nuevos clientes
    pdef = ProcessDefinition("Actualizacion detalle de Morosos Ex Entidades nuevos clientes", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_MOROSOS_NUEVOS");
    pdefs.addProcess(pdef)
    
    # Proceso de Actualizacion Situacion Morosos Ex Entidades
    pdef = ProcessDefinition("Actualizacion Situacion Morosos Ex Entidades", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_MOROSOS_SITUACION");
    pdefs.addProcess(pdef)
    
    # Proceso de Actualizacion Situacion Resultante
    pdef = ProcessDefinition("Actualizacion Situacion Resultante", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_SITUACION_RESULTANTE");
    pdefs.addProcess(pdef)
    
    # Proceso de Borrado de situacion juridica
    pdef = ProcessDefinition("Borrado de situacion juridica", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_LIMPIA_SITUACION_JUDICIAL");
    pdefs.addProcess(pdef)
    
    # Proceso de Imputaci?n situacion juridica
    pdef = ProcessDefinition("Imputacion situacion juridica", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZA_SITUACION_JUDICIAL");
    pdefs.addProcess(pdef)

    # PROCESO: Rechazar Solicitud integrante Juzgado
    pdef = ProcessDefinition("Rechazar Solicitud Integrante Juzgado", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.rechazoSolicitudIntegranteJuzgado");
    pdefs.addProcess(pdef)

    # PROCESO: Rechazar Solicitud Activar Inactivar Causas - DJ
    pdef = ProcessDefinition("Rechazar Solicitud Activar-Inactivar Causa", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.rechazoSolicitudActivarInactivarCausa");
    pdefs.addProcess(pdef)

    # PROCESO : Altas Masivas Actualiza Firma
    pdef = ProcessDefinition("Proceso de Altas Masivas - Actualiza Firma","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "SP_MA_ACTUALIZA_FIRMA");
    pdef.addConstant("ParamtersPositions", "Num_Lote,P;");
    pdef.addParameter("Num_Lote",1,"",1);
    pdefs.addProcess(pdef)

    # PROCESO: Llamada reporte 3301 Asientos sin Cierre
    pdef = ProcessDefinition("3301 - Asientos sin Cierre","topsystems.automaticprocess.basicreport.ReportProcess")
    pdef.addConstant("REPORT","3301");
    pdef.addConstant("REPORTNAME","3301 Asientos sin Cierre.pdf");
    #pdef.addParameter("Fecha Proceso",4,"dd/mm/yyyy");
    pdef.addConstant("DESTINY","3");
    pdefs.addProcess(pdef)

    # PROCESO: Llamada reporte 3327 Libro Diario General
    pdef = ProcessDefinition("3327 - Libro Diario General", "topsystems.reports.reportesbasicos.ReporteGenerico")
    pdef.addConstant("FILE_NAME","3327 - Libro Diario General pdf");
    pdef.addConstant("OUPUT_TYPE","1");
    pdef.addConstant("TOPAZ_BIG_REPORTS_PAGE_SIZE","100000");
    pdef.addParameter("FECHA_DESDE",4,"dd/mm/yyyy",1);
    pdef.addParameter("FECHA_HASTA",4,"dd/mm/yyyy",1);
    pdefs.addProcess(pdef)

    # PROCESO: Llamada reporte 3327 Libro Diario General
    pdef = ProcessDefinition("3327 - Libro Diario General excel", "topsystems.reports.reportesbasicos.ReporteGenerico")
    pdef.addConstant("FILE_NAME","3327 - Libro Diario General planilla");
    pdef.addConstant("OUPUT_TYPE","5");
    pdef.addParameter("FECHA_DESDE",4,"dd/mm/yyyy",1);
    pdef.addParameter("FECHA_HASTA",4,"dd/mm/yyyy",1);
    pdefs.addProcess(pdef)

    # PROCESO: Llamada reporte 3325 Movimientos de Prestamos
    pdef = ProcessDefinition("3325 - Movimientos de Prestamos", "topsystems.reports.reportesbasicos.ReporteGenerico")
    pdef.addConstant("FILE_NAME","3325 - Movimientos de Prestamos");
    pdef.addConstant("OUPUT_TYPE","5");
    pdef.addParameter("SUCURSAL",1);
    pdef.addParameter("FECHA_DESDE",4,"dd/mm/yyyy",1);
    pdef.addParameter("FECHA_HASTA",4,"dd/mm/yyyy",1);
    pdefs.addProcess(pdef)

    # PROCESO: Llamada reporte 3326 - Devengamiento de Intereses
    pdef = ProcessDefinition("3326 - Devengamiento de Intereses", "topsystems.reports.reportesbasicos.ReporteGenerico")
    pdef.addConstant("FILE_NAME","3326 - Devengamiento de Intereses");
    pdef.addConstant("OUPUT_TYPE","5");
    pdef.addParameter("SUCURSAL",1);
    pdef.addParameter("FECHA_DESDE",4,"dd/mm/yyyy",1);
    pdef.addParameter("FECHA_HASTA",4,"dd/mm/yyyy",1);
    pdefs.addProcess(pdef)

    # Proceso de Reseteo de Clasificacion  
    pdef = ProcessDefinition("Prepara Clasificacion", "topsystems.automaticprocess.storedprocedures.SpBasicParameters"  )
    pdef.addConstant("StoreName", "SP_PA_PREPARA_CLASIFICACION");
    pdefs.addProcess(pdef)
    
    # PROCESO: Cliente Novedad Demografica
    pdef = ProcessDefinition("Cliente Novedad Demo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ClienteNovedadDemo");
    pdefs.addProcess(pdef)

    #ITF CAUSAS JUDICIALES - 2.12.17 - KETTLE
    pdef = ProcessDefinition("Causas Judiciales - Validacion de registros", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ALTACAUSAJUDICIAL_CAJAAHORRO.kjb")
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre_Archivo.TXT",1)
    pdef.addParameter("PRUEBA",3,"S/N",1)
    pdefs.addProcess(pdef)
    #ITF CAUSAS JUDICIALES - 2.12.17 - OPERACIÓN TOPAZ DESASISTIDA
    pdef = ProcessDefinition("Causas Judiciales - Alta de cuentas", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","20");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.altaCuentasJudiciales");
    pdefs.addProcess(pdef)
    # INTERFASES: Recepcion pagos TUYA
    pdef = ProcessDefinition("ITF PAGOS TUYA","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PAGOS_TUYA.kjb");
    pdef.addParameter("NOMBREARCHIVO",3,"NOMBRE ARCHIVO",1);
    pdefs.addProcess(pdef)
	
    # Comision seguro sobre saldo deudor
    pdef = ProcessDefinition("Seguro Saldo Deudor", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOverBalance");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOverBalance");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOverBalance");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("descriptor","4356");
    pdef.addConstant("eventList","900");
    pdef.addConstant("jtsOidFieldNumber","43944");
    pdef.addConstant("monedaFieldNumber","43945");
    pdef.addConstant("saldoActualFieldNumber","43946");
    pdef.addConstant("nroOperacion","8680");
    pdef.addConstant("descripcion","Cupo sobregiro");
    pdef.addConstant("reports","500");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef) 
    
    #Agrego registros tabla seguro sobre saldo
    pdef = ProcessDefinition("SP Seguro sobre saldo deudor", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_SEGUROSALDODEUDOR");
    pdefs.addProcess(pdef)
    # PROCESO: Link Maestro Tarjeta Debito
    pdef = ProcessDefinition("Link Maestro Tarjeta Debito", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.tarjetaDebitoLinkMaestro");
    pdefs.addProcess(pdef)
    # PROCESO: Link Maestro Cuenta Tarjeta Debito
    pdef = ProcessDefinition("Link Maestro Cuenta Tarjeta Debito", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.tarjetaDebitoLinkMaestroCuenta");
    pdefs.addProcess(pdef)
    #2.14.1 LK TRX
    pdef = ProcessDefinition("LK TRX", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_TRX.kjb")
    pdef.addParameter("NOMBREARCHIVO",3, "Nombre de archivo con extensión")
    pdef.addParameter("TIPO",3,"F o R") 
    pdefs.addProcess(pdef)

    #INTERFACES: ITF. BEE cuentas y abonados a Banca Empresa - 2.7.6
    pdef = ProcessDefinition("BEE CUENTAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_CUENTAS.kjb");
    pdef.addParameter("NOMBREARCHIVO",3,"Ingrese el nombre del archivo con extensión",1);
    pdefs.addProcess(pdef)
    #ITF BEE - REFTRANSFER 2.7.1
    pdef = ProcessDefinition("BEE REFTRANSFER", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "218");
    pdefs.addProcess(pdef)

    #ITF COMARB - PADRON - 2.9.1
    pdef = ProcessDefinition("COMARB Padron", "topsystems.kettle.processes.KettleProcess")    
    pdef.addConstant("ID_MASTER", "129")
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre del Archivo",1);
    # pdef.addParameter("PERIODO",3,"Periodo a procesar (AAAAMM)",1)
    # pdef.addParameter("REPROCESO",3,"Reproceso (S/N)",1)
    pdefs.addProcess(pdef)

    #ITF TANGO IVA DIGITAL COMPRAS ALICUOTAS 1.18.5
    pdef = ProcessDefinition("Tango iva digital compras alicuotas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TANG_IVACOMALI.kjb")
    pdef.addConstant("ID_MASTER", "135")
    pdef.addParameter("archivo",3,"Nombre_Archivo.TXT",1)
    pdef.addParameter("periodo",1,"ejm. 202301",1)
    pdefs.addProcess(pdef)
    #ITF TANGO IVA DIGITAL COMPRAS COMPROBANTE 1.18.6
    pdef = ProcessDefinition("Tango iva digital compras comprobante", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TANG_IVACOMCOM.kjb")
    pdef.addConstant("ID_MASTER", "137")
    pdef.addParameter("archivo",3,"Nombre_Archivo.TXT",1)
    pdef.addParameter("periodo",1,"ejm. 202301",1)
    pdefs.addProcess(pdef)
    # Proceso de graduacion y grandes exp
    pdef = ProcessDefinition("Analisis de graduacion y grandes exposiciones", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_PA_GRADUACION_FRACCIONAMIENTO");
    pdefs.addProcess(pdef)	
    # INTERFACES: ITF BEE Movimientos conformados - 2.7.4
    pdef = ProcessDefinition("BEE MOVIMIENTOS CONFORMADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "165");
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_MOVIMIENTOS.kjb");
    pdefs.addProcess(pdef)

    #ITF - BEE EXTTRANSFER 2.7.5
    pdef = ProcessDefinition("BEE EXTTRANSFER", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_EXTTRANSFER.kjb")
    pdef.addParameter("ARCHIVO",3,"Nombre archivo",1)
    pdefs.addProcess(pdef)

    #ITF BEE - CURSA TRANSFERENCIAS 2.7.1 - 2.7.5
    pdef = ProcessDefinition("BEE CURSA TRANSFERENCIAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb");
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_CURSADO_TRANSFERENCIAS.kjb");
    pdefs.addProcess(pdef)

    # INTERFACES: ITF BEE TENENCIA_PF - 2.7.7
    pdef = ProcessDefinition("BEE TENENCIA PF", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_TENENCIA_DPF.kjb")
    pdefs.addProcess(pdef)

    # INTERFACES: ITF BEE Movimientos diferidos - 2.7.3
    pdef = ProcessDefinition("BEE MOVIMIENTOS DIFERIDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "166");
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_MOVDIFERIDOS.kjb");
    pdefs.addProcess(pdef)
    # ITF - 2.14.9 LK - NORIX
    pdef = ProcessDefinition("LK - NORIX", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_NORIX.kjb");
    pdef.addParameter("NOMBREARCHIVO", 3, "ARCHIVO")
    pdefs.addProcess(pdef)
    # ITF - 2.14.10 LK - NDESX
    pdef = ProcessDefinition("LK - NDESX", "topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_NDESX.kjb");
    pdef.addConstant("ID_MASTER", "154") 
    pdef.addParameter("NOMBREARCHIVO", 3, "ARCHIVO") 
    pdefs.addProcess(pdef)

    # ITF - 2.14.11 LK - CLI
    pdef = ProcessDefinition("LK - CLI", "topsystems.kettle.processes.KettleProcess") 
    # pdef.addConstant("KettleFileName", "ITF_LK_CLI.kjb");
    pdef.addConstant("ID_MASTER", "283") 
    # pdef.addParameter("NOMBREARCHIVO", 3, "ARCHIVO") 
    pdefs.addProcess(pdef)

    # 2.7.2 BEE - SALDOS
    pdef = ProcessDefinition("BEE SALDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_SALDOS.kjb");
    pdefs.addProcess(pdef)
    # *** Clearing Sesion de Presentados Propios INICIO ***
    
    # ITF COELSA CHEQUES PRESENTADOS RECIBIDOS - 2.8.2
    pdef = ProcessDefinition("ACOELSA CHEQUES Y AJUSTES PROPIOS RECIBIDOS CP0", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CARGA_CHEQUES_CP0.kjb")
    pdef.addParameter("CP0", 3, "Nacha Cheques Presentados Recibidos (CP0)", 1)
    pdefs.addProcess(pdef)
    
    # ITF COELSA Archivo de control de imágenes cheques presentados recibidos - 2.8.41
    pdef = ProcessDefinition("BCHEQUES PRESENTADOS RECIBIDOS IMG VCP", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CARGA_CHEQUES_VCP.kjb")
    pdef.addParameter("VCP", 3, "Control Cheques Presentados Recibidos (VCP)", 1)
    pdefs.addProcess(pdef)
    
    # ITF COELSA Archivo de imágenes cheques presentados recibidos - 2.8.42
    pdef = ProcessDefinition("CCHEQUES PROPIOS RECIBIDOS ZIP CONTROL VIP", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CARGA_CHEQUES_VIP.kjb")
    pdef.addParameter("VIP", 3, "Imagenes Cheques Presentados Recibidos (VIP)", 0)
    pdefs.addProcess(pdef)
    
    # ITF COELSA DEPOSITOS PRESENTADOS RECIBIDOS - 2.8.4
    pdef = ProcessDefinition("DCOELSA DPF Y AJUSTES PROPIOS RECIBIDOS CP1", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CARGA_DEPOSITOS_CP1.kjb")
    pdef.addParameter("CP1", 3, "Nacha DPF Presentados Recibidos (CP1)", 1)
    pdefs.addProcess(pdef)
    
    # ITF COELSA DPFD - Archivo de control de Imágenes Presentados Recibidos - 2.8.50
    pdef = ProcessDefinition("EDPFD PRESENTADOS RECIBIDOS IMG VCD", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CARGA_DEPOSITOS_VCD.kjb")
    pdef.addParameter("VCD", 3, "Control DPF Presentados Recibidos (VCD)", 1)
    pdefs.addProcess(pdef)
    
    # ITF COELSA DPFD - Archivo de Imágenes Presentados Recibidos - 2.8.51
    pdef = ProcessDefinition("FDPFD PRESENTADOS RECIBIDOS ZIP CONTROL VID", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_CARGA_DEPOSITOS_VID.kjb")
    pdef.addParameter("VID", 3, "Imagenes DPF Presentados Recibidos (VID)", 0)
    pdefs.addProcess(pdef)
    
    # COELSA Importacion Final de Interfaz Cheques y Ajustes Sesion Presentados Propios
    pdef = ProcessDefinition("COELSA IMPORTACION FINAL CHEQUES Y AJUSTES SESION PRESENTADOS PROPIOS", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_COELSA_IMPORTA_ITF_CHEQUES_AJUSTES_SESION_PRESENTADOS_PROPIOS");
    pdefs.addProcess(pdef)
    
    # COELSA Importacion Final de Interfaz DPFD Sesion Presentados Propios
    pdef = ProcessDefinition("COELSA IMPORTACION FINAL DPFD SESION PRESENTADOS PROPIOS", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_COELSA_IMPORTA_ITF_DPFD_SESION_PRESENTADOS_PROPIOS");
    pdefs.addProcess(pdef)
    
    # *** Clearing Sesion de Presentados Propios FIN ***

    
    # Proceso de Recategorización
    pdef = ProcessDefinition("Proceso de recategorizacion", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_RECATEGORIZACION");
    pdefs.addProcess(pdef)	
    # ITF - 2.12.6 ECOM-SSMALTPR052
    pdef = ProcessDefinition("Prestamos al SSM 052", "topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ECOM_SSMALTPR052.kjb");
    pdef.addConstant("ID_MASTER", "161")
    pdefs.addProcess(pdef)
    # ITF - 2.12.8 ECOM-SSMALTPR053
    pdef = ProcessDefinition("Prestamos al SSM 053", "topsystems.kettle.processes.KettleProcess") 
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ECOM_SSMALTPR053.kjb");
    pdef.addConstant("ID_MASTER", "162")
    pdefs.addProcess(pdef)
    #ITF Generar archivo PBF Topaz POS
    pdef = ProcessDefinition("Genera PBF POS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PBF_POS.kjb");    
    pdefs.addProcess(pdef)
    
    # TRANSFERENCIA SUELDOS PRESENTADOS 2.8.17
    pdef = ProcessDefinition("TRANSFERENCIA SUELDOS PRESENTADOS PESOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SUELDOS_PRESENTADOS_PESOS.kjb")
    pdef.addConstant("ID_MASTER", "238");
    pdefs.addProcess(pdef)
    
    # CLS CBU Master 2.8.20
    pdef = ProcessDefinition("CLS CBU MASTER", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_CBU_BASE.kjb");
    pdef.addParameter("REFRESH_TOTAL", 3, "Ingrese 'S' para full refresh o 'N' para update", 1)
    pdefs.addProcess(pdef)

   # INTERFACES: 2.28.1 ITF - INS - CPRESTAM
    pdef = ProcessDefinition("INS CPRESTAM", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "226");
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_INS_CPRESTAM.kjb");
    pdefs.addProcess(pdef)

    # 2.14.35 LK – CBU OUT
    pdef = ProcessDefinition("LK CBU OUT", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_CBU_OUT_BASE.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    # 2.14.36 LK –ECHEQ EXTRACT
    pdef = ProcessDefinition("ECHEQ_LINK_EXTRACT", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ECHEQ_EXTRACT_LINK.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)

# 1.31.13 NBCH24 - ECHEQ Deposito
    pdef = ProcessDefinition("ECHEQ_NBCH24_EXTRACT_DEPOSITO", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ECHEQ_EXTRACT_DEPOSITO_NBCH.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    
    # TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES 2.8.19
    pdef = ProcessDefinition("TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS.kjb")
    pdef.addConstant("ID_MASTER", "222");
    pdef.addConstant("MONEDA_IN", "1");
    pdef.addConstant("CODREGISTRO_IN", "CTX");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)

    # LK CBUG 2.14.12
    pdef = ProcessDefinition("LK CBUG", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_CBUG.kjb")
    pdef.addParameter("Archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    
    # LK CBU Master 2.14.13
    pdef = ProcessDefinition("LK CBU MASTER", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_CBU_BASE.kjb");
    pdef.addParameter("REFRESH_TOTAL", 3, "Ingrese 'S' para full refresh o 'N' para update", 1)
    pdefs.addProcess(pdef)
    # 1.11.8 I2000 - Contabilidad
    pdef = ProcessDefinition("I2000 Contabilidad", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_I2000_CONTABILIDAD.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    # 1.11.8 I2000 - Contabilidad Reporte
    pdef = ProcessDefinition("I2000 ASIENTOS CONTABLES REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "229");
    pdefs.addProcess(pdef)

    # 1.11.13 I2000 - OPCAM
    pdef = ProcessDefinition("I2000 OPCAM", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_RRII_OPCAM_IN.kjb")
    pdef.addConstant("SATELITE", "I2000")
    pdef.addConstant("DIRECTORIO_INPUT", "I2000/OPCAM/")
    pdef.addConstant("DIRECTORIO_OUTPUT", "I2000/OPCAM/")
    pdef.addParameter("ARCHIVO_NOMBRE",3,"Nombre del archivo con extensión", 1);
    pdefs.addProcess(pdef)

    #ITF I2000 POSICION GENERAL DE CAMBIO 1.11.15
    pdef = ProcessDefinition("I2000 POSICION GENERAL DE CAMBIO", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "257");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre archivo",1);
    pdefs.addProcess(pdef)


    # 1.19.6 UNITRADE - Contabilidad
    pdef = ProcessDefinition("UNITRADE Contabilidad", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_UNTD_CONTABILIDAD.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    # 1.19.6 UNITRADE - Contabilidad Reporte
    pdef = ProcessDefinition("UNITRADE ASIENTOS CONTABLES REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "229");
    pdefs.addProcess(pdef)

    # 1.19.9 UNTD - OPCAM
    pdef = ProcessDefinition("UNTD OPCAM", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_RRII_OPCAM_IN.kjb")
    pdef.addConstant("SATELITE", "UNTRD")
    pdef.addConstant("DIRECTORIO_INPUT", "UNITRADE/OPCAM/")
    pdef.addConstant("DIRECTORIO_OUTPUT", "UNITRADE/OPCAM/")
    pdef.addParameter("ARCHIVO_NOMBRE",3,"Nombre del archivo con extensión", 1);
    pdefs.addProcess(pdef)

    # 1.18.8 TNG - Ajuste - Contabilidad
    pdef = ProcessDefinition("TNG AJUSTE Contabilidad", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TNG_AJUSTE_ASIENTOS_CONTABLES.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    # 1.18.8 TNG - Ajuste - Contabilidad Reporte
    pdef = ProcessDefinition("TNG AJUSTE ASIENTOS CONTABLES REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "229");
    pdefs.addProcess(pdef)
    # 1.18.7 TNG - BU - Contabilidad
    pdef = ProcessDefinition("TNG BU Contabilidad", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TNG_BU_ASIENTOS_CONTABLES.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    # 1.18.7 TNG - BU - Contabilidad Reporte
    pdef = ProcessDefinition("TNG BU ASIENTOS CONTABLES REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "229");
    pdefs.addProcess(pdef)
    # ITF COELSA DEB DIR EMPRESAS HOMOLOGADAS 2.8.12
    pdef = ProcessDefinition("CLS DEBITOS DIRECTOS PADRON EMPRESAS HOMOLOGADAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_EMPR.kjb")
    pdef.addParameter("archivo", 3, "Ingrese nombre del archivo con extension a procesar", 1)
    pdef.addParameter("OPCION_EJECUCION", 3,"Ingrese 'N' para ejecucion normal o 'F' para ejecucion forzada",1)
    pdefs.addProcess(pdef)
    
    # 2.8.57 CLS - ECHEQ
    pdef = ProcessDefinition("CLS - ECHEQ", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_ECHEQ.kjb")
    pdef.addParameter("Archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdef.addConstant("ID_MASTER", "301")
    pdefs.addProcess(pdef)
    
    # 2.8.69 CLS - EC_RECHAZO_CANJE
    pdef = ProcessDefinition("CLS - EC RECHAZO CANJE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_EC_RECHAZO_CANJE.kjb.kjb")
    pdef.addConstant("ID_MASTER", "304")
    pdefs.addProcess(pdef)
    
    # ANSES FALLECIDOS
    pdef = ProcessDefinition("ANSES FALLECIDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ANSES_FALLECIDOS.kjb")
    pdef.addParameter("NOMBRE_ARCHIVO", 3, "Nombre del Archivo a procesar con extension", 1)
    pdef.addParameter("SIMULACION", 3, "S (SI) / N (NO)", 1)
    pdefs.addProcess(pdef)
    # LK ADH - 2.14.18
    pdef = ProcessDefinition("LK ADH", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_ADH.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)

    # 1.16.2 SOS - Operaciones
    pdef = ProcessDefinition("SOS Operaciones", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_OPERACIONES.kjb")
    pdef.addConstant("ID_MASTER", "242")
    pdefs.addProcess(pdef)

    # CRM NOVEDADES DOMICILIOS 1.9.2
    pdef = ProcessDefinition("CRM NOVEDADES DOMICILIOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "CRM_DOMICILIOS_MAINJOB.kjb")
    pdef.addParameter("FECHADESDE", 4, "Ingrese la fecha desde la que quiere leer las bitacoras", 1)
    pdefs.addProcess(pdef)

    # Apertura Carga Fecha TOPAZ en CONTROL-M
    pdef = ProcessDefinition("Carga fecha TOPAZ en CONTROL-M", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "Apertura_Carga_Fecha_CONTROLM.kjb")
    pdefs.addProcess(pdef)
    # 1.18.9 TNG -BAJA - Contabilidad
    pdef = ProcessDefinition("TNG BAJA", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TNG_BAJA.kjb")
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre de archivo con extension")
    pdefs.addProcess(pdef)

    #Reseteo de Parametro
    pdef = ProcessDefinition("BitacoraReseteoParametro","topsystems.automaticprocess.storedprocedures.SpBasicParameters") 
    pdef.addConstant("StoreName", "PA_ITF_BITACORA_RESETEO_PARAM");
    pdefs.addProcess(pdef)

    # 1.18.4 TNG - Impactos
    pdef = ProcessDefinition("TNG IMPACTOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TNG_IMPACTOS.kjb")
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre de archivo con extension")
    pdefs.addProcess(pdef)


    # 1.3.28 AD - IMPACTOS
    pdef = ProcessDefinition("AD IMPACTOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AD_IMPACTOS.kjb")
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre de archivo con extension")
    pdefs.addProcess(pdef)

    # 1.16.4 SOS - Cuentas
    pdef = ProcessDefinition("SOS Cuentas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_CUENTAS.kjb")
    pdef.addConstant("ID_MASTER", "256")
    pdefs.addProcess(pdef)

    # 1.16.9 SOS - CuentasCont
    pdef = ProcessDefinition("SOS Cuentas Mensual", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_CUENTAS_CONT.kjb")
    pdef.addConstant("ID_MASTER", "258")
    pdefs.addProcess(pdef)

    # 1.16.1 SOS - Clientes
    pdef = ProcessDefinition("SOS Clientes", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_CLIENTES.kjb")
    pdef.addConstant("ID_MASTER", "259")
    pdefs.addProcess(pdef)

    # 1.16.3 SOS - Vinculacion
    pdef = ProcessDefinition("SOS Vinculacion", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_VINCULACION.kjb")
    pdef.addConstant("ID_MASTER", "260")
    pdefs.addProcess(pdef)

    # 1.16.5 SOS - ClientesSinMov
    pdef = ProcessDefinition("SOS ClientesSinMov", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_CLIENTES_SINMOV.kjb")
    pdef.addConstant("ID_MASTER", "266")
    pdefs.addProcess(pdef)

    # 1.16.7 SOS - ClientesCont
    pdef = ProcessDefinition("SOS Clientes Mensual", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_CLIENTES_CONT.kjb")
    pdef.addConstant("ID_MASTER", "264")
    pdefs.addProcess(pdef)

    #ITF - 2.19.6.2 RP-PADCARESP_SECH
    pdef = ProcessDefinition("ITF PADRON CONVENIOS SA/SE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PADRON_CONVENIOS_SAMEEP_SACHEEP.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "CARGA PADRON CONVENIOS SA/SE");
    pdef.addConstant("ID_MASTER", "33");
    pdef.addParameter("archivo", 3, "Nombre de archivo con extension:", 1)
    pdefs.addProcess(pdef)
    
    #ITF - 2.19.6.2 RP-PADCARESP_SECH
    pdef = ProcessDefinition("ITF PADRON CONVENIOS SACHEEP", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_PADRON_CONVENIOS_SACHEEP.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "CARGA PADRON CONVENIOS SACHEEP");
    pdef.addConstant("ID_MASTER", "341");
    pdef.addParameter("archivo", 3, "Nombre de archivo con extension:", 1)
    pdefs.addProcess(pdef)

    # 1.11.10 I2000 - PLD_Cuentas
    pdef = ProcessDefinition("I2000 Cuentas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_I2000_CUENTAS.kjb")
    pdef.addParameter("Archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdef.addConstant("ID_MASTER", "267")
    pdefs.addProcess(pdef)

    # 1.11.9 I2000 - PLD_Clientes
    pdef = ProcessDefinition("I2000 Clientes", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_I2000_CLIENTES.kjb")
    pdef.addParameter("Archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdef.addConstant("ID_MASTER", "269")
    pdefs.addProcess(pdef)

    # 1.11.11 I2000 - PLD_Movimientos
    pdef = ProcessDefinition("I2000 Movimientos", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_I2000_MOVIMIENTOS.kjb")
    pdef.addParameter("Archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdef.addConstant("ID_MASTER", "271")
    pdefs.addProcess(pdef)

    # 1.16.8 SOS - VinCont
    pdef = ProcessDefinition("SOS Vinculacion Mensual", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_VINCONT.kjb")
    pdef.addConstant("ID_MASTER", "272")
    pdefs.addProcess(pdef)
    
    #ITF SOS IPC 1.16.11
    pdef = ProcessDefinition("ITF_SOS_IPC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "277");    
    pdefs.addProcess(pdef)

    # 1.16.6 SOS - PerfilDoc
    pdef = ProcessDefinition("SOS PerfilDoc Diario", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_PERFILDOC.kjb")
    pdef.addConstant("ID_MASTER", "280")
    pdefs.addProcess(pdef)

    # 1.16.6 SOS - PerfilDoc
    pdef = ProcessDefinition("SOS PerfilDoc Mensual", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_PERFILDOC_CONT.kjb")
    pdef.addConstant("ID_MASTER", "281")
    pdefs.addProcess(pdef)

    # 1.16.10 SOS - Actualización de datos de Perfil Documental
    pdef = ProcessDefinition("SOS Actualiza Perfil Doc", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_ACTUALIZA_PERFILDOC.kjb")
    pdef.addConstant("ID_MASTER", "282")
    pdefs.addProcess(pdef)

    # 2.33.1 MiPyME - Padrón
    pdef = ProcessDefinition("MiPyME Padron", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_MIPYME_PADRON.kjb")
    pdef.addConstant("ID_MASTER", "285")
    pdefs.addProcess(pdef)

    #ITF - AFIP SITEROP 2.1.18
    pdef = ProcessDefinition("ITF AFIP SITEROP", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "298");
    pdef.addParameter("fecha",3,"dd/MM/yyyy");
    pdefs.addProcess(pdef)

    #RRII AFIP SITERDOM 2.1.19 
    pdef = ProcessDefinition("RPT_AFIP_SITERDOM", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AFIP_SITERDOM.kjb")
    pdef.addConstant("ID_MASTER", "313");
    pdef.addParameter("anio",3,"Ingrese el anio (AAAA)")
    pdef.addParameter("semestre",3,"Ingrese semestre (1 o 2)")
    pdefs.addProcess(pdef)

    #2.1.20 AFIP - SITEREX
    pdef = ProcessDefinition("ITF SITEREX", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_AFIP_SITEREX.kjb")
    pdef.addConstant("ID_MASTER", "299")
    pdef.addParameter("FECHA",4,"DD/MM/YYYY",1);
    pdefs.addProcess(pdef)

    #operaciones activas
    pdef = ProcessDefinition("RRII Operaciones Activas", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "OPERACIONES_ACTIVAS.kjb")
    pdef.addParameter("fecha",3,"DD/MM/YYYY",1);
    pdefs.addProcess(pdef)

    #2.12.15 - 2.12.16 ECOM-SSMREPR15x
    pdef = ProcessDefinition("ECOM Rechazos Novedades", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ECOM_RECHAZOS.kjb")
    pdef.addConstant("ID_MASTER", "302")
    pdef.addParameter("FECHA",3,"Fecha (yyyyMMdd)",1);
    pdefs.addProcess(pdef)

    #2.14.80 LK - TRX Comisiones
    pdef = ProcessDefinition("LK TRX - Comisiones", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_TRX_COMISIONES.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre de archivo con extension:", 1)
    pdefs.addProcess(pdef)

    # 1.29.3 DJP - ACPRIV
    pdef = ProcessDefinition("DJP ACPRIV", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_DJP_ACPRIV.kjb")
    pdef.addParameter("Archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdef.addConstant("ID_MASTER", "270")
    pdefs.addProcess(pdef)
    #Agrego SP Sistema Calificacion Interna (SIC)
    pdef = ProcessDefinition("Sistema Interno de Calificacion", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_CRE_SIC");
    pdefs.addProcess(pdef)

    #ITF Consulta NOSIS para SIC
    pdef = ProcessDefinition("Consulta NOSIS SIC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_NOSIS_SIC.kjb");    
    pdefs.addProcess(pdef)

    #Genera Archivos memo
    pdef = ProcessDefinition("Genera Memos", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_GENERA_MEMOS.kjb");  
    pdefs.addProcess(pdef)
	
    #Genera Archivos memo por fecha
    pdef = ProcessDefinition("Genera Memos por fecha", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_GENERA_MEMOS.kjb");  
    pdef.addParameter("FECHA", 3, "Formato (YYYMMDD)")	
    pdefs.addProcess(pdef)
	
	# LK RESTJDINAHB - 2.14.78
    pdef = ProcessDefinition("LK RESTJDINAHB", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_RESTJDINAHB_MAIN_JOB.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
# LK RESTJDINAHB - 2.14.79
    pdef = ProcessDefinition("ECHEQ_LINK_EXTRACT_EMISION", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LINK_ECHEQ_EXTRACT_EMISION.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre de archivo con extension", 1)
    pdef.addConstant("ID_MASTER", "305")
    pdefs.addProcess(pdef)

    # 1.31.5 NBCH24 - ECHEQ EXTRACT EMISION
    pdef = ProcessDefinition("ECHEQ_NBCH24_EXTRACT_EMISION", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_NBCH_ECHEQ_EXTRACT_EMISION.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre de archivo con extension", 1)
    pdef.addConstant("ID_MASTER", "312")
    pdefs.addProcess(pdef)

	# LK TJDINAHB - 2.14.76
    pdef = ProcessDefinition("LK TJDINAHB", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_TJDINAHB_MAIN_JOB.kjb")
    pdefs.addProcess(pdef)
    
    # Cobro Reserva Topaz POS 
    pdef = ProcessDefinition("Cobro Reserva Topaz POS", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.Cobranza_ReservasPOS");
    pdefs.addProcess(pdef)
    # UNITRADE-INTERVINIENTES 1.19.10
    pdef = ProcessDefinition("UNITRADE INTERVINIENTES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_UNTD_INTERVINIENTES.kjb")
    pdef.addParameter("FECHADESDE", 4, "Ingrese la fecha desde la que quiere leer las novedades", 1)
    pdefs.addProcess(pdef)
    # CRM NOVEDADES CLIENTES 1.9.1
    pdef = ProcessDefinition("CRM NOVEDADES CLIENTES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "CRM_CLIENTES_MAINJOB.kjb")
    pdef.addParameter("FECHADESDE", 4, "Ingrese la fecha desde la que quiere leer las bitacoras", 1)
    pdefs.addProcess(pdef)
    #LK CAF 2.14.77
    pdef = ProcessDefinition("LK CAF", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_CAF.kjb")
    pdef.addParameter("archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdefs.addProcess(pdef)
    #ITF I2000 MOVIMIENTOS 1.11.12
    pdef = ProcessDefinition("I2000 COD MOVIMIENTOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "265");
    pdef.addParameter("NOMBREARCHIVO",3,"Nombre archivo",1);
    pdefs.addProcess(pdef)
    #ITF 1.19.7 UNTD - SYNC PLANCTAS 
    pdef = ProcessDefinition("ITF UNTD SYNC PLANCTAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "284");        
    pdefs.addProcess(pdef)

    # 1.16.13 SOS - Transferencias
    pdef = ProcessDefinition("SOS Transferencias", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_TRANSFERENCIAS_CONT.kjb")
    pdef.addConstant("ID_MASTER", "315")
    pdefs.addProcess(pdef)

    # 1.16.12 UIF 68/2013 - Agencieros
    pdef = ProcessDefinition("SOS Agencieros", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_AGENCIEROS.kjb")
    pdef.addConstant("ID_MASTER", "323")
    pdefs.addProcess(pdef)

    # 1.16.12 SOS - LAVADOPERDFILDET
    pdef = ProcessDefinition("SOS LAVADOPERDFILDET", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SOS_LAVADOPERDFILDET.kjb")
    pdef.addConstant("ID_MASTER", "324")
    pdefs.addProcess(pdef)

    return
def addMoreProcesses5(pdefs):
    pdef = ProcessDefinition("DevengamientoPlazo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorDevengamientoPlazo");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerDevengamientoPlazo");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDevengamientoPlazo");
    pdef.addConstant("MetodoContabilizacion","Extorno");
    pdef.addConstant("rangoCommit","20000");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("rangoSumarizaInstrGeneradasPorEsquema","2000");
    pdef.addConstant("guardaDetalleContabilidad","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("Mueve a Suspenso Intereses Devengados en Vigente","False");
    pdef.addConstant("Mueve a Vencidos Intereses Devengados en Vigente","False");
    pdef.addConstant("Mueve a Suspenso Mora Devengada en Vigente","False");
    pdef.addConstant("Mueve a Vencidos Mora Devengada en Vigente","False");
    pdef.addConstant("Contabiliza Devengado No Pagado","True");
    pdef.addConstant("Pasa a Suspenso en Feriado","False");
    pdef.addConstant("Pasa a Vencido en Feriado","True");
    pdef.addConstant("Cierre extendido","True");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Devengado Intereses Deudores N Acuerdos Un Jts_Oid", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("CAMPO_DEVENGADO_59_DIAS","C1806");
    pdef.addConstant("ES_COBRO","False");
    pdef.addConstant("Cobro Intereses Por Cargo","False");
    pdef.addConstant("query_name", "query.QuerySaldosCobroDeudoresNAunJtsOid")
    pdef.addParameter("JTS_OID",1,"",1);
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Devengado Intereses Deudores N Acuerdos Todos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("CAMPO_DEVENGADO_59_DIAS","C1806");
    pdef.addConstant("ES_COBRO","False");
    pdef.addConstant("Cobro Intereses Por Cargo","False");
    pdef.addConstant("query_name", "query.QuerySaldosCobroDeudoresNAtodos")
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cobro Intereses Deudores N Acuerdos Un Jts_Oid", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("CAMPO_DEVENGADO_59_DIAS","C1806");
    pdef.addConstant("ES_COBRO","True");
    pdef.addConstant("Cobro Intereses Por Cargo","False");
    pdef.addConstant("QUERY_NAME", "query.QuerySaldosCobroDeudoresNAunJtsOid")
    pdef.addParameter("JTS_OID",1,"",1);
    pdef.addConstant("usaClienteEnComisiones","true");
    pdef.addConstant("campoExentoImpuestoSello","33104");
    pdefs.addProcess(pdef)

    # Proceso de revisión de Tasas Acuerdos
    pdef = ProcessDefinition("Revision Tasas Acuerdos","topsystems.automaticprocess.storedprocedures.SpBasicParameters") 
    pdef.addConstant("StoreName", "SP_PA_REVISION_DE_TASAS_ACUERDOS");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cobro Intereses Deudores N Acuerdos Todos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWInteresesVistaCobroDeudoresNAcuerdos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","15");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("CAMPO_DEVENGADO_59_DIAS","C1806");
    pdef.addConstant("ES_COBRO","True");
    pdef.addConstant("Cobro Intereses Por Cargo","False");
    pdef.addConstant("query_name", "query.QuerySaldosCobroDeudoresNAtodos")
    pdef.addConstant("usaClienteEnComisiones","true");
    pdef.addConstant("campoExentoImpuestoSello","33104");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Evento Generico transferencia fallida", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorEnviarEventosGenerico");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerEnviarEventosGenerico");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("descriptor","2");
    pdef.addConstant("codigoTransaccion","0");
    pdef.addConstant("nroOperacion","92");
    pdef.addConstant("fieldNumberEmpresa","7465");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Transferencias de fondos Reintento", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorTransferenciasPeriodicas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerTransferenciasPeriodicas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("reintento","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)

    # Transferencias periodicas entre Cuentas
    pdef = ProcessDefinition("Transferencias de fondos Periodica", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorTransferenciasPeriodicas");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerTransferenciasPeriodicas");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("reintento","false");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Transferencia Cobranzas a Convenios", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDTransferenciasCobranzasAConvenios");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWTransferenciasCobranzasAConvenios");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Cobranza Vista Multihilo", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCobranzaVistaMultiHilos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerCobranzaVistaDefault");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerCobranzaVistaDefault");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("priorityType", "topsystems:service:RequestSorting.ComisionExterna");
    pdef.addConstant("transactionByRequest", "false");
    pdef.addConstant("fechaVencimiento","50027");
    pdef.addConstant("diasAtraso","50026");
    pdef.addConstant("mesesAtraso","50025");
    pdef.addConstant("deuda","50024");
    pdef.addConstant("mora","50023");
    pdef.addConstant("campoNombreConvenio","50022");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("QUERY_NAME_MULTIHILOS","query.Solicitud_Recaudacion_MultiHilos");
    pdefs.addProcess(pdef)

    # PROCESO: Extorno con Sucursal
    pdef = ProcessDefinition("Extorno con Sucursal", "topsystems.automaticprocess.extorno.ExtornProcess")
    pdef.addParameter("FECHA_VALOR",4,"dd/MM/yyyy",0);
    pdef.addParameter("esAjusteParam",3,"",0);
    pdef.addParameter("sucursalProceso",1,"",0);
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Canales - Reversa Cargos Especificos", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_CANALES_ESTADO_CONV_PADRONES");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Agencieros - Reversa REC_agencieros", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "PA_AGENCIEROS_ESTADO_REC_agencieros");
    pdef.addConstant("ParamtersPositions", "FECHA_REND,P;SIGNO,P;");
    pdef.addParameter("FECHA_REND", 3, "", 1);
    pdef.addParameter("SIGNO", 1, "", 1);
    pdefs.addProcess(pdef)

    # MIG_CARGA_DEVENGADO
    pdef = ProcessDefinition("Mig Carga Devengado", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_CARGA_DEVENGADO")
    pdefs.addProcess(pdef)

    #MIG_AJUS_REC
    pdef = ProcessDefinition("Mig Ajuste Recalculo", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_AJUS_REC")
    pdef.addConstant("ParamtersPositions", "ID_PROCESO_RECALCULO,P;")
    pdef.addParameter("ID_PROCESO_RECALCULO",1,"",1)
    pdefs.addProcess(pdef)

    # ITF ADINTAR USUARIOS - DG - MIGNBCAR-2459 - 13/05/2024
    pdef = ProcessDefinition("MIG - ADINTAR USUARIOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TC_AD_USUARIOS.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "Adintar Usuarios");
    pdef.addConstant("ID_MASTER", "39");
    pdef.addConstant("archivo", "ARCHUSUM.DAT");
    pdefs.addProcess(pdef)

    # ITF ADINTAR SALDOS
    pdef = ProcessDefinition("MIG - ADINTAR SALDOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TC_AD_SALDOS.kjb");
    pdef.addConstant("NOMBRE_INTERFASE", "Adintar Saldos");
    pdef.addConstant("ID_MASTER", "40");
    pdef.addConstant("archivo", "SALDOSD.TXT");
    pdefs.addProcess(pdef)

    # MIG_AJUSTO_INVENTARIO
    pdef = ProcessDefinition("Mig Ajusto Inventario", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_AJUSTO_INVENTARIO")
    pdefs.addProcess(pdef)

# MIG_ACTUALIZO_BS_HISTORIA_PLAZO
    pdef = ProcessDefinition("Mig Actualizo BS Historia Plazo", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_ACTUALIZO_BS_HISTORIA_PLAZO")
    pdef.addConstant("ParamtersPositions", "CICLO,C;PROCESO,C;")
    pdef.addConstant("CICLO","1")
    pdef.addConstant("PROCESO","1")
    pdefs.addProcess(pdef)
	
    # Traspaso entre Cuentas acreditación DPF UVA/UVI
    pdef = ProcessDefinition("Traspaso acreditacion DPF UVA", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorFundsTransfer");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerFundsTransfer");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerFundsTransfer");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("usaClienteEnComisiones","true");
    pdef.addConstant("campoCondicionCREDEB",  "58400" );
    pdef.addConstant("campoCondicionSIRCREB",  "58401" );
    pdef.addConstant("permiteTransferenciaParcial","false");
    pdef.addConstant("activarBitacora","false");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("applyCodigoTransaccion","true");
    pdef.addConstant("productosCodigoDiferente","80");
    pdef.addConstant("campoCargarProductoSaldoDebito","35690");
    pdef.addConstant("QUERY_NAME","query.AcreditacionDPF");
    pdefs.addProcess(pdef)
    # 2.4.1 ANSES - APERTURA
    pdef = ProcessDefinition("ANSES APERTURA", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ANSES_APERTURA.kjb")
    pdef.addParameter("Archivo", 3, "Ingrese el nombre del archivo a procesar", 1)
    pdef.addConstant("ID_MASTER", "275")
    pdefs.addProcess(pdef)
    #ITF UNTD IMPUESTOS 1.19.8
    pdef = ProcessDefinition("ITF_UNTD_IMPUESTOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "276");
    pdef.addParameter("archivo",3,"Nombre del Archivo",1);
    pdefs.addProcess(pdef)

    # Generacion Estados de Cuenta Semestral
    pdef = ProcessDefinition("EstadosdeCuentaKetZ","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA.kjb")
    pdef.addConstant("Periodicidad", "Z");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;");
    pdefs.addProcess(pdef)
 
    # Generacion Estados de Cuenta Cuatrimestral
    pdef = ProcessDefinition("EstadosdeCuentaKetC","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "EEC_ESTADOCUENTA.kjb")
    pdef.addConstant("Periodicidad", "C");
    pdef.addConstant("ParamtersPositions", "Legal,C;Periodicidad,C;");
    pdefs.addProcess(pdef)
    #ITF I2000 IMPUESTOS 1.11.14 
    pdef = ProcessDefinition("ITF I2000 IMPUESTOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "279");
    pdef.addParameter("archivo",3,"Nombre del Archivo",1);    
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Bitacora Credeb para nuevas cuentas", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "PA_VTA_BITACORA_CREDEB");
    pdefs.addProcess(pdef)
	
    # Cobro Pendientes Topaz POS 
    pdef = ProcessDefinition("Cobro Pendientes Topaz POS", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.Cobranza_PendientesPOS");
    pdefs.addProcess(pdef)
	
    #PROCESO: Contabiliza Rechazo Canje Interno
    pdef = ProcessDefinition("Contabiliza Rechazo Canje Interno", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.ContabilizaRechazoCanjeInterno");
    pdefs.addProcess(pdef)

    # Proceso Solicitudes de Cheques electrónicos propios 
    pdef = ProcessDefinition("Solicitudes Cheques Electronicos Propios", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.chequesElectronicosPropios");
    pdefs.addProcess(pdef)

    # Proceso Solicitudes de Cheques electrónicos de terceros 
    pdef = ProcessDefinition("Solicitudes Cheques Electronicos Terceros", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.chequesElectronicosTerceros");
    pdefs.addProcess(pdef)

    # Actualización Tipo reg Cheques de terceros
    pdef = ProcessDefinition("Actualiza Tipo Reg Cheques Terceros","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "SP_ACTUALIZA_TIPO_REG_CHE_T");
    pdefs.addProcess(pdef)

    # Actualización Tipo reg Cheques propios
    pdef = ProcessDefinition("Actualiza Tipo Reg Cheques Propios","topsystems.automaticprocess.storedprocedures.SpStoreParameters") 
    pdef.addConstant("StoreName", "SP_ACTUALIZA_TIPO_REG_CHE_P");
    pdefs.addProcess(pdef)

    #CONTA SP_TJC_DEUDA_TARJ_CREDITO
    pdef = ProcessDefinition("TJC - Datos Deuda Tarjetas de Credito", "topsystems.automaticprocess.storedprocedures.SpBasicParameters")
    pdef.addConstant("StoreName", "SP_TJC_DEUDA_TARJ_CREDITO");
    pdefs.addProcess(pdef)
    #CONTA SP_TJC_DEUDA_TARJ_CREDITO
    pdef = ProcessDefinition("TJC - Contabilidad Deuda Tarjetas de Credito", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","20");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.sucursalesDeudaTarjetaCredito");
    pdefs.addProcess(pdef)

    #CONTA EXTORNO SALDOS TARJETA CREDITO
    pdef = ProcessDefinition("TJC - Extorno Saldos No Utilizados Tarjetas de Credito", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorExtornProcess");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerExtornProcess");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("queryAsientosExtornar","query.extornoSaldosTarjetasCredito");
    pdef.addConstant("queryFechaValor","");
    pdef.addConstant("condicion","");
    pdefs.addProcess(pdef)

    # NumeroFolioLibroTesoreria
    pdef = ProcessDefinition("NumeroFolioLibroTesoreria", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("QUERY_NAME","query.fechaFolioLibroTesoreria");
    pdefs.addProcess(pdef)

    #MODIFICA ESTADO Y CADUCIDAD E-CHEQUES
    pdef = ProcessDefinition("VTA - Actualiza estado cheques electronicos", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida");
    pdef.addConstant("rangoCommit","1");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addConstant("QUERY_NAME","query.chequesModificarEstado");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("Analiza Cuentas Remuneradas", "topsystems.automaticprocess.storedprocedures.SpStoreParametersSessionInfo")
    pdef.addConstant("StoreName", "SP_ANALIZA_CUENTA_REMUNERADA");
    pdefs.addProcess(pdef)

    # 2.6.8 BCRA - OPCAM
    pdef = ProcessDefinition("BCRA OPCAM","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BCRA_OPCAM.kjb")
    pdef.addParameter("FECHA_PROCESAR", 3, "Fecha de Información. Formato AAAAMMDD", 1)
    pdef.addParameter("RECTIFICATIVA", 3, "\"N\"ormal/\"R\"ectificativa", 1)
    pdefs.addProcess(pdef)

    # Asientos Varios VSAC SUPERPOWERS (IMPORTACION)
    pdef = ProcessDefinition("AsientosVarios_ImportaVSAC", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb");
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "AsientosVarios_MainJob.kjb");
    pdef.addParameter("ARCHIVO",3,"NombreArchivo.Extension",1);
    pdefs.addProcess(pdef)
    # Asientos Varios VSAC SUPERPOWERS (IMPACTO)
    pdef = ProcessDefinition("AsientosVarios_CargaBandeja", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "AsientosVarios_CargaBandeja.kjb")
    pdef.addParameter("MD5",3,"Hash MD5 del archivo Confirmado",1);
    pdefs.addProcess(pdef)
    # Asientos Varios VSAC SUPERPOWERS (RESPUESTA)
    pdef = ProcessDefinition("AsientosVarios_Respuesta", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "AsientosVarios_Respuesta.kjb")
    pdefs.addProcess(pdef)

# 2.14.82 LK - Comisiones x Uso Cajero
    pdef = ProcessDefinition("LK Cobro Comisiones ATM","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_COBRO_COMISIONES.kjb")
    pdefs.addProcess(pdef)

# Bolsa Con Movimientos Pendientes de Impactar
    pdef = ProcessDefinition("SBCMPI","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "PA_BCMPI.kjb")
    pdef.addConstant("CANAL", "PA_BOLSA_MOVIMIENTOS_PENDIENTES")
    pdefs.addProcess(pdef)

# Bolsa Con Movimientos Pendientes de Impactar - Acreditaciones Masivas
    pdef = ProcessDefinition("SBCMPI - Debitos y Creditos Masivos", "topsystems.automaticprocess.processmanager.WorkManager") 
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDDebitosCreditosMasivos");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWDebitosCreditosMasivos");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","1000");
    pdef.addConstant("cantidadHilos","1");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("generaAsientoContable","true");
    pdef.addConstant("contabiliza","true");
    pdef.addParameter("CANAL",3,"IGNORAR. PRESIONE ACEPTAR",0, "PA_BOLSA_MOVIMIENTOS_PENDIENTES");
    pdef.addConstant("applyInstalationFields","true");
    pdef.addConstant("campoCanalAcreditacionMasiva", "45788");
    pdef.addConstant("campoCondicionCREDEB", "58400" );
    pdef.addConstant("campoCondicionSIRCREB", "58401" );
    pdefs.addProcess(pdef)

# Bolsa Con Movimientos Pendientes de Impactar - Reporte / Resultado
    pdef = ProcessDefinition("SBCMPI Resultado","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "PA_BCMPI_RESULTADO.kjb")
    pdef.addConstant("CANAL", "PA_BOLSA_MOVIMIENTOS_PENDIENTES")
    pdefs.addProcess(pdef)

# BEE Banca Electr�nica de Empresas Cobro de Comisiones por Mantenimiento de Servicio
    pdef = ProcessDefinition("BEE Cobro Comisiones","topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_BEE_COBRO_COMISIONES.kjb")
    pdefs.addProcess(pdef)
#------------------------------------------------------------------------#
#--------------------------MIGRACION-------------------------------------#
#------------------------------------------------------------------------#
#---actualizar el que esta------#

    # MIG_ACTUALIZO_BS_HISTORIA_PLAZO 
    pdef = ProcessDefinition("MIG Actualizo BS_HISTORIA_PLAZO", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_ACTUALIZO_BS_HISTORIA_PLAZO")
    pdefs.addProcess(pdef)

#--------------------------------#
#---------nuevos-----------------#

   # Proceso MIG_PREV_CON_DES
    pdef = ProcessDefinition("MIG PREVIO CONV DESEMBOLSO","topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName","MIG_PREV_CON_DES");
    pdefs.addProcess(pdef)

    # Proceso MIG_POST_CON_DES
    pdef = ProcessDefinition("MIG POSTERIOR CONV DESEMBOLSO","topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName","MIG_POST_CON_DES");
    pdefs.addProcess(pdef)

    # MIG_GRABO_SALDOS
    pdef = ProcessDefinition("MIG Grabo Saldos", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_GRABO_SALDOS")
    pdef.addConstant("ParamtersPositions", "TABLAAGRABAR,P;")
    pdef.addParameter("TABLAAGRABAR",3,"",1)
    pdefs.addProcess(pdef)

    # MIG_ACTUALIZA_FECHAS
    pdef = ProcessDefinition("MIG Actualiza Fechas", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_ACTUALIZA_FECHAS")
    pdefs.addProcess(pdef)

    # MIG_GRABO_SALDOS - SALDOS_POST_RECALCULO
    pdef = ProcessDefinition("MIG Grabo SALDOS_POST_RECALCULO", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_GRABO_SALDOS")
    pdef.addConstant("ParamtersPositions", "TABLAAGRABAR,C;")
    pdef.addConstant("TABLAAGRABAR","SALDOS_POST_RECALCULO")
    pdefs.addProcess(pdef)

    # MIG_GRABO_SALDOS - SALDOS_PRE_AJUSTE
    pdef = ProcessDefinition("MIG Grabo SALDOS_PRE_AJUSTE", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_GRABO_SALDOS")
    pdef.addConstant("ParamtersPositions", "TABLAAGRABAR,C;")
    pdef.addConstant("TABLAAGRABAR","SALDOS_PRE_AJUSTE")
    pdefs.addProcess(pdef)

    # MIG_GRABO_SALDOS - SALDOS_PRE_CADENA
    pdef = ProcessDefinition("MIG Grabo SALDOS_PRE_CADENA", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_GRABO_SALDOS")
    pdef.addConstant("ParamtersPositions", "TABLAAGRABAR,C;")
    pdef.addConstant("TABLAAGRABAR","SALDOS_PRE_CADENA")
    pdefs.addProcess(pdef)

    # MIG_GRABO_SALDOS - SALDOS_POST_CADENA
    pdef = ProcessDefinition("MIG Grabo SALDOS_POST_CADENA", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_GRABO_SALDOS")
    pdef.addConstant("ParamtersPositions", "TABLAAGRABAR,C;")
    pdef.addConstant("TABLAAGRABAR","SALDOS_POST_CADENA")
    pdefs.addProcess(pdef)

    # PROCESO: PRECADENA Procesamiento de la bandeja de entrada
    pdef = ProcessDefinition("PRECADENA Procesamiento de la Bandeja contable", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorProcesarAsientosBandejaContable");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerProcesarAsientosBandejaContable");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerProcesarAsientosBandejaContable");
    pdef.addConstant("rangoCommit","100");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("applySchemes","true");
    pdef.addConstant("isSumarizable","true");
    pdef.addConstant("offLine","true");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("ORIGEN_A_PROCESAR","CON");
   #pdef.addConstant("ORIGEN_A_PROCESAR_CTE","XXX");
    pdef.addConstant("productosAplicaOffLine","");
    pdef.addConstant("ABORTA SALDOS X DIFERENCIA RUBRO","false");
    pdef.addConstant("generaAsientoContable","true");
    pdefs.addProcess(pdef)

    #2.14.1 MIG LK TRX
    pdef = ProcessDefinition("MIG - ITF LK TRX", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_LK_TRX.kjb")
    pdef.addConstant("NOMBREARCHIVO", "RM.DAT")
    pdef.addConstant("TIPO","F")
    pdefs.addProcess(pdef)

    #MIG- ITF-AFIP PADRONES
    pdef = ProcessDefinition("MIG - ITF AFIP Padrones", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("ID_MASTER", "24");
    pdef.addConstant("NOMBREARCHIVO","PUCA.TMP");
    pdefs.addProcess(pdef)

    #MIG - ITF BCRA Padron PFPJ
    pdef = ProcessDefinition("MIG - ITF BCRA Padron PFPJ", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "ITF_BCRA_PADFYJ.kjb")
    pdef.addConstant("NOMBREARCHIVO","PADFYJ.TXT")
    pdefs.addProcess(pdef)

    # MIG_ACTUALIZA_DPF_INMOV
    pdef = ProcessDefinition("Mig Actualiza DPF Inmov", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "MIG_ACTUALIZA_DPF_INMOV")
    pdefs.addProcess(pdef)

    # Mig_INT_CHE0006
    pdef = ProcessDefinition("Mig INT_CHE0006", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "Mig_INT_CHE0006")
    pdefs.addProcess(pdef)

    # 1.3.29 AD - OPCAM
    pdef = ProcessDefinition("AD OPCAM", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_RRII_OPCAM_IN.kjb")
    pdef.addConstant("SATELITE", "ADINT")
    pdef.addConstant("DIRECTORIO_INPUT", "ADINTAR/OPCAM/")
    pdef.addConstant("DIRECTORIO_OUTPUT", "ADINTAR/OPCAM/")
    pdef.addParameter("ARCHIVO_NOMBRE",3,"Nombre del archivo con extensión", 1);
    pdefs.addProcess(pdef)
# 1.31.23 NBCH24 - ECHEQ DEPOGEN
    pdef = ProcessDefinition("NBCH24_ECHEQ_DEPOGEN", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_NBCH24_ECHEQ_DEPOGEN.kjb")
    pdefs.addProcess(pdef)

    # 1.31.24 NBCH24 - ECHEQ GENEMISION
    pdef = ProcessDefinition("NBCH24_ECHEQ_GENEMISION", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_NBCH_ECHEQ_GENEMISION.kjb")
    pdefs.addProcess(pdef)

    # 2.18.2 NCF - RESCATE
    pdef = ProcessDefinition("NCF_RESCATE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_NCF_RESCATE.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre de archivo con extension", 1)
    pdefs.addProcess(pdef)

    #PROCESO RML BANDAS
    pdef = ProcessDefinition("ITF RML BANDAS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RML_BANDAS.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)
    #PROCESO RML BANDAS DISMINUCIONES
    pdef = ProcessDefinition("RML BANDAS DISMINUCIONES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RML_BANDAS_D.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    pdefs.addProcess(pdef)
    
    #PROCESO RML BANDAS DISMINUCIONES
    pdef = ProcessDefinition("RML BANDAS DISMINUCIONES", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "RML_BANDAS_D.kjb")
    pdef.addParameter("fecha",3,"dd/MM/yyyy")
    #PROCESO: Proceso Altas Masivas - Reporte
    pdef = ProcessDefinition("Proceso de Altas Masivas - Reporte", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "MA_BANDEJA_REPORTE.kjb");
    pdef.addParameter("LOTE_ID",1,"Número Identificador de Lote",1);
    pdefs.addProcess(pdef)

    # ITF DJP ACPRIV Post Bandeja
    pdef = ProcessDefinition("Post-Proceso Altas Masivas DJP ACPRIV", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WorkDescriptorOperacionDesasistida")
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerOperacionDesasistida")
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerOperacionDesasistida")
    pdef.addConstant("rangoCommit","1")
    pdef.addConstant("cantidadHilos","1")
    pdef.addConstant("isStopable","true")
    pdef.addConstant("applySchemes","false")
    pdef.addConstant("isSumarizable","false")
    pdef.addConstant("offLine","true")
    pdef.addConstant("enqueue","false")
    pdef.addConstant("generaAsientoContable","false")
    pdef.addConstant("utilizaParametrosEntrada","true")
    pdef.addParameter("grupo_operacion",1)
    pdef.addConstant("QUERY_NAME","query.djp_acpriv_post")
    pdefs.addProcess(pdef)

    #Actualiza numerador Tarjeta Raiz
    pdef = ProcessDefinition("Actualiza numerador Tarjeta Raiz", "topsystems.automaticprocess.storedprocedures.SpStoreParameters")
    pdef.addConstant("StoreName", "SP_ACTUALIZAR_NUMERADOR_TARJETA_RAIZ");    
    pdefs.addProcess(pdef)
    
     # 1.29.29
    pdef = ProcessDefinition("SOS ACTUALIZA RIESGO", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_IGR_ACTUALIZA_RIESGO.kjb")
    pdefs.addProcess(pdef)
    
    # MEP IMPACTO - REPORTE
    pdef = ProcessDefinition("MEP IMPACTO - REPORTE", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_MEP_IMPACTO_REPORTE.kjb")
    pdef.addParameter("ID_ENVIO", 3,"Identificador del envío", 1)
    pdef.addParameter("PROCESAR_BANDEJA", 3, "Estado de ejecucion", 1)
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("ALTA_DIARIA_ECHEQ_COELSA", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_ALTA_DIARIA_ECHEQ_COELSA.kjb")
    pdef.addParameter("COELSAEC_FECHA_ALTA", 3, "FECHA CON FORMATO yyyyMMdd", 1)
    pdefs.addProcess(pdef)
    

    pdef = ProcessDefinition("GeneraChequesRechazadosCanjeInterno","topsystems.automaticprocess.storedprocedures.SpBasicParameters") 
    pdef.addConstant("StoreName", "SP_INSERT_CHE_BCO_RECHAZADOS");
    pdefs.addProcess(pdef)

    # Borrado tabla historico ajuste por fecha
    pdef = ProcessDefinition("Borrado tabla CO_HIS_AJUSTE_X_INFLACION por fecha", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDBorradoDatosAjustePorInflacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BusinessWorkerBorradoDatosPorVO");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=ResultHandlerDefault");
    pdef.addConstant("rangoCommit","500");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","true");
    pdef.addConstant("queryTablaDepurar","query.HistoricoAjusteXInflacion");
    pdef.addConstant("VoName","core.vo_HistoricoAjustes");
    pdef.addParameter("fecha",4,"dd/MM/yyyy",1);
    pdefs.addProcess(pdef)
    
    # Ajuste por inflacion contabilizacion por fecha
    pdef = ProcessDefinition("Contabilizo ajuste por inflacion por fecha", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDContabAjPorInflacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWContabAjPorInflacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=RHContabAjPorInflacion");
    pdef.addConstant("rangoCommit","200");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addConstant("campoAjusteInflacion","ajusteinflacion");
    pdef.addConstant("generaAsientoContable","false");
    pdef.addParameter("fecha",4,"dd/MM/yyyy",1);
    pdefs.addProcess(pdef)

    # Ajuste por inflacion solo calculo por fecha
    pdef = ProcessDefinition("Calculo Ajuste por Inflacion por fecha", "topsystems.automaticprocess.processmanager.WorkManager")
    pdef.addConstant("workDescriptorName","topsystems:processManager:WorkDescriptor=WDCalculoAjustePorInflacion");
    pdef.addConstant("businessWorkName","topsystems:processManager:BusinessWorker=BWCalculoAjustePorInflacion");
    pdef.addConstant("resultHandlerName","topsystems:processManager:ResultHandler=RHCalculoAjustePorInflacion");
    pdef.addConstant("rangoCommit","200");
    pdef.addConstant("cantidadHilos","10");
    pdef.addConstant("isStopable","false");
    pdef.addConstant("applySchemes","false");
    pdef.addConstant("isSumarizable","false");
    pdef.addConstant("offLine","false");
    pdef.addConstant("enqueue","false");
    pdef.addParameter("fecha",4,"dd/MM/yyyy",1);
    pdef.addConstant("INDICEACTUAL","MES_ACTUAL");
    pdefs.addProcess(pdef)

    pdef = ProcessDefinition("ITF_DEPOSITO_DIARIO_ECHEQ_NEGOCIADOS", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_DEPOSITO_DIARIO_ECHEQ_NEGOCIADOS.kjb")
    pdef.addParameter("FECHA_ECHEQ_DEPOSITO", 3, "FECHA CON FORMATO yyyyMMdd", 0, "busqueda-default")
    pdefs.addProcess(pdef)
    
	# TRANSFERENCIA MINORISTA PRESENTADAS 2.8.13_V2
    pdef = ProcessDefinition("TRANSFERENCIA MINORISTA PRESENTADAS PESOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_PRESENTADAS_V2.kjb")
    pdef.addConstant("ID_MASTER", "339");
    pdefs.addProcess(pdef)

    # TRANSFERENCIA MINORISTA RECIBIDAS 2.8.14_V2
    pdef = ProcessDefinition("TRANSFERENCIA MINORISTA RECIBIDAS PESOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS_V2.kjb")
    pdef.addConstant("ID_MASTER", "338");
    pdef.addConstant("MONEDA_IN", "0");
    pdef.addConstant("CODREGISTRO_IN", "CTX");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
    # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.15_V2
    pdef = ProcessDefinition("COELSA TRANSFERENCIAS MINORISTAS PRESENT DOLARES V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_TRANSFERENCIAS_MPD_V2.kjb")
    pdef.addConstant("ID_MASTER", "337");
    pdefs.addProcess(pdef)

	# TRANSFERENCIA MINORISTA RECIBIDAS 2.8.16_V2
    pdef = ProcessDefinition("TRANSFERENCIA MINORISTA RECIBIDAS DOLARES V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS_V2.kjb")
    pdef.addConstant("ID_MASTER", "338");
    pdef.addConstant("MONEDA_IN", "1");
    pdef.addConstant("CODREGISTRO_IN", "CTX");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)

    # TRANSFERENCIA SUELDOS PRESENTADOS 2.8.17_V2
    pdef = ProcessDefinition("TRANSFERENCIA SUELDOS PRESENTADOS PESOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_SUELDOS_PRESENTADOS_PESOS_V2.kjb")
    pdef.addConstant("ID_MASTER", "340");
    pdefs.addProcess(pdef)

	# SUELDOS PRESENTADOS RECIBIDOS PESOS 2.8.18_V2
    pdef = ProcessDefinition("SUELDOS PRESENTADOS RECIBIDOS PESOS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS_V2.kjb")
    pdef.addConstant("ID_MASTER", "338");
    pdef.addConstant("MONEDA_IN", "0");
    pdef.addConstant("CODREGISTRO_IN", "CCD");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
    # TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES 2.8.19_V2
    pdef = ProcessDefinition("TRANSFERENCIA RECHAZADAS RECIBIDAS DOLARES V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS_V2.kjb")
    pdef.addConstant("ID_MASTER", "338");
    pdef.addConstant("MONEDA_IN", "1");
    pdef.addConstant("CODREGISTRO_IN", "CTX");
    pdef.addParameter("NOMBREARCHIVO",3)
    pdefs.addProcess(pdef)
	
   # ITF COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS 2.8.44_V2
    pdef = ProcessDefinition("COELSA TRANSFERENCIAS RECHAZADAS ENVIADAS V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_COELSA_TRAN_RECH_ENVIADAS_V2.kjb")
    pdef.addConstant("ID_MASTER", "336");
    pdefs.addProcess(pdef)
	
    # ITF COELSA TRANSFERENCIAS REJECTADAS PESOS 2.8.53_V2
    pdef = ProcessDefinition("Transf pres en pesos reject V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_TRANSF_PRESENTADAS_REJECT_PESOS_V2.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre del archivo con extension", 1)
    pdef.addConstant("ID_MASTER", "335");
    pdefs.addProcess(pdef)

    # ITF COELSA TRANSFERENCIAS REJECTADAS DOLARES 2.8.54_V2
    pdef = ProcessDefinition("Transf pres en dolares reject V2", "topsystems.kettle.processes.KettleProcess")
    pdef.addConstant("KettleFileName", "PUNTO_ENTRADA_LOG_PA.kjb")
    pdef.addConstant("MAIN_JOB_EX__LOGPA", "ITF_CLS_TRANSF_PRESENTADAS_REJECT_PESOS_V2.kjb")
    pdef.addParameter("NOMBREARCHIVO", 3, "Nombre del archivo con extension", 1)
    pdef.addConstant("ID_MASTER", "335");
    pdefs.addProcess(pdef)