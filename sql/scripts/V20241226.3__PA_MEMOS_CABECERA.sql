EXECUTE('
ALTER PROCEDURE PA_MEMOS_CABECERA
   @P_ID_PROCESO float(53), /* Identificador de proceso*/
   @P_DT_PROCESO datetime2(0), /* Fecha de proceso*/

   @P_RET_PROCESO float(53)  OUTPUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error)*/
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS 
   BEGIN
   	
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      --- Cargo variables ---
      DECLARE @FECHA_PROCESO DATETIME 
      
      
      /*
       Prevision
       Sit Juridica Ext
       Max atraso
      */
      

      DECLARE @INFO_CLIENTES TABLE (TIPO_DOCUMENTO VARCHAR(4), NUMERODOC VARCHAR(20), NOMBRE VARCHAR(70),
      CLASIFICACION VARCHAR(3), CUENTAORDEN VARCHAR(1), CLIENTE NUMERIC(12), NUMPERSONA NUMERIC(12),
	  SECTOR_PERSONA VARCHAR(5), SECTOR_ACTIVIDAD NUMERIC(5),
      COD_ACT_BCRA NUMERIC(5), SECCION VARCHAR(1), COD_ACT_AFIP VARCHAR(12), DESC_COD_ACT_AFIP VARCHAR(400), 
      CAT_CLIENTE VARCHAR(1), CAT_IVA VARCHAR(2), DESC_CAT_IVA VARCHAR(40), TIPO_PERSONA VARCHAR(1),
      SEGMENTO NUMERIC(2), SUBSEGMENTO NUMERIC(2), FALLECIDO VARCHAR(1), CLIENTE_VINC VARCHAR(1),
      SITUACION_JURIDICA VARCHAR(1), SUCURSAL_CLIENTE NUMERIC(5), ---CLIENTE_ENCUADRADO VARCHAR(1),
      REFINANCIADO VARCHAR(1), ORIGEN_SITUACION VARCHAR(50), TAMANO_EMP VARCHAR(20), SIT_ATRASO VARCHAR(3),
      PREVISION NUMERIC(15,2), EMERGENCIA VARCHAR(1), DESC_CATEGORIA VARCHAR(60), SIT_JUD_EXT VARCHAR(1)
      )

     ---DECLARE @FECHA_PROCESO DATETIME 
     
      
      SET @FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
      
      DELETE FROM MEMO_CABECERA WHERE Fecha_Info = @FECHA_PROCESO
             		        			 
                BEGIN TRY
                
                INSERT INTO @INFO_CLIENTES
                SELECT DISTINCT
                 MD.Tipo_Doc, --Tipo documento
                 MD.Num_Doc, --Numero documento
                 MD.Nombre_Apellido AS NOMBRE, ---Nombre
                 C.CATEGORIARESULTANTE AS CLASIFICACION, ---Clasificacion
                 ''N'' AS CUENTA_ORDEN, ---Cuenta orden
                 C.CODIGOCLIENTE, ---Cliente
                 CP.NUMEROPERSONA, --- Persona
                 C.SUBDIVISION1 AS SECTOR_PERSONA, --- Sector persona
                 CAF.CODIGO_SECTOR, --- Sector actividad
                 CAF.CODIGO_BCRA, ---Cod actividad BCRA
                 CAF.CODIGO_SECCION, ---Seccion
                 CAF.CODIGO_ACT_AFIP, --- Cod act afip
                 caf.DESCRIPCION, --- CLI_Cod_Act_AFIP
                 C.CATEGORIA_COMERCIAL, ---- Categoria comercial
                 C.IVA, ---IVA
                 OP.DESCRIPCION, ---Descripcion iva
                 C.TIPO, ---Tipo persona
                 C.SEGMENTOCLIENTE, ---Segmento cliente
                 C.SUBSEGMENTOCLIENTE, ---Subsegmento cliente
                 ---CASE WHEN CF.CUIL IS NULL THEN ''N'' ELSE ''S'' END 
                 ''N'' AS FALLECIDO,  ---Fallecido
                 ---CASE WHEN V.ID_VINCULO IS NULL THEN ''N'' ELSE ''S'' END 
                 ''N'' AS VINCULADO, ---Vinculado
                 ---CASE WHEN C.TIPO = ''F'' THEN PF.SITUACION_JURIDICA ELSE PJ.SITUACION_JURIDICA END 
                 '''' AS SIT_JURIDICA, ---Situacion juridica
                 c.SUCURSALVINCULADA, ---Sucursal cliente
                 CASE WHEN c.OBJETIVA_REFINANCIADO <> '' '' OR c.OBJETIVA_REFINANCIADO IS NULL THEN ''N'' ELSE ''S'' END AS REFINACIADO, ---Refinanciado
                 CASE WHEN
                 CXC.TIPO_CALIFICACION IS NULL THEN ''N/A'' ELSE OP2.DESCRIPCION END AS ORIGEN_SITUACION, --- Origen situacion
                 CTE.TAM_ACTUAL,
                 C.CATEGORIAOBJETIVA AS SIT_ATRASO,
                 ---SUM(ISNULL(MD.PREVISION,0)),
                 0 AS PREVISION,
                 CASE 
                 WHEN CCE.id_emergencia IS NULL THEN ''N'' ELSE ''S'' END AS EMERGENCIA,
                 CASE 
                WHEN C.CATEGORIA_COMERCIAL = ''M'' THEN ''Comercial''
                WHEN C.CATEGORIA_COMERCIAL = ''S'' THEN ''Comercial asimilable a consumo''
                WHEN C.CATEGORIA_COMERCIAL = ''C'' THEN ''Consumo''
                ELSE '''' END AS DESC_CATEGORIA,
                CASE WHEN C.CLIENTE_DEVENGA_SUSPENSO = 1 THEN ''S'' ELSE ''N'' END AS SIT_JUD_EXT
                FROM CLI_CLIENTES C WITH(NOLOCK)
                INNER JOIN MEMO_DETALLE MD WITH(NOLOCK) ON C.CODIGOCLIENTE = MD.Cliente
                 
                 INNER JOIN CLI_CLIENTEPERSONA CP WITH(NOLOCK) ON CP.TITULARIDAD = ''T'' AND CP.CODIGOCLIENTE = C.CODIGOCLIENTE AND CP.TZ_LOCK = 0
                 INNER JOIN CLI_ACTIVIDAD_ECONOMICA AE WITH(NOLOCK) ON AE.CODIGO_PERSONA_CLIENTE = CP.NUMEROPERSONA AND AE.TZ_LOCK = 0
                 AND AE.ORDINAL_ACTIVIDAD IN (SELECT MIN(ORDINAL_ACTIVIDAD) FROM CLI_ACTIVIDAD_ECONOMICA WITH(NOLOCK) WHERE CODIGO_PERSONA_CLIENTE = AE.CODIGO_PERSONA_CLIENTE AND TZ_LOCK = 0)
                 INNER JOIN CLI_COD_ACT_AFIP CAF WITH(NOLOCK) ON CAF.CODIGO_ACT_AFIP = AE.CODIGO_ACTIVIDAD
                 LEFT JOIN CRE_TAM_EMP_BITACORA CTE WITH(NOLOCK) ON CTE.CLIENTE = C.CODIGOCLIENTE AND CTE.TZ_LOCK = 0 AND
                 CTE.JTS_BITACORA = (SELECT TOP 1 JTS_BITACORA FROM CRE_TAM_EMP_BITACORA WITH(NOLOCK) 
                 WHERE CLIENTE = C.CODIGOCLIENTE AND FECHA <= @FECHA_PROCESO AND TZ_LOCK = 0 ORDER BY FECHA DESC, JTS_BITACORA DESC)
                 LEFT JOIN HISTORICO_CALIF_X_CLIENTE CXC WITH(NOLOCK) ON CXC.CLIENTE = C.CODIGOCLIENTE AND CXC.TZ_LOCK = 0
                 AND CXC.FECHA = (SELECT TOP 1 FECHA FROM HISTORICO_CALIF_X_CLIENTE WITH(NOLOCK) WHERE CLIENTE = C.CODIGOCLIENTE 
                 AND FECHA <= @FECHA_PROCESO AND TZ_LOCK=0 ORDER BY FECHA DESC)
                 LEFT JOIN OPCIONES OP2 WITH(NOLOCK) ON OP2.NUMERODECAMPO = 43917 AND OP2.IDIOMA = ''E'' AND OP2.OPCIONINTERNA = CXC.TIPO_CALIFICACION 
                 ----LEFT JOIN CLI_PERSONASFISICAS PF WITH(NOLOCK) ON PF.NUMEROPERSONAFISICA = CP.NUMEROPERSONA AND PF.TZ_LOCK = 0
                 ----LEFT JOIN CLI_PERSONASJURIDICAS PJ WITH(NOLOCK) ON PJ.NUMEROPERSONAJURIDICA = CP.NUMEROPERSONA AND PJ.TZ_LOCK = 0
                 ----LEFT JOIN CLI_MAESTRO_FALLECIDOS CF WITH(NOLOCK) ON CF.CUIL = MD.Num_Doc AND CF.ESTADO = ''P'' AND CF.TZ_LOCK = 0
                 ---LEFT JOIN CRE_VINCULACIONES V WITH(NOLOCK) ON V.ID_PERSONA_VINCULADA = CP.NUMEROPERSONA AND V.FECHA_INICIO <= @FECHA_PROCESO 
                 ---AND V.TZ_LOCK = 0 AND (V.FECHA_FIN IS NULL OR (CASE WHEN (SELECT REL.PARAMETRO_613 FROM CRE_VINCULOS_RELACIONES REL WITH(NOLOCK) WHERE REL.ID_VINCULO = V.TIPO_VINCULO) = ''N'' THEN V.FECHA_FIN
                 ---ELSE DATEADD(yy,(SELECT IMPORTE FROM CRE_PARAMETROS WITH(NOLOCK) WHERE CODIGO = 613), V.FECHA_FIN) END) >= @FECHA_PROCESO)
                 
                 LEFT JOIN OPCIONES OP WITH(NOLOCK) ON OP.NUMERODECAMPO = 1357 AND OP.IDIOMA = ''E'' AND OP.OPCIONINTERNA = C.IVA 
                 LEFT JOIN CRE_CERTIFICADOS_EMERGENCIA CCE WITH(NOLOCK) ON CCE.nro_cliente = C.CODIGOCLIENTE AND CCE.TZ_LOCK = 0 AND CCE.fecha_alta >= @FECHA_PROCESO
                 AND CCE.id_emergencia IN (SELECT ID FROM CRE_EMERGENCIA_AGRO WITH(NOLOCK) WHERE TZ_LOCK = 0 AND fecha_vig_desde >= @FECHA_PROCESO
                 AND fecha_vig_hasta <= @FECHA_PROCESO)
                 WHERE C.TZ_LOCK = 0 AND MD.Fecha_Info = @FECHA_PROCESO
                 /*GROUP BY C.CODIGOCLIENTE, MD.Tipo_Doc, 
                 MD.Num_Doc, 
                 MD.Nombre_Apellido, 
                 C.CATEGORIARESULTANTE,
                 CP.NUMEROPERSONA, --- Persona
                 C.SUBDIVISION1, --- Sector persona
                 CAF.CODIGO_SECTOR, --- Sector actividad
                 CAF.CODIGO_BCRA, ---Cod actividad BCRA
                 CAF.CODIGO_SECCION, ---Seccion
                 CAF.CODIGO_ACT_AFIP, --- Cod act afip
                 caf.DESCRIPCION, --- CLI_Cod_Act_AFIP
                 C.CATEGORIA_COMERCIAL, ---- Categoria comercial
                 C.IVA, ---IVA
                 OP.DESCRIPCION, ---Descripcion iva
                 C.TIPO, ---Tipo persona
                 C.SEGMENTOCLIENTE, ---Segmento cliente
                 C.SUBSEGMENTOCLIENTE,
                 c.SUCURSALVINCULADA,
                 CXC.TIPO_CALIFICACION,
                 OP2.DESCRIPCION,
                 CTE.TAM_ACTUAL,
                 C.CATEGORIAOBJETIVA,
                 CCE.id_emergencia,
                 C.CLIENTE_DEVENGA_SUSPENSO,
                 c.OBJETIVA_REFINANCIADO */
                
                
                
                --- Situacion juridica PF - SITUACION_JURIDICA
                
                UPDATE IC
                SET SITUACION_JURIDICA = CPF.SITUACION_JURIDICA
                FROM @INFO_CLIENTES IC
                INNER JOIN CLI_PERSONASFISICAS CPF ON CPF.NUMEROPERSONAFISICA = IC.NUMPERSONA AND CPF.TZ_LOCK = 0
                WHERE IC.TIPO_PERSONA = ''F''
                
                --- Situacion juridica PJ
                
                UPDATE IC
                SET SITUACION_JURIDICA = CPJ.SITUACION_JURIDICA
                FROM @INFO_CLIENTES IC
                INNER JOIN CLI_PERSONASJURIDICAS CPJ ON CPJ.NUMEROPERSONAJURIDICA = IC.NUMPERSONA AND CPJ.TZ_LOCK = 0
                WHERE IC.TIPO_PERSONA = ''J''
                
                --- Fallecidos
                
                UPDATE IC
                SET FALLECIDO = ''S''
                FROM @INFO_CLIENTES IC
                INNER JOIN CLI_MAESTRO_FALLECIDOS CF WITH(NOLOCK) ON CF.CUIL = IC.NUMERODOC 
                AND CF.ESTADO = ''P'' AND CF.TZ_LOCK = 0
                
                
               ---- Vinculados
               
               UPDATE IC
               SET CLIENTE_VINC = ''S''
               FROM @INFO_CLIENTES IC
               INNER JOIN CRE_VINCULACIONES V WITH(NOLOCK) ON V.ID_PERSONA_VINCULADA = IC.NUMPERSONA AND V.FECHA_INICIO <= @FECHA_PROCESO 
               AND V.TZ_LOCK = 0 AND (V.FECHA_FIN IS NULL OR (CASE WHEN (SELECT REL.PARAMETRO_613 FROM CRE_VINCULOS_RELACIONES REL WITH(NOLOCK) WHERE REL.ID_VINCULO = V.TIPO_VINCULO) = ''N'' THEN V.FECHA_FIN
               ELSE DATEADD(yy,(SELECT IMPORTE FROM CRE_PARAMETROS WITH(NOLOCK) WHERE CODIGO = 613), V.FECHA_FIN) END) >= @FECHA_PROCESO)
                
               ---- Cuenta orden
               
               UPDATE IC
               SET CUENTAORDEN = ''S''
               FROM @INFO_CLIENTES IC
               INNER JOIN MEMO_DETALLE M WITH(NOLOCK) ON M.Cuenta_Orden = ''S'' AND M.Fecha_Info = @FECHA_PROCESO 
               AND M.Num_Doc = IC.NUMERODOC
               
               ---- Prevision
                
               UPDATE IC
               SET PREVISION = M.Prevision
               FROM @INFO_CLIENTES IC
               INNER JOIN (SELECT Num_Doc, SUM(ISNULL(Prevision,0)) AS Prevision 
               FROM MEMO_DETALLE WITH(NOLOCK) WHERE Fecha_Info = @FECHA_PROCESO GROUP BY Num_Doc) M ON M.Num_Doc = IC.NUMERODOC
               
                --- Asistencias
                DECLARE @INFO_ASISTENCIAS TABLE (DEUDA_TOTAL NUMERIC(18,2), DEUDA_SIN_GARANTIA NUMERIC(18,2), 
                DEUDA_CON_GARANTIA_A NUMERIC(18,2),
                DEUDA_CON_GARANTIA_B NUMERIC(18,2), NUMERODOC VARCHAR(20))
                
                INSERT INTO @INFO_ASISTENCIAS
                SELECT 
				SUM(MD.Saldo_Capital + (MD.Int_Deven_Cobrar_Cont-MD.Int_Adelantados) + MD.IVA_Financiado + MD.RG_Financiado + MD.Seguro_Financ + MD.Otros_Accesorios + MD.Acuerdo_No_Utiliz),
				SUM(CASE WHEN (MD.Tipo_Gtia_BCRA IS NULL OR MD.Tipo_Gtia_BCRA = 0) THEN (MD.Saldo_Capital + (MD.Int_Deven_Cobrar_Cont-MD.Int_Adelantados) + MD.IVA_Financiado + MD.RG_Financiado + MD.Seguro_Financ + MD.Otros_Accesorios + MD.Acuerdo_No_Utiliz) ELSE 0 END),
				SUM(CASE WHEN MD.Tipo_Gtia_BCRA = 1 THEN (MD.Saldo_Capital + (MD.Int_Deven_Cobrar_Cont-MD.Int_Adelantados) + MD.IVA_Financiado + MD.RG_Financiado + MD.Seguro_Financ + MD.Otros_Accesorios + MD.Acuerdo_No_Utiliz) ELSE 0 END),
				SUM(CASE WHEN MD.Tipo_Gtia_BCRA = 2 THEN (MD.Saldo_Capital + (MD.Int_Deven_Cobrar_Cont-MD.Int_Adelantados) + MD.IVA_Financiado + MD.RG_Financiado + MD.Seguro_Financ + MD.Otros_Accesorios + MD.Acuerdo_No_Utiliz) ELSE 0 END),
				IC.NUMERODOC
				FROM @INFO_CLIENTES IC
				INNER JOIN MEMO_DETALLE MD WITH(NOLOCK) ON IC.NUMERODOC = MD.Num_Doc
				WHERE MD.Fecha_Info = @FECHA_PROCESO
				GROUP BY IC.NUMERODOC
                
                
                --- Max asistencia
                DECLARE @INFO_MAX_ASISTENCIA TABLE (DEUDA_MAXIMA NUMERIC(18,2), NUMERODOC VARCHAR(20), FECHA_ALTA DATETIME)
                DECLARE @INFO_MAX_ASISTENCIA_MEMO TABLE (DEUDA_MAXIMA NUMERIC(18,2), NUMERODOC VARCHAR(20), FECHA_ALTA DATETIME)
                
                
                DECLARE @DIA_FECHA NUMERIC(2)
                SET @DIA_FECHA = (SELECT DATEPART(DD, @FECHA_PROCESO))
                
                INSERT INTO @INFO_MAX_ASISTENCIA (DEUDA_MAXIMA, NUMERODOC, FECHA_ALTA)
                (SELECT
                IA.DEUDA_TOTAL,
                IC.NUMERODOC,
                @FECHA_PROCESO
                FROM @INFO_CLIENTES IC
                INNER JOIN @INFO_ASISTENCIAS IA ON IA.NUMERODOC = IC.NUMERODOC)
                
                
                IF(@DIA_FECHA > 1)
                	BEGIN
                		---- Obtengo la deuda máxima del mes
                		INSERT INTO @INFO_MAX_ASISTENCIA_MEMO (DEUDA_MAXIMA, NUMERODOC)
                		(SELECT 
                		MAX(MC.Max_Asistencia),
                		MC.CUIT_CUIL_CDI
                		FROM MEMO_CABECERA MC
                		INNER JOIN @INFO_CLIENTES IC ON MC.CUIT_CUIL_CDI = IC.NUMERODOC
                		WHERE datediff(yy,MC.Fecha_Info,@FECHA_PROCESO) = 0
                		AND datediff(MM,MC.Fecha_Info,@FECHA_PROCESO) = 0
                		GROUP BY MC.CUIT_CUIL_CDI
                		)
                	
                		UPDATE IMAM
               			SET FECHA_ALTA = (SELECT TOP 1 FECHA_INFO FROM MEMO_CABECERA WHERE CUIT_CUIL_CDI = IMAM.NUMERODOC AND
               			Max_Asistencia = IMAM.DEUDA_MAXIMA AND datediff(yy,Fecha_Info,@FECHA_PROCESO) = 0
                		AND datediff(MM,Fecha_Info,@FECHA_PROCESO) = 0 ORDER BY Fecha_Info ASC)
               			FROM @INFO_MAX_ASISTENCIA_MEMO IMAM
               			INNER JOIN @INFO_CLIENTES IC ON IMAM.NUMERODOC = IC.NUMERODOC
                	
						UPDATE IMA SET
						DEUDA_MAXIMA = (CASE WHEN IMA.DEUDA_MAXIMA < ISNULL(IMAM.DEUDA_MAXIMA,0) THEN IMAM.DEUDA_MAXIMA ELSE IMA.DEUDA_MAXIMA END)
						,FECHA_ALTA = (CASE WHEN IMA.DEUDA_MAXIMA < ISNULL(IMAM.DEUDA_MAXIMA,0) THEN IMAM.FECHA_ALTA 
						WHEN IMA.DEUDA_MAXIMA > ISNULL(IMAM.DEUDA_MAXIMA,0) THEN IMA.FECHA_ALTA 
						WHEN IMA.DEUDA_MAXIMA = ISNULL(IMAM.DEUDA_MAXIMA,0) AND IMAM.FECHA_ALTA < IMA.FECHA_ALTA THEN IMAM.FECHA_ALTA
						ELSE IMA.FECHA_ALTA END)
						FROM @INFO_MAX_ASISTENCIA IMA
						LEFT JOIN @INFO_MAX_ASISTENCIA_MEMO IMAM ON IMA.NUMERODOC = IMAM.NUMERODOC
                	END
                
                
                DECLARE @INFO_ATRASO TABLE (NUMERODOC VARCHAR(20), DIAS_ATRASO NUMERIC(10), ANIOS_ATRASO NUMERIC(10))
                
                INSERT INTO @INFO_ATRASO
                SELECT
                MD.Num_Doc,
                MAX(MD.Dias_Atraso),
                DATEDIFF(YY,DATEADD(dd,-(MAX(MD.Dias_Atraso)), @FECHA_PROCESO),@FECHA_PROCESO)
                ----MAX(DATEDIFF(YY,@FECHA_PROCESO,C1628))
                FROM MEMO_DETALLE MD WITH(NOLOCK)
                INNER JOIN @INFO_CLIENTES IC ON MD.Num_Doc = IC.NUMERODOC
                WHERE MD.Fecha_Info = @FECHA_PROCESO
                GROUP BY MD.Num_Doc
                /*FROM SALDOS S WITH(NOLOCK) 
                INNER JOIN VW_CLI_X_DOC C WITH(NOLOCK) ON S.C1803 = C.CODIGOCLIENTE
                WHERE S.TZ_LOCK = 0 AND S.C1604 <> 0 AND S.C1785 IN (5,6)
                AND S.C1621 <= @FECHA_PROCESO AND S.C1628 >= @FECHA_PROCESO
                GROUP BY C.NUMERODOC*/
                
                
                
                
                INSERT INTO MEMO_CABECERA 
                (FECHA_INFO, 
                CUIT_CUIL_CDI, 
                Denominacion, 
                CLASIFICACION, 
                ORIGEN_SITUACION, 
                CUENTA_ORDEN,
                DEUDA_TOTAL, 
                DEUDA_SIN_GAR, 
                DEUDA_GTIASPREFA, 
                DEUDA_GTIASPREFB, 
                SECTOR_ACTIV, 
                SECCION_ACTIV, 
                COD_ACTIV_BCRA,
                COD_ACTIV_AFIP, 
                DESC_COD_ACTIV_AFIP, 
                SUC_CLIENTE, 
                Categoria_Cliente, 
                CAT_IVA, 
                DESC_CAT_IVA, 
                SIT_prod_banco,
                SECTOR_PERSONA, 
                TIPO_PERSONA, 
                SEGMENTO, 
                SUBSEGMENTO, 
                DEUDOR_ENCUADRADO_Ley25326, 
                Clte_Refinanciado, 
                FALLECIDO, 
                SIT_JURIDICA,
                TAMANO_EMP, 
                MAX_ASISTENCIA, 
                FECHA_MAX_ASIST, 
                CLIENTE_VINC, 
                CLIENTE, 
                TZ_LOCK,
                PREVISION,
                MAX_ATRASO,
                EMERGENCIA,
                DESC_CATEGORIA, 
                SIT_JURIDICA_EXT)
                (SELECT DISTINCT
                @FECHA_PROCESO,
                IC.NUMERODOC,
                IC.NOMBRE,
                IC.CLASIFICACION,
                IC.ORIGEN_SITUACION,
                IC.CUENTAORDEN,
                CASE
                WHEN IA.DEUDA_TOTAL IS NOT NULL THEN IA.DEUDA_TOTAL ELSE 0 END,
                CASE
                WHEN IA.DEUDA_SIN_GARANTIA IS NOT NULL THEN IA.DEUDA_SIN_GARANTIA ELSE 0 END,
                CASE
                WHEN IA.DEUDA_CON_GARANTIA_A IS NOT NULL THEN IA.DEUDA_CON_GARANTIA_A ELSE 0 END,
                CASE
                WHEN IA.DEUDA_CON_GARANTIA_B IS NOT NULL THEN IA.DEUDA_CON_GARANTIA_B ELSE 0 END,
                IC.SECTOR_ACTIVIDAD,
                IC.SECCION,
                IC.COD_ACT_BCRA,
                CASE 
                WHEN LEN(RTRIM(IC.COD_ACT_AFIP)) = 0 OR IC.COD_ACT_AFIP IS NULL THEN NULL
                ELSE
                CONVERT(NUMERIC(12),IC.COD_ACT_AFIP) END,
                IC.DESC_COD_ACT_AFIP,
                IC.SUCURSAL_CLIENTE,
                CASE 
                WHEN LEN(RTRIM(IC.CAT_CLIENTE)) = 0 OR IC.CAT_CLIENTE IS NULL
                THEN NULL
                WHEN IC.CAT_CLIENTE = ''M'' THEN 1
                WHEN IC.CAT_CLIENTE = ''S'' THEN 2
                WHEN IC.CAT_CLIENTE = ''C'' THEN 3 END,
                IC.CAT_IVA,
                IC.DESC_CAT_IVA,
                IC.SIT_ATRASO,
                CASE WHEN LEN(RTRIM(IC.SECTOR_PERSONA)) = 0 OR IC.SECTOR_PERSONA IS NULL
                THEN NULL
                ELSE
                CONVERT(NUMERIC(5),IC.SECTOR_PERSONA) END,
                IC.TIPO_PERSONA,
                IC.SEGMENTO,
                IC.SUBSEGMENTO,
                CASE WHEN ISNULL(IAT.ANIOS_ATRASO,0) > 5 THEN ''N'' ELSE ''S'' END AS DEUDOR_ENCUADRADO,
                IC.REFINANCIADO,
                IC.FALLECIDO,
                IC.SITUACION_JURIDICA,
                IC.TAMANO_EMP,
                CASE
                WHEN IMA.DEUDA_MAXIMA IS NOT NULL THEN IMA.DEUDA_MAXIMA ELSE 0 END,
                CASE
                WHEN IMA.FECHA_ALTA IS NOT NULL THEN IMA.FECHA_ALTA ELSE NULL END,
                IC.CLIENTE_VINC,
                IC.CLIENTE,
                0,
                CASE WHEN IA.DEUDA_TOTAL = 0 OR IA.DEUDA_TOTAL IS NULL THEN 0 ELSE IC.PREVISION END AS PREVISION,
                ISNULL(IAT.DIAS_ATRASO,0),
                IC.EMERGENCIA,
                IC.DESC_CATEGORIA,
                IC.SIT_JUD_EXT
                FROM @INFO_CLIENTES IC 
                LEFT JOIN @INFO_ASISTENCIAS IA ON IC.NUMERODOC = IA.NUMERODOC
                LEFT JOIN @INFO_MAX_ASISTENCIA IMA ON IMA.NUMERODOC = IC.NUMERODOC
                LEFT JOIN @INFO_ATRASO IAT ON IAT.NUMERODOC=IC.NUMERODOC
                WHERE IMA.DEUDA_MAXIMA <> 0
                AND IA.DEUDA_TOTAL >= 0)
                
                
                  	 
			           BEGIN
			
			            SET @P_RET_PROCESO = 1
			
			            SET @P_MSG_PROCESO = ''Las tablas de memos han sido cargadas correctamente''
			
			            DECLARE
			               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5 varchar(8000)
			               
			               SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5 = ''I''
			
			            EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			               @P_ID_PROCESO = @P_ID_PROCESO, 
			               @P_FCH_PROCESO = @P_DT_PROCESO, 
			               @P_NOM_PACKAGE = ''PA_MEMOS'', 
			               @P_COD_ERROR = @P_RET_PROCESO, 
			               @P_MSG_ERROR = @P_MSG_PROCESO, 
			               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5
			         END
			         
			         
					 BEGIN
					 
					   SET @P_RET_PROCESO = 1
					   
					   DECLARE @CANTCAMP_ NUMERIC(10)
					   
					   SET @CANTCAMP_ = (SELECT COUNT(1) FROM MEMO_CABECERA WITH(NOLOCK) WHERE FECHA_INFO = @FECHA_PROCESO)
					 
			           SET @P_MSG_PROCESO = ''Se agregaron '' + ISNULL(CAST(@CANTCAMP_ AS varchar(max)), '''') + '' registros a memos cabecera''
			
			            DECLARE
			               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)
			               
			               SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''I''
			
			    
			            EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			               @P_ID_PROCESO = @P_ID_PROCESO, 
			               @P_FCH_PROCESO = @P_DT_PROCESO, 
			               @P_NOM_PACKAGE = ''PA_MEMOS_CABECERA'', 
			               @P_COD_ERROR = @P_RET_PROCESO, 
			               @P_MSG_ERROR = @P_MSG_PROCESO, 
			               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
			
			         END          
            

              END TRY
              
              BEGIN CATCH
              	BEGIN	
              	
         
				  SET @P_RET_PROCESO = 3
					
				  SET @P_MSG_PROCESO = ''Ingreso de memos Finalizo con Errores:'' + ERROR_MESSAGE()
					         
				  DECLARE
					@PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 varchar(8000)
					
					SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 = ''E''
							
				  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
					@P_ID_PROCESO = @P_ID_PROCESO, 
					@P_FCH_PROCESO = @P_DT_PROCESO, 
					@P_NOM_PACKAGE = ''PA_MEMOS_CABECERA - Error'', 
					@P_COD_ERROR = @P_RET_PROCESO, 
					@P_MSG_ERROR = @P_MSG_PROCESO, 
					@P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4
					
				END
              END CATCH
																	  

   END
')