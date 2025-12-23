EXECUTE('

IF OBJECT_ID (''dbo.SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS'') IS NOT NULL
	DROP PROCEDURE dbo.SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS
')
EXECUTE('
CREATE PROCEDURE [dbo].[SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS]
   @TICKET NUMERIC(16)
AS 
BEGIN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 07/09/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se ajusta la query para filtrar solo cheques y ajustes (dpf van en plano aparte).
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 20/05/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de generar la información de los cheques propios rechazados a informar a COELSA.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Limpieza de tabla auxiliar --
TRUNCATE TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX;

-- Variables Generales --
DECLARE @NroLinea NUMERIC(15) = 1;
-- Fin Variables Generales --

-- Variables Cabecera Archivo --
DECLARE @IdRegistroCA NUMERIC(15) = 1;
DECLARE @CodigoPrioridadCA VARCHAR(2) = ''01'';
DECLARE @DestinoInmediatoCA VARCHAR(10) = '' 000000010'';
DECLARE @OrigenInmediatoCA VARCHAR(10) = '' 031100300'';
DECLARE @FechaPresentacion VARCHAR(6) = FORMAT((SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) , ''yyMMdd'');;
DECLARE @HoraPresentacion VARCHAR(4) = FORMAT((SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), ''hhmm'');;
DECLARE @IdArchivoCA NUMERIC(15) = 1;
DECLARE @TamanioRegistro VARCHAR(3) = ''094'';
DECLARE @FactorBloque VARCHAR(2) = ''10'';
DECLARE @CodigoFormato VARCHAR(1) = ''1'';
DECLARE @NombreDestinoInmediato VARCHAR(6) = ''COELSA'';
DECLARE @NombreOrigenInmediato VARCHAR(21) = ''NUEVO BCO CHACHO S.A.'';
DECLARE @CodigoReferencia VARCHAR(8) = ''CHQ.RECH'';
-- Fin Variables Cabecera Archivo --

-- Grabar cabecera de archivo --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (ID, LINEA) VALUES (@NroLinea, concat(@IdRegistroCA, @CodigoPrioridadCA, @DestinoInmediatoCA, @OrigenInmediatoCA, @FechaPresentacion, @HoraPresentacion, @IdArchivoCA, @TamanioRegistro, @FactorBloque, @CodigoFormato, @NombreDestinoInmediato, @NombreOrigenInmediato, @CodigoReferencia));
SET @NroLinea = @NroLinea + 1;
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
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (ID, LINEA) VALUES (@NroLinea, concat(@IdRegistroCL, @CodigoTransaccionCL, @Reservado1CL, @Reservado2CL, @Reservado3CL, @CodigoEstandarCL, @DescripcionTransaccionCL, @FechaPresentacionCL, @FechaVencimientoCL, @Reservado4CL, @CodigoOrigenCL, @IdEntidadOrigenCL, @NumeroLoteCL));
SET @NroLinea = @NroLinea + 1;
------------------------------


-- Variables Registro Individual Rechazo Cheques y Ajustes --
DECLARE @IdRegistroRI VARCHAR(1) = ''6'';
DECLARE @CodigoTransaccionRI VARCHAR(2) = ''26''; --
DECLARE @EntidadDebitarRI VARCHAR(8) = ''''; --
DECLARE @Reservado1RI VARCHAR(1) = ''0'';
DECLARE @CuentaDebitarRI VARCHAR(17) = '''';
DECLARE @ImporteRI NUMERIC(8, 2);
DECLARE @NroChequeRI VARCHAR(15);
DECLARE @CodigoPostalRI VARCHAR(6);
DECLARE @PuntoIntercambioRI VARCHAR(16);
DECLARE @InfoAdicionalRI VARCHAR(2) = ''00'';
DECLARE @RegistrosAdicionalesRI NUMERIC(1);
DECLARE @ContadorRegistrosRI NUMERIC(15);
-- Fin Variables Registro Individual Rechazo Cheques y Ajustes --

-- Variables Registro Adicional Rechazo Cheques y Ajustes --
DECLARE @IdRegistroRA VARCHAR(1) = ''7'';
DECLARE @CodigoAdicionalRA VARCHAR(2) = ''99'';
DECLARE @PrimerMotivoRechazoRA VARCHAR(3) = (concat(''R'', (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WITH(NOLOCK) WHERE CODIGO_DE_CAUSAL = 62)));
DECLARE @ContadorRegistrosOriginalRA VARCHAR(15);
DECLARE @NumeroComunicadoRA VARCHAR(6) = replicate('' '', 6);
DECLARE @EntidadTransaccionOriginalRA VARCHAR(8);
DECLARE @OtrosMotivosRechazosRA VARCHAR(43);
DECLARE @ContadorRegistrosRA VARCHAR(15);
-- Fin Variables Registro Adicional Rechazo Cheques y Ajustes --

-- Variables Registro Individual Respuesta Fuera de Canje --
DECLARE @IdRegistroFC VARCHAR(1) = ''6'';
DECLARE @CodigoTransaccionFC VARCHAR(2) = ''26'';
DECLARE @EntidadDestinoFC VARCHAR(8);
DECLARE @Reservado1F VARCHAR(1) = ''0'';
DECLARE @CuentaAfectadaFC VARCHAR(17);
DECLARE @ImporteFC  NUMERIC(8,2);
DECLARE @NroChequeFC VARCHAR(15);
DECLARE @DatosReclamoFC VARCHAR(6);
DECLARE @PuntoIntercambioFC VARCHAR(16);
DECLARE @InfoAdicionalFC VARCHAR(2);
DECLARE @RegistrosAdicionalesFC VARCHAR(1);
DECLARE @ContadorRegistrosFC VARCHAR(15);
-- Fin Variables Registro Adicional Respuesta Fuera de Canje --

-- Variables Registro Adicional Respuesta Fuera de Canje --
/*
DECLARE @IdRegistroFCA = 6;
DECLARE @CodigoRegistroFCA = 99;
DECLARE @MotivoRechazoFCA;
DECLARE @ContadorRegistrosOriginalFCA;
DECLARE @Reservado1FCA;
DECLARE @EntidadTransaccionOriginalFCA;
DECLARE @OtrosMotivosRechazoFCA;
DECLARE @ContadorRegistrosFCA;
*/
-- Fin Variables Registro Adicional Respuesta Fuera de Canje --

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

-- Variables Control Fin de Archivo --
DECLARE @IdRegistroFA VARCHAR(1) = ''9'';
DECLARE @CantidadLotesFA NUMERIC(6);
DECLARE @NumeroBloquesFA NUMERIC(6);
DECLARE @CantidadRegistrosFA VARCHAR(8);
DECLARE @TotalesControlFA VARCHAR(10);
DECLARE @SumaTotalDebitosFA NUMERIC(12) = 0;
DECLARE @SumaTotalCreditosFA NUMERIC(12) = 0;
DECLARE @Reservado1FA VARCHAR(36);

-- Fin Variables Control Fin de Archivo --

DECLARE cursor_che_rechazados CURSOR FOR

SELECT ID, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, FECHA_PRESENTADO, CODIGO_POSTAL, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO FROM ITF_COELSA_CHEQUES_RECHAZO WHERE TIPO IN (''C'', ''A'') AND ESTADO = ''P'' AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));

