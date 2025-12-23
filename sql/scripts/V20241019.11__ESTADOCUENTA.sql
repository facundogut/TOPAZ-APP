EXECUTE('
CREATE OR ALTER  PROCEDURE [ESTADOCUENTA]
   @p_id_proceso float(53) = NULL,
   @p_dt_proceso DATETIME = NULL,
   @p_legal varchar(max) = NULL,
   @p_periodo varchar(max),
   @p_FechaIni DATETIME = NULL,
   @p_FechaFin DATETIME = NULL,
   @p_JTSOID NUMERIC(10) = NULL,
   @p_ret_proceso float(53)  OUTPUT,
   @p_msg_proceso varchar(max)  OUTPUT
AS 
BEGIN
	
	------- Campos para el LOG --------
	DECLARE
		@c_log_tipo_error varchar(30),
		@c_log_tipo_informacion VARCHAR(30),
		
		-- HELP VARIABLES!!
		@jts_oid FLOAT,
		@datoclientehelp FLOAT,
		@integraclientehelp VARCHAR (200),
		@localidad VARCHAR (100),
		@asientomovimiento FLOAT,
		@contadorInfoExt float

	-----------------------------------
	
	------- Campos para el LOG --------
		SET @c_log_tipo_error = ''E''
		SET @c_log_tipo_informacion = ''I''
			
	------- Parametro JTSOID ----------
		IF @p_JTSOID = 0
			SET @p_JTSOID = NULL
   
	------------Tablas auxiliares--------------
   
	-- Saldos
	DECLARE @TMPSaldos TABLE (
		IdCab INT IDENTITY(1,1) NOT NULL,
		Cliente float(53),
		Rubro float(53),
		Prod float(53),
		TipoTasa char(1),
		Cuenta float(53),
		TipoProd float(53),
		Moneda float(53),
		Sucursal float(53),
		Operacion float(53),
		Ordinal float(53),
		Sal24 numeric(15, 2),
		Sal48 numeric(15, 2),
		Garantia char(1),
		TasaRen numeric(11, 7),
		PlazoRen numeric(5),
		SignoSal char(1),
		CodOpVenc char(1),
		SaldoAct numeric(15, 2),
		CupoSobregiro numeric(15, 2),
		JTSOID float(53),
		PeriodProd char(1),
		PeriodEC char(1),
		Correo char(1),
		TipoDireccion varchar(2),
		CantDeb FLOAT,
		CantCred FLOAT,
		Periodicidad CHAR (1),
		Canal CHAR (1),
		NombreSucursal VARCHAR (50),
		NombreProducto VARCHAR(50),
		MonedaCAB VARCHAR(20),
		ResumenEn VARCHAR (20),
		CBU VARCHAR (25),
		SaldoCalcLinea NUMERIC (15,2),
		CREDEB NUMERIC(15,2),
		SIRCREB NUMERIC(15,2),
		IIBB_CORRIENTES NUMERIC(15,2),
		ImportesPend numeric(15, 2),
		Transferencia numeric(15, 2),
		Disponible numeric(15, 2)
	)
	
	-- Saldos Diarios
	DECLARE @TMPSaldosDiarios TABLE	(
		JTSOID float(53),
		SalDiaIni NUMERIC(15, 2),
		TeaCobro NUMERIC(15, 7),
		TeaPago  NUMERIC(15, 7),
		Promedio NUMERIC(15, 2),
		CuposobregiroDiario NUMERIC (15,2),
		SaldoCalcLineaABS NUMERIC (15,2),
		SaldoCalcLinea NUMERIC (15,2),
		SaldoINI NUMERIC (15,2),
		SaldoFin NUMERIC(15,2),
		SalDiaFin numeric(15, 2),
		TeapagoSD numeric(15, 2),
		TeacobroSD numeric(15, 2)
	)
	
    -- Datos del Titular
	DECLARE @TMPDatosTitular TABLE	(
		Cliente float(53),
        NroPersona NUMERIC(12),
        TipoPersona VARCHAR(1),
        DocTitular varchar(20),
        NomTitular varchar(70),
        TipoCliente VARCHAR(1),
        nomcli varchar(70),
        Formato VARCHAR(2),
        TipoDireccion varchar(2),
        JTSOID float(53)
	)
	
	-- Dirección Titular	 
	DECLARE @TMPDireccionTitular TABLE (
		Cliente float(53),
        Calle varchar(60),
        NumeroPuerta numeric(10),
        Apartamento varchar(100),
		Piso numeric(8),
        CiudadLocalidad varchar(60),
        Provincia varchar(60),
        CodigoPais numeric(5),
        CodigoPostal varchar(15),
        Barrio varchar(100),
        JTSOID float(53)
	)
	
	-- Personas Integrantes Cliente
	DECLARE @TMPIntegrantesCliente TABLE (
		Cliente float(53),
		CantTitulares numeric(10),
        DocTitular2 varchar(20),
        NomTitular2 varchar(70),
        DocTitular3 varchar(20),
        NomTitular3 varchar(70),
        JTSOID float(53)
	)
	
	-- Movimientos dependiendo del producto
	DECLARE @TMPMovimientosContables TABLE (
		FechaRealMov datetime,
		HoraMov varchar(8),
		FechaProcesado datetime,
        Concepto varchar(256),
        SucursalOrigen float(53),
        Asiento float(53),
        FechaValor datetime,
        SignoMov char(1),
        TIPOMOV char(1),
        Monto float(53),
        Referencia numeric(15),
        OperacionTopaz float(53),
        CodTransaccion float(53),
        JTSOID float(53),
        ImporteD numeric(15, 2),
		ImporteC numeric(15, 2),
		DetalleTr VARCHAR(60),
		InfoExtendida VARCHAR(1),
		LineaInfo VARCHAR(150),
		Cuenta float(53),
		SaldoCalcLineaAux NUMERIC (15,2),
		CREDEBAux NUMERIC(15,2),
		SIRCREBAux NUMERIC(15,2),
		IIBB_CORRIENTESAux NUMERIC(15,2),
		SignoSal char(1),
		Cliente float(53),
        RegistroxJTS BIGINT
	)
	
	-- Auxiliar de Temporal de Movimientos Contables (para acumulador)
	DECLARE @TMPMovimientosContablesAux TABLE (
		JTSOID float(53),
		RegistroxJTS BIGINT,
		SaldoCalcLineaAux NUMERIC (15,2)
	)
	
	-- Auxiliar para Información Extendida
	DECLARE @TMPInfoExt TABLE (
		JTSOID float(53),
		RegistroxJTS BIGINT,
		Asiento float(53),
		CodTransaccion float(53),
		Cliente float(53),
		LineaInfo VARCHAR(150)
	)
	
    ------------Cargo Tablas auxiliares y variables necesarias--------------
               
	/*			SALDOS
	*
	*   cliente, producto, cuenta. tipoprod, moneda, suc, operacion, ordinal
	*   Sal24,Sal48, garantia, tasaRen, pzoRen, CodOpVenc, SaldoAct, CupoSobregiro, jts
	*/
	--BEGIN TRY
    
    BEGIN TRY
	
		INSERT INTO @TMPSaldos
			SELECT
				s.C1803 AS Cliente,
				s.C1730 AS Rubro,
				s.PRODUCTO AS Prod,
				Pr.C6253 AS TipoTasa ,
				s.CUENTA AS Cuenta,
				s.C1785 AS TipoProd,
				s.MONEDA AS Moneda,
				s.SUCURSAL AS Sucursal,
				s.OPERACION AS Operacion,
				s.ORDINAL AS Ordinal,
				s.C1606 AS Sal24,
				s.C1607 AS Sal48,
				s.C1734 AS Garantia,
				s.C1637 AS TasaRen,
				s.C1689 AS PlazoRen,
				p.C6305 AS SignoSal,
				s.C1728 AS CodOpVenc,
				s.C1604 AS SaldoAct,
				s.C1683 AS CupoSobregiro,
				s.JTS_OID AS JTSOID,
				isnull(Pr.PERIODOLEGALESTCTA, ''M'') AS PeriodProd,
				isnull(E.PERIODICIDAD, ''M'') AS PeriodEC,
				isnull(E.RETENER_CORRESPONDENCIA, ''S'') AS Correo,
				E.TIPODIRECCION AS TipoDireccion,
				0 AS CantDeb,
				0 AS CantCred,
				'''' AS Periodicidad,
				'''' AS Canal,
				n.NOMBRESUCURSAL AS NombreSucursal,
				Pr.C6251 AS NombreProducto,
				(CASE
					WHEN C6403=''I'' THEN
						(SELECT C6400 FROM MONEDAS with (nolock)
							WHERE C6399 = (SELECT MONNAC FROM PARAMETROS with (nolock))
							AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000)
								AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)
							)
						)
					ELSE
						m.C6400
				END) AS MonedaCAB,
				m.C6400 AS ResumenEn,
				v.CTA_CBU AS CBU,
				0 AS SaldoCalcLinea,
				0 AS CREDEB,
				0 AS SIRCREB,
				0 AS IIBB_CORRIENTES,
				ISNULL((	SELECT sum(C.IMPORTE)
				     		FROM dbo.CLE_CHEQUES_SALIENTE AS C with (nolock)
				     		INNER JOIN dbo.CLE_DEPOSITOS  AS D with (nolock) ON
				     			D.SALDO_JTS_OID = s.JTS_OID
								AND D.NUMERO_DEPOSITO = C.NUMERO_DEPOSITO
								AND C.ACREDITADO = 0 
								AND C.DESTINO_CHEQUE IN (1,5)
							), 0
				) AS ImportesPend,
				0 AS Transferencia,
				0 AS Disponible
			FROM
				dbo.SALDOS  AS s with (nolock)
			INNER JOIN dbo.PLANCTAS  AS p with (nolock) ON
				s.TZ_LOCK = 0
				AND p.TZ_LOCK = 0
				AND s.C1730 = p.C6326
				AND s.C1785 in (2,3)
				AND (s.JTS_OID = @p_JTSOID or isnull(@p_JTSOID, -1) = -1)
				AND s.C1728 <>''I'' and s.C1651 <>''1''
		   INNER JOIN dbo.GRL_ESTADOS_DE_CUENTA  AS E with (nolock) ON
				s.CUENTA = E.CUENTA
				AND E.TZ_LOCK = 0
				AND s.PRODUCTO = E.PRODUCTO
				AND s.MONEDA = E.MONEDA
				AND s.SUCURSAL = E.SUCURSAL
				AND s.OPERACION = E.OPERACION
				AND s.ORDINAL = E.ORDINAL
				/* Obtener periodicidad dependiendo de si es Legal o no*/
				AND (
						(
							(E.PERIODICIDAD = upper(@p_Periodo)
								OR upper(@p_Periodo) = ''P''
							)
							AND @p_Legal <> ''L''
						)
						OR
						(	E.PERIODICIDAD = upper(@p_Periodo)
							AND	E.TIPO_EMISION = ''N''
							AND @p_Legal = ''L''
						)
					)
			/*Obtengo nombre del producto*/
			INNER JOIN dbo.PRODUCTOS  AS Pr with (nolock) ON
				Pr.TZ_LOCK = 0
				AND s.PRODUCTO = Pr.C6250
				AND Pr.C6250 = E.PRODUCTO
			/*Obtengo nombre sucursal*/
			INNER JOIN dbo.SUCURSALES  AS n WITH  (nolock) ON
				n.SUCURSAL=s.SUCURSAL
				AND ((n.TZ_LOCK < 300000000000000 OR n.TZ_LOCK >= 400000000000000 )
					AND (n.TZ_LOCK < 100000000000000 OR n.TZ_LOCK >= 200000000000000 )
				)
			/*Obtengo nombre Moneda*/
			INNER JOIN dbo.MONEDAS AS m WITH  (nolock) ON
				m.C6399 =s.MONEDA
				AND ((m.TZ_LOCK < 300000000000000 OR m.TZ_LOCK >= 400000000000000)
					AND (m.TZ_LOCK < 100000000000000 OR m.TZ_LOCK >= 200000000000000)
				)
			/*Obtengo CBU*/	
			LEFT JOIN  VTA_SALDOS AS v WITH (nolock) ON
				v.JTS_OID_SALDO =s.JTS_OID
				AND v.TZ_LOCK=0
			ORDER BY
				s.C1803,
				s.SUCURSAL,
				s.PRODUCTO,
				s.CUENTA,
				s.MONEDA,
				s.OPERACION
	
	END TRY
	       
	BEGIN CATCH
	
	SET @p_ret_proceso = ERROR_NUMBER()
	SET @p_msg_proceso = ''Error al obtener registros del saldo'' + ERROR_MESSAGE()
	
	EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
		@p_id_proceso = @p_id_proceso,
		@p_fch_proceso = @p_dt_proceso,
		@p_nom_package = ''ESTADOCUENTA'',
		@p_cod_error = @p_ret_proceso,
		@p_msg_error = @p_msg_proceso,
		@p_tipo_error = @c_log_tipo_informacion
	
	END CATCH
	
    /*SET @jts_oid = (SELECT s.JTSOID FROM @TMPSaldos s)
    PRINT @jts_oid	*/
    
    BEGIN TRY
	
		-- Cargo tabla temporal de datos del titular
		INSERT INTO @TMPDatosTitular
		SELECT
			s.Cliente AS Cliente,
			cp.NUMEROPERSONA AS NroPersona,
			cp.TIPOPERSONA AS TipoPersona,
			cp.NUMERODOC AS DocTitular,
			cp.NOMBRE AS NomTitular,
			c.TIPO AS TipoCliente,
			c.NOMBRECLIENTE AS nomcli,
			(CASE WHEN cp.TIPOPERSONA=''F'' THEN ''PF'' ELSE ''PJ'' END) AS Formato,
			s.TipoDireccion AS TipoDireccion,
			s.JTSOID
		FROM @TMPSaldos AS s
		INNER JOIN VW_CLIENTES_PERSONAS cp with (nolock) ON
			cp.CODIGOCLIENTE=s.Cliente
		INNER JOIN CLI_CLIENTES c with (nolock) ON
			c.CODIGOCLIENTE=s.Cliente
		WHERE
			cp.TITULARIDAD = ''T''
			AND ((c.TZ_LOCK < 300000000000000 OR c.TZ_LOCK >= 400000000000000)
				AND (c.TZ_LOCK < 100000000000000 OR c.TZ_LOCK >= 200000000000000)
			)
	
	END TRY
	
	BEGIN CATCH
		
		SET @p_ret_proceso = ERROR_NUMBER()
		SET @p_msg_proceso = ''Error al obtener los datos del titular '' + ERROR_MESSAGE()
		
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
			@p_id_proceso = @p_id_proceso,
			@p_fch_proceso = @p_dt_proceso,
			@p_nom_package = ''ESTADOCUENTA'',
			@p_cod_error = @p_ret_proceso,
			@p_msg_error = @p_msg_proceso,
			@p_tipo_error = @c_log_tipo_informacion
	
	END CATCH
	
	/*SET @datoclientehelp = (SELECT s.Cliente FROM @TMPDatosTitular s)
	PRINT @datoclientehelp   */
	
	-- Cargo tabla temporal de direcciones del titular
	/* Obtiene datos para cabezal con dirección del cliente*/
	BEGIN TRY
	
		INSERT INTO @TMPDireccionTitular
		SELECT
			t.Cliente AS Cliente,
			d.CALLE AS Calle,
			d.NUMERO AS NumeroPuerta,
			d.APARTAMENTO AS Apartamento,
			d.PISO AS Piso,
			(	SELECT DESCRIPCION_DIM3
				FROM CLI_LOCALIDADES with (nolock)
				WHERE
					CODIGOPAIS = d.PAIS
					AND DIM1 = d.PROVINCIA
					AND DIM2 = d.DEPARTAMENTO 
					AND DIM3 = d.LOCALIDAD
			) AS CiudadLocalidad,
			(	SELECT DESCRIPCION
				FROM CLI_PROVINCIAS with (nolock)
				WHERE
					DIM1 = d.PROVINCIA
			) AS Provincia,
			d.PAIS AS CodigoPais,
			d.CPA_NUEVO AS CodigoPostal,
			d.BARRIO AS Barrio,
			t.JTSOID
		FROM dbo.CLI_DIRECCIONES d with (nolock)
		INNER JOIN @TMPDatosTitular t ON
			t.NroPersona=d.ID
			AND t.TipoDireccion = d.TIPODIRECCION
			AND t.Formato=d.FORMATO
		WHERE
			d.ORDINAL_DIR = (	SELECT MIN(DIR.ORDINAL_DIR)
								FROM CLI_DIRECCIONES DIR with (nolock)
								INNER JOIN @TMPDatosTitular dt ON
									dt.NroPersona=DIR.ID
									AND dt.TipoDireccion = DIR.TIPODIRECCION
									AND dt.Formato=DIR.FORMATO
							)
			AND ((d.TZ_LOCK < 300000000000000 OR d.TZ_LOCK >= 400000000000000)
				AND (d.TZ_LOCK < 100000000000000 OR d.TZ_LOCK >= 200000000000000)
			)
	
	END TRY
	
	BEGIN CATCH
	
		SET @p_ret_proceso = ERROR_NUMBER()
		SET @p_msg_proceso = ''Error al obtener la dirección del titular '' + ERROR_MESSAGE()
		
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
			@p_id_proceso = @p_id_proceso,
			@p_fch_proceso = @p_dt_proceso,
			@p_nom_package = ''ESTADOCUENTA'',
			@p_cod_error = @p_ret_proceso,
			@p_msg_error = @p_msg_proceso,
			@p_tipo_error = @c_log_tipo_informacion
	
	END CATCH
	
	/*SET @localidad = (SELECT s.CiudadLocalidad FROM @TMPDireccionTitular s)
	PRINT  @localidad*/
	
	/* Obtiene datos de las personas que integran el cliente */
	BEGIN TRY
	
  INSERT INTO @TMPIntegrantesCliente		
	    SELECT
			s.Cliente AS Cliente,
			count(*) AS CantTitulares,
			(CASE
				WHEN (count(*) = 2)
					THEN (
						SELECT TOP 1 NUMERODOC
					 	FROM VW_CLIENTES_PERSONAS cp with (nolock)
					 	--INNER JOIN @TMPSaldos s ON 
					 		--s.Cliente=cp.CODIGOCLIENTE
						WHERE TITULARIDAD != ''T''
						AND cp.CODIGOCLIENTE = s.Cliente
					)
				WHEN (count(*) > 2)
					THEN (
						SELECT TOP 1 NUMERODOC
						FROM VW_CLIENTES_PERSONAS cp with (nolock)
						--INNER JOIN @TMPSaldos s ON
							--s.Cliente=cp.CODIGOCLIENTE
						WHERE TITULARIDAD != ''T''
						AND cp.CODIGOCLIENTE = s.Cliente
						ORDER BY NUMEROPERSONA
					)
			END) AS DocTitular2,
			(CASE
				WHEN (count(*) = 2)
					THEN (
						SELECT TOP 1 NOMBRE
						FROM VW_CLIENTES_PERSONAS cp with (nolock)
						--INNER JOIN @TMPSaldos s ON 
							--s.Cliente=cp.CODIGOCLIENTE 
						WHERE TITULARIDAD != ''T''
						AND cp.CODIGOCLIENTE = s.Cliente
					)
				WHEN (count(*) > 2)
					THEN (
						SELECT TOP 1 NOMBRE
						FROM VW_CLIENTES_PERSONAS cp with (nolock)
						--INNER JOIN @TMPSaldos s ON 
							--s.Cliente=cp.CODIGOCLIENTE 
						WHERE TITULARIDAD != ''T''
						AND cp.CODIGOCLIENTE = s.Cliente
						ORDER BY NUMEROPERSONA
					)	   
			END) AS NomTitular2,
			(CASE 
				WHEN (count(*) > 2) 
					THEN (
						SELECT TOP 1 NUMERODOC 
						FROM VW_CLIENTES_PERSONAS with (nolock)
						WHERE 
							NUMEROPERSONA IN (
								SELECT TOP 2 NUMEROPERSONA
								FROM VW_CLIENTES_PERSONAS cp with (nolock)
								--INNER JOIN @TMPSaldos s ON 
									--s.Cliente=cp.CODIGOCLIENTE 
								WHERE TITULARIDAD != ''T''
								AND cp.CODIGOCLIENTE = s.Cliente
								ORDER BY NUMEROPERSONA DESC
							)
						ORDER BY NUMEROPERSONA DESC
					)
			END) AS DocTitular3,
			(CASE 
				WHEN (count(*) > 2) 
					THEN (
						SELECT TOP 1 NOMBRE 
						FROM VW_CLIENTES_PERSONAS with (nolock)
						WHERE 
							NUMEROPERSONA IN (
								SELECT TOP 2 NUMEROPERSONA
								FROM VW_CLIENTES_PERSONAS cp with (nolock)
								--INNER JOIN @TMPSaldos s ON 
									--s.Cliente=cp.CODIGOCLIENTE 
								WHERE TITULARIDAD != ''T''
								AND cp.CODIGOCLIENTE = s.Cliente
								ORDER BY NUMEROPERSONA DESC
							)
						ORDER BY NUMEROPERSONA DESC)
			END) AS NomTitular3,
			s.JTSOID
		FROM VW_CLIENTES_PERSONAS cp with (nolock)
		INNER JOIN @TMPSaldos s ON
			s.Cliente=cp.CODIGOCLIENTE
		GROUP BY s.Cliente, s.JTSOID
	
	END TRY
	
	BEGIN CATCH
	
		SET @p_ret_proceso = ERROR_NUMBER()
		SET @p_msg_proceso = ''Error al obtener los integrantes del cliente'' + ERROR_MESSAGE()
		
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
			@p_id_proceso = @p_id_proceso,
			@p_fch_proceso = @p_dt_proceso,
			@p_nom_package = ''ESTADOCUENTA'',
			@p_cod_error = @p_ret_proceso,
			@p_msg_error = @p_msg_proceso,
			@p_tipo_error = @c_log_tipo_informacion
	
	END CATCH
	
	BEGIN
	   	/******************* Definición y asignación de valores a las variables que luego trabajaremos con las tablas temporales********************/
		
		/*
		*    Variables para parametos inicializados
		*/
		
		DECLARE
		@vFechaIni datetime,
		@vFechaFin datetime,
		@vFechaIniAnt datetime,
		@vFechaProc datetime,
		@vFechaProxProc datetime,
		@vPeriodo char(1),
		@vLegal char(1),
		
		@vIdDet numeric(12),
		
		/* Aux*/
		@vFechaAux datetime,
		@vDia float(53),
		@vMes float(53),
		@vAnio float(53),
		@vDiaProx float(53),
		@vMesProx float(53),
		@vAnioProx float(53),
		
		/* Excepciones*/
		@periodo_invalido$exception nvarchar(1000)
	
		BEGIN TRY
			IF @p_FechaIni = ''18000101''
				SET @p_FechaIni = NULL
			IF @p_FechaFin = ''18000101''
				SET @p_FechaFin = NULL
			IF @p_JTSOID = 0
				SET @p_JTSOID = NULL
				SET @periodo_invalido$exception = ''Estado de Cuenta - Periodo Invalido''
			DECLARE
				@vDescErrorAdic varchar(100)
			/*
			*   --------------Programa Principal-----------------------
			*    Valida parametros
			*/
			SET @vDescErrorAdic = NULL
			SET @vIdDet = 0
			SET @vPeriodo = upper(@p_Periodo)
			
			/*Z diario diferido para los diarios*/
			IF @vPeriodo NOT IN (
					''M'',
					''P'',
					''J'',
					''S'',
					''E'',
					''Q'',
					''T'',
					''A'',
					''Z'',
					''C''
				) 
				OR @vPeriodo IS NULL
				BEGIN
					SET @vDescErrorAdic = ''El parametro Periodicidad ingresado es invalido''
					RAISERROR(59999, 16, 1, @periodo_invalido$exception)
				END
			/* Normaliza Legal*/
			SET @vLegal = @p_Legal
			
			IF (@vLegal <> ''L'' AND @vLegal <> ''D'') OR @vLegal IS NULL
				SET @vLegal = '' ''
			
			IF @vPeriodo = ''J'' AND @vLegal = ''D''
				BEGIN
					SET @vFechaProc = @p_fechaini
					SET @vFechaProxProc = DATEADD(D, 1, @p_fechaini)
					SET @vLegal = '' ''
				END
			ELSE 
				BEGIN
					/* Obtiene fechas de proceso*/
					SELECT 
						@vFechaProc = PARAMETROS.FECHAPROCESO, 
						@vFechaProxProc = PARAMETROS.FECHAPROXIMOPROCESO
					FROM dbo.PARAMETROS with (nolock)
					--EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
				END
			/*
			*   vfechaproc:=''1-sep-2011'';
			*   vfechaproxProc:=''2-sep-2011'';
			*/
			SET @vAnio = datepart(YEAR, @vFechaProc)
			SET @vMes = datepart(MONTH, @vFechaProc)
			SET @vDia = datepart(DAY, @vFechaProc)
			SET @vAnioProx = datepart(YEAR, @vFechaProxProc)
			SET @vMesProx = datepart(MONTH, @vFechaProxProc)
			SET @vDiaProx = datepart(DAY, @vFechaProxProc)
			/* Periodo=M(Mensual)*/
			IF @vPeriodo = ''M''
				IF @vMes = @vMesProx
					BEGIN
						SET @vFechaAux = dateadd(m, -1, @vFechaProc)
						SET @vFechaIni = CONVERT(datetime, ''01/'' + ISNULL(CAST(datepart(MONTH, @vFechaAux) AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@vFechaAux  )+1, 0))
					END
				ELSE 
					BEGIN
						SET @vFechaIni = CONVERT(datetime, ''01/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@vFechaAux  )+1, 0))
					END
			/* Periodo=P(Periodo definido por usuario): Inicializa FECHAS parametro en caso de que vengan nulas (principio mes a fecha proceso)*/
			IF @vPeriodo = ''P''
				BEGIN
					IF @p_FechaIni IS NULL
						SET @vFechaIni = CONVERT(datetime2, ''01/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
					ELSE 
						SET @vFechaIni = @p_FechaIni
					
					IF @p_FechaFin IS NULL
						SET @vFechaFin = @vFechaProc
					ELSE 
						SET @vFechaFin = @p_FechaFin
				END
			/* Periodo=J (Dia actual)*/
			IF @vPeriodo = ''J''
				BEGIN
					SET @vFechaIni = @vFechaProc
					SET @vFechaFin = @vFechaProc
				END
			/* Periodo=S (Semanal)*/
			IF @vPeriodo = ''S''
				BEGIN
					SET @vFechaAux = dateadd(m, -1, @vFechaProc)
					IF @vDiaProx <= 7
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''22/'' + ISNULL(CAST(datepart(MONTH, @vFechaAux) AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@vFechaAux)+1, 0))
						END
					ELSE IF @vDiaProx BETWEEN 8 AND 14
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''01/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = CONVERT(datetime2, ''07/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						END
					ELSE IF @vDiaProx BETWEEN 15 AND 21
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''08/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = CONVERT(datetime2, ''14/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						END
					ELSE IF @vDiaProx >= 22 OR (@vMes < @vMesProx)
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''15/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = CONVERT(datetime2, ''21/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						END
				END
			/* Periodo=E (Decaderial)*/
			IF @vPeriodo = ''E''
				BEGIN
					SET @vFechaAux = dateadd(m, -1, @vFechaProc)
					IF @vDiaProx <= 10
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''21/'' + ISNULL(CAST(datepart(MONTH, @vFechaAux) AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@vFechaAux)+1, 0))
						END
					ELSE IF @vDiaProx BETWEEN 11 AND 20
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''01/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = CONVERT(datetime2, ''10/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						END
					ELSE IF @vDia >= 21 OR (@vMes < @vMesProx)
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''11/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = CONVERT(datetime2, ''20/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						END
				END
			/* Periodo=Q (Quincenal)*/
			IF @vPeriodo = ''Q''
				BEGIN
					SET @vFechaAux = dateadd(m, -1, @vFechaProc)
					IF @vDiaProx <= 15
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''16/'' + ISNULL(CAST(datepart(MONTH, @vFechaAux) AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@vFechaAux)+1, 0))
						END
					ELSE IF @vDiaProx >= 16 OR (@vMes < @vMesProx)
						BEGIN
							SET @vFechaIni = CONVERT(datetime2, ''01/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
							SET @vFechaFin = CONVERT(datetime2, ''15/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						END
				END
			/* Periodo=T (Trimestral)*/
			IF @vPeriodo = ''T''
				IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''31/03''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
					BEGIN
						SET @vFechaAux = dateadd(m, -12, @vFechaProc)
						SET @vFechaIni = CONVERT(datetime2, ''01/10/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''31/12/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
					END
				ELSE IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/04/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''30/06''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
					BEGIN
						SET @vFechaIni = CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''31/03/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					END
				ELSE IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/07/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''30/09''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
					BEGIN
						SET @vFechaIni = CONVERT(datetime2, ''01/04/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''30/06/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					END
				ELSE IF @vFechaProxProc >= CONVERT(datetime2, ''01/10/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					BEGIN
						SET @vFechaIni = CONVERT(datetime2, ''01/07/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''30/09/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					END
			/* Periodo=C (Cuatrimestral)*/
			IF @vPeriodo = ''C''
				IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''30/04''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
					BEGIN
						SET @vFechaAux = dateadd(m, -12, @vFechaProc)
						SET @vFechaIni = CONVERT(datetime2, ''01/09/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''31/12/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
					END
				ELSE IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/05/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''31/08''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
					BEGIN
						SET @vFechaIni = CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''30/04/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					END
				ELSE IF @vFechaProxProc >= CONVERT(datetime2, ''01/09/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					BEGIN
						SET @vFechaIni = CONVERT(datetime2, ''01/05/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''31/08/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					END
			/* Periodo=Z (Semestral)*/
			IF @vPeriodo = ''Z''
				IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''30/06''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
					BEGIN
						SET @vFechaAux = dateadd(m, -12, @vFechaProc)
						SET @vFechaIni = CONVERT(datetime2, ''01/07/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''31/12/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
					END
				ELSE IF @vFechaProxProc >= CONVERT(datetime2, ''01/07/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					BEGIN
						SET @vFechaIni = CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''30/06/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
					END
			/* Periodo=A (Anual)*/
			IF @vPeriodo = ''A''
				IF @vAnio = datepart(YEAR, @vFechaProxProc)
					BEGIN
						SET @vFechaAux = dateadd(m, -12, @vFechaProc)
						SET @vFechaIni = CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''31/12/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
					END
				ELSE
					BEGIN
						SET @vFechaIni = CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
						SET @vFechaFin = CONVERT(datetime2, ''31/12/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
					END
				
				SET @vFechaIniAnt = DATEADD(D, -1, @vFechaIni)
			
			/* Inicializa tablas de estado cuenta (borrando solo los registros para la perioicidad que va a generar)*/
			IF @p_JTSOID IS NULL
				BEGIN
					DELETE dbo.GRL_DET_ENVIO_ESTCTA
					WHERE --GRL_DET_ENVIO_ESTCTA.LEGAL = @vLegal AND
						 GRL_DET_ENVIO_ESTCTA.PERIODO = @vPeriodo
					
					DELETE dbo.GRL_CAB_ENVIO_ESTCTA
					WHERE --GRL_CAB_ENVIO_ESTCTA.LEGAL = @vLegal AND
						 GRL_CAB_ENVIO_ESTCTA.PERIODO = @vPeriodo
				END
			ELSE
				BEGIN
					DELETE dbo.GRL_DET_ENVIO_ESTCTA
					WHERE --GRL_DET_ENVIO_ESTCTA.LEGAL = @vLegal AND
						 GRL_DET_ENVIO_ESTCTA.PERIODO = @vPeriodo
						AND GRL_DET_ENVIO_ESTCTA.JTSOID = @p_JTSOID
					
					DELETE dbo.GRL_CAB_ENVIO_ESTCTA
					WHERE --GRL_CAB_ENVIO_ESTCTA.LEGAL = @vLegal AND
						 GRL_CAB_ENVIO_ESTCTA.PERIODO = @vPeriodo
						AND GRL_CAB_ENVIO_ESTCTA.JTSOID = @p_JTSOID
				END
		
		END TRY
		
		BEGIN CATCH
		
			SET @p_ret_proceso = ERROR_NUMBER()
			SET @p_msg_proceso = ''Error al actualizar registros iniciales '' + ERROR_MESSAGE()
			
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
				@p_id_proceso = @p_id_proceso,
				@p_fch_proceso = @p_dt_proceso,
				@p_nom_package = ''ESTADOCUENTA'',
				@p_cod_error = @p_ret_proceso,
				@p_msg_error = @p_msg_proceso,
				@p_tipo_error = @c_log_tipo_informacion
		
		END CATCH
		
		-- Cargo tabla temporal de saldos diarios Inicial
		/*Obtiene saldo diario del dia anterior al dia desde (saldo anterior a la fecha comienzo)*/
		BEGIN TRY
			
			INSERT INTO @TMPSaldosDiarios
			SELECT
				sd.SALDOS_JTS_OID AS JTSOID,
				sd.SALDO_AL_CORTE AS SalDiaIni,
				sd.TASAINTERESPAGO AS TeaCobro,
				sd.TASAINTERESCOBRO AS TeaPago,
				/* Valor absoluto del saldo ini*/
				sd.PROMEDIO_DIARIO AS Promedio,
				sd.CUPO_SOBREGIRO AS CuposobregiroDiario,
				abs(sd.SALDO_AL_CORTE) AS SaldoCalcLineaABS,
				ISNULL(sd.SALDO_AL_CORTE,0) AS SaldoCalcLinea,
				0 AS SaldoINI,
				0 AS SaldoFin,
				0 AS SalDiaFin,
				0 AS TeapagoSD,
				0 AS TeacobroSD
			FROM dbo.GRL_SALDOS_DIARIOS AS sd with (nolock)
			INNER JOIN @TMPSaldos s ON
				s.JTSOID=sd.SALDOS_JTS_OID
			WHERE
				sd.FECHA = @vFechaIniAnt AND
				sd.TZ_LOCK = 0
		
		END TRY
		
		BEGIN CATCH
		
			SET @p_ret_proceso = ERROR_NUMBER()
			SET @p_msg_proceso = ''Error al obtener saldo diario inicial '' + ERROR_MESSAGE()
			
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
				@p_id_proceso = @p_id_proceso,
				@p_fch_proceso = @p_dt_proceso,
				@p_nom_package = ''ESTADOCUENTA'',
				@p_cod_error = @p_ret_proceso,
				@p_msg_error = @p_msg_proceso,
				@p_tipo_error = @c_log_tipo_informacion
		
		END CATCH
	
	END
	
	BEGIN
	
		BEGIN TRY
		
			/*
			*    Normaliza Periodicidad y Canal (esto se puede agragar al cusor pivote para ganar performance pero queda muy compleja la consulta y por ahora no vale la pena)
			*       IF vLegal = ''L'' THEN
			*             vPeriodicidad:=vPeriodProd;
			*           ELSE 
			*  vPeriodicidad:=vPeriodEC;
			*           END IF;
			*
			*    MC 01-10-2010
			*/
			UPDATE @TMPSaldos
			SET
				Periodicidad = (case when PeriodEC IN ( '' '', ''M'' ) then ''C'' else ''P'' end),
				Canal = (case when Correo  <> ''N'' AND Correo <> ''E'' then ''S'' end)
		
		END TRY
		
		BEGIN CATCH
		
			SET @p_ret_proceso = ERROR_NUMBER()
			SET @p_msg_proceso = ''Error al actualizar Periodicidad y Canal '' + ERROR_MESSAGE()
			
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
				@p_id_proceso = @p_id_proceso,
				@p_fch_proceso = @p_dt_proceso,
				@p_nom_package = ''ESTADOCUENTA'',
				@p_cod_error = @p_ret_proceso,
				@p_msg_error = @p_msg_proceso,
				@p_tipo_error = @c_log_tipo_informacion
		
		END CATCH
	
	END
	
	/*Obtengo Saldo al día anterior de inicio*/
	
	BEGIN
	
		BEGIN TRY
		
			UPDATE sd
			SET sd.SaldoINI = g.SALDO_AL_CORTE
			FROM @TMPSaldosDiarios sd
			LEFT JOIN GRL_SALDOS_DIARIOS g WITH (nolock) ON
				g.SALDOS_JTS_OID = sd.JTSOID
				AND g.TZ_LOCK = 0
				AND g.FECHA = DATEADD(DAY,-1,@vFechaIni)
		
		END TRY
		
		BEGIN CATCH
		
			SET @p_ret_proceso = ERROR_NUMBER()
			SET @p_msg_proceso = ''Error al obtener el saldo del día anterior '' + ERROR_MESSAGE()
			
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
				@p_id_proceso = @p_id_proceso,
				@p_fch_proceso = @p_dt_proceso,
				@p_nom_package = ''ESTADOCUENTA'',
				@p_cod_error = @p_ret_proceso,
				@p_msg_error = @p_msg_proceso,
				@p_tipo_error = @c_log_tipo_informacion
		
		END CATCH
	
	END
	
	BEGIN TRY
	
		INSERT INTO dbo.GRL_CAB_ENVIO_ESTCTA(
			LEGAL,
			PERIODO,
			IDCAB,
			CODIGOCLIENTE,
			TIPODIRECCION,
			FECHADESDE,
			FECHAHASTA,
			CUENTA,
			TIPOPRODUCTO,
			TIPOCUENTA,
			MONEDA,
			RESUMENEN,
			CBU,
			SALDOINI,
			SUCURSAL,
			NOMBRESUCURSAL,
			JTSOID,
			NOMBRECLIENTE,
			CALLE,
			NUMPUERTA,
			APARTAMENTO,
			PISO,
			CIUDADLOCALIDAD,
			CODIGOPAIS,
			CODIGOPOSTAL,
			FECHAEMISION,
			BARRIO,
			CANTTITULARES,
			NOMBRETIT,
			DOCUMENTOTIT,
			NOMBRETIT2,
			DOCUMENTOTIT2,
			NOMBRETIT3,
			DOCUMENTOTIT3,
			CUITCUIL,
			PROVINCIA)
		(SELECT
			@vLegal,
			@vPeriodo,
			s.IdCab,
			s.Cliente,
			t.TipoDireccion,
			@vFechaIni,
			@vFechaFin,
			s.Cuenta,
			s.TipoProd,
			s.NombreProducto,
			s.MonedaCAB,
			s.ResumenEn,
			s.CBU,
			ISNULL(sd.SalDiaIni,0),
			s.Sucursal,
			s.NombreSucursal,
			s.JTSOID,
			t.NomCli,
			d.Calle,
			d.NumeroPuerta,
			d.Apartamento,
			d.Piso,
			d.CiudadLocalidad,
			d.CodigoPais,
			d.CodigoPostal,
			@vFechaProc,
			d.Barrio,
			i.CantTitulares,
			t.NomTitular,
			t.DocTitular,
			i.NomTitular2,
			i.DocTitular2,
			i.NomTitular3,
			i.DocTitular3,
			t.DocTitular,
			d.Provincia
		FROM @TMPSaldos s
		LEFT JOIN @TMPDatosTitular t ON
			t.Cliente=s.Cliente
			AND t.JTSOID = s.JTSOID
		LEFT JOIN @TMPDireccionTitular d ON
			d.Cliente=s.Cliente
			AND d.JTSOID = s.JTSOID
		LEFT JOIN @TMPSaldosDiarios sd ON
			sd.JTSOID=s.JTSOID
		LEFT JOIN @TMPIntegrantesCliente i ON
			i.Cliente=s.Cliente
			AND i.JTSOID = s.JTSOID
		)
	
	END TRY
	
	BEGIN CATCH
	
		SET @p_ret_proceso = ERROR_NUMBER()
		SET @p_msg_proceso = ''Error al grabar cabezal'' + ERROR_MESSAGE()
		
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
			@p_id_proceso = @p_id_proceso,
			@p_fch_proceso = @p_dt_proceso,
			@p_nom_package = ''ESTADOCUENTA'',
			@p_cod_error = @p_ret_proceso,
			@p_msg_error = @p_msg_proceso,
			@p_tipo_error = @c_log_tipo_informacion
	
	END CATCH
	
	/* MOV ''I''*/
	SET @vIdDet = @vIdDet + 1
	BEGIN TRY
	
		INSERT into dbo.GRL_DET_ENVIO_ESTCTA(
			LEGAL,
			PERIODO,
			IDCAB,
			IDDET,
			SUCURSAL,
			TIPOPRODUCTO,
			PRODUCTO,
			CUENTA,
			MONEDA,
			OPERACION,
			ORDINAL,
			PERIODICIDAD,
			CANAL,
			TIPOMOV,
			FECHAMOV,
			CONCEPTO,
			SUCURSALORIGEN,
			ASIENTO,
			FECHAVALOR,
			IMPORTEDEBITO,
			IMPORTECREDITO,
			SALDOCALCLINEA,
			REFERENCIA,
			IMPORTESPENDIENTES,
			TASASRENOVACION,
			PLAZORENOVACION,
			CANTIDADCREDITOS,
			CANTIDADDEBITOS,
			PROMEDIO,
			SALDOACTUAL,
			TRANSFERENCIA,
			GARANTIA,
			DISPONIBLE,
			TEAPAGO,
			TEACOBRO,
			JTSOID)
		(SELECT
			@vLegal,
			@vPeriodo,
			s.IdCab,
			@vIdDet,
			s.Sucursal,
			s.TipoProd,
			s.Prod,
			s.Cuenta,
			s.Moneda,
			s.Operacion,
			s.Ordinal,
			s.Periodicidad,
			s.Canal,
			''I'',
			@vFechaIni,
			''Saldo Inicial'',
			s.Sucursal,
			0,
			NULL,
			0,
			0,
			ISNULL(sd.SalDiaIni,0),
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			s.JTSOID
		FROM @TMPSaldos s
		INNER JOIN @TMPDatosTitular t ON
			t.Cliente=s.Cliente
			AND t.JTSOID = s.JTSOID
		LEFT JOIN @TMPSaldosDiarios sd ON
			sd.JTSOID=s.JTSOID
		)
	
	END TRY
	
	BEGIN CATCH
		SET @p_ret_proceso = ERROR_NUMBER()
		SET @p_msg_proceso = ''Error al grabar detalle'' + ERROR_MESSAGE()
		
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
			@p_id_proceso = @p_id_proceso,
			@p_fch_proceso = @p_dt_proceso,
			@p_nom_package = ''ESTADOCUENTA'',
			@p_cod_error = @p_ret_proceso,
			@p_msg_error = @p_msg_proceso,
			@p_tipo_error = @c_log_tipo_informacion
	END CATCH
	
	/* Graba MOVs M obteniendo los datos de los movimientos dependiendo del tipo de producto*/
	INSERT INTO @TMPMovimientosContables (
		FechaProcesado,
		SignoMov,
		SignoSal,
		Monto,
		RegistroxJTS,
		JTSOID)
	SELECT
		@vFechaIniAnt,
		s.SignoSal,
		s.SignoSal,
		sd.SalDiaIni,
		0,
		sd.JTSOID
	FROM @TMPSaldosDiarios sd
	INNER JOIN @TMPSaldos s ON
		s.JTSOID = sd.JTSOID
	
	INSERT INTO @TMPMovimientosContables
	SELECT
		(CASE
			WHEN M.MARCAAJUSTE = ''A''
				THEN M.FECHAVALOR
			ELSE M.FECHAPROCESO
		END) AS FechaRealMov,
		CONVERT(VARCHAR(8),A.HORAFIN, 108) AS HoraMov,
		M.FECHAPROCESO AS FechaProcesado,
		M.CONCEPTO AS Concepto,
		M.SUCURSAL AS SucursalOrigen,
		M.ASIENTO AS Asiento,
		M.FECHAVALOR AS FechaValor,
		M.DEBITOCREDITO AS SignoMov,
		M.TIPO AS TipoMov,
		M.CAPITALREALIZADO AS Monto,
		/* Referencia (antes sacaba referencia de hist vista(tprod 2 y 3), ahora es el asiento del movtoctable en todos los casos)*/
		(CASE
			WHEN (M.REFERENCIA IS NULL OR M.REFERENCIA=0)
				THEN M.ASIENTO
			ELSE
				M.REFERENCIA
		END) AS Referencia,
		M.OPERACION AS OperacionTopaz,
		M.COD_TRANSACCION AS CodTransaccion,
		s.JTSOID AS JTSOID,
		ISNULL((CASE 
					WHEN (M.CAPITALREALIZADO<>0 AND M.DEBITOCREDITO = ''D'')
						THEN M.CAPITALREALIZADO
				END)
			, 0
		) AS ImporteD,
		ISNULL((CASE
					WHEN (M.CAPITALREALIZADO<>0 AND M.DEBITOCREDITO = ''C'')
						THEN M.CAPITALREALIZADO
				END)
			, 0
		) AS ImporteC,
		/*Obtengo detalle transacción y si corresponde info extendida*/
		ISNULL((CASE
					WHEN (M.COD_TRANSACCION IS NOT NULL OR M.COD_TRANSACCION <> 0)
						THEN (
							SELECT DESCRIPCION
							FROM TTR_CODIGO_TRANSACCION_DEF WITH (NOLOCK)
							WHERE
								((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000)
									AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)
								)
								AND CODIGO_TRANSACCION = M.COD_TRANSACCION
						)
					WHEN (M.COD_TRANSACCION IS NOT NULL OR M.COD_TRANSACCION = 0)
						THEN M.CONCEPTO
				END),
			m.CONCEPTO
		) AS DetalleTr,
		/* INFO EXTENDIDA */
		(CASE
			WHEN (M.COD_TRANSACCION IS NOT NULL OR M.COD_TRANSACCION <> 0)
				THEN (
					SELECT INFO_EXTENDIDA
					FROM TTR_CODIGO_TRANSACCION_DEF WITH (NOLOCK)
					WHERE
						((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000)
							AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)
						)
						AND CODIGO_TRANSACCION = M.COD_TRANSACCION)
		END) AS InfoExtendida,
		NULL AS LineaInfo,
		S.Cuenta AS Cuenta,
		0 AS SaldoCalcLineaAux,
		isnull((CASE
					WHEN (
						m.Cod_Transaccion IN (
							SELECT CODIGO_TRANSACCION
							FROM CI_CARGOS WITH (NOLOCK)
							WHERE TIPO_CARGO_IMPOSITIVO = 6
						)
						OR m.Cod_Transaccion IN (
							SELECT CODIGO_TRANSACCION
							FROM CI_IMPUESTOS WITH (NOLOCK)
							WHERE TIPO_IMPUESTO = 6)
					)
					THEN
						CASE
							WHEN C6403 = ''I''
								THEN (M.CAPITALREALIZADO * HTC.TIPO_CAMBIO_VENTA)
							WHEN C6403 = ''N''
								THEN M.CAPITALREALIZADO
							ELSE
								(M.CAPITALREALIZADO * COT.TC_VENTA)
						END
				END)
			, 0
		) AS CREDEBAux,
		isnull((CASE
					WHEN (
						m.Cod_Transaccion IN (
							SELECT CODIGO_TRANSACCION
							FROM CI_CARGOS WITH (NOLOCK)
							WHERE TIPO_CARGO_IMPOSITIVO = 5
						) 
						OR m.Cod_Transaccion IN (
							SELECT CODIGO_TRANSACCION 
							FROM CI_IMPUESTOS WITH (NOLOCK)
							WHERE TIPO_IMPUESTO = 5
						)
					)
					THEN
						CASE
							WHEN C6403 = ''I''
								THEN (M.CAPITALREALIZADO * HTC.TIPO_CAMBIO_VENTA)
							WHEN C6403 = ''N''
								THEN M.CAPITALREALIZADO
							ELSE
								(M.CAPITALREALIZADO * COT.TC_VENTA)
						END
				END)
			, 0
		) AS SIRCREBAux,
		isnull((CASE
					WHEN (
						m.Cod_Transaccion IN (
							SELECT CODIGO_TRANSACCION
							FROM CI_CARGOS WITH (NOLOCK)
							WHERE TIPO_CARGO_IMPOSITIVO = 9
						) 
						OR m.Cod_Transaccion IN (
							SELECT CODIGO_TRANSACCION 
							FROM CI_IMPUESTOS WITH (NOLOCK)
							WHERE TIPO_IMPUESTO = 9
						)
					)
					THEN
						CASE
							WHEN C6403 = ''I''
								THEN (M.CAPITALREALIZADO * HTC.TIPO_CAMBIO_VENTA)
							WHEN C6403 = ''N''
								THEN M.CAPITALREALIZADO
							ELSE
								(M.CAPITALREALIZADO * COT.TC_VENTA)
						END
				END)
			, 0
		) AS IIBB_CORRIENTESAux,
		s.SignoSal AS SignoSal,
		s.Cliente AS Cliente,
		/* NUMERADOR */
		DENSE_RANK() OVER (
				PARTITION BY S.JTSOID
				ORDER BY
					M.FECHAPROCESO,
					A.HORAFIN,
					M.SUCURSAL_CUENTA,
					M.MONEDA,
					M.CUENTA,
					M.PRODUCTO,
					M.OPERACION_CUENTA,
					M.ORDINAL_CUENTA,
					M.ASIENTO,
					M.JTS_OID ASC
		) AS RegistroxJTS
	FROM
		dbo.MOVIMIENTOS_CONTABLES AS M with (nolock)
	INNER JOIN @TMPSaldos AS S ON
		S.Sucursal=M.SUCURSAL_CUENTA
		AND S.Moneda = M.MONEDA
		AND S.Cuenta = M.CUENTA
		AND S.Operacion = M.OPERACION_CUENTA
		AND S.Ordinal = M.ORDINAL_CUENTA
		AND S.Rubro = M.RUBROCONTABLE
		AND S.Cliente = M.CLIENTE
	INNER JOIN dbo.ASIENTOS AS A with (nolock) ON
		M.ASIENTO = A.ASIENTO
		AND M.FECHAPROCESO = A.FECHAPROCESO
		AND M.SUCURSAL = A.SUCURSAL
		AND (CASE
				WHEN M.MARCAAJUSTE = ''A''
					THEN M.FECHAVALOR
				ELSE M.FECHAPROCESO
			END) >= @vFechaIni
		AND (CASE
				WHEN M.MARCAAJUSTE = ''A''
					THEN M.FECHAVALOR
				ELSE M.FECHAPROCESO
			END) <= @vFechaFin
		AND A.ESTADO = 77
	INNER JOIN MONEDAS AS MON WITH(nolock) ON
		MON.C6399 = M.MONEDA
	LEFT JOIN CON_COTIZACIONES_BNA AS COT WITH (nolock) ON
		COT.Moneda = M.MONEDA
		AND COT.Fecha_Cotizacion = dbo.diahabil(dateadd(DD,-1,M.FECHACONTABLE), ''D'')
		AND ((COT.TZ_LOCK < 100000000000000 OR COT.TZ_LOCK >= 200000000000000)
			AND (COT.TZ_LOCK < 300000000000000 OR COT.TZ_LOCK >= 400000000000000)
		)	
	LEFT JOIN HISTORICOTIPOSCAMBIO AS HTC WITH (nolock) ON
		HTC.MONEDA = M.MONEDA
		AND HTC.FECHA_COTIZACION = dbo.diahabil(dateadd(DD,-1,M.FECHACONTABLE), ''D'')
		AND HTC.CODIGO_TIPO_CAMBIO = (
			SELECT TOP 1 CODIGO_TIPO_CAMBIO
			FROM HISTORICOTIPOSCAMBIO WITH (nolock)
			WHERE MONEDA = HTC.MONEDA
				AND FECHA_COTIZACION = HTC.FECHA_COTIZACION
				AND ((TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)
					AND (TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000)
				)
			ORDER BY CODIGO_TIPO_CAMBIO
		)
		AND ((HTC.TZ_LOCK < 100000000000000 OR HTC.TZ_LOCK >= 200000000000000)
			AND (HTC.TZ_LOCK < 300000000000000 OR HTC.TZ_LOCK >= 400000000000000)
		)
	WHERE
		m.CAPITALREALIZADO <> 0
	ORDER BY
		FechaRealMov,
		M.FECHAPROCESO,
		A.HORAFIN,
		M.SUCURSAL_CUENTA,
		M.MONEDA,
		M.CUENTA,
		M.PRODUCTO,
		M.OPERACION_CUENTA,
		M.ORDINAL_CUENTA,
		M.ASIENTO
	
	BEGIN
		/*SET @asientomovimiento = (SELECT s.ASIENTO FROM @TMPMovimientosContables s WHERE s.RegistroxJTS=1)
		PRINT @asientomovimiento
		
		SET @contadorInfoExt = (SELECT count(*) FROM @TMPMovimientosContables s WHERE s.Infoextendida =''S'')
		PRINT @contadorInfoExt*/
		
		/* Acumula saldo según signo: Mismo signo => suma el monto, de lo contrario lo resta*/
		INSERT INTO @TMPMovimientosContablesAux
		SELECT
			m.JTSOID AS JTSOID,
			m.RegistroxJTS AS RegistroxJTS,
			SUM(a.Monto *
				CASE
					WHEN a.SignoSal = a.SignoMov
						THEN 1
					ELSE -1
				END
			) AS SaldoCalcLineaAux
		FROM @TMPMovimientosContables m
		LEFT JOIN @TMPMovimientosContables a ON
			a.JTSOID = m.JTSOID
			AND	a.RegistroxJTS <= m.RegistroxJTS
		GROUP BY
			m.RegistroxJTS,
			m.JTSOID
		ORDER BY
			m.RegistroxJTS,
			m.JTSOID
		
		UPDATE m
		SET m.SaldoCalcLineaAux = a.SaldoCalcLineaAux
		FROM @TMPMovimientosContables m
		INNER JOIN @TMPMovimientosContablesAux a ON
			a.JTSOID = m.JTSOID
			AND	a.RegistroxJTS = m.RegistroxJTS
		
		/* Acumula las cantidades y la graba en la temporal de saldos*/
		/* OBTENGO CREDEB Y SIRCREB */
		UPDATE s
		SET
			s.CantDeb = ISNULL((
							SELECT count(*)
							FROM @TMPMovimientosContables m
							WHERE
								m.Monto<>0
								AND m.SignoMov = ''D''
								AND m.JTSOID = s.JTSOID
							)
						, 0),
			s.CantCred = ISNULL((
							SELECT count(*)
							FROM @TMPMovimientosContables m
							WHERE
								m.Monto<>0 
								AND m.SignoMov = ''C''
								AND m.JTSOID = s.JTSOID
							)
						, 0),
			s.SaldoCalcLinea = ISNULL((
								SELECT TOP 1 SaldoCalcLineaAux
								FROM @TMPMovimientosContables m
								WHERE
									m.JTSOID = s.JTSOID
								ORDER BY
									m.RegistroxJTS DESC
								)
							, 0),
			/*CREDEB*/
			s.CREDEB= ISNULL((
						SELECT sum(CREDEBAux)
						FROM @TMPMovimientosContables m
						WHERE 
							m.JTSOID = s.JTSOID
						)
					,0),
			/*SIRCREB*/
			s.SIRCREB = ISNULL((
							SELECT sum(SIRCREBAux)
							FROM @TMPMovimientosContables m
							WHERE m.JTSOID = s.JTSOID
							)
						,0),
			/*IIBB_CORRIENTES*/
			s.IIBB_CORRIENTES = ISNULL((
							SELECT sum(IIBB_CORRIENTESAux)
							FROM @TMPMovimientosContables m
							WHERE m.JTSOID = s.JTSOID
							)
						,0)
		FROM @TMPSaldos s
		LEFT JOIN @TMPMovimientosContables m ON
			m.JTSOID = s.JTSOID
		
		
		/* INFO EXTENDIDA */
		INSERT INTO @TMPInfoExt
		SELECT
			m.JTSOID AS JTSOID,
			m.RegistroxJTS AS RegistroxJTS,
			m.Asiento AS Asiento,
			m.CodTransaccion AS CodTransaccion,
			m.Cliente AS Cliente,
			/* Transferencias para crédito */
			(CASE
				WHEN m.CodTransaccion IN (28,29,30,31,32,33,34) AND mc.DEBITOCREDITO=''D''
					THEN
						''Originante: '' + cp.NOMBRE +
						'' CUIT/CUIL/DNI: '' + cp.NUMERODOC +
						'' Ref.: '' + mc.CONCEPTO
				/* Transferencias para débito */
				WHEN m.CodTransaccion IN (21,22,23,24,25,26,27) AND mc.DEBITOCREDITO=''C''
					THEN
						''CUIT Destino: '' +  cp.NUMERODOC +
						'' Descripción: '' +  cp.NOMBRE +
						'' Ref.: '' + mc.CONCEPTO
				/* Plazo fijo */
				WHEN m.CodTransaccion IN (48,49,50)
					THEN
						''Suc.: '' + convert(VARCHAR(8), h.SUCURSALMOV) + '' Cert.: '' + str((SELECT ps.CERTIFICADO_DPF FROM PZO_SALDOS ps WHERE ps.JTS_OID_SALDO = (SELECT s2.JTS_OID FROM saldos s2 WHERE s2.C1665 = m.JTSOID))) + -- convert(VARCHAR(20),m.Cuenta) +
						'' Cap.: '' + convert(VARCHAR(20), h.CAPITALORIGINAL) + '' Int.: '' + convert(VARCHAR(20), h.INTALVTO)
				/* Préstamos */
				WHEN m.CodTransaccion IN (3016)
					THEN
						''Préstamo: '' + convert(VARCHAR(8), (
											SELECT OPERACION
											FROM SALDOS
											WHERE
												JTS_OID IN (
													SELECT SALDO_JTS_OID
													FROM MOVIMIENTOS_CONTABLES
													WHERE
														ASIENTO = m.Asiento
														AND SUCURSAL = m.SucursalOrigen
														AND FECHAPROCESO = m.FechaProcesado
												)
												AND C1785 = 5
											)
										) +
						'' Línea: '' + convert(VARCHAR(12),(
											SELECT PRODUCTO
											FROM SALDOS
											WHERE
												JTS_OID IN (
													SELECT SALDO_JTS_OID
													FROM MOVIMIENTOS_CONTABLES
													WHERE 
														ASIENTO = m.Asiento
														AND SUCURSAL = m.SucursalOrigen
														AND FECHAPROCESO = m.FechaProcesado
												) 
												AND C1785 = 5
											)
										) +
						'' Cuota: '' + convert(VARCHAR(20), (
											SELECT TOP 1 CUOTA
											FROM BS_PAYS_DETAIL
											WHERE
												SALDOS_JTS_OID IN (
													SELECT JTS_OID
													FROM SALDOS
													WHERE
														C1785 = 5
												)
												AND NROASIENTOMOV = m.Asiento
												AND SUCURSALMVTO = m.SucursalOrigen
												AND FECHAPROCESOMOV = m.FechaProcesado
											ORDER BY CUOTA DESC
											)
										) + 
						'' Tit.: '' + convert(VARCHAR(12), cp.NUMERODOC) + '' '' + cp.NOMBRE
			END ) AS LineaInfo
		FROM @TMPMovimientosContables m
		INNER JOIN MOVIMIENTOS_CONTABLES mc with (nolock) ON
			mc.Asiento = m.Asiento
			AND mc.SUCURSAL = m.SucursalOrigen
			AND mc.FECHAPROCESO = m.FechaProcesado
		INNER JOIN VW_CLIENTES_PERSONAS cp with (nolock) ON
			cp.CODIGOCLIENTE=mc.CLIENTE
			AND TITULARIDAD=''T''
		LEFT JOIN BS_HISTORIA_PLAZO h with (nolock) ON
			h.NROASIENTOMOV=m.Asiento
		WHERE
			m.InfoExtendida=''S''
			/*AND m.CodTransaccion IN (28,29,30,31,32,33,34, -- Crédito
									   21,22,23,24,25,26,27, -- Débito
									   48,49,50 )			 -- DPF*/
		
		UPDATE m
		SET m.LineaInfo = i.LineaInfo
		FROM @TMPMovimientosContables m
		INNER JOIN @TMPInfoExt i ON 
			i.ASIENTO=m.Asiento 
			AND m.CodTransaccion = i.CodTransaccion
        
        /*Obtengo Saldo al último día*/
        BEGIN TRY
        
        	UPDATE sd
            SET sd.SaldoFin = g.SALDO_AL_CORTE
            FROM @TMPSaldosDiarios sd
            LEFT JOIN GRL_SALDOS_DIARIOS g WITH (nolock) ON
            	g.SALDOS_JTS_OID = sd.JTSOID
            	AND g.TZ_LOCK = 0
				AND g.FECHA = @vFechaFin
		
		END TRY
		
		BEGIN CATCH
		
			SET @p_ret_proceso = ERROR_NUMBER()
			SET @p_msg_proceso = ''Error al obtener el saldo del último día'' + ERROR_MESSAGE()
			
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
				@p_id_proceso = @p_id_proceso,
				@p_fch_proceso = @p_dt_proceso,
				@p_nom_package = ''ESTADOCUENTA'',
				@p_cod_error = @p_ret_proceso,
				@p_msg_error = @p_msg_proceso,
				@p_tipo_error = @c_log_tipo_informacion
		
		END CATCH
	
	END
	
	/* Graba Movimiento M*/
	--PRINT ''LLEGA a movimiento M''
	BEGIN TRY
		INSERT dbo.GRL_DET_ENVIO_ESTCTA(
			LEGAL,
			PERIODO,
			IDCAB,
			IDDET,
			SUCURSAL,
			TIPOPRODUCTO,
			PRODUCTO,
			CUENTA,
			MONEDA,
			OPERACION,
			ORDINAL,
			PERIODICIDAD,
			CANAL,
			TIPOMOV,
			FECHAMOV,
			CONCEPTO,
			SUCURSALORIGEN,
			ASIENTO,
			FECHAVALOR,
			FECHA_REAL_MOV,
			HORA_MOV,
			IMPORTEDEBITO,
			IMPORTECREDITO,
			SALDOCALCLINEA,
			REFERENCIA,
			IMPORTESPENDIENTES,
			TASASRENOVACION,
			PLAZORENOVACION,
			CANTIDADCREDITOS,
			CANTIDADDEBITOS,
			PROMEDIO,
			SALDOACTUAL,
			TRANSFERENCIA,
			GARANTIA,
			DISPONIBLE,
			TEAPAGO,
			TEACOBRO,
			SALDOAFECHA,
			CREDEB,
			SIRCREB,
			IIBB_CORRIENTES,
			DESCTRANSACCION,
			INFOEXTENDIDA,
			CODMOVIMIENTO,
			JTSOID)
		(SELECT
			@vLegal,
			@vPeriodo,
			s.IdCab,
			isnull(m.RegistroxJTS,0),
			s.Sucursal,
			s.TipoProd,
			s.Prod,
			s.Cuenta,
			s.Moneda,
			s.Operacion,
			s.Ordinal,
			s.Periodicidad,
			s.Canal,
			''M'',
			m.FechaProcesado,
			m.Concepto,
			m.SucursalOrigen,
			m.Asiento,
			m.FechaValor,
			m.FechaRealMov,
			m.HoraMov,
			m.ImporteD,
			m.ImporteC,
			m.SaldoCalcLineaAux,
			m.Referencia,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			isnull(sd.SaldoFin,0),
			0,
			0,
			0,
			m.DetalleTr,
			m.LineaInfo,
			m.CodTransaccion,
			s.JTSOID
		FROM @TMPMovimientosContables m
		LEFT JOIN @TMPSaldos s ON
			s.JTSOID=m.JTSOID
		LEFT JOIN @TMPDatosTitular t ON
			t.Cliente=s.Cliente 
			AND t.JTSOID = s.JTSOID
		LEFT JOIN @TMPSaldosDiarios sd ON 
			sd.JTSOID=s.JTSOID
		WHERE
			m.RegistroxJTS <> 0
		)
	
	END TRY
	
	BEGIN CATCH
	
		SET @p_ret_proceso = ERROR_NUMBER()
		SET @p_msg_proceso = ''Error al grabar detalle de movimientos'' + ERROR_MESSAGE()
		
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
			@p_id_proceso = @p_id_proceso,
			@p_fch_proceso = @p_dt_proceso,
			@p_nom_package = ''ESTADOCUENTA'',
			@p_cod_error = @p_ret_proceso,
			@p_msg_error = @p_msg_proceso,
			@p_tipo_error = @c_log_tipo_informacion
	
	END CATCH
	
	BEGIN
		
		/* Se genera el último F al terminar corte de control  Obiene saldo diario del dia desde (saldo actual a la fecha comienzo). Tambien obtiene las tasas por si las necesita luego en el calculo de tasa*/
		BEGIN TRY
		
			UPDATE sd
			SET
				sd.SaldiaFin = g.SALDO_AL_CORTE,
				sd.TeapagoSD = g.TASAINTERESPAGO,
				sd.TeacobroSD = g.TASAINTERESCOBRO,
				sd.CupoSobregiroDiario = g.CUPO_SOBREGIRO,
				/* TEAPAGO, TEACOBRO según tipo tasa y tipo producto*/
			 	sd.Teapago= ISNULL((
				 					CASE 
				 						WHEN s.TipoProd IN (2,3) AND s.TipoTasa = ''E''
				 							THEN sd.TeapagoSD
										ELSE 0
									END)
								, 0
							),
				
				sd.Teacobro= ISNULL((
									CASE 
										WHEN s.TipoProd IN (2,3) AND s.TipoTasa = ''E''
											THEN sd.TeacobroSD
										ELSE 0
									END)
								, 0
							)
			FROM @TMPSaldosDiarios sd
			INNER JOIN @TMPSaldos s ON
				s.JTSOID = sd.JTSOID
			LEFT JOIN GRL_SALDOS_DIARIOS g WITH (nolock) ON
				g.SALDOS_JTS_OID = sd.JTSOID
				AND g.TZ_LOCK = 0
				AND g.FECHA = @vFechaFin
		
		END TRY
		
		BEGIN CATCH
		
			SET @p_ret_proceso = ERROR_NUMBER()
			SET @p_msg_proceso = ''Error al obtener el saldo del último día'' + ERROR_MESSAGE()
			
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
				@p_id_proceso = @p_id_proceso,
				@p_fch_proceso = @p_dt_proceso,
				@p_nom_package = ''ESTADOCUENTA'',
				@p_cod_error = @p_ret_proceso,
				@p_msg_error = @p_msg_proceso,
				@p_tipo_error = @c_log_tipo_informacion
		
		END CATCH
		
		/* Disponible, Transferencia y Garantía, Según tipo de producto y moneda*/
		UPDATE s
		SET
			s.Transferencia = ISNULL((
									CASE 
										WHEN s.TipoProd IN (2,3) AND m.C6403=''E''
											THEN sd.SalDiaFin + sd.CuposobregiroDiario
									END)
								, 0
							),
			s.Disponible = ISNULL((
									CASE 
										WHEN s.TipoProd IN (2,3) AND m.C6403<>''E''
											THEN sd.SalDiaFin + sd.CuposobregiroDiario
									END)
								, 0
							)
		FROM @TMPSaldos s
		LEFT JOIN @TMPSaldosDiarios sd ON
			sd.JTSOID = s.JTSOID
		INNER JOIN MONEDAS m WITH (nolock) ON
			m.C6399=s.Moneda
	
	END
	
	BEGIN TRY
	
		BEGIN
		
			INSERT dbo.GRL_DET_ENVIO_ESTCTA(
				LEGAL,
				PERIODO,
				IDCAB,
				IDDET,
				SUCURSAL,
				TIPOPRODUCTO,
				PRODUCTO,
				CUENTA,
				MONEDA,
				OPERACION,
				ORDINAL,
				PERIODICIDAD,
				CANAL,
				TIPOMOV,
				FECHAMOV,
				CONCEPTO,
				SUCURSALORIGEN,
				ASIENTO,
				FECHAVALOR,
				IMPORTEDEBITO,
				IMPORTECREDITO,
				SALDOCALCLINEA,
				REFERENCIA,
				IMPORTESPENDIENTES,
				TASASRENOVACION,
				PLAZORENOVACION,
				CANTIDADCREDITOS,
				CANTIDADDEBITOS,
				PROMEDIO,
				SALDOACTUAL,
				TRANSFERENCIA,
				GARANTIA,
				DISPONIBLE,
				TEAPAGO,
				TEACOBRO,
				JTSOID,
				CREDEB,
				SIRCREB,
				IIBB_CORRIENTES)
				(SELECT
				@vLegal,
				@vPeriodo,
				s.IdCab,
				ISNULL((
					(SELECT TOP 1 RegistroxJTS
					FROM @TMPMovimientosContables m
					WHERE 
						m.JTSOID = s.JTSOID
					ORDER BY
						RegistroxJTS DESC
					) + 1
				), @vIdDet + 1),
				s.Sucursal,
				s.TipoProd,
				s.Prod,
				s.Cuenta,
				s.Moneda,
				s.Operacion,
				s.Ordinal,
				s.Periodicidad,
				s.Canal,
				''F'',
				@vFechaFin,
				''Saldo Final'',
				s.Sucursal,
				0,
				NULL,
				0,
				0,
				s.SaldoCalcLinea,
				0,
				s.ImportesPend,
				s.TasaRen,
				s.PlazoRen,
				s.CantCred,
				s.CantDeb,
				sd.Promedio,
				sd.SalDiaFin,
				s.Transferencia,
				0,
				s.Disponible,
				sd.TeaPago,
				sd.TeaCobro,
				s.JTSOID,
				s.CREDEB,
				s.SIRCREB,
				s.IIBB_CORRIENTES
			FROM @TMPSaldos s
			INNER JOIN @TMPDatosTitular t ON
				t.Cliente=s.Cliente 
				AND t.JTSOID = s.JTSOID
			LEFT JOIN @TMPSaldosDiarios sd ON
				sd.JTSOID=s.JTSOID)
			
			UPDATE dbo.GRL_DET_ENVIO_ESTCTA
			SET CANAL = ''E''
			FROM dbo.GRL_DET_ENVIO_ESTCTA AS D
			WHERE
				D.LEGAL = ''L''
				AND NOT EXISTS (
					SELECT
						C.LEGAL,
						C.PERIODO,
						C.IDCAB,
						C.CODIGOCLIENTE,
						C.TIPODIRECCION,
						C.NOMBRECLIENTE,
						C.CALLE,
						C.NUMPUERTA,
						C.APARTAMENTO,
						C.PISO,
						C.CIUDADLOCALIDAD,
						C.CODIGOPAIS,
						C.CODIGOPOSTAL,
						C.FECHAEMISION,
						C.PROCESADO
					FROM dbo.GRL_CAB_ENVIO_ESTCTA  AS C with (nolock)
					WHERE
						C.LEGAL = D.LEGAL
						AND C.PERIODO = D.PERIODO
						AND C.IDCAB = D.IDCAB
						AND C.CODIGOPAIS IN (
							0,
							(
								SELECT NUMERICO 
								FROM PARAMETROSGENERALES with (nolock)
								WHERE 
									CODIGO = 1
							)
						)
				)
			
			UPDATE dbo.GRL_DET_ENVIO_ESTCTA
			SET CANAL = ''S''
			FROM dbo.GRL_DET_ENVIO_ESTCTA AS D WITH (NOLOCK)
			WHERE 
				D.LEGAL = ''L'' 
				AND EXISTS (
					SELECT
						C.LEGAL,
						C.PERIODO,
						C.IDCAB,
						C.CODIGOCLIENTE,
						C.TIPODIRECCION,
						C.NOMBRECLIENTE,
						C.CALLE,
						C.NUMPUERTA,
						C.APARTAMENTO,
						C.PISO,
						C.CIUDADLOCALIDAD,
						C.CODIGOPAIS,
						C.CODIGOPOSTAL,
						C.FECHAEMISION,
						C.PROCESADO
					FROM dbo.GRL_CAB_ENVIO_ESTCTA  AS C with (nolock)
					WHERE
						C.LEGAL = D.LEGAL
						AND C.PERIODO = D.PERIODO
						AND C.IDCAB = D.IDCAB
						AND (C.CALLE IN ( ''.'', ''+'', ''..'', ''-'' ) OR C.CALLE IS NULL)
				)
		 	
		 	SET @p_msg_proceso = ''Reporte de Resumen de Cuenta generado exitosamente''
			SET @p_ret_proceso = 1
		
		END
	
		-- Logueo de información
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso
			@p_id_proceso,
			@p_dt_proceso,
			''ESTADOCUENTA'',
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
               @p_nom_package = ''ESTADOCUENTA'',
               @p_cod_error = @p_ret_proceso,
               @p_msg_error = @p_msg_proceso,
               @p_tipo_error = @c_log_tipo_informacion
	
    END CATCH

END
')

