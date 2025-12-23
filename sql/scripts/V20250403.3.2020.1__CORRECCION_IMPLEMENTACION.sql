EXECUTE('

CREATE OR ALTER PROCEDURE [dbo].[SP_ITF_LK_EC_EMISION_ALTA]
    @P_CUIT					NUMERIC(20),
    @P_CBU 					VARCHAR(22),
    @P_CANTIDAD				NUMERIC(10),
    @P_TIPO					VARCHAR(50),
    @O_CODIGO				NUMERIC(5) OUTPUT,
    @O_MENSAJE				VARCHAR(250) OUTPUT,
    @O_SUCURSAL 			NUMERIC(5,0) OUTPUT,
    @O_CUENTA 				NUMERIC(12,0) OUTPUT,
    @O_MONDEA 				NUMERIC(4,0) OUTPUT,
    @O_OPERACION 			NUMERIC(6,0) OUTPUT,
    @O_ORDINAL 				NUMERIC(3,0) OUTPUT,
    @O_PRODUCTO 			NUMERIC(5,0) OUTPUT,
    @O_SERIE 				VARCHAR(3) OUTPUT,
    @O_NROCHEQUERA 			NUMERIC(4,0) OUTPUT,
    @O_CHEQUES_DISPONIBLES 	NUMERIC(5,0) OUTPUT
AS
BEGIN
    DECLARE @V_EXISTE_CUIT	NUMERIC(5) = 0;
    DECLARE @V_EXISTE_CBU	NUMERIC(5) = 0;
    DECLARE @V_CUENTA_HABILITADA 	NUMERIC(5) = 0;
    DECLARE @V_CUIT_CORRESPONDE_CBU NUMERIC(5) = 0;
    DECLARE @V_CHEQUES_DISPONIBLES	NUMERIC(10) = 0;
    DECLARE @V_TOTAL_CHEQUES_DISPONIBLES	NUMERIC(10) = 0;
    DECLARE @V_CANTIDAD_RESTANTE 	NUMERIC(10) = @P_CANTIDAD;
    DECLARE @V_CANTIDAD_RESTANTE_CURSOR 	NUMERIC(10);
    DECLARE @V_SUCURSAL 			NUMERIC(5,0);
    DECLARE @V_CUENTA 				NUMERIC(12,0);
    DECLARE @V_MONDEA				NUMERIC(4,0);
    DECLARE @V_OPERACION 			NUMERIC(6,0);
    DECLARE @V_ORDINAL				NUMERIC(3,0);
    DECLARE @V_PRODUCTO				NUMERIC(5,0);
    DECLARE @V_SERIE				VARCHAR(3);
    DECLARE @V_CHEQUE_DESDE			NUMERIC(12,0);
    DECLARE @V_CHEQUE_HASTA			NUMERIC(12,0);
    DECLARE @V_NUM_NUEVO_CHEQUE		NUMERIC(12,0);
    DECLARE @V_FECHA_PROCESO		DATETIME;
    DECLARE @V_NRO_CHEQUERA			NUMERIC(4,0);
    DECLARE @rango_min INT;
    DECLARE @rango_max INT;
    SET NOCOUNT ON;
    BEGIN
        SELECT @V_EXISTE_CUIT = count(*)
        FROM CLI_DocumentosPFPJ
        WHERE NUMERODOCUMENTO = @P_CUIT;

        SELECT @V_EXISTE_CBU = count(*)
        FROM vta_saldos
        WHERE CTA_CBU = @P_CBU;

        --Verificar que el cbu se corresponda con el cuit del librador.
        --Si es >= 1, es válido.
        SELECT @V_CUIT_CORRESPONDE_CBU = count(*)
        FROM vta_saldos V WITH (NOLOCK)
            JOIN SALDOS S WITH (NOLOCK) ON V.JTS_OID_SALDO = S.JTS_OID
            JOIN CLI_ClientePersona CP WITH (NOLOCK) ON S.C1803 = CP.CODIGOCLIENTE
            JOIN CLI_DocumentosPFPJ CD WITH (NOLOCK) ON CP.NUMEROPERSONA = CD.NUMEROPERSONAFJ AND CD.NUMERODOCUMENTO = @P_CUIT
        WHERE V.CTA_CBU = @P_CBU;

    END
    IF @V_EXISTE_CUIT = 0
        BEGIN
        SET @O_CODIGO = 0
        SET @O_MENSAJE = ''El CUIT no existe.''
    END
    ELSE IF @V_EXISTE_CBU = 0
        BEGIN
        SET @O_CODIGO = 0
        SET @O_MENSAJE = ''El CBU no existe.''
    END
    ELSE IF @V_CUIT_CORRESPONDE_CBU = 0
	BEGIN
        SET @O_CODIGO = 0
        SET @O_MENSAJE = ''El CBU no está asociado al CUIT del librador''
    END
	ELSE
		BEGIN
        --Verificar que la cuenta corriente este habilitada para emisión.
        --Si devuelve 1, está habilitada, caso contrario no.
        SELECT @V_CUENTA_HABILITADA = count(1)
        FROM vta_saldos V WITH (NOLOCK)
            JOIN SALDOS S WITH (NOLOCK) ON V.JTS_OID_SALDO = S.JTS_OID AND S.PERMITE_ECHEQ = ''S''
        WHERE V.CTA_CBU = @P_CBU;

        IF @V_CUENTA_HABILITADA <> 1
		BEGIN
            SET @O_CODIGO = 0
            SET @O_MENSAJE = ''La cuenta no se encuentra habilitada para la emisión de cheques electrónicos.''
        END
			ELSE 
				BEGIN
            --Verificar la disponibilidad de Echeqs para emitir para eso debe tener una chequera virtual habilitada con la cantidad de cheques los cuales deben estar en estado PENDIENTE DE EMITIR.
            --Si devuelve null o nada, no tiene la cantidad de cheques disponibles.
            SELECT @V_TOTAL_CHEQUES_DISPONIBLES = sum(cantidad)
            FROM (
					SELECT C.CHEQUEDESDE, C.CHEQUEHASTA, (C.CANTIDADCHEQUES  - COUNT(CH.NUMEROCHEQUE)) AS cantidad
                FROM CHE_CHEQUERAS C
                    LEFT JOIN CHE_CHEQUES CH ON C.SUCURSAL = CH.SUCURSAL
                        AND C.CUENTA = CH.CUENTA
                        AND C.OPERACION = CH.OPERACION
                        AND C.ORDINAL = CH.ORDINAL
                        AND CH.NUMEROCHEQUE 
								BETWEEN C.CHEQUEDESDE AND C.CHEQUEHASTA
                    JOIN SALDOS S ON C.SUCURSAL = S.SUCURSAL
                        AND C.CUENTA = S.CUENTA
                        AND C.MONEDA = S.MONEDA
                        AND C.OPERACION = S.OPERACION
                        AND C.ORDINAL = S.ORDINAL
                        AND C.CLIENTE = S.C1803
                        AND S.PERMITE_ECHEQ = ''S''
                    JOIN VTA_SALDOS V ON V.JTS_OID_SALDO = S.JTS_OID AND V.CTA_CBU = @P_CBU
                WHERE C.SERIE = ''E''
                GROUP BY C.CHEQUEDESDE, C.CHEQUEHASTA,C.CANTIDADCHEQUES
                HAVING (CANTIDADCHEQUES - COUNT(CH.NUMEROCHEQUE)) >= 0
					) a
            IF @V_TOTAL_CHEQUES_DISPONIBLES IS NULL OR @V_TOTAL_CHEQUES_DISPONIBLES = 0
						BEGIN
                SET @O_CODIGO = 0
                SET @O_MENSAJE =  ''No posee cheques para emitir.''
            END
					ELSE
						BEGIN
                IF @V_TOTAL_CHEQUES_DISPONIBLES < @P_CANTIDAD
								BEGIN
                    SET @O_CODIGO = 0
                    SET @O_MENSAJE = ''La chequera no cuenta con la cantidad de cheques requeridos. | Restantes: '' + CAST(@V_TOTAL_CHEQUES_DISPONIBLES AS VARCHAR) + ''. | Solicitados: '' + CAST(@P_CANTIDAD AS VARCHAR) + ''.''
                END
							ELSE
								BEGIN
                    SELECT @V_FECHA_PROCESO = FECHAPROCESO
                    FROM PARAMETROS WITH (NOLOCK)

                    DECLARE c_chequeras CURSOR FOR
										SELECT C.CHEQUEDESDE
											, C.CHEQUEHASTA
											, C.SUCURSAL
											, C.CUENTA
											, C.MONEDA
											, C.OPERACION
											, C.ORDINAL
											, C.PRODUCTO
											, C.SERIE
											, C.NUMEROCHEQUERA
											, (CANTIDADCHEQUES - COUNT(CH.NUMEROCHEQUE)) AS CHEQUES_DISPONIBLES
                    FROM CHE_CHEQUERAS C WITH (NOLOCK)
                        LEFT JOIN CHE_CHEQUES CH WITH (NOLOCK) ON C.SUCURSAL = CH.SUCURSAL
                            AND C.CUENTA = CH.CUENTA
                            AND C.OPERACION = CH.OPERACION
                            AND C.ORDINAL = CH.ORDINAL
                            AND CH.NUMEROCHEQUE 
                                            BETWEEN C.CHEQUEDESDE AND C.CHEQUEHASTA
                        JOIN SALDOS S WITH (NOLOCK) ON C.SUCURSAL = S.SUCURSAL
                            AND C.CUENTA = S.CUENTA
                            AND C.MONEDA = S.MONEDA
                            AND C.OPERACION = S.OPERACION
                            AND C.ORDINAL = S.ORDINAL
                            AND C.CLIENTE = S.C1803
                            AND S.PERMITE_ECHEQ = ''S''
                        JOIN VTA_SALDOS V WITH (NOLOCK) ON V.JTS_OID_SALDO = S.JTS_OID AND V.CTA_CBU = @P_CBU
                    WHERE C.SERIE = ''E''
                    GROUP BY    C.CHEQUEDESDE ,  C.CHEQUEHASTA ,  C.SUCURSAL ,  C.CUENTA ,  C.MONEDA ,  C.OPERACION ,  C.ORDINAL ,  C.PRODUCTO ,  C.SERIE ,  C.NUMEROCHEQUERA,C.CANTIDADCHEQUES
                    HAVING (CANTIDADCHEQUES - COUNT(CH.NUMEROCHEQUE)) >= 0
                    ORDER BY C.CHEQUEDESDE
                    OPEN c_chequeras
                    FETCH NEXT FROM c_chequeras
									INTO @V_CHEQUE_DESDE, @V_CHEQUE_HASTA,@V_SUCURSAL,@V_CUENTA,@V_MONDEA,@V_OPERACION,@V_ORDINAL,@V_PRODUCTO,@V_SERIE,@V_NRO_CHEQUERA,@V_CHEQUES_DISPONIBLES
                    WHILE @@FETCH_STATUS = 0
									BEGIN
                        SET @V_CANTIDAD_RESTANTE_CURSOR = @V_CHEQUES_DISPONIBLES
                        WHILE @V_CANTIDAD_RESTANTE > 0 AND @V_CANTIDAD_RESTANTE_CURSOR > 0
											BEGIN
                            SET @rango_min = @V_CHEQUE_DESDE
                            SET @rango_max = @V_CHEQUE_HASTA

                            SELECT @V_NUM_NUEVO_CHEQUE = MIN(n.numero)
                            FROM CHE_CHEQUERAS C WITH (NOLOCK)
												CROSS JOIN 
												(
                                                    SELECT TOP (@rango_max - @rango_min + 1)
                                                    @rango_min + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS numero
                                                    FROM sys.all_objects
												) n
                                LEFT JOIN CHE_CHEQUES CH WITH (NOLOCK) ON C.SUCURSAL = CH.SUCURSAL
                                    AND C.CUENTA = CH.CUENTA
                                    AND C.OPERACION = CH.OPERACION
                                    AND C.ORDINAL = CH.ORDINAL
                                    AND n.numero = CH.NUMEROCHEQUE
                            WHERE n.numero BETWEEN @V_CHEQUE_DESDE AND @V_CHEQUE_HASTA
                                AND ch.NUMEROCHEQUE IS NULL AND c.SUCURSAL = @V_SUCURSAL AND C.CUENTA = @V_CUENTA AND C.MONEDA = @V_MONDEA AND C.OPERACION = @V_OPERACION AND c.ORDINAL = @V_ORDINAL AND C.PRODUCTO = @V_PRODUCTO AND C.SERIE = @V_SERIE AND C.CHEQUEDESDE = @V_CHEQUE_DESDE AND C.CHEQUEHASTA = @V_CHEQUE_HASTA

                            INSERT INTO dbo.CHE_CHEQUES
                                (TZ_LOCK, SUCURSAL, MONEDA, CUENTA, PRODUCTO, OPERACION, ORDINAL, NUMEROCHEQUE, IMPORTE, FECHAESTADO, ESTADO, JTS_ORIGEN, NUMEROCHEQREIMPRESO, MOTIVO, FECHAINGRESO, SERIE, JTS_ACTUAL, JTS_CHEQUE, MARCA_JTS, FECHA_VENCIMIENTO, ALAORDENDE, NRO_SOLICITUD, EST_MIGRACION, ORDEN, PORTADOR, TITULAR_FONDOS, TIPO_DOC_CERTIF, DOCUMENTO_CERTIF, NOMINA_CIERRE, CANAL_ORIGEN)
                            VALUES
                                (0, @V_SUCURSAL, @V_MONDEA, @V_CUENTA, @V_PRODUCTO, @V_OPERACION, @V_ORDINAL, @V_NUM_NUEVO_CHEQUE, 0, @V_FECHA_PROCESO, ''I'', 0, 0, '' '', NULL, @V_SERIE, 0, 0, 0, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL)

                            SET @V_CANTIDAD_RESTANTE = @V_CANTIDAD_RESTANTE - 1;
                            SET @V_CANTIDAD_RESTANTE_CURSOR = @V_CANTIDAD_RESTANTE_CURSOR - 1;
                        END
                        FETCH NEXT FROM c_chequeras
    									INTO @V_CHEQUE_DESDE, @V_CHEQUE_HASTA,@V_SUCURSAL,@V_CUENTA,@V_MONDEA,@V_OPERACION,@V_ORDINAL,@V_PRODUCTO,@V_SERIE,@V_NRO_CHEQUERA,@V_CHEQUES_DISPONIBLES
                    END
                    CLOSE c_chequeras;
                    DEALLOCATE c_chequeras;

                    SET @O_CODIGO = 1
                    SET @O_MENSAJE = ''OK.''
                    SET @O_SUCURSAL = @V_SUCURSAL
                    SET @O_CUENTA = @V_CUENTA
                    SET @O_MONDEA = @V_MONDEA
                    SET @O_OPERACION = @V_OPERACION
                    SET @O_ORDINAL = @V_ORDINAL
                    SET @O_PRODUCTO = @V_PRODUCTO
                    SET @O_SERIE = @V_SERIE
                    SET @O_NROCHEQUERA = @V_NRO_CHEQUERA
                    SET @O_CHEQUES_DISPONIBLES = @V_TOTAL_CHEQUES_DISPONIBLES - @P_CANTIDAD
                END
            END
        END
    END
    SET NOCOUNT OFF;
END

')