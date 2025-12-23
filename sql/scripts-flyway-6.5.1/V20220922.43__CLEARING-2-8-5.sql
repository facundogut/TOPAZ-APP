EXECUTE('

IF OBJECT_ID (''dbo.ITF_COELSA_CHEQUES_RECHAZO'') IS NOT NULL
	DROP TABLE dbo.ITF_COELSA_CHEQUES_RECHAZO
	

CREATE TABLE dbo.ITF_COELSA_CHEQUES_RECHAZO
	(
	ID                 INT IDENTITY NOT NULL,
	ID_TICKET          NUMERIC (16),
	ID_PROCESO         NUMERIC (15),
	FECHAPROCESO       DATE,
	CODIGO_TRANSACCION NUMERIC (2),
	ENTIDAD_DEBITAR    NUMERIC (8),
	CUENTA_DEBITAR     NUMERIC (17),
	IMPORTE            NUMERIC (15, 2),
	CODIGO_POSTAL      VARCHAR (6),
	FECHA_PRESENTADO   DATE,
	FECHA_VENCIMIENTO  DATE,
	NRO_CHEQUE         NUMERIC (15),
	PUNTO_INTERCAMBIO  VARCHAR (16),
	TRACE_NUMBER       NUMERIC (15),
	ESTADO             VARCHAR (1),
	TIPO               VARCHAR (1),
	COD_RECHAZO        NUMERIC (2),
	INFO_ADICIONAL     VARCHAR (2),
	CONSTRAINT PK__ITF_COELSA_CHEQUES_RECHAZO PRIMARY KEY (ID)
	)

')

EXECUTE('

IF OBJECT_ID (''dbo.SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS'') IS NOT NULL
	DROP PROCEDURE dbo.SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS
	

')
EXECUTE('
CREATE PROCEDURE [dbo].[SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS]
   @TICKET NUMERIC(16),
   @MONEDA NUMERIC(4)
AS 
BEGIN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 20/05/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de generar la información de los dpf propios rechazados a informar a COELSA.
--- Mediante el parametro MONEDA se filtra los dpf en pesos o dolares.
--- 0 pesos , 1 dolares
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------ Limpieza de tabla auxiliar --------------------
TRUNCATE TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX;
------------------------------------------------------------

-- Variables Cabecera Archivo --
DECLARE @IdRegistroCA NUMERIC(15) = 1;
DECLARE @CodigoPrioridadCA VARCHAR(2) = ''01'';
DECLARE @DestinoInmediatoCA VARCHAR(10) = '' 000000010'';
DECLARE @OrigenInmediatoCA VARCHAR(10) = '' 031100300'';
DECLARE @FechaPresentacion VARCHAR(6) = FORMAT((SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) , ''yyMMdd'');
DECLARE @HoraPresentacion VARCHAR(4) = FORMAT((SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), ''hhmm'');
DECLARE @IdArchivoCA NUMERIC(15) = 1;
DECLARE @TamanioRegistro VARCHAR(3) = ''094'';
DECLARE @FactorBloque VARCHAR(2) = ''10'';
DECLARE @CodigoFormato VARCHAR(1) = ''1'';
DECLARE @NombreDestinoInmediato VARCHAR(6) = ''COELSA'';
DECLARE @NombreOrigenInmediato VARCHAR(21) = ''NUEVO BCO CHACHO S.A.'';
DECLARE @CodigoReferencia VARCHAR(8) = ''CHQ.RECH'';
-- Fin Variables Cabecera Archivo --

-- Grabar cabecera de archivo --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (concat(@IdRegistroCA, @CodigoPrioridadCA, @DestinoInmediatoCA, @OrigenInmediatoCA, @FechaPresentacion, @HoraPresentacion, @IdArchivoCA, @TamanioRegistro, @FactorBloque, @CodigoFormato, @NombreDestinoInmediato, @NombreOrigenInmediato, @CodigoReferencia));
--------------------------------------------

-- Variables Cabecera de Lote --
DECLARE @IdRegistroCL NUMERIC(15) = 5;
DECLARE @CodigoTransaccionCL VARCHAR(3) = ''200'';
DECLARE @Reservado1CL VARCHAR(16) = replicate('' '', 16);
DECLARE @Reservado2CL VARCHAR(20) = replicate('' '', 20);
DECLARE @Reservado3CL VARCHAR(10) = replicate('' '', 10);
DECLARE @CodigoEstandarCL VARCHAR(3) = ''TRC'';
DECLARE @DescripcionTransaccionCL VARCHAR(10) = ''CHEQHESREC'';
DECLARE @FechaPresentacionCL VARCHAR(6) = FORMAT((SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) , ''yyMMdd'');
DECLARE @FechaVencimientoCL VARCHAR(6) = FORMAT((SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)) , ''yyMMdd''); 
DECLARE @Reservado4CL VARCHAR(3) = ''000'';
DECLARE @CodigoOrigenCL VARCHAR(1) = ''1'';
DECLARE @IdEntidadOrigenCL VARCHAR(8) = ''03110030'';
DECLARE @NumeroLoteCL VARCHAR(8) = RIGHT(concat(replicate(''0'', 8), @CodigoOrigenCL), 8);
-- Fin Variables Cabecera de Lote --

-- Grabar cabecera de lote --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (concat(@IdRegistroCL, @CodigoTransaccionCL, @Reservado1CL, @Reservado2CL, @Reservado3CL, @CodigoEstandarCL, @DescripcionTransaccionCL, @FechaPresentacionCL, @FechaVencimientoCL, @Reservado4CL, @CodigoOrigenCL, @IdEntidadOrigenCL, @NumeroLoteCL));
------------------------------

-- Variables Control Fin de Lote --
DECLARE @IdRegistroFL VARCHAR(1) = ''8'';
DECLARE @CodigoTransaccionFL VARCHAR(2) = ''200'';
DECLARE @CantidadRegistrosFL NUMERIC(5) = 0;
DECLARE @TotalesControlFL VARCHAR(10) = 0;
DECLARE @SumaTotalDebitosFL NUMERIC(12) = 0;
DECLARE @SumaTotalCreditosFL NUMERIC(12) = 0;
DECLARE @Reservado1FL VARCHAR(10) = replicate('' '', 10);
DECLARE @Reservado2FL VARCHAR(19) = replicate('' '', 19);
DECLARE @Reservado3FL VARCHAR(6) = replicate('' '', 6);
DECLARE @IdOrigenFL VARCHAR(8) = @CodigoOrigenCL;
DECLARE @NroLoteFL VARCHAR(8) = RIGHT(concat(replicate(''0'', 8), @IdOrigenFL), 8);
DECLARE @SumaEntidad NUMERIC(15);
DECLARE @SumaSucursal NUMERIC(15);
-- Fin Variables Control Fin de Lote --

-- Variables Registro Individual Rechazo Cheques y Ajustes --
DECLARE @IdRegistroRI VARCHAR(1) = ''6'';
DECLARE @CodigoTransaccionRI VARCHAR(2) = ''26'';
DECLARE @EntidadDebitarRI VARCHAR(8) = ''''; 
DECLARE @Reservado1RI VARCHAR(1) = ''0'';
DECLARE @CuentaDebitarRI VARCHAR(17) = '''';
DECLARE @ImporteRI NUMERIC(8, 2);
DECLARE @NroChequeRI VARCHAR(15);
DECLARE @CodigoPostalRI VARCHAR(6);
DECLARE @PuntoIntercambioRI VARCHAR(16);
DECLARE @InfoAdicionalRI VARCHAR(2) = ''00'';
DECLARE @RegistrosAdicionalesRI NUMERIC(1) = 0;
DECLARE @ContadorRegistrosRI NUMERIC(15);
-- Fin Variables Registro Individual Rechazo Cheques y Ajustes --

-- Grabar Registros Individuales --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA)

SELECT concat(@IdRegistroRI, @CodigoTransaccionRI, ENTIDAD_DEBITAR, @Reservado1RI, CUENTA_DEBITAR, IMPORTE, NRO_CHEQUE, CODIGO_POSTAL, PUNTO_INTERCAMBIO, @InfoAdicionalRI, @RegistrosAdicionalesRI, TRACE_NUMBER)
FROM ITF_COELSA_CHEQUES_RECHAZO 
WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))

