Execute('
CREATE OR ALTER PROCEDURE [dbo].[SP_LINK_IPDUV]

@ticket NUMERIC(20)

AS
BEGIN

DECLARE 
	@idRef INT, 
	@cantDet INT,
	@idConv NUMERIC(15),
	@nomConv VARCHAR(40),
	@idCabezal NUMERIC (15),
	@impTotal NUMERIC(15,2);
	

DECLARE cursorOk CURSOR forward_only fast_forward read_only   
FOR 
SELECT substring(CADENA_01,1,2) a,count(*) b FROM REC_EXT_RECAUDOS_CANAL B WHERE B.ID_CABEZAL = @ticket AND B.CORRELATIVO = 2 
GROUP BY substring(CADENA_01,1,2)
OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @idRef, @cantDet
    WHILE @@FETCH_STATUS = 0 
    BEGIN
    	SET @idConv = -1; 
		SELECT @idConv = id_convrec, @nomConv = nomconvrec FROM CONV_CONVENIOS_REC WHERE id_refext LIKE concat(''30-'',@idRef)
					
		IF(@idConv <> -1) --existe convenio
		BEGIN		
			SET @idCabezal = (SELECT Max(isnull(ID,0)) + 1 FROM REC_CAB_RECAUDOS_CANAL (nolock));
			SET @impTotal = (SELECT sum(NRO_04) FROM REC_EXT_RECAUDOS_CANAL WHERE id_cabezal = @ticket AND correlativo = 2 AND substring(CADENA_01, 1, 2) = @idRef);
			
			--inserto en cabezal
						
			INSERT INTO REC_CAB_RECAUDOS_CANAL				
		   		SELECT @idCabezal , ''I'',CADENA_02, @idConv,FECHA_01,0,1,@cantDet ,@impTotal,0,0,@nomConv,FECHA
				FROM REC_EXT_RECAUDOS_CANAL WHERE ID_CABEZAL = @ticket AND CORRELATIVO = 3;
						
			--creo seq para nroLinea 
			CREATE SEQUENCE nroLineaDet
			start WITH 1
			increment BY 1; 
			
			--inserto en detalle
			INSERT INTO REC_DET_RECAUDOS_CANAL				
		   		SELECT @idCabezal, next value for nroLineaDet , 1,NRO_04, CADENA_01,CADENA_02, ''I'', ''Ingresado'', 0,0,FECHA,CADENA_04
				FROM REC_EXT_RECAUDOS_CANAL WHERE ID_CABEZAL = @ticket AND CORRELATIVO = 2 AND substring(CADENA_01, 1, 2) = @idRef ;
			
		 	--dropeo para reiniciar seq
		 	DROP SEQUENCE nroLineaDet;		
		END			

	FETCH NEXT FROM cursorOk INTO @idRef, @cantDet
   	END --Fin del WHILE
CLOSE cursorOk --Cerrar el CURSOR ok
DEALLOCATE cursorOk

END
')
