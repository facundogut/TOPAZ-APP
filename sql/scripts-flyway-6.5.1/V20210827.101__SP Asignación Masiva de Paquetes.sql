EXECUTE('
ALTER PROCEDURE [dbo].[SP_CLI_ASIGNACION_MASIVA_PAQUETES]
@p_id_proceso FLOAT(53),     /* Identificador de proceso*/
@p_dt_proceso DATETIME,   /* Fecha de proceso*/
@p_Paquete_anterior FLOAT(53),
@p_Paquete_nuevo FLOAT(53),
@p_Concat_clientes VARCHAR(MAX),
@p_ret_proceso FLOAT OUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error)*/
@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	
	DECLARE
    ------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30)
	-----------------------------------
	
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E''
	SET @c_log_tipo_informacion = ''I''
	-----------------------------------
	
  
   -- Tablas auxiliares --
   
   		-- Cargo tabla temporal para cargarlo como string
	
 				CREATE TABLE #TABLETMPIDSCLIENTES (
				
				Item INT null
				
				)
				
				DECLARE @ListaTemp NVARCHAR(4000)
					SET @ListaTemp = @p_concat_clientes
				DECLARE @indx INT
				DECLARE @Item NVARCHAR(4000)		
					SET @ListaTemp = REPLACE (@ListaTemp, '' '', '''')
					SET @indx = CHARINDEX('','', @ListaTemp)
				WHILE (LEN(@ListaTemp) > 0)
			   		BEGIN
							IF @indx = 0
							SET @Item = @ListaTemp
							ELSE
							SET @Item = LEFT(@ListaTemp, @indx - 1)
							SET @Item = CAST(@Item as INT)
							INSERT INTO #TABLETMPIDSCLIENTES(Item) VALUES(@Item)
							IF @indx = 0
							SET @ListaTemp =''''
							ELSE
							SET @ListaTemp = RIGHT(@ListaTemp, LEN(@ListaTemp) - @indx)
							SET @indx = CHARINDEX('','', @ListaTemp)
			   		END
   			
   		-- Tabla auxiliar Cliente - Paquetes
   	
		   		DECLARE @TMPClientePaquete TABLE(
				    PAQUETE float (53),
					CLIENTE FLOAT (53)
					)
			
        
	BEGIN TRY
	
	 	   /*	1- Consultamos paquetes para los clientes.
 	   		2- Para los encontrados actualizamos CLI_CLIENTES_PAQUETES (relación Cliente-Paq), Clientes y los saldos.
 	   	   */
	
				INSERT INTO @TMPClientePaquete
				   	    SELECT C.COD_PAQUETE AS PAQUETE, C.COD_CLIENTE AS CLIENTE
			            FROM dbo.CLI_CLIENTES_PAQUETES  AS C with (nolock)
			            WHERE 
			               C.ACTIVO = 1 AND 
			               C.TZ_LOCK = 0 AND 
			               C.COD_PAQUETE  = @p_Paquete_anterior 
						   AND C.COD_CLIENTE IN (SELECT Item FROM #TABLETMPIDSCLIENTES with (nolock))
	
				DECLARE	 @ENCONTRO_ float(53)
				SET @ENCONTRO_ = 0
				DECLARE @contador NUMERIC(10)
				SET @contador= ISNULL((SELECT COUNT(*) FROM @TMPClientePaquete),0)
   
   		  				BEGIN
			
						  	     	UPDATE cp
									SET cp.COD_PAQUETE = @p_paquete_nuevo
									FROM CLI_CLIENTES_PAQUETES cp with (nolock)
									INNER JOIN @TMPClientePaquete tcp ON tcp.CLIENTE=cp.COD_CLIENTE
									WHERE cp.COD_PAQUETE =@p_paquete_anterior AND cp.ACTIVO=1
										  
									
						  			UPDATE c
									SET c.CODIGOPAQUETE = convert(VARCHAR(5), @p_paquete_nuevo)
									FROM CLI_CLIENTES c with (nolock)
									INNER JOIN @TMPClientePaquete tcp ON tcp.CLIENTE=c.CODIGOCLIENTE 
																		
									  	SELECT @ENCONTRO_ = count_big(*)
						            	FROM dbo.SALDOS s with (nolock)
						            	INNER JOIN @TMPClientePaquete tcp ON tcp.CLIENTE=s.C1803 AND tcp.PAQUETE = s.C1770 
						           	    WHERE s.TZ_LOCK = 0
									
								    IF @ENCONTRO_ > 0
					              				
					                    UPDATE dbo.SALDOS
					                    SET C1770 = @p_Paquete_nuevo
					                    FROM dbo.SALDOS s with (nolock)
					                    INNER JOIN @TMPClientePaquete tcp ON tcp.CLIENTE=s.C1803 AND tcp.PAQUETE = s.C1770 
					                    WHERE s.TZ_LOCK = 0
					                       
					                   DROP TABLE #TABLETMPIDSCLIENTES;    
					     END
								  				   
         	
         	
         	SET @p_msg_proceso = ''El proceso de asignación masiva de paquetes clientes ha culminado correctamente. Clientes Actualizados: ''+convert(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 
			
			-- Logueo de información
			 EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
			 							 @p_id_proceso,
                                         @p_dt_proceso,
                                         ''SP_CLI_ASIGNACION_MASIVA_PAQUETES'',
                                         @p_cod_error = @p_ret_proceso, 
							             @p_msg_error = @p_msg_proceso, 
							             @p_tipo_error = @c_log_tipo_informacion
	   	  
	END TRY	
	
	BEGIN CATCH
	
        SET @p_ret_proceso = ERROR_NUMBER()
        SET @p_msg_proceso = ''Error al actualizar registros '' + ERROR_MESSAGE()
        
		 EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''SP_CLI_ASIGNACION_MASIVA_PAQUETES'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @c_log_tipo_informacion
               
   END CATCH
	
END
')

