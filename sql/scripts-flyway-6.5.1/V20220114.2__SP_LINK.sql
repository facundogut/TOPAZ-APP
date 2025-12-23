EXECUTE('DROP PROCEDURE IF EXISTS dbo.SP_LINK;')
EXECUTE('
CREATE PROCEDURE dbo.SP_LINK @fch_chr AS VARCHAR(10), @tipo VARCHAR(1), @completo AS INT = 0
/*

Nuevo parámetro: completo -- si viene en 1 se obtienen todos los movimientos

Procedimiento que a partir de los saldos obtenemos por cada JTS_OID los ultimos 10 movimientos a una fecha dada
(
	-- si el parametro tipo es ''0'' no se filtra por fch procesado en la HISTRORIA_VISTA
	-- si el parametro tipo es ''1'' se filtra con fecha <= a fch procesado en la HISTORIA_VISTA
)
de latabla HISTORIA_VISTA

*/

AS
BEGIN
	
	DECLARE @fch_proceso DATETIME;
	DECLARE @secuencia NUMERIC(5,0) = 0;
	DECLARE @cant_movimientos INT;  -- parametrosgenerales
	
	SET @cant_movimientos = (SELECT CAST(NUMERICO AS INT) FROM PARAMETROSGENERALES WHERE [CODIGO]=650);
	SET @fch_proceso  = CONVERT(DATETIME, @fch_chr, 101);			
	
	DELETE FROM ITF_MOVCONFORMADOS;
	
	declare cursor_saldos cursor for
	SELECT s.JTS_OID, s.c1785 from SALDOS (nolock) s WHERE s.c1785 IN (2,3) AND s.TZ_LOCK=0
	
	/*ahora declaramos las variables con las que vamos a recorrer el cursor:*/
	
	declare @oid NUMERIC(15,0);
	DECLARE @tpo_prod NUMERIC(1,0);
	
	/*Abrimos el cursor para iniciar el recorrido del mismo*/
	open cursor_saldos
	
	/*Se mueve al siguiente registro dentro del cursor y los asignamos a las variables antes declaradas*/
	fetch next from cursor_saldos into @oid, @tpo_prod
	
	/*Retorna el estatus del último registro recorrido en el cursor, cuando es igual a 0 encontró registro pendientes de recorrer*/
	while @@fetch_status = 0
	begin
	IF @oid <> 0 
		
		IF @tipo = ''1''  
		BEGIN
		    IF @completo = 0
		    BEGIN
			    INSERT INTO ITF_MOVCONFORMADOS (asiento, fch_procesado, sucursal, nro_mov, ordinal, TRTIPO, 
			    TRVIRTUAL, secuencia, tpo_prod, jts_oid) 
			    SELECT TOP (@cant_movimientos) hv.ASIENTO, hv.FECHA_PROCESADO, hv.SUCURSAL, hv.NUMERO_MOVIMIENTO, hv.ORDINAL, hv.TRTIPO, 
				    hv.TRVIRTUAL, 
				    ROW_NUMBER() OVER (ORDER BY hv.FECHA_PROCESADO desc) AS secuencia,
				    @tpo_prod AS ''tpo_prod'',
				    hv.SALDO_JTS_OID				
				    FROM HISTORIA_VISTA (nolock) hv 
				    WHERE hv.SALDO_JTS_OID=@oid AND hv.FECHA_PROCESADO <= @fch_proceso ORDER BY hv.FECHA_PROCESADO, MOV_JTS_OID desc;
			END
			ELSE
			BEGIN
			    INSERT INTO ITF_MOVCONFORMADOS (asiento, fch_procesado, sucursal, nro_mov, ordinal, TRTIPO, 
			    TRVIRTUAL, secuencia, tpo_prod, jts_oid) 
			    SELECT hv.ASIENTO, hv.FECHA_PROCESADO, hv.SUCURSAL, hv.NUMERO_MOVIMIENTO, hv.ORDINAL, hv.TRTIPO, 
				    hv.TRVIRTUAL, 
				    ROW_NUMBER() OVER (ORDER BY hv.FECHA_PROCESADO desc) AS secuencia,
				    @tpo_prod AS ''tpo_prod'',
				    hv.SALDO_JTS_OID				
				    FROM HISTORIA_VISTA (nolock) hv 
				    WHERE hv.SALDO_JTS_OID=@oid AND hv.FECHA_PROCESADO <= @fch_proceso ORDER BY hv.FECHA_PROCESADO, MOV_JTS_OID desc;
			END
		END
		
		IF @tipo = ''0''
		BEGIN
		    IF @completo = 0
		    BEGIN
			    INSERT INTO ITF_MOVCONFORMADOS (asiento, fch_procesado, sucursal, nro_mov, ordinal, TRTIPO, 
			    TRVIRTUAL, secuencia, tpo_prod, jts_oid) 
			    SELECT TOP (@cant_movimientos) hv.ASIENTO, hv.FECHA_PROCESADO, hv.SUCURSAL, hv.NUMERO_MOVIMIENTO, hv.ORDINAL, hv.TRTIPO, 
				    hv.TRVIRTUAL, 
				    ROW_NUMBER() OVER (ORDER BY hv.FECHA_PROCESADO desc) AS secuencia,
				    @tpo_prod AS ''tpo_prod'',
				    hv.SALDO_JTS_OID				
				    FROM HISTORIA_VISTA (nolock) hv 
				    WHERE hv.SALDO_JTS_OID=@oid ORDER BY hv.FECHA_PROCESADO, MOV_JTS_OID desc;
			END
			ELSE
			BEGIN
			    INSERT INTO ITF_MOVCONFORMADOS (asiento, fch_procesado, sucursal, nro_mov, ordinal, TRTIPO, 
			    TRVIRTUAL, secuencia, tpo_prod, jts_oid) 
			    SELECT hv.ASIENTO, hv.FECHA_PROCESADO, hv.SUCURSAL, hv.NUMERO_MOVIMIENTO, hv.ORDINAL, hv.TRTIPO, 
				    hv.TRVIRTUAL, 
				    ROW_NUMBER() OVER (ORDER BY hv.FECHA_PROCESADO desc) AS secuencia,
				    @tpo_prod AS ''tpo_prod'',
				    hv.SALDO_JTS_OID				
				    FROM HISTORIA_VISTA (nolock) hv 
				    WHERE hv.SALDO_JTS_OID=@oid ORDER BY hv.FECHA_PROCESADO, MOV_JTS_OID desc;
			END
		END
		
		--Se mueve al siguiente registro dentro del cursor
		fetch next from cursor_saldos into @oid, @tpo_prod
		SET @secuencia = 0;
	
	END 
	
	--Cuando concluimos con el recorrido del cursor, este debe ser cerrado y luego destruído mediante las siguientes sentencias:
	close cursor_saldos --Cierra el cursor.
	deallocate cursor_saldos --Lo libera de la memoria y lo destruye.
END
')
