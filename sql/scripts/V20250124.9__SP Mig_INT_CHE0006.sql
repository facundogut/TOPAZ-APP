create or ALTER    PROCEDURE [dbo].[Mig_INT_CHE0006]
/*********************************************************************************
Modulo  : DESCDOC
Tabla   : Bs_Historia_Plazo
Version : 20/12/2024 
***********************************************************************************/

@P_ID_PROCESO INT,
@P_DT_PROCESO DATE,

@P_RET_PROCESO INT OUTPUT,
@P_MSG_PROCESO VARCHAR(500) OUTPUT

AS

BEGIN

----------------Definicion Variables Intermedias--------------------------
--------------------------------------------------------------------------
DECLARE @p_modulo	 	    VARCHAR(30)
DECLARE @p_NomScr	 	    VARCHAR(30)
DECLARE @p_file		 	    VARCHAR(30)
DECLARE @p_tabl		 	    VARCHAR(30)
DECLARE @p_NomS		 	    VARCHAR(30)
DECLARE @v_FECHASYS  	    DATETIME
DECLARE @v_mensaje_ERR	    VARCHAR(2000)
DECLARE @v_CICLO            SMALLINT 
DECLARE @v_PROCESO          SMALLINT
DECLARE @v_CANT_FINAL	    BIGINT
DECLARE @v_CREDEB_Condicion NUMERIC (12)  
DECLARE @W_JTS_OID_SALDO    NUMERIC(20)
DECLARE @V_MAX_JTS_OID      NUMERIC(20)
DECLARE @v_FECHAPARAM  	    DATETIME

--------------------------------------------------------------------------

/*********************************************************************************
SETEO DE VARIABLES PRINCIPALES
***********************************************************************************/

SET @p_modulo			= 'CHEQUES'
SET @p_NomScr			= 'INT_CHE0006'
SET @p_tabl	    		= 'SALDOS'
SET @p_NomS				= 'INT_CHE0006'
SET @v_FECHASYS 		= SYSDATETIME()
SET @v_ciclo 			= 1
SET @v_proceso 			= 1
SET @v_CANT_FINAL 		= 1