-- Variables Cursor cursor_che_rechazados --
DECLARE @ID INT;  
DECLARE @CheFechaProceso DATE;
DECLARE @CheCodigoTransaccion NUMERIC(2);
DECLARE @CheEntidadDebitar NUMERIC(8);
DECLARE @CheCuentaDebitar NUMERIC(12);
DECLARE @CheImporte NUMERIC(15, 2);
DECLARE @CheCodigoPostal VARCHAR(6);
DECLARE @CheFechaPresentado DATE;
DECLARE @CheFechaVencimiento DATE;
DECLARE @CheNroCheque NUMERIC(15);
DECLARE @ChePuntoIntercambio VARCHAR(16);
DECLARE @CheTraceNumber NUMERIC(15);
DECLARE @CheEstado VARCHAR(1);
DECLARE @CheTipo VARCHAR(1);
DECLARE @CheCodRechazo NUMERIC(2); 	  	  
-- Fin Variables Cursor --


OPEN cursor_che_rechazados
	  
FETCH NEXT FROM cursor_che_rechazados INTO @ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo
	  
WHILE @@FETCH_STATUS = 0
BEGIN


--SET @EntidadDebitarRI = @CheEntidadDebitar; 
--SET @CuentaDebitarRI = @CheCuentaDebitar;
--SET @ImporteRI = @CheImporte;
--SET @NroChequeRI = @CheNroCheque;
--SET @CodigoPostalRI = @CheCodigoPostal;
--SET @PuntoIntercambioRI = @ChePuntoIntercambio;
SET @RegistrosAdicionalesRI = ''0'';
--SET @ContadorRegistrosRI = @CheTraceNumber;

