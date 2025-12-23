EXECUTE('
ALTER PROCEDURE [dbo].[ESTADOCUENTA]  
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
        /* Variables clave (más que nada de saldos)*/
         @vRubro float(53), 
         @vRubroAnt float(53), 
         @vCliente float(53), 
         @vClienteAnt float(53), 
         @vProd float(53), 
         @vProdAnt float(53), 
         @vCuenta float(53), 
		 @vCuentaAnt float(53), 
         @vMoneda float(53), 
		 @vMonedaAnt float(53), 
 		 @vOperacion float(53), 
         @vOperacionAnt float(53), 
         @vOrdinal float(53), 
         @vOrdinalAnt float(53), 
         @vSucursal float(53), 
         @vSucursalAnt float(53), 
         @vIdCab numeric(12), 
         @vIdDet numeric(12), 
         @vJTSOID float(53), 
         @vJTSOIDAnt float(53), 
         /* Parametros Estado Cuenta*/
         @vPeriodicidad char(1), 
         @vCanal char(1), 
         @vPeriodicidadAnt char(1), 
         @vCanalAnt char(1), 
         /* Variables Saldos extra*/
         @vTipoProd float(53), 
         @vTipoProdAnt float(53), 
         @vSalDiaIni numeric(15, 2), 
         @vSalDiaFin numeric(15, 2), 
         @vSalDiaFinAnt numeric(15, 2), 
         @vSal24 numeric(15, 2), 
         @vSal24Ant numeric(15, 2), 
         @vSal48 numeric(15, 2), 
         @vSal48Ant numeric(15, 2), 
         @vTasaRen numeric(11, 7), 
         @vTasaRenAnt numeric(11, 7), 
         @VPlazoRen numeric(5), 
         @VPlazoRenAnt numeric(5), 
         @vGarantia char(1), 
         @vGarantiaAnt char(1), 
         @vImpGtia numeric(15, 2), 
         @vSignoSal char(1), 
         @vSaldoAct numeric(15, 2), 
         @vSaldoActAnt numeric(15, 2), 
         @vCodOpVenc char(1)/*s1728*/, 
         @vCodOpVencAnt char(1)/*s1728*/, 
         @vCupoSobregiro numeric(15, 2)/*s1683*/, 
         @vCupoSobregiroAnt numeric(15, 2)/*s1683*/, 
         @vCupoSobregiroDiario numeric(15, 2)/*s1683*/, 
         /* Variables Producto*/
         @vTipoTasa char(1)/* pr6253*/, 
         @vTipoTasaAnt char(1)/* pr6253*/, 
         @vPeriodProd char(1), 
         /* Variables tabla estado cuenta*/
         @vPeriodEC char(1), 
         @vCorreo char(1), 
         @vTipoDireccion varchar(2), -- @vTipoDireccion numeric(3), 
         @vTipoDireccionAnt varchar(2), -- @vTipoDireccionAnt numeric(3), 
         /* Variables Clientes*/
         @vnomcli varchar(70), 
         @vCalle varchar(50), 
         @vNumeroPuerta numeric(8), 
         @vApartamento varchar(100), 
		 @vPiso numeric(8), 
         @vCiudadLocalidad varchar(60), 
         @vCodigoPais numeric(5), 
         @vCodigoPostal varchar(3),
         @vBarrio varchar(100),
         @vFormato VARCHAR(2),
         @vTipoCliente VARCHAR(1),
         /* Variables de personas */
         @vNroPersona NUMERIC(12),
         @vTipoPersona VARCHAR(1),
         @vCantTitulares numeric(10),
         @vDocTitular varchar(20),
         @vNomTitular varchar(70),
         @vDocTitular2 varchar(20),
         @vNomTitular2 varchar(70),
         @vDocTitular3 varchar(20),
         @vNomTitular3 varchar(70),
         /* Otras variables para cabecera */
         @vNombreSucursal VARCHAR(35),
         @vNombreProducto VARCHAR(50),
         @vCBU VARCHAR(22),
         @vSaldoINI NUMERIC(15,2),
         @vMonedaCAB VARCHAR(20),
         @vResumenEn VARCHAR(20),
         /*variable provincia agregada por ajustes demo 3 - 02 09 2020*/
         @vProvincia VARCHAR(60),
         /* Otras variables para el detalle */
         @vCREDEB NUMERIC(15,2),
		@vSIRCREB NUMERIC(15,2),
         @vSaldoFin NUMERIC(15,2),
         /* INFO EXTENDIDA */
         @vLineaInfo VARCHAR(150),
         /*Prestamos*/
         @vNroPrestamo NUMERIC(10),
         @vLineaPrestamo NUMERIC(10),
         @vCuotaP NUMERIC(10),
         @vBonificacionP NUMERIC(15,2),
         /*DEBITOS DIRECTOS */
         @vOriginanteDD VARCHAR(50),
         @vDocOriginanteDD VARCHAR(20),
         @vRefDD VARCHAR(50),
         /*TRANSFERENCIAS PARA CRÉDITO*/
         @vOriginanteTC VARCHAR(50),
         @vDocOriginanteTC VARCHAR(20),
         @vRefTC VARCHAR(50),
         /*TRANSFERENCIAS PARA DÉBITO*/
         @vDescTD VARCHAR(50),
         @vCuitDestTD VARCHAR(20),
         @vRefTD VARCHAR(50),
         /*PLAZO FIJO*/
         @vSucursalPF NUMERIC(5),
         @vCertificadoPF NUMERIC(10),
         @vCapitalPF NUMERIC(15,2),
         @vInteresesPF NUMERIC(15,2),
         /* Variables Movs*/
         @vFechaProcesado datetime, 
         @vConcepto varchar(256), 
         @vSucursalOrigen float(53), 
         @vAsiento float(53), 
         @vFechaValor datetime, 
         @vMonto float(53), 
         @vSaldoCalcLinea numeric(15, 2), 
         @vSaldoCalcLineaABS numeric(15, 2), 
         @vSignoMov char(1), 
         @vImporteD numeric(15, 2), 
         @vImporteC numeric(15, 2), 
         @vImportesPend numeric(15, 2), 
         @vTIPOMOV char(1), 
         @vCantDeb float(53), 
         @vCantCred float(53), 
         @vTransferencia numeric(15, 2), 
         @vPromedio numeric(15, 2), 
         @vDisponible numeric(15, 2), 
         @vTeapago numeric(15, 2), 
         @vTeacobro numeric(15, 2), 
         @vTeapagoSD numeric(15, 2), 
         @vTeacobroSD numeric(15, 2), 
         @vReferencia numeric(15), 
         @vDetalleTr VARCHAR(60),
         @vInfoExtendida VARCHAR(1),
         /* Aux*/
         @vFechaAux datetime, 
         @vDia float(53), 
         @vMes float(53), 
         @vAnio float(53), 
         @vDiaProx float(53), 
         @vMesProx float(53), 
         @vAnioProx float(53), 
         @vOperacionTopaz float(53), 
         @vCodTransaccion float(53),
         @vId_proveedor varchar(20), 
         @vlote float(53), 
         @vregistro float(53), 
         @vCodCliAUX NUMERIC(12),
         @vCREDEBAUX NUMERIC(15,2),
		 @vSIRCREBAUX NUMERIC(15,2),
		 @vCantidad NUMERIC(10),
		 @vCantidad2 NUMERIC(10), 
         /* Excepciones*/
         @periodo_invalido$exception nvarchar(1000)

      BEGIN TRY
         SET @p_ret_proceso = NULL
         SET @p_msg_proceso = NULL
         SET @vSIRCREB = 0
         SET @vCREDEB = 0
         SET @vCantidad = 0
         SET @vCantidad2 = 0
         SET @vSIRCREBAUX = 0
         SET @vCREDEBAUX = 0
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
         SET @vIdCab = 0
         SET @vPeriodo = upper(@p_Periodo)
		 PRINT @p_Periodo
		 PRINT @vPeriodo
         /*Z diario diferido para los diarios*/
         IF @vPeriodo NOT IN ( 
            ''M'', 
            ''P'', 
            ''J'', 
            ''S'', 
            ''E'', 
            ''Q'', 
            ''T'', 
            ''A'' ) OR @vPeriodo IS NULL
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
               SELECT @vFechaProc = PARAMETROS.FECHAPROCESO, @vFechaProxProc = PARAMETROS.FECHAPROXIMOPROCESO
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
               ELSE 
                  IF @vDiaProx BETWEEN 8 AND 14
                     BEGIN
                        SET @vFechaIni = CONVERT(datetime2, ''01'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                        SET @vFechaFin = CONVERT(datetime2, ''07'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                     END
                  ELSE 
                     IF @vDiaProx BETWEEN 15 AND 21
                        BEGIN
                           SET @vFechaIni = CONVERT(datetime2, ''08'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                           SET @vFechaFin = CONVERT(datetime2, ''14'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                        END
                     ELSE 
                        IF @vDiaProx >= 22 OR (@vMes < @vMesProx)
            BEGIN
                              SET @vFechaIni = CONVERT(datetime2, ''15'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                              SET @vFechaFin = CONVERT(datetime2, ''21'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
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
               ELSE 
                  IF @vDiaProx BETWEEN 11 AND 20
                     BEGIN
                        SET @vFechaIni = CONVERT(datetime2, ''01'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                        SET @vFechaFin = CONVERT(datetime2, ''10'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                     END
                  ELSE 
                     IF @vDia >= 21 OR (@vMes < @vMesProx)
                        BEGIN
                           SET @vFechaIni = CONVERT(datetime2, ''11'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                           SET @vFechaFin = CONVERT(datetime2, ''20'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
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
               ELSE 
                  IF @vDiaProx >= 16 OR (@vMes < @vMesProx)
                     BEGIN
                        SET @vFechaIni = CONVERT(datetime2, ''01'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                       SET @vFechaFin = CONVERT(datetime2, ''15'' + ''/'' + ISNULL(CAST(@vMes AS nvarchar(max)), '''') + ''/'' + ISNULL(CAST(@vAnio AS nvarchar(max)), ''''), 103)
                     END
            END
         /* Periodo=T (Trimestral)*/
         IF @vPeriodo = ''T''
            IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/01''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''31/03''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
               BEGIN
                  SET @vFechaAux = dateadd(m, -12, @vFechaProc)
                  SET @vFechaIni = CONVERT(datetime2, ''01/10'' + ''/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
                  SET @vFechaFin = CONVERT(datetime2, ''31/12'' + ''/'' + ISNULL(CAST(datepart(YEAR, @vFechaAux) AS nvarchar(max)), ''''), 103)
               END
            ELSE 
               IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/04''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''30/06''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
                  BEGIN
                     SET @vFechaIni = CONVERT(datetime2, ''01/01/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
                     SET @vFechaFin = CONVERT(datetime2, ''31/03/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
                  END
               ELSE 
                  IF (@vFechaProxProc BETWEEN CONVERT(datetime2, ''01/07''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103) AND CONVERT(datetime2, ''30/09''  +  ''/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103))
                     BEGIN
                        SET @vFechaIni = CONVERT(datetime2, ''01/04/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
                        SET @vFechaFin = CONVERT(datetime2, ''30/06/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
                     END
                  ELSE 
                     IF @vFechaProxProc >= CONVERT(datetime2, ''01/10'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
                        BEGIN
                           SET @vFechaIni = CONVERT(datetime2, ''01/07/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
                           SET @vFechaFin = CONVERT(datetime2, ''30/09/'' + ISNULL(CAST(@vAnioProx AS nvarchar(max)), ''''), 103)
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
         WHERE GRL_DET_ENVIO_ESTCTA.LEGAL = @vLegal 
				AND GRL_DET_ENVIO_ESTCTA.PERIODO = @vPeriodo

         DELETE dbo.GRL_CAB_ENVIO_ESTCTA
         WHERE GRL_CAB_ENVIO_ESTCTA.LEGAL = @vLegal AND GRL_CAB_ENVIO_ESTCTA.PERIODO = @vPeriodo
         END 
         ELSE 
         BEGIN
         DELETE dbo.GRL_DET_ENVIO_ESTCTA
         WHERE GRL_DET_ENVIO_ESTCTA.LEGAL = @vLegal 
				AND GRL_DET_ENVIO_ESTCTA.PERIODO = @vPeriodo 
				AND GRL_DET_ENVIO_ESTCTA.JTSOID = @p_JTSOID

         DELETE dbo.GRL_CAB_ENVIO_ESTCTA
         WHERE GRL_CAB_ENVIO_ESTCTA.LEGAL = @vLegal 
				AND GRL_CAB_ENVIO_ESTCTA.PERIODO = @vPeriodo 
				AND GRL_CAB_ENVIO_ESTCTA.JTSOID = @p_JTSOID
         END

         IF @@TRANCOUNT > 0
            COMMIT WORK 
         SET @vIdCab = 0
         SET @vClienteAnt = -1
         SET @vJTSOIDAnt = -1
		 SET @vJTSOID = @p_JTSOID
         /*
         *    Cursor Pivote por cliente producto, cuenta. Ademas: tipoprod(2-4), moneda, suc, op., ord
         *    Sal24,Sal48, IndGarantia, tasaRen, pzoRen, signo, jts
         *    El signo del saldo se obtiene del plan de cuentas ya que no se guarda mas en tabla saldos
         */
         DECLARE
             cSaldos CURSOR LOCAL FOR 
               SELECT 
                  s.C1803, 
                  s.C1730, 
                  s.PRODUCTO, 
                  Pr.C6253, 
                  s.CUENTA, 
                  s.C1785, 
				  s.MONEDA, 
                  s.SUCURSAL, 
                  s.OPERACION, 
                  s.ORDINAL, 
                  s.C1606, 
                  s.C1607, 
                  s.C1734, 
                  s.C1637, 
                  s.C1689, 
                  p.C6305, 
                  s.C1728, 
                  s.C1604, 
                  s.C1683, 
                  s.JTS_OID, 
                  isnull(Pr.PERIODOLEGALESTCTA, ''M''), 
                  isnull(E.PERIODICIDAD, ''M''), 
                  isnull(E.RETENER_CORRESPONDENCIA, ''S''), 
                  E.TIPODIRECCION
               FROM 
					dbo.SALDOS  AS s with (nolock) 
					inner join dbo.PLANCTAS  AS p with (nolock) on s.TZ_LOCK = 0
																	AND p.TZ_LOCK = 0
																	AND s.C1730 = p.C6326
																	AND s.C1785 in (2,3,4,5) --BETWEEN 2 AND 5
																	AND s.JTS_OID= @vJTSOID or isnull(@vJTSOID, -1) = -1 

					inner join dbo.GRL_ESTADOS_DE_CUENTA  AS E with (nolock) on s.CUENTA = E.CUENTA
																				AND E.TZ_LOCK = 0
																				AND s.PRODUCTO = E.PRODUCTO
																				AND s.MONEDA = E.MONEDA
																				AND s.SUCURSAL = E.SUCURSAL
																				AND s.OPERACION = E.OPERACION
																				AND s.ORDINAL = E.ORDINAL
																						/* Obtener periodicidad dependiendo de si es Legal o no*/
																				AND 
																						(
																							((E.PERIODICIDAD = @vPeriodo OR @vPeriodo = ''P'') AND @vLegal <> ''L'') 
																								OR /*OR (pr.PERIODOLEGALESTCTA=vPeriodo AND vLegal=''L'' AND E.PERIODICIDAD=vPeriodo)*/
																							(E.PERIODICIDAD = @vPeriodo AND	E.TIPO_EMISION = ''N'' AND @vlegal = ''L'')
																						)
					inner join dbo.PRODUCTOS  AS Pr with (nolock) on  Pr.TZ_LOCK = 0
																	AND s.PRODUCTO = Pr.C6250
																	AND Pr.C6250 = E.PRODUCTO
  
               ORDER BY 
                  s.C1803, 
                  s.SUCURSAL, 
                  s.PRODUCTO, 
                  s.CUENTA, 
                  s.MONEDA, 
                  s.OPERACION

         OPEN cSaldos
         WHILE 1 = 1
            BEGIN
               /*
               *   cliente, producto, cuenta. tipoprod, moneda, suc, operacion, ordinal
               *   Sal24,Sal48, garantia, tasaRen, pzoRen, CodOpVenc, SaldoAct, CupoSobregiro, jts
               */
               FETCH cSaldos
                   INTO 
                     @vCliente, 
                     @vRubro, 
                     @vProd, 
                     @vTipoTasa, 
  					 @vCuenta, 
                     @vTipoProd, 
                     @vMoneda, 
                     @vSucursal, 
                     @vOperacion, 
                     @vOrdinal, 
                     @vSal24, 
                     @vSal48, 
                     @vGarantia, 
                     @vTasaRen, 
                 	 @vPlazoRen, 
                     @vSignoSal, 
                     @vCodOpVenc, 
                     @vSaldoAct, 
                     @vCupoSobregiro, 
                     @vJTSOID, 
                     @vPeriodProd, 
                     @vPeriodEC, 
                     @vCorreo, 
                     @vTipoDireccion
               /*
               *   SSMA warning messages:
               *   O2SS0113: The value of @@FETCH_STATUS might be changed by previous FETCH operations on other cursors, if the cursors are used simultaneously.
               */

               /* Graba MOV F datos de fin al cambiar clave (EXCEPTO en la 1ra pasada)*/
               /*PRINT @vJTSOID
 			   PRINT @vJTSOIDAnt
 			   PRINT @@FETCH_STATUS
 			   PRINT @vProdAnt*/
               IF ((@vJTSOID <> @vJTSOIDAnt) AND @vProdAnt <> -1) OR (@@FETCH_STATUS <> 0 AND @vProdAnt <> -1)
                  BEGIN
                     BEGIN/* Se genera el último F al terminar corte de control  Obiene saldo diario del dia desde (saldo actual a la fecha comienzo). Tambien obtiene las tasas por si las necesita luego en el calculo de tasa*/
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$pJTSOID float(53)
                        DECLARE
                           @OBTENER_SALDO_DIARIO$pFECHA datetime
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PTIPOPROD float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PSaldo float(53)
                        DECLARE
                         /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PTeaPago float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PTeaCobro float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$pPromedio float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$pCupoSobregiro float(53)
                        SET @OBTENER_SALDO_DIARIO$pJTSOID = @vJTSOIDAnt
                        SET @OBTENER_SALDO_DIARIO$pFECHA = @vFechaFin
                        SET @OBTENER_SALDO_DIARIO$PTIPOPROD = @vTipoProdAnt
                        SET @OBTENER_SALDO_DIARIO$PSaldo = @vSalDiaFin
                        SET @OBTENER_SALDO_DIARIO$PTeaPago = @vTeaPagoSD
                        SET @OBTENER_SALDO_DIARIO$PTeaCobro = @vTeaCobroSD
                        SET @OBTENER_SALDO_DIARIO$pPromedio = @vPromedio
                        SET @OBTENER_SALDO_DIARIO$pCupoSobregiro = @vCuposobregiroDiario
            BEGIN
							SET @OBTENER_SALDO_DIARIO$PSaldo = NULL
                           SET @OBTENER_SALDO_DIARIO$PTeaPago = NULL
                           SET @OBTENER_SALDO_DIARIO$PTeaCobro = NULL
                           SET @OBTENER_SALDO_DIARIO$pPromedio = NULL
                          SET @OBTENER_SALDO_DIARIO$pCupoSobregiro = NULL
                           DECLARE
                              @OBTENER_SALDO_DIARIO$vSalAux numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vLiq numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vTasaPagoAux numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vTasaCobroAux numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vPromedioAux numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vCupoSobregiroAux numeric(15, 2)
                           BEGIN
                              BEGIN TRY
                            SELECT 
                                    @OBTENER_SALDO_DIARIO$vSalAux = GRL_SALDOS_DIARIOS.SALDO_AL_CORTE, 
                                    --@OBTENER_SALDO_DIARIO$vLiq = abs(GRL_SALDOS_DIARIOS.INT_A_LIQUIDAR), 
                                    @OBTENER_SALDO_DIARIO$vTasaPagoAux = GRL_SALDOS_DIARIOS.TASAINTERESPAGO, 
                                    @OBTENER_SALDO_DIARIO$vTasaCobroAux = GRL_SALDOS_DIARIOS.TASAINTERESCOBRO, 
                                    --@OBTENER_SALDO_DIARIO$vPromedioAux = GRL_SALDOS_DIARIOS.PROMEDIOPAGO, 
                                    @OBTENER_SALDO_DIARIO$vCupoSobregiroAux = GRL_SALDOS_DIARIOS.CUPO_SOBREGIRO
                                 FROM dbo.GRL_SALDOS_DIARIOS with (nolock)
                          WHERE 
                                    GRL_SALDOS_DIARIOS.SALDOS_JTS_OID = @OBTENER_SALDO_DIARIO$pJTSOID AND 
                                    GRL_SALDOS_DIARIOS.FECHA = @OBTENER_SALDO_DIARIO$pFECHA AND 
                                    GRL_SALDOS_DIARIOS.TZ_LOCK = 0
                                   --SET @OBTENER_SALDO_DIARIO$vSalAux = ISNULL(@OBTENER_SALDO_DIARIO$vSalAux,@vSaldoCalcLinea)
									--EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                              END TRY
                              BEGIN CATCH
                                 DECLARE
                                    @OBTENER_SALDO_DIARIO$errornumber int
                                 SET @OBTENER_SALDO_DIARIO$errornumber = ERROR_NUMBER()
                                 DECLARE
                                    @OBTENER_SALDO_DIARIO$errormessage nvarchar(4000)
                                 SET @OBTENER_SALDO_DIARIO$errormessage = ERROR_MESSAGE()
                                 DECLARE
                                    @OBTENER_SALDO_DIARIO$exceptionidentifier nvarchar(4000)
                                 SELECT @OBTENER_SALDO_DIARIO$exceptionidentifier = @OBTENER_SALDO_DIARIO$errormessage +'' '' + @OBTENER_SALDO_DIARIO$errornumber
                                 IF (@OBTENER_SALDO_DIARIO$exceptionidentifier LIKE N''ORA+00100%'')
                                    BEGIN
                                       /* no hay saldo diario para esa fecha*/
                                       SET @OBTENER_SALDO_DIARIO$vSalAux = 0
                                       SET @OBTENER_SALDO_DIARIO$vLiq = 0
                                       SET @OBTENER_SALDO_DIARIO$vTasaPagoAux = 0
                                       SET @OBTENER_SALDO_DIARIO$vTasaCobroAux = 0
										SET @OBTENER_SALDO_DIARIO$vPromedioAux = 0
                                       SET @OBTENER_SALDO_DIARIO$vCupoSobregiroAux = 0
                                    END
                                 ELSE 
                                    BEGIN
                                       IF (@OBTENER_SALDO_DIARIO$exceptionidentifier IS NOT NULL)
                                          BEGIN
                         IF @OBTENER_SALDO_DIARIO$errornumber = 59998
                                                RAISERROR(59998, 16, 1, @OBTENER_SALDO_DIARIO$exceptionidentifier)
                                             ELSE 
                                                RAISERROR(59999, 16, 1, @OBTENER_SALDO_DIARIO$exceptionidentifier)
                                          END
                                       ELSE 
                                          BEGIN
                                             SELECT ERROR_MESSAGE()
                                          END
                                    END
                              END CATCH
                           END
                           /* A los productos de tipo 4 se les suman los intereses a liquidar*/
         IF @OBTENER_SALDO_DIARIO$PTIPOPROD = 4
                           SET @OBTENER_SALDO_DIARIO$vSalAux = @OBTENER_SALDO_DIARIO$vSalAux + @OBTENER_SALDO_DIARIO$vLiq
                           SET @OBTENER_SALDO_DIARIO$PSaldo = @OBTENER_SALDO_DIARIO$vSalAux
                           SET @OBTENER_SALDO_DIARIO$PTeaPago = @OBTENER_SALDO_DIARIO$vTasaPagoAux
                           SET @OBTENER_SALDO_DIARIO$PTeaCobro = @OBTENER_SALDO_DIARIO$vTasaCobroAux
                           SET @OBTENER_SALDO_DIARIO$pPromedio = @OBTENER_SALDO_DIARIO$vPromedioAux
                           SET @OBTENER_SALDO_DIARIO$pCupoSobregiro = @OBTENER_SALDO_DIARIO$vCupoSobregiroAux
                        END
                        SET @vSalDiaFin = @OBTENER_SALDO_DIARIO$PSaldo
                        SET @vTeaPagoSD = @OBTENER_SALDO_DIARIO$PTeaPago
                        SET @vTeaCobroSD = @OBTENER_SALDO_DIARIO$PTeaCobro
						SET @vPromedio = @OBTENER_SALDO_DIARIO$pPromedio
                        SET @vCuposobregiroDiario = @OBTENER_SALDO_DIARIO$pCupoSobregiro
                     END
          BEGIN
                        DECLARE
                           /*   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.*/
                           @OBTENER_IMPORTES_PENDIENTES$pJTSOID float(53)
                        DECLARE
                           /*   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.*/
                           @OBTENER_IMPORTES_PENDIENTES$return_value_argument float(53)
                        SET @OBTENER_IMPORTES_PENDIENTES$pJTSOID = @vJTSOIDAnt
                        SET @OBTENER_IMPORTES_PENDIENTES$return_value_argument = @vImportesPend
                        BEGIN
                           DECLARE
                              @OBTENER_IMPORTES_PENDIENTES$ImpAux numeric(15, 2)
                           BEGIN
                              BEGIN TRY
                                 SELECT @OBTENER_IMPORTES_PENDIENTES$ImpAux = sum(C.IMPORTE)
                                 FROM dbo.CLE_CHEQUES_SALIENTE  AS C  with (nolock)
								 inner join dbo.CLE_DEPOSITOS  AS D with (nolock) on D.SALDO_JTS_OID = @OBTENER_IMPORTES_PENDIENTES$pJTSOID
																					AND D.NUMERO_DEPOSITO = C.NUMERO_DEPOSITO
																					AND C.ACREDITADO = 0 
																					AND C.DESTINO_CHEQUE IN (1,5)
                             
                              END TRY
                              BEGIN CATCH
                                 DECLARE
                                    @OBTENER_IMPORTES_PENDIENTES$errornumber int
									SET @OBTENER_IMPORTES_PENDIENTES$errornumber = ERROR_NUMBER()
                                 DECLARE
										@OBTENER_IMPORTES_PENDIENTES$errormessage nvarchar(4000)
									SET @OBTENER_IMPORTES_PENDIENTES$errormessage = ERROR_MESSAGE()
                                 DECLARE
                                    @OBTENER_IMPORTES_PENDIENTES$exceptionidentifier nvarchar(4000)
                                 SELECT @OBTENER_IMPORTES_PENDIENTES$exceptionidentifier = (@OBTENER_IMPORTES_PENDIENTES$errormessage +'' '' + @OBTENER_IMPORTES_PENDIENTES$errornumber)
                                 IF (@OBTENER_IMPORTES_PENDIENTES$exceptionidentifier LIKE N''ORA+00100%'')
                                    /* no hay cheques para la cuenta*/
                                    SET @OBTENER_IMPORTES_PENDIENTES$ImpAux = 0
                                 ELSE 
               BEGIN
                                       IF (@OBTENER_IMPORTES_PENDIENTES$exceptionidentifier IS NOT NULL)
                                          BEGIN
                                             IF @OBTENER_IMPORTES_PENDIENTES$errornumber = 59998
                                                RAISERROR(59998, 16, 1, @OBTENER_IMPORTES_PENDIENTES$exceptionidentifier)
                                             ELSE 
                                                RAISERROR(59999, 16, 1, @OBTENER_IMPORTES_PENDIENTES$exceptionidentifier)
                                          END
                                       ELSE 
                                          BEGIN
                                             SELECT ERROR_MESSAGE()
                                          END
                                    END
                              END CATCH
                 END
              IF @OBTENER_IMPORTES_PENDIENTES$ImpAux IS NULL
                              SET @OBTENER_IMPORTES_PENDIENTES$ImpAux = 0

                           SET @OBTENER_IMPORTES_PENDIENTES$return_value_argument = @OBTENER_IMPORTES_PENDIENTES$ImpAux

                           GOTO OBTENER_IMPORTES_PENDIENTES$RETURN_LABEL

                        END

                        OBTENER_IMPORTES_PENDIENTES$RETURN_LABEL:

                        SET @vImportesPend = @OBTENER_IMPORTES_PENDIENTES$return_value_argument

                     END

                     /* Disponible, Transferencia y Garantía, Según tipo de producto y moneda*/
                     SET @vImpGtia = 0
                     SET @vDisponible = 0
                     SET @vTransferencia = 0
                     IF @vTipoProd = 4 AND @vCodOpVencAnt = ''G''
                        SET @vImpGtia = @vSaldoActAnt
                     IF @vTipoProd IN ( 2, 3 ) AND @vMonedaAnt = 2222
                        SET @vTransferencia = @vSalDiaFin + @vCuposobregiroDiario
                     IF @vTipoProd IN ( 2, 3 ) AND @vMonedaAnt <> 2222
                        SET @vDisponible = @vSalDiaFin + @vCuposobregiroDiario
                     /* TEAPAGO, TEACOBRO según tipo tasa y tipo producto*/
                     SET @vTeapago = 0
                     SET @vTeacobro = 0
                     IF @vTipoTasa = ''E''
                        BEGIN
                           /*Tasa efectiva*/
                           IF @vTipoProd IN ( 2, 3 )
           BEGIN
                                 SET @vTeapago = @vTeapagoSD
                                 SET @vTeacobro = @vTeacobroSD
                              END
                           IF @vTipoProd = 4
                              BEGIN
                                 BEGIN TRY
                                    SELECT @vTeapago = BS_HISTORIA_PLAZO.TASAINTERES
                                    FROM dbo.BS_HISTORIA_PLAZO with (nolock)
									WHERE 
                                       BS_HISTORIA_PLAZO.TZ_LOCK = 0 AND 
                                       BS_HISTORIA_PLAZO.TIPOMOV = ''A'' AND 
                                       BS_HISTORIA_PLAZO.SALDOS_JTS_OID = @vJTSOID
                                    --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                                 END TRY
                                 BEGIN CATCH
                                    DECLARE
                                       @errornumber int
                                    SET @errornumber = ERROR_NUMBER()
                                    DECLARE
                                       @errormessage nvarchar(4000)
                                    SET @errormessage = ERROR_MESSAGE()
                                    DECLARE
                                       @exceptionidentifier nvarchar(4000)
                                    SELECT @exceptionidentifier = (@errormessage+'' ''+ @errornumber)
                                    IF (@exceptionidentifier LIKE N''ORA+00100%'')
                                       SET @vTeapago = 0
                                    ELSE 
                                       BEGIN
                                          IF (@exceptionidentifier IS NOT NULL)
                                             BEGIN
                                                IF @errornumber = 59998
                                                   RAISERROR(59998, 16, 1, @exceptionidentifier)
                                                ELSE 
                                                   RAISERROR(59999, 16, 1, @exceptionidentifier)
                                             END
                                          ELSE 
                                             BEGIN
                SELECT ERROR_MESSAGE()
                  END
                        END
                                 END CATCH
                              END
                        END
                     ELSE 
                        BEGIN
                           /*Tasa nominal (En NBC no hay, por ahora queda pendiente)*/
                           SET @vTeapago = 0
                           SET @vTeacobro = 0
						 END
                     PRINT @vJTSOID
                     PRINT ''SIRCREB FINAL''
                     PRINT @vSIRCREB
                     SET @vIdDet = @vIdDet + 1
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
    					SIRCREB)
                       VALUES (
         				   @vLegal, 
                           @vPeriodo, 
                           @vIdCab, 
                           @vIdDet, 
                           @vSucursalAnt, 
                           @vTipoProdAnt, 
                           @vProdAnt, 
                           @vCuentaAnt, 
                           @vMonedaAnt, 
                           @vOperacionAnt, 
                           @vOrdinalAnt, 
                           @vPeriodicidadAnt, 
                           @vCanalAnt, 
                           ''F'', 
                           @vFechaFin, 
                           ''Saldo Final'', 
                           @vSucursalAnt, 
                           0, 
                           NULL, 
                           0, 
                           0, 
                           @vSaldoCalcLinea, 
                           0, 
                           @vImportesPend, 
                           @vTasaRenAnt, 
							@vPlazoRenAnt, 
                           @vCantCred, 
                           @vCantDeb, 
                           @vPromedio, 
                           @vSalDiaFin, 
                           @vTransferencia, 
                           @vImpGtia, 
                           @vDisponible, 
                           @vTeaPago, 
                           @vTeaCobro,
                           @vJTSOIDAnt,
                           @vCREDEB,
                           @vSIRCREB)
                     IF @@TRANCOUNT > 0
                        COMMIT WORK 
                     /* Restaura Variables para el corte de control*/
                     SET @vJTSOIDAnt = -1
                  END
               IF @@TRANCOUNT > 0
                  COMMIT WORK 
               /* Como esta es la posible salida de loop hace el commit aquí (1 COMMIT por cliente)*/

               /*
               *   SSMA warning messages:
               *   O2SS0113: The value of @@FETCH_STATUS might be changed by previous FETCH operations on other cursors, if the cursors are used simultaneously.
               */
               IF @@FETCH_STATUS <> 0
                  BREAK
               ELSE
               	SET @vCantidad += 1
               /* Si ya no hay mas saldos termina luego del MOV F
               *    Graba MOV I datos de cabezal Al cambiar clave
               *    además resetea los acumuladores */
      IF (@vJTSOID <> @vJTSOIDAnt)
                    BEGIN
                     BEGIN/*Obiene saldo diario del dia anterior al dia desde (saldo anterior a la fecha comienzo)*/
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$pJTSOID$2 float(53)
                        DECLARE
                           @OBTENER_SALDO_DIARIO$pFECHA$2 datetime
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PTIPOPROD$2 float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PSaldo$2 float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PTeaPago$2 float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$PTeaCobro$2 float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
                           */
                           @OBTENER_SALDO_DIARIO$pPromedio$2 float(53)
                        DECLARE
                           /*
                           *   SSMA warning messages:
                           *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
          */
                           @OBTENER_SALDO_DIARIO$pCupoSobregiro$2 float(53)
                        SET @OBTENER_SALDO_DIARIO$pJTSOID$2 = @vJTSOID
                        SET @OBTENER_SALDO_DIARIO$pFECHA$2 = @vFechaIniAnt
						SET @OBTENER_SALDO_DIARIO$PTIPOPROD$2 = @vTipoProd
                        SET @OBTENER_SALDO_DIARIO$PSaldo$2 = @vSalDiaIni
                        SET @OBTENER_SALDO_DIARIO$PTeaPago$2 = @vTeacobro
                        SET @OBTENER_SALDO_DIARIO$PTeaCobro$2 = @vTeapago
					    SET @OBTENER_SALDO_DIARIO$pPromedio$2 = @vPromedio
                        SET @OBTENER_SALDO_DIARIO$pCupoSobregiro$2 = @vCuposobregiroDiario
                        BEGIN
                           SET @OBTENER_SALDO_DIARIO$PSaldo$2 = NULL
                           SET @OBTENER_SALDO_DIARIO$PTeaPago$2 = NULL
                           SET @OBTENER_SALDO_DIARIO$PTeaCobro$2 = NULL
                           SET @OBTENER_SALDO_DIARIO$pPromedio$2 = NULL
                           SET @OBTENER_SALDO_DIARIO$pCupoSobregiro$2 = NULL
                           DECLARE
                              @OBTENER_SALDO_DIARIO$vSalAux$2 numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vLiq$2 numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vTasaPagoAux$2 numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vTasaCobroAux$2 numeric(15, 2), 
                              @OBTENER_SALDO_DIARIO$vPromedioAux$2 numeric(15, 2), 
                   @OBTENER_SALDO_DIARIO$vCupoSobregiroAux$2 numeric(15, 2)
                           BEGIN
                              BEGIN TRY
                                 SELECT 
                                    @OBTENER_SALDO_DIARIO$vSalAux$2 = GRL_SALDOS_DIARIOS.SALDO_AL_CORTE, 
                                   -- @OBTENER_SALDO_DIARIO$vLiq$2 = abs(GRL_SALDOS_DIARIOS.INT_A_LIQUIDAR), 
				                     @OBTENER_SALDO_DIARIO$vTasaPagoAux$2 = GRL_SALDOS_DIARIOS.TASAINTERESPAGO, 
                                    @OBTENER_SALDO_DIARIO$vTasaCobroAux$2 = GRL_SALDOS_DIARIOS.TASAINTERESCOBRO, 
                                    --@OBTENER_SALDO_DIARIO$vPromedioAux$2 = GRL_SALDOS_DIARIOS.PROMEDIOPAGO, 
                                    @OBTENER_SALDO_DIARIO$vCupoSobregiroAux$2 = GRL_SALDOS_DIARIOS.CUPO_SOBREGIRO
                                 FROM dbo.GRL_SALDOS_DIARIOS with (nolock)
                                 WHERE 
                                    GRL_SALDOS_DIARIOS.SALDOS_JTS_OID = @OBTENER_SALDO_DIARIO$pJTSOID$2 AND 
                                    GRL_SALDOS_DIARIOS.FECHA = @OBTENER_SALDO_DIARIO$pFECHA$2 AND 
                                    GRL_SALDOS_DIARIOS.TZ_LOCK = 0

                                 --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT

                              END TRY

                              BEGIN CATCH

                                 DECLARE
                                    @OBTENER_SALDO_DIARIO$errornumber$2 int

                                 SET @OBTENER_SALDO_DIARIO$errornumber$2 = ERROR_NUMBER()
                                 DECLARE
                                    @OBTENER_SALDO_DIARIO$errormessage$2 nvarchar(4000)
                                 SET @OBTENER_SALDO_DIARIO$errormessage$2 = ERROR_MESSAGE()
                                 DECLARE
                                    @OBTENER_SALDO_DIARIO$exceptionidentifier$2 nvarchar(4000)
                                 SELECT @OBTENER_SALDO_DIARIO$exceptionidentifier$2 = (@OBTENER_SALDO_DIARIO$errormessage$2 +'' ''+ @OBTENER_SALDO_DIARIO$errornumber$2)
                                 IF (@OBTENER_SALDO_DIARIO$exceptionidentifier$2 LIKE N''ORA+00100%'')
                                    BEGIN
                                       /* no hay saldo diario para esa fecha*/
                                       SET @OBTENER_SALDO_DIARIO$vSalAux$2 = 0
                                       SET @OBTENER_SALDO_DIARIO$vLiq$2 = 0
                                       SET @OBTENER_SALDO_DIARIO$vTasaPagoAux$2 = 0
							SET @OBTENER_SALDO_DIARIO$vTasaCobroAux$2 = 0
                                      SET @OBTENER_SALDO_DIARIO$vPromedioAux$2 = 0
                                       SET @OBTENER_SALDO_DIARIO$vCupoSobregiroAux$2 = 0
                                    END
          ELSE 
                                    BEGIN
                                       IF (@OBTENER_SALDO_DIARIO$exceptionidentifier$2 IS NOT NULL)
                                          BEGIN
                                             IF @OBTENER_SALDO_DIARIO$errornumber$2 = 59998
                                                RAISERROR(59998, 16, 1, @OBTENER_SALDO_DIARIO$exceptionidentifier$2)
                                             ELSE 
                                                RAISERROR(59999, 16, 1, @OBTENER_SALDO_DIARIO$exceptionidentifier$2)
                                          END
                                       ELSE 
                                          BEGIN
                                             SELECT ERROR_MESSAGE()
                                          END
                                    END
                              END CATCH
                           END
                           /* A los productos de tipo 4 se les suman los intereses a liquidar*/
           IF @OBTENER_SALDO_DIARIO$PTIPOPROD$2 = 4
                              SET @OBTENER_SALDO_DIARIO$vSalAux$2 = @OBTENER_SALDO_DIARIO$vSalAux$2 + @OBTENER_SALDO_DIARIO$vLiq$2
                           SET @OBTENER_SALDO_DIARIO$PSaldo$2 = @OBTENER_SALDO_DIARIO$vSalAux$2
                           SET @OBTENER_SALDO_DIARIO$PTeaPago$2 = @OBTENER_SALDO_DIARIO$vTasaPagoAux$2
                           SET @OBTENER_SALDO_DIARIO$PTeaCobro$2 = @OBTENER_SALDO_DIARIO$vTasaCobroAux$2
                           SET @OBTENER_SALDO_DIARIO$pPromedio$2 = @OBTENER_SALDO_DIARIO$vPromedioAux$2
                           SET @OBTENER_SALDO_DIARIO$pCupoSobregiro$2 = @OBTENER_SALDO_DIARIO$vCupoSobregiroAux$2
                        END
                        SET @vSalDiaIni = @OBTENER_SALDO_DIARIO$PSaldo$2
                        SET @vTeacobro = @OBTENER_SALDO_DIARIO$PTeaPago$2
                        SET @vTeapago = @OBTENER_SALDO_DIARIO$PTeaCobro$2
                        SET @vPromedio = @OBTENER_SALDO_DIARIO$pPromedio$2
                        SET @vCuposobregiroDiario = @OBTENER_SALDO_DIARIO$pCupoSobregiro$2
                     END
                     /* Valor absoluto del saldo ini*/
                     SET @vSaldoCalcLineaABS = abs(@vSalDiaIni)
                     SET @vSaldoCalcLinea = ISNULL(@vSalDiaIni,0)--LUCIA
                     SET @vCantDeb = 0
                     SET @vCantCred = 0
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
                     SET @vPeriodicidad = @vPeriodEC
                     IF @vPeriodicidad IN ( '' '', ''M'' )
                        SET @vPeriodicidad = ''C''
                     ELSE 
                        SET @vPeriodicidad = ''P''
                     SET @vCanal = @vCorreo
                     IF @vCanal <> ''N'' AND @vCanal <> ''E''
                        /*
                        *            vCanal:=''N'';
                        *    MC 01-10-2010
                        */
           SET @vCanal = ''S''
           /*Obtengo nombre sucursal*/
					BEGIN
                        BEGIN TRY
							SELECT @vNombreSucursal = SUCURSALES.NOMBRESUCURSAL
							FROM dbo.SUCURSALES with (nolock)
							WHERE SUCURSALES.SUCURSAL = @vSucursal 
									AND ((SUCURSALES.TZ_LOCK < 300000000000000 
											OR SUCURSALES.TZ_LOCK >= 400000000000000
										  ) 
											AND (SUCURSALES.TZ_LOCK < 100000000000000 
													OR SUCURSALES.TZ_LOCK >= 200000000000000
												)
										)
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$3 int
                           SET @errornumber$3 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$3 nvarchar(4000)
                           SET @errormessage$3 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$3 nvarchar(4000)
                           SELECT @exceptionidentifier$3 = (@errormessage$3+'' ''+@errornumber$3)
                           IF (@exceptionidentifier$3 LIKE N''ORA+00100%'')
                              /* Sin datos en tabla sucursales*/
                              SET @vNombreSucursal = NULL
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$3 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$3 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$3)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$3)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                       /*Obtengo nombre del producto*/
					BEGIN
                        BEGIN TRY
                           SELECT @vNombreProducto = PRODUCTOS.C6251
                           FROM dbo.PRODUCTOS with (nolock)
                           WHERE PRODUCTOS.C6250 = @vProd 
								AND ((PRODUCTOS.TZ_LOCK < 300000000000000 
										OR PRODUCTOS.TZ_LOCK >= 400000000000000) 
										AND (PRODUCTOS.TZ_LOCK < 100000000000000 
											OR PRODUCTOS.TZ_LOCK >= 200000000000000)
									)
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$4 int
                           SET @errornumber$4 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$4 nvarchar(4000)
                           SET @errormessage$4 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$4 nvarchar(4000)
                           SELECT @exceptionidentifier$4 = (@errormessage$4+'' ''+@errornumber$4)
                           IF (@exceptionidentifier$4 LIKE N''ORA+00100%'')
                              /* Sin datos en tabla productos*/
                              SET @vNombreProducto = NULL
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$4 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$4 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$4)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$4)
                                    END
                                 ELSE 
                            BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                        /*Obtengo nombre Moneda*/
					BEGIN
             BEGIN TRY
  						   IF @vMoneda IN (SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO IN (18,709))
  						   BEGIN
  						   SELECT @vMonedaCAB = C6400 FROM dbo.MONEDAS with (nolock)
                           WHERE C6399 = (SELECT MONNAC FROM PARAMETROS) AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000))
  						   END
  						   ELSE
  						   BEGIN
                           SELECT @vMonedaCAB = C6400 FROM dbo.MONEDAS with (nolock)
                           WHERE C6399 = @vMoneda AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000))
                           END
                           SELECT @vResumenEn = C6400 FROM dbo.MONEDAS with (nolock)
                           WHERE C6399 = @vMoneda AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000))
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$24 int
                           SET @errornumber$24 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$24 nvarchar(4000)
                           SET @errormessage$24 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$24 nvarchar(4000)
                           SELECT @exceptionidentifier$24 = (@errormessage$24+'' ''+@errornumber$24)
                           IF (@exceptionidentifier$24 LIKE N''ORA+00100%'')
                              /* Sin datos en tabla monedas*/
                              BEGIN
                              SET @vMonedaCAB = NULL
                              SET @vResumenEn = NULL
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$24 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$24 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$24)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$24)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                     /*Obtengo CBU*/
					BEGIN
                        BEGIN TRY
                           SELECT @vCBU = VTA_SALDOS.CTA_CBU
                           FROM dbo.VTA_SALDOS with (nolock)
                           WHERE VTA_SALDOS.JTS_OID_SALDO = @vJTSOID 
								AND VTA_SALDOS.TZ_LOCK = 0
                          --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$5 int
                           SET @errornumber$5 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$5 nvarchar(4000)
                           SET @errormessage$5 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$5 nvarchar(4000)
                           SELECT @exceptionidentifier$5 = (@errormessage$5+'' ''+@errornumber$5)
                           IF (@exceptionidentifier$5 LIKE N''ORA+00100%'')
                              /* Sin datos del CBU*/
                              SET @vCBU = NULL
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$5 IS NOT NULL)
        BEGIN
                                       IF @errornumber$5 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$5)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$5)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                     /*Obtengo Saldo al día anterior de inicio*/
					BEGIN
                           SELECT @vSaldoINI = GRL_SALDOS_DIARIOS.SALDO_AL_CORTE
                           FROM dbo.GRL_SALDOS_DIARIOS with (nolock)
                           WHERE GRL_SALDOS_DIARIOS.SALDOS_JTS_OID = @vJTSOID 
									AND GRL_SALDOS_DIARIOS.TZ_LOCK = 0
									AND GRL_SALDOS_DIARIOS.FECHA = DATEADD(DAY,-1,@vFechaIni);
						  /* Sin registro de saldo a esa fecha*/
						  SET @vSaldoINI = ISNULL(@vSaldoINI,0)
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                       -- END TRY
--                        BEGIN CATCH
--                           DECLARE
--                              @errornumber$6 int
--
--                           SET @errornumber$6 = ERROR_NUMBER()
--
--                           DECLARE
--                              @errormessage$6 nvarchar(4000)
--
--                           SET @errormessage$6 = ERROR_MESSAGE()
--
--                           DECLARE
--                              @exceptionidentifier$6 nvarchar(4000)
--
--                           SELECT @exceptionidentifier$6 = (@errormessage$6+'' ''+@errornumber$6)
--
--                           IF (@exceptionidentifier$6 LIKE N''ORA+00100%'')
--                            /* Sin registro de saldo a esa fecha*/
--							SET @vSaldoINI = 0
--
--                           ELSE 
--                              BEGIN
--                                 IF (@exceptionidentifier$6 IS NOT NULL)
--                                    BEGIN
--                                       IF @errornumber$6 = 59998
--                                          RAISERROR(59998, 16, 1, @exceptionidentifier$6)
--                                       ELSE 
--                                          RAISERROR(59999, 16, 1, @exceptionidentifier$6)
--                                    END
--                                 ELSE 
--                                    BEGIN
--                                   SELECT ERROR_MESSAGE()
--                                    END
--                              END
--
--                        END CATCH
                     END
                     BEGIN
                        BEGIN TRY
                           SELECT @vDocTitular = NUMERODOC, @vNomTitular = NOMBRE, @vTipoPersona = TIPOPERSONA,
                           @vNroPersona = NUMEROPERSONA
                           FROM VW_CLIENTES_PERSONAS with (nolock) 
						   WHERE CODIGOCLIENTE = @vCliente 
								AND TITULARIDAD = ''T''

                           SELECT @vnomcli = CLI_CLIENTES.NOMBRECLIENTE, @vTipoCliente = CLI_CLIENTES.TIPO
                           FROM dbo.CLI_CLIENTES with (nolock)
                           WHERE CLI_CLIENTES.CODIGOCLIENTE = @vCliente 
								AND ((CLI_CLIENTES.TZ_LOCK < 300000000000000 OR CLI_CLIENTES.TZ_LOCK >= 400000000000000) AND (CLI_CLIENTES.TZ_LOCK < 100000000000000 OR CLI_CLIENTES.TZ_LOCK >= 200000000000000))
                           IF @vTipoPersona = ''F''
                           SET @vFormato = ''PF''
                           IF @vTipoPersona = ''J''
                           SET @vFormato =  ''PJ''
                           /*IF @vTipoCliente = ''I''
                           SET @vFormato = ''CJ''*/
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$7 int
                           SET @errornumber$7 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$7 nvarchar(4000)
                           SET @errormessage$7 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$7 nvarchar(4000)
                           SELECT @exceptionidentifier$7 = (@errormessage$7+'' ''+@errornumber$7)
                           IF (@exceptionidentifier$7 LIKE N''ORA+00100%'')
                              /* Sin datos en tabla clientes*/
                              BEGIN
                              SET @vnomcli = NULL
                              SET @vTipoCliente = NULL
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$7 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$7 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$7)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$7)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                     /* Obtiene datos para cabezal con dirección del cliente*/
                     BEGIN
                        BEGIN TRY
						PRINT @vCliente
						PRINT @vFormato
						PRINT @vTipoDireccion
                           SELECT 
                              @vCalle = CLI_DIRECCIONES.CALLE, 
                              @vNumeroPuerta = CLI_DIRECCIONES.NUMERO, 
                              @vApartamento = CLI_DIRECCIONES.APARTAMENTO, 
							  @vPiso = CLI_DIRECCIONES.PISO, 
                              @vCiudadLocalidad = (SELECT DESCRIPCION_DIM3 
													FROM CLI_LOCALIDADES with (nolock) 
													WHERE CODIGOPAIS = CLI_DIRECCIONES.PAIS AND
															DIM1 = CLI_DIRECCIONES.PROVINCIA AND 
															DIM2 = CLI_DIRECCIONES.DEPARTAMENTO AND 
															DIM3 = CLI_DIRECCIONES.LOCALIDAD),
                              @vProvincia = (SELECT DESCRIPCION 
												FROM CLI_PROVINCIAS with (nolock)
												WHERE DIM1 = CLI_DIRECCIONES.PROVINCIA),
                              @vCodigoPais = CLI_DIRECCIONES.PAIS, 
                              @vCodigoPostal = CLI_DIRECCIONES.CPA_NUEVO,
                              @vBarrio = CLI_DIRECCIONES.BARRIO
                           FROM dbo.CLI_DIRECCIONES with (nolock)
                           WHERE 
                              CLI_DIRECCIONES.ID = @vNroPersona AND 
                              CLI_DIRECCIONES.TIPODIRECCION = @vTipoDireccion AND 
                              CLI_DIRECCIONES.FORMATO = @vFormato AND
                              CLI_DIRECCIONES.ORDINAL_DIR = (SELECT MIN(DIR.ORDINAL_DIR) 
																FROM CLI_DIRECCIONES DIR with (nolock)
																WHERE DIR.ID = @vNroPersona 
																	AND DIR.TIPODIRECCION = @vTipoDireccion 
																	AND DIR.FORMATO = @vFormato
															)
							  AND ((CLI_DIRECCIONES.TZ_LOCK < 300000000000000 OR CLI_DIRECCIONES.TZ_LOCK >= 400000000000000) AND (CLI_DIRECCIONES.TZ_LOCK < 100000000000000 OR CLI_DIRECCIONES.TZ_LOCK >= 200000000000000))
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$2 int
                           SET @errornumber$2 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$2 nvarchar(4000)
                           SET @errormessage$2 = ERROR_MESSAGE()
    DECLARE
                        @exceptionidentifier$2 nvarchar(4000)
                           SELECT @exceptionidentifier$2 = (@errormessage$2+'' ''+ @errornumber$2)
                           IF (@exceptionidentifier$2 LIKE N''ORA+00100%'')
                              BEGIN
                                 /* Cliente Sin direccion de envío*/
                                 SET @vCalle = NULL
                                 SET @vNumeroPuerta = NULL
                                 SET @vApartamento = NULL
                                 SET @vPiso = 0
                                 SET @vCiudadLocalidad = NULL
                                 SET @vProvincia = NULL
                                 SET @vCodigoPais = 0
                                 SET @vCodigoPostal = NULL
                                 SET @vBarrio = NULL
                                 SET @vFormato = NULL
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$2 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$2 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$2)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$2)
                                    END
                                 ELSE 
                                    BEGIN
                                       SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                     /* Obtiene datos de las personas que integran el cliente */
                     BEGIN
                        BEGIN TRY
						SELECT @vCantTitulares = count(*) 
						FROM VW_CLIENTES_PERSONAS with (nolock)
						WHERE CODIGOCLIENTE = @vCliente
						SELECT @vDocTitular = NUMERODOC, @vNomTitular = NOMBRE 
						FROM VW_CLIENTES_PERSONAS with (nolock)
						WHERE CODIGOCLIENTE = @vCliente 
								AND TITULARIDAD = ''T''
						IF(@vCantTitulares = 2)
						SELECT TOP 1 @vDocTitular2 = NUMERODOC,@vNomTitular2 = NOMBRE 
						FROM VW_CLIENTES_PERSONAS with (nolock)
						WHERE CODIGOCLIENTE = @vCliente 
								AND TITULARIDAD != ''T'' 
						IF(@vCantTitulares > 2)
						BEGIN
						/*Obtiene otras personas que conforman el cliente*/
						WITH CLIPER AS
						(
						 SELECT NUMERODOC, NOMBRE, ROW_NUMBER() OVER (ORDER BY NUMEROPERSONA) RN
						 FROM VW_CLIENTES_PERSONAS with (nolock)
						 WHERE CODIGOCLIENTE = @vCliente 
								AND TITULARIDAD != ''T'' 
						)
						SELECT @vDocTitular2 = MAX(CASE WHEN RN = 1 THEN NUMERODOC END),
							   @vNomTitular2 = MAX(CASE WHEN RN = 1 THEN NOMBRE END),
       						   @vDocTitular3 = MAX(CASE WHEN RN = 2 THEN NUMERODOC END),
							   @vNomTitular3 = MAX(CASE WHEN RN = 2 THEN NOMBRE END)
						FROM CLIPER with (nolock)
						WHERE RN <= 2;
						END
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$8 int
                           SET @errornumber$8 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$8 nvarchar(4000)
                           SET @errormessage$8 = ERROR_MESSAGE()
    DECLARE
                        @exceptionidentifier$8 nvarchar(4000)
                           SELECT @exceptionidentifier$8 = (@errormessage$8+'' ''+ @errornumber$8)
                           IF (@exceptionidentifier$8 LIKE N''ORA+00100%'')
                              BEGIN
                                 SET @vCantTitulares = 0
                                 SET @vDocTitular = NULL
                                 SET @vNomTitular = NULL 
                                 SET @vDocTitular2 = NULL
                                 SET @vNomTitular2 = NULL 
                                 SET @vDocTitular3 = NULL
                                 SET @vNomTitular3 = NULL 
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$8 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$8 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$8)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$8)
                                    END
                                 ELSE 
                                    BEGIN
                                       SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH

                     END
                     SET @vIdCab = @vIdCab + 1
					 PRINT @vIdCab
					 BEGIN TRY
                     INSERT dbo.GRL_CAB_ENVIO_ESTCTA(
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
                        VALUES (
                           @vLegal, 
                           @vPeriodo, 
                           @vIdCab, 
                           @vCliente, 
                           @vTipoDireccion,
                           @vFechaIni,
                           @vFechaFin,
                           @vCuenta,
                           @vTipoProd,
                           @vNombreProducto,
                           @vMonedaCAB,
                           @vResumenEn,
                           @vCBU,
                           ISNULL(@vSalDiaIni,0),
                           @vSucursal,
							 @vNombreSucursal,
							 @vJTSOID,
							 @vNomCli,
							 @vCalle,
							 @vNumeroPuerta,
							 @vApartamento,
							 @vPiso,
							 @vCiudadLocalidad,
							 @vCodigoPais,
							 @vCodigoPostal,
							 @vFechaProc,
							 @vBarrio,
							 @vCantTitulares,
							 @vNomTitular,
							 @vDocTitular,
							 @vNomTitular2,
							 @vDocTitular2,
							 @vNomTitular3,
							 @vDocTitular3,
							 @vDocTitular,
							 @vProvincia)
                      END TRY
					 BEGIN CATCH
					 PRINT ''NO INSERTA''
					 PRINT ERROR_MESSAGE()
					 END CATCH
                  /* MOV ''I''*/
            SET @vIdDet = @vIdDet + 1
            PRINT @vIdDet
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
                        VALUES (
                           @vLegal, 
                           @vPeriodo, 
                           @vIdCab, 
                           @vIdDet, 
                           @vSucursal, 
                           @vTipoProd, 
                           @vProd, 
                           @vCuenta, 
                           @vMoneda, 
                           @vOperacion, 
                           @vOrdinal, 
                           @vPeriodicidad, 
                           @vCanal, 
                           ''I'', 
                           @vFechaIni, 
                           ''Saldo Inicial'', 
                           @vSucursal, 
                           0, 
                           NULL, 
                           0, 
                           0, 
                           ISNULL(@vSalDiaIni,0), --LUCIA
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
                           @vJTSOID)
					 END TRY
					 BEGIN CATCH
					 PRINT ''NO INSERTA''
					 PRINT ERROR_MESSAGE()
					 END CATCH
					 SET @vIdDet = 0
                     IF @@TRANCOUNT > 0
                        COMMIT WORK 
                  END
               DECLARE
                   cMovsContables CURSOR LOCAL FOR 
                     SELECT 
                        M.FECHAPROCESO, 
                        M.CONCEPTO, 
                        M.SUCURSAL, 
                        M.ASIENTO, 
                        M.FECHAVALOR, 
                        M.DEBITOCREDITO, 
                        M.TIPO, 
    					M.CAPITALREALIZADO, 
                        M.REFERENCIA, 
                        M.OPERACION AS OPERACION_TOPAZ,
                        M.COD_TRANSACCION
                     FROM	dbo.MOVIMIENTOS_CONTABLES  AS M with (nolock) 
							inner join dbo.ASIENTOS  AS A with (nolock) on M.ASIENTO = A.ASIENTO
																		   AND M.FECHAPROCESO = A.FECHAPROCESO
																		   AND M.SUCURSAL = A.SUCURSAL
																		   AND M.FECHAPROCESO >= @vFechaIni 
																		   AND M.FECHAPROCESO <= @vFechaFin 
																		   AND M.SUCURSAL_CUENTA = @vSucursal
																		   AND M.RUBROCONTABLE = @vRubro
																		   AND M.MONEDA = @vMoneda
																		   AND M.CLIENTE = @vCliente
																		   AND M.CUENTA = @vCuenta
																		   AND M.OPERACION_CUENTA = @vOperacion
																		   AND M.ORDINAL_CUENTA = @vOrdinal
																		   AND A.ESTADO = 77
                     ORDER BY
                        M.FECHAPROCESO, 
                        M.HORASISTEMA,
                      	M.SUCURSAL_CUENTA, 
                        M.MONEDA, 
                        M.CUENTA, 
      					M.PRODUCTO, 
                        M.OPERACION_CUENTA, 
                        M.ORDINAL_CUENTA, 
                        M.ASIENTO

               /* Graba MOVs M obteniendo los datos de los movimientos dependiendo del tipo de producto*/
               OPEN cMovsContables
               WHILE 1 = 1
                  BEGIN
                     SET @vImporteD = 0
                     SET @vImporteC = 0
                     FETCH cMovsContables
                         INTO 
                           @vFechaProcesado, 
                           @vConcepto, 
                           @vSucursalOrigen, 
                           @vAsiento, 
                           @vFechaValor, 
                           @vSignoMov, 
                           @vTipoMov, 
							@vMonto, 
                           @vReferencia, 
							@vOperacionTopaz,
                           @vCodTransaccion
                     /*
                     *   SSMA warning messages:
                     *   O2SS0113: The value of @@FETCH_STATUS might be changed by previous FETCH operations on other cursors, if the cursors are used simultaneously.
                     */
                     IF @@FETCH_STATUS <> 0
                        BREAK
                     ELSE
                        SET @vCantidad2 += 1
                     IF @vMonto <> 0
                        BEGIN
                           /* Referencia (antes sacaba referencia de hist vista(tprod 2 y 3), ahora es el asiento del movtoctable en todos los casos)*/
                           IF (@vReferencia IS NULL OR @vReferencia = 0)
                              SET @vReferencia = @VAsiento
                           /* Acumula debitos y creditos*/
                           IF @vSignoMov = ''D''
                              BEGIN
                                 SET @vImporteD = @vMonto
                                 PRINT @vImporteD
                                 SET @vCantDeb = @vCantDeb + 1
                              END
                           ELSE 
                              BEGIN
                                 SET @vImporteC = @vMonto
                                 PRINT @vImporteC
                                 SET @vCantCred = @vCantCred + 1
                              END
                           /* Acumula saldo según signo: Mismo signo => suma el monto, de lo contrario lo resta*/
                           IF @vSignoSal = @vSignoMov
                           BEGIN
                           	  PRINT @vSaldoCalcLinea
                              PRINT @vMonto
                              SET @vSaldoCalcLinea = @vSaldoCalcLinea + @vMonto
                              PRINT @vSaldoCalcLinea
                           END
                           ELSE 
                           BEGIN
                           	  PRINT @vSaldoCalcLinea
                              PRINT @vMonto
                              SET @vSaldoCalcLinea = @vSaldoCalcLinea - @vMonto
                              PRINT @vSaldoCalcLinea
                           END
                              /*Obtengo detalle transacción y si corresponde info extendida*/
					BEGIN
                        BEGIN TRY
                        PRINT ''Cod trans''
                        PRINT @vCodTransaccion
                        IF @vCodTransaccion IS NOT NULL
                        BEGIN
                           SELECT @vDetalleTr = DESCRIPCION, @vInfoExtendida = INFO_EXTENDIDA
                           FROM TTR_CODIGO_TRANSACCION_DEF WITH (NOLOCK)
                           WHERE ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)) AND CODIGO_TRANSACCION = @vCodTransaccion
                           END 
                             ELSE 
						BEGIN
						PRINT ''Es NULL''
							SET @vDetalleTr = @vConcepto
							END 
						IF @vCodTransaccion <> 0
                        BEGIN
                           SELECT @vDetalleTr = DESCRIPCION, @vInfoExtendida = INFO_EXTENDIDA
                           FROM TTR_CODIGO_TRANSACCION_DEF WITH (NOLOCK)
                           WHERE ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)) AND CODIGO_TRANSACCION = @vCodTransaccion
                           END
                           ELSE 
						BEGIN
						PRINT ''Es 0''
							SET @vDetalleTr = @vConcepto
							END 
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$9 int
                           SET @errornumber$9 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$9 nvarchar(4000)
                           SET @errormessage$9 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$9 nvarchar(4000)
                           SELECT @exceptionidentifier$9 = (@errormessage$9+'' ''+@errornumber$9)
                           IF (@exceptionidentifier$9 LIKE N''ORA+00100%'')
                              /* Sin datos en tabla de códigos de transacción*/
							  BEGIN
                              SET @vDetalleTr = NULL
                              SET @vInfoExtendida = NULL
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$9 IS NOT NULL)
                                    BEGIN
                                      IF @errornumber$9 = 59998
                              RAISERROR(59998, 16, 1, @exceptionidentifier$9)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$9)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                     /* OBTENGO CREDEB Y SIRCREB */
                     	BEGIN
                        BEGIN TRY
                        /* CREDEB */
						IF @vCodTransaccion IN (SELECT CODIGO_TRANSACCION 
												FROM CI_CARGOS WITH (NOLOCK) 
												WHERE TIPO_CARGO_IMPOSITIVO = 6) 
														OR @vCodTransaccion IN 
																		(SELECT CODIGO_TRANSACCION 
																			FROM CI_IMPUESTOS WITH (NOLOCK)
																			WHERE TIPO_IMPUESTO = 6)
						BEGIN
						SET @vCREDEBAUX = NULL
                        SET @vCREDEBAUX = @vMonto
                        
                        PRINT ''CREDEB''
                        PRINT @vCREDEBAUX
                        PRINT @vAsiento
                        PRINT @vOperacionTopaz
                        PRINT @vSucursalOrigen

						IF @vCREDEBAUX IS NOT NULL
						BEGIN
                        SET @vCREDEB = @vCREDEB + @vCREDEBAUX
                        PRINT @vCREDEB
                        END
                        END
                        /*SIRCREB*/
						IF @vCodTransaccion IN (SELECT CODIGO_TRANSACCION 
												FROM CI_CARGOS WITH (NOLOCK)
												WHERE TIPO_CARGO_IMPOSITIVO = 5) 
														OR @vCodTransaccion IN (SELECT CODIGO_TRANSACCION 
																				FROM CI_IMPUESTOS WITH (NOLOCK) 
																				WHERE TIPO_IMPUESTO = 5)
						BEGIN
						SET @vSIRCREBAUX = NULL
                        SET @vSIRCREBAUX = @vMonto
                        
                        IF @vSIRCREBAUX IS NOT NULL
                        BEGIN
                        SET @vSIRCREB = @vSIRCREB + @vSIRCREBAUX
						END
                        END
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$10 int
                           SET @errornumber$10 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$10 nvarchar(4000)
                           SET @errormessage$10 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$10 nvarchar(4000)
                           SELECT @exceptionidentifier$10 = (@errormessage$10+'' ''+@errornumber$10)
                         IF (@exceptionidentifier$10 LIKE N''ORA+00100%'')
                              /* Sin datos*/
							  BEGIN
							  SET @vCREDEB = 0
							  SET @vSIRCREB = 0
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$10 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$10 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$10)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$10)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                     /* INFO EXTENDIDA */
                     IF @vInfoExtendida = ''S''
                     BEGIN
                     PRINT ''ENTRA ACA EN INFO EXT''
                     /*Préstamos*/
                     /*IF @vOperacionTopaz IN ()
                     	BEGIN
						
						SET @vNroPrestamo = @vCuenta
						
                        BEGIN TRY
                        
                        SELECT @vBonificacionP = BONIFICACION, @vCuotaP = CUOTA FROM BS_PAYS_DETAIL
                        WHERE NROASIENTOMOV = @vAsiento 
                        
						SET @vLineaInfo = ''Préstamo '' + @vNroPrestamo + '' Línea '' + @vLineaPrestamo + '' Cuota '' + @vCuotaP + ''Tit '' + @vDocTitular + '' '' + @vNomTitular + '' Bonif. $'' + @vBonificacionP
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT

                        END TRY

                        BEGIN CATCH

                           DECLARE
                              @errornumber$11 int

                           SET @errornumber$11 = ERROR_NUMBER()

                           DECLARE
                              @errormessage$11 nvarchar(4000)

                           SET @errormessage$11 = ERROR_MESSAGE()

                           DECLARE
                              @exceptionidentifier$11 nvarchar(4000)

                           SELECT @exceptionidentifier$11 = (@errormessage$11+'' ''+@errornumber$11)

                           IF (@exceptionidentifier$11 LIKE N''ORA+00100%'')
                             
							  BEGIN
							  
							  SET @vNroPrestamo = 0
							  
							  SET @vLineaPrestamo = 0
							  
							  SET @vCuotaP = 0
							  
							  SET @vBonificacionP = 0
                              
                              END

                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$11 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$11 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$11)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$11)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END

                        END CATCH

                     END */
                     
                     /* Débitos directos */
                                      
                     /*IF @vOperacionTopaz IN ()
                     	BEGIN
						
						SET @vCodCliAUX = 0
						
                        BEGIN TRY
                        
                        SELECT @vCodCliAUX  = CLIENTE, @vRefDD = CONCEPTO
                        FROM MOVIMIENTOS_CONTABLES
                        WHERE ASIENTO = @vAsiento AND DEBITOCREDITO = ''C''
                        
                        SELECT @vOriginanteDD = NOMBRE, @vDocOriginanteDD = NUMERODOC
                        FROM VW_CLIENTES_PERSONAS
                        WHERE CODIGOCLIENTE = @vCodCliAUX AND TITULARIDAD = ''T''
                        
						SET @vLineaInfo = ''Originante: '' + @vOriginanteDD + '' CUIT/CUIL/DNI: '' + @vDocOriginanteDD + '' Ref.: '' + @vRefDD
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT

                        END TRY

                        BEGIN CATCH

                           DECLARE
                              @errornumber$12 int

                           SET @errornumber$12 = ERROR_NUMBER()

                           DECLARE
                              @errormessage$12 nvarchar(4000)

                           SET @errormessage$12 = ERROR_MESSAGE()

                           DECLARE
                              @exceptionidentifier$12 nvarchar(4000)

                           SELECT @exceptionidentifier$12 = (@errormessage$12+'' ''+@errornumber$12)

               IF (@exceptionidentifier$12 LIKE N''ORA+00100%'')
    
							  BEGIN
							  
							  SET @vOriginanteDD = NULL
							  
							  SET @vDocOriginanteDD = NULL
							  
							  SET @vRefDD = NULL
                              
                              END

                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$12 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$12 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$12)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$12)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END

                        END CATCH

                     END */
                     
                     /* Transferencias para crédito */
                     IF @vCodTransaccion IN (28,29,30,31,32,33,34)
                     	BEGIN
                     	SET @vCodCliAUX = 0
                        BEGIN TRY
                        SELECT @vCodCliAUX  = CLIENTE, @vRefTC = CONCEPTO
                        FROM MOVIMIENTOS_CONTABLES with (nolock)
                        WHERE ASIENTO = @vAsiento AND DEBITOCREDITO = ''D''
                        
                        SELECT @vOriginanteTC = NOMBRE, @vDocOriginanteTC = NUMERODOC
                        FROM VW_CLIENTES_PERSONAS WITH (NOLOCK)
                        WHERE CODIGOCLIENTE = @vCodCliAUX 
								AND TITULARIDAD = ''T''
						SET @vLineaInfo = ''Originante: '' + @vOriginanteTC + '' CUIT/CUIL/DNI: '' + @vDocOriginanteTC + '' Ref.: '' + @vRefTC
                        PRINT @vLineaInfo
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$13 int
                           SET @errornumber$13 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$13 nvarchar(4000)
                           SET @errormessage$13 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$13 nvarchar(4000)
                           SELECT @exceptionidentifier$13 = (@errormessage$3+'' ''+@errornumber$3)
                           IF (@exceptionidentifier$13 LIKE N''ORA+00100%'')
                              /* Sin datos*/
							  BEGIN
							  SET @vOriginanteTC = NULL
							  SET @vDocOriginanteTC = NULL
							  SET @vRefTC = NULL
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$13 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$13 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$13)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$13)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
  END
                     /* Transferencias para débito */
                     IF @vCodTransaccion IN (21,22,23,24,25,26,27)
                     	BEGIN
                     	SET @vCodCliAUX = 0
                        BEGIN TRY
                        SELECT @vCodCliAUX  = CLIENTE, @vRefTD = CONCEPTO
                        FROM MOVIMIENTOS_CONTABLES WITH (NOLOCK)
                        WHERE ASIENTO = @vAsiento 
								AND DEBITOCREDITO = ''C''
                        SELECT @vDescTD = NOMBRE, @vCuitDestTD = NUMERODOC
                        FROM VW_CLIENTES_PERSONAS WITH (NOLOCK)
                        WHERE CODIGOCLIENTE = @vCodCliAUX 
								AND TITULARIDAD = ''T''
						SET @vLineaInfo = ''CUIT Destino: '' + @vCuitDestTD + '' Descripción: '' + @vDescTD + '' Ref.: '' + @vRefTD
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$14 int
                           SET @errornumber$14 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$14 nvarchar(4000)
                           SET @errormessage$14 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$14 nvarchar(4000)
                           SELECT @exceptionidentifier$14 = (@errormessage$14+'' ''+@errornumber$14)
                           IF (@exceptionidentifier$14 LIKE N''ORA+00100%'')
                              /* Sin datos*/
							  BEGIN
							  SET @vCuitDestTD = NULL
							  SET @vDescTD = NULL
							  SET @vRefTD = NULL
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$14 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$14 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$14)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$14)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                       END
                        END CATCH
                     END
                     /* Plazo fijo */
                      IF @vCodTransaccion IN (48,49,50)
                     	BEGIN
                     	SET @vCertificadoPF = @vCuenta
                        BEGIN TRY
                        SELECT @vSucursalPF = SUCURSALMOV, 
								@vCapitalPF = CAPITALORIGINAL, 
								@vInteresesPF = INTALVTO
                        FROM BS_HISTORIA_PLAZO with (nolock)
						WHERE NROASIENTOMOV = @vAsiento
						SET @vLineaInfo = ''Suc.: '' + @vSucursalPF + '' Cert.: '' + @vCertificadoPF + '' Cap.: '' + @vCapitalPF + '' Int.: '' + @vInteresesPF
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$15 int
                           SET @errornumber$15 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$15 nvarchar(4000)
                           SET @errormessage$15 = ERROR_MESSAGE()
              DECLARE
                              @exceptionidentifier$15 nvarchar(4000)
						 SELECT @exceptionidentifier$15 = (@errormessage$15+'' ''+@errornumber$15)
                           IF (@exceptionidentifier$15 LIKE N''ORA+00100%'')
							  BEGIN
							  SET @vSucursalPF = 0
							  SET @vCertificadoPF = 0
							  SET @vCapitalPF = 0
							  SET @vInteresesPF = 0
                              END
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$15 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$15 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$15)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$15)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                     END
                     /*Obtengo Saldo al último día*/
					BEGIN
                        BEGIN TRY
                           SELECT @vSaldoFin = GRL_SALDOS_DIARIOS.SALDO_AL_CORTE
                           FROM dbo.GRL_SALDOS_DIARIOS with (nolock)
                           WHERE GRL_SALDOS_DIARIOS.SALDOS_JTS_OID = @vJTSOID 
								AND GRL_SALDOS_DIARIOS.TZ_LOCK = 0
								AND GRL_SALDOS_DIARIOS.FECHA = @vFechaFin
                           --EXECUTE sysdb.ssma_oracle.db_error_exact_one_row_check @@ROWCOUNT
                        END TRY
                        BEGIN CATCH
                           DECLARE
                              @errornumber$16 int
                           SET @errornumber$16 = ERROR_NUMBER()
                           DECLARE
                              @errormessage$16 nvarchar(4000)
                           SET @errormessage$16 = ERROR_MESSAGE()
                           DECLARE
                              @exceptionidentifier$16 nvarchar(4000)
                           SELECT @exceptionidentifier$16 = (@errormessage$16+'' ''+@errornumber$16)
                           IF (@exceptionidentifier$16 LIKE N''ORA+00100%'')
                              /* Sin registro de saldo a esa fecha*/
             SET @vSaldoFin = 0
                           ELSE 
                              BEGIN
                                 IF (@exceptionidentifier$16 IS NOT NULL)
                                    BEGIN
                                       IF @errornumber$16 = 59998
                                          RAISERROR(59998, 16, 1, @exceptionidentifier$16)
                                       ELSE 
                                          RAISERROR(59999, 16, 1, @exceptionidentifier$16)
                                    END
                                 ELSE 
                                    BEGIN
                                   SELECT ERROR_MESSAGE()
                                    END
                              END
                        END CATCH
                     END
                           /* Graba Movimiento M*/
                           SET @vIdDet = @vIdDet + 1
						   PRINT @vConcepto
						   PRINT @vDetalleTr
						   PRINT ''LLEGA a movimiento M''
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
                              DESCTRANSACCION,
                              INFOEXTENDIDA,
                              CODMOVIMIENTO,
                              JTSOID)
                              VALUES (
                                 @vLegal, 
								@vPeriodo, 
                                 @vIdCab, 
								@vIdDet, 
                                 @vSucursal, 
                                 @vTipoProd, 
                                 @vProd, 
                                 @vCuenta, 
                                 @vMoneda, 
                                 @vOperacion, 
                                 @vOrdinal, 
                                 @vPeriodicidad, 
                                 @vCanal, 
                                 ''M'', 
                                 @vFechaProcesado, 
                                 @vConcepto, 
                                 @vSucursalOrigen, 
                                 @vAsiento, 
                                 @vFechaValor, 
                                 @vImporteD, 
								@vImporteC, 
                                 @vSaldoCalcLinea, 
                                 @vReferencia, 
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
                                 @vSaldoFin,
                                 0,
                                 0,
                                 @vDetalleTr,
                                 @vLineaInfo,
                                 @vCodTransaccion,
                                 @vJTSOID)
						   END TRY
						   BEGIN CATCH
						   PRINT ERROR_MESSAGE()
						   END CATCH 
						   
                           IF @@TRANCOUNT > 0
                              COMMIT WORK 
                        END
                  END
               CLOSE cMovsContables
               DEALLOCATE cMovsContables
               /* Guarda valores anteriores para el corte de control*/
               SET @vRubro = @vRubroAnt
               SET @vClienteAnt = @vCliente
               SET @vSucursalAnt = @vSucursal
               SET @vProdAnt = @vProd
               SET @vCuentaAnt = @vCuenta
               SET @vMonedaAnt = @vMoneda
			   SET @vOperacionAnt = @vOperacion
               SET @vJTSOIDAnt = @vJTSOID
               /* Guarda los demas valores anteriores en caso de que haya que grabar MOV F*/
               SET @vTipoProdAnt = @vTipoProd
               SET @vOrdinalAnt = @vOrdinal
               SET @vSalDiaFinAnt = @vSalDiaFin
               SET @vSal24Ant = @vSal24
               SET @vSal48Ant = @vSal48
               SET @vTasaRenAnt = @vTasaRen
               SET @vPlazoRenAnt = @vPlazoRen
               SET @vGarantiaAnt = @vGarantia
               SET @vPeriodicidadAnt = @vPeriodicidad
               SET @vCanalAnt = @vCanal
               SET @vSaldoActAnt = @vSaldoAct
               SET @vCodOpVencAnt = @vCodOpVenc
               SET @vCupoSobregiroAnt = @vCupoSobregiro
               SET @vTipoTasaAnt = @vTipoTasa
               SET @vTipoDireccionAnt = @vTipoDireccion
            END
         CLOSE cSaldos
         DEALLOCATE cSaldos
         UPDATE dbo.GRL_DET_ENVIO_ESTCTA
            SET CANAL = ''E''
         FROM dbo.GRL_DET_ENVIO_ESTCTA  AS D
         WHERE D.LEGAL = ''L'' AND NOT EXISTS 
            (
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
                  C.LEGAL = D.LEGAL AND 
                  C.PERIODO = D.PERIODO AND 
                  C.IDCAB = D.IDCAB AND 
                  C.CODIGOPAIS IN ( 0, (SELECT NUMERICO 
										FROM PARAMETROSGENERALES with (nolock)
										WHERE CODIGO = 1) ) --C.CODIGOPAIS IN ( 0, 858 )
            )
         UPDATE dbo.GRL_DET_ENVIO_ESTCTA
			SET CANAL = ''S''
         FROM dbo.GRL_DET_ENVIO_ESTCTA  AS D WITH (NOLOCK)
         WHERE D.LEGAL = ''L'' AND EXISTS 
            (
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
                  C.LEGAL = D.LEGAL AND 
                  C.PERIODO = D.PERIODO AND 
                  C.IDCAB = D.IDCAB AND 
                  (C.CALLE IN ( ''.'', ''+'', ''..'', ''-'' ) OR C.CALLE IS NULL)
            )
         IF @@TRANCOUNT > 0
            COMMIT WORK 
         /* Finaliza correctamente*/
         SET @p_ret_proceso = 1
         SET @p_msg_proceso = ''Reporte de Estados de Cuenta generado exitosamente''
         PRINT @vCantidad
         PRINT @vCantidad2
      END TRY
      BEGIN CATCH
         DECLARE
            @errornumber$17 int
         SET @errornumber$17 = ERROR_NUMBER()
         DECLARE
            @errormessage$17 nvarchar(4000)
         SET @errormessage$17 = ERROR_MESSAGE()
         DECLARE
            @exceptionidentifier$17 nvarchar(4000)
         SELECT @exceptionidentifier$17 = @errormessage$17
         BEGIN
            BEGIN
               DECLARE
                  @bigerrmsg varchar(4000)
               IF @@TRANCOUNT > 0
                  ROLLBACK WORK 
               /* revierte cambios y cierra cursores*/
               /* Valores de Retorno.*/
               SET @p_ret_proceso =  @errornumber$5
               SET @p_msg_proceso = 
                  ''Error al generar EEC: ''   + 
                  ISNULL(@vDescErrorAdic, '''')
                   + 
                  ''-''
                   + 
                  ISNULL(@exceptionidentifier$5, '''')
                   + 
                  ''-''
                   + 
                  ISNULL(@bigerrmsg, '''')
                   + 
                  ISNULL(CAST(@vCliente AS nvarchar(max)), '''')
               DECLARE
                 @pkg_constantes$c_log_tipo_error varchar(8000)
                 SET @pkg_constantes$c_log_tipo_error = ''A''
               EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
                  @p_id_proceso = @p_id_proceso, 
                  @p_fch_proceso = @p_dt_proceso, 
                  @p_nom_package = ''ESTADOS DE CUENTA'', 
                  @p_cod_error = @p_ret_proceso, 
                  @p_msg_error = @p_msg_proceso, 
                  @p_tipo_error = @pkg_constantes$c_log_tipo_error
            END
         END
      END CATCH
   END
  
   --END
   
   --END;
')

SELECT * FROM MOVIMIENTOS_CONTABLES WHERE OPERACION = 8606 AND COD_TRANSACCION IN (212,213)

