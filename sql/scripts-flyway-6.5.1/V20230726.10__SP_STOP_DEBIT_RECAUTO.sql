Execute('
CREATE OR ALTER PROCEDURE dbo.[SP_RECAUTO_STOP_DEBIT]

	@CABEZAL NUMERIC(10) , @Cant_SD INT OUTPUT
	--32421;
AS
BEGIN

--variables cursor
DECLARE @c_id_linea NUMERIC(15), @c_tipo_cta VARCHAR(2), @c_sucursal_cta NUMERIC(5), @c_nro_cta NUMERIC(12);

--var update
DECLARE @estado VARCHAR(1) = ''V'' ,@detalle_estado VARCHAR(35) = ''Rechazo por STOP DEBIT'' , @tiene_sd VARCHAR(1) = ''S'';

DECLARE @fecha_proceso DATETIME = (SELECT fechaproceso FROM PARAMETROS (nolock));

DECLARE cursorOk CURSOR FOR 
SELECT  ID_LINEA, TIPO_CTA, SUCURSAL_CTA, NRO_CUENTA FROM REC_DET_DEBITOSAUTOMATICOS WHERE ID_CABEZAL = @CABEZAL --184139
OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @c_id_linea, @c_tipo_cta, @c_sucursal_cta, @c_nro_cta
    WHILE @@FETCH_STATUS = 0 
    BEGIN
    UPDATE REC_DET_DEBITOSAUTOMATICOS SET ESTADO = @estado, DETALLE_ESTADO = @detalle_estado, TIENE_STOP_DEBIT = @tiene_sd 
    	WHERE EXISTS(
					SELECT det.NRO_CUENTA
						FROM SNP_STOP_DEBIT sd 
				   			 JOIN saldos s ON sd.CLIENTE_ADHERIDO = s.c1803 
				   			 			AND sd.TZ_LOCK = 0 
				   			 			AND sd.SALDO_JTS_OID = ( CASE 
				   			 										WHEN sd.SALDO_JTS_OID = 0 THEN sd.SALDO_JTS_OID
				   			 										ELSE s.JTS_OID END
				   			 									)				   			 				
							 JOIN  REC_DET_DEBITOSAUTOMATICOS det ON det.NRO_CUENTA = s.CUENTA 
							 	WHERE det.ID_CABEZAL = @CABEZAL 
							 		AND det.NRO_CUENTA = @c_nro_cta
							 	   	AND @c_sucursal_cta = s.SUCURSAL				
						            AND s.MONEDA = 1
						            AND s.C1785 = (
						                Case
						                    When det.TIPO_CTA = ''AC'' Then 3
						                    Else 2
						                END
						            )
						            AND sd.FECHA_DESDE <= @fecha_proceso
						            AND @fecha_proceso < sd.FECHA_HASTA
						            AND sd.DEBITO_DIRECTO = ''N'' 
				   			 		AND sd.ESTADO = ''AC''

						)						            
						       
				AND ID_CABEZAL = @CABEZAL
				AND ID_LINEA = @c_id_linea
		  		AND ESTADO = ''I'';
				SET @Cant_SD += @@ROWCOUNT;
				
   	FETCH NEXT FROM cursorOk INTO @c_id_linea, @c_tipo_cta, @c_sucursal_cta, @c_nro_cta
   	END --Fin del WHILE

    	
CLOSE cursorOk --Cerrar el CURSOR ok
DEALLOCATE cursorOk


END;
')