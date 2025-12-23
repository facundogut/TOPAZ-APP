EXECUTE('

	
IF OBJECT_ID (''dbo.ITF_AFIP_IGARG2681'') IS NOT NULL
	DROP TABLE dbo.ITF_AFIP_IGARG2681
	
IF OBJECT_ID (''dbo.SP_ITF_AFIP_IGARG2681'') IS NOT NULL
	DROP PROCEDURE dbo.SP_ITF_AFIP_IGARG2681
')

EXECUTE('
DELETE FROM dbo.ITF_MASTER
WHERE ID = 143

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 143, ''AFIP IGARG2681 2.1.3'', ''ITF_AFIP_IGARG2681.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

')


EXECUTE('

CREATE TABLE dbo.ITF_AFIP_IGARG2681
	(
	ID                        INT IDENTITY NOT NULL,
	CUIT                      NUMERIC (11) DEFAULT ((0)),
	TIPO_SUJETO               VARCHAR (60) DEFAULT ('' ''),
	CODIGO_ESTADO             VARCHAR (2) DEFAULT ('' ''),
	DESCRIPCION_ESTADO        VARCHAR (30) DEFAULT ((0)),
	FECHA_EMISION_CERTIFICADO DATE,
	FECHA_ADM_FORMAL          DATE,
	AUTORIZA_DEDUCCION        VARCHAR (2) DEFAULT ('' ''),
	OBLIGADO_PRES_DDJJ        VARCHAR (2) DEFAULT ('' ''),
	CODIGO_INCISO             VARCHAR (1) DEFAULT ('' ''),
	VIGENCIA_DESDE            DATE,
	VIGENCIA_HASTA            DATE,
	NRO_CERTIFICADO           NUMERIC (15) DEFAULT ((0)),
	ORDEN_JUDICIAL            VARCHAR (1) DEFAULT ('' ''),
	FECHA_ULT_MOD             DATETIME,
	CONSTRAINT PK_ITF_AFIP_IGARG2681 PRIMARY KEY (ID)
	)
')
EXECUTE('
CREATE PROCEDURE dbo.[SP_ITF_AFIP_IGARG2681]
--Fabio Menendez: 05/07/2023
	@reproceso VARCHAR(1)
AS
BEGIN 

 CREATE TABLE #ClientesTmp (
    CODIGOCLIENTE NUMERIC(12),
    NUMEROPERSONA NUMERIC(12)
);   
DECLARE @fecha_hasta DATETIME = (SELECT FECHAPROCESO FROM PARAMETROS (nolock));
--Logica de Reproceso
IF @reproceso=''S''
BEGIN

UPDATE c 
SET c.fecha_hasta = @fecha_hasta
FROM CI_CARGOS_TARIFAS c 
WHERE  c.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS_IGARG830 (nolock));

DELETE FROM ITF_LOG_CARGOS_IMPUESTOS WHERE COD_IMPUESTO IN (SELECT TIPOCARGO FROM VW_CARGOS_IMPUESTOS_IGARG830 (nolock));

END

--variables clave
DECLARE @cuit VARCHAR(11),@razonSocial VARCHAR(80), @fechaDesde DATETIME, @fechaHasta DATETIME, @porcentaje NUMERIC(7,4), @resGeneral VARCHAR(19), @tipoCertificado VARCHAR(11);

--var de cursor
DECLARE @C_idCargo NUMERIC(10), @C_descripcion VARCHAR (80), @C_tipoCargo NUMERIC(3), @C_tasa NUMERIC (4,4), @C_moneda NUMERIC(1)  ;		

--variables aux
DECLARE @codCli NUMERIC (10), @nroPersona NUMERIC(10), @condIVA VARCHAR(2);
DECLARE @inserts NUMERIC(6), @actualizados NUMERIC(6), @hayTemporales INT, @hayUpdate INT, @faltanCargos INT;
DECLARE @idCount INT = 1;
--recorro padron de entrada
SELECT @cuit = CUIT, @fechaDesde = VIGENCIA_DESDE, @fechaHasta = VIGENCIA_HASTA
FROM ITF_AFIP_IGARG2681 (nolock) WHERE ID=@idCount;

WHILE @cuit IS NOT NULL 
BEGIN	     		
  		--recorro clientes solo si la persona es titular
	INSERT INTO #ClientesTmp (CODIGOCLIENTE,NUMEROPERSONA)
	SELECT DISTINCT
	    cp.CODIGOCLIENTE,
	    cp.NUMEROPERSONA
	FROM CLI_DocumentosPFPJ pfj (nolock)
	JOIN CLI_ClientePersona cp (nolock) ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA
	WHERE cp.TZ_LOCK = 0 AND cp.TITULARIDAD = ''T'' AND pfj.NUMERODOCUMENTO = @cuit;
	
	
	WHILE EXISTS (SELECT 1 FROM #ClientesTmp)
	BEGIN
		
	    -- Obtener el siguiente registro de #ClientesTmp
	    SELECT TOP 1 @codCli = CODIGOCLIENTE, @nroPersona = NUMEROPERSONA FROM #ClientesTmp;
		
			DECLARE @IGA VARCHAR(4) = (SELECT IGA FROM CLI_CLIENTES (nolock) WHERE TZ_LOCK=0 AND CODIGOCLIENTE=@codCli);
			IF EXISTS (SELECT 1 FROM CI_CARGOS_TARIFAS c (nolock) WHERE c.ID_CLIENTE=@codCli AND c.tz_lock=0)
			BEGIN
			--grabo en bitacora el tipo de cargo dado de baja 
			INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, VALOR_EXCLUSION, FECHA_INICIO, FECHA_FIN)
			SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS (nolock)),0)+ (ROW_NUMBER() OVER (ORDER BY c.TIPOCARGO)), ''B'',@fecha_hasta, (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, c.TIPOCARGO, 0, @fechaDesde, @fechaHasta
			FROM VW_CARGOS_IMPUESTOS_IGARG830 c (nolock) INNER JOIN dbo.CI_CARGOS_TARIFAS t (nolock) ON t.ID_CLIENTE=@codCli AND c.ID_CARGO=t.ID_CARGO
			WHERE t.tz_lock=0 AND t.ID_CLIENTE=@codCli AND
			c.ID_CARGO IN (
			SELECT i.ID_CARGO FROM VW_CARGOS_IMPUESTOS_IGARG830 i (nolock) WHERE i.segmento=@IGA 
			) AND c.segmento=@IGA
			GROUP BY c.TIPOCARGO, c.TASA
			END
			
			IF @reproceso=''N''
			BEGIN
			--doy de baja los cargos vigentes
			UPDATE dbo.CI_CARGOS_TARIFAS
			SET FECHA_HASTA = @fecha_hasta
			WHERE ID_CLIENTE=@codCli AND tz_lock=0 AND  
			 ID_CARGO  IN (
			SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS_IGARG830 (nolock) WHERE segmento=@IGA 
			)
			END
			
			--inserto en el log 1 reg 
			INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,PERIODO_DESDE,  PERIODO_HASTA, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
			SELECT TOP 1 c.TIPOCARGO, CONVERT(VARCHAR(8), @fechaDesde, 112), CONVERT(VARCHAR(8), @fechaHasta, 112),@codCli, @nroPersona, CONVERT(VARCHAR(8), @fecha_hasta, 112), FORMAT(@fecha_hasta, ''yyyyMMdd''),'''',0
			FROM VW_CARGOS_IMPUESTOS_IGARG830 c (nolock)
			WHERE c.segmento=@IGA
			GROUP BY c.TIPOCARGO, c.TASA
			
			
			
			--inserto en bitacora el alta
			INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, VALOR_EXCLUSION, FECHA_INICIO, FECHA_FIN)
			SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS (nolock)),0)+ (ROW_NUMBER() OVER (ORDER BY c.TIPOCARGO)),''A'', @fecha_hasta, (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, c.TIPOCARGO, 0, @fechaDesde, @fechaHasta
			FROM VW_CARGOS_IMPUESTOS_IGARG830 c (nolock)
			WHERE 
			c.ID_CARGO IN  (
			SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS_IGARG830 i (nolock) WHERE i.segmento=@IGA
			) AND c.segmento=@IGA
			GROUP BY c.TIPOCARGO, c.TASA 
			
			--update temporales existentes			
			UPDATE c 
			SET c.fecha_hasta = @fechaHasta, c.TASA = 0
			FROM CI_CARGOS_TARIFAS c
			WHERE c.id_cliente = @codCli AND c.TZ_LOCK = 0 AND c.ID_CARGO IN (
			SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS_IGARG830 i (nolock) WHERE i.segmento=@IGA 
			)
			
			--inserto los certificados que no tiene				 
			INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, MONEDA, ID_CLIENTE, SEGMENTO, FECHA_DESDE, FECHA_HASTA, TASA) 
			SELECT ID_CARGO, MONEDA, @codCli, segmento, @fechaDesde, @fechaHasta, 0
			FROM VW_CARGOS_IMPUESTOS_IGARG830 (nolock) WHERE ID_CARGO NOT IN (SELECT ID_CARGO FROM  CI_CARGOS_TARIFAS (nolock) WHERE id_cliente = @codCli  AND TZ_LOCK = 0  AND ID_CARGO IN (
			SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS_IGARG830 i (nolock) WHERE i.segmento=@IGA
			)) AND segmento=@IGA
					 		   
	   
	   	-- Eliminar el registro procesado
    	DELETE FROM #ClientesTmp WHERE CODIGOCLIENTE = @codCli AND NUMEROPERSONA = @nroPersona;
		END --Fin del WHILE    	
			   
SET @idCount = @idCount+1;
SET @cuit = NULL;
SELECT @cuit = CUIT, @fechaDesde = VIGENCIA_DESDE, @fechaHasta = VIGENCIA_HASTA
            FROM ITF_AFIP_IGARG2681 (nolock)
            WHERE ID = @idCount;

END

DROP TABLE #ClientesTmp;
END




')

