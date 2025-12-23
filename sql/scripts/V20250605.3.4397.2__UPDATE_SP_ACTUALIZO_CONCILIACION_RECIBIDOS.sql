
EXEC('
CREATE OR ALTER PROCEDURE dbo.SP_ACTUALIZO_CONCILIACION_RECIBIDOS
    @ELEMENT0 NVARCHAR(4), --C79550
    @ELEMENT3 VARCHAR(6), --79551
    @TOPAZPOSTINGNUMBER NUMERIC(15), --9501
    @TOPAZBRANCH NUMERIC(5) ,
     --@ELEMENT11 VARCHAR(6) = TRACE NUMBER 000000, 
    @ELEMENT12 NVARCHAR(6),  -- Hora transacción - c79554
    @ELEMENT13 NVARCHAR(4),  -- Fecha transacción - c79553
    @ELEMENT37 NVARCHAR(99), -- Número transacción - c79557
    @ELEMENT41 NVARCHAR(16), -- Identificación cajero - c79559
    @ELEMENT4 NVARCHAR(12),  -- Importe - c57
    @ELEMENT102 NVARCHAR(99),-- From account - c79562
    @ELEMENT49 NVARCHAR(50), -- Moneda - 109
    @ELEMENT103 NVARCHAR(21), -- Cuenta destino (TOACCOUNT) - C79563
    @ELEMENT39 NUMERIC(2),  -- Este elemento se usa para condicionar 
    ---- PARA EL UPDATE ----
    @FECHACAPTURA NVARCHAR(4),  -- Fecha captura - c79552
    @ELEMENT35 VARCHAR (50),
    ---- NUEVOS CAMPOS ----
    @ELEMENT43 VARCHAR (40),
    @ELEMENT62 VARCHAR (2),
    @ELEMENT120 VARCHAR (25)
AS
BEGIN
	DECLARE @EXISTEASIENTO NUMERIC (2);
	SET @EXISTEASIENTO=0;
    BEGIN TRY
        BEGIN TRANSACTION;
        SET @EXISTEASIENTO = (SELECT COUNT(*) FROM ASIENTOS WITH (NOLOCK) WHERE ASIENTO=@TOPAZPOSTINGNUMBER 
        					 AND SUCURSAL=@TOPAZBRANCH 
        				     AND FECHAPROCESO= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))
        IF ((@ELEMENT39) > 0 OR (@ELEMENT39 = 0 AND @EXISTEASIENTO =0))
        BEGIN
        SET @ELEMENT4 =RIGHT(REPLICATE(''0'', 12) + @ELEMENT4, 12);
            -- DELETE en TP_TOPAZPOSCONTROL
            DELETE FROM TP_TOPAZPOSCONTROL
            WHERE ELEMENT0 = ''0220''
            AND ELEMENT12 = @ELEMENT12
            AND ELEMENT13 = @ELEMENT13
            AND ELEMENT37 = @ELEMENT37
            AND ELEMENT41 = @ELEMENT41
            AND ELEMENT4 = @ELEMENT4;

            -- Actualización del campo CONCILIACION en TJD_TLF_SUMMARY
            UPDATE TJD_TLF_SUMMARY
            SET CONCILIACION = ''N''
            WHERE TIPOMENSAJE = ''200'' 
            AND FECHACAPTURA = @FECHACAPTURA
            AND FECHATRANSACCION = @ELEMENT13
            AND HORATRANSACCION = @ELEMENT12
            AND NUMEROTRANSACCION = @ELEMENT37
            AND IDENTIFICACIONCAJERO = @ELEMENT41;
        END
        ELSE
        BEGIN
        
        -- Corto la cta_Redlink para que grabe en la tp sin el tipo
        SET @ELEMENT102 = SUBSTRING(@ELEMENT102, 3, LEN(@ELEMENT102));
        SET @ELEMENT103 = SUBSTRING(@ELEMENT103, 3, LEN(@ELEMENT103));
        --Seteo valor con la fecha y hora actual
        DECLARE @FECHAMENSAJE DATETIME;
        SET @FECHAMENSAJE = GETDATE();

        DECLARE @JTS_OID_TP NUMERIC(20,0);
        
        SET @ELEMENT4 =RIGHT(REPLICATE(''0'', 12) + @ELEMENT4, 12);
        ---ARMO MES+DIA+HORA+MINUTO+SEGUNDOS
			DECLARE @ELEMENT7 NVARCHAR(10);
        	SET @ELEMENT7 = (SELECT RIGHT(''0'' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) + 
                                RIGHT(''0'' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) + 
                                RIGHT(''0'' + CAST(DATEPART(HOUR, GETDATE()) % 12 AS VARCHAR(2)), 2) + 
                                RIGHT(''0'' + CAST(DATEPART(MINUTE, GETDATE()) AS VARCHAR(2)), 2) + 
                                RIGHT(''0'' + CAST(DATEPART(SECOND, GETDATE()) AS VARCHAR(2)), 2));
           
            -- Insert de nuevo registro en TP_TOPAZPOSCONTROL
            INSERT INTO TP_TOPAZPOSCONTROL (ELEMENT0,TOPAZBRANCH, TOPAZPROCESSDATE, ELEMENT3, TOPAZPOSTINGNUMBER, NRECEIVED, NSEND, TIMEOUT, ELEMENT7, ELEMENT11, ELEMENT12, ELEMENT13,ELEMENT17,ELEMENT37, ELEMENT41,ELEMENT43,ELEMENT62,ELEMENT102, ELEMENT49, ELEMENT4, ELEMENT103, ELEMENT39,FECHAMENSAJE,ELEMENT35,ELEMENT120)
            VALUES (''0230'',@TOPAZBRANCH,(SELECT fechaproceso FROM PARAMETROS), @ELEMENT3,@TOPAZPOSTINGNUMBER, 1, 0, 0, @ELEMENT7, ''000000'', @ELEMENT12, @ELEMENT13,@FECHACAPTURA,@ELEMENT37, @ELEMENT41,@ELEMENT43,@ELEMENT62, @ELEMENT102, 
                CASE 
                    WHEN @ELEMENT49 = ''1'' THEN ''032''  
                    WHEN @ELEMENT49 = ''2'' THEN ''840'' 
                    ELSE NULL
                END,
                @ELEMENT4, @ELEMENT103, ''00'',@FECHAMENSAJE,@ELEMENT35,@ELEMENT120);

            SET @JTS_OID_TP = (
                SELECT TOP 1
                    JTS_OID 
                FROM TP_TOPAZPOSCONTROL
                WHERE 
                    ELEMENT13=@ELEMENT13
				AND ELEMENT12=@ELEMENT12
				AND ELEMENT37=@ELEMENT37
				AND ELEMENT41=@ELEMENT41
				AND ELEMENT3=@ELEMENT3
				AND ELEMENT102=RIGHT(@ELEMENT102, 19)
				AND ELEMENT103=RIGHT(@ELEMENT103, 19)
				AND ELEMENT0 = ''0230''
				AND TOPAZPOSTINGNUMBER=@TOPAZPOSTINGNUMBER
                ORDER BY JTS_OID DESC
            )
            

            ------------------------------------------------------------------------
            -- TABLAS TLF_CONCILIACION
            ------------------------------------------------------------------------

            DECLARE
                @ID_CABECERA BIGINT = 0,
                @ID_DETALLE BIGINT = 0;

            SET @ID_CABECERA = (
                SELECT ID_CABECERA
                FROM TLF_CONCILIACION_CABECERA WITH (NOLOCK)
                WHERE LKTRAD = @ELEMENT13
                AND LKTRAT = @ELEMENT12
                AND LKSEQN = @ELEMENT37
                AND LKTERM = @ELEMENT41
                AND LKFROM = RIGHT(@ELEMENT102, 19)
                AND LKTOAC = RIGHT(@ELEMENT103, 19)
                AND COD_MSJ_H2H = @ELEMENT3
            );

            INSERT INTO dbo.ITF_LOG (FECHA, INTERFASE, MENSAJE, TIPOMENSAJE)
            VALUES (
                (SELECT fechaproceso FROM PARAMETROS),
                ''SP_ACT_CONC_REC'',
                CONCAT(''ID_CABECERA: '', @ID_CABECERA, '' - JTS_OID_TP: '',@JTS_OID_TP),
                ''''
            );

            IF (@ID_CABECERA IS NOT NULL AND @ID_CABECERA <> 0) AND (@JTS_OID_TP IS NOT NULL AND @JTS_OID_TP <> 0)  
            BEGIN
                -- ACTUALIZAR CANTIDAD CABECERA
                UPDATE TLF_CONCILIACION_CABECERA
                SET IMPACTOS_ONLINE = IMPACTOS_ONLINE+1
                FROM TLF_CONCILIACION_CABECERA
                WHERE ID_CABECERA = @ID_CABECERA

                -- OBTENER MAX_ID_DETALLE
                SET @ID_DETALLE = COALESCE(
                    (SELECT MAX(ID_DETALLE) 
                    FROM TLF_CONCILIACION_DETALLE WITH (NOLOCK)
                    WHERE ID_CABECERA = @ID_CABECERA), 
                    0)+1;

                -- ACTUALIZAR DETALLE
                INSERT INTO dbo.TLF_CONCILIACION_DETALLE (
                    ID_CABECERA, ID_DETALLE, 
                    LKTRAD, LKTRAT, LKSEQN, LKTERM, COD_MSJ_H2H, LKFROM, LKTOAC, LKORIG, LKAMT1, 
                    IMPORTE, LKTYP, ASIENTO_SUCURSAL, ASIENTO_FECHA, ASIENTO_NUMERO, JTS_OID_TP
                )
                SELECT
                    @ID_CABECERA, @ID_DETALLE,
                    ELEMENT13, ELEMENT12, ELEMENT37, ELEMENT41, ELEMENT3, ELEMENT102, ELEMENT103, ELEMENT49, ELEMENT4,
                    NULL, ELEMENT0, TOPAZBRANCH, TOPAZPROCESSDATE, TOPAZPOSTINGNUMBER, @JTS_OID_TP
                FROM TP_TOPAZPOSCONTROL
                WHERE JTS_OID = @JTS_OID_TP; 
            END;

            ---------------------------------------------------------------------------
            -----		Actualizar estado de cabecera
            ---------------------------------------------------------------------------
            UPDATE dbo.TLF_CONCILIACION_CABECERA
            SET ESTADO_CONCILIACION = 
                CASE 
                    WHEN ESTADO_TLF = ''REVERSADA'' AND IMPACTOS_ONLINE = REVERSAS_ONLINE THEN ''CONCILIADO''
                    WHEN ESTADO_TLF = ''APROBADA'' AND IMPACTOS_ONLINE = REVERSAS_ONLINE + 1 THEN ''CONCILIADO''
                    WHEN ESTADO_TLF = ''RECHAZADA'' AND IMPACTOS_ONLINE = REVERSAS_ONLINE THEN ''CONCILIADO''
                    ELSE ''NO_OK''
                END,
                DESCRIPCION_CONCILIACION = ''''
            WHERE ID_CABECERA = @ID_CABECERA;

            
            ---------------------------------------------------------------------------
            -----		Actualización del campo CONCILIACION en TJD_TLF_SUMMARY
            ---------------------------------------------------------------------------
            UPDATE dbo.TJD_TLF_SUMMARY
            SET CONCILIACION = ''S''
            FROM TJD_TLF_SUMMARY s 
            WHERE
                    s.FECHATRANSACCION = @ELEMENT13
                AND s.HORATRANSACCION = @ELEMENT12
                AND s.NUMEROTRANSACCION = @ELEMENT37
                AND s.IDENTIFICACIONCAJERO = @ELEMENT41
                AND RIGHT(s.FROMACCOUNT, 19) = @ELEMENT102
                AND RIGHT(s.TOACCOUNT, 19) = @ELEMENT103
                AND s.CODIGOPROCESAMIENTO = @ELEMENT3
                ;

        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        --errores
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
');