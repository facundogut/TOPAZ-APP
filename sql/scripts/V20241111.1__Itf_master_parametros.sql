EXECUTE('
delete from itf_master_parametros where codigo=242
INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (242, 0, ''AGIP RENDICION CONT'', ''AGIP RENDICION CONTADOR'', '''', '''', 0, 0, ''20000130'', 0, 0, 0)

drop table if exists itf_historico_agip_rendicion
CREATE TABLE dbo.itf_historico_agip_rendicion
	(
	fecha_proceso                     DATETIME,
	tipo_operacion                    VARCHAR (1),
	codigo_norma                      VARCHAR (3),
	fecha_retencion_percepcion        DATETIME,
	tipo_comprobante_origen_retencion VARCHAR (2),
	letra_comprobante                 VARCHAR (1),
	nro_comprobante                   NUMERIC (16),
	fecha_comprobante                 DATETIME,
	monto_comprobante                 NUMERIC (15, 2),
	nro_certificado_propio            VARCHAR (16),
	tipo_doc_retenido_percibido       VARCHAR (1),
	nro_doc_retenido_percibido        NUMERIC (11),
	situacion_ibb_ret_percibido       VARCHAR (1),
	nro_inscripcion_ibb_ret_percibido NUMERIC (11),
	situacion_iva_ret_percibido       VARCHAR (1),
	razon_social_retenido             VARCHAR (30),
	importe_otros_conceptos           NUMERIC (15, 2),
	importe_iva                       NUMERIC (15, 2),
	monto_sujeto_ret_percepcion       NUMERIC (15, 2),
	alicuota                          NUMERIC (4, 2),
	retencion_percepcion_practicada   NUMERIC (15, 2),
	monto_total_ret_percibido         NUMERIC (15, 2),
	aceptacion                        VARCHAR (1),
	fecha_aceptacion_express          DATETIME
	)



')