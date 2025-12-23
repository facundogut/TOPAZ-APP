--PA

EXECUTE('        
CREATE OR ALTER PROCEDURE PA_CONV_REC_CAJAS_LIQ
	@P_ID_PROCESO  float(53),
	@P_DT_PROCESO  datetime2(0),
	@P_RET_PROCESO float(53)  OUTPUT,
	@P_MSG_PROCESO varchar(max)  OUTPUT
AS
	BEGIN
	SET @P_RET_PROCESO = NULL
    SET @P_MSG_PROCESO = NULL
	
	DECLARE @fecha_proceso DATETIME;--
	DECLARE @id_numerador NUMERIC(10);--
	DECLARE @id_cabezal NUMERIC(15);
	DECLARE @cantidad_registros NUMERIC(7);--
	DECLARE @convenio NUMERIC(15);--
	DECLARE @moneda NUMERIC(5);--
	DECLARE @total_importe DECIMAL(15,2);--
	DECLARE @liq_existentes TABLE (convenio NUMERIC(15), estado VARCHAR(1) );--
	DECLARE @contador NUMERIC(15);
	DECLARE @v_constante VARCHAR(1);
	DECLARE @nombre_convenio VARCHAR(40);
	DECLARE @total_cargo_especifico DECIMAL(15,2);
	
	
	--INSTANCIA VARIABLES
	SELECT @fecha_proceso = FECHAPROCESO, @moneda = MONNAC FROM PARAMETROS
	INSERT INTO @liq_existentes (convenio) SELECT CONVENIO FROM REC_LIQUIDACION WHERE FECHA = @fecha_proceso AND TZ_LOCK = 0 AND ESTADO = ''R''
	SET @contador = 0
	
	DECLARE
	cursor_cabezales CURSOR
	FOR
		SELECT COUNT(a.ID_LINEA) , SUM(ISNULL(a.IMPORTE,0)) , b.ID, b.CONVENIO , c.NomConvRec, SUM(ISNULL(a.TOTAL_CARGO_ESPECIFICO,0))
		FROM REC_DET_RECAUDOS_CAJA a 
		RIGHT JOIN REC_CAB_RECAUDOS_CAJA b ON b.ID = a.ID_CABEZAL 
		RIGHT JOIN CONV_CONVENIOS_REC c ON b.CONVENIO = c.Id_ConvRec
		WHERE b.FECHACARGA = @fecha_proceso 
		AND b.ESTADO = ''I''
		AND b.TZ_LOCK = 0		
		AND ISNULL(a.ESTADO,''V'') = ''V'' 
		AND ISNULL(a.TZ_LOCK,0) =0 
		GROUP BY b.ID, b.CONVENIO, c.NomConvRec, a.TOTAL_CARGO_ESPECIFICO
	
	BEGIN TRANSACTION
		BEGIN TRY
			OPEN cursor_cabezales
			FETCH NEXT FROM cursor_cabezales INTO @cantidad_registros, @total_importe, @id_cabezal, @convenio, @nombre_convenio, @total_cargo_especifico
			WHILE @@FETCH_STATUS = 0
				BEGIN
				
				IF NOT EXISTS(SELECT convenio FROM @liq_existentes WHERE convenio = @convenio)
					BEGIN
					SET @contador = @contador + 1
					
					
					--CREO LIQUIDACION PARA CABEZALES CON DETALLES Y ACTUALIZO LOS DETALLES
					IF @cantidad_registros >0
					BEGIN
						EXECUTE SP_GET_NUMERADOR_TOPAZ 45036, @id_numerador OUTPUT;
						--CREO LIQUIDACION
						INSERT INTO REC_LIQUIDACION (ID_LIQUIDACION, ESTADO, CONVENIO, CONVENIO_PADRE, FECHA, MONEDA, TOTALREGISTROS, TOTALIMPORTE, NOMBRE_CONVENIO_PADRE, TOTAL_CARGO_ESPECIFICO)
						VALUES (@id_numerador,''L'',@convenio, 0, @fecha_proceso, @moneda, @cantidad_registros, @total_importe, @nombre_convenio,@total_cargo_especifico)
						
						--SET DETALLES ESTADO P
						UPDATE b
						SET b.ESTADO = ''P''
						FROM
						REC_CAB_RECAUDOS_CAJA a JOIN REC_DET_RECAUDOS_CAJA b ON a.ID = b.ID_CABEZAL 
						WHERE a.CONVENIO = @convenio
						AND a.FECHACARGA = @fecha_proceso 
						AND a.ESTADO = ''I'' 
						AND a.TZ_LOCK = 0
						AND b.ESTADO = ''V''
						AND b.TZ_LOCK = 0
						
						--SET CAB ESTADO P con ID_LIQUIDACION
						UPDATE REC_CAB_RECAUDOS_CAJA
						SET 
						ESTADO = ''P'',
						TOTALREGISTROS = @cantidad_registros,
						TOTALIMPORTE = @total_importe,
						ID_LIQUIDACION = @id_numerador
						WHERE CONVENIO = @convenio AND FECHACARGA = @fecha_proceso AND ESTADO = ''I'' AND TZ_LOCK = 0
					END
					ELSE
					BEGIN
						UPDATE REC_CAB_RECAUDOS_CAJA
						SET 
						ESTADO = ''P'',
						TOTALREGISTROS = @cantidad_registros,
						TOTALIMPORTE = @total_importe
						WHERE CONVENIO = @convenio AND FECHACARGA = @fecha_proceso AND ESTADO = ''I'' AND TZ_LOCK = 0
					END		
					END
					
					
					
				FETCH NEXT FROM cursor_cabezales INTO @cantidad_registros, @total_importe, @id_cabezal, @convenio, @nombre_convenio, @total_cargo_especifico
				END
				IF @@TRANCOUNT > 0
					BEGIN
					COMMIT TRANSACTION
					END
				SET @P_RET_PROCESO = 1
				SET @P_MSG_PROCESO = CONCAT(''Creacion de Liquidaciones Funcionó correctamente, se liquidaron '',@contador,'' cabezales'')
				EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			SET @P_RET_PROCESO = ERROR_NUMBER()
			SET @P_MSG_PROCESO = ERROR_MESSAGE()
			EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;
		END CATCH
	
	CLOSE cursor_cabezales
	DEALLOCATE cursor_cabezales
	
	EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_REC_CAJAS_LIQ'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	
	END



')