SET @W_JTS_OID_SALDO 	= ISNULL((SELECT MAX(JTS_OID) + 1 FROM SALDOS (NOLOCK)),1)
SET @V_MAX_JTS_OID		= 0
SET @v_FECHAPARAM       = (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))


	BEGIN TRY
		-----------------------------------------------------------------
		--- Borrado defensivo de datos migrados
		-----------------------------------------------------------------
        DELETE FROM SALDOS WHERE C1827 IN ('IC1','IC2')
		-----------------------------------------------------------------

		-----------------------------------------------------------------
		-- CREACION DE TABLAS TEMPORALES
		-----------------------------------------------------------------
		
		-- Tabla con saldo acreedor faltantes -- 
		CREATE TABLE #MIG_SALDO_ACREEDOR (
		    SUCURSAL 	 		NUMERIC(5),
		    PRODUCTO 	 		NUMERIC(5),
		    CUENTA 		 		NUMERIC(12),
		    MONEDA 		 		NUMERIC(4),
		    OPERACION 	 		NUMERIC(12),
		    ORDINAL 	 		NUMERIC(3),
		    C1730  				NUMERIC(12),
		    C1692	 			NUMERIC(12),
		    C1804				NUMERIC(6),
		    C1803 				FLOAT,
		    C1620				DATETIME,
		    C1621				DATETIME,
		    C1627				DATETIME,
		    C1785 				NUMERIC(1),
		    INTERESES			DECIMAL(15,2)  
		); 
		
		-- Tabla con saldo deudor  faltantes -- 
		CREATE TABLE #MIG_SALDO_DEUDOR (
		    SUCURSAL 	 		NUMERIC(5),
		    PRODUCTO 	 		NUMERIC(5),
		    CUENTA 		 		NUMERIC(12),
		    MONEDA 		 		NUMERIC(4),
		    OPERACION 	 		NUMERIC(12),
		    ORDINAL 	 		NUMERIC(3),
		    C1730  				NUMERIC(12),
		    C1692	 			NUMERIC(12),
		    C1804				NUMERIC(6),
		    C1620				DATETIME,
		    C1621				DATETIME,
		    C1627				DATETIME,
		    C1785 				NUMERIC(1),
		    INTERESES			DECIMAL(15,2)  
		);	
		
		
		-----------------------------------------------------------------
		-- CARGAMOS LAS TABLAS TEMPORALES
		-----------------------------------------------------------------
		INSERT INTO #MIG_SALDO_ACREEDOR (
								SUCURSAL,
							    PRODUCTO,
							    CUENTA,
							    MONEDA,
							    OPERACION,
							    ORDINAL,
							    C1730,
							    C1692,
							    C1804,
							    C1803,
							    C1620,
							    C1621,
							    C1627,
							    C1785,
							    INTERESES
								)
								SELECT 
									s.SUCURSAL,
									92 PRODUCTO, 
									P.C6326 AS CUENTA,
									s.MONEDA,
									s.OPERACION,
									0 AS ORDINAL,
									P.C6326 AS C1730, 
									P.C6326 AS C1692, 
									123001 AS c1804,
									s.C1803,
									s.C1620,
									s.C1621,
									s.C1627,
									1 AS C1785,
									-s.C1608 AS INTERESES
								FROM SALDOS s (nolock)
								INNER JOIN CLI_CLIENTES c (nolock)
									ON s.C1803 = c.CODIGOCLIENTE
								INNER JOIN PLANCTAS P (nolock)
									ON 	P.C6340	= 123001
									AND P.C6308 = c.CODIGORESIDENCIA
									AND P.C6310 = c.SUBDIVISION1
								WHERE s.C1827 = 'CHE' 
								AND s.C1785 = 6;
								
	
		-- SELECT * FROM #MIG_SALDO_ACREEDOR;
		
		
		INSERT INTO #MIG_SALDO_DEUDOR (
								SUCURSAL,
							    PRODUCTO,
							    CUENTA,
							    MONEDA,
							    OPERACION,
							    ORDINAL,
							    C1730,
							    C1692,
							    C1804,
							    C1620,
							    C1621,
							    C1627,
							    C1785,
							    INTERESES
								)
								SELECT 
									s.SUCURSAL,
									0 PRODUCTO, 
									P.C6326 AS CUENTA,
									s.MONEDA,
									0 AS OPERACION,
									0 AS ORDINAL,
									P.C6326 AS C1730, 
									P.C6326 AS C1692, 
									124000 AS c1804,
									PA.FECHAPROCESO AS C1620,
									PA.FECHAPROCESO AS C1621,
									PA.FECHAPROCESO AS C1627,
									1 AS C1785,
									SUM(s.C1608) AS INTERESES
								FROM SALDOS s (nolock)
								INNER JOIN CLI_CLIENTES c (nolock)
									ON s.C1803 = c.CODIGOCLIENTE
								INNER JOIN PLANCTAS P (nolock)
									ON 	P.C6340	= 124000
									AND P.C6308 = c.CODIGORESIDENCIA
									AND P.C6310 = c.SUBDIVISION1
								INNER JOIN PARAMETROS PA (NOLOCK)
									ON 1 = 1
								WHERE s.C1827 = 'CHE' 
								AND s.C1785 = 6
								GROUP BY s.SUCURSAL,P.C6326,s.MONEDA,PA.FECHAPROCESO;
								
		  
		-- SELECT * FROM #MIG_SALDO_DEUDOR;						
		-----------------------------------------------------------------
 
                      
        -----------------------------------------------------------------
		--------- Se eliminan los indices asociados al JTS_OID ----------
		-----------------------------------------------------------------			
		BEGIN
			BEGIN TRANSACTION 
				DROP INDEX INDICEJTS ON dbo.SALDOS;  	
				DROP INDEX SALDOS_IDX01 ON dbo.SALDOS;  
			COMMIT; 
		END	
		-----------------------------------------------------------------

		-----------------------------------------------------------------
		-------- Se deshabilita el trigger asociados al JTS_OID ---------
		-----------------------------------------------------------------
		BEGIN	
			DISABLE TRIGGER [dbo].[saldos_jts_oid] ON [dbo].[SALDOS];
		END
		-----------------------------------------------------------------

		-----------------------------------------------------------------
		-- Carga Masiva Saldo acreedor faltantes --
		-----------------------------------------------------------------
		BEGIN
			INSERT INTO Saldos	(                                        
                                SUCURSAL,
                                PRODUCTO,
								CUENTA,
								MONEDA, 
								OPERACION, 
								ORDINAL,
								C1600,
								C1601,
								C1603,
								C1604,
								c1620, 
								c1621,
								c1627,
								C1692,
								C1730,
								C1804,
								C1785,
								C1803,
                                JTS_OID,
                                C1827
                                ) 
								( 
								SELECT 
                                SUCURSAL,
							    PRODUCTO,
							    CUENTA,
							    MONEDA,
							    OPERACION,
							    ORDINAL,
							    INTERESES, -- C1600
							    INTERESES, -- C1601
							    INTERESES, -- C1603
							    INTERESES, -- C1604
							    C1620,
							    C1621,
							    C1627,
							    C1692,
							    C1730,
							    C1804,
							    C1785,
							    C1803,
                                (ROW_NUMBER() OVER(ORDER BY SUCURSAL,PRODUCTO,CUENTA,MONEDA,OPERACION,ORDINAL) + @W_JTS_OID_SALDO) as JTS_OID, -- JTS_OID
								'IC1'
                                FROM #MIG_SALDO_ACREEDOR
                                )
		END 
		-----------------------------------------------------------------
		
		/*
        -----------------------------------------------------------------
		--- Actualizo JTS_OID MAX despues de Alta Producto 92
		-----------------------------------------------------------------
        SET @W_JTS_OID_SALDO 	= (SELECT MAX(JTS_OID) + 1 FROM SALDOS (NOLOCK))
        -----------------------------------------------------------------

		SELECT 
        SUCURSAL,
	    PRODUCTO,
	    CUENTA,
	    MONEDA,
	    OPERACION,
	    ORDINAL,
	    INTERESES, -- C1600
	    INTERESES, -- C1601
	    INTERESES, -- C1603
	    INTERESES, -- C1604
	    C1620,
	    C1621,
	    C1627,
	    C1692,
	    C1730,
	    C1804,
	    C1785,
        (ROW_NUMBER() OVER(ORDER BY SUCURSAL,PRODUCTO,CUENTA,MONEDA,OPERACION,ORDINAL) + @W_JTS_OID_SALDO) as JTS_OID, -- JTS_OID
		'IC2'
        FROM #MIG_SALDO_DEUDOR
                                                     
		-----------------------------------------------------------------
		-- Carga Masiva Saldo deudor faltantes --
		-----------------------------------------------------------------
		BEGIN
			INSERT INTO Saldos	(                                        
                                SUCURSAL,
                                PRODUCTO,
								CUENTA,
								MONEDA, 
								OPERACION, 
								ORDINAL,
								C1600,
								C1601,
								C1603,
								C1604,
								c1620, 
								c1621,
								c1627,
								C1692,
								C1730,
								C1804,
								C1785,
                                JTS_OID,
                                C1827
                                ) 
								( 
								SELECT 
                                SUCURSAL,
							    PRODUCTO,
							    CUENTA,
							    MONEDA,
							    OPERACION,
							    ORDINAL,
							    INTERESES, -- C1600
							    INTERESES, -- C1601
							    INTERESES, -- C1603
							    INTERESES, -- C1604
							    C1620,
							    C1621,
							    C1627,
							    C1692,
							    C1730,
							    C1804,
							    C1785,
                                (ROW_NUMBER() OVER(ORDER BY SUCURSAL,PRODUCTO,CUENTA,MONEDA,OPERACION,ORDINAL) + @W_JTS_OID_SALDO) as JTS_OID, -- JTS_OID
								'IC2'
                                FROM #MIG_SALDO_DEUDOR
                                )
		END 
		-----------------------------------------------------------------
		*/
	
		-----------------------------------------------------------------
		---- Se crean los indices asociados al JTS_OID y clave Topaz ----
		-----------------------------------------------------------------		
		BEGIN
			BEGIN TRANSACTION 
				CREATE UNIQUE INDEX INDICEJTS
					ON dbo.SALDOS (JTS_OID)  
				
				
				CREATE UNIQUE INDEX SALDOS_IDX01
					ON dbo.SALDOS (SUCURSAL, PRODUCTO, CUENTA, MONEDA, OPERACION, ORDINAL)

			COMMIT;
			
		END
		-----------------------------------------------------------------
		
		-----------------------------------------------------------------
		---------- Se habilita el trigger asociados al JTS_OID ----------
		-----------------------------------------------------------------		
		BEGIN
			-- Se habilita el trigger asociados al JTS_OID
			ENABLE Trigger [dbo].[saldos_jts_oid] ON [dbo].[SALDOS];
		END
		-----------------------------------------------------------------

		--------------------------------------------------------------------------------------------------------
		-- Se actualiza el numerador del SEQUENCE que se utiliza para resolver el valor del JST_OID en Saldos --
		--------------------------------------------------------------------------------------------------------
		BEGIN
			SET @V_MAX_JTS_OID = (SELECT MAX(JTS_OID)+1 FROM SALDOS (NOLOCK))
			DBCC CHECKIDENT (SEQUENCE_saldos, RESEED, @V_MAX_JTS_OID)
		END
		--------------------------------------------------------------------------------------------------------
		
	 ---
		 SET @P_RET_PROCESO = 1
		 SET @P_MSG_PROCESO = 'EJECUTADO CON EXITO. '
	 ---	 


		BEGIN
			BEGIN TRANSACTION
			INSERT INTO MIG_RESULTADOS
						(CICLO, PROCESO, MODULO, FECHAINICIO, FECHAFIN, ESTADO, ERRORES, MENSAJE, ARCHIVO)
					VALUES
					   (@v_CICLO,
						@v_PROCESO,
						@p_MODULO,
						@v_FECHASYS,
						SYSDATETIME(),
						'A',
						'N',
						'OK',
						@p_NomScr)
			COMMIT;	
		END
	END TRY

	BEGIN CATCH
		 BEGIN TRANSACTION
		 ---
		 SET @P_RET_PROCESO = 0
		 SET @P_MSG_PROCESO = 'EJECUCION CON ERROR. '
	 ---	 
		 SET @v_mensaje_ERR = ERROR_MESSAGE()	
		 INSERT INTO MIG_RESULTADOS
					(CICLO, PROCESO, MODULO, FECHAINICIO, FECHAFIN, ESTADO, ERRORES, MENSAJE, ARCHIVO)
					VALUES
					   (@v_CICLO,
						@v_PROCESO,
						@p_MODULO,
						@v_FECHASYS,
						SYSDATETIME(),
						'R',
						'S',
				    		@v_mensaje_ERR,
						@p_NomScr)
											
			COMMIT;
	END CATCH
END





GO

