EXECUTE('DROP VIEW IF EXISTS dbo.VW_ITF_LINK_SOLICITUDES;')
EXECUTE('
CREATE VIEW dbo.VW_ITF_LINK_SOLICITUDES AS SELECT 

	LEFT(CAST(tj.TIPO_SOLICITUD as VARCHAR), 6) AS cod_transaccion,

	''0311'' AS cod_entidad, 
	
	RIGHT(replicate(''0'', 6) + (SELECT ALFA FROM PARAMETROSGENERALES WHERE [CODIGO]=705), 6) AS gru_operador,
	
		
	
	replicate(''0'', 16) AS nro_terminal, 
	
	replicate(''0'', 10) AS id, 
	

	 LEFT(concat(convert(varchar, tj.FECHA_SOLICITUD,112) , replace(convert(varchar, tj.HORA_SOLICITUD,114),'':'','''')), 16) AS hora_dia,
	 
	''00'' AS nro_tabla, 
	
	replicate(''0'', 5) AS nro_version, 
	
	RIGHT(NRO_AUDITORIA ,22) AS aud_modif,
	RIGHT(NRO_AUDITORIA ,22) AS aud_alta,	
	RIGHT(NRO_AUDITORIA ,22) AS aud_confir,
	LEFT(concat(tj.NRO_TARJETA_BASE, replicate('' '', 19)) , 19) AS nro_raiz,
	
	LEFT(concat(tj.PREFIJO, replicate('' '', 11)) , 11) AS prefijo,	
	
  
	RIGHT(concat(replicate(''0'', 12), COD_CLIENTE), 12) AS nro_cliente,  		
				
	RIGHT(concat(replicate(''0'', 4) , SUCURSAL_CTA_PRIMARIA) ,4) AS sucursal,
	LEFT(concat(tj.TIPO_TARJETA, replicate('' '', 4)) , 4) AS producto,	
	
	''1'' AS est_raiz,	
		
	RIGHT(concat(''00'', TIPO_CTA_PRIMARIA), 2) AS tpo_cuenta_ppal,
	
	LEFT(concat(tjc.NUMERO_CUENTA_PBF, replicate('' '', 19)), 19) AS nro_cuenta,
			
	RIGHT((CASE WHEN TIPO_DOCUMENTO_AD IS NULL THEN ''N/D'' ELSE TIPO_DOCUMENTO_AD END), 3) AS tpo_doc_apoderado,
	 
	RIGHT(concat(replicate(''0'', 9), (CASE WHEN NRO_DOCUMENTO_AD IS NULL THEN replicate(''0'', 9) ELSE NRO_DOCUMENTO_AD END)), 9) AS nro_doc_apoderado,
	
	RIGHT((CASE WHEN APELL_AD IS NOT NULL AND rtrim(ltrim(APELL_AD)) <> '''' THEN concat(replicate('' '', 15), APELL_AD) ELSE replicate(''.'', 15) END), 15) AS apellido_apoderado,
	
	RIGHT( (CASE WHEN NOMBRE_AD IS NOT NULL AND rtrim(ltrim(NOMBRE_AD)) <> '''' THEN concat(replicate('' '', 15), NOMBRE_AD) ELSE replicate(''.'', 15) END) ,15) AS nombre_apoderado,
				
	replicate(''0'', 6) AS cod_ente,  		
			
	RIGHT( concat(''00'', CANT_MIEMBROS) ,2) AS cant_miembros,
	
	RIGHT(concat(''0'', TIPO_DOMICILIO) ,1) AS dom_pin,
	
	RIGHT(concat(''0'', TIPO_DOMICILIO) ,1) AS dom_plastico,	
	
	LEFT((CASE WHEN (SELECT CALLE FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR'') IS NOT NULL THEN concat(
	
	(SELECT CALLE FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR''), replicate('' '', 45)) ELSE replicate(''.'', 45) END)  , 45) AS calle,
	
	LEFT((CASE WHEN (SELECT NUMERO FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR'') IS NOT NULL THEN concat(
	
	(SELECT NUMERO FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR''), replicate('' '', 5)) ELSE replicate(''.'', 5) END)  , 5) AS nro_calle,	
	
	LEFT((CASE WHEN (SELECT PISO FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR'') IS NOT NULL THEN concat(
	
	(SELECT PISO FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR''), replicate('' '', 2)) ELSE replicate(''.'', 2) END)  , 2) AS piso,	
	
	LEFT((CASE WHEN (SELECT DEPARTAMENTO FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR'') IS NOT NULL THEN concat(
	
	(SELECT DEPARTAMENTO FROM CLI_DIRECCIONES WHERE tj.COD_CLIENTE = ID AND FORMATO = ''PF'' AND TIPODIRECCION = ''PR''), replicate('' '', 3)) ELSE replicate(''.'', 3) END)  , 3) AS dpto,		
	
	LEFT(CASE WHEN TIPO_DOMICILIO = ''P'' AND cloc.DESCRIPCION_DIM3 IS NOT NULL AND rtrim(ltrim(cloc.DESCRIPCION_DIM3)) <> '''' THEN concat(cloc.DESCRIPCION_DIM3, replicate('' '', 20)) ELSE replicate('' '', 20) END , 20) AS localidad,
	
	LEFT(CASE WHEN TIPO_DOMICILIO = ''P'' AND cl.CPA_NUEVO IS NOT NULL THEN CPA_NUEVO ELSE replicate(''.'', 15) END, 15) AS cod_postal,
	
	LEFT(concat((SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE [CODIGO_INTERFACE] = 3 AND ALFA_2 = tj.PROVINCIA), replicate(''.'', 2)), 2) AS cod_provincia,
  	 	
	LEFT(CASE WHEN (SELECT NUMERO FROM CLI_TELEFONOS WHERE TIPO = ''PE'' AND ID = tj.COD_CLIENTE AND ORDINAL = 1) IS NOT NULL THEN concat((SELECT NUMERO FROM CLI_TELEFONOS WHERE TIPO = ''PE'' AND ID = tj.COD_CLIENTE AND ORDINAL = 1), replicate('' '', 15)) ELSE replicate(''.'', 15) END ,15) AS telefono,
	
	LEFT(CASE WHEN tj.TIPO_DOMICILIO = ''L'' AND cl.CALLE IS NOT NULL AND rtrim(ltrim(cl.CALLE)) <> '''' THEN concat(cl.CALLE, replicate('' '', 45)) ELSE replicate(''.'', 45) END, 45) AS calle_dom_laboral,
	
	LEFT((CASE WHEN tj.TIPO_DOMICILIO = ''L'' AND cl.NUMERO IS NOT NULL AND rtrim(ltrim(cl.NUMERO)) <> '''' THEN concat(cl.NUMERO, replicate('' '', 5)) ELSE replicate(''.'', 5) END), 5) AS nro_dom_laboral,
	
	LEFT((CASE WHEN tj.TIPO_DOMICILIO = ''L'' AND cl.PISO IS NOT NULL AND rtrim(ltrim(cl.PISO)) <> '''' THEN concat(cl.PISO, replicate('' '', 2)) ELSE replicate(''.'', 2) END), 2) AS piso_dom_laboral, 
	
	LEFT((CASE WHEN tj.TIPO_DOMICILIO = ''L'' AND cl.DEPARTAMENTO IS NOT NULL AND rtrim(ltrim(cl.DEPARTAMENTO)) <> '''' THEN concat(cl.DEPARTAMENTO, replicate('' '', 3)) ELSE replicate(''.'', 3) END), 3) AS dpto_dom_laboral,			
	
	LEFT((CASE WHEN tj.TIPO_DOMICILIO = ''L'' AND cloc.DESCRIPCION_DIM3 IS NOT NULL AND rtrim(ltrim(cloc.DESCRIPCION_DIM3)) <> '''' THEN concat(cloc.DESCRIPCION_DIM3, replicate('' '', 20)) ELSE replicate(''.'', 20) END), 20) AS localidad_dom_laboral,			
	
	LEFT((CASE WHEN tj.TIPO_DOMICILIO = ''L'' AND cl.CPA_NUEVO IS NOT NULL AND rtrim(ltrim(cl.CPA_NUEVO)) <> '''' THEN concat(cl.CPA_NUEVO, replicate('' '', 15)) ELSE replicate(''.'', 15) END), 15) AS cod_postal_dom_laboral,
	
	LEFT((CASE WHEN tj.TIPO_DOMICILIO = ''L'' AND tj.PROVINCIA IS NOT NULL AND rtrim(ltrim(tj.PROVINCIA)) <> '''' THEN concat(tj.PROVINCIA, replicate('' '', 2)) ELSE replicate(''.'', 2) END), 2) AS provincia_dom_laboral,	
	
	replicate(''0'', 15) AS tel_dom_laboral, 
	
	RIGHT(NRO_AUDITORIA ,22) AS persona_aud_modif,
	
	RIGHT(NRO_AUDITORIA ,22) AS persona_aud_alta,
	
	RIGHT(NRO_AUDITORIA ,22) AS persona_aud_confir,
	
	RIGHT((CASE WHEN TIPO_DOCUMENTO IS NULL THEN ''N/D'' ELSE TIPO_DOCUMENTO END), 3) AS persona_tpo_doc,
	 
	RIGHT(concat(replicate(''0'', 9), (CASE WHEN NRO_DOCUMENTO IS NULL THEN replicate(''0'', 9) ELSE NRO_DOCUMENTO END)), 9) AS persona_nro_doc,
	
	RIGHT((CASE WHEN APELLIDO IS NOT NULL AND rtrim(ltrim(APELLIDO)) <> '''' THEN concat(replicate('' '', 15), APELLIDO) ELSE replicate(''.'', 15) END), 15) AS persona_apllido,
	
	RIGHT( (CASE WHEN NOMBRE IS NOT NULL AND rtrim(ltrim(NOMBRE)) <> '''' THEN concat(replicate('' '', 15), NOMBRE) ELSE replicate(''.'', 15) END) ,15) AS persona_nombre,
	
	LEFT(SEXO, 1) AS persona_sexo,		
	
	SUBSTRING(CAST(CUIL AS VARCHAR), 1, 2) AS cuil_cod,  	
	
	RIGHT(replicate('''', 9) + SUBSTRING(CAST(CUIL AS VARCHAR), 3, 8),9) AS cuil_nro_doc,  		
	
	SUBSTRING(CAST(CUIL AS VARCHAR), 11, 1) AS cuil_dig_verificador, 	 
		
	replicate(''.'', 20) AS cuil_ocupacion,
	
	convert(varchar, (SELECT CONVERT(Datetime, FECHA_NAC, 120)),112) AS cuil_fch_nac, 
	LEFT(concat(ESTADO_CIVIL, replicate('' '', 1)), 1) AS cuil_est_civil,
		
	RIGHT(concat(replicate('' '', 15), ''ARGENTINA'') ,15) AS cuil_nacionalidad,
	
	replicate(''.'', 30) AS cuil_observaciones, 
		
	RIGHT(NRO_AUDITORIA ,22) AS tt1_aud_modif,
	
	RIGHT(NRO_AUDITORIA ,22) AS tt1_aud_alta,
	
	RIGHT(NRO_AUDITORIA ,22) AS tt1_aud_confir,
	
	LEFT(concat(NRO_TARJETA_BASE, replicate('' '', 19)), 19) AS tt1_nro_tarjeta,
	
	LEFT(CASE WHEN Miembro IS NOT NULL AND rtrim(ltrim(Miembro)) <> '''' THEN Miembro ELSE ''0'' END, 1) AS tt1_miembro,
		
	RIGHT((CASE WHEN TIPO_DOCUMENTO IS NULL THEN ''N/D'' ELSE TIPO_DOCUMENTO END), 3) AS tt1_tpo_doc,
	 
	RIGHT(concat(replicate(''0'', 9), (CASE WHEN NRO_DOCUMENTO IS NULL THEN replicate(''0'', 9) ELSE NRO_DOCUMENTO END)), 9) AS tt1_nro_doc,
	
	LEFT(CASE WHEN NUM_VERSION IS NOT NULL AND rtrim(ltrim(NUM_VERSION)) <> '''' THEN NUM_VERSION ELSE ''0'' END, 1) AS tt1_nro_version,
	
	LEFT(CASE WHEN DIGITO_VERIFICADOR IS NOT NULL AND rtrim(ltrim(DIGITO_VERIFICADOR)) <> '''' THEN DIGITO_VERIFICADOR ELSE ''0'' END, 1) AS tt1_dig_verificdor,
	
	''01'' AS tt1_cat_comision,  
	
	RIGHT(CASE WHEN LIMITE_DEBITO IS NOT NULL AND rtrim(ltrim(LIMITE_DEBITO)) <> '''' THEN concat(''00'', LIMITE_DEBITO) ELSE ''00'' END, 2) AS tt1_cod_limit_debito,
	
	RIGHT(CASE WHEN LIMITE_CREDITO IS NOT NULL AND rtrim(ltrim(LIMITE_CREDITO)) <> '''' THEN concat(''00'', LIMITE_CREDITO) ELSE ''00'' END, 2) AS tt1_cod_limit_credito,
	
	RIGHT((CASE WHEN TIPO_TARJETA IS NOT NULL AND rtrim(ltrim(TIPO_TARJETA)) <> '''' THEN concat(''00'',TIPO_TARJETA) ELSE ''00'' END) , 2) AS tt1_tpo_tarjeta,
	
	''072'' AS tt1_meses_vigencia, 
	
	(CASE WHEN tj.ID_SOLICITUD = 120005 OR tj.ID_SOLICITUD = 120006 THEN (SELECT RIGHT(replicate(''0'', 4) + CAST(year(VENCIMIENTO) AS VARCHAR(4)), 4) FROM TJD_TARJETAS WHERE ID_TARJETA = tj.nro_tarjeta_completa) ELSE replicate(''0'', 4) END) AS tt1_fch_vencimiento,
	
	LEFT(CASE WHEN tj.ESTADO = ''I'' THEN 0 ELSE 1 END, 1) AS tt1_estado,
	
	(SELECT RIGHT(''00'' + CAST(count(*) AS VARCHAR(2)),2) FROM TJD_REL_TARJETA_CUENTA WHERE ID_TARJETA = tj.nro_tarjeta_completa) AS tt1_cant_cuen_asoc,	 
	
	RIGHT(concat(replicate(''0'', 12), tj.COD_CLIENTE) ,12) AS tt1_ref_cliente,
	
	replicate(''0'', 2) AS tt1_cant_pin_impresos,
	
	(CASE WHEN tj.ID_SOLICITUD = 120005 OR tj.ID_SOLICITUD = 120006 THEN ''N'' ELSE ''D'' END) AS marca_pin, 
	
	replicate(''0'', 8) AS fch_emision_pin,
	
	replicate(''0'', 8) AS fch_entrega_pin,
	
	replicate(''0'', 2) AS cant_plasticos,
	
	replicate(''N'', 1) AS marca_plastico,
	
	convert(varchar, (SELECT CONVERT(Datetime, FECHA_SOLICITUD, 120)),112) AS fch_emision_plastico,  	
	
	(SELECT convert(varchar, (SELECT CONVERT(Datetime, FECHA_ENTREGA, 120)),112) FROM TJD_TARJETAS WHERE ID_TARJETA=tj.nro_tarjeta_completa) AS fch_entrega_plastico,  	
	
	(CASE WHEN tj.ID_SOLICITUD = 120005 OR tj.ID_SOLICITUD = 120006 THEN replicate(''0'', 16) ELSE replicate(''0'', 16) END) AS cod_denuncia,
	
	replicate(''0'', 4) AS grupo_afinidad,
	
	dbo.itf_cuentas_LINK(tj.ID_SOLICITUD, 16) AS cuentas,
	
	replicate(''0'', 19) AS nro_tarj_anterior,
	
	replicate('' '', 1) AS filler,
	
	''EE'' AS tpo_emision,
	
	RIGHT(NRO_AUDITORIA ,22) AS dc_audit_alta,

	RIGHT(NRO_AUDITORIA ,22) AS dc_audit_modif,
	
	replicate(''.'', 60) AS dc_calle,
	
	replicate(''.'', 10) AS dc_numero,
	
	replicate(''.'', 2) AS dc_piso,
	
	replicate(''.'', 3) AS dc_dpto,
	
	replicate(''.'', 30) AS dc_provincia,
	
	replicate(''.'', 40) AS dc_localidad,
	
	replicate(''.'', 4) AS tp_cod_area,
	
	replicate(''.'', 10) AS tp_nro_tel,
	
	replicate(''.'', 4) AS tl_cod_area,
	
	replicate(''.'', 10) AS tl_nro_tel,
	
	replicate(''.'', 5) AS tl_nro_interno,
		
	replicate(''.'', 4) AS tc_cod_area,
	
	replicate(''.'', 10) AS tc_nro_cel, 
	
	replicate(''.'', 100) AS tc_email,
	
	replicate('' '', 85) AS tc_filler,
	
	''*'' AS etx,  
	
	''*'' AS null_filler, 
	
	tj.FECHA_SOLICITUD,
	tj.ID_SOLICITUD,
	tj.ESTADO
	
FROM TJD_SOLICITUD_LINK tj 

LEFT JOIN CLI_DIRECCIONES cl ON tj.COD_CLIENTE=cl.ID AND cl.FORMATO=''CL'' AND cl.TIPODIRECCION=tj.TIPO_DOMICILIO AND cl.ORDINAL_DIR=tj.ORDINAL
	
LEFT JOIN CLI_LOCALIDADES cloc ON cloc.[CODIGOPAIS]=32 AND cloc.DIM1=cl.PROVINCIA AND cloc.DIM2=cl.DEPARTAMENTO AND cloc.DIM3=cl.LOCALIDAD
	
JOIN TJD_SOLICITUD_CUENTAS_LINK tjc ON tj.ID_SOLICITUD = tjc.ID_SOLICITUD
	
WHERE tj.TZ_LOCK=0;
')