-- Registro Individual --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (ID, LINEA) VALUES (@NroLinea, concat(@IdRegistroRI, @CodigoTransaccionRI, @CheEntidadDebitar, @Reservado1RI, @CheCuentaDebitar, @CheImporte, @CheNroCheque, @CheCodigoPostal, @ChePuntoIntercambio, @InfoAdicionalRI, @RegistrosAdicionalesRI, @CheTraceNumber));

SET @NroLinea = @NroLinea + 1;
SET @CantidadRegistrosFL = @CantidadRegistrosFL +1;
SET @SumaTotalDebitosFL += @ImporteRI;	
------------------------------

FETCH NEXT FROM cursor_che_rechazados INTO @ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo
END
	  
CLOSE cursor_che_rechazados 
DEALLOCATE cursor_che_rechazados 	  	      


-- Variables Cursor cursor_che_devueltos --
DECLARE @CheEntidadDebitarCD VARCHAR(8);
DECLARE @CheCuentaDebitarCD VARCHAR(12);
DECLARE @CheImporteCD VARCHAR(12);
DECLARE @CheCodigoPostalCD VARCHAR(6);
DECLARE @CheNroChequeCD VARCHAR(15);
DECLARE @ChePuntoIntercambioCD VARCHAR(16);
DECLARE @CheTraceNumberCD VARCHAR(15);
DECLARE @CheInfoAdicionalCD VARCHAR(2);
DECLARE @CheRegistrosAdicionalesCD VARCHAR(1);
-- Fin Variables Cursor --

-- Cursor cursor_che_devueltos

DECLARE cursor_che_devueltos CURSOR FOR 

SELECT concat(RIGHT(concat(replicate(''0'', 4), CD.CODBANCO), 4), RIGHT(concat(replicate(''0'',4), CD.SUCURSAL), 4)) AS EntidadDebitar, RIGHT(concat(replicate(''0'', 12), CD.CUENTA), 12) AS CuentaDebitar,

