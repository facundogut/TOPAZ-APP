EXECUTE('
ALTER PROCEDURE dbo.SP_CLE_DESCUENTOS_ECHEQ
    @COD_NEGOCIACION VARCHAR(15),
    @COD_LISTA NUMERIC(15),
    @NRO_DOC VARCHAR(20),
    @REFERENCIA NUMERIC(15)
AS
BEGIN
		--DELETE FROM IO_CAPTURA_CHEQUES WHERE REFERENCIA=@COD_LISTA;
		
        -- Insertar los datos en IO_CAPTURA_CHEQUES
        INSERT INTO IO_CAPTURA_CHEQUES (
            TZ_LOCK,
            BANCO_EMISOR,
            SUC_BANCO_EMISOR,
            COD_POSTAL,
            NUM_CHEQUE,
            NUM_CUENTA,          
            SERIE_CHEQUE,
            -- FECHA_CHEQUE,
            IMPORTE,
            REFERENCIA,
            -- TIPO_DOCUMENTO,
            -- PLAZA_COMPENSACION,
            -- CERTIF_AUTENTICIDAD,
            -- DIG_INTERCAMBIO,
            -- DIG_PREMARCADO,
            -- NRO_MAQUINA,
            FECHA,
            BANDAMAGNETICA
            -- IMAGENANVERSO,
            -- IMAGENREVERSO,
            -- STATUS,
            -- REF_CLIENTE,
            -- CANT_ING_CHEQUE,
            -- FECHA_APLIC_CHEQUE,
            -- FORMA_INGRESO,
            -- ORDINAL,
            -- MONEDA,
            -- ORDENANTE,

            -- NOMBRE_LIBRADOR,
            -- CODIGO_OBSERVACION,
            -- OBSERVACIONES,
            
        )
        SELECT 
        0 AS TZ_LOCK ,
		CODIGO_BANCO, 
		SUCURSAL, 
		CODIGO_POSTAL, 
		NUMERO_CHEQUE, 
		NUMERO_CUENTA,
		''E'', 
		-- CODIGO_VERIFICADOR_1, 
		-- CODIGO_VERIFICADOR_2, 
		-- CODIGO_VERIFICADOR_3, 
		IMPORTE, 
		@REFERENCIA,
		FECHA_VTO, 
		CMC7
		FROM dbo.CLE_DESCUENTOS_ECHEQ WITH (NOLOCK)
        WHERE COD_NEGOCIACION = @COD_NEGOCIACION 
          AND CUIT_NEGOCIADOR = @NRO_DOC
          AND ESTADO=''A'' AND NUM_LISTA <> @COD_LISTA
          
       -- Actualizar el campo NUM_LISTA en CLE_DESCUENTOS_ECHEQ
        UPDATE dbo.CLE_DESCUENTOS_ECHEQ
        SET NUM_LISTA = @COD_LISTA
        WHERE COD_NEGOCIACION = @COD_NEGOCIACION 
          AND CUIT_NEGOCIADOR = @NRO_DOC
          AND ESTADO = ''A'';
END
')