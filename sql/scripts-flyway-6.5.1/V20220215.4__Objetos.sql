execute(' IF  EXISTS (select * from sys.views where  name = ''VW_INTEGRAL_EFECTIVO'')
	DROP view [dbo].[VW_INTEGRAL_EFECTIVO]; ')
execute(' IF  EXISTS (select * from sys.views where  name = ''VW_Grabo_CHE_RECHAZADOS_prueba'')
	DROP view [dbo].[VW_Grabo_CHE_RECHAZADOS_prueba]; ')
execute(' IF  EXISTS (select * from sys.views where  name = ''SP_CARGASWIFT_NBC'')
	DROP view [dbo].[SP_CARGASWIFT_NBC]; ')
execute(' IF  EXISTS (select * FROM sys.foreign_keys where  name = ''FK_CARGOS_EV_EVENTO'')
       ALTER TABLE [dbo].[CI_CARGOS_X_EVENTO] DROP CONSTRAINT [FK_CARGOS_EV_EVENTO];')
execute('
ALTER TABLE dbo.LISTADECATALOGOS ALTER COLUMN DESCRIPCION varchar(max);
ALTER TABLE dbo.LISTADECATALOGOS ALTER COLUMN PATH varchar(max);
ALTER TABLE dbo.LISTADECATALOGOS ALTER COLUMN PERIODICIDAD varchar(max);
ALTER TABLE dbo.LISTADECATALOGOS ALTER COLUMN PERMISOS varchar(max);
ALTER TABLE dbo.RCT_CONVENIO_SALDOS ALTER COLUMN CONCEPTO_HABILITADO varchar(max);
ALTER TABLE dbo.LISTADEREPORTES ALTER COLUMN PERMISOS varchar(max);
ALTER TABLE dbo.LISTADEREPORTES ALTER COLUMN ORIENTACION varchar(max);
ALTER TABLE dbo.LISTADEREPORTES ALTER COLUMN TIPO varchar(max);
ALTER TABLE dbo.LISTADEREPORTES ALTER COLUMN PATH varchar(max);
ALTER TABLE dbo.LISTADEREPORTES ALTER COLUMN DESCRIPCION varchar(max);
ALTER TABLE dbo.LISTADEREPORTES ALTER COLUMN TEMA  varchar(max);
ALTER TABLE dbo.RCT_SUSCRIPCION_SERVICIO ALTER COLUMN NOMBRE_FACTURA varchar(max);
ALTER TABLE dbo.RCT_SUSCRIPCION_SERVICIO ALTER COLUMN NOMBRE_DEUDOR varchar(max);
ALTER TABLE dbo.RCT_COBRANZACTA3OS ALTER COLUMN HORA varchar(max);
ALTER TABLE dbo.RCT_COBRANZACTA3OS ALTER COLUMN NOMBRE_FACTURA varchar(max);
ALTER TABLE dbo.CO_HIS_AJUSTE_X_INFLACION ALTER COLUMN ULTIMA_FECHA_AJUSTE varchar(max);
ALTER TABLE dbo.RCT_CONCEPTOS ALTER COLUMN TIPO_COMPROBANTE varchar(max);
ALTER TABLE dbo.SWIFTERRORMSG ALTER COLUMN ERRORMSG varchar(max);
ALTER TABLE dbo.HIS_LOG_PROCESO ALTER COLUMN MENSAJE varchar(max);                                                                                                                         
ALTER TABLE dbo.LOG_PROCESO ALTER COLUMN MSG_ERROR varchar(max);                                                                                                                        
ALTER TABLE dbo.CLEARING_CACHE ALTER COLUMN RESPUESTA varchar(max);                                                                                                                        
ALTER TABLE dbo.SERVERTASK ALTER COLUMN INFO varchar(max);                                                                                                                             
ALTER TABLE dbo.CI_RETOMA_COBRO_EVENTO ALTER COLUMN COLA_ATRIBUTOS_VISTA varchar(max);                                                                                                              
ALTER TABLE dbo.PLAN_TABLE ALTER COLUMN REMARKS varchar(max);                                                                                                              
ALTER TABLE dbo.PLAN_TABLE ALTER COLUMN ACCESS_PREDICATES varchar(max); 
ALTER TABLE dbo.PLAN_TABLE ALTER COLUMN FILTER_PREDICATES varchar(max); 
ALTER TABLE dbo.PLAN_TABLE ALTER COLUMN PROJECTION varchar(max);                                                                                                                      
ALTER TABLE dbo.MIG_ERRORES ALTER COLUMN MENSAJE varchar(max); 
ALTER TABLE dbo.JBPM_DELEGATION ALTER COLUMN CLASSNAME_ varchar(max);                                                                                                                       
ALTER TABLE dbo.JBPM_DELEGATION ALTER COLUMN CONFIGURATION_ varchar(max);                                                                                                                   
ALTER TABLE dbo.ESCANER_CHEQUES ALTER COLUMN XML_CONFIG varchar(max);  
ALTER TABLE dbo.REPORTS ALTER COLUMN TRANSACTIONS varchar(max);                                                                                                                      
ALTER TABLE dbo.CRE_COMPRA_CARTERA ALTER COLUMN DETALLE_CUOTAS varchar(max);                                                                                                                   
ALTER TABLE dbo.JBPM_EXCEPTIONHANDLER ALTER COLUMN EXCEPTIONCLASSNAME_ varchar(max);                                                                                                              
ALTER TABLE dbo.JBPM_NODE ALTER COLUMN DESCRIPTION_ varchar(max);                                                                                                                     
ALTER TABLE dbo.JBPM_PROCESSDEFINITION ALTER COLUMN DESCRIPTION_ varchar(max);                                                                                                                           
ALTER TABLE dbo.CRE_BANDEJA_CARTCOMP_CRE ALTER COLUMN DETALLE_CUOTAS varchar(max);                                                                                                                  
ALTER TABLE dbo.QUEST_SL_TEMP_EXPLAIN1 ALTER COLUMN ACCESS_PREDICATES varchar(max);   
ALTER TABLE dbo.QUEST_SL_TEMP_EXPLAIN1 ALTER COLUMN FILTER_PREDICATES varchar(max);   
ALTER TABLE dbo.SYS_EXPORT_SCHEMA_01 ALTER COLUMN OBJECT_LONG_NAME varchar(max);                                                                                                                  
ALTER TABLE dbo.SYS_EXPORT_SCHEMA_01 ALTER COLUMN VALUE_T varchar(max);                                                                                                                           
ALTER TABLE dbo.SYS_EXPORT_SCHEMA_01 ALTER COLUMN USER_DIRECTORY varchar(max);                                                                                                                   
ALTER TABLE dbo.SYS_EXPORT_SCHEMA_01 ALTER COLUMN USER_FILE_NAME varchar(max);                                                                                                                    
ALTER TABLE dbo.SYS_EXPORT_SCHEMA_01 ALTER COLUMN FILE_NAME varchar(max);                                                                                                                          
ALTER TABLE dbo.SYS_EXPORT_SCHEMA_01 ALTER COLUMN OLD_VALUE varchar(max);                                                                                                                          
ALTER TABLE dbo.SYS_EXPORT_SCHEMA_01 ALTER COLUMN REMOTE_LINK varchar(max);                                                                                                                        
ALTER TABLE dbo.ITF_CONCILIACIONES ALTER COLUMN REGISTRO varchar(max);                                                                                                                          
ALTER TABLE dbo.JBPM_ACTION ALTER COLUMN EXPRESSION_ varchar(max);                                                                                                                         
ALTER TABLE dbo.JBPM_JOB ALTER COLUMN EXCEPTION_ varchar(max);                                                                                                                       
ALTER TABLE dbo.JBPM_TASKINSTANCE ALTER COLUMN DESCRIPTION_ varchar(max);                                                                                                                      
ALTER TABLE dbo.JBPM_TRANSITION ALTER COLUMN DESCRIPTION_ varchar(max);                                                                                                                    
ALTER TABLE dbo.CORREOS_NO_ENVIADOS ALTER COLUMN DATA varchar(max);                                                                                                                               
ALTER TABLE dbo.JBPM_VARIABLEINSTANCE ALTER COLUMN STRINGVALUE_ varchar(max);                                                                                                                      
ALTER TABLE dbo.JBPM_TASK ALTER COLUMN DESCRIPTION_ varchar(max);                                                                                                                     
ALTER TABLE dbo.DUMMY_TABLE ALTER COLUMN PERSONAS varchar(max);                                                                                                                            
ALTER TABLE dbo.TOAD_PLAN_TABLE ALTER COLUMN REMARKS varchar(max);     
ALTER TABLE dbo.TOAD_PLAN_TABLE ALTER COLUMN ACCESS_PREDICATES varchar(max);                                                                                                                
ALTER TABLE dbo.TOAD_PLAN_TABLE ALTER COLUMN FILTER_PREDICATES varchar(max);                                                                                                                
ALTER TABLE dbo.TOAD_PLAN_TABLE ALTER COLUMN PROJECTION varchar(max);                                                                                                                       
ALTER TABLE dbo.PM_BTPROCESS ALTER COLUMN RETURN_DESCRIPTION varchar(max);                                                                                                                 
ALTER TABLE dbo.PM_BTPROCESS ALTER COLUMN PARAMETERS varchar(max);                                                                                                                       
ALTER TABLE dbo.EVENTOS_TRANSACCION ALTER COLUMN CONDICION varchar(max);                                                                                                                         
ALTER TABLE dbo.EVENTOS_TRANSACCION ALTER COLUMN CAMPOS varchar(max);                                                                                                                            
ALTER TABLE dbo.ITF_MASTER_LINEAS ALTER COLUMN CONTENIDO varchar(max);                                                                                                                         
ALTER TABLE dbo.GERACAOHTML ALTER COLUMN VALOR varchar(max);                                                                                                                             
ALTER TABLE dbo.CLI_ALTAPERSONAS_MOROSOSALIMEN ALTER COLUMN NOMBRE varchar(max);                                                                                                                            
ALTER TABLE dbo.CLI_ALTAPERSONAS_MOROSOSALIMEN ALTER COLUMN NOMBRE2 varchar(max);                                                                                                                           
ALTER TABLE dbo.CLI_ALTAPERSONAS_MOROSOSALIMEN ALTER COLUMN APELLIDO varchar(max);                                                                                                                          
ALTER TABLE dbo.CLI_ALTAPERSONAS_MOROSOSALIMEN ALTER COLUMN APELLIDO2 varchar(max);                                                                                                                         
ALTER TABLE dbo.MANAGER_EXECUTE_WS ALTER COLUMN SERVICE_PATH varchar(max);                                                                                                                      
ALTER TABLE dbo.JBPM_MODULEDEFINITION ALTER COLUMN NAME_ varchar(max);                                                                                                                             
ALTER TABLE dbo.BITACORA_RESTRICCIONES ALTER COLUMN DESCRIPCION_RESTRICCION varchar(max);                                                                                                           
ALTER TABLE dbo.JBPM_COMMENT ALTER COLUMN MESSAGE_ varchar(max);                                                                                                                          
ALTER TABLE dbo.CORREOS_ENVIADOS  ALTER COLUMN DATA varchar(max);                                                                                                                              
ALTER TABLE dbo.JBPM_LOG ALTER COLUMN MESSAGE_ varchar(max);                                                                                                                          
ALTER TABLE dbo.JBPM_LOG ALTER COLUMN EXCEPTION_ varchar(max);                                                                                                                        
ALTER TABLE dbo.JBPM_LOG ALTER COLUMN OLDSTRINGVALUE_ varchar(max);                                                                                                                   
ALTER TABLE dbo.JBPM_LOG ALTER COLUMN NEWSTRINGVALUE_ varchar(max);                                                                                                                   
ALTER TABLE dbo.ITF_LOG_JASPER ALTER COLUMN DESCRIPCION varchar(max);
ALTER TABLE dbo.TMPPASAJEMOV ALTER COLUMN INDICATORS varchar(max);
ALTER TABLE dbo.AUDITO ALTER COLUMN INDICATORS varchar(max);
ALTER TABLE dbo.UNLOAD_TABLE ALTER COLUMN INDICATORS varchar(max);
ALTER TABLE dbo.MOVIMIENTOSRSP ALTER COLUMN INDICATORS varchar(max);
ALTER TABLE dbo.MOVIMIENTOS ALTER COLUMN INDICATORS varchar(max);
ALTER TABLE [dbo].[CONCEPTOSEXTRACTOS] DROP CONSTRAINT [PK_CONCEPTOSEXTRACTOS] WITH ( ONLINE = OFF );
ALTER TABLE dbo.CONCEPTOSEXTRACTOS ALTER COLUMN CODMENSAJE varchar(20) not null;
ALTER TABLE [dbo].[CONCEPTOSEXTRACTOS] ADD CONSTRAINT [PK_CONCEPTOSEXTRACTOS] PRIMARY KEY CLUSTERED ([CODMENSAJE] ASC,[IDIOMA] ASC) ON [PRIMARY];
')
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_AUXILIAR'')
drop index 	IDX_AUXILIAR on MOVIMIENTOS  ;') 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IX_SERVERS_CONNECTION_CONTROL'')
drop index 	IX_SERVERS_CONNECTION_CONTROL on SERVERS_CONTROL ;')  
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_MOVIMIENTO_REVERSAL'')
drop index 	IDX_MOVIMIENTO_REVERSAL on 	MOVIMIENTOS;')             
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_MOVIMIENTO_TIPOPROCESO_FECHAPROCESO'')
drop index 	IDX_MOVIMIENTO_TIPOPROCESO_FECHAPROCESO on 	MOVIMIENTOS;')
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_MOVIMIENTO_TIPOPROCESO'')
drop index 	IDX_MOVIMIENTO_TIPOPROCESO on MOVIMIENTOS;')         
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_FECHAHORA_BITACORA'')
drop index 	IDX_FECHAHORA_BITACORA on 	BITACORA;')                
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX$$_01880001'')
drop index 	IDX$$_01880001 on NUMERATORASIGNED ;')               
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''Indice_1582_1581'')
drop index 	Indice_1582_1581 on PYF_APODERADOS;')              
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IX_NUMASIG_AS_SUC_FP_EST'')
drop index 	IX_NUMASIG_AS_SUC_FP_EST on 	NUMERATORASIGNED ;')   
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''Indice_2086_2085'')
drop index 	Indice_2086_2085 on NUMERATORASIGNED;')            
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''Indice_184_183'')
drop index 	Indice_184_183 on CLI_LOCALIDADES ;')                
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_MOV_FECHAVAL'')
drop index 	IDX_MOV_FECHAVAL on 	MOVIMIENTOS_CONTABLES;')       
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IND2_GRL'')
drop index 	IND2_GRL on GRL_SALDOS_DIARIOS ;')                 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''ASIENTOS_IDX02'')
drop index 	ASIENTOS_IDX02 on ASIENTOS;') 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_PORCLIENTEC1803'')
drop index 	IDX_PORCLIENTEC1803 on 	SALDOS ;')                     
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''NBC_I_CON3_ASIENTOS'')
drop index 	NBC_I_CON3_ASIENTOS on ASIENTOS ;')                  
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''ASIENTOS_IDX05'')
drop index 	ASIENTOS_IDX05 on ASIENTOS;')                        
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''PM_BTPROCESS_STATICS'')
drop index 	PM_BTPROCESS_STATICS on PM_BTPROCESS ;')           
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''PM_BTPROCESS_DATE'')
drop index 	PM_BTPROCESS_DATE on PM_BTPROCESS ;')               
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''PM_BTPROCESS_NAME'')
drop index 	PM_BTPROCESS_NAME on PM_BTPROCESS ;')               
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''CR_SALDOS_INDEX1'')
drop index 	CR_SALDOS_INDEX1 on SALDOS;')                      
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_SALDOS_1730_OTROS'')
drop index 	IDX_SALDOS_1730_OTROS on SALDOS;')                  
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_AUXBANCENTASA'')
drop index 	IDX_AUXBANCENTASA on SALDOS;')                      
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_SALDOS_1730'')
drop index 	IDX_SALDOS_1730 on SALDOS;')                          
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''SALDOS_INDEX1'')
drop index 	SALDOS_INDEX1 on SALDOS ;')                         
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''PK_INDICE2_SALDOS'')
drop index 	PK_INDICE2_SALDOS on SALDOS;')                      
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_RUBROFECHA'')
drop index 	IDX_RUBROFECHA on MOVIMIENTOS_CONTABLES;')           
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_MOV_MAYOR'')
drop index 	IDX_MOV_MAYOR on MOVIMIENTOS_CONTABLES;')           
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''NBC_I_CON3_MOVCONT'')
drop index 	NBC_I_CON3_MOVCONT on MOVIMIENTOS_CONTABLES;')       
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IND3_MOVIMIENTOS_CONTABLES_03'')
drop index 	IND3_MOVIMIENTOS_CONTABLES_03 on MOVIMIENTOS_CONTABLES;')     
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_MOV_CONSULTA'')
drop index 	IDX_MOV_CONSULTA on MOVIMIENTOS_CONTABLES ;')      
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_MOV_RUBRO'')
drop index 	IDX_MOV_RUBRO on MOVIMIENTOS_CONTABLES ;')          
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''CR_SALDOS_OPERACIONES'')
drop index 	CR_SALDOS_OPERACIONES on SALDOS;')  
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''TEMP_CLI_ACTIVIDAD_ECONOMICA_X_CODIGO_ACTIVIDAD_Y_CODIGO_PERSONA_CLIENTE'')
drop index 	TEMP_CLI_ACTIVIDAD_ECONOMICA_X_CODIGO_ACTIVIDAD_Y_CODIGO_PERSONA_CLIENTE on TEMP_CLI_ACTIVIDAD_ECONOMICA ;')    
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''TEMP_CLI_ACTIVIDAD_ECONOMICA_X_CODIGO_PERSONA_CLIENTE'')
drop index TEMP_CLI_ACTIVIDAD_ECONOMICA_X_CODIGO_PERSONA_CLIENTE on TEMP_CLI_ACTIVIDAD_ECONOMICA ;') 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''CLI_ACTIVIDAD_ECONOMICA_X_CODIGO_ACTIVIDAD_Y_CODIGO_PERSONA_CLIENTE'')
drop index 	CLI_ACTIVIDAD_ECONOMICA_X_CODIGO_ACTIVIDAD_Y_CODIGO_PERSONA_CLIENTE on CLI_ACTIVIDAD_ECONOMICA;')   
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''I_SALDOS'')
drop index 	I_SALDOS on SALDOS;') 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''INDEX_HISTORIA_VISTA'')
drop index 	INDEX_HISTORIA_VISTA on HISTORIA_VISTA ;') 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IX_HISVISTA_GROUP'')
drop index 	IX_HISVISTA_GROUP on HISTORIA_VISTA;')   
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_PORCATEGORIA'')
drop index 	IDX_PORCATEGORIA on CLI_CLIENTES;')  
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''INDEX_MOV'')
drop index 	INDEX_MOV on GRL_DETALLE_CONTABILIDAD;') 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''Indice_1170_1169'')
drop index 	Indice_1170_1169 on CLI_PERSONASJURIDICAS;') 
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''Indice_2049_2048'')
drop index 	Indice_2049_2048 on CLI_PERSONASFISICAS;')  
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_BS_HISTORIA_PLAZO_FPROCMOV'')
drop index 	IDX_BS_HISTORIA_PLAZO_FPROCMOV on BS_HISTORIA_PLAZO;')
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''Indice_2502_2501'')
drop index 	Indice_2502_2501 on 	BS_HISTORIA_PLAZO;')  
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IDX_BS_HISTORIA_PLAZO_TIPOMOV'')
drop index 	IDX_BS_HISTORIA_PLAZO_TIPOMOV on BS_HISTORIA_PLAZO ;')
execute(' IF  EXISTS (select * from  sys.indexes where  name = ''IX_BS_PAYS_DETAIL'')
drop index  IX_BS_PAYS_DETAIL on BS_PAYS_DETAIL;')


