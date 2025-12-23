EXECUTE('

ALTER PROCEDURE PA_CONV_REC_CAJAS_ALTA_CAB

--ESTO SE VA A CORRER EN CADENA DE INCIO TONCES TENGO QUE VER PARAMETROS NECESARIOS*/ 
@P_ID_PROCESO float(53),
@P_DT_PROCESO  datetime2(0),
@P_RET_PROCESO float(53)  OUTPUT,
@P_MSG_PROCESO varchar(max)  OUTPUT

AS

	BEGIN
	
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
	  
	  DECLARE @fecha_proceso  DATETIME;
      DECLARE @str_archivo  VARCHAR(24);
      DECLARE @estado  VARCHAR(1);
      DECLARE @last_id  NUMERIC(15);
      DECLARE @id_convenio NUMERIC(15);
      DECLARE @moneda NUMERIC(5);
      DECLARE @cab_existentes TABLE ( convenio NUMERIC(15));
      DECLARE @v_constante VARCHAR(1);
      DECLARE @count NUMERIC(10);
		
	-- INSTANCIO VARIABLES
	SET @count = 0;
	SET @estado  = ''I'';
	SET @str_archivo = ''REC_CAJA_'';
	SELECT @fecha_proceso = FECHAPROCESO, @moneda = MONNAC FROM PARAMETROS;
	SELECT @last_id = MAX(ID) FROM REC_CAB_RECAUDOS_CAJA;
	INSERT INTO @cab_existentes (convenio) SELECT CONVENIO 
											FROM REC_CAB_RECAUDOS_CAJA with (nolock)
											WHERE FECHACARGA = @fecha_proceso 
													AND TZ_LOCK = 0;
	
	DECLARE 
		cursor_convenios  CURSOR
		FOR SELECT Id_ConvRec 
			FROM CONV_CONVENIOS_REC with (nolock)
			WHERE Canal = 1 
					AND Id_TpoConv = 4 
					AND Estado = ''A'' 
					AND TZ_LOCK = 0
		OPEN cursor_convenios
		FETCH NEXT FROM cursor_convenios INTO @id_convenio 
		
		BEGIN TRANSACTION
		
			BEGIN TRY
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF NOT EXISTS (SELECT convenio  FROM @cab_existentes WHERE convenio = @id_convenio)
					BEGIN
						--SET @last_id = @last_id + 1
						SET @count = @count + 1 
						INSERT INTO REC_CAB_RECAUDOS_CAJA (ID, ESTADO, ARCHIVO, CONVENIO, FECHACARGA, ID_LIQUIDACION, MONEDA, TOTALREGISTROS, TOTALIMPORTE, TZ_LOCK)
						VALUES (@last_id+@count, @estado, CONCAT(@str_archivo,@id_convenio), @id_convenio, @fecha_proceso, 0, @moneda, 0, 0, 0)
					END
				FETCH NEXT FROM cursor_convenios INTO @id_convenio
				END
			IF @@TRANCOUNT > 0
				
			BEGIN
				COMMIT TRANSACTION
				
			END
			
			SET @P_RET_PROCESO = 1
			SET @P_MSG_PROCESO = CONCAT(''Creacion de Cabeceras Funcionó correctamente, se crearon '',@count,'' cabeceras'')
			EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
			
			END TRY
			
			BEGIN CATCH
				
				ROLLBACK TRANSACTION
				SET @P_RET_PROCESO = ERROR_NUMBER()
				SET @P_MSG_PROCESO = ERROR_MESSAGE()
				EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;
			
			END CATCH
			
			
		CLOSE cursor_convenios
		DEALLOCATE cursor_convenios
		
		
	  
	    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_REC_CAJAS_ALTA_CAB'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	
	
	END
	
	')
	
	execute ('
	
CREATE PROCEDURE SP_CB_TELECOM
	-- Parametro de Entrada
    @CB_INI varchar(max),
	-- Parametro salida
    @P_RETORNO varchar(max)  OUTPUT

AS 

	BEGIN

      DECLARE

    	@AUX1 INT,
		@I INT,
		@RESTO INT,
		@DV INT,
		@FACTOR varchar(max),
		@DV_TXT varchar(1),
		@CB_FIN varchar(max),
		@NUM_1 INT,
		@NUM_2 INT,
		@MULT INT,	
		--Variables para manejar largo variable del CB
		@IND_FAC INT,
		@NRO_FAC INT,
		@LARGO_CB INT
         
        --Cargo el Factor para todas las posiciones 		
		-- VALORES FACTOR ''31''
		SET @LARGO_CB = LEN(@CB_INI)		 
		SET @IND_FAC = 1
		SET @NRO_FAC = 3
		SET @I = 1;
		SET @AUX1 = 0;
		WHILE (@I <= @LARGO_CB)
		BEGIN
			-- Cargo el primer nro del CB y el primer nro del Factor
			SET @NUM_1 = CAST(SUBSTRING(@CB_INI,@I,1) AS INT);
		 	SET @NUM_2 = @NRO_FAC;
			-- Pondero
		 	SET @MULT = (@NUM_1 * @NUM_2);
		 	SET @AUX1 = (@AUX1 + @MULT);
			SET @I += 1;

			--Obtengo proximo indice del Factor 
			IF @IND_FAC = 2
				SET @IND_FAC = 1
			ELSE
				SET @IND_FAC += 1
			-- CARGO PROXIMO CHAR DEL FACTOR
			SET @NRO_FAC = 
				(
					CASE
						WHEN @IND_FAC = 1 THEN 3
						WHEN @IND_FAC = 2 THEN 1
					END
				)

		END		 
		-- Obtengo el resto	
		SET @RESTO = @AUX1%10;
		-- Calculo el Dígito Verificador
		IF @RESTO = 0
			SET @DV = 0
		ELSE
			SET @DV = 10 - @RESTO

		-- Agrego al final del Codigo de Barras		
		SET @DV_TXT = CAST(@DV AS varchar);
		SET @CB_FIN = CONCAT(@CB_INI, @DV_TXT);
		
		-- DEVUELVO CODIGO BARRAS CON DV CALCULADO.
		SET @P_RETORNO = @CB_FIN;	 
		 
	END
	')
	execute ('

CREATE PROCEDURE PA_CONV_RENOV_BAJA
	@P_ID_PROCESO float(53),
	@P_DT_PROCESO  datetime2(0),
	@P_CLAVE       varchar(max),
	@P_SUCURSAL    float(53),
	@P_RET_PROCESO float(53)  OUTPUT,
	@P_MSG_PROCESO varchar(max)  OUTPUT
AS
BEGIN
	
	DECLARE 
		@IDCONVENIO NUMERIC(15),
		@RENAUTO VARCHAR(1),
		@ESTADO VARCHAR(1),
		@FECHAVEN DATETIME,
		@FECHAULTACT DATETIME,
		@FECHACAMEST DATETIME,
		@PLAZO NUMERIC(4),
		@FECHAPROCESO DATETIME,
		@NUEVAFECHAVEN DATETIME,
		@VCORRELATIVO NUMERIC(10),
		@v_constante VARCHAR(1),
		@CANTRENOV NUMERIC(10),
		@CANTBAJA NUMERIC(10)
		
		SET @FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))
		SET @CANTRENOV = 0
		SET @CANTBAJA = 0
		
		
	DECLARE CURSOR_REGS CURSOR
		FOR 
			SELECT C.Id_ConvRec, C.FecVto,C.Estado, C.FecUltAct, C.FecCamEst, C.RenAuto, C.Plazo 
			FROM CONV_CONVENIOS_REC C WITH (NOLOCK)
			WHERE C.Estado = ''A''
		OPEN CURSOR_REGS 
		FETCH NEXT FROM CURSOR_REGS INTO @IDCONVENIO, @FECHAVEN, @ESTADO, @FECHAULTACT, @FECHACAMEST, @RENAUTO, @PLAZO
		
		BEGIN TRANSACTION
		BEGIN TRY
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			-- 
			IF (@FECHAPROCESO = @FECHAVEN)
			BEGIN
				IF(@RENAUTO = ''S'')
				BEGIN
					SET @VCORRELATIVO= (SELECT ISNULL(MAX(Bit_Corr),0) +1 
										FROM CONV_BITACORA WITH (NOLOCK)
										WHERE Id_Convenio=@IDCONVENIO 
												AND TpoConv=''R''
										)
					SET @NUEVAFECHAVEN = DATEADD(MONTH,@PLAZO,@FECHAVEN)
					
				    UPDATE CONV_CONVENIOS_REC SET FecVto = @NUEVAFECHAVEN, FecUltAct = @FECHAPROCESO WHERE Id_ConvRec = @IDCONVENIO
				
					INSERT INTO CONV_BITACORA (Id_Convenio, TpoConv, Bit_Corr, Bit_Estado, Bit_Fecha, Bit_Hora, Bit_Asiento, Bit_Sucursal, Bit_Usuario, Bit_Com, TZ_LOCK)
					VALUES (@IDCONVENIO, ''R'', @VCORRELATIVO, ''A'', CONVERT(DATETIME,@FECHAPROCESO), NULL, 0, @P_SUCURSAL, @P_CLAVE, concat(''Se renueva automáticamente el convenio: '',@IDCONVENIO,'' con fecha:'',@NUEVAFECHAVEN),0)
					SET @CANTRENOV = @CANTRENOV + 1
				END
				ELSE
				BEGIN
					SET @VCORRELATIVO= (SELECT ISNULL(MAX(Bit_Corr),0) +1 
										FROM CONV_BITACORA WITH (NOLOCK) 
										WHERE Id_Convenio=@IDCONVENIO 
												AND TpoConv=''R''
										)

					UPDATE CONV_CONVENIOS_REC 
					SET Estado = ''B'', FecUltAct = @FECHAPROCESO, FecCamEst = @FECHAPROCESO 
					WHERE Id_ConvRec = @IDCONVENIO
					
					INSERT INTO CONV_BITACORA (Id_Convenio, TpoConv, Bit_Corr, Bit_Estado, Bit_Fecha, Bit_Hora, Bit_Asiento, Bit_Sucursal, Bit_Usuario, Bit_Com, TZ_LOCK)
					VALUES (@IDCONVENIO, ''R'', @VCORRELATIVO, ''B'', CONVERT(DATETIME,@FECHAPROCESO), NULL, 0, @P_SUCURSAL, @P_CLAVE, CONCAT(''Se da de baja el convenio; '',@IDCONVENIO,'' por fecha de Vencimiento''),0)
					SET @CANTBAJA = @CANTBAJA + 1
				END -- else renov auto 
			END -- fechaproceso = fechavencimiento
		   
		   FETCH NEXT FROM CURSOR_REGS INTO @IDCONVENIO, @FECHAVEN, @ESTADO, @FECHAULTACT, @FECHACAMEST, @RENAUTO, @PLAZO

		END -- while
		
		
		
		SET @P_RET_PROCESO = 1
		SET @P_MSG_PROCESO = ''Renovación automática / baja Funcionó correctamente. Se renovaron '' + ISNULL(CAST(@CANTRENOV AS NVARCHAR(max)), '''') + '' Convenios y se dieron de Baja ''+ ISNULL(CAST(@CANTBAJA AS nvarchar(max)), '''') + '' Convenios.''
		  
		EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
		  
		EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_RENOV_AUTO_BAJA'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
  
		
		COMMIT TRANSACTION;
		
		END TRY
		BEGIN CATCH
        BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @P_RET_PROCESO = ERROR_NUMBER()

            SET @P_MSG_PROCESO = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @P_ID_PROCESO, 
               @p_fch_proceso = @P_DT_PROCESO, 
               @p_nom_package = ''PA_CONV_RENOV_AUTO_BAJA'', 
               @p_cod_error = @P_RET_PROCESO, 
               @p_msg_error = @P_MSG_PROCESO, 
               @p_tipo_error = @v_constante

        END

      END CATCH
      
      CLOSE CURSOR_REGS
      DEALLOCATE CURSOR_REGS
		
END;

')

execute ('

CREATE PROCEDURE SP_CB_MOD11
   @CB_INI varchar(max),
   
   @P_RETORNO varchar(max)  OUTPUT
   --@P_RETORNO INT  OUTPUT
AS 

   BEGIN

      DECLARE

         @AUX1 INT,
		 @I INT,
		 @RESTO INT,
		 @DV INT,
		 @FACTOR varchar(max),
		 @DV_TXT varchar(1),
		 @CB_FIN varchar(max),
		 @NUM_1 INT,
		 @NUM_2 INT,
		 @MULT INT,	
		 --Variables para manejar largo variable del CB
		 @J INT,
		 @IND_FAC INT,
		 @CHAR_FAC varchar(1),
		 @LARGO_CB INT

         
         --Cargo el Factor para todas las posiciones (45)
		 --SET @FACTOR = ''791357913579135791357913579135791357913579135'';
		-- VALORES FACTOR ''79135''
		SET @LARGO_CB = LEN(@CB_INI)
		SET @J = 1
		SET @IND_FAC = 1
		SET @CHAR_FAC = ''7''
		SET @FACTOR = ''''

		WHILE (@J <= @LARGO_CB)
		BEGIN
			SET @FACTOR = CONCAT(@FACTOR, @CHAR_FAC);
			SET @J += 1;
			IF @IND_FAC = 5
				SET @IND_FAC = 1
			ELSE
				SET @IND_FAC += 1
			-- CARGO PROXIMO CHAR DEL FACTOR
			SET @CHAR_FAC =
				(
					CASE
						WHEN @IND_FAC = 1 THEN ''7''
						WHEN @IND_FAC = 2 THEN ''9''
						WHEN @IND_FAC = 3 THEN ''1''
						WHEN @IND_FAC = 4 THEN ''3''
						WHEN @IND_FAC = 5 THEN ''5''
					END
				)

		END
		 -------------------------------------
		 SET @I = 1;
		 SET @AUX1 = 0;
		 WHILE (@I <= @LARGO_CB)
		 BEGIN 	 	
		 	SET @NUM_1 = CAST(SUBSTRING(@CB_INI,@I,1) AS INT);
		 	SET @NUM_2 = CAST(SUBSTRING(@FACTOR,@I,1) AS INT);
		 	SET @MULT = (@NUM_1 * @NUM_2);
		 	SET @AUX1 = (@AUX1 + @MULT);
			SET @I += 1;
		 END
			
		SET @RESTO = @AUX1%11;
		
		IF @RESTO = 0
			SET @DV = 1
		ELSE
			BEGIN
				IF @RESTO = 1
					SET @DV = 0
				ELSE
					SET @DV = 11 - @RESTO
		END ;		
				
		SET @DV_TXT = CAST(@DV AS varchar);
		SET @CB_FIN = CONCAT(@CB_INI, @DV_TXT);
		
		-- DEVUELVO CODIGO BARRAS CON DV CALCULADO.
		--SET @P_RETORNO = @AUX1;
		SET @P_RETORNO = @CB_FIN;	 
		 
	END
')	