EXECUTE('
CREATE OR ALTER   PROCEDURE [dbo].[SP_LK_98_B]

@ticket NUMERIC(20)
AS
BEGIN
DECLARE 
	@concepto INT, 
	@cantDet INT,
	@idConv NUMERIC(15),
	@nomConv VARCHAR(40),
	@idCabezal NUMERIC (15),
	@codEnte VARCHAR(3),
	@impTotal NUMERIC(15,2);  
	
TRUNCATE TABLE ITF_LK_PARAMETROS_REP;	

DECLARE cursorOk CURSOR forward_only fast_forward read_only   
FOR 
SELECT NRO_02 a,count(*) b FROM REC_EXT_RECAUDOS_CANAL B WHERE B.ID_CABEZAL = @ticket AND B.CORRELATIVO = 2 
GROUP BY NRO_02
OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @concepto, @cantDet
    WHILE @@FETCH_STATUS = 0 
    BEGIN
    	SET @idConv = -1
    	SET @codEnte = (SELECT CADENA_01 FROM REC_EXT_RECAUDOS_CANAL WHERE ID_CABEZAL = @ticket AND CORRELATIVO = 1);
		SELECT TOP 1 @idConv = id_convrec, @nomConv = nomconvrec FROM CONV_REL_ENTECONV WHERE TIPO_CONCEPTO = @concepto AND COD_ENTE = @codEnte;
		IF(@idConv <> -1) --existe convenio
		BEGIN		
			SET @idCabezal = (SELECT Max(isnull(ID,0)) + 1 FROM REC_CAB_RECAUDOS_CANAL (nolock));
			SET @impTotal = (SELECT sum(NRO_04) FROM REC_EXT_RECAUDOS_CANAL WHERE id_cabezal = @ticket AND correlativo = 2 AND NRO_02 = @concepto);
			
			--inserto en cabezal						
			INSERT INTO REC_CAB_RECAUDOS_CANAL				
		   		SELECT @idCabezal , ''I'',CADENA_02, @idConv,FECHA_01,0,1,@cantDet ,@impTotal,0,0,@nomConv,FECHA
				FROM REC_EXT_RECAUDOS_CANAL WHERE ID_CABEZAL = @ticket AND CORRELATIVO = 3;
						
			INSERT INTO ITF_LK_PARAMETROS_REP SELECT @idCabezal;
			
			--creo seq para nroLinea 
			CREATE SEQUENCE nroLinDet
			start WITH 1
			increment BY 1; 
						
			--inserto en detalle
			INSERT INTO REC_DET_RECAUDOS_CANAL				
		   		SELECT @idCabezal, next value for nroLinDet , 1,NRO_04, CADENA_01,CADENA_02, ''I'', ''Ingresado'', 0,0,FECHA,CADENA_04
				FROM REC_EXT_RECAUDOS_CANAL WHERE ID_CABEZAL = @ticket AND CORRELATIVO = 2 AND NRO_02 = @concepto;
			
		 	--dropeo para reiniciar seq
		 	DROP SEQUENCE nroLinDet;		
		END			
	FETCH NEXT FROM cursorOk INTO @concepto, @cantDet
   	END --Fin del WHILE
CLOSE cursorOk --Cerrar el CURSOR ok
DEALLOCATE cursorOk
END
')