RIGHT(replace(concat(replicate(''0'', 10), TRY_CONVERT(NUMERIC(8,2), CD.IMPORTE)), ''.'', ''''), 12) AS Importe, concat(''00'', RIGHT(concat(replicate(''0'', 13), CD.NROCHEQUE), 13)) AS NroCheque,

concat(''00'', RIGHT(concat(replicate(''0'', 4), CD.CODBANCO), 4)) AS CodigoPostal, concat(''0000'', RIGHT(concat(''0000'', CR.CODIGO_CAUSAL_DEVOLUCION), 4), replicate('' '', 8)) AS PtoIntercambio,

concat(CASE WHEN CD.MONEDA = 1 THEN ''0'' ELSE ''1'' END, ''0'') AS InfoAdicional, ''0'' AS RegistroAdicionales,

RIGHT(concat(''0311'', RIGHT(concat(replicate(''0'', 4), CD.SUCURSAL), 4), RIGHT(concat(replicate(''0'', 7), ISNULL((SELECT MAX(ORDINAL) FROM ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL WHERE FECHA = (SELECT FECHAPROCESO FROM PARAMETROS)), 0) + 1), 7)), 15)  AS ContadorRegistros

FROM CLE_CHEQUES_CLEARING_DEVUELTOS CD, CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR 

WHERE CD.NROCHEQUE = CC.NUMERO_CHEQUE AND CC.NUMERO_CHEQUE = CR.NUMERO_CHEQUE AND CR.CANJE_INTERNO IN (''N'', NULL) AND CD.FECHACHEQUE = (SELECT FECHAPROCESO FROM PARAMETROS) AND CD.TZ_LOCK = 0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0;

OPEN cursor_che_devueltos
	  
FETCH NEXT FROM cursor_che_devueltos INTO @CheEntidadDebitarCD, @CheCuentaDebitarCD, @CheImporteCD, @CheCodigoPostalCD, @CheNroChequeCD, @ChePuntoIntercambioCD, @CheTraceNumberCD, @CheInfoAdicionalCD, @CheRegistrosAdicionalesCD
	  
WHILE @@FETCH_STATUS = 0
BEGIN

--
SET @IdRegistroRI = 6;
SET @CodigoTransaccionRI = ''26'';

-- Registro Individual --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (ID, LINEA) VALUES (@NroLinea, concat(@IdRegistroRI, @CodigoTransaccionRI, @CheEntidadDebitarCD, @Reservado1RI, @CheCuentaDebitarCD, @CheImporteCD, @CheNroChequeCD, @CheCodigoPostalCD, @ChePuntoIntercambioCD, @CheInfoAdicionalCD, @CheRegistrosAdicionalesCD, @CheTraceNumberCD));

SET @NroLinea = @NroLinea + 1;

SET @CantidadRegistrosFL = @CantidadRegistrosFL +1;

SET @SumaTotalDebitosFL += @CheImporteCD;

SET @SumaEntidad += CAST(substring(@CheEntidadDebitarCD, 1, 4) AS NUMERIC);

SET @SumaSucursal += CAST(substring(@CheEntidadDebitarCD, 5, 4) AS NUMERIC);

-- Actualizamos secuencial único--
INSERT INTO dbo.ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL (ORDINAL, FECHA) VALUES ((ISNULL((SELECT MAX(ORDINAL) FROM ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL WHERE FECHA = (SELECT FECHAPROCESO FROM PARAMETROS)), 0) + 1), (SELECT FECHAPROCESO FROM PARAMETROS));
------------------------------

-- Variables cursor_che_ajustes --
DECLARE @CheNroChequeAJ VARCHAR(12);

DECLARE @CheImporteAJ NUMERIC(8,2);
-----------------------------------

-- Cursor de ajustes cheques --
DECLARE cursor_che_ajustes CURSOR FOR

SELECT NUMERO_CHEQUE, IMPORTE FROM CLE_CHEQUES_AJUSTE WHERE ESTADO = ''F'' AND ENVIADO_RECIBIDO = ''R'' AND ESTADO_AJUSTE = ''R'' AND NUMERO_CHEQUE = @CheNroChequeCD;

OPEN cursor_che_ajustes

FETCH NEXT FROM cursor_che_ajustes INTO @CheNroChequeAJ, @CheImporteAJ

WHILE @@FETCH_STATUS = 0
BEGIN

-- Registro de Ajuste--
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (ID, LINEA) VALUES (@NroLinea, concat(@IdRegistroRA, @CodigoAdicionalRA, @PrimerMotivoRechazoRA, @CheTraceNumberCD, @NumeroComunicadoRA, @CheEntidadDebitarCD, ''    '', @CheTraceNumberCD));
SET @NroLinea = @NroLinea + 1;
SET @CantidadRegistrosFL = @CantidadRegistrosFL +1;
SET @SumaTotalDebitosFL += @CheImporteAJ;
-----------------------
FETCH NEXT FROM cursor_che_ajustes INTO @CheNroChequeAJ, @CheImporteAJ
END
CLOSE cursor_che_ajustes 
DEALLOCATE cursor_che_ajustes 
-- Fin Cursor Ajustes Cheques --

FETCH NEXT FROM cursor_che_devueltos INTO @CheEntidadDebitarCD, @CheEntidadDebitarCD, @CheImporteCD, @CheCodigoPostalCD, @CheNroChequeCD, @ChePuntoIntercambioCD, @CheTraceNumberCD, @CheInfoAdicionalCD, @CheRegistrosAdicionalesCD
END
	  
CLOSE cursor_che_devueltos 
DEALLOCATE cursor_che_devueltos 

SET @SumaEntidad += CAST(substring(@CheEntidadDebitarCD, 1, 4) AS NUMERIC);

SET @SumaSucursal += CAST(substring(@CheEntidadDebitarCD, 5, 4) AS NUMERIC);


SET @CantidadRegistrosFL = RIGHT(concat(replicate(''0'', 6), @CantidadRegistrosFL), 6);

DECLARE @SumatoriaSignificativaSucursal VARCHAR(4);

SET @SumatoriaSignificativaSucursal = RIGHT(@SumaSucursal , 4);

DECLARE @SobranteSumatoriaSucursal VARCHAR(4);

SET @SobranteSumatoriaSucursal = substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4));

SET @SumaEntidad += CAST(@SobranteSumatoriaSucursal AS NUMERIC);

SET @TotalesControlFL = concat(@SumaEntidad, @SumaSucursal);


-- Control Fin Lote --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (ID, LINEA) VALUES (@NroLinea, concat(@IdRegistroFL, @CodigoTransaccionFL, @CantidadRegistrosFL, @TotalesControlFL, @SumaTotalDebitosFL, @SumaTotalCreditosFL, @Reservado1FL, @Reservado2FL, @Reservado3FL, @IdOrigenFL, @NroLoteFL));
SET @NroLinea = @NroLinea + 1;
--------------------

DECLARE @CantRegistrosAux NUMERIC(6) = (ISNULL((SELECT COUNT(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX), 0));

SET @CantidadLotesFA = (concat(replicate(''0'', 5), ''1''));
SET @NumeroBloquesFA = (CASE WHEN (@CantRegistrosAux) % 10 = 0 THEN (@CantRegistrosAux/10) ELSE (FLOOR(@CantRegistrosAux/10) + 1) END);
SET @CantidadRegistrosFA = @CantidadRegistrosFL;
SET @TotalesControlFA = concat(@SumaEntidad, @SumaSucursal);
SET @SumaTotalDebitosFA = @SumaTotalDebitosFL;
SET @Reservado1FA = replicate('' '', 36);

-- Control Fin Archivo --
INSERT INTO ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (ID, LINEA) VALUES (@NroLinea, concat(@IdRegistroFA, @CantidadLotesFA, @NumeroBloquesFA, @CantidadRegistrosFA, @TotalesControlFA, @SumaTotalDebitosFA, @SumaTotalCreditosFA, @Reservado1FA));
SET @NroLinea = @NroLinea + 1;
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


IF OBJECT_ID (''dbo.ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL'') IS NOT NULL
	DROP TABLE dbo.ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL


CREATE TABLE dbo.ITF_CHE_RECIBIDOS_RECHAZADOS_HISTORIAL
	(
	ORDINAL NUMERIC (15) NOT NULL,
	FECHA   DATETIME NOT NULL,
	CONSTRAINT PK_ITF_CHE_RECIBIDOS_HISTORIAL_01 PRIMARY KEY (ORDINAL, FECHA)
	)

')