-- Contar la cantidad de registros y la suma de sus importes -----------------------------------------------------------
SET @CantidadRegistrosFL += ISNULL((SELECT COUNT(ID) FROM ITF_COELSA_CHEQUES_RECHAZO WITH(NOLOCK) WHERE TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA AND ESTADO = ''P'' AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))), 0);
SET @SumaTotalDebitosFL += ISNULL((SELECT SUM(IMPORTE) FROM ITF_COELSA_CHEQUES_RECHAZO WITH(NOLOCK) WHERE TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA AND ESTADO = ''P'' AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))), 0);	
-----------------------------------------------------------------------------------------------------------------------

-- Variables Control Fin de Archivo --
DECLARE @IdRegistroFA VARCHAR(1) = ''9'';
DECLARE @CantidadLotesFA NUMERIC(6);
DECLARE @NumeroBloquesFA NUMERIC(6);
DECLARE @CantidadRegistrosFA VARCHAR(8);
DECLARE @TotalesControlFA VARCHAR(10);
DECLARE @SumaTotalDebitosFA NUMERIC(12) = 0;
DECLARE @SumaTotalCreditosFA NUMERIC(12) = 0;
DECLARE @Reservado1FA VARCHAR(36) = replicate('' '', 36);
-- Fin Variables Control Fin de Archivo --

