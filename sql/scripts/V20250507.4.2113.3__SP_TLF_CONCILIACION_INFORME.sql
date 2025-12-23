
EXEC('
CREATE OR ALTER PROCEDURE dbo.SP_TLF_CONCICLIACION_INFORME
	@extorno_codigo NUMERIC(3,0),
	@extorno_resultado VARCHAR(4000),
	@jts_oid_tp NUMERIC(30),
	@resultado VARCHAR(35) OUT
AS
BEGIN
	SET @resultado = ''DESCONOCIDO'';

	BEGIN TRY
		-- Declarar variables
		DECLARE 
			@ID_CABECERA BIGINT,
			@ID_DETALLE BIGINT,
			@LKTRAD VARCHAR(6),
			@LKTRAT VARCHAR(8),
			@LKSEQN VARCHAR(12),
			@LKTERM VARCHAR(16),
			@COD_MSJ_H2H VARCHAR(6),
			@LKFROM VARCHAR(28),
			@LKTOAC VARCHAR(28),
			@LKORIG NUMERIC(3,0),
			@LKAMT1 VARCHAR(12),
			@IMPORTE NUMERIC(19,2),
			@LKTYP VARCHAR(4),
			@ASIENTO_ORIGINAL_SUCURSAL NUMERIC(12,0),
			@ASIENTO_ORIGINAL_FECHA DATETIME,
			@ASIENTO_ORIGINAL_NUMERO NUMERIC(15,0),
			@ASIENTO_SUCURSAL NUMERIC(12,0),
			@ASIENTO_FECHA DATETIME,
			@ASIENTO_NUMERO NUMERIC(15,0),
			@JTS_OID_TP_ACTUALIZAR NUMERIC(18,0),
			@ID_DETALLE_ACTUALIZAR BIGINT;

		-- Obtener clave link
		SELECT 
			@ID_CABECERA=ID_CABECERA,
			@ID_DETALLE=ID_DETALLE,
			@LKTRAD=LKTRAD,
			@LKTRAT=LKTRAT,
			@LKSEQN=LKSEQN,
			@LKTERM=LKTERM,
			@COD_MSJ_H2H=COD_MSJ_H2H,
			@LKFROM=LKFROM,
			@LKTOAC=LKTOAC,
			@LKORIG=LKORIG,
			@LKAMT1=LKAMT1,
			@IMPORTE=IMPORTE,
			@ASIENTO_ORIGINAL_FECHA=ASIENTO_FECHA,
			@ASIENTO_ORIGINAL_SUCURSAL=ASIENTO_SUCURSAL,
			@ASIENTO_ORIGINAL_NUMERO=ASIENTO_NUMERO
		FROM TLF_CONCILIACION_DETALLE WITH (NOLOCK)
		WHERE JTS_OID_TP = @jts_oid_tp

		----------------------------------------------------------------------------------------------------
		-- CUANDO EL EXTORNO FUÉ UN ÉXITO
		----------------------------------------------------------------------------------------------------
		IF @extorno_codigo = 1
		BEGIN
			---------------------------------------------------------------------------
			-----		Obtener máximo id del detalle (+1)
			---------------------------------------------------------------------------
			SET @ID_DETALLE_ACTUALIZAR = COALESCE(
				(SELECT MAX(ID_DETALLE) 
				FROM TLF_CONCILIACION_DETALLE WITH (NOLOCK)
				WHERE ID_CABECERA = @ID_CABECERA), 
				0)+1;
			
			---------------------------------------------------------------------------
			-----		Obtener jts_oid de topazcontrol a actualizar
			---------------------------------------------------------------------------
			SELECT 
				@JTS_OID_TP_ACTUALIZAR = MAX(JTS_OID)
			FROM TP_TOPAZPOSCONTROL WITH (NOLOCK)
			WHERE
				ELEMENT13=@LKTRAD
				AND ELEMENT12=@LKTRAT
				AND ELEMENT37=@LKSEQN
				AND ELEMENT41=@LKTERM
				AND ELEMENT3=@COD_MSJ_H2H
				AND ELEMENT102=@LKFROM
				AND ELEMENT103=@LKTOAC
				AND ELEMENT0 =''0430''
				AND TOPAZPOSTINGNUMBER=0;

			---------------------------------------------------------------------------
			-----		Obtener nuevo asiento extornado
			---------------------------------------------------------------------------
			SELECT
				@ASIENTO_NUMERO=ASIENTO,
				@ASIENTO_FECHA=FECHAPROCESO,
				@ASIENTO_SUCURSAL=SUCURSAL
			FROM CON_ASIENTOS_EXTORNADOS
			WHERE 
				ASIENTO_ORIGINAL = @ASIENTO_ORIGINAL_NUMERO
				AND SUCURSAL_ORIGINAL = @ASIENTO_ORIGINAL_SUCURSAL
				AND FECHAPROCESO_ORIGINAL = @ASIENTO_ORIGINAL_FECHA
			
			IF @ASIENTO_NUMERO IN (NULL,0)
			BEGIN
				SET @resultado = ''ERROR AL OBTENER NUEVO ASIENTO.'';
				
				UPDATE dbo.TLF_CONCILIACION_CABECERA
				SET ESTADO_CONCILIACION = @resultado,
					DESCRIPCION_CONCILIACION = CONCAT(''JTS_OID_TP:'',@jts_oid_tp,'' - Error al consultar la tabla CON_ASIENTOS_EXTORNADOS, asiento extornado inexistente al consultar con asiento original: N°'',@ASIENTO_ORIGINAL_NUMERO, '' - Suc: '',@ASIENTO_ORIGINAL_SUCURSAL,'' - Fecha: '',FORMAT(@ASIENTO_ORIGINAL_FECHA, ''yyyy-MM-dd''))
				WHERE ID_CABECERA = @ID_CABECERA;
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT 1 FROM TP_TOPAZPOSCONTROL WITH (NOLOCK) WHERE JTS_OID=@JTS_OID_TP_ACTUALIZAR)
				BEGIN
					---------------------------------------------------------------------------
					-----		ACTUALIZAR EN TP_TOPAZPOSCONTROL
					---------------------------------------------------------------------------
					SET @resultado = ''OK'';

					UPDATE TP_TOPAZPOSCONTROL
					SET
						TOPAZPOSTINGNUMBER = @ASIENTO_NUMERO,
						TOPAZBRANCH = @ASIENTO_SUCURSAL,
						TOPAZPROCESSDATE = @ASIENTO_FECHA,
						ELEMENT39 = ''00''
					WHERE JTS_OID=@JTS_OID_TP_ACTUALIZAR;
				END
				ELSE
				BEGIN
					---------------------------------------------------------------------------
					-----		INSERT EN TP_TOPAZPOSCONTROL (con datos)
					---------------------------------------------------------------------------
					SET @resultado = ''OK'';
					
					IF EXISTS (SELECT 1 FROM TP_TOPAZPOSCONTROL WITH (NOLOCK)
							WHERE ELEMENT13=@LKTRAD 	AND ELEMENT12=@LKTRAT 	AND ELEMENT37=@LKSEQN AND ELEMENT41=@LKTERM
							AND ELEMENT3=@COD_MSJ_H2H 	AND ELEMENT102=@LKFROM	AND ELEMENT103=@LKTOAC
					)
					BEGIN
						INSERT INTO dbo.TP_TOPAZPOSCONTROL
						(
							-- TODAS LAS COLUMNAS MENOS JTS_OID (IDENTITY)
							TZ_LOCK,    ELEMENT39,  ELEMENT0,   TOPAZBRANCH,    TOPAZPROCESSDATE,   TOPAZPOSTINGNUMBER,     
							NRECEIVED,  ELEMENT1,   ELEMENT3,   ELEMENT4,   ELEMENT7,   ELEMENT10,  ELEMENT11,  ELEMENT12,
							ELEMENT13,  ELEMENT15,  ELEMENT17,  ELEMENT18,  ELEMENT22,  ELEMENT32,  ELEMENT35,  ELEMENT37,
							ELEMENT38,  ELEMENT41,  ELEMENT42,  ELEMENT43,  ELEMENT44,  ELEMENT45,  ELEMENT48,  ELEMENT49,
							ELEMENT52,  ELEMENT53,  ELEMENT54,  ELEMENT60,  ELEMENT61,  ELEMENT62,  ELEMENT63,  ELEMENT66,  
							ELEMENT67,  ELEMENT68,  ELEMENT70,  ELEMENT75,  ELEMENT83,  ELEMENT90,  ELEMENT93,  ELEMENT95,  
							ELEMENT100, ELEMENT102, ELEMENT103, ELEMENT120, ELEMENT121, ELEMENT123, ELEMENT124, ELEMENT125, 
							ELEMENT126, REQUESTOID, ISOLITERAL, INDICATORPRODUCT, RELEASENUMBER,    STATUS,     ORIGINATORCODE,
							RESPONDERCODE,          FECHAMENSAJE,     SERVERIP,         NSEND,      TIMEOUT,    ELEMENT55,  
							ELEMENT127, ELEMENT105, ELEMENT122
						)
						SELECT TOP 1
							-- TZ_LOCK, ELEMENT39, ELEMENT0, TOPAZBRANCH, TOPAZPROCESSDATE, TOPAZPOSTINGNUMBER,
							0 AS TZ_LOCK,  
							''00'' AS ELEMENT39,
							''0430'' AS ELEMENT0,
							@ASIENTO_SUCURSAL AS TOPAZBRANCH,
							@ASIENTO_FECHA  AS TOPAZPROCESSDATE,
							@ASIENTO_NUMERO AS TOPAZPOSTINGNUMBER,
							-- RESTO DE COLUMNAS
							NRECEIVED,  ELEMENT1,   ELEMENT3,   ELEMENT4,   ELEMENT7,   ELEMENT10,  ELEMENT11,  ELEMENT12,
							ELEMENT13,  ELEMENT15,  ELEMENT17,  ELEMENT18,  ELEMENT22,  ELEMENT32,  ELEMENT35,  ELEMENT37,
							ELEMENT38,  ELEMENT41,  ELEMENT42,  ELEMENT43,  ELEMENT44,  ELEMENT45,  ELEMENT48,  ELEMENT49,
							ELEMENT52,  ELEMENT53,  ELEMENT54,  ELEMENT60,  ELEMENT61,  ELEMENT62,  ELEMENT63,  ELEMENT66,  
							ELEMENT67,  ELEMENT68,  ELEMENT70,  ELEMENT75,  ELEMENT83,  ELEMENT90,  ELEMENT93,  ELEMENT95,  
							ELEMENT100, ELEMENT102, ELEMENT103, ELEMENT120, ELEMENT121, ELEMENT123, ELEMENT124, ELEMENT125, 
							ELEMENT126, REQUESTOID, ISOLITERAL, INDICATORPRODUCT, RELEASENUMBER,    STATUS,     ORIGINATORCODE,
							RESPONDERCODE,          FECHAMENSAJE,     SERVERIP,         NSEND,      TIMEOUT,    ELEMENT55,  
							ELEMENT127, ELEMENT105, ELEMENT122
						FROM dbo.TP_TOPAZPOSCONTROL
						WHERE
								ELEMENT13=@LKTRAD
								AND ELEMENT12=@LKTRAT
								AND ELEMENT37=@LKSEQN
								AND ELEMENT41=@LKTERM
								AND ELEMENT3=@COD_MSJ_H2H
								AND ELEMENT102=@LKFROM
								AND ELEMENT103=@LKTOAC
								AND ELEMENT0 IN (''0230'', ''0220'')
						ORDER BY ELEMENT0, TOPAZPOSTINGNUMBER DESC
					END
					ELSE
					---------------------------------------------------------------------------
					-----		INSERT EN TP_TOPAZPOSCONTROL (sin datos)
					---------------------------------------------------------------------------
					BEGIN
						INSERT INTO dbo.TP_TOPAZPOSCONTROL (TZ_LOCK, ELEMENT39, ELEMENT0, TOPAZBRANCH, TOPAZPROCESSDATE, TOPAZPOSTINGNUMBER, NRECEIVED)
						VALUES (
							0, ''00'', ''0430'', @ASIENTO_SUCURSAL, @ASIENTO_FECHA, @ASIENTO_NUMERO, 1
						);
					END
				END
				---------------------------------------------------------------------------
				-----		Actualizar cabecera
				---------------------------------------------------------------------------
				UPDATE TLF_CONCILIACION_CABECERA
				SET REVERSAS_ONLINE = REVERSAS_ONLINE +1
				WHERE ID_CABECERA = @ID_CABECERA
				---------------------------------------------------------------------------
				-----		Volver a obtener nuevo_jts_oid
				---------------------------------------------------------------------------
				IF @JTS_OID_TP_ACTUALIZAR IS NULL
				BEGIN
					SELECT top 1
						@JTS_OID_TP_ACTUALIZAR = MAX(JTS_OID)
					FROM TP_TOPAZPOSCONTROL WITH (NOLOCK)
					WHERE
						ELEMENT13=@LKTRAD
						AND ELEMENT12=@LKTRAT
						AND ELEMENT37=@LKSEQN
						AND ELEMENT41=@LKTERM
						AND ELEMENT3=@COD_MSJ_H2H
						AND ELEMENT102=@LKFROM
						AND ELEMENT103=@LKTOAC
						AND ELEMENT0 =''0430'';
				END
				---------------------------------------------------------------------------
				-----		Insertar detalle
				---------------------------------------------------------------------------
				INSERT INTO dbo.TLF_CONCILIACION_DETALLE (
					ID_CABECERA, ID_DETALLE, 
					LKTRAD, LKTRAT, LKSEQN, LKTERM, COD_MSJ_H2H, LKFROM, LKTOAC, LKORIG, LKAMT1, 
					IMPORTE, LKTYP, ASIENTO_SUCURSAL, ASIENTO_FECHA, ASIENTO_NUMERO, JTS_OID_TP
				)
				VALUES (
					@ID_CABECERA, @ID_DETALLE_ACTUALIZAR, 
					@LKTRAD, @LKTRAT, @LKSEQN, @LKTERM, @COD_MSJ_H2H, @LKFROM, @LKTOAC, @LKORIG, @LKAMT1,
					@IMPORTE, ''0430'', @ASIENTO_SUCURSAL, @ASIENTO_FECHA, @ASIENTO_NUMERO, @JTS_OID_TP_ACTUALIZAR
				);
				---------------------------------------------------------------------------
				-----		Actualizar estado de cabecera
				---------------------------------------------------------------------------
				UPDATE dbo.TLF_CONCILIACION_CABECERA
				SET ESTADO_CONCILIACION = 
					CASE 
						WHEN ESTADO_TLF = ''REVERSADA'' AND IMPACTOS_ONLINE = REVERSAS_ONLINE THEN ''CONCILIADO''
						WHEN ESTADO_TLF = ''APROBADA'' AND IMPACTOS_ONLINE = REVERSAS_ONLINE + 1 THEN ''CONCILIADO''
						WHEN ESTADO_TLF = ''RECHAZADA'' AND IMPACTOS_ONLINE = REVERSAS_ONLINE THEN ''CONCILIADO''
						ELSE ''NO_OK''
					END,
					DESCRIPCION_CONCILIACION = ''Extorno realizado''
				WHERE ID_CABECERA = @ID_CABECERA;
			END
		END
		ELSE
		----------------------------------------------------------------------------------------------------
		-- CUANDO EL EXTORNO FUÉ UN ERROR
		----------------------------------------------------------------------------------------------------
		BEGIN
			UPDATE dbo.TLF_CONCILIACION_CABECERA
			SET 
				ESTADO_CONCILIACION = ''ERROR'',
				DESCRIPCION_CONCILIACION = @extorno_resultado
			WHERE ID_CABECERA = @ID_CABECERA

			SET @resultado = ''ERROR AL EJECUTAR EXTORNO''
		END
	END TRY
	BEGIN CATCH
		SET @resultado = SUBSTRING(ERROR_MESSAGE(), 1, 100);
	END CATCH
END

');