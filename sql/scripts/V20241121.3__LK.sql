EXECUTE('delete from dbo.ITF_MASTER where ID in (217,301,302,303,304,305,306,309,312,316,317)');

EXECUTE('
	INSERT INTO ITF_MASTER (TZ_LOCK,ID,DESCRIPCION,OBJ_KETTLE,P0_MODO,P0_TIPO,P0_CAPTION,P0_CONSTANTE,P1_MODO,P1_TIPO,P1_CAPTION,P1_CONSTANTE,P2_MODO,P2_TIPO,P2_CAPTION,P2_CONSTANTE,P3_MODO,P3_TIPO,P3_CAPTION,P3_CONSTANTE,P4_MODO,P4_TIPO,P4_CAPTION,P4_CONSTANTE,P5_MODO,P5_TIPO,P5_CAPTION,P5_CONSTANTE,P6_MODO,P6_TIPO,P6_CAPTION,P6_CONSTANTE,P7_MODO,P7_TIPO,P7_CAPTION,P7_CONSTANTE,P8_MODO,P8_TIPO,P8_CONSTANTE,P8_CAPTION,P9_MODO,P9_TIPO,P9_CAPTION,P9_CONSTANTE,TIPO_OBJ,COMENTARIO,ID_REPORTE,MODO_EJECUCION,KETTLE_NAME) VALUES
	 (0,217,''DJP ordenes debitos'',''PUNTO_ENTRADA_LOG_PA.kjb'','''','''','''','' '','''','''','''','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_DJP_ORDDEB.kjb''),
	 (0,301,''2.8.57 CLS - ECHEQ'',''PUNTO_ENTRADA_LOG_PA.kjb'','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_CLS_ECHEQ.kjb''),
	 (0,302,''2.12.15 - 2.12.16 ECOM-SSMREPR15x'',''PUNTO_ENTRADA_LOG_PA.kjb'','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_ECOM_RECHAZOS.kjb''),
	 (0,303,''2.8.68 CLS - EC_CANJE'',''PUNTO_ENTRADA_LOG_PA.kjb'','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_ECHEQ_CANJE.kjb''),
	 (0,304,''2.8.69 CLS - EC RECHAZO CANJE'',''PUNTO_ENTRADA_LOG_PA.kjb'','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_CLS_EC_RECHAZO_CANJE.kjb''),
	 (0,305,''2.14.79 LK - EXTRACT EMISION ECHEQ'',''PUNTO_ENTRADA_LOG_PA.kjb'','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_LK_EXTRACT_EMISION_ECHEQ.kjb''),
	 (0,312,''1.31.5 NBCH24 - ECH EXTRACT EMISION'',''PUNTO_ENTRADA_LOG_PA.kjb'','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_LK_EXTRACT_EMISION_ECH.kjb''),
	 (0,316,''2.8.58 CLS - EC_CADUCADO'',''PUNTO_ENTRADA_LOG_PA.kjb'','''','''','''','' '','''','''','''','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_CLS_EC_CADUCADO.kjb''),
	 (0,317,''1.37.1 Debitia'',''PUNTO_ENTRADA_LOG_PA.kjb'','''','''','''','' '','''','''','''','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'','' '',0,''M'',''ITF_DEBITIA.kjb'');
');
EXECUTE('
	IF OBJECT_ID (''dbo.BS_PAYS_DETAIL_MIGRADOS'') IS NOT NULL
		DROP TABLE dbo.BS_PAYS_DETAIL_MIGRADOS
')

EXECUTE('CREATE TABLE BS_PAYS_DETAIL_MIGRADOS
	(
	TZ_LOCK                   NUMERIC (15) DEFAULT ((0)),
	SALDOS_JTS_OID            NUMERIC (10) DEFAULT ((0)) NOT NULL,
	CUOTA                     NUMERIC (4) NOT NULL,
	VENCIMIENTO               DATETIME,
	FECHA_PAGO                DATETIME,
	DIAS_ATRASO               NUMERIC (5) DEFAULT ((0)),
	TASA_INTERES              NUMERIC (11, 7),
	CAPITAL                   NUMERIC (15, 2) DEFAULT ((0)),
	INTERES                   NUMERIC (15, 2) DEFAULT ((0)),
	IVA_INTERES               NUMERIC (15, 2) DEFAULT ((0)),
	IVA_PERCEPCION_INTERES    NUMERIC (15, 2) DEFAULT ((0)),
	MORA                      NUMERIC (15, 2) DEFAULT ((0)),
	IVA_MORA                  NUMERIC (15, 2) DEFAULT ((0)),
	IVA_PERCEPCION_MORA       NUMERIC (15, 2) DEFAULT ((0)),
	PUNITORIOS                NUMERIC (15, 2) DEFAULT ((0)),
	IVA_PUNITORIOS            NUMERIC (15, 2) DEFAULT ((0)),
	IVA_PERCEPCION_PUNITORIOS NUMERIC (15, 2) DEFAULT ((0)),
	GASTOS                    NUMERIC (15, 2) DEFAULT ((0)),
	SUBSIDIO                  NUMERIC (15, 2) DEFAULT ((0)),
	OTROS                     NUMERIC (15, 2) DEFAULT ((0)),
	SEGUROS                   NUMERIC (15, 2) DEFAULT ((0)),
	COMISION                  NUMERIC (15, 2) DEFAULT ((0)),
	PERCEPCION_IIBB           NUMERIC (15, 2) DEFAULT ((0)),
	CANON_DE_LEASING          NUMERIC (15, 2) DEFAULT ((0)),
	CONSTRAINT IDX1_BS_PAYS_DETAIL_MIGRADOS PRIMARY KEY (SALDOS_JTS_OID, CUOTA)
	)')
