execute('
IF  EXISTS (select * from sys.objects where  name = ''VW_ITF_CONCILIACIONES_BANRED'')
drop view VW_ITF_CONCILIACIONES_BANRED;
IF  EXISTS (select * from sys.objects where  name = ''VW_ITF_DEPOSITO_RECH'')
drop view VW_ITF_DEPOSITO_RECH;
IF  EXISTS (select * from sys.objects where  name = ''VW_ITF_RECAUDACIONES'')
drop view VW_ITF_RECAUDACIONES;
IF  EXISTS (select * from sys.objects where  name = ''VW_JBPM_PROC_INST_COBI'')
drop view VW_JBPM_PROC_INST_COBI;
IF  EXISTS (select * from sys.objects where  name = ''VW_JBPM_PROC_INST_LCE'')
drop view VW_JBPM_PROC_INST_LCE;
IF  EXISTS (select * from sys.objects where  name = ''VW_ITF_EMERIX_VINCULACIONES'')
drop view VW_ITF_EMERIX_VINCULACIONES;
IF  EXISTS (select * from sys.objects where  name = ''VW_ITF_EMERIX_RELACIONES'')
drop view VW_ITF_EMERIX_RELACIONES;
IF  EXISTS (select * from sys.objects where  name = ''mia'')
drop view mia;
IF  EXISTS (select * from sys.objects where  name = ''mia1'')
drop view mia1;
IF  EXISTS (select * from sys.objects where  name = ''VW_TARJETAS_DEBITO'')
drop view VW_TARJETAS_DEBITO;
IF  EXISTS (select * from sys.objects where  name = ''gap31'')
drop view gap31;
IF  EXISTS (select * from sys.objects where  name = ''VW_NOM_DIR_PERSONAS'')
drop view VW_NOM_DIR_PERSONAS;
IF  EXISTS (select * from sys.objects where  name = ''VW_PERSONASCOMPONENCLIENTE'')
drop view VW_PERSONASCOMPONENCLIENTE;
IF  EXISTS (select * from sys.objects where  name = ''MC_CTADEBITAR'')
drop view MC_CTADEBITAR;
IF  EXISTS (select * from sys.objects where  name = ''VW_MOV_CONFORMADOS'')
drop view VW_MOV_CONFORMADOS;
IF  EXISTS (select * from sys.objects where  name = ''YEAR_$IMPL'')
drop view PEPE22;
IF  EXISTS (select * from sys.objects where  name = ''PEPE22'')
drop view VW_SALDOS_TARJETA;
IF  EXISTS (select * from sys.objects where  name = ''VW_AUT_BUZONES'')
drop view VW_AUT_BUZONES;
IF  EXISTS (select * from sys.objects where  name = ''VW_TJD_DOCUMENTOS_ALTAS'')
drop view VW_TJD_DOCUMENTOS_ALTAS;
IF  EXISTS (select * from sys.objects where  name = ''VW_CUENTAS_DPF_copia'')
drop view VW_CUENTAS_DPF_copia;
IF  EXISTS (select * from sys.objects where  name = ''VW_CLI_ACTIVIDAD_ECONOMICA'')
drop view VW_CLI_ACTIVIDAD_ECONOMICA;
IF  EXISTS (select * from sys.objects where  name = ''VW_Grabo_CHE_RECHAZADOS'')
drop view VW_Grabo_CHE_RECHAZADOS;
IF  EXISTS (select * from sys.objects where  name = ''VW_Grabo_CHE_RECHAZADOS_prueba'')
drop view VW_Grabo_CHE_RECHAZADOS_prueba;
IF  EXISTS (select * from sys.objects where  name = ''VW_COMISION_PREGIRO'')
drop view VW_COMISION_PREGIRO;
IF  EXISTS (select * from sys.objects where  name = ''VW_COMISION_PREGIRO_SALDOS'')
drop view VW_COMISION_PREGIRO_SALDOS;
IF  EXISTS (select * from sys.objects where  name = ''VW_CONCILIACIONBANRED_BANDEJA'')
drop view VW_CONCILIACIONBANRED_BANDEJA;
IF  EXISTS (select * from sys.objects where  name = ''VW_ITF_EMERIX_CUOTAS'')
drop view VW_ITF_EMERIX_CUOTAS;
IF  EXISTS (select * from sys.objects where  name = ''VW_CONTROL_BASE_CHEQUES_01'')
drop view VW_CONTROL_BASE_CHEQUES_01;
IF  EXISTS (select * from sys.objects where  name = ''VW_CONTROL_BASE_CHEQUES_07'')
drop view VW_CONTROL_BASE_CHEQUES_07;
IF  EXISTS (select * from sys.objects where  name = ''VW_DATOS_FACTURACION'')
drop view VW_DATOS_FACTURACION;
')