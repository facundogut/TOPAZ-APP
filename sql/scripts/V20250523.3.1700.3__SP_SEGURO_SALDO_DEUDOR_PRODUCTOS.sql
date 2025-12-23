EXECUTE('
CREATE OR ALTER PROCEDURE SP_SEGURO_SALDO_DEUDOR_PRODUCTOS
   @P_ID_PROCESO float(53), /* Identificador de proceso*/
   @P_DT_PROCESO datetime2(0), /* Fecha de proceso*/
   @p_Fecha DATETIME, /*Fecha de Generacion del Archivo*/

   @P_RET_PROCESO float(53)  OUTPUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error)*/
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS 
   BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      --- Cargo variables ---
      
      DECLARE @FECHA_PROCESO DATETIME

      DECLARE @INFO_GENERAL TABLE (
      SALDO_JTS_OID NUMERIC(15),
      NRO_CLIENTE NUMERIC(15),
      COD_ASEGURADORA NUMERIC(4),
      FECHA_INFO DATETIME,
      DNI NUMERIC(10),
      CUIL NUMERIC(11),
      PRODUCTO VARCHAR(2),
      SUCURSAL NUMERIC(5),
      OPERACION NUMERIC(16), 
      DESGLOSE NUMERIC(12),
      ADMINISTRADORA NUMERIC(2),      
      NUM_TARJETA NUMERIC(20),
      ID_PRODUCTO VARCHAR(35),        
      FECHA_ALTA DATETIME,
      EDAD NUMERIC(3),
      FECHA_NACIMIENTO DATETIME,
      LIMITE_CREDITO NUMERIC(15,2),
      DEUDA_TOTAL_PRODUCTO NUMERIC(15,2),
      DEUDA_TOPEADA NUMERIC(15,2),
      DEUDA_REMANENTE NUMERIC(15,2),
      GERENCIA NUMERIC(2)
      )
      
      
      BEGIN TRY
      
      SET @FECHA_PROCESO = @p_Fecha
      
	  BEGIN
      DELETE FROM CRE_SEGURO_DEUDAS_POR_PRODUCTO WHERE Fecha_Info = @FECHA_PROCESO
                
                INSERT INTO @INFO_GENERAL     
                --PRESTAMOS ASEGURADORA 18 BANCA EMPRESA
			   select md.SALDO_JTS_OID, 
			   md.Cliente,
			   18 as Cod_Aseguradora, 
			   md.fecha_info, 
			   doc.NUM_DOC_FISICO, 
			   md.Num_Doc, 
			   ''PR'' as Producto,
			   md.Suc_Cliente,
			   md.Operacion,
			   md.Desglose,
			   0 as Administradora,
			   0 as Nro_Tarjeta,
			   CONCAT(md.Suc_Cliente,md.Operacion,md.Desglose) as ID_Producto,
			   md.Fecha_Alta_Oper,
			   DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info) -
			       CASE
			           WHEN DATEADD(YY, DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info), pf.FECHANACIMIENTO) > md.fecha_info
			           THEN 1
			           ELSE 0
			       END AS Edad,
			   pf.FECHANACIMIENTO, 
			   0 as Limite_Credito,
			   sum(md.Saldo_Capital + md.Int_Deven_Cobrar_Cont + md.IVA_Financiado + md.RG_Financiado + md.Seguro_Financ + md.Otros_Accesorios) as Deuda_Total_Producto,
			   0 as Deuda_Topeada,
			   0 as Deuda_Remanente,
			   2 as Gerencia
			   from MEMO_DETALLE md WITH(NOLOCK)
			   INNER JOIN CRE_SEGURO_SALDO_DEUDOR cssd WITH(NOLOCK) ON md.saldo_jts_oid = cssd.saldos_jts_oid AND cssd.tz_lock = 0 and cssd.ASEGURADORA=18 and cssd.TIPO_SEGURO=''A''--solo préstamos que tienen seguro con aseguradora 18
			   INNER JOIN CLI_CLIENTES C WITH(NOLOCK) ON C.CODIGOCLIENTE = md.Cliente AND C.TZ_LOCK = 0 AND C.CATEGORIA_COMERCIAL = ''M'' --me quedo con banca empresa
			   INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON cp.TITULARIDAD = ''T'' AND cp.CODIGOCLIENTE = md.cliente AND cp.TZ_LOCK = 0
			   INNER JOIN CLI_PERSONASFISICAS pf WITH(NOLOCK) ON pf.NUMEROPERSONAFISICA = cp.NUMEROPERSONA AND pf.TZ_LOCK = 0 --solo personas físicas
			   INNER JOIN CLI_DOCUMENTOSPFPJ doc WITH(NOLOCK) ON doc.NUMEROPERSONAFJ = cp.NUMEROPERSONA AND doc.TZ_LOCK = 0 AND doc.TIPOPERSONA=''F''
			   where md.fecha_info=@FECHA_PROCESO --fecha de cierre de mes
			   and md.Cuenta_orden=''N'' --quito las cuentas de orden
			   and md.producto in (select b.c6250 from PRODUCTOS b WITH(NOLOCK) where b.TZ_LOCK=0 and b.c6252=5) --solo préstamos
			   and c.CATEGORIARESULTANTE not in (''3'', ''4'', ''5'') ---calificacion <=2 - donde parametrizar los días de atraso
			   and md.Num_Doc not in (select CUIL from CLI_MAESTRO_FALLECIDOS cmf (nolock) where cmf.tz_lock=0 AND cmf.FECHA_DEFUNCION<@FECHA_PROCESO) --se quitan fallecidos
			   group by md.SALDO_JTS_OID, md.Cliente, md.fecha_info, doc.NUM_DOC_FISICO, md.Num_Doc, md.Suc_Cliente, md.Operacion, md.Desglose, md.Fecha_Alta_Oper, pf.FECHANACIMIENTO
			UNION ALL
			   --PRESTAMOS ASEGURADORA 18 BANCA PERSONAL
			   select md.SALDO_JTS_OID, 
			   md.Cliente,
			   18 as Cod_Aseguradora, 
			   md.fecha_info, 
			   doc.NUM_DOC_FISICO, 
			   md.Num_Doc, 
			   ''PR'' as Producto,
			   md.Suc_Cliente,
			   md.Operacion,
			   md.Desglose,
			   0 as Administradora,
			   0 as Nro_Tarjeta,
			   CONCAT(md.Suc_Cliente,md.Operacion,md.Desglose) as ID_Producto,
			   md.Fecha_Alta_Oper,
			   DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info) -
			       CASE
			           WHEN DATEADD(YY, DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info), pf.FECHANACIMIENTO) > md.fecha_info
			           THEN 1
			           ELSE 0
			       END AS Edad,
			   pf.FECHANACIMIENTO, 
			   0 as Limite_Credito,
			   sum(md.Saldo_Capital + md.Int_Deven_Cobrar_Cont + md.IVA_Financiado + md.RG_Financiado + md.Seguro_Financ + md.Otros_Accesorios) as Deuda_Total_Producto,
			   0 as Deuda_Topeada,
			   0 as Deuda_Remanente,
			   1 as Gerencia
			   from MEMO_DETALLE md WITH(NOLOCK)
			   INNER JOIN CRE_SEGURO_SALDO_DEUDOR cssd WITH(NOLOCK) ON md.saldo_jts_oid = cssd.saldos_jts_oid AND cssd.tz_lock = 0 and cssd.ASEGURADORA=18 and cssd.TIPO_SEGURO=''A''--solo préstamos que tienen seguro con aseguradora 18
			   INNER JOIN CLI_CLIENTES C WITH(NOLOCK) ON C.CODIGOCLIENTE = md.Cliente AND C.TZ_LOCK = 0 AND C.CATEGORIA_COMERCIAL != ''M'' --que no sea banca empresa
			   INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON cp.TITULARIDAD = ''T'' AND cp.CODIGOCLIENTE = md.cliente AND cp.TZ_LOCK = 0
			   INNER JOIN CLI_PERSONASFISICAS pf WITH(NOLOCK) ON pf.NUMEROPERSONAFISICA = cp.NUMEROPERSONA AND pf.TZ_LOCK = 0 --solo personas físicas
			   INNER JOIN CLI_DOCUMENTOSPFPJ doc WITH(NOLOCK) ON doc.NUMEROPERSONAFJ = cp.NUMEROPERSONA AND doc.TZ_LOCK = 0 AND doc.TIPOPERSONA=''F''
			   where md.fecha_info=@FECHA_PROCESO --fecha de cierre de mes
			   and md.Cuenta_orden=''N'' --quito las cuentas de orden
			   and md.producto in (select b.c6250 from PRODUCTOS b WITH(NOLOCK) where b.TZ_LOCK=0 and b.c6252=5) --solo préstamos
			   and c.CATEGORIARESULTANTE not in (''3'', ''4'', ''5'') 
			   and md.Num_Doc not in (select CUIL from CLI_MAESTRO_FALLECIDOS cmf (nolock) where cmf.tz_lock=0 AND cmf.FECHA_DEFUNCION<@FECHA_PROCESO) --se quitan fallecidos
			   group by md.SALDO_JTS_OID, md.Cliente, md.fecha_info, doc.NUM_DOC_FISICO, md.Num_Doc, md.Suc_Cliente, md.Operacion, md.Desglose, md.Fecha_Alta_Oper, pf.FECHANACIMIENTO
			UNION ALL
			   --CC ASEGURADORA 19
			   select md.SALDO_JTS_OID, 
			   md.Cliente,
			   19 as Cod_Aseguradora, 
			   md.fecha_info, 
			   doc.NUM_DOC_FISICO, 
			   md.Num_Doc, 
			   ''CC'' as Producto,
			   md.Suc_Cliente,
			   md.Operacion,
			   md.Desglose,
			   0 as Administradora,
			   0 as Nro_Tarjeta,
			   CAST(md.Operacion AS VARCHAR(35)) AS ID_Producto,
			   md.Fecha_Alta_Oper,
			   DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info) -
			       CASE
			           WHEN DATEADD(YY, DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info), pf.FECHANACIMIENTO) > md.fecha_info
			           THEN 1
			           ELSE 0
			       END AS Edad,
			   pf.FECHANACIMIENTO, 
			   0 as Limite_Credito,
			   sum(md.Saldo_Capital + md.Int_Deven_Cobrar_Cont + md.IVA_Financiado + md.RG_Financiado + md.Seguro_Financ + md.Otros_Accesorios) as Deuda_Total_Producto,
			   0 as Deuda_Topeada,
			   0 as Deuda_Remanente,
			   2 as Gerencia
			   from MEMO_DETALLE md WITH(NOLOCK)
			   INNER JOIN CRE_SEGURO_SALDO_DEUDOR cssd WITH(NOLOCK) ON md.saldo_jts_oid = cssd.saldos_jts_oid AND cssd.tz_lock = 0 and cssd.ASEGURADORA=19 and cssd.TIPO_SEGURO=''A''--solo CC que tienen seguro con aseguradora 19
			   INNER JOIN CLI_CLIENTES C WITH(NOLOCK) ON C.CODIGOCLIENTE = md.Cliente AND C.TZ_LOCK = 0
			   INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON cp.TITULARIDAD = ''T'' AND cp.CODIGOCLIENTE = md.cliente AND cp.TZ_LOCK = 0
			   INNER JOIN CLI_PERSONASFISICAS pf WITH(NOLOCK) ON pf.NUMEROPERSONAFISICA = cp.NUMEROPERSONA AND pf.TZ_LOCK = 0 --solo personas físicas
			   INNER JOIN CLI_DOCUMENTOSPFPJ doc WITH(NOLOCK) ON doc.NUMEROPERSONAFJ = cp.NUMEROPERSONA AND doc.TZ_LOCK = 0 AND doc.TIPOPERSONA=''F''
			   where md.fecha_info=@FECHA_PROCESO --fecha de cierre de mes
			   and md.Cuenta_orden=''N'' --quito las cuentas de orden
			   and md.producto in (select b.c6250 from PRODUCTOS b WITH(NOLOCK) where b.TZ_LOCK=0 and (b.c6252=2 or b.c6800 in (''A'', ''S''))) --solo CC y acuerdos
			   and c.CATEGORIARESULTANTE not in (''3'', ''4'', ''5'') ---calificacion <=2 - donde parametrizar los días de atraso
			   and md.Num_Doc not in (select CUIL from CLI_MAESTRO_FALLECIDOS cmf (nolock) where cmf.tz_lock=0 AND cmf.FECHA_DEFUNCION<@FECHA_PROCESO) --se quitan fallecidos
			   group by md.SALDO_JTS_OID, md.Cliente, md.fecha_info, doc.NUM_DOC_FISICO, md.Num_Doc, md.Suc_Cliente, md.Operacion, md.Desglose, md.Fecha_Alta_Oper, pf.FECHANACIMIENTO
			   having sum(md.Saldo_Capital + md.Int_Deven_Cobrar_Cont + md.IVA_Financiado + md.RG_Financiado + md.Seguro_Financ + md.Otros_Accesorios) <> 0
			UNION ALL
			   --TJC ASEGURADORA 17
			   select md.SALDO_JTS_OID, 
			   md.Cliente,
			   17 as Cod_Aseguradora, 
			   md.fecha_info, 
			   doc.NUM_DOC_FISICO, 
			   md.Num_Doc, 
			   ''TC'' as Producto,
			   md.Suc_Cliente,
			   md.Operacion,
			   md.Desglose,
			   tmu.Administradora as Administradora,
			   md.Nro_Tarjeta_Cre as Nro_Tarjeta,
			   CONCAT(tmu.Administradora,md.Nro_Tarjeta_Cre) as ID_Producto,
			   md.Fecha_Alta_Oper,
			   DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info) -
			       CASE
			           WHEN DATEADD(YY, DATEDIFF(YY, pf.FECHANACIMIENTO, md.fecha_info), pf.FECHANACIMIENTO) > md.fecha_info
			           THEN 1
			           ELSE 0
			       END AS Edad,
			   pf.FECHANACIMIENTO, 
			   sum(md.Capital_Original) as Limite_Credito,
			   sum(md.Saldo_Capital + md.Int_Deven_Cobrar_Cont + md.IVA_Financiado + md.RG_Financiado + md.Seguro_Financ + md.Otros_Accesorios) as Deuda_Total_Producto,
			   0 as Deuda_Topeada,
			   0 as Deuda_Remanente,
			   2 as Gerencia
			   from MEMO_DETALLE md WITH(NOLOCK)
			   INNER JOIN TJC_MAESTRO_USUARIO tmu WITH(NOLOCK) ON tmu.jts_saldo_tarjeta = md.saldo_jts_oid AND tmu.TZ_LOCK = 0 and tmu.tipo_tjc=''T''
			   --INNER JOIN CRE_SEGURO_SALDO_DEUDOR cssd WITH(NOLOCK) ON md.saldo_jts_oid = cssd.saldos_jts_oid AND cssd.tz_lock = 0 and cssd.ASEGURADORA=17 and cssd.TIPO_SEGURO=''A''--solo TJC que tienen seguro con aseguradora 17
			   INNER JOIN CLI_CLIENTES C WITH(NOLOCK) ON C.CODIGOCLIENTE = md.Cliente AND C.TZ_LOCK = 0
			   INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON cp.TITULARIDAD = ''T'' AND cp.CODIGOCLIENTE = md.cliente AND cp.TZ_LOCK = 0
			   INNER JOIN CLI_PERSONASFISICAS pf WITH(NOLOCK) ON pf.NUMEROPERSONAFISICA = cp.NUMEROPERSONA AND pf.TZ_LOCK = 0 --solo personas físicas
			   INNER JOIN CLI_DOCUMENTOSPFPJ doc WITH(NOLOCK) ON doc.NUMEROPERSONAFJ = cp.NUMEROPERSONA AND doc.TZ_LOCK = 0 AND doc.TIPOPERSONA=''F''
			   where md.fecha_info=@FECHA_PROCESO --fecha de cierre de mes
			   and md.Cuenta_orden=''N'' --quito las cuentas de orden
			   and md.producto in (select b.c6250 from PRODUCTOS b WITH(NOLOCK) where b.TZ_LOCK=0 and b.c6800=''T'') --solo TJC
			   and c.CATEGORIARESULTANTE not in (''3'', ''4'', ''5'')
			   and md.Num_Doc not in (select CUIL from CLI_MAESTRO_FALLECIDOS cmf (nolock) where cmf.tz_lock=0 AND cmf.FECHA_DEFUNCION<@FECHA_PROCESO) --se quitan fallecidos
			   group by md.SALDO_JTS_OID, md.Cliente, md.fecha_info, doc.NUM_DOC_FISICO, md.Num_Doc, md.Suc_Cliente, md.Operacion, md.Desglose, tmu.Administradora, md.Nro_Tarjeta_Cre, md.Fecha_Alta_Oper, pf.FECHANACIMIENTO
			   ORDER BY md.Cliente                 
                 
                
                 INSERT INTO CRE_SEGURO_DEUDAS_POR_PRODUCTO  
                 (SALDO_JTS_OID,
    			  NRO_CLIENTE,
    			  COD_ASEGURADORA,
    			  FECHA_INFO,
    			  DNI,
    			  CUIL,
    			  PRODUCTO,
    			  SUCURSAL,
    			  OPERACION,
    			  DESGLOSE,
    			  ADMINISTRADORA,
    			  NUM_TARJETA,
    			  ID_PRODUCTO,
    			  FECHA_ALTA,
    			  EDAD,
    			  FECHA_NACIMIENTO,
    			  LIMITE_CREDITO,
    			  DEUDA_TOTAL_PRODUCTO,
    			  DEUDA_TOPEADA,
    			  DEUDA_REMANENTE,
    			  GERENCIA
                 )
                 (SELECT
                 SALDO_JTS_OID,
    			  NRO_CLIENTE,
    			  COD_ASEGURADORA,
    			  FECHA_INFO,
    			  DNI,
    			  CUIL,
    			  PRODUCTO,
    			  SUCURSAL,
    			  OPERACION,
    			  DESGLOSE,
    			  ADMINISTRADORA,
    			  NUM_TARJETA,
    			  ID_PRODUCTO,
    			  FECHA_ALTA,
    			  EDAD,
    			  FECHA_NACIMIENTO,
    			  LIMITE_CREDITO,
    			  DEUDA_TOTAL_PRODUCTO,
    			  DEUDA_TOPEADA,
    			  DEUDA_REMANENTE,
    			  GERENCIA
                 FROM @INFO_GENERAL 
                 WHERE DEUDA_TOTAL_PRODUCTO > 0
                 )
                 
              
                
                  	 
			           BEGIN
			
			            SET @P_RET_PROCESO = 1
			
			            SET @P_MSG_PROCESO = ''La tabla de deudas por producto ha sido cargada correctamente''
			
			            DECLARE
			               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5 varchar(8000)
			               
			               SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5 = ''I''
			
			            EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			               @P_ID_PROCESO = @P_ID_PROCESO, 
			               @P_FCH_PROCESO = @P_DT_PROCESO, 
			               @P_NOM_PACKAGE = ''SP_SEGURO_SALDO_DEUDOR_PRODUCTOS'', 
			               @P_COD_ERROR = @P_RET_PROCESO, 
			               @P_MSG_ERROR = @P_MSG_PROCESO, 
			               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5
			         END
			         
			         
					 BEGIN
					 
					   DECLARE @CANTCAMP_ NUMERIC(10)
					   
					   SET @CANTCAMP_ = (SELECT COUNT(1) FROM CRE_SEGURO_DEUDAS_POR_PRODUCTO WITH(NOLOCK) WHERE FECHA_INFO = @FECHA_PROCESO)
					 
					   SET @P_RET_PROCESO = 1
					 
			           SET @P_MSG_PROCESO = ''Se agregaron '' + ISNULL(CAST(@CANTCAMP_ AS varchar(max)), '''') + '' a DEUDAS_POR_PRODUCTO''
			
			            DECLARE
			               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)
			               
			               SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''I''
			
			    
			            EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			               @P_ID_PROCESO = @P_ID_PROCESO, 
			               @P_FCH_PROCESO = @P_DT_PROCESO, 
			               @P_NOM_PACKAGE = ''SP_SEGURO_SALDO_DEUDOR_PRODUCTOS'', 
			               @P_COD_ERROR = @P_RET_PROCESO, 
			               @P_MSG_ERROR = @P_MSG_PROCESO, 
			               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
			
			         END          
              END
             
              

              END TRY
              
              BEGIN CATCH
              	BEGIN	
         
				  SET @P_RET_PROCESO = 3
					
				  SET @P_MSG_PROCESO = ''Ingreso de DEUDAS por PRODUCTO Finalizo con Errores: ''+ ERROR_MESSAGE() + '' '' + CONVERT(VARCHAR,ERROR_LINE())
					         
				  DECLARE
					@PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 varchar(8000)
					
					SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 = ''E''
							
				  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
					@P_ID_PROCESO = @P_ID_PROCESO, 
					@P_FCH_PROCESO = @P_DT_PROCESO, 
					@P_NOM_PACKAGE = ''SP_SEGURO_SALDO_DEUDOR_PRODUCTOS - Error'', 
					@P_COD_ERROR = @P_RET_PROCESO, 
					@P_MSG_ERROR = @P_MSG_PROCESO, 
					@P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4
					
				END
              END CATCH
																	  

   END
 ')