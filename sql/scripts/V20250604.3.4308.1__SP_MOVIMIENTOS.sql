EXECUTE ('
	CREATE OR ALTER PROCEDURE [dbo].[SP_MOVIMIENTOS_FILAS]
		@P_jtsoid numeric(15, 0),
		@P_fechaDesde datetime,
		@P_fechaHasta datetime,
		@P_pagina integer, 
		@P_cantidad integer,
		@P_ttr nvarchar(MAX) = NULL,
		@P_fv char(1),
		@P_filter char(7) -- Aumentado a 7 para incluir ''*VALOR''
	AS
	BEGIN
		SET NOCOUNT ON;

		DECLARE @TotalFilas INT;

		SELECT @TotalFilas = COUNT(*) 
		FROM HISTORIA_VISTA h WITH (NOLOCK)
		INNER JOIN ASIENTOS A WITH (NOLOCK) ON H.ASIENTO = A.ASIENTO AND H.SUCURSAL = A.SUCURSAL AND H.FECHA_PROCESADO = A.FECHAPROCESO 
		LEFT JOIN HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) ON h.MOV_JTS_OID = hm.movJtsOid AND h.FECHA_PROCESADO = hm.fechaAsiento AND DATETRUNC(day,A.HORAFIN) = hm.fechaReloj  
		INNER JOIN saldos s WITH (NOLOCK) ON s.JTS_OID = h.SALDO_JTS_OID 
		LEFT JOIN TTR_CODIGO_TRANSACCION_DEF codTtr WITH (NOLOCK) ON h.CODIGO_TRANSACCION = codTtr.CODIGO_TRANSACCION
		LEFT JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
		LEFT JOIN GRL_SALDOS_DIARIOS sal WITH (NOLOCK) ON sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') AND h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
		LEFT JOIN VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) ON h.FECHA_VALOR = ctz.fecha AND ctz.codigo = s.moneda
		LEFT JOIN monedas mon ON ctz.codigo = mon.C6399
		WHERE a.ESTADO = 77 
		  AND h.MONTO > 0 
		  AND (
				(@P_filter = ''*PROC'' AND CAST(h.FECHA_PROCESADO AS DATE) BETWEEN @P_fechaDesde AND @P_fechaHasta)
			 OR (@P_filter = ''*TIME'' AND CAST(a.HORAFIN AS DATE) BETWEEN @P_fechaDesde AND @P_fechaHasta)
			 OR (@P_filter = ''*VALOR'' AND CAST(h.FECHA_VALOR AS DATE) BETWEEN @P_fechaDesde AND @P_fechaHasta)
			  )
		  AND h.SALDO_JTS_OID = @P_jtsoid
		  AND (@P_ttr IS NULL OR ttr.value IS NOT NULL)
		  AND (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO);

		SELECT @TotalFilas AS TotalFilas;
	END;
');