-- Variable Moneda Topaz --
DECLARE @MonedaTopaz NUMERIC(4) = (CASE WHEN @MONEDA = 1 THEN 2 ELSE 1 END); 
-------------------------
SELECT * FROM MONEDAS
-- Registro Individual --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA)

SELECT 
concat(@IdRegistroRI, @CodigoTransaccionRI, 

concat(RIGHT(concat(replicate(''0'', 4), D.BANCO_DEPOSITANTE), 4), RIGHT(concat(replicate(''0'',4), D.NUMERO_DEPENDENCIA), 4)) , --entidad a debitar 

@Reservado1RI,

RIGHT(concat(replicate(''0'', 12), D.NUMERICO_CUENTA), 12) , -- cuenta a debitar

RIGHT(replace(concat(replicate(''0'', 10), TRY_CONVERT(NUMERIC(8,2), D.IMPORTE)), ''.'', ''''), 12), -- importe 

concat(''00'', RIGHT(concat(replicate(''0'', 13), D.NUMERO_DPF), 13)) , -- nro cheque

concat(''00'', RIGHT(concat(replicate(''0'', 4), D.BANCO_DEPOSITANTE), 4)) ,  -- codigo postal

concat(''0000'', RIGHT(concat(''0000'', D.CODIGO_CAUSAL_RECHAZO), 4), replicate('' '', 8)) , -- pto intercambio

concat(CASE WHEN D.MONEDA = 1 THEN ''0'' ELSE ''1'' END, ''0''), ''0'' , -- registros adicionales

RIGHT(concat(''0311'', RIGHT(concat(replicate(''0'', 4), D.NUMERO_DEPENDENCIA), 4), RIGHT(concat(replicate(''0'', 7), ISNULL((SELECT MAX(ORDINAL) FROM ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL WHERE FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))), 0) + 1), 7)), 15)  -- contador de registros
)

FROM CLE_DPF_RECIBIDO D

WHERE D.FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND MONEDA = @MonedaTopaz AND D.TZ_LOCK = 0 AND D.CODIGO_CAUSAL_RECHAZO <> 0 AND D.ESTADO_DPF IN (''R'', ''E'');
--(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) 

-- Contar la cantidad de registros y la suma de sus importes -----------------------------------------------------------
SET @CantidadRegistrosFL += ISNULL((SELECT COUNT(*) FROM CLE_DPF_RECIBIDO WITH(NOLOCK) WHERE FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND MONEDA = @MONEDA  AND ESTADO_DPF IN (''R'', ''E'') AND CODIGO_CAUSAL_RECHAZO <> 0), 0);
SET @SumaTotalDebitosFL += ISNULL((SELECT SUM(IMPORTE) FROM CLE_DPF_RECIBIDO WITH(NOLOCK) WHERE FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND MONEDA = @MONEDA  AND ESTADO_DPF IN (''R'', ''E'') AND CODIGO_CAUSAL_RECHAZO <> 0), 0);	
-----------------------------------------------------------------------------------------------------------------------

-- Suma de entidad y sucursal ---------------------------------------------
SET @SumaEntidad += ISNULL((SELECT SUM(BANCO_DEPOSITANTE) FROM CLE_DPF_RECIBIDO WITH(NOLOCK) WHERE FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND MONEDA = @MONEDA AND ESTADO_DPF IN (''R'', ''E'') AND CODIGO_CAUSAL_RECHAZO <> 0) , 0);
SET @SumaSucursal += ISNULL((SELECT SUM(NUMERO_DEPENDENCIA) FROM CLE_DPF_RECIBIDO WITH(NOLOCK) WHERE FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND MONEDA = @MONEDA AND ESTADO_DPF IN (''R'', ''E'') AND CODIGO_CAUSAL_RECHAZO <> 0) , 0);
-----------------------------------------------------------------------------

-- Actualizamos secuencial único--
INSERT INTO dbo.ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL (ORDINAL, FECHA) VALUES ((ISNULL((SELECT MAX(ORDINAL) FROM ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL WHERE FECHA = (SELECT FECHAPROCESO FROM PARAMETROS)), 0) + 1), (SELECT FECHAPROCESO FROM PARAMETROS));
------------------------------

SET @CantidadRegistrosFL = RIGHT(concat(replicate(''0'', 6), @CantidadRegistrosFL), 6);

DECLARE @SumatoriaSignificativaSucursal VARCHAR(4);

SET @SumatoriaSignificativaSucursal = RIGHT(@SumaSucursal , 4);

DECLARE @SobranteSumatoriaSucursal VARCHAR(4);

SET @SobranteSumatoriaSucursal = substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4));

SET @SumaEntidad += CAST(@SobranteSumatoriaSucursal AS NUMERIC);

SET @TotalesControlFL = concat(@SumaEntidad, @SumaSucursal);


-- Control Fin Lote --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (concat(@IdRegistroFL, @CodigoTransaccionFL, @CantidadRegistrosFL, @TotalesControlFL, @SumaTotalDebitosFL, @SumaTotalCreditosFL, @Reservado1FL, @Reservado2FL, @Reservado3FL, @IdOrigenFL, @NroLoteFL));
--------------------

DECLARE @CantRegistrosAux NUMERIC(6) = (ISNULL((SELECT COUNT(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX), 0));

SET @CantidadLotesFA = (concat(replicate(''0'', 5), ''1''));
SET @NumeroBloquesFA = (CASE WHEN (@CantRegistrosAux) % 10 = 0 THEN (@CantRegistrosAux/10) ELSE (FLOOR(@CantRegistrosAux/10) + 1) END);
SET @CantidadRegistrosFA = @CantidadRegistrosFL;
SET @TotalesControlFA = concat(@SumaEntidad, @SumaSucursal);
SET @SumaTotalDebitosFA = @SumaTotalDebitosFL;


-- Control Fin Archivo --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (concat(@IdRegistroFA, @CantidadLotesFA, @NumeroBloquesFA, @CantidadRegistrosFA, @TotalesControlFA, @SumaTotalDebitosFA, @SumaTotalCreditosFA, @Reservado1FA));
--------------------
END;


')


EXECUTE('

IF OBJECT_ID (''dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX



CREATE TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX
	(
	ID    INT IDENTITY NOT NULL,
	LINEA VARCHAR (200),
	PRIMARY KEY (ID)
	)

')
