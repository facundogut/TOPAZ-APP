
Execute('
CREATE OR ALTER  PROCEDURE dbo.SP_ITF_LOTIPAGOS
AS
--Alvaro Etchelar - 15/6/2022
--Hay un "error" de que falta una dependencia si se le da clic derecho y objects properties
--Es porque en el SP dropea una sequence que sea crea en el SP y como no existe
--aún da ese error

DECLARE 

/*VARIABLES*/

@V_CUR_NroConvenio NUMERIC(12),
@V_CUR_TOTIMPORTE NUMERIC(15,2),
@V_CUR_NomArchivo  VARCHAR(40),
@V_CUR_FechaPago DATETIME,
@V_CUR_RegXConvenio NUMERIC(8),
@V_CUR_NomConvenio VARCHAR(40),
@V_FechaCarga DATETIME,
@ID_CABEZAL NUMERIC(15,0) = 0,
@TZ_LOCK NUMERIC(15,0) = 0


/*CURSOR*/

DECLARE	cur_Convenios CURSOR LOCAL FORWARD_ONLY FOR
	SELECT nroconvenio,SUM(Importeabonado) AS ImporteTotal,nomarchivo,fechapago,count(*) AS TotalRegXConvenio,nomconvrec
	FROM itf_intermedia_lotipagos a,CONV_CONVENIOS_REC b WHERE id_convrec = nroconvenio AND a.TZ_LOCK=0 AND tiporegistro = 2
	AND conerror = ''N'' GROUP BY NroConvenio,nomarchivo,fechapago,nomconvrec ORDER BY NroConvenio;
	
OPEN cur_Convenios
FETCH NEXT FROM cur_Convenios INTO @V_CUR_NroConvenio,@V_CUR_TOTIMPORTE,@V_CUR_NomArchivo,@V_CUR_FechaPago,@V_CUR_RegXConvenio,@V_CUR_NomConvenio
WHILE @@fetch_status = 0
	BEGIN
		
		SET @ID_CABEZAL = ( SELECT (ISNULL(max(ID),0)+1) AS MAX_ID FROM REC_CAB_RECAUDOS_CANAL );
		SET @V_FechaCarga = (SELECT fechaproceso FROM PARAMETROS);
		
		INSERT INTO dbo.REC_CAB_RECAUDOS_CANAL (ID, ESTADO, ARCHIVO, CONVENIO, FECHACARGA, ID_LIQUIDACION, MONEDA, TOTALREGISTROS, TOTALIMPORTE, TZ_LOCK, TOTAL_CARGO_ESPECIFICO, NOMBRE,Fecha_Cobranza)
		VALUES (@ID_CABEZAL, ''I'', @V_CUR_NomArchivo,@V_CUR_NroConvenio, @V_FechaCarga, 0, 1, @V_CUR_RegXConvenio, @V_CUR_TOTIMPORTE, @TZ_LOCK, 0, @V_CUR_NomConvenio,@V_CUR_FechaPago);
		
		--Grabo el cabezal en la tabla intermedia, me sirve luego para generar reportes
		UPDATE ITF_INTERMEDIA_LOTIPAGOS SET ID_Cabezal = @ID_CABEZAL WHERE NroConvenio = @V_CUR_NroConvenio AND ConError = ''N'';
	   
		--IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[ID_LINEASEC]'') AND type = ''SO'')
			CREATE SEQUENCE dbo.ID_LINEASEC  START WITH 1  INCREMENT BY 1;
	 
		INSERT INTO dbo.REC_DET_RECAUDOS_CANAL (ID_CABEZAL, ID_LINEA, MONEDA, IMPORTE, CODIGO_BARRAS, CODIGO_BARRAS_RENDIDO, ESTADO,
		DETALLE_ESTADO,TOTAL_CARGO_ESPECIFICO, TZ_LOCK,Fecha_Cobranza)
		SELECT @ID_CABEZAL, NEXT VALUE FOR dbo.ID_LINEASEC,1,ImporteAbonado,CodigoBarras, '' '', ''I'', CampoAuxDetalle, 0, @TZ_LOCK,@V_CUR_FechaPago
		FROM itf_intermedia_lotipagos WHERE TZ_LOCK = 0 AND NroConvenio = @V_CUR_NroConvenio AND TipoRegistro = 2 AND ConError = ''N'';
		
		DROP SEQUENCE dbo.ID_LINEASEC;
		
		FETCH NEXT FROM	cur_Convenios INTO @V_CUR_NroConvenio,@V_CUR_TOTIMPORTE,@V_CUR_NomArchivo,@V_CUR_FechaPago,@V_CUR_RegXConvenio,@V_CUR_NomConvenio
	END
CLOSE cur_Convenios
DEALLOCATE cur_Convenios')

