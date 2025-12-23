EXECUTE('ALTER TABLE CRE_SALDOS ADD TIPO_DOCUMENTO numeric (1,0) NULL')
EXECUTE('ALTER TABLE TOPAZ_ROLES_ASSIGNMENT ALTER COLUMN DATA varchar(10) NOT NULL')
EXECUTE('ALTER TABLE CLE_CHEQUES_SALIENTE ADD  COD_POSTAL numeric(4,0) NULL')

EXECUTE(' IF OBJECT_ID (''CRE_AUX_CONF_FACTURAS'') IS NOT NULL
	DROP TABLE CRE_AUX_CONF_FACTURAS
')

EXECUTE('CREATE TABLE CRE_AUX_CONF_FACTURAS
	(
	TZ_LOCK            NUMERIC (15) DEFAULT ((0)) NULL,
	NUMERO_LISTA       NUMERIC (6) DEFAULT ((0)) NOT NULL,
	NUMERO_DOC_INTERNO NUMERIC (12) DEFAULT ((0)) NOT NULL,
	SERIE              VARCHAR (6) DEFAULT ('' '') NULL,
	NUMERO_DOC_REAL    VARCHAR (15) DEFAULT ('' '') NULL,
	IMPORTE            NUMERIC (15,2) DEFAULT ((0)) NULL,
	FECHA_DOCUMENTO    DATETIME NULL,
	FECHA_VENCIMIENTO  DATETIME NULL,
	NOMBRE_VENDEDOR    VARCHAR (60) DEFAULT ('' '') NULL,
	DOCUMENTO_LIBRADOR VARCHAR (20) DEFAULT ('' '') NULL,
	ESTADO             NUMERIC (1) DEFAULT ((0)) NULL,
	TIPO_DOCUMENTO     VARCHAR (4) DEFAULT ('' '') NULL,
	TASA_INTERES       NUMERIC (11,7) NULL,
	JTS_OID_SALDO      NUMERIC (10) NULL,
	FECHA_VALOR        DATETIME NULL,
	CONSTRAINT PK_CRE_AUX_CONF_FACTURAS170143 PRIMARY KEY (NUMERO_LISTA,NUMERO_DOC_INTERNO)
	)
')

EXECUTE('IF OBJECT_ID (''CRE_CONF_FACTURAS'') IS NOT NULL
	DROP TABLE CRE_CONF_FACTURAS
')

EXECUTE('CREATE TABLE CRE_CONF_FACTURAS
	(
	TZ_LOCK            NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CUENTA             NUMERIC (12) DEFAULT ((0)) NULL,
	SERIE              VARCHAR (6) DEFAULT ('' '') NOT NULL,
	NUMERO_DOC_REAL    VARCHAR (15) DEFAULT ('' '') NOT NULL,
	IMPORTE            NUMERIC (15,2) DEFAULT ((0)) NULL,
	FECHA_DOCUMENTO    DATETIME NULL,
	FECHA_VENCIMIENTO  DATETIME NULL,
	NOMBRE_VENDEDOR    VARCHAR (60) DEFAULT ('' '') NULL,
	DOCUMENTO_LIBRADOR VARCHAR (20) DEFAULT ('' '') NULL,
	MONEDA             NUMERIC (4) DEFAULT ((0)) NULL,
	ESTADO             NUMERIC (1) DEFAULT ((0)) NULL,
	JTS_OID_CTA_VISTA  NUMERIC (10) DEFAULT ((0)) NULL,
	NUMERO_OPERACION   NUMERIC (12) DEFAULT ((0)) NULL,
	TIPO_DOCUMENTO     VARCHAR (4) DEFAULT ('' '') NULL,
	JTS_OID_SALDO      NUMERIC (10) DEFAULT ((0)) NULL,
	DESTINO            NUMERIC (2) NULL,
	CONSTRAINT PK_CRE_CONF_FACTURAS PRIMARY KEY (SERIE,NUMERO_DOC_REAL)
	)
')

EXECUTE('IF OBJECT_ID (''CRE_CAB_LISTA_DOCUMENTOS'') IS NOT NULL
	DROP TABLE CRE_CAB_LISTA_DOCUMENTOS
')

EXECUTE('CREATE TABLE CRE_CAB_LISTA_DOCUMENTOS
	(
	TZ_LOCK             NUMERIC (15) DEFAULT ((0)) NOT NULL,
	DEBITA_VTO          VARCHAR (1) DEFAULT ('' '') NULL,
	NUMERO_LISTA        NUMERIC (6) DEFAULT ((0)) NOT NULL,
	ESTADO              NUMERIC (1) DEFAULT ((0)) NULL,
	CANTIDAD_DOCUMENTOS NUMERIC (6) DEFAULT ((0)) NULL,
	IMPORTE_TOTAL       NUMERIC (15,2) DEFAULT ((0)) NULL,
	TIPO_DOCUMENTO      NUMERIC (1) DEFAULT ((0)) NULL,
	CLIENTE             NUMERIC (12) DEFAULT ((0)) NULL,
	MONEDA              NUMERIC (4) DEFAULT ((0)) NULL,
	FECHA_LISTA         DATETIME NULL,
	TASA_INTERES        NUMERIC (11,7) DEFAULT ((0)) NULL,
	JTS_OID_SALDO       NUMERIC (10) DEFAULT ((0)) NULL,
	CUENTA              NUMERIC (12) DEFAULT ((0)) NULL,
	PRODUCTO            NUMERIC (5) DEFAULT ((0)) NULL,
	NUMERO_LOTE         NUMERIC (6) DEFAULT ((0)) NULL,
	EN_GARANTIA         VARCHAR (1) DEFAULT (''N'') NULL,
	VENDEDOR            NUMERIC (12) DEFAULT ((0)) NULL,
	ORIGEN              NUMERIC (1) NULL,
	VALOR_AL_COBRO      VARCHAR (1) NULL,
	TIPO_LISTA          NUMERIC (1) NULL,
	CONSTRAINT PK_CRE_CAB_LISTA_DOCUMENTOS PRIMARY KEY (NUMERO_LISTA)
	)
')


EXECUTE('IF OBJECT_ID (''CHE_CUENTAS_CHEQUES'') IS NOT NULL
	DROP TABLE CHE_CUENTAS_CHEQUES
')

EXECUTE('CREATE TABLE CHE_CUENTAS_CHEQUES
	(
	TZ_LOCK          NUMERIC (15) DEFAULT ((0)) NOT NULL,
	TIPO_DOCUMENTO   VARCHAR (4) NOT NULL,
	NUMERO_DOCUMENTO VARCHAR (20) NOT NULL,
	BANCO_CHEQUE     NUMERIC (4) DEFAULT ((0)) NOT NULL,
	SUC_CHEQUE       NUMERIC (5) DEFAULT ((0)) NOT NULL,
	CUENTA_CHEQUE    NUMERIC (12) DEFAULT ((0)) NOT NULL,
	NOMBRE_CHEQUE    VARCHAR (60) DEFAULT ('' '') NULL,
	CONSTRAINT PK_CUENTAS_CHEQUES PRIMARY KEY (TIPO_DOCUMENTO,NUMERO_DOCUMENTO,BANCO_CHEQUE,SUC_CHEQUE,CUENTA_CHEQUE)
	)
')



EXECUTE('IF OBJECT_ID (''CLE_CHEQUES_LISTA_DESCUENTO'') IS NOT NULL
	DROP TABLE CLE_CHEQUES_LISTA_DESCUENTO
')

EXECUTE('CREATE TABLE CLE_CHEQUES_LISTA_DESCUENTO
	(
	TZ_LOCK                  NUMERIC (15) DEFAULT ((0)) NULL,
	TIPO_DOCUMENTO           VARCHAR (4) DEFAULT ('' '') NOT NULL,
	MONEDA                   NUMERIC (4) DEFAULT ((0)) NULL,
	SERIE_DEL_CHEQUE         VARCHAR (6) DEFAULT ('' '') NOT NULL,
	NUMERO_CHEQUE            NUMERIC (12) DEFAULT ((0)) NOT NULL,
	BANCO_GIRADO             NUMERIC (4) DEFAULT ((0)) NOT NULL,
	SUCURSAL_BANCO_GIRADO    NUMERIC (5) DEFAULT ((0)) NOT NULL,
	CODIGO_PLAZA             NUMERIC (4) DEFAULT ((0)) NULL,
	CODIGO_CAMARA            NUMERIC (4) DEFAULT ((0)) NULL,
	CODIGO_VERIFICADOR_1     NUMERIC (3) DEFAULT ((0)) NULL,
	CODIGO_VERIFICADOR_2     VARCHAR (3) DEFAULT ('' '') NULL,
	CODIGO_VERIFICADOR_3     NUMERIC (3) DEFAULT ((0)) NULL,
	NUMERICO_CUENTA_GIRADORA NUMERIC (12) DEFAULT ((0)) NULL,
	FECHA_ALTA               DATETIME NULL,
	NUMERO_DEPOSITO          NUMERIC (15) DEFAULT ((0)) NULL,
	IMPORTE                  NUMERIC (15,2) DEFAULT ((0)) NULL,
	PLAZO_COMPENSACION       NUMERIC (2) DEFAULT ((0)) NULL,
	FECHA_ACREDITACION       DATETIME NULL,
	CODIGO_CLIENTE           NUMERIC (12) DEFAULT ((0)) NULL,
	ESTADO                   NUMERIC (1) DEFAULT ((0)) NULL,
	CAUSAL_RECHAZO           NUMERIC (3) DEFAULT ((0)) NULL,
	JTS_OID_SALDO            NUMERIC (10) DEFAULT ((0)) NULL,
	FECHA_ENVIO_CAMARA       DATETIME NULL,
	PLAZO_PRESENTACION       NUMERIC (3) DEFAULT ((0)) NULL,
	COD_POSTAL               NUMERIC (4) NULL,
	CMC7                     VARCHAR (30) NULL,
	CONSTRAINT PK_CLE_CHEQUES_LISTA_DESCUENTO PRIMARY KEY (TIPO_DOCUMENTO,SERIE_DEL_CHEQUE,NUMERO_CHEQUE,BANCO_GIRADO,SUCURSAL_BANCO_GIRADO)
	)
')


EXECUTE('IF OBJECT_ID (''VW_CRE_DOCUMENTOS_DESC_O_AL_COBRO'') IS NOT NULL
	DROP VIEW VW_CRE_DOCUMENTOS_DESC_O_AL_COBRO
')

EXECUTE('CREATE VIEW VW_CRE_DOCUMENTOS_DESC_O_AL_COBRO
AS

SELECT ''FACTURA'' AS tipo,ISNULL((SELECT C1803 FROM SALDOS WHERE JTS_OID=jts_oid_cta_vista),0) AS cliente, CASE destino WHEN 3 THEN ''DESCUENTO'' ELSE ''AL COBRO'' END AS destino,
tipo_documento,documento_librador,Serie + ''-'' + numero_doc_real AS documento,
moneda,importe,fecha_documento,fecha_vencimiento,jts_oid_cta_vista ,0 AS banco_girado,0 AS sucursal_banco_girado, 0 AS numerico_cuenta_giradora
FROM CRE_CONF_FACTURAS WHERE ESTADO=1 AND TZ_LOCK=0
union
SELECT  ''CHEQUE'' AS TIPO, ISNULL((SELECT C1803 FROM SALDOS WHERE JTS_OID=jts_oid_banco),0) AS cliente, CASE destino_cheque WHEN 3 THEN ''DESCUENTO'' ELSE ''AL COBRO'' END AS destino,
ISNULL((SELECT TOP 1 tipo_documento FROM CHE_CUENTAS_CHEQUES WHERE CUENTA_CHEQUE= numerico_cuenta_giradora AND SUC_CHEQUE = sucursal_banco_girado AND  BANCO_CHEQUE=  banco_girado),'''') AS tipo_documento,
ISNULL((SELECT TOP 1 numero_documento FROM CHE_CUENTAS_CHEQUES WHERE CUENTA_CHEQUE= numerico_cuenta_giradora AND SUC_CHEQUE = sucursal_banco_girado AND  BANCO_CHEQUE=  banco_girado),'''') AS  documento_librador,
convert(VARCHAR(4),banco_girado,1) + ''-'' + convert(VARCHAR(5),sucursal_banco_girado,1) + ''-'' + convert(VARCHAR(4),COD_POSTAL,1) + ''-'' + convert(VARCHAR(12),numero_cheque,1) + ''-'' + convert(VARCHAR(12),numerico_cuenta_giradora,1) AS documento,
MONEDA,importe,fecha_alta AS fecha_documento,fecha_acreditacion AS fecha_vencimiento,jts_oid_banco AS jts_oid_cta_vusta,banco_girado,sucursal_banco_girado,numerico_cuenta_giradora
  FROM CLE_CHEQUES_SALIENTE WHERE ESTADO = 2 AND DESTINO_CHEQUE IN(2,3) AND TZ_LOCK=0
')



EXECUTE('IF OBJECT_ID (''VW_DEUDAS_INTERNAS_PP'') IS NOT NULL
	DROP VIEW VW_DEUDAS_INTERNAS_PP
')

EXECUTE('CREATE VIEW dbo.VW_DEUDAS_INTERNAS_PP (
	Sucursal, 
	"Nombre Sucursal", 
	Producto, 
	"Nombre Producto", 
	Cuenta, 
	Operacion, 
	Desglose, 
	Moneda, 
	Monto,  
	Opcion,
	"Numero Solicitud"
)
AS
	SELECT SUCURSAL AS "Sucursal", 
	NOMBRESUCURSAL AS "Nombre Sucursal", 
	PRODUCTO AS "Producto", 
	NOMBREPRODUCTO AS "Nombre Producto", 
	CUENTA AS "Cuenta", 
	OPERACION AS "Operacion", 
	DESGLOSE AS "Desglose", 
	MONEDA AS "Moneda", 
	CAP_REESTRUCTURA AS "Monto", 
	CASE WHEN r.CANCELO = ''S'' THEN ''Precancelar'' ELSE ''Vencido'' END AS "Opcion",
	NUMERO_SOLICITUD AS "Numero Solicitud"
	FROM VW_ASISTENCIAS cre
	INNER JOIN CRE_DET_REESTRUCTURA r ON cre.JTS_OID = r.JTS_OID_REESTRUCTURADA AND r.TZ_LOCK = 0
')



EXECUTE('IF OBJECT_ID (''VW_LISTA_DOCUMENTOS'') IS NOT NULL
	DROP VIEW VW_LISTA_DOCUMENTOS
')

EXECUTE('CREATE VIEW dbo.VW_LISTA_DOCUMENTOS (
	"Lista", 
	"Fecha", 
	"Estado", 
	"Descripcion", 
	"Cantidad", 
	"Monto", 
	"TipoDocumento", 
	"NombreDocumento", 
	"Producto", 
	"NombreProducto", 
	"ValorCobro", 
	"Tipo",
	"TipoLista", 
	"Cliente"
)
AS
	SELECT c.NUMERO_LISTA AS ''Lista'', c.FECHA_LISTA AS ''Fecha'', c.ESTADO AS ''Estado'', o.DESCRIPCION AS ''Descripcion'', 
	c.CANTIDAD_DOCUMENTOS AS ''Cantidad'', c.IMPORTE_TOTAL AS ''Monto'', c.TIPO_DOCUMENTO AS ''TipoDocumento'', 
	ot.DESCRIPCION AS ''NombreDocumento'', c.PRODUCTO AS ''Producto'', p.C6251 AS ''NombreProducto'', 
	c.VALOR_AL_COBRO AS ''ValorCobro'', c.TIPO_LISTA AS "Tipo", ol.DESCRIPCION AS ''TipoLista'', c.CLIENTE AS ''Cliente''
	FROM CRE_CAB_LISTA_DOCUMENTOS c
	INNER JOIN OPCIONES o ON c.ESTADO = o.OPCIONINTERNA AND o.NUMERODECAMPO = 2972 AND o.IDIOMA = ''E''
	INNER JOIN OPCIONES ot ON c.TIPO_DOCUMENTO = ot.OPCIONINTERNA AND ot.NUMERODECAMPO = 2975 AND ot.IDIOMA = ''E''
	LEFT JOIN OPCIONES ol ON c.TIPO_LISTA = ol.OPCIONINTERNA AND ol.NUMERODECAMPO = 43782 AND ol.IDIOMA = ''E''
	INNER JOIN PRODUCTOS p ON c.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0
	WHERE c.TZ_LOCK = 0
')



EXECUTE('IF OBJECT_ID (''V_SALDOS_PLANPAGOS'') IS NOT NULL
	DROP VIEW V_SALDOS_PLANPAGOS
')

EXECUTE('CREATE VIEW V_SALDOS_PLANPAGOS
AS
SELECT  0 AS TZ_LOCK,
        s.CUENTA AS NROPRESTAMO,
        p.C2300 AS NROCUOTA,
        p.C2302 AS FECHAVTO,
        s.MONEDA AS MONEDA,
        (
          CASE
            WHEN  s.C1601=(
                    SELECT  SUM(pp.C2304)
                    FROM    PLANPAGOS pp (nolock)
                    WHERE   s.JTS_OID=pp.SALDO_JTS_OID
                  )
              THEN  p.C2304
            ELSE  (
                    CASE
                      WHEN  (
                              SELECT  COUNT_BIG(*)
                              FROM    BS_PAYS_DETAIL pd (nolock),
                                      BS_HISTORIA_PLAZO hp (nolock)
                              WHERE   s.JTS_OID=pd.SALDOS_JTS_OID
                                      AND
                                      s.JTS_OID=hp.SALDOS_JTS_OID
                                      AND
                                      p.SALDO_JTS_OID=pd.SALDOS_JTS_OID
                                      AND
                                      p.SALDO_JTS_OID=hp.SALDOS_JTS_OID
                                      AND
                                      pd.HP_JTS_OID=hp.JTS_OID
                                      AND
                                      p.C2300=pd.CUOTA
                                      AND
                                      hp.ALGORITMO IN (5, 8)
                                      AND
                                      pd.CAPITALADELANTADO>0
                                      AND
                                      hp.CAPITALADELANTADO>0
                            )>0
                        THEN  p.C2304+(
                                SELECT  SUM(pd.CAPITALADELANTADO)
                                FROM    BS_PAYS_DETAIL pd (nolock),
                                        BS_HISTORIA_PLAZO hp (nolock)
                                WHERE   s.JTS_OID=pd.SALDOS_JTS_OID
                                        AND
                                        s.JTS_OID=hp.SALDOS_JTS_OID
                                        AND
                                        p.SALDO_JTS_OID=pd.SALDOS_JTS_OID
                                        AND
                                        p.SALDO_JTS_OID=hp.SALDOS_JTS_OID
                                        AND
                                        pd.HP_JTS_OID=hp.JTS_OID
                                        AND
                                        p.C2300=pd.CUOTA
                                        AND
                                        hp.ALGORITMO IN (5, 8)
                                        AND
                                        pd.CAPITALADELANTADO>0
                                        AND
                                        hp.CAPITALADELANTADO>0
                              )
                      ELSE  p.C2304
                    END
                  )
          END
        ) AS CAPITAL,
        p.C2305 AS INTERES,
        p.C2311 AS MORA, -- Este es el saldo de mora, lo carga el PA de días de atraso
        p.C2310 AS SDOINTERES,
        p.C2312 AS SDOMORA, -- No se carga
        s.PRODUCTO AS NROPRODUCTO,
        s.C1803 AS NROCLIENTE,
        p.C2309 AS SDOCAPITAL,
        s.C1785 AS TIPOPROD,
        s.C1601 AS CAPORIGINAL,
        s.C1644 AS TOTCUOTAS,
       --- s.C4765 AS CUOGRACIA,
        s.C1632 AS TASAINT,
        s.C1633 AS TASAMORA,
        s.C1621 AS FECDESEM,
        s.C1704 AS NROSOLICITUD,
        s.C1670 AS ANALISTA,
        s.JTS_OID AS IDJTSOID,
    --    p.FECHACANCELACION AS FECCANC,
        (
          SELECT  ISNULL(SUM(g.IMPORTE_GASTO), 0)
          FROM    GASTOS_POR_CUOTA g (nolock)
          WHERE   g.SALDOS_JTS_OID=s.JTS_OID
                  AND
                  g.NUMERO_CUOTA=p.C2300
                  AND
                  g.TZ_LOCK=0
        ) AS GASTO,
        (
          SELECT  ISNULL(SUM(g.SALDO_GASTO), 0)
          FROM    GASTOS_POR_CUOTA g (nolock)
          WHERE   g.SALDOS_JTS_OID=s.JTS_OID
                  AND
                  g.NUMERO_CUOTA=p.C2300
                  AND
                  g.TZ_LOCK=0
        ) AS SDOGASTO,
       --- s.CUENTASISTANT AS CUENTASISTANT,
        p.REMANENTE_CAPITAL AS REMANENTECAPITAL
     ---   p.ICMORA_DEV_CUO AS INTERESES_COMPESATORIO_MORA
FROM    SALDOS s (nolock)
        INNER JOIN  PLANPAGOS p (nolock)
          ON  s.JTS_OID=p.SALDO_JTS_OID
WHERE   p.TZ_LOCK=0
        AND
        s.TZ_LOCK=0
        AND S.ORDINAL=(SELECT max(z.ORDINAL) FROM SALDOS z WHERE z.C1785=5 and z.CUENTA=s.CUENTA AND z.TZ_LOCK=0)
')


EXECUTE('CREATE PROCEDURE dbo.[SP_CATEGORIZACION]
@p_id_proceso FLOAT(53),     /* Identificador de proceso */
@p_dt_proceso DATETIME,   /* Fecha de proceso */
@p_ret_proceso FLOAT OUT, /* Estado de ejecucion del PL/SQL(0:Correcto, 2: Error) */
@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------
	@numcli NUMERIC(12), -- numero de cliente
	@categoriacliente VARCHAR(1),
	@maxcategoria VARCHAR(1),
	@catnueva VARCHAR(1),
	@contador NUMERIC(10),
	@f_proceso DATE;
	
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
		SET @f_proceso =(SELECT FECHAPROCESO FROM PARAMETROS_FER with (nolock));
		
		DELETE FROM CRE_CATEGORIA_COMERCIAL_BITACORA WHERE F_PROCESO=  @f_proceso;

		DECLARE cursor1 CURSOR FOR 
			SELECT CODIGOCLIENTE, CATEGORIA_COMERCIAL, MAX(CATEGORIA)  FROM(
			SELECT  C.CODIGOCLIENTE,  C.CATEGORIA_COMERCIAL,
					CASE L.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE '' ''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN CRE_LIMITECLIENTE L ON C.CODIGOCLIENTE = L.CLIENTE AND PLAZO >= @f_proceso AND L.ESTADO=''A'' 
			WHERE (C.TZ_LOCK = 0 AND L.TZ_LOCK = 0)
			UNION ALL
			SELECT  C.CODIGOCLIENTE,   C.CATEGORIA_COMERCIAL,
					CASE VTA.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE '' ''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN SALDOS S ON C.CODIGOCLIENTE = S.C1803 AND S.C1785= 2 
			JOIN VTA_SOBREGIROS VTA ON S.JTS_OID = VTA.JTS_OID_SALDO AND VTA.FECHA_VENCIMIENTO >= @f_proceso 
			WHERE (C.TZ_LOCK = 0 AND VTA.TZ_LOCK = 0)
			UNION ALL
			SELECT  C.CODIGOCLIENTE,  C.CATEGORIA_COMERCIAL,
					CASE CRE.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE '' ''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN SALDOS S ON C.CODIGOCLIENTE = S.C1803 AND (S.C1785= 5 OR S.C1785= 6) AND S.C1604<0
			JOIN CRE_SALDOS CRE ON S.JTS_OID = CRE.SALDOS_JTS_OID 
			WHERE (C.TZ_LOCK = 0 AND CRE.TZ_LOCK = 0)
			) AS SUBQUERY GROUP BY CODIGOCLIENTE, CATEGORIA_COMERCIAL

	OPEN cursor1 
	FETCH NEXT FROM cursor1 INTO @numcli,  @categoriacliente,  @maxcategoria
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  	  
	   	  SET @catnueva = CASE @maxcategoria
	                       WHEN 1 THEN ''C''
	        	 		   WHEN 2 THEN ''S''
	        	 		   WHEN 3 THEN ''M''
	        	 		   ELSE '' ''
	                  	  END 
	                  
	                  	  
	      PRINT ''Numero Cliente:'' + CAST(@numcli AS VARCHAR) 
	   	  PRINT ''Categoria Actual:'' + @categoriacliente            	  
	      PRINT ''Nueva Categoria:'' + @catnueva   
	                	  
	      INSERT INTO dbo.CRE_CATEGORIA_COMERCIAL_BITACORA (COD_CLIENTE, F_PROCESO, CATEG_ANTERIOR, CATEG_NUEVA, TZ_LOCK)
		  VALUES (@numcli, @f_proceso, @categoriacliente, @catnueva, 0)
	      
	      UPDATE dbo.CLI_CLIENTES
		  SET CATEGORIA_COMERCIAL = @catnueva
		  WHERE CODIGOCLIENTE = @numcli
		 	      
	      
	      SET @contador=@contador+1
	       
	       
	             
	      FETCH NEXT FROM cursor1 INTO @numcli, @categoriacliente, @maxcategoria
	END 
	
	CLOSE cursor1  
	DEALLOCATE cursor1 
	
	
		    SET @p_msg_proceso = ''El Proceso de Cateorización de Clientes ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_CATEGORIZACION'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Cateorización de Clientes: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_CATEGORIZACION'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END

   	--   	CRE_CATEGORIA_COMERCIAL_BITACORA
')

 
EXECUTE('CREATE PROCEDURE dbo.SP_LISTA_DOCUMENTOS 
   @LISTA NUMERIC(12,0),
   @LISTA_NUEVA NUMERIC(12,0)
AS 
   BEGIN
   
   	INSERT INTO CRE_CAB_LISTA_DOCUMENTOS (TZ_LOCK, DEBITA_VTO, NUMERO_LISTA, ESTADO, CANTIDAD_DOCUMENTOS, IMPORTE_TOTAL, TIPO_DOCUMENTO, CLIENTE, MONEDA, FECHA_LISTA, TASA_INTERES, JTS_OID_SALDO, CUENTA, PRODUCTO, NUMERO_LOTE, EN_GARANTIA, VENDEDOR, ORIGEN, VALOR_AL_COBRO, TIPO_LISTA)
	SELECT 0, DEBITA_VTO, @LISTA_NUEVA, 1, CANTIDAD_DOCUMENTOS, IMPORTE_TOTAL, TIPO_DOCUMENTO, CLIENTE, MONEDA, FECHA_LISTA, TASA_INTERES, 0, 0, PRODUCTO, NUMERO_LOTE, EN_GARANTIA, VENDEDOR, ORIGEN, VALOR_AL_COBRO, TIPO_LISTA
	FROM CRE_CAB_LISTA_DOCUMENTOS
	WHERE NUMERO_LISTA = @LISTA AND TZ_LOCK = 0
	
	INSERT INTO CRE_AUX_CONF_FACTURAS (TZ_LOCK, NUMERO_LISTA, NUMERO_DOC_INTERNO, SERIE, NUMERO_DOC_REAL, IMPORTE, FECHA_DOCUMENTO, FECHA_VENCIMIENTO, NOMBRE_VENDEDOR, DOCUMENTO_LIBRADOR, ESTADO, TIPO_DOCUMENTO, TASA_INTERES, JTS_OID_SALDO, FECHA_VALOR)
	SELECT 0, @LISTA_NUEVA, NUMERO_DOC_INTERNO, SERIE, NUMERO_DOC_REAL, IMPORTE, FECHA_DOCUMENTO, FECHA_VENCIMIENTO, NOMBRE_VENDEDOR, DOCUMENTO_LIBRADOR, ESTADO, TIPO_DOCUMENTO, TASA_INTERES, JTS_OID_SALDO, FECHA_VALOR
	FROM CRE_AUX_CONF_FACTURAS
	WHERE NUMERO_LISTA = @LISTA AND TZ_LOCK = 0
	
	DELETE FROM CRE_CAB_LISTA_DOCUMENTOS WHERE NUMERO_LISTA = @LISTA
	
	DELETE FROM CRE_AUX_CONF_FACTURAS WHERE NUMERO_LISTA = @LISTA

   END
')


EXECUTE('CREATE   PROCEDURE SP_CONTROL_LIMITES_CREDITOS 
    @C_PRODUTO NUMERIC(5,0), 
    @PROD_MAX_CAP_ORIGEN    NUMERIC(15,2) OUTPUT,
    @PROD_MAX_CAP_VIGENTE   NUMERIC(15,2) OUTPUT, 
    @F_PROD_MAX_CAP_ORIGEN  NUMERIC(15,2) OUTPUT,
    @F_PROD_MAX_CAP_VIGENTE NUMERIC(15,2)OUTPUT
    
AS
BEGIN
	--------------- DECLARO VRIABLES ---------------
	DECLARE @P_PROD_MAX_CAP_ORIGEN    NUMERIC(15,2);
    DECLARE @P_PROD_MAX_CAP_VIGENTE   NUMERIC(15,2); 
    DECLARE @P_F_PROD_MAX_CAP_ORIGEN  NUMERIC(15,2);
    DECLARE @P_F_PROD_MAX_CAP_VIGENTE NUMERIC(15,2);
    DECLARE @P_FAMILIA_PRODUCTO       NUMERIC(5,0);
	------------------------------------------------
	
	 	
	 	
	 SELECT @P_FAMILIA_PRODUCTO = p.C6283
	   FROM PRODUCTOS p
	  WHERE p.C6250= @C_PRODUTO
	    AND p.TZ_LOCK =0
	    
	    
  SELECT @P_PROD_MAX_CAP_ORIGEN  = isnull(sum(C1601),0), 
         @P_PROD_MAX_CAP_VIGENTE = isnull(sum(abs(C1604)),0)	    
    FROM SALDOS
   WHERE PRODUCTO=@C_PRODUTO  
     AND TZ_LOCK =0	    
	   
  SELECT @P_F_PROD_MAX_CAP_ORIGEN   =  isnull(sum(C1601),0), 
         @P_F_PROD_MAX_CAP_VIGENTE  = isnull(sum(abs(C1604)),0)	    
    FROM SALDOS
   WHERE PRODUCTO IN (SELECT C6250 FROM PRODUCTOS
                       WHERE C6283 = @P_FAMILIA_PRODUCTO
                         AND TZ_LOCK = 0
                      ) 
     AND TZ_LOCK =0  
 
   
	SET @PROD_MAX_CAP_ORIGEN     = @P_PROD_MAX_CAP_ORIGEN;
	SET @PROD_MAX_CAP_VIGENTE    = @P_PROD_MAX_CAP_VIGENTE;
    SET @F_PROD_MAX_CAP_ORIGEN   = @P_F_PROD_MAX_CAP_ORIGEN;
    SET @F_PROD_MAX_CAP_VIGENTE  = @P_F_PROD_MAX_CAP_VIGENTE;
			 				
END
')



 

