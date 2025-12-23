execute('
ALTER  VIEW [dbo].[VW_ERROR_LIMITE] (	NRO_SOLICITUD, 
										DESCRIPCION)
AS 
   SELECT DISTINCT	E.NRO_SOLICITUD, 
					E.DESCRIPCION
   FROM dbo.CRE_ERROR_LIMITE  AS E WITH (NOLOCK)
   WHERE (	(E.TZ_LOCK < 300000000000000 OR E.TZ_LOCK >= 400000000000000) 
		AND (E.TZ_LOCK < 100000000000000 OR E.TZ_LOCK >= 200000000000000));
; ')
execute('
ALTER VIEW [dbo].[VW_EXCEPCION_NEGA_DOCUMENTO] (
												NUMEROPERSONAFJ, 
												TIPODOCUMENTO, 
												NUMERODOCUMENTO, 
												PAISDOCUMENTO, 
												FECHAPRESENTACION, 
												FECHAVENCIMIENTO, 
												REPORTAAORGANISMOCONTROL, 
												TIPOPERSONA, 
												NRO_PERSONA, 
												FECHA_VTO)
AS 
   SELECT 
      D.NUMEROPERSONAFJ, 
      D.TIPODOCUMENTO, 
      D.NUMERODOCUMENTO, 
      D.PAISDOCUMENTO, 
      D.FECHAPRESENTACION, 
      D.FECHAVENCIMIENTO, 
      D.REPORTAAORGANISMOCONTROL, 
      D.TIPOPERSONA, 
      E.NRO_PERSONA, 
      E.FECHA_VTO
   FROM dbo.CLI_DOCUMENTOSPFPJ  AS D WITH (NOLOCK), 
		dbo.CRE_EXCEPCION_NEGATIVA  AS E WITH (NOLOCK)
   WHERE 
      (		(D.TZ_LOCK < 300000000000000 OR D.TZ_LOCK >= 400000000000000) 
		AND (D.TZ_LOCK < 100000000000000 OR D.TZ_LOCK >= 200000000000000)) 
	  AND 
      (		(E.TZ_LOCK < 300000000000000 OR E.TZ_LOCK >= 400000000000000) 
		AND (E.TZ_LOCK < 100000000000000 OR E.TZ_LOCK >= 200000000000000)) 
	AND D.NUMEROPERSONAFJ = E.NRO_PERSONA
; ')
execute('
ALTER VIEW [dbo].[VW_FECHA_LIMITE] (CODIGO_GRUPO, FECHA)
AS 
   SELECT fci.CODIGO_GRUPO, max(fci.FECHA) AS FECHA
   FROM 
      (
         SELECT GEC.CODIGOGRUPOECONOMICO AS CODIGO_GRUPO, SC.FECHAVIGENCIA AS FECHA
         FROM	dbo.CRE_SOLLICCLIENTE  AS SC WITH (NOLOCK), 
				dbo.CLI_GRUPOSECONOMICOSCLIENTE  AS GEC WITH (NOLOCK)
         WHERE 
            (GEC.CODIGOCLIENTE = SC.CLIENTE) AND 
            (		(SC.TZ_LOCK < 300000000000000 OR SC.TZ_LOCK >= 400000000000000) 
				AND (SC.TZ_LOCK < 100000000000000 OR SC.TZ_LOCK >= 200000000000000)) 
			AND 
            (		(GEC.TZ_LOCK < 300000000000000 OR GEC.TZ_LOCK >= 400000000000000) 
				AND (GEC.TZ_LOCK < 100000000000000 OR GEC.TZ_LOCK >= 200000000000000))
          UNION ALL
         SELECT GEC$2.CODIGOGRUPOECONOMICO AS CODIGO_GRUPO, SI.PLAZOMAXIMO AS FECHA
         FROM dbo.CRE_SOLLICINST  AS SI WITH (NOLOCK), 
			dbo.CLI_GRUPOSECONOMICOSCLIENTE  AS GEC$2 WITH (NOLOCK)
         WHERE 
            GEC$2.CODIGOCLIENTE = SI.INSTITUCION AND 
            (	(SI.TZ_LOCK < 300000000000000 OR SI.TZ_LOCK >= 400000000000000) 
			AND (SI.TZ_LOCK < 100000000000000 OR SI.TZ_LOCK >= 200000000000000)) 
			AND 
            (	(GEC$2.TZ_LOCK < 300000000000000 OR GEC$2.TZ_LOCK >= 400000000000000) 
			AND (GEC$2.TZ_LOCK < 100000000000000 OR GEC$2.TZ_LOCK >= 200000000000000))
      )  AS fci 
   GROUP BY fci.CODIGO_GRUPO
; ')
execute('
ALTER VIEW [dbo].[VW_GRUPO_CLIENTE] (	GRUPO, 
										CODIGOCLIENTE, 
										NOMBRECLIENTE)
AS 
   SELECT LG.GRUPO, C.CODIGOCLIENTE, C.NOMBRECLIENTE
   FROM dbo.CRE_LIMITEGRUPO  AS LG WITH (NOLOCK), 
		dbo.CLI_GRUPOSECONOMICOSCLIENTE  AS GE WITH (NOLOCK), 
		dbo.CLI_CLIENTES  AS C WITH (NOLOCK)
   WHERE 
      (		(LG.TZ_LOCK < 300000000000000 OR LG.TZ_LOCK >= 400000000000000) 
		AND	(LG.TZ_LOCK < 100000000000000 OR LG.TZ_LOCK >= 200000000000000)) 
	  AND 
      (		(GE.TZ_LOCK < 300000000000000 OR GE.TZ_LOCK >= 400000000000000) 
		AND (GE.TZ_LOCK < 100000000000000 OR GE.TZ_LOCK >= 200000000000000)) 
	  AND 
      (		(C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
	    AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000)) 
	  AND LG.GRUPO = GE.CODIGOGRUPOECONOMICO 
	  AND GE.CODIGOCLIENTE = C.CODIGOCLIENTE
; ')
execute('
ALTER VIEW [dbo].[VW_GTIA_LIMITE] (
								   CLIENTE, 
								   RIESGO, 
								   FAMILIA, 
								   MONEDA, 
								   TIPO_GARANTIA, 
								   SUBTIPO_GARANTIA, 
								   SUBCLASIFICACION_GARANTIA, 
								   PAIS_GARANTIA, 
								   CONDICIONANTE_DESEMBOLSO, 
								   TIPO)
AS 
   SELECT 
      fci.CLIENTE, 
      fci.RIESGO, 
      fci.FAMILIA, 
      fci.MONEDA, 
      fci.TIPO_GARANTIA, 
      fci.SUBTIPO_GARANTIA, 
      fci.SUBCLASIFICACION_GARANTIA, 
      fci.PAIS_GARANTIA, 
      fci.CONDICIONANTE_DESEMBOLSO, 
      fci.TIPO
   FROM 
      (
         SELECT 
            LC.CLIENTE AS CLIENTE, 
            R.CODIGO_RIESGO AS RIESGO, 
            F.FAMILIAPROD AS FAMILIA, 
            M.C6399 AS MONEDA, 
            LG.TIPO_GARANTIA, 
            LG.SUBTIPO_GARANTIA, 
            LG.SUBCLASIFICACION_GARANTIA, 
            LG.PAIS_GARANTIA, 
            LG.CONDICIONANTE_DESEMBOLSO, 
            LG.TIPO
         FROM 
            dbo.CRE_LIMITECLIENTE  AS LC WITH (NOLOCK), 
            dbo.CRE_TIPOS_RIESGOS  AS R WITH (NOLOCK), 
            dbo.CRE_FAMILIAS  AS F WITH (NOLOCK), 
            dbo.MONEDAS  AS M WITH (NOLOCK), 
            dbo.CRE_LIMITE_GARANTIA  AS LG WITH (NOLOCK)
         WHERE 
            ((LC.TZ_LOCK < 300000000000000 OR LC.TZ_LOCK >= 400000000000000) AND (LC.TZ_LOCK < 100000000000000 OR LC.TZ_LOCK >= 200000000000000)) AND 
            ((R.TZ_LOCK < 300000000000000 OR R.TZ_LOCK >= 400000000000000) AND (R.TZ_LOCK < 100000000000000 OR R.TZ_LOCK >= 200000000000000)) AND 
            ((F.TZ_LOCK < 300000000000000 OR F.TZ_LOCK >= 400000000000000) AND (F.TZ_LOCK < 100000000000000 OR F.TZ_LOCK >= 200000000000000)) AND 
            ((M.TZ_LOCK < 300000000000000 OR M.TZ_LOCK >= 400000000000000) AND (M.TZ_LOCK < 100000000000000 OR M.TZ_LOCK >= 200000000000000)) AND 
            ((LG.TZ_LOCK < 300000000000000 OR LG.TZ_LOCK >= 400000000000000) AND (LG.TZ_LOCK < 100000000000000 OR LG.TZ_LOCK >= 200000000000000)) AND 
            F.RIESGO = R.CODIGO_RIESGO AND 
            LG.TIPO = ''L'' AND 
            LG.ID_LIMITE = LC.IDLIMITE AND 
            LG.CONDICIONANTE_DESEMBOLSO = ''S''
          UNION
         SELECT 
            LC$2.CLIENTE AS CLIENTE, 
            RL.CODIGO_RIESGO AS RIESGO, 
            F$2.FAMILIAPROD AS FAMILIA, 
            M$2.C6399 AS MONEDA, 
            LG$2.TIPO_GARANTIA, 
            LG$2.SUBTIPO_GARANTIA, 
            LG$2.SUBCLASIFICACION_GARANTIA, 
            LG$2.PAIS_GARANTIA, 
            LG$2.CONDICIONANTE_DESEMBOLSO, 
            LG$2.TIPO
         FROM 
            dbo.CRE_LIMITECLIENTE  AS LC$2  WITH (NOLOCK), 
            dbo.CRE_RIESGOLIC  AS RL  WITH (NOLOCK), 
            dbo.CRE_FAMILIAS  AS F$2  WITH (NOLOCK), 
            dbo.MONEDAS  AS M$2  WITH (NOLOCK), 
            dbo.CRE_LIMITE_GARANTIA  AS LG$2  WITH (NOLOCK)
         WHERE 
            ((LC$2.TZ_LOCK < 300000000000000 OR LC$2.TZ_LOCK >= 400000000000000) AND (LC$2.TZ_LOCK < 100000000000000 OR LC$2.TZ_LOCK >= 200000000000000)) AND 
            ((RL.TZ_LOCK < 300000000000000 OR RL.TZ_LOCK >= 400000000000000) AND (RL.TZ_LOCK < 100000000000000 OR RL.TZ_LOCK >= 200000000000000)) AND 
            ((F$2.TZ_LOCK < 300000000000000 OR F$2.TZ_LOCK >= 400000000000000) AND (F$2.TZ_LOCK < 100000000000000 OR F$2.TZ_LOCK >= 200000000000000)) AND 
            ((M$2.TZ_LOCK < 300000000000000 OR M$2.TZ_LOCK >= 400000000000000) AND (M$2.TZ_LOCK < 100000000000000 OR M$2.TZ_LOCK >= 200000000000000)) AND 
            ((LG$2.TZ_LOCK < 300000000000000 OR LG$2.TZ_LOCK >= 400000000000000) AND (LG$2.TZ_LOCK < 100000000000000 OR LG$2.TZ_LOCK >= 200000000000000)) AND 
            LC$2.IDLIMITE = RL.IDLIMITE AND 
            RL.APERRIESGOFAM = ''N'' AND 
            F$2.RIESGO = RL.CODIGO_RIESGO AND 
            LG$2.TIPO = ''R'' AND 
            LG$2.RIESGO = RL.CODIGO_RIESGO AND 
            LG$2.ID_LIMITE = LC$2.IDLIMITE AND 
            LG$2.CONDICIONANTE_DESEMBOLSO = ''S''
          UNION
         SELECT 
            LC$3.CLIENTE AS CLIENTE, 
            FL.CODIGO_RIESGO AS RIESGO, 
            FL.FAMILIA AS FAMILIA, 
            M$3.C6399 AS MONEDA, 
            LG$3.TIPO_GARANTIA, 
            LG$3.SUBTIPO_GARANTIA, 
            LG$3.SUBCLASIFICACION_GARANTIA, 
            LG$3.PAIS_GARANTIA, 
            LG$3.CONDICIONANTE_DESEMBOLSO, 
            LG$3.TIPO
         FROM 
            dbo.CRE_LIMITECLIENTE  AS LC$3  WITH (NOLOCK), 
            dbo.CRE_FAMILIALIC  AS FL  WITH (NOLOCK), 
            dbo.MONEDAS  AS M$3  WITH (NOLOCK), 
            dbo.CRE_LIMITE_GARANTIA  AS LG$3  WITH (NOLOCK)
         WHERE 
            ((LC$3.TZ_LOCK < 300000000000000 OR LC$3.TZ_LOCK >= 400000000000000) AND (LC$3.TZ_LOCK < 100000000000000 OR LC$3.TZ_LOCK >= 200000000000000)) AND 
            ((FL.TZ_LOCK < 300000000000000 OR FL.TZ_LOCK >= 400000000000000) AND (FL.TZ_LOCK < 100000000000000 OR FL.TZ_LOCK >= 200000000000000)) AND 
            ((M$3.TZ_LOCK < 300000000000000 OR M$3.TZ_LOCK >= 400000000000000) AND (M$3.TZ_LOCK < 100000000000000 OR M$3.TZ_LOCK >= 200000000000000)) AND 
            ((LG$3.TZ_LOCK < 300000000000000 OR LG$3.TZ_LOCK >= 400000000000000) AND (LG$3.TZ_LOCK < 100000000000000 OR LG$3.TZ_LOCK >= 200000000000000)) AND 
            LC$3.IDLIMITE = FL.IDLIMITE AND 
            /*AND fl.APERMONEDA =''N''*/LG$3.TIPO = ''F'' AND 
            LG$3.RIESGO = FL.CODIGO_RIESGO AND 
            LG$3.FAMILIA = FL.FAMILIA AND 
            LG$3.ID_LIMITE = LC$3.IDLIMITE AND 
            LG$3.CONDICIONANTE_DESEMBOLSO = ''S''
          UNION
         SELECT 
            LC$4.CLIENTE AS CLIENTE, 
            ML.CODIGO_RIESGO AS RIESGO, 
            ML.FAMILIA AS FAMILIA, 
            ML.MONEDA AS MONEDA, 
            LG$4.TIPO_GARANTIA, 
            LG$4.SUBTIPO_GARANTIA, 
            LG$4.SUBCLASIFICACION_GARANTIA, 
            LG$4.PAIS_GARANTIA, 
            LG$4.CONDICIONANTE_DESEMBOLSO, 
            LG$4.TIPO
         FROM	dbo.CRE_LIMITECLIENTE  AS LC$4  WITH (NOLOCK), 
				dbo.CRE_MONEDALIC  AS ML  WITH (NOLOCK), 
				dbo.CRE_LIMITE_GARANTIA  AS LG$4 WITH (NOLOCK)
         WHERE 
            ((LC$4.TZ_LOCK < 300000000000000 OR LC$4.TZ_LOCK >= 400000000000000) AND (LC$4.TZ_LOCK < 100000000000000 OR LC$4.TZ_LOCK >= 200000000000000)) AND 
            ((ML.TZ_LOCK < 300000000000000 OR ML.TZ_LOCK >= 400000000000000) AND (ML.TZ_LOCK < 100000000000000 OR ML.TZ_LOCK >= 200000000000000)) AND 
            ((LG$4.TZ_LOCK < 300000000000000 OR LG$4.TZ_LOCK >= 400000000000000) AND (LG$4.TZ_LOCK < 100000000000000 OR LG$4.TZ_LOCK >= 200000000000000)) AND 
            LC$4.IDLIMITE = ML.IDLIMITE AND 
            LG$4.TIPO = ''M'' AND 
            LG$4.RIESGO = ML.CODIGO_RIESGO AND 
            LG$4.FAMILIA = ML.FAMILIA AND 
            LG$4.MONEDA = ML.MONEDA AND 
            LG$4.ID_LIMITE = LC$4.IDLIMITE AND 
            LG$4.CONDICIONANTE_DESEMBOLSO = ''S''
      )  AS fci
; ')
execute('
ALTER VIEW [dbo].[VW_INTEGRANTES_SOLICITUD] (
									   SOLICITUD, 
									   PERSONA, 
									   TIPOPERSONA, 
									   ROL)
AS 
   SELECT	S.NUMEROSOLICITUD AS SOLICITUD, 
			C.NUMEROPERSONA AS PERSONA, 
			I.TIPO_PERSONA AS TIPOPERSONA, 
			''T'' AS ROL
   FROM dbo.CRE_GARANTES_INGRESOS  AS I WITH (NOLOCK), 
		dbo.CLI_CLIENTEPERSONA  AS C WITH (NOLOCK), 
		dbo.CRE_SOLICITUDCREDITO  AS S WITH (NOLOCK)
   WHERE 
      I.NRO_SOLICITUD = S.NUMEROSOLICITUD AND 
      I.PERSONA = C.NUMEROPERSONA AND 
      S.CLIENTE = C.CODIGOCLIENTE AND 
      C.TZ_LOCK = 0 AND 
      I.TZ_LOCK = 0 AND 
      S.TZ_LOCK = 0 AND 
      C.TITULARIDAD = ''T''
    UNION ALL
   /*Traigo rol Codedudores*/
   SELECT	S.NUMEROSOLICITUD AS SOLICITUD, 
			C.NUMEROPERSONA AS PERSONA, 
			I.TIPO_PERSONA AS TIPOPERSONA, 
			''C'' AS ROL
   FROM dbo.CRE_GARANTES_INGRESOS  AS I WITH (NOLOCK), 
		dbo.CLI_CLIENTEPERSONA  AS C WITH (NOLOCK), 
		dbo.CRE_SOLICITUDCREDITO  AS S WITH (NOLOCK)
   WHERE 
      I.NRO_SOLICITUD = S.NUMEROSOLICITUD AND 
      I.PERSONA = C.NUMEROPERSONA AND 
      S.CLIENTE = C.CODIGOCLIENTE AND 
      C.TZ_LOCK = 0 AND 
      I.TZ_LOCK = 0 AND 
      S.TZ_LOCK = 0 AND 
      C.TITULARIDAD <> ''T'' AND 
      I.GARANTE = ''N'' AND 
      NOT EXISTS 
      (
         SELECT 1 AS expr
         FROM	dbo.CRE_GARANTES_INGRESOS  AS II WITH (NOLOCK), 
				dbo.CRE_SOLICITUDCREDITO  AS SS WITH (NOLOCK), 
				dbo.VW_CONYUGECLIENTES  AS YY WITH (NOLOCK)
         WHERE 
            II.NRO_SOLICITUD = I.NRO_SOLICITUD AND 
            I.NRO_SOLICITUD = SS.NUMEROSOLICITUD AND 
            II.TZ_LOCK = 0 AND 
            SS.TZ_LOCK = 0 AND 
            II.PERSONA = YY.NUMEROPERSONA AND 
            SS.CLIENTE = YY.CODIGOCLIENTE AND 
            YY.TITULARIDAD = ''T'' AND 
            I.PERSONA = YY.NUMEROPERSONAFISICACONY
      )
    UNION ALL
   /*Traigo rol Garantes*/
   SELECT	S.NUMEROSOLICITUD AS SOLICITUD, 
			I.PERSONA AS PERSONA, 
			I.TIPO_PERSONA AS TIPOPERSONA, 
			''G'' AS ROL
   FROM dbo.CRE_GARANTES_INGRESOS  AS I WITH (NOLOCK), 
		dbo.CRE_SOLICITUDCREDITO  AS S WITH (NOLOCK)
   WHERE 
      I.NRO_SOLICITUD = S.NUMEROSOLICITUD AND 
      I.TZ_LOCK = 0 AND 
      S.TZ_LOCK = 0 AND 
      I.GARANTE = ''S''
    UNION ALL
   /*Traigo rol Conyuges Codeudores*/
   SELECT	S.NUMEROSOLICITUD AS SOLICITUD, 
			Y.NUMEROPERSONAFISICACONY AS PERSONA, 
			I.TIPO_PERSONA AS TIPOPERSONA, 
			''J'' AS ROL
   FROM dbo.CRE_GARANTES_INGRESOS  AS I WITH (NOLOCK), 
		dbo.CRE_SOLICITUDCREDITO  AS S WITH (NOLOCK), 
		dbo.VW_CONYUGECLIENTES  AS Y WITH (NOLOCK)
   WHERE 
      I.NRO_SOLICITUD = S.NUMEROSOLICITUD AND 
      I.PERSONA = Y.NUMEROPERSONA AND 
      S.CLIENTE = Y.CODIGOCLIENTE AND 
      I.TZ_LOCK = 0 AND 
      S.TZ_LOCK = 0 AND 
      Y.TITULARIDAD = ''T'' AND 
      EXISTS 
      (
         SELECT 1 AS expr
         FROM dbo.CRE_GARANTES_INGRESOS  AS I1 WITH (NOLOCK)
         WHERE I1.NRO_SOLICITUD = I.NRO_SOLICITUD 
			AND I1.PERSONA = Y.NUMEROPERSONAFISICACONY
      )
    UNION ALL
   /*Traigo rol Otros sin responsabilidad*/
   SELECT	S.NUMEROSOLICITUD AS SOLICITUD, 
			Y.NUMEROPERSONAFISICACONY AS PERSONA, 
			I.TIPO_PERSONA AS TIPOPERSONA, 
			''N'' AS ROL
   FROM dbo.CRE_GARANTES_INGRESOS  AS I WITH (NOLOCK), 
		dbo.CRE_SOLICITUDCREDITO  AS S WITH (NOLOCK), 
		dbo.VW_CONYUGECLIENTES  AS Y WITH (NOLOCK)
   WHERE 
      I.NRO_SOLICITUD = S.NUMEROSOLICITUD AND 
      I.PERSONA = Y.NUMEROPERSONA AND 
      S.CLIENTE = Y.CODIGOCLIENTE AND 
      I.TZ_LOCK = 0 AND 
      S.TZ_LOCK = 0 AND 
      Y.TITULARIDAD = ''T'' AND 
      NOT EXISTS 
      (
         SELECT 1 AS expr
         FROM dbo.CRE_GARANTES_INGRESOS  AS I1 WITH (NOLOCK)
         WHERE	I1.NRO_SOLICITUD = I.NRO_SOLICITUD 
				AND I1.PERSONA = Y.NUMEROPERSONAFISICACONY
      )
    UNION ALL
   /*Traigo rol Adicional*/
   SELECT CRE_SOL_TARJ_ADICI.NRO_SOLICITUD AS SOLICITUD, 
			CRE_SOL_TARJ_ADICI.ID_PERSONAS AS PERSONA, 
			CRE_SOL_TARJ_ADICI.TIPO_PERSONA AS TIPOPERSONA, 
			''A'' AS ASROL
   FROM dbo.CRE_SOL_TARJ_ADICI WITH (NOLOCK)
   WHERE CRE_SOL_TARJ_ADICI.TZ_LOCK = 0
 ; ')
execute('
ALTER VIEW [dbo].[VW_CUPONESCODNBC] (
									   CODIGOBCO, 
									   CODINTERNACIONAL, 
									   CODTITULO, 
									   NROCUPON, 
									   FECHAPAGO, 
									   MARCAPAGO, 
									   TASACUPON, 
									   INDICE, 
									   FECHACAPITALIZACION, 
									   PORCENTAJECAPITALIZACION, 
									   PERIODO, 
									   FECHAVENC)
AS 
   SELECT TOP 9223372036854775807 WITH TIES 
		  T.CODIGOBCO, 
		  T.CODINTERNACIONAL, 
		  C.CODTITULO, 
		  C.NROCUPON, 
		  C.FECHAPAGO, 
		  C.MARCAPAGO, 
		  C.TASACUPON, 
		  C.INDICE, 
		  C.FECHACAPITALIZACION, 
		  C.PORCENTAJECAPITALIZACION, 
		  C.PERIODO, 
		  C.FECHAVENC
   FROM dbo.VAL_TITULOS  AS T WITH(NOLOCK), 
		dbo.VAL_CUPONES_AMORTIZACIONES  AS C WITH(NOLOCK)
   WHERE 
      T.CODTITULO = C.CODTITULO AND 
      (		(T.TZ_LOCK < 300000000000000 OR T.TZ_LOCK >= 400000000000000) 
		AND (T.TZ_LOCK < 100000000000000 OR T.TZ_LOCK >= 200000000000000)) 
	AND 
      (		(C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
	    AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000))
   ORDER BY T.CODIGOBCO
 ; ')
execute('
ALTER VIEW [dbo].[VW_CUPONES_PROYECCION] (
									   TITULO, 
									   CUPON, 
									   NRO_CLIENTE, 
									   NOMBRE_CLIENTE, 
									   NRO_CUENTA, 
									   SALDO_JTS_OID, 
									   JTS_OID_CONTRACUENTA, 
									   NOMBRE_CONTRACUENTA, 
									   CLIENTE_CONTRACUENTA, 
									   ORIGEN)
AS 
   SELECT 
      V1.CODIGOTITULO AS TITULO, 
      V1.NUMERO_CUPON AS CUPON, 
      S1.C1803 AS NRO_CLIENTE, 
      C1.NOMBRECLIENTE AS NOMBRE_CLIENTE, 
      S1.CUENTA AS NRO_CUENTA, 
      V1.SALDO_JTS_OID AS SALDO_JTS_OID, 
      S1.C1665 AS JTS_OID_CONTRACUENTA, 
      C2.NOMBRECLIENTE AS NOMBRE_CONTRACUENTA, 
      C2.CODIGOCLIENTE AS CLIENTE_CONTRACUENTA, 
      V1.ORIGEN AS ORIGEN
   FROM 
      dbo.VAL_CUPONES_PROYECCION  AS V1 WITH (NOLOCK)
         INNER JOIN dbo.SALDOS  AS S1  WITH (NOLOCK)
				ON S1.JTS_OID = V1.SALDO_JTS_OID  
         INNER JOIN dbo.CLI_CLIENTES  AS C1  WITH (NOLOCK)
				ON S1.C1803 = C1.CODIGOCLIENTE  
         LEFT JOIN dbo.SALDOS  AS S2  WITH (NOLOCK)
				ON S2.JTS_OID = V1.SALDO_JTS_OID_CONTRACUENTA 
         LEFT JOIN dbo.CLI_CLIENTES  AS C2  WITH (NOLOCK)
				ON S2.C1803 = C2.CODIGOCLIENTE
 ; ')
execute('
ALTER VIEW [dbo].[VW_CTAS_SOBREG_CHE_Y_CTAS_ASOC] (
											   RESULTADO, 
											   JTS_OID, 
											   C1803, 
											   SUCURSAL, 
											   MONEDA, 
											   NUMERO_SERIE, 
											   NUMERO_CHEQUE, 
											   ASIENTO_FECHAPROCESO, 
											   PRODUCTO)
AS 
   SELECT TOP 9223372036854775807 WITH TIES 
		  fci.RESULTADO, 
		  fci.JTS_OID, 
		  fci.C1803, 
		  fci.SUCURSAL, 
		  fci.MONEDA, 
		  fci.NUMERO_SERIE, 
		  fci.NUMERO_CHEQUE, 
		  fci.ASIENTO_FECHAPROCESO, 
		  fci.PRODUCTO
   FROM 
      (
         SELECT 
            0 AS RESULTADO, 
            S.JTS_OID, 
            S.C1803, 
            S.SUCURSAL, 
            S.MONEDA, 
            R.NUMERO_SERIE, 
            R.NUMERO_CHEQUE, 
            R.ASIENTO_FECHAPROCESO, 
            S.PRODUCTO
         FROM	dbo.CLE_CHEQUES_CLEARING_RECIBIDO  AS R WITH (NOLOCK), 
				dbo.SALDOS  AS S  WITH (NOLOCK)
         WHERE 
            S.SUCURSAL = R.SUCURSAL AND 
            S.PRODUCTO = R.PRODUCTO AND 
            S.CUENTA = R.CUENTA AND 
            S.MONEDA = R.MONEDA AND 
            S.OPERACION = R.OPERACION AND 
            S.C1785 IN ( 2, 3 ) AND 
            substring(CAST(R.TZ_LOCK AS nvarchar(4000)), 1, 1) <> ''3'' AND 
            substring(CAST(S.TZ_LOCK AS nvarchar(4000)), 1, 1) <> ''3'' AND 
            S.C1604 < 0
          UNION
         SELECT 
            1 AS RESULTADO, 
            S1.JTS_OID, 
            S1.C1803, 
            S1.SUCURSAL, 
            S1.MONEDA, 
            R1.NUMERO_SERIE, 
            R1.NUMERO_CHEQUE, 
            R1.ASIENTO_FECHAPROCESO, 
            S1.PRODUCTO
         FROM 
            dbo.SALDOS  AS S1  WITH (NOLOCK) 
               LEFT OUTER JOIN dbo.CLE_CHEQUES_CLEARING_RECIBIDO  AS R1   WITH (NOLOCK)
               ON 
                  S1.SUCURSAL = R1.SUCURSAL AND 
                  S1.PRODUCTO = R1.PRODUCTO AND 
                  S1.CUENTA = R1.CUENTA AND 
                  S1.MONEDA = R1.MONEDA AND 
                  S1.OPERACION = R1.OPERACION AND 
                  R1.SUCURSAL = 999999, 
            dbo.MONEDAS  AS M1  WITH (NOLOCK)
         WHERE 
            S1.SUCURSAL = 1 AND 
            S1.C1785 IN ( 2, 3 ) AND 
            substring(CAST(S1.TZ_LOCK AS nvarchar(4000)), 1, 1) <> ''3'' AND 
            (NOT EXISTS 
            (
               SELECT 
                  R2$2.NUMERO_SERIE, 
                  R2$2.NUMERO_CHEQUE, 
                  R2$2.CODIGO_PLAZA, 
                  R2$2.CAMARA_COMPENSADORA, 
                  R2$2.SUCURSAL, 
                  R2$2.MONEDA, 
                  R2$2.CUENTA, 
                  R2$2.PRODUCTO, 
                  R2$2.OPERACION, 
                  R2$2.BANCO_DEPOSITANTE, 
                  R2$2.IMPORTE_CHEQUE, 
                  R2$2.ESTADO_CONTABILIZACION, 
                  R2$2.CODIGO_CAUSAL_DEVOLUCION, 
                  R2$2.ESTADO_DEVOLUCION, 
                  R2$2.DESCRIPCION_DEVOLUCION, 
                  R2$2.CODIGO_USUARIO, 
                  R2$2.FECHA, 
                  R2$2.HORA, 
                  R2$2.TZ_LOCK, 
                  R2$2.ASIENTO_POSTING, 
                  R2$2.ASIENTO_SUCURSAL, 
                  R2$2.ASIENTO_FECHAPROCESO, 
                  R2$2.CLIENTE, 
                  R2$2.PROCESADO_PREGIRO, 
                  R2$2.FECHA_EMISION, 
                  R2$2.FECHA_VENCIMIENTO, 
                  R2$2.MICRLINE, 
                  R2$2.ESTADO, 
                  R2$2.ULTIMAMODIFICACION
               FROM dbo.CLE_CHEQUES_CLEARING_RECIBIDO  AS R2$2  WITH (NOLOCK)
               WHERE 
                  S1.SUCURSAL = R2$2.SUCURSAL AND 
                  S1.PRODUCTO = R2$2.PRODUCTO AND 
                  S1.CUENTA = R2$2.CUENTA AND 
                  S1.MONEDA = R2$2.MONEDA AND 
                  S1.OPERACION = R2$2.OPERACION
            ) OR S1.C1604 >= 0) AND 
            S1.MONEDA = M1.C6399 AND 
            M1.C6403 IN ( ''N'', ''D'' ) AND 
            S1.PRODUCTO IN ( 2101, 2201 ) AND 
            EXISTS 
            (
               SELECT 
                  R2.NUMERO_SERIE, 
                  R2.NUMERO_CHEQUE, 
                  R2.CODIGO_PLAZA, 
                  R2.CAMARA_COMPENSADORA, 
                  R2.SUCURSAL, 
                  R2.MONEDA, 
                  R2.CUENTA, 
                  R2.PRODUCTO, 
                  R2.OPERACION, 
                  R2.BANCO_DEPOSITANTE, 
                  R2.IMPORTE_CHEQUE, 
                  R2.ESTADO_CONTABILIZACION, 
                  R2.CODIGO_CAUSAL_DEVOLUCION, 
                  R2.ESTADO_DEVOLUCION, 
                  R2.DESCRIPCION_DEVOLUCION, 
                  R2.CODIGO_USUARIO, 
                  R2.FECHA, 
                  R2.HORA, 
                  R2.TZ_LOCK, 
                  R2.ASIENTO_POSTING, 
                  R2.ASIENTO_SUCURSAL, 
                  R2.ASIENTO_FECHAPROCESO, 
                  R2.CLIENTE, 
                  R2.PROCESADO_PREGIRO, 
                  R2.FECHA_EMISION, 
                  R2.FECHA_VENCIMIENTO, 
                  R2.MICRLINE, 
                  R2.ESTADO, 
                  R2.ULTIMAMODIFICACION, 
                  S2.TZ_LOCK AS TZ_LOCK$2, 
                  S2.SUCURSAL AS SUCURSAL$2, 
                  S2.PRODUCTO AS PRODUCTO$2, 
                  S2.CUENTA AS CUENTA$2, 
                  S2.MONEDA AS MONEDA$2, 
                  S2.OPERACION AS OPERACION$2, 
                  S2.ORDINAL, 
                  S2.C1600, 
                  S2.C1601, 
                  S2.C1602, 
                  S2.C1603, 
                  S2.C1604, 
                  S2.C1605, 
                  S2.C1606, 
                  S2.C1607, 
                  S2.C1608, 
                  S2.C1609, 
                  S2.C1610, 
                  S2.C1611, 
                  S2.C1612, 
                  S2.C1613, 
                  S2.C1614, 
                  S2.C1615, 
                  S2.C1616, 
                  S2.C1617, 
                  S2.C1618, 
                  S2.C1619, 
                  S2.C1620, 
                  S2.C1621, 
                  S2.C1622, 
                  S2.C1623, 
                  S2.C1624, 
                  S2.C1625, 
                  S2.C1626, 
                  S2.C1627, 
                  S2.C1628, 
                  S2.C1629, 
                  S2.C1630, 
                  S2.C1631, 
                  S2.C1632, 
                  S2.C1633, 
                  S2.C1634, 
                  S2.C1635, 
                  S2.C1636, 
                  S2.C1637, 
                  S2.C1639, 
                  S2.C1640, 
                  S2.C1641, 
                  S2.C1642, 
                  S2.C1643, 
                  S2.C1644, 
                  S2.C1645, 
                  S2.C1646, 
                  S2.C1647, 
                  S2.C1648, 
                  S2.C1649, 
                  S2.C1650, 
                  S2.C1651, 
                  S2.C1652, 
                  S2.C1653, 
                  S2.C1654, 
                  S2.C1655, 
                  S2.C1657, 
                  S2.C1658, 
                  S2.C1659, 
                  S2.C1661, 
                  S2.C1662, 
                  S2.C1665, 
                  S2.C1666, 
                  S2.C1670, 
                  S2.C1671, 
                  S2.C1673, 
                  S2.C1674, 
                  S2.C1675, 
                  S2.C1676, 
                  S2.C1677, 
                  S2.C1678, 
                  S2.C1679, 
                  S2.C1680, 
                  S2.C1681, 
                  S2.C1682, 
                  S2.C1683, 
                  S2.C1684, 
                  S2.C1685, 
                  S2.C1686, 
                  S2.C1687, 
                  S2.C1688, 
                  S2.C1689, 
                  S2.C1690, 
                  S2.C1691, 
                  S2.C1692, 
                  S2.C1693, 
                  S2.C1694, 
                  S2.C1695, 
                  S2.C1696, 
                  S2.C1697, 
                  S2.C1698, 
                  S2.C1699, 
                  S2.C1700, 
                  S2.C1701, 
                  S2.C1702, 
                  S2.C1703, 
                  S2.C1704, 
                  S2.C1705, 
                  S2.C1706, 
                  S2.C1707, 
                  S2.C1708, 
                  S2.C1709, 
                  S2.C1710, 
                  S2.C1711, 
                  S2.C1712, 
                  S2.C1714, 
                  S2.C1715, 
                  S2.C1716, 
                  S2.C1717, 
                  S2.C1718, 
                  S2.C1719, 
                  S2.C1720, 
                  S2.C1721, 
                  S2.C1722, 
                  S2.C1723, 
                  S2.C1724, 
                  S2.C1725, 
                  S2.C1728, 
                  S2.C1729, 
                  S2.C1730, 
                  S2.C1747, 
                  S2.C1748, 
                  S2.C1749, 
                  S2.C1750, 
                  S2.C1751, 
                  S2.C1753, 
                  S2.C1755, 
                  S2.C1758, 
                  S2.C1760, 
                  S2.C1761, 
                  S2.C1799, 
                  S2.C1800, 
                  S2.C1801, 
                  S2.C1802, 
                  S2.C1803, 
                  S2.C1804, 
                  S2.C1806, 
                  S2.C1807, 
                  S2.C1808, 
                  S2.C1809, 
                  S2.C1756, 
                  S2.JTS_OID, 
                  S2.C1811, 
                  S2.C1812, 
                  S2.C1813, 
                  S2.C1814, 
                  S2.C1815, 
                  S2.C1816, 
                  S2.C1817, 
                  S2.C1818, 
                  S2.C1819, 
                  S2.C1820, 
                  S2.C1821, 
                  S2.C1822, 
                  S2.C1823, 
                  S2.C1824, 
                  S2.C1785, 
                  S2.C1745, 
                  S2.C1746, 
                  S2.C1731, 
                  S2.C1732, 
                  S2.C1733, 
                  S2.C1829, 
                  S2.C1828, 
                  S2.C1830, 
                  S2.C1831, 
                  S2.C1727, 
                  S2.C1832, 
                  S2.C1734, 
                  S2.C1735, 
                  S2.C1827, 
                  S2.C1833, 
                  S2.C1660, 
                  S2.C1736, 
                  S2.C1834, 
                  S2.C1835, 
                  S2.C1836, 
                  S2.C1837, 
                  S2.C1726, 
                  S2.C1770, 
                  S2.C1771, 
                  S2.C1772, 
                  S2.C1773, 
                  S2.C1892, 
                  S2.C3958, 
                  S2.C3959, 
                  S2.C3877, 
                  S2.C3977, 
                  S2.C3991, 
                  S2.C4682, 
                  S2.C4683, 
                  S2.C4684, 
                  S2.C3362, 
                  S2.C3363, 
                  S2.C3580, 
                  S2.C3581, 
                  S2.C3582, 
                  S2.C1893, 
                  S2.C1933, 
                  S2.C2627, 
                  S2.C6672, 
                  S2.C6673, 
                  S2.C6674, 
                  S2.C6676, 
                  S2.C2777, 
                  S2.C8131, 
                  S2.C8132, 
                  S2.C8673, 
                  S2.C8748, 
                  S2.C8773, 
                  S2.C8127, 
                  S2.C8128, 
                  S2.C7358, 
                  S2.C6966, 
                  S2.C6967, 
                  S2.C6968, 
                  S2.C6969, 
                  S2.C1805, 
                  S2.C1713, 
                  S2.C1663, 
                  S2.C1664, 
                  S2.C1656, 
                  S2.C1672, 
                  S2.NUMERO_BOLETO, 
                  S2.AJUSTEINFLACION, 
                  S2.IMPORTE_REMUNERACION, 
                  S2.DIFERENCIA_VALUACION, 
                  S2.C50007, 
                  S2.CRITREVTASAS, 
                  S2.TIPOTASAB, 
                  S2.CALIFICACION, 
                  S2.PUNTOSTASA, 
                  S2.FECHA_SALDO_ICMORA, 
                  S2.ICMORA_CONTABILIZADO, 
                  S2.PERIODOREVTASA, 
                  S2.FECHINIREVTAS, 
                  S2.TASA_ICMORA, 
                  S2.ICMORA_PERCIBIDO_SALDOS, 
                  S2.ICMORA_DEVENGADO_NP, 
                  S2.ENTREGA_ACUENTA_ICMORA, 
                  S2.ULT_CUOTA_PAGO_ICMORA, 
                  S2.ICMORA_NP_CALC_ULT_PAGO, 
                  S2.ICMORA_CONT_ANT, 
                  S2.NUMCDPF, 
                  S2.TIPO_DPF, 
                  S2.C50099, 
                  S2.C50155, 
                  S2.C50156, 
                  S2.C50157, 
                  S2.C50158, 
                  S2.EVENTO_GASTOS_ALTA, 
                  S2.C50163, 
                  S2.ACREDITO_POR, 
                  S2.C50107, 
                  S2.C50109, 
                  S2.JTS_OID_RENOVACION, 
                  S2.C49997, 
                  S2.FECHA_CONT_DEVENGADO, 
                  S2.VALIDA_INT_MIGRADOS, 
                  S2.ULT_FECHA_VIGENTE, 
                  S2.EMPRESA, 
                  S2.SUCURSAL_EMPRESA, 
                  S2.FCAMBIOESTADOSUSPENSO, 
                  S2.FECHA_VTO_ULT_CUO_CON_SALDO, 
                  S2.ULTIMA_CUOTA_CON_SALDO, 
                  S2.CUOTAS_CANCELADAS, 
                  S2.ID_HISTORICO_TARIFARIO, 
                  S2.ESQUEMA_MORA, 
                  S2.SAL_DIAS_GRACIA_MORA, 
                  S2.SAL_DIAS_GRACIA_ICMORA, 
                  S2.SAL_DIAS_GRACIA_MULTAMORA, 
                  S2.RETIRO_CON_INTERES_DESDE, 
                  M2.TZ_LOCK AS TZ_LOCK$3, 
                  M2.C6399, 
                  M2.C6400, 
                  M2.C6401, 
                  M2.C6402, 
                  M2.C6403, 
                  M2.C6404, 
                  M2.TCCOMPRACOMUN, 
                  M2.TCVENTACOMUN, 
                  M2.TCCOMPRAPERSONAL, 
                  M2.TCVENTAPERSONAL, 
                  M2.TCCOMPRACOBERTURA, 
                  M2.TCVENTACOBERTURA, 
                  M2.C6426, 
                  M2.C6428, 
                  M2.C6429, 
                  M2.C6430, 
                  M2.C6431, 
                  M2.C6432, 
                  M2.C6433, 
                  M2.C6434, 
                  M2.C6435, 
                  M2.C6436, 
                  M2.C6437, 
                  M2.C6438, 
                  M2.C6440, 
                  M2.C6442, 
                  M2.C6443, 
                  M2.C6444, 
                  M2.C6445, 
                  M2.C6448, 
                  M2.C6449, 
                  M2.C6450, 
                  M2.C6451, 
                  M2.C6452, 
                  M2.C6453, 
                  M2.SPMAXCOMPRASUC, 
                  M2.SPMAXVENTASUC, 
                  M2.SPMAXCOMPRAMESA, 
                  M2.SPMAXVENTAMESA, 
                  M2.COMPUTABLE_DEPOSITO, 
                  M2.PORCENTAJE_TOLERANCIA, 
                  M2.LIMITE_POSICION, 
                  M2.C7500, 
                  M2.C7501, 
                  M2.CODIGO_TIPO, 
                  M2.C2622, 
                  M2.OPERA_VALORES, 
                  M2.GAMMA, 
                  M2.C6455, 
                  M2.CIERRE_OFICIAL, 
                  M2.CODIGO_MERCADO, 
                  M2.TEST_CINCO, 
                  M2.C50101, 
                  M2.RUBRO_GANANCIAS_EXP, 
                  M2.CTA_GANANCIAS_EXP, 
                  M2.RUBRO_PERDIDAS_EXP, 
                  M2.CTA_PERDIDAS_EXP, 
                  M2.TIPO_MONEDA_IFRS
               FROM dbo.CLE_CHEQUES_CLEARING_RECIBIDO  AS R2  WITH (NOLOCK), 
					dbo.SALDOS  AS S2, dbo.MONEDAS  AS M2  WITH (NOLOCK)
               WHERE 
                  substring(CAST(M2.TZ_LOCK AS nvarchar(4000)), 1, 1) <> ''3'' AND 
                  substring(CAST(R2.TZ_LOCK AS nvarchar(4000)), 1, 1) <> ''3'' AND 
                  substring(CAST(S2.TZ_LOCK AS nvarchar(4000)), 1, 1) <> ''3'' AND 
                  S2.SUCURSAL = R2.SUCURSAL AND 
                  S2.PRODUCTO = R2.PRODUCTO AND 
                  S2.CUENTA = R2.CUENTA AND 
                  S2.MONEDA = R2.MONEDA AND 
                  S2.OPERACION = R2.OPERACION AND 
                  S2.C1785 IN ( 2, 3 ) AND 
                  S2.MONEDA = M2.C6399 AND 
                  S2.C1604 < 0 AND 
                  S1.C1803 = S2.C1803 AND 
                  M1.C6403 <> M2.C6403
            )
      )  AS fci
   ORDER BY fci.RESULTADO
    ; ')
execute('
ALTER VIEW [dbo].[VW_CTA_COBRO_TJD] (
								   ID_TARJETA, 
								   SALDO_JTS_OID, 
								   MONEDA, 
								   C1785, 
								   C1604, 
								   ROWNUMTARJ)
AS 
   SELECT 
      TJD.ID_TARJETA, 
      TJD.SALDO_JTS_OID, 
      TJD.MONEDA, 
      TJD.C1785, 
      TJD.C1604, 
      TJD.ROWNUMTARJ
   FROM 
      (
         SELECT 
            SSMAROWNUM.ID_TARJETA, 
            SSMAROWNUM.SALDO_JTS_OID, 
            SSMAROWNUM.MONEDA, 
            SSMAROWNUM.C1785, 
            SSMAROWNUM.C1604, 
            SSMAROWNUM.ROWNUM AS ROWNUMTARJ
         FROM 
            (
               SELECT 
                  ID_TARJETA, 
                  SALDO_JTS_OID, 
                  MONEDA, 
                  C1785, 
                  C1604, 
                  FECHA, 
                  FECHAPROCESO, 
                  ID_TARJETA$2, 
                  ID_TARJETA$3, 
                  MES, 
                  ANIO, 
                  JTS_OID, 
                  TZ_LOCK, 
                  TZ_LOCK$2, 
                  TZ_LOCK$3, 
                  TZ_LOCK$4, 
                  ROW_NUMBER() OVER(
                     ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
               FROM 
                  (
                     SELECT 
                        R.ID_TARJETA, 
                        R.SALDO_JTS_OID, 
                        S.MONEDA, 
                        S.C1785, 
                        S.C1604, 
                        D.FECHA, 
                        P.FECHAPROCESO, 
                        D.ID_TARJETA AS ID_TARJETA$2, 
                        M.ID_TARJETA AS ID_TARJETA$3, 
                        M.MES, 
                        M.ANIO, 
                        S.JTS_OID, 
                        D.TZ_LOCK, 
                        M.TZ_LOCK AS TZ_LOCK$2, 
                        R.TZ_LOCK AS TZ_LOCK$3, 
                        S.TZ_LOCK AS TZ_LOCK$4, 
                        0 AS SSMAPSEUDOCOLUMN
                     FROM 
                        dbo.TJD_ATM_CONTADOR_DIARIO  AS D WITH (NOLOCK), 
                        dbo.TJD_ATM_CONTADOR_MENSUAL  AS M WITH (NOLOCK), 
                        dbo.PARAMETROS  AS P WITH (NOLOCK), 
                        dbo.TJD_REL_TARJETA_CUENTA  AS R WITH (NOLOCK), 
                        dbo.SALDOS  AS S WITH (NOLOCK)
                     WHERE 
                        D.FECHA = P.FECHAPROCESO AND 
                        D.ID_TARJETA = M.ID_TARJETA AND 
                        MONTH(P.FECHAPROCESO) = M.MES AND 
                        CONVERT(varchar(4), P.FECHAPROCESO, 102) = M.ANIO AND 
                        D.ID_TARJETA = R.ID_TARJETA AND 
                        S.JTS_OID = R.SALDO_JTS_OID AND 
                        S.C1785 IN ( 2, 3 ) AND 
                        S.MONEDA IN ( 0, 2222, 2225 ) AND 
                        D.TZ_LOCK = 0 AND 
                        M.TZ_LOCK = 0 AND 
                        R.TZ_LOCK = 0 AND 
                        S.TZ_LOCK = 0
                  )  AS SSMAPSEUDO
            )  AS SSMAROWNUM
         WHERE 
            SSMAROWNUM.FECHA = SSMAROWNUM.FECHAPROCESO AND 
            SSMAROWNUM.ID_TARJETA = SSMAROWNUM.ID_TARJETA AND 
            MONTH(SSMAROWNUM.FECHAPROCESO) = SSMAROWNUM.MES AND 
            CONVERT(varchar(4), SSMAROWNUM.FECHAPROCESO, 102) = SSMAROWNUM.ANIO AND 
            SSMAROWNUM.ID_TARJETA = SSMAROWNUM.ID_TARJETA AND 
            SSMAROWNUM.JTS_OID = SSMAROWNUM.SALDO_JTS_OID AND 
            SSMAROWNUM.C1785 IN ( 2, 3 ) AND 
            SSMAROWNUM.MONEDA IN ( 0, 2222, 2225 ) AND 
            SSMAROWNUM.TZ_LOCK = 0 AND 
            SSMAROWNUM.TZ_LOCK = 0 AND 
            SSMAROWNUM.TZ_LOCK = 0 AND 
            SSMAROWNUM.TZ_LOCK = 0
      )  AS TJD, 
      (
         SELECT SSMAROWNUM$2.ID_TARJETA AS ID_TARJETAMIN, min(SSMAROWNUM$2.ROWNUM) AS ROWNUMMIN
         FROM 
            (
               SELECT 
                  ID_TARJETA, 
                  FECHA, 
                  FECHAPROCESO, 
                  ID_TARJETA$2, 
                  ID_TARJETA$3, 
                  MES, 
                  ANIO, 
                  JTS_OID, 
                  SALDO_JTS_OID, 
                  C1785, 
                  MONEDA, 
                  TZ_LOCK, 
                  TZ_LOCK$2, 
                  TZ_LOCK$3, 
                  TZ_LOCK$4, 
                  ROW_NUMBER() OVER(
                     ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
               FROM 
                  (
                     SELECT 
                        R$2.ID_TARJETA, 
                        D$2.FECHA, 
                        P$2.FECHAPROCESO, 
                        D$2.ID_TARJETA AS ID_TARJETA$2, 
                        M$2.ID_TARJETA AS ID_TARJETA$3, 
                        M$2.MES, 
                        M$2.ANIO, 
                        S$2.JTS_OID, 
                        R$2.SALDO_JTS_OID, 
                        S$2.C1785, 
                        S$2.MONEDA, 
                        D$2.TZ_LOCK, 
                        M$2.TZ_LOCK AS TZ_LOCK$2, 
                        R$2.TZ_LOCK AS TZ_LOCK$3, 
                        S$2.TZ_LOCK AS TZ_LOCK$4, 
                        0 AS SSMAPSEUDOCOLUMN
                     FROM 
                        dbo.TJD_ATM_CONTADOR_DIARIO  AS D$2 WITH (NOLOCK), 
                        dbo.TJD_ATM_CONTADOR_MENSUAL  AS M$2 WITH (NOLOCK), 
                        dbo.PARAMETROS  AS P$2 WITH (NOLOCK), 
                        dbo.TJD_REL_TARJETA_CUENTA  AS R$2 WITH (NOLOCK), 
                        dbo.SALDOS  AS S$2 WITH (NOLOCK)
                     WHERE 
                        D$2.FECHA = P$2.FECHAPROCESO AND 
                        D$2.ID_TARJETA = M$2.ID_TARJETA AND 
                        MONTH(P$2.FECHAPROCESO) = M$2.MES AND 
                        CONVERT(varchar(4), P$2.FECHAPROCESO, 102) = M$2.ANIO AND 
                        D$2.ID_TARJETA = R$2.ID_TARJETA AND 
                        S$2.JTS_OID = R$2.SALDO_JTS_OID AND 
                        S$2.C1785 IN ( 2, 3 ) AND 
                        S$2.MONEDA IN ( 0, 2222, 2225 ) AND 
                        D$2.TZ_LOCK = 0 AND 
                        M$2.TZ_LOCK = 0 AND 
                        R$2.TZ_LOCK = 0 AND 
                        S$2.TZ_LOCK = 0
                  )  AS SSMAPSEUDO$2
            )  AS SSMAROWNUM$2
         WHERE 
            SSMAROWNUM$2.FECHA = SSMAROWNUM$2.FECHAPROCESO AND 
            SSMAROWNUM$2.ID_TARJETA = SSMAROWNUM$2.ID_TARJETA AND 
            MONTH(SSMAROWNUM$2.FECHAPROCESO) = SSMAROWNUM$2.MES AND 
            CONVERT(varchar(4), SSMAROWNUM$2.FECHAPROCESO, 102) = SSMAROWNUM$2.ANIO AND 
            SSMAROWNUM$2.ID_TARJETA = SSMAROWNUM$2.ID_TARJETA AND 
            SSMAROWNUM$2.JTS_OID = SSMAROWNUM$2.SALDO_JTS_OID AND 
            SSMAROWNUM$2.C1785 IN ( 2, 3 ) AND 
            SSMAROWNUM$2.MONEDA IN ( 0, 2222, 2225 ) AND 
            SSMAROWNUM$2.TZ_LOCK = 0 AND 
            SSMAROWNUM$2.TZ_LOCK = 0 AND 
            SSMAROWNUM$2.TZ_LOCK = 0 AND 
            SSMAROWNUM$2.TZ_LOCK = 0
         GROUP BY SSMAROWNUM$2.ID_TARJETA
      )  AS TJDMIN
   WHERE TJDMIN.ID_TARJETAMIN = TJD.ID_TARJETA 
		AND TJDMIN.ROWNUMMIN = TJD.ROWNUMTARJ
    ; ')
execute('
ALTER VIEW [dbo].[VW_CRE_LISTA_LOTE] (
								   NUMERO_LOTE, 
								   NUMERO_DOC_INTERNO, 
								   NUMERO_LISTA, 
								   SERIE, 
								   NUMERO_DOC_REAL, 
								   IMPORTE, 
								   FECHA_DOCUMENTO, 
								   ESTADO)
AS 
	SELECT 
		  LOTE.NUMERO_LOTE, 
		  AUX.NUMERO_DOC_INTERNO, 
		  AUX.NUMERO_LISTA, 
		  AUX.SERIE, 
		  AUX.NUMERO_DOC_REAL, 
		  AUX.IMPORTE, 
		  AUX.FECHA_DOCUMENTO, 
		  AUX.ESTADO
   FROM dbo.CRE_AUX_CONF_FACTURAS  AS AUX WITH(NOLOCK), 
		dbo.CRE_CAB_INGRESO_LOTE  AS LOTE WITH(NOLOCK), 
		dbo.CRE_CAB_LISTA_DOCUMENTOS  AS LISTA WITH(NOLOCK)
   WHERE LOTE.NUMERO_LOTE = LISTA.NUMERO_LOTE 
		AND AUX.NUMERO_LISTA = LISTA.NUMERO_LISTA
    ; ')
execute('
ALTER VIEW [dbo].[VW_CRE_COMPRA_CARTERA] (
									   LOTE, 
									   CANTIDAD_DOCUMENTOS, 
									   CAPITAL_ORIGINAL, 
									   SALDO_CAPITAL, 
									   ESTADO, 
									   TZ_LOCK)
AS 
    SELECT 
      CRE_COMPRA_CARTERA.ID_LOTE AS LOTE, 
      count_big(CRE_COMPRA_CARTERA.NUM_VALE_PRONTO) AS CANTIDAD_DOCUMENTOS, 
      sum(CRE_COMPRA_CARTERA.CAPITAL_ORIGINAL) AS CAPITAL_ORIGINAL, 
      sum(CRE_COMPRA_CARTERA.SALDO_CAPITAL) AS SALDO_CAPITAL, 
      CRE_COMPRA_CARTERA.ESTADO, 
      0 AS TZ_LOCK
   FROM dbo.CRE_COMPRA_CARTERA WITH (NOLOCK)
   GROUP BY CRE_COMPRA_CARTERA.ID_LOTE, 
			CRE_COMPRA_CARTERA.ESTADO
; ')
execute('
ALTER PROCEDURE [dbo].[PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO_AT$IMPL]  
   @P_ID_PROCESO float(53),
   @P_FCH_PROCESO datetime2(0),
   @P_NOM_PACKAGE varchar(max),
   @P_COD_ERROR float(53),
   @P_MSG_ERROR varchar(max),
   @P_TIPO_ERROR varchar(max)
AS 
   BEGIN
      SET  IMPLICIT_TRANSACTIONS  ON
      BEGIN TRY

         INSERT dbo.LOG_PROCESO(
            ID_PROCESO, 
            FECHA_ERROR, 
            NOM_PACKAGE, 
            COD_ERROR, 
            MSG_ERROR, 
            TIPO_ERROR)
            VALUES (
               @P_ID_PROCESO, 
               @P_FCH_PROCESO, 
               @P_NOM_PACKAGE, 
               @P_COD_ERROR, 
               @P_MSG_ERROR, 
               @P_TIPO_ERROR)

         IF @@TRANCOUNT > 0
            COMMIT WORK 

      END TRY

      BEGIN CATCH
         BEGIN
            DECLARE
               @db_null_statement int
         END
      END CATCH

   END
   ; ')
execute('
	ALTER VIEW [dbo].[VW_ERROR_LIMITE] (NRO_SOLICITUD, DESCRIPCION)
	AS 
	SELECT DISTINCT E.NRO_SOLICITUD, E.DESCRIPCION
	FROM dbo.CRE_ERROR_LIMITE  AS E WITH(NOLOCK)
	WHERE (	(E.TZ_LOCK < 300000000000000 OR E.TZ_LOCK >= 400000000000000) 
		AND (E.TZ_LOCK < 100000000000000 OR E.TZ_LOCK >= 200000000000000))
   ; ')
execute('
ALTER VIEW [dbo].[VW_EXCEPCION_NEGA_DOCUMENTO] (
											   NUMEROPERSONAFJ, 
											   TIPODOCUMENTO, 
											   NUMERODOCUMENTO, 
											   PAISDOCUMENTO, 
											   FECHAPRESENTACION, 
											   FECHAVENCIMIENTO, 
											   REPORTAAORGANISMOCONTROL, 
											   TIPOPERSONA, 
											   NRO_PERSONA, 
											   FECHA_VTO)
AS 
   SELECT 
      D.NUMEROPERSONAFJ, 
      D.TIPODOCUMENTO, 
      D.NUMERODOCUMENTO, 
      D.PAISDOCUMENTO, 
      D.FECHAPRESENTACION, 
      D.FECHAVENCIMIENTO, 
      D.REPORTAAORGANISMOCONTROL, 
      D.TIPOPERSONA, 
      E.NRO_PERSONA, 
      E.FECHA_VTO
   FROM dbo.CLI_DOCUMENTOSPFPJ  AS D WITH (NOLOCK), 
		dbo.CRE_EXCEPCION_NEGATIVA  AS E  WITH (NOLOCK)
   WHERE 
      (		(D.TZ_LOCK < 300000000000000 OR D.TZ_LOCK >= 400000000000000) 
		AND	(D.TZ_LOCK < 100000000000000 OR D.TZ_LOCK >= 200000000000000)) 
	AND 
      (		(E.TZ_LOCK < 300000000000000 OR E.TZ_LOCK >= 400000000000000) 
		AND (E.TZ_LOCK < 100000000000000 OR E.TZ_LOCK >= 200000000000000)) 
	AND D.NUMEROPERSONAFJ = E.NRO_PERSONA
   ; ')
execute('
ALTER VIEW [dbo].[VW_GTIA_LIMITE] (
								   CLIENTE, 
								   RIESGO, 
								   FAMILIA, 
								   MONEDA, 
								   TIPO_GARANTIA, 
								   SUBTIPO_GARANTIA, 
								   SUBCLASIFICACION_GARANTIA, 
								   PAIS_GARANTIA, 
								   CONDICIONANTE_DESEMBOLSO, 
								   TIPO)
AS 
   SELECT 
      fci.CLIENTE, 
      fci.RIESGO, 
      fci.FAMILIA, 
      fci.MONEDA, 
      fci.TIPO_GARANTIA, 
      fci.SUBTIPO_GARANTIA, 
      fci.SUBCLASIFICACION_GARANTIA, 
      fci.PAIS_GARANTIA, 
      fci.CONDICIONANTE_DESEMBOLSO, 
      fci.TIPO
   FROM 
      (
         SELECT 
            LC.CLIENTE AS CLIENTE, 
            R.CODIGO_RIESGO AS RIESGO, 
            F.FAMILIAPROD AS FAMILIA, 
            M.C6399 AS MONEDA, 
            LG.TIPO_GARANTIA, 
            LG.SUBTIPO_GARANTIA, 
            LG.SUBCLASIFICACION_GARANTIA, 
            LG.PAIS_GARANTIA, 
            LG.CONDICIONANTE_DESEMBOLSO, 
            LG.TIPO
         FROM 
            dbo.CRE_LIMITECLIENTE  AS LC WITH(NOLOCK), 
            dbo.CRE_TIPOS_RIESGOS  AS R WITH(NOLOCK), 
            dbo.CRE_FAMILIAS  AS F WITH(NOLOCK), 
            dbo.MONEDAS  AS M WITH(NOLOCK), 
            dbo.CRE_LIMITE_GARANTIA  AS LG WITH(NOLOCK)
         WHERE 
            ((LC.TZ_LOCK < 300000000000000 OR LC.TZ_LOCK >= 400000000000000) AND (LC.TZ_LOCK < 100000000000000 OR LC.TZ_LOCK >= 200000000000000)) AND 
            ((R.TZ_LOCK < 300000000000000 OR R.TZ_LOCK >= 400000000000000) AND (R.TZ_LOCK < 100000000000000 OR R.TZ_LOCK >= 200000000000000)) AND 
            ((F.TZ_LOCK < 300000000000000 OR F.TZ_LOCK >= 400000000000000) AND (F.TZ_LOCK < 100000000000000 OR F.TZ_LOCK >= 200000000000000)) AND 
            ((M.TZ_LOCK < 300000000000000 OR M.TZ_LOCK >= 400000000000000) AND (M.TZ_LOCK < 100000000000000 OR M.TZ_LOCK >= 200000000000000)) AND 
            ((LG.TZ_LOCK < 300000000000000 OR LG.TZ_LOCK >= 400000000000000) AND (LG.TZ_LOCK < 100000000000000 OR LG.TZ_LOCK >= 200000000000000)) AND 
            F.RIESGO = R.CODIGO_RIESGO AND 
            LG.TIPO = ''L'' AND 
            LG.ID_LIMITE = LC.IDLIMITE AND 
            LG.CONDICIONANTE_DESEMBOLSO = ''S''
          UNION
         SELECT 
            LC$2.CLIENTE AS CLIENTE, 
            RL.CODIGO_RIESGO AS RIESGO, 
            F$2.FAMILIAPROD AS FAMILIA, 
            M$2.C6399 AS MONEDA, 
            LG$2.TIPO_GARANTIA, 
            LG$2.SUBTIPO_GARANTIA, 
            LG$2.SUBCLASIFICACION_GARANTIA, 
            LG$2.PAIS_GARANTIA, 
            LG$2.CONDICIONANTE_DESEMBOLSO, 
            LG$2.TIPO
         FROM 
            dbo.CRE_LIMITECLIENTE  AS LC$2 WITH(NOLOCK), 
            dbo.CRE_RIESGOLIC  AS RL WITH(NOLOCK), 
            dbo.CRE_FAMILIAS  AS F$2 WITH(NOLOCK), 
            dbo.MONEDAS  AS M$2 WITH(NOLOCK), 
            dbo.CRE_LIMITE_GARANTIA  AS LG$2 WITH(NOLOCK)
         WHERE 
            ((LC$2.TZ_LOCK < 300000000000000 OR LC$2.TZ_LOCK >= 400000000000000) AND (LC$2.TZ_LOCK < 100000000000000 OR LC$2.TZ_LOCK >= 200000000000000)) AND 
            ((RL.TZ_LOCK < 300000000000000 OR RL.TZ_LOCK >= 400000000000000) AND (RL.TZ_LOCK < 100000000000000 OR RL.TZ_LOCK >= 200000000000000)) AND 
            ((F$2.TZ_LOCK < 300000000000000 OR F$2.TZ_LOCK >= 400000000000000) AND (F$2.TZ_LOCK < 100000000000000 OR F$2.TZ_LOCK >= 200000000000000)) AND 
            ((M$2.TZ_LOCK < 300000000000000 OR M$2.TZ_LOCK >= 400000000000000) AND (M$2.TZ_LOCK < 100000000000000 OR M$2.TZ_LOCK >= 200000000000000)) AND 
            ((LG$2.TZ_LOCK < 300000000000000 OR LG$2.TZ_LOCK >= 400000000000000) AND (LG$2.TZ_LOCK < 100000000000000 OR LG$2.TZ_LOCK >= 200000000000000)) AND 
            LC$2.IDLIMITE = RL.IDLIMITE AND 
            RL.APERRIESGOFAM = ''N'' AND 
            F$2.RIESGO = RL.CODIGO_RIESGO AND 
            LG$2.TIPO = ''R'' AND 
            LG$2.RIESGO = RL.CODIGO_RIESGO AND 
            LG$2.ID_LIMITE = LC$2.IDLIMITE AND 
            LG$2.CONDICIONANTE_DESEMBOLSO = ''S''
          UNION
         SELECT 
            LC$3.CLIENTE AS CLIENTE, 
            FL.CODIGO_RIESGO AS RIESGO, 
            FL.FAMILIA AS FAMILIA, 
            M$3.C6399 AS MONEDA, 
            LG$3.TIPO_GARANTIA, 
            LG$3.SUBTIPO_GARANTIA, 
            LG$3.SUBCLASIFICACION_GARANTIA, 
            LG$3.PAIS_GARANTIA, 
            LG$3.CONDICIONANTE_DESEMBOLSO, 
            LG$3.TIPO
         FROM 
            dbo.CRE_LIMITECLIENTE  AS LC$3 WITH(NOLOCK), 
            dbo.CRE_FAMILIALIC  AS FL WITH(NOLOCK), 
            dbo.MONEDAS  AS M$3 WITH(NOLOCK), 
            dbo.CRE_LIMITE_GARANTIA  AS LG$3 WITH(NOLOCK)
         WHERE 
            ((LC$3.TZ_LOCK < 300000000000000 OR LC$3.TZ_LOCK >= 400000000000000) AND (LC$3.TZ_LOCK < 100000000000000 OR LC$3.TZ_LOCK >= 200000000000000)) AND 
            ((FL.TZ_LOCK < 300000000000000 OR FL.TZ_LOCK >= 400000000000000) AND (FL.TZ_LOCK < 100000000000000 OR FL.TZ_LOCK >= 200000000000000)) AND 
            ((M$3.TZ_LOCK < 300000000000000 OR M$3.TZ_LOCK >= 400000000000000) AND (M$3.TZ_LOCK < 100000000000000 OR M$3.TZ_LOCK >= 200000000000000)) AND 
            ((LG$3.TZ_LOCK < 300000000000000 OR LG$3.TZ_LOCK >= 400000000000000) AND (LG$3.TZ_LOCK < 100000000000000 OR LG$3.TZ_LOCK >= 200000000000000)) AND 
            LC$3.IDLIMITE = FL.IDLIMITE AND 
            /*AND fl.APERMONEDA =''N''*/LG$3.TIPO = ''F'' AND 
            LG$3.RIESGO = FL.CODIGO_RIESGO AND 
            LG$3.FAMILIA = FL.FAMILIA AND 
            LG$3.ID_LIMITE = LC$3.IDLIMITE AND 
            LG$3.CONDICIONANTE_DESEMBOLSO = ''S''
          UNION
         SELECT 
            LC$4.CLIENTE AS CLIENTE, 
            ML.CODIGO_RIESGO AS RIESGO, 
            ML.FAMILIA AS FAMILIA, 
            ML.MONEDA AS MONEDA, 
            LG$4.TIPO_GARANTIA, 
            LG$4.SUBTIPO_GARANTIA, 
            LG$4.SUBCLASIFICACION_GARANTIA, 
            LG$4.PAIS_GARANTIA, 
            LG$4.CONDICIONANTE_DESEMBOLSO, 
            LG$4.TIPO
         FROM	dbo.CRE_LIMITECLIENTE  AS LC$4 WITH(NOLOCK), 
				dbo.CRE_MONEDALIC  AS ML WITH(NOLOCK), 
				dbo.CRE_LIMITE_GARANTIA  AS LG$4 WITH(NOLOCK)
         WHERE 
            ((LC$4.TZ_LOCK < 300000000000000 OR LC$4.TZ_LOCK >= 400000000000000) AND (LC$4.TZ_LOCK < 100000000000000 OR LC$4.TZ_LOCK >= 200000000000000)) AND 
            ((ML.TZ_LOCK < 300000000000000 OR ML.TZ_LOCK >= 400000000000000) AND (ML.TZ_LOCK < 100000000000000 OR ML.TZ_LOCK >= 200000000000000)) AND 
            ((LG$4.TZ_LOCK < 300000000000000 OR LG$4.TZ_LOCK >= 400000000000000) AND (LG$4.TZ_LOCK < 100000000000000 OR LG$4.TZ_LOCK >= 200000000000000)) AND 
            LC$4.IDLIMITE = ML.IDLIMITE AND 
            LG$4.TIPO = ''M'' AND 
            LG$4.RIESGO = ML.CODIGO_RIESGO AND 
            LG$4.FAMILIA = ML.FAMILIA AND 
            LG$4.MONEDA = ML.MONEDA AND 
            LG$4.ID_LIMITE = LC$4.IDLIMITE AND 
            LG$4.CONDICIONANTE_DESEMBOLSO = ''S''
      )  AS fci
   ; ')
execute('
ALTER VIEW [dbo].[LISTADO_REPORTES] (
								   TITULO, 
								   NOMBRETIT, 
								   IDENTID, 
								   NOMBRE_REPORTE)
AS 
   SELECT 
      CASE 
         WHEN REPORTES.IDENTIFICACION = 0 THEN CAST(REPORTES.TITULO AS varchar(max))
         ELSE '' ''
      END AS TITULO, 
      CASE 
         WHEN REPORTES.IDENTIFICACION = 0 THEN REPORTES.DESCRIPCION
         ELSE '' ''
      END AS NOMBRETIT, 
      CASE 
         WHEN REPORTES.IDENTIFICACION = 0 THEN '' ''
         ELSE CAST(REPORTES.IDENTIFICACION AS varchar(max))
      END AS IDENTID, 
      CASE 
         WHEN REPORTES.IDENTIFICACION = 0 THEN '' ''
         ELSE REPORTES.DESCRIPCION
      END AS NOMBRE_REPORTE
   FROM dbo.REPORTES WITH(NOLOCK)

   ; ')
execute('
ALTER VIEW [dbo].[VW_TIPOSUBTIPO_DOCUMENTOS] (	TPO_GARANTIA, 
												SUBTIPO_GARANTIA)
AS 
   SELECT	CRE_DOCUMENTOS.TPO_GARANTIA, 
			CRE_DOCUMENTOS.SUBTIPO_GARANTIA
   FROM dbo.CRE_DOCUMENTOS WITH (NOLOCK)
   WHERE CRE_DOCUMENTOS.TZ_LOCK = 0
   GROUP BY CRE_DOCUMENTOS.TPO_GARANTIA, 
			CRE_DOCUMENTOS.SUBTIPO_GARANTIA
   ; ')
execute('
ALTER VIEW [dbo].[VW_TIPOSUBTIPO_DOCUMENTOS] (	TPO_GARANTIA, 
												SUBTIPO_GARANTIA)
AS 
   SELECT	CRE_DOCUMENTOS.TPO_GARANTIA, 
			CRE_DOCUMENTOS.SUBTIPO_GARANTIA
   FROM dbo.CRE_DOCUMENTOS WITH (NOLOCK)
   WHERE CRE_DOCUMENTOS.TZ_LOCK = 0
   GROUP BY CRE_DOCUMENTOS.TPO_GARANTIA, 
			CRE_DOCUMENTOS.SUBTIPO_GARANTIA
   ; ')
execute('
ALTER VIEW [dbo].[VW_BASE_NEGATIVA] (
									   SUCURSAL, 
									   DESC_SUCURSAL, 
									   REFERENCIA, 
									   PAIS, 
									   NOM_PAIS, 
									   TIPO_DOCUMENTO, 
									   NRO_DOCUMENTO, 
									   TITULARIDAD, 
									   ESTADO_ACTUAL, 
									   ESTADO_MOV, 
									   TIPO_PERSONA, 
									   COD_CLIENTE, 
									   NOM_CLIENTE, 
									   COD_SEGMENTO, 
									   DESC_SEG, 
									   COD_OFICIAL, 
									   NOM_OFIC, 
									   MONEDA, 
									   DESC_MONEDA, 
									   PRODUCTO, 
									   DESC_PROD, 
									   IMPORTE, 
									   DIAS_VENCIDOS, 
									   CUENTA, 
									   ORDINAL)
AS 
   SELECT 
      CN.SUCURSAL, 
      SU.NOMBRESUCURSAL AS DESC_SUCURSAL, 
      CN.REFERENCIA, 
      CN.PAIS, 
      P.NOMBREPAIS AS NOM_PAIS, 
      CN.TIPO_DOCUMENTO, 
      CN.NRO_DOCUMENTO, 
      CP.TITULARIDAD, 
      CN.ESTADO_ACTUAL, 
      CN.ESTADO_MOV, 
      CN.TIPO_PERSONA, 
      C.CODIGOCLIENTE AS COD_CLIENTE, 
      C.NOMBRECLIENTE AS NOM_CLIENTE, 
      C.SEGMENTOCLIENTE AS COD_SEGMENTO, 
      SEG.DESCRIPCION_SEGMENTO AS DESC_SEG, 
      C.EJECUTIVOCLIENTE AS COD_OFICIAL, 
      OFI.NOMBREOFIC AS NOM_OFIC, 
      CN.MONEDA, 
      M.C6400 AS DESC_MONEDA, 
      CN.PRODUCTO, 
      PRO.C6251 AS DESC_PROD, 
      CN.IMPORTE, 
      CN.DIAS_VENCIDOS, 
      CN.CUENTA, 
      CN.ORDINAL
   FROM 
      dbo.CRE_CLEARING_NEGATIVA  AS CN WITH(NOLOCK), 
      dbo.SALDOS  AS S WITH(NOLOCK), 
      dbo.CLI_CLIENTES  AS C WITH(NOLOCK), 
      dbo.SUCURSALES  AS SU WITH(NOLOCK), 
      dbo.CLI_PAISES  AS P WITH(NOLOCK), 
      dbo.PRODUCTOS  AS PRO WITH(NOLOCK), 
      dbo.MONEDAS  AS M WITH(NOLOCK), 
      dbo.CLI_SEGMENTOS  AS SEG WITH(NOLOCK), 
      dbo.CLI_OFICUENTA  AS OFI WITH(NOLOCK), 
      dbo.CLI_CLIENTEPERSONA  AS CP WITH(NOLOCK)
   WHERE 
      ((CN.TZ_LOCK < 300000000000000 OR CN.TZ_LOCK >= 400000000000000) AND (CN.TZ_LOCK < 100000000000000 OR CN.TZ_LOCK >= 200000000000000)) AND 
      ((S.TZ_LOCK < 300000000000000 OR S.TZ_LOCK >= 400000000000000) AND (S.TZ_LOCK < 100000000000000 OR S.TZ_LOCK >= 200000000000000)) AND 
      ((C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000)) AND 
      ((SU.TZ_LOCK < 300000000000000 OR SU.TZ_LOCK >= 400000000000000) AND (SU.TZ_LOCK < 100000000000000 OR SU.TZ_LOCK >= 200000000000000)) AND 
      ((P.TZ_LOCK < 300000000000000 OR P.TZ_LOCK >= 400000000000000) AND (P.TZ_LOCK < 100000000000000 OR P.TZ_LOCK >= 200000000000000)) AND 
      ((PRO.TZ_LOCK < 300000000000000 OR PRO.TZ_LOCK >= 400000000000000) AND (PRO.TZ_LOCK < 100000000000000 OR PRO.TZ_LOCK >= 200000000000000)) AND 
      ((M.TZ_LOCK < 300000000000000 OR M.TZ_LOCK >= 400000000000000) AND (M.TZ_LOCK < 100000000000000 OR M.TZ_LOCK >= 200000000000000)) AND 
      ((SEG.TZ_LOCK < 300000000000000 OR SEG.TZ_LOCK >= 400000000000000) AND (SEG.TZ_LOCK < 100000000000000 OR SEG.TZ_LOCK >= 200000000000000)) AND 
      ((OFI.TZ_LOCK < 300000000000000 OR OFI.TZ_LOCK >= 400000000000000) AND (OFI.TZ_LOCK < 100000000000000 OR OFI.TZ_LOCK >= 200000000000000)) AND 
      ((CP.TZ_LOCK < 300000000000000 OR CP.TZ_LOCK >= 400000000000000) AND (CP.TZ_LOCK < 100000000000000 OR CP.TZ_LOCK >= 200000000000000)) AND 
      CP.CODIGOCLIENTE = C.CODIGOCLIENTE AND 
      CP.NUMEROPERSONA = CN.NRO_PERSONA AND 
      S.SUCURSAL = CN.SUCURSAL AND 
      S.PRODUCTO = CN.PRODUCTO AND 
      S.CUENTA = CN.CUENTA AND 
      S.MONEDA = CN.MONEDA AND 
      S.OPERACION = CN.REFERENCIA AND 
      S.ORDINAL = CN.ORDINAL AND 
      S.C1803 = C.CODIGOCLIENTE AND 
      CN.SUCURSAL = SU.SUCURSAL AND 
      CN.PAIS = P.CODIGOPAIS AND 
      CN.MONEDA = M.C6399 AND 
      PRO.C6250 = CN.PRODUCTO AND 
      C.SEGMENTOCLIENTE = SEG.COD_SEGMENTO AND 
      C.EJECUTIVOCLIENTE = OFI.CODOFICIAL
   ; ')
execute('
ALTER VIEW [dbo].[VW_TJD_TLF_CONCILIACION] (
										   HORAMENSAJE, 
										   TERMINAL, 
										   REFERENCIA, 
										   CUENTA, 
										   IMPORTE, 
										   FECHAPROCESO, 
										   SUCURSAL, 
										   ASIENTO, 
										   ERROR, 
										   CORRECCION)
AS 
   SELECT 
      C.HORAMENSAJE, 
      C.TERMINAL, 
      C.REFERENCIA, 
      CAST(
         ISNULL(STR(M.SUCURSAL_CUENTA, 3, 0), '''')
          + 
         ''-''
          + 
         ISNULL(STR(M.PRODUCTO, 5, 0), '''')
          + 
         ''-''
          + 
         ISNULL(STR(M.MONEDA, 4, 0), '''')
          + 
         ''-''
          + 
         ISNULL(STR(M.CUENTA, 12, 0), '''')
          + 
         ''-''
          + 
         ISNULL(STR(M.OPERACION_CUENTA, 14, 0), '''')
          + 
         ''-''
          + 
         ISNULL(STR(M.ORDINAL_CUENTA, 6, 0), '''') AS varchar(44)) AS CUENTA, 
      C.IMPORTE_ORIGINAL AS IMPORTE, 
      C.FECHAPROCESO, 
      CAST(C.SUCURSAL AS numeric(3, 0)) AS SUCURSAL, 
      C.ASIENTO, 
      C.ERROR, 
      CASE 
         WHEN C.MANUAL = ''M'' THEN ''Manual''
         ELSE ''Automatico''
      END AS CORRECCION
   FROM dbo.TJD_TLF_SUMMARY_NEW  AS C WITH (NOLOCK), 
		dbo.MOVIMIENTOS_CONTABLES  AS M WITH (NOLOCK)
   WHERE 
      C.ERROR <> ''  '' AND 
      C.FECHAPROCESO = M.FECHAPROCESO AND 
      C.SUCURSAL = M.SUCURSAL AND 
      C.ASIENTO = M.ASIENTO AND 
      M.DEBITOCREDITO = ''D''
   ; ')
execute('
ALTER VIEW [dbo].[VW_CAMP_PROD] (
							   COD_CAMPANIA, 
							   DESC_CAMPANIA, 
							   PRODUCTO, 
							   DESC_PRODUCTO, 
							   MONEDA, 
							   DESC_MONEDA, 
							   SEGMENTO, 
							   SUBSEGMENTO, 
							   RESIDENCIA, 
							   DEPENDENCIA, 
							   CANAL, 
							   PAQUETE)
AS 
   SELECT 
      C.COD_CAMPANIA AS COD_CAMPANIA, 
      C.DESCRIPCION_CAMPANIA AS DESC_CAMPANIA, 
      C.PRODUCTO, 
      '' '' AS DESC_PRODUCTO, 
      C.MONEDA, 
      '' '' AS DESC_MONEDA, 
      C.SEGMENTO, 
      C.SUBSEGMENTO, 
      C.RESIDENCIA, 
      C.DEPENDENCIA, 
      C.CANAL, 
      C.PAQUETE
   FROM dbo.CLI_CAMPANIAS  AS C WITH (NOLOCK)
   WHERE (	(C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
		AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000))
   ; ')

execute('
ALTER VIEW [dbo].[VW_CANTIDAD_MOVMES_CAJA] (SALDO_JTS_OID, 
											CANTMOVMES)
AS 
   SELECT S.JTS_OID AS SALDO_JTS_OID, 
		count_big(*) AS CANTMOVMES
   FROM dbo.MOVIMIENTOS_CONTABLES  AS M WITH(NOLOCK), 
		dbo.PARAMETROS  AS P WITH(NOLOCK), 
		dbo.SALDOS  AS S WITH(NOLOCK)
   WHERE 
      M.SUCURSAL_CUENTA = S.SUCURSAL AND 
      M.CLIENTE = S.C1803 AND 
      M.MONEDA = S.MONEDA AND 
      M.CUENTA = S.CUENTA AND 
      M.OPERACION_CUENTA = S.OPERACION AND 
      M.PRODUCTO = S.PRODUCTO AND 
      M.ORDINAL_CUENTA = S.ORDINAL AND 
      S.C1803 <> 0 AND 
      S.C1785 IN ( 2, 3 ) AND 
      S.CUENTA <> 0 AND 
      S.TZ_LOCK = 0 AND 
      M.CAJADIARIO = ''C'' AND 
      CONVERT(varchar(2), M.FECHAPROCESO, 101) = CONVERT(varchar(2), dateadd(m, -1, P.FECHAPROCESO), 101) AND 
      CAST(CONVERT(varchar(4), M.FECHAPROCESO, 102) AS numeric(38, 10)) = CONVERT(varchar(4), dateadd(m, -1, P.FECHAPROCESO), 102)
   GROUP BY S.JTS_OID
   ; ')
execute('
ALTER VIEW [dbo].[VWNOMBRECONVENIOPAGO] (
										   LOTE, 
										   MONTO, 
										   FECHA_ACREDITACION, 
										   FECHA_ALTA, 
										   ESTADO, 
										   CAUSAL, 
										   LOTE_REFERENCIA, 
										   NROCONVENIO, 
										   NOMBRE)
AS 
   SELECT TOP 9223372036854775807 WITH TIES 
      SCL_CABEZAL_CREDITOS.LOTE AS LOTE, 
      SCL_CABEZAL_CREDITOS.MONTO, 
      SCL_CABEZAL_CREDITOS.FECHA_ACREDITACION, 
      SCL_CABEZAL_CREDITOS.FECHA_ALTA, 
      SCL_CABEZAL_CREDITOS.ESTADO, 
      SCL_CABEZAL_CREDITOS.CAUSAL, 
      SCL_CABEZAL_CREDITOS.LOTE_REFERENCIA, 
      SCL_CABEZAL_CREDITOS.ID_CONVENIO AS NROCONVENIO, 
      PCT_CONVENIOS_PAGOS.NOMBRE
   FROM dbo.SCL_CABEZAL_CREDITOS WITH(NOLOCK), 
		dbo.PCT_CONVENIOS_PAGOS WITH(NOLOCK)
   WHERE 
      SCL_CABEZAL_CREDITOS.ID_CONVENIO = PCT_CONVENIOS_PAGOS.ID_CONVENIO AND 
      ((SCL_CABEZAL_CREDITOS.TZ_LOCK < 300000000000000 OR SCL_CABEZAL_CREDITOS.TZ_LOCK >= 400000000000000) 
		AND (SCL_CABEZAL_CREDITOS.TZ_LOCK < 100000000000000 OR SCL_CABEZAL_CREDITOS.TZ_LOCK >= 200000000000000)) AND 
      ((PCT_CONVENIOS_PAGOS.TZ_LOCK < 300000000000000 OR PCT_CONVENIOS_PAGOS.TZ_LOCK >= 400000000000000) 
		AND (PCT_CONVENIOS_PAGOS.TZ_LOCK < 100000000000000 OR PCT_CONVENIOS_PAGOS.TZ_LOCK >= 200000000000000))
   ORDER BY SCL_CABEZAL_CREDITOS.LOTE
   ; ')
execute('
ALTER VIEW [dbo].[VW_CARTERA] (
						   CLIENTE, 
						   PERSONA, 
						   MES, 
						   ANIO, 
						   PAIS, 
						   TIPO_DOC, 
						   NRO_DOC, 
						   GRUPO_ECONOMICO)
AS 
   SELECT 
      CLI.CODIGOCLIENTE AS CLIENTE, 
      PER.NUMEROPERSONA AS PERSONA, 
      CAR.FECHA_MES AS MES, 
      CAR.FECHA_ANIO AS ANIO, 
      CAR.PAIS_DOCUMENTO AS PAIS, 
      CAR.TIPO_DOCUMENTO AS TIPO_DOC, 
      CAR.NRO_DOCUMENTO AS NRO_DOC, 
      CAR.GRUPO_ECONOMICO AS GRUPO_ECONOMICO
   FROM dbo.CLI_CLIENTES  AS CLI WITH (NOLOCK), 
		dbo.CLI_CLIENTEPERSONA  AS PER WITH (NOLOCK), 
		dbo.CRE_CARTERA  AS CAR WITH (NOLOCK)
   WHERE 
      ((CAR.TZ_LOCK < 300000000000000 OR CAR.TZ_LOCK >= 400000000000000) 
		AND (CAR.TZ_LOCK < 100000000000000 OR CAR.TZ_LOCK >= 200000000000000)) AND 
      ((PER.TZ_LOCK < 300000000000000 OR PER.TZ_LOCK >= 400000000000000) 
		AND (PER.TZ_LOCK < 100000000000000 OR PER.TZ_LOCK >= 200000000000000)) AND 
      ((CLI.TZ_LOCK < 300000000000000 OR CLI.TZ_LOCK >= 400000000000000) 
		AND (CLI.TZ_LOCK < 100000000000000 OR CLI.TZ_LOCK >= 200000000000000)) AND 
      CLI.CODIGOCLIENTE = PER.CODIGOCLIENTE AND 
      CAR.NRO_PERSONA = PER.NUMEROPERSONA
   ; ')
execute('
ALTER VIEW [dbo].[VW_CHE_CHEQUERAS_RECIBIDAS] (
										   PRODUCTO, 
										   MONEDA, 
										   TIPOLIBRETA, 
										   CANTIDADCHEQUES, 
										   CANTIDADCHEQUERAS, 
										   TOTALCHEQUES, 
										   FECHARECEPCIONIMP)
AS 
   SELECT TOP 9223372036854775807 WITH TIES 
      CHE_CHEQUERAS.PRODUCTO, 
      CHE_CHEQUERAS.MONEDA, 
      CHE_CHEQUERAS.TIPOLIBRETA, 
      CHE_CHEQUERAS.CANTIDADCHEQUES, 
      count_big(*) AS CANTIDADCHEQUERAS, 
      CHE_CHEQUERAS.CANTIDADCHEQUES * count_big(*) AS TOTALCHEQUES, 
      CHE_CHEQUERAS.FECHARECEPCIONIMP
   FROM dbo.CHE_CHEQUERAS WITH(NOLOCK)
   GROUP BY 
      CHE_CHEQUERAS.PRODUCTO, 
      CHE_CHEQUERAS.MONEDA, 
      CHE_CHEQUERAS.TIPOLIBRETA, 
      CHE_CHEQUERAS.CANTIDADCHEQUES, 
      CHE_CHEQUERAS.FECHARECEPCIONIMP
   ORDER BY 
      CHE_CHEQUERAS.PRODUCTO, 
      CHE_CHEQUERAS.MONEDA, 
      CHE_CHEQUERAS.TIPOLIBRETA, 
      CHE_CHEQUERAS.CANTIDADCHEQUES, 
      CHE_CHEQUERAS.FECHARECEPCIONIMP
   ; ')
execute(' 
ALTER VIEW [dbo].[VW_CHE_SUSP_TIT_FIRM] (
									   JTS_SALDOS, 
									   CUENTA, 
									   SERIE_CHEQUE, 
									   NRO_CHEQUE, 
									   NUMEROPERSONA, 
									   NOMBRE, 
									   TIPO_PERS, 
									   TIPO_DOC, 
									   NRO_DOC, 
									   FECHA_NOTIF_JUDICIAL, 
									   FECHA_EMISION, 
									   FECHA_CHEQUE)
AS 
   SELECT 
      B.JTS_SALDOS, 
      B.CUENTA, 
      B.SERIE_CHEQUE, 
      B.NRO_CHEQUE, 
      P.NUMEROPERSONA, 
      
         ISNULL(F.PRIMERNOMBRE, '''')
          + 
         '' ''
          + 
         ISNULL(F.SEGUNDONOMBRE, '''')
          + 
         '' ''
          + 
         ISNULL(F.APELLIDOPATERNO, '''')
          + 
         '' ''
          + 
         ISNULL(F.APELLIDOMATERNO, '''') AS NOMBRE, 
      ''AF'' AS TIPO_PERS, 
      D.TIPODOCUMENTO AS TIPO_DOC, 
      D.NUMERODOCUMENTO AS NRO_DOC, 
      B.FECHA_NOTIF_JUDICIAL, 
      B.FECHA_EMISION, 
      B.FECHA_CHEQUE
   FROM 
      dbo.CHE_BCO_RECHAZADOS  AS B WITH(NOLOCK), 
      dbo.CLI_CLIENTEPERSONA  AS P WITH(NOLOCK), 
      dbo.CLI_PERSONASFISICAS  AS F WITH(NOLOCK), 
      dbo.CLI_DOCUMENTOSPFPJ  AS D WITH(NOLOCK)
   WHERE 
      B.CLIENTE = P.CODIGOCLIENTE AND 
      P.NUMEROPERSONA = F.NUMEROPERSONAFISICA AND 
      P.NUMEROPERSONA = D.NUMEROPERSONAFJ AND 
      D.TIPOPERSONA IN ( ''F'', ''U'' ) AND 
      (B.TZ_LOCK < 310000000000000 OR B.TZ_LOCK > 339999999999999) AND 
      (P.TZ_LOCK < 310000000000000 OR P.TZ_LOCK > 339999999999999) AND 
      (F.TZ_LOCK < 310000000000000 OR F.TZ_LOCK > 339999999999999) AND 
      (D.TZ_LOCK < 310000000000000 OR D.TZ_LOCK > 339999999999999)
    UNION ALL
   SELECT 
      B.JTS_SALDOS, 
      B.CUENTA, 
      B.SERIE_CHEQUE, 
      B.NRO_CHEQUE, 
      P.NUMEROPERSONA, 
      J.RAZONSOCIAL AS NOMBRE, 
      ''AJ'' AS TIPO_PERS, 
      D.TIPODOCUMENTO AS TIPO_DOC, 
      D.NUMERODOCUMENTO AS NRO_DOC, 
      B.FECHA_NOTIF_JUDICIAL, 
      B.FECHA_EMISION, 
      B.FECHA_CHEQUE
   FROM 
      dbo.CHE_BCO_RECHAZADOS  AS B WITH(NOLOCK), 
      dbo.CLI_CLIENTEPERSONA  AS P WITH(NOLOCK), 
      dbo.CLI_PERSONASJURIDICAS  AS J WITH(NOLOCK), 
      dbo.CLI_DOCUMENTOSPFPJ  AS D WITH(NOLOCK)
   WHERE 
      B.CLIENTE = P.CODIGOCLIENTE AND 
      P.NUMEROPERSONA = J.NUMEROPERSONAJURIDICA AND 
      P.NUMEROPERSONA = D.NUMEROPERSONAFJ AND 
      D.TIPOPERSONA = ''J'' AND 
      (B.TZ_LOCK < 310000000000000 OR B.TZ_LOCK > 339999999999999) AND 
      (P.TZ_LOCK < 310000000000000 OR P.TZ_LOCK > 339999999999999) AND 
      (J.TZ_LOCK < 310000000000000 OR J.TZ_LOCK > 339999999999999) AND 
      (D.TZ_LOCK < 310000000000000 OR D.TZ_LOCK > 339999999999999)
    UNION ALL
   SELECT 
      B.JTS_SALDOS, 
      B.CUENTA, 
      B.SERIE_CHEQUE, 
      B.NRO_CHEQUE, 
      F.NUMEROPERSONA, 
      F.NOMB_FIRMANTE AS NOMBRE, 
      ''F'' AS TIPO_PERS, 
      F.TIPO_DOC, 
      F.NRO_DOCUM AS NRO_DOC, 
      B.FECHA_NOTIF_JUDICIAL, 
      B.FECHA_EMISION, 
      B.FECHA_CHEQUE
   FROM dbo.CHE_BCO_RECHAZADOS  AS B WITH(NOLOCK), 
		dbo.CLE_FIRMANTES_DEV  AS F WITH(NOLOCK)
   WHERE 
      B.JTS_SALDOS = F.JTS_SALDOS AND 
      B.NRO_CHEQUE = F.NRO_CHEQUE AND 
      B.NRO_CHEQUE = F.NRO_CHEQUE AND 
      (B.TZ_LOCK < 310000000000000 OR B.TZ_LOCK > 339999999999999) AND 
      (F.TZ_LOCK < 310000000000000 OR F.TZ_LOCK > 339999999999999)
 ; ')
 execute(' 
 ALTER VIEW [dbo].[VW_CHEQUES_CLE_REC_SALDOS] (
   SUCURSAL, 
   MONEDA, 
   CUENTA, 
   PRODUCTO, 
   OPERACION, 
   CLIENTE)
AS 
   SELECT 
      P.SUCURSAL, 
      P.MONEDA, 
      P.CUENTA, 
      P.PRODUCTO, 
      P.OPERACION, 
      V.C1803 AS CLIENTE
   FROM dbo.CLE_CHEQUES_CLEARING_RECIBIDO  AS P WITH(NOLOCK), 
		dbo.SALDOS  AS V WITH(NOLOCK)
   WHERE 
      P.SUCURSAL = V.SUCURSAL AND 
      P.MONEDA = V.MONEDA AND 
      P.CUENTA = V.CUENTA AND 
      P.PRODUCTO = V.PRODUCTO AND 
      P.OPERACION = V.OPERACION AND 
      V.ORDINAL = 0 AND 
      ((V.TZ_LOCK < 300000000000000 OR V.TZ_LOCK >= 400000000000000) 
		AND (V.TZ_LOCK < 100000000000000 OR V.TZ_LOCK >= 200000000000000)) AND 
      ((P.TZ_LOCK < 300000000000000 OR P.TZ_LOCK >= 400000000000000) 
		AND (P.TZ_LOCK < 100000000000000 OR P.TZ_LOCK >= 200000000000000))
 ; ')
 execute(' 
 ALTER VIEW [dbo].[VW_CLEARING_NOSOBREGIROS] (
										   SUCURSAL, 
										   PRODUCTO, 
										   MONEDA, 
										   CUENTA, 
										   OPERACION, 
										   SALDOALCORTE, 
										   FECHA, 
										   DIFERENCIA)
AS 
   SELECT 
      fci.SUCURSAL, 
      fci.PRODUCTO, 
      fci.MONEDA, 
      fci.CUENTA, 
      fci.OPERACION, 
      fci.SALDOALCORTE, 
      fci.FECHA, 
      fci.DIFERENCIA
   FROM 
      (
         SELECT 
            fci$2.SUCURSAL, 
            fci$2.PRODUCTO, 
            fci$2.MONEDA, 
            fci$2.CUENTA, 
            fci$2.OPERACION, 
            fci$2.SALDO_AL_CORTE AS SALDOALCORTE, 
            fci$2.FECHA, 
            CASE 
               WHEN fci$2.SALDO IS NULL THEN 0
               ELSE fci$2.SALDO_AL_CORTE - CAST(fci$2.SALDO AS float(53))
            END AS SALDO, 
            (CAST(fci$2.SALDOALCORTE AS float(53)) - CAST(fci$2.SALDO AS float(53))) AS DIFERENCIA
         FROM 
            (
               SELECT 
                  S.SUCURSAL, 
                  S.PRODUCTO, 
                  S.MONEDA, 
                  S.CUENTA, 
                  S.OPERACION, 
                  SD.SALDO_AL_CORTE, 
                  SD.FECHA, 
                  CASE 
                     WHEN S.C1603 IS NULL THEN 0
                     ELSE SD.SALDO_AL_CORTE
                  END AS SALDOALCORTE, 
                  sum(CCR.IMPORTE_CHEQUE) AS SALDO
               FROM 
                  dbo.GRL_SALDOS_DIARIOS  AS SD WITH(NOLOCK), 
                  dbo.SALDOS  AS S WITH(NOLOCK), 
                  dbo.CLE_CHEQUES_CLEARING_RECIBIDO  AS CCR  WITH(NOLOCK), 
                  dbo.CLE_TIPO_CAUSAL  AS C WITH(NOLOCK)
               WHERE 
                  S.JTS_OID = SD.SALDOS_JTS_OID AND 
                  S.SUCURSAL = CCR.SUCURSAL AND 
                  S.MONEDA = CCR.MONEDA AND 
                  S.CUENTA = CCR.CUENTA AND 
                  S.PRODUCTO = CCR.PRODUCTO AND 
                  S.OPERACION = CCR.OPERACION AND 
                  S.ORDINAL = 0 AND 
                  C.CODIGO_DE_CAUSAL = CCR.CODIGO_CAUSAL_DEVOLUCION AND 
                  C.TIPO_RECHAZO IN ( 1, 2 ) AND 
                  CCR.FECHA = CONVERT(datetime2, ''20100416'', 112) AND 
                  SD.FECHA = CONVERT(datetime2, ''20100415'', 112) AND 
                  CCR.ESTADO_DEVOLUCION = 1 AND 
                  C.DEVOLUCION_AUTOMATICA = ''S''
               GROUP BY 
                  S.SUCURSAL, 
                  S.PRODUCTO, 
                  S.MONEDA, 
                  S.CUENTA, 
                  S.OPERACION, 
                  S.C1603, 
                  SD.SALDO_AL_CORTE, 
                  SD.FECHA
            )  AS fci$2
      )  AS fci
 ; ')
 execute('
 ALTER VIEW [dbo].[VW_JMPM_PROCESS_INSTANCE] (
											   NROSOLICITUD, 
											   TIPO, 
											   PROCESS_INSTANCE, 
											   TZ_LOCK)
AS 
   SELECT	J.NROSOLICITUD AS NROSOLICITUD, 
			''E'' AS TIPO, 
			J.PROCESSINSTANCE_ID AS PROCESS_INSTANCE, 
			0 AS TZ_LOCK
   FROM dbo.CRE_SOLICITUDCREDITO  AS S WITH(NOLOCK), 
		dbo.JBPM_TZKEY_SOLICITUDCREDITOSEMPRESAS  AS J WITH(NOLOCK)
   WHERE S.NUMEROSOLICITUD = J.NROSOLICITUD
 ; ')
 execute('
 ALTER VIEW [dbo].[VW_CLI_DOC_FALTANTE] (
									   OFICIAL, 
									   NOM_OFICIAL, 
									   CLIENTE, 
									   NOM_CLIENTE, 
									   TIPO_DEUDOR, 
									   SEGMENTO, 
									   DESC_SEGMENTO, 
									   CODIGO_DOC, 
									   DESC_DOC, 
									   FECHA_PRESENTACION, 
									   FECHA_VENCIMIENTO, 
									   REQUERIDA_EVALUACION, 
									   TIPO, 
									   FECHA_BALANCE)
AS 
   SELECT DISTINCT 
      fci.OFICIAL, 
      fci.NOM_OFICIAL, 
      fci.CLIENTE, 
      fci.NOM_CLIENTE, 
      fci.TIPO_DEUDOR, 
      fci.SEGMENTO, 
      fci.DESC_SEGMENTO, 
      fci.CODIGO_DOC, 
      fci.DESC_DOC, 
      fci.FECHA_PRESENTACION, 
      fci.FECHA_VENCIMIENTO, 
      fci.REQUERIDA_EVALUACION, 
      ''F'' AS TIPO, 
      fci.FECHA_BALANCE
   FROM 
      (
         /*Tiene Información Financiera*/
         SELECT DISTINCT 
            C3.EJECUTIVOCLIENTE AS OFICIAL, 
            O3.NOMBREOFIC AS NOM_OFICIAL, 
            C3.CODIGOCLIENTE AS CLIENTE, 
            C3.NOMBRECLIENTE AS NOM_CLIENTE, 
            TD3.TIPO_DEUDOR, 
            C3.SEGMENTOCLIENTE AS SEGMENTO, 
            S3.DESCRIPCION_SEGMENTO AS DESC_SEGMENTO, 
            DOC3.CODIGO_DOCUMENTO AS CODIGO_DOC, 
            DOC3.DESCRIPCION_DOCUMENTO AS DESC_DOC, 
            CAST(NULL AS DATETIME) AS FECHA_PRESENTACION, 
            CAST(NULL AS DATETIME) AS FECHA_VENCIMIENTO, 
            TD3.REQUERIDA_EVALUACION, 
            FIN3.FECHA_BALANCE AS FECHA_BALANCE
         FROM 
            dbo.CLI_CLIENTES  AS C3 WITH(NOLOCK), 
            dbo.CLI_CLIENTEPERSONA  AS CP3 WITH(NOLOCK), 
            dbo.CLI_OFICUENTA  AS O3 WITH(NOLOCK), 
            dbo.CLI_SEGMENTOS  AS S3 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS  AS DOC3 WITH(NOLOCK), 
            dbo.CRE_DOC_TIPO_DEUDOR  AS TD3 WITH(NOLOCK), 
            dbo.CRE_INFO_FINANCIERA  AS FIN3 WITH(NOLOCK)
         WHERE 
            (C3.CODIGOCLIENTE = CP3.CODIGOCLIENTE) AND 
            (CP3.TITULARIDAD = ''T'') AND 
            (C3.TIPO_DEUDOR = TD3.TIPO_DEUDOR) AND 
            (TD3.COD_DOCUMENTO = DOC3.CODIGO_DOCUMENTO) AND 
            (C3.EJECUTIVOCLIENTE = O3.CODOFICIAL) AND 
            (C3.SEGMENTOCLIENTE = S3.COD_SEGMENTO) AND 
            (FIN3.PERSONA_JURIDICA = CP3.NUMEROPERSONA) AND 
            ((C3.TZ_LOCK < 300000000000000 OR C3.TZ_LOCK >= 400000000000000) 
				AND (C3.TZ_LOCK < 100000000000000 OR C3.TZ_LOCK >= 200000000000000)) AND 
            ((CP3.TZ_LOCK < 300000000000000 OR CP3.TZ_LOCK >= 400000000000000) 
				AND (CP3.TZ_LOCK < 100000000000000 OR CP3.TZ_LOCK >= 200000000000000)) AND 
            ((O3.TZ_LOCK < 300000000000000 OR O3.TZ_LOCK >= 400000000000000) 
				AND (O3.TZ_LOCK < 100000000000000 OR O3.TZ_LOCK >= 200000000000000)) AND 
            ((S3.TZ_LOCK < 300000000000000 OR S3.TZ_LOCK >= 400000000000000) 
				AND (S3.TZ_LOCK < 100000000000000 OR S3.TZ_LOCK >= 200000000000000)) AND 
            ((DOC3.TZ_LOCK < 300000000000000 OR DOC3.TZ_LOCK >= 400000000000000) 
				AND (DOC3.TZ_LOCK < 100000000000000 OR DOC3.TZ_LOCK >= 200000000000000)) AND 
            ((TD3.TZ_LOCK < 300000000000000 OR TD3.TZ_LOCK >= 400000000000000) 
				AND (TD3.TZ_LOCK < 100000000000000 OR TD3.TZ_LOCK >= 200000000000000)) AND 
            ((FIN3.TZ_LOCK < 300000000000000 OR FIN3.TZ_LOCK >= 400000000000000) 
				AND (FIN3.TZ_LOCK < 100000000000000 OR FIN3.TZ_LOCK >= 200000000000000)) AND 
            (NOT EXISTS 
            (
               SELECT 
                  D4.TZ_LOCK, 
                  D4.CODIGO_PERSONA, 
                  D4.CODIGO_DOCUMENTO, 
                  D4.NUMERO_DOCUMENTO, 
                  D4.FECHA_PRESENTACION, 
                  D4.FECHA_VENCIMIENTO, 
                  D4.CODIGO_EXONERACION, 
                  D4.MOTIVO_EXONERACION, 
                  D4.FECHA_SUSPENDIDO_VIGENTE, 
                  D4.ESTADO, 
                  D4.DEPARTAMENTO_EMISOR
               FROM dbo.CLI_DOCUMENTOS_PERSONAS  AS D4  WITH(NOLOCK)
               WHERE 
                  ((D4.TZ_LOCK < 300000000000000 OR D4.TZ_LOCK >= 400000000000000) 
					AND (D4.TZ_LOCK < 100000000000000 OR D4.TZ_LOCK >= 200000000000000)) AND 
                  (DOC3.CODIGO_DOCUMENTO = D4.CODIGO_DOCUMENTO) AND 
                  (D4.CODIGO_PERSONA = CP3.NUMEROPERSONA)
            ))
          UNION
         /*No Tiene Información Financiera*/
         SELECT DISTINCT 
            C3$2.EJECUTIVOCLIENTE AS OFICIAL, 
            O3$2.NOMBREOFIC AS NOM_OFICIAL, 
            C3$2.CODIGOCLIENTE AS CLIENTE, 
            C3$2.NOMBRECLIENTE AS NOM_CLIENTE, 
            TD3$2.TIPO_DEUDOR, 
            C3$2.SEGMENTOCLIENTE AS SEGMENTO, 
            S3$2.DESCRIPCION_SEGMENTO AS DESC_SEGMENTO, 
            DOC3$2.CODIGO_DOCUMENTO AS CODIGO_DOC, 
            DOC3$2.DESCRIPCION_DOCUMENTO AS DESC_DOC, 
            CAST(NULL AS DATETIME) AS FECHA_PRESENTACION, 
            CAST(NULL AS DATETIME) AS FECHA_VENCIMIENTO, 
            TD3$2.REQUERIDA_EVALUACION, 
            CAST(NULL AS DATETIME) AS FECHA_BALANCE
         FROM 
            dbo.CLI_CLIENTES  AS C3$2 WITH(NOLOCK), 
            dbo.CLI_CLIENTEPERSONA  AS CP3$2 WITH(NOLOCK), 
            dbo.CLI_OFICUENTA  AS O3$2 WITH(NOLOCK), 
            dbo.CLI_SEGMENTOS  AS S3$2 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS  AS DOC3$2 WITH(NOLOCK), 
            dbo.CRE_DOC_TIPO_DEUDOR  AS TD3$2 WITH(NOLOCK)
         WHERE 
            (C3$2.CODIGOCLIENTE = CP3$2.CODIGOCLIENTE) AND 
            (CP3$2.TITULARIDAD = ''T'') AND 
            (C3$2.TIPO_DEUDOR = TD3$2.TIPO_DEUDOR) AND 
            (TD3$2.COD_DOCUMENTO = DOC3$2.CODIGO_DOCUMENTO) AND 
            (C3$2.EJECUTIVOCLIENTE = O3$2.CODOFICIAL) AND 
            (C3$2.SEGMENTOCLIENTE = S3$2.COD_SEGMENTO) AND 
            ((C3$2.TZ_LOCK < 300000000000000 OR C3$2.TZ_LOCK >= 400000000000000) 
				AND (C3$2.TZ_LOCK < 100000000000000 OR C3$2.TZ_LOCK >= 200000000000000)) AND 
            ((CP3$2.TZ_LOCK < 300000000000000 OR CP3$2.TZ_LOCK >= 400000000000000) 
				AND (CP3$2.TZ_LOCK < 100000000000000 OR CP3$2.TZ_LOCK >= 200000000000000)) AND 
            ((O3$2.TZ_LOCK < 300000000000000 OR O3$2.TZ_LOCK >= 400000000000000) 
				AND (O3$2.TZ_LOCK < 100000000000000 OR O3$2.TZ_LOCK >= 200000000000000)) AND 
            ((S3$2.TZ_LOCK < 300000000000000 OR S3$2.TZ_LOCK >= 400000000000000) 
				AND (S3$2.TZ_LOCK < 100000000000000 OR S3$2.TZ_LOCK >= 200000000000000)) AND 
            ((DOC3$2.TZ_LOCK < 300000000000000 OR DOC3$2.TZ_LOCK >= 400000000000000) 
				AND (DOC3$2.TZ_LOCK < 100000000000000 OR DOC3$2.TZ_LOCK >= 200000000000000)) AND 
            ((TD3$2.TZ_LOCK < 300000000000000 OR TD3$2.TZ_LOCK >= 400000000000000) 
				AND (TD3$2.TZ_LOCK < 100000000000000 OR TD3$2.TZ_LOCK >= 200000000000000)) AND 
            CP3$2.NUMEROPERSONA NOT IN 
            (
               SELECT FIN.PERSONA_JURIDICA
               FROM dbo.CRE_INFO_FINANCIERA  AS FIN WITH(NOLOCK)
               WHERE ((FIN.TZ_LOCK < 300000000000000 OR FIN.TZ_LOCK >= 400000000000000) 
				AND (FIN.TZ_LOCK < 100000000000000 OR FIN.TZ_LOCK >= 200000000000000))
            ) AND 
            (NOT EXISTS 
            (
               SELECT 
                  D4$2.TZ_LOCK, 
                  D4$2.CODIGO_PERSONA, 
                  D4$2.CODIGO_DOCUMENTO, 
                  D4$2.NUMERO_DOCUMENTO, 
                  D4$2.FECHA_PRESENTACION, 
                  D4$2.FECHA_VENCIMIENTO, 
                  D4$2.CODIGO_EXONERACION, 
                  D4$2.MOTIVO_EXONERACION, 
                  D4$2.FECHA_SUSPENDIDO_VIGENTE, 
                  D4$2.ESTADO, 
                  D4$2.DEPARTAMENTO_EMISOR
               FROM dbo.CLI_DOCUMENTOS_PERSONAS  AS D4$2 WITH(NOLOCK)
               WHERE 
                  ((D4$2.TZ_LOCK < 300000000000000 OR D4$2.TZ_LOCK >= 400000000000000) 
					AND (D4$2.TZ_LOCK < 100000000000000 OR D4$2.TZ_LOCK >= 200000000000000)) AND 
                  (DOC3$2.CODIGO_DOCUMENTO = D4$2.CODIGO_DOCUMENTO) AND 
                  (D4$2.CODIGO_PERSONA = CP3$2.NUMEROPERSONA)
            ))
      )  AS fci
 ; ')
 execute(' 
ALTER VIEW [dbo].[VW_CLI_DOC_PRESENTADO] (
										   OFICIAL, 
										   NOM_OFICIAL, 
										   CLIENTE, 
										   NOM_CLIENTE, 
										   TIPO_DEUDOR, 
										   SEGMENTO, 
										   DESC_SEGMENTO, 
										   CODIGO_DOC, 
										   DESC_DOC, 
										   FECHA_PRESENTACION, 
										   FECHA_VENCIMIENTO, 
										   REQUERIDA_EVALUACION, 
										   TIPO, 
										   FECHA_BALANCE)
AS 
   SELECT DISTINCT 
      fci.OFICIAL, 
      fci.NOM_OFICIAL, 
      fci.CLIENTE, 
      fci.NOM_CLIENTE, 
      fci.TIPO_DEUDOR, 
      fci.SEGMENTO, 
      fci.DESC_SEGMENTO, 
      fci.CODIGO_DOC, 
      fci.DESC_DOC, 
      fci.FECHA_PRESENTACION, 
      fci.FECHA_VENCIMIENTO, 
      fci.REQUERIDA_EVALUACION, 
      ''P'' AS TIPO, 
      fci.FECHA_BALANCE
   FROM 
      (
         
         /*
         *   Tiene Información financiera
         *   Tiene Documentos Por Tipo Deudor
         */
         SELECT 
            C1.EJECUTIVOCLIENTE AS OFICIAL, 
            O1.NOMBREOFIC AS NOM_OFICIAL, 
            C1.CODIGOCLIENTE AS CLIENTE, 
            C1.NOMBRECLIENTE AS NOM_CLIENTE, 
            TD1.TIPO_DEUDOR, 
            C1.SEGMENTOCLIENTE AS SEGMENTO, 
            S1.DESCRIPCION_SEGMENTO AS DESC_SEGMENTO, 
            D1.CODIGO_DOCUMENTO AS CODIGO_DOC, 
            DOC1.DESCRIPCION_DOCUMENTO AS DESC_DOC, 
            D1.FECHA_PRESENTACION, 
            D1.FECHA_VENCIMIENTO, 
            TD1.REQUERIDA_EVALUACION, 
            FIN1.FECHA_BALANCE AS FECHA_BALANCE
         FROM 
            dbo.CLI_CLIENTES  AS C1 WITH(NOLOCK), 
            dbo.CLI_CLIENTEPERSONA  AS CP1 WITH(NOLOCK), 
            dbo.CLI_OFICUENTA  AS O1 WITH(NOLOCK), 
            dbo.CLI_SEGMENTOS  AS S1 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS_PERSONAS  AS D1 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS  AS DOC1 WITH(NOLOCK), 
            dbo.CRE_DOC_TIPO_DEUDOR  AS TD1 WITH(NOLOCK), 
            dbo.CRE_INFO_FINANCIERA  AS FIN1 WITH(NOLOCK)
         WHERE 
            (C1.CODIGOCLIENTE = CP1.CODIGOCLIENTE) AND 
            (CP1.TITULARIDAD = ''T'') AND 
            (C1.TIPO_DEUDOR = TD1.TIPO_DEUDOR) AND 
            (CP1.NUMEROPERSONA = D1.CODIGO_PERSONA) AND 
            (D1.CODIGO_DOCUMENTO = DOC1.CODIGO_DOCUMENTO) AND 
            (TD1.COD_DOCUMENTO = D1.CODIGO_DOCUMENTO) AND 
            (C1.EJECUTIVOCLIENTE = O1.CODOFICIAL) AND 
            (C1.SEGMENTOCLIENTE = S1.COD_SEGMENTO) AND 
            (FIN1.PERSONA_JURIDICA = CP1.NUMEROPERSONA) AND 
            ((C1.TZ_LOCK < 300000000000000 OR C1.TZ_LOCK >= 400000000000000) AND (C1.TZ_LOCK < 100000000000000 OR C1.TZ_LOCK >= 200000000000000)) AND 
            ((CP1.TZ_LOCK < 300000000000000 OR CP1.TZ_LOCK >= 400000000000000) AND (CP1.TZ_LOCK < 100000000000000 OR CP1.TZ_LOCK >= 200000000000000)) AND 
            ((O1.TZ_LOCK < 300000000000000 OR O1.TZ_LOCK >= 400000000000000) AND (O1.TZ_LOCK < 100000000000000 OR O1.TZ_LOCK >= 200000000000000)) AND 
            ((S1.TZ_LOCK < 300000000000000 OR S1.TZ_LOCK >= 400000000000000) AND (S1.TZ_LOCK < 100000000000000 OR S1.TZ_LOCK >= 200000000000000)) AND 
            ((D1.TZ_LOCK < 300000000000000 OR D1.TZ_LOCK >= 400000000000000) AND (D1.TZ_LOCK < 100000000000000 OR D1.TZ_LOCK >= 200000000000000)) AND 
            ((DOC1.TZ_LOCK < 300000000000000 OR DOC1.TZ_LOCK >= 400000000000000) AND (DOC1.TZ_LOCK < 100000000000000 OR DOC1.TZ_LOCK >= 200000000000000)) AND 
            ((TD1.TZ_LOCK < 300000000000000 OR TD1.TZ_LOCK >= 400000000000000) AND (TD1.TZ_LOCK < 100000000000000 OR TD1.TZ_LOCK >= 200000000000000)) AND 
            ((FIN1.TZ_LOCK < 300000000000000 OR FIN1.TZ_LOCK >= 400000000000000) AND (FIN1.TZ_LOCK < 100000000000000 OR FIN1.TZ_LOCK >= 200000000000000))
          UNION
         /* No Tiene Documentos Por Tipo Deudor*/
         SELECT 
            C1$2.EJECUTIVOCLIENTE AS OFICIAL, 
            O1$2.NOMBREOFIC AS NOM_OFICIAL, 
            C1$2.CODIGOCLIENTE AS CLIENTE, 
            C1$2.NOMBRECLIENTE AS NOM_CLIENTE, 
            C1$2.TIPO_DEUDOR, 
            C1$2.SEGMENTOCLIENTE AS SEGMENTO, 
            S1$2.DESCRIPCION_SEGMENTO AS DESC_SEGMENTO, 
            D1$2.CODIGO_DOCUMENTO AS CODIGO_DOC, 
            DOC1$2.DESCRIPCION_DOCUMENTO AS DESC_DOC, 
            D1$2.FECHA_PRESENTACION, 
            D1$2.FECHA_VENCIMIENTO, 
            NULL AS REQUERIDA_EVALUACION, 
            FIN1$2.FECHA_BALANCE AS FECHA_BALANCE
         FROM 
            dbo.CLI_CLIENTES  AS C1$2 WITH(NOLOCK), 
            dbo.CLI_CLIENTEPERSONA  AS CP1$2 WITH(NOLOCK), 
            dbo.CLI_OFICUENTA  AS O1$2 WITH(NOLOCK), 
            dbo.CLI_SEGMENTOS  AS S1$2 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS_PERSONAS  AS D1$2 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS  AS DOC1$2 WITH(NOLOCK), 
            dbo.CRE_INFO_FINANCIERA  AS FIN1$2 WITH(NOLOCK)
         WHERE 
            (C1$2.CODIGOCLIENTE = CP1$2.CODIGOCLIENTE) AND 
            (CP1$2.TITULARIDAD = ''T'') AND 
            (CP1$2.NUMEROPERSONA = D1$2.CODIGO_PERSONA) AND 
            (D1$2.CODIGO_DOCUMENTO = DOC1$2.CODIGO_DOCUMENTO) AND 
            (C1$2.EJECUTIVOCLIENTE = O1$2.CODOFICIAL) AND 
            (C1$2.SEGMENTOCLIENTE = S1$2.COD_SEGMENTO) AND 
            (FIN1$2.PERSONA_JURIDICA = CP1$2.NUMEROPERSONA) AND 
            ((C1$2.TZ_LOCK < 300000000000000 OR C1$2.TZ_LOCK >= 400000000000000) 
				AND (C1$2.TZ_LOCK < 100000000000000 OR C1$2.TZ_LOCK >= 200000000000000)) AND 
            ((CP1$2.TZ_LOCK < 300000000000000 OR CP1$2.TZ_LOCK >= 400000000000000) 
				AND (CP1$2.TZ_LOCK < 100000000000000 OR CP1$2.TZ_LOCK >= 200000000000000)) AND 
            ((O1$2.TZ_LOCK < 300000000000000 OR O1$2.TZ_LOCK >= 400000000000000) 
				AND (O1$2.TZ_LOCK < 100000000000000 OR O1$2.TZ_LOCK >= 200000000000000)) AND 
            ((S1$2.TZ_LOCK < 300000000000000 OR S1$2.TZ_LOCK >= 400000000000000) 
				AND (S1$2.TZ_LOCK < 100000000000000 OR S1$2.TZ_LOCK >= 200000000000000)) AND 
            ((D1$2.TZ_LOCK < 300000000000000 OR D1$2.TZ_LOCK >= 400000000000000) 
				AND (D1$2.TZ_LOCK < 100000000000000 OR D1$2.TZ_LOCK >= 200000000000000)) AND 
            ((DOC1$2.TZ_LOCK < 300000000000000 OR DOC1$2.TZ_LOCK >= 400000000000000) 
				AND (DOC1$2.TZ_LOCK < 100000000000000 OR DOC1$2.TZ_LOCK >= 200000000000000)) AND 
            ((FIN1$2.TZ_LOCK < 300000000000000 OR FIN1$2.TZ_LOCK >= 400000000000000) 
				AND (FIN1$2.TZ_LOCK < 100000000000000 OR FIN1$2.TZ_LOCK >= 200000000000000)) AND 
            D1$2.CODIGO_DOCUMENTO NOT IN 
            (
               SELECT DT1.COD_DOCUMENTO
               FROM dbo.CRE_DOC_TIPO_DEUDOR  AS DT1 WITH(NOLOCK)
               WHERE (		(DT1.TZ_LOCK < 300000000000000 OR DT1.TZ_LOCK >= 400000000000000) 
						AND (DT1.TZ_LOCK < 100000000000000 OR DT1.TZ_LOCK >= 200000000000000)) 
					AND C1$2.TIPO_DEUDOR = DT1.TIPO_DEUDOR
            )
          UNION      
         /*
         *    No Tiene Información financiera
         *   Tiene Documentos Por Tipo Deudor
         */
         SELECT 
            C1$3.EJECUTIVOCLIENTE AS OFICIAL, 
            O1$3.NOMBREOFIC AS NOM_OFICIAL, 
            C1$3.CODIGOCLIENTE AS CLIENTE, 
            C1$3.NOMBRECLIENTE AS NOM_CLIENTE, 
            TD1$2.TIPO_DEUDOR, 
            C1$3.SEGMENTOCLIENTE AS SEGMENTO, 
            S1$3.DESCRIPCION_SEGMENTO AS DESC_SEGMENTO, 
            D1$3.CODIGO_DOCUMENTO AS CODIGO_DOC, 
            DOC1$3.DESCRIPCION_DOCUMENTO AS DESC_DOC, 
            D1$3.FECHA_PRESENTACION, 
            D1$3.FECHA_VENCIMIENTO, 
            TD1$2.REQUERIDA_EVALUACION, 
            CAST(NULL AS DATETIME) AS FECHA_BALANCE
         FROM 
            dbo.CLI_CLIENTES  AS C1$3 WITH(NOLOCK), 
            dbo.CLI_CLIENTEPERSONA  AS CP1$3 WITH(NOLOCK), 
            dbo.CLI_OFICUENTA  AS O1$3 WITH(NOLOCK), 
            dbo.CLI_SEGMENTOS  AS S1$3 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS_PERSONAS  AS D1$3 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS  AS DOC1$3 WITH(NOLOCK), 
            dbo.CRE_DOC_TIPO_DEUDOR  AS TD1$2
         WHERE 
            (C1$3.CODIGOCLIENTE = CP1$3.CODIGOCLIENTE) AND 
            (CP1$3.TITULARIDAD = ''T'') AND 
            (C1$3.TIPO_DEUDOR = TD1$2.TIPO_DEUDOR) AND 
            (CP1$3.NUMEROPERSONA = D1$3.CODIGO_PERSONA) AND 
            (D1$3.CODIGO_DOCUMENTO = DOC1$3.CODIGO_DOCUMENTO) AND 
            (TD1$2.COD_DOCUMENTO = D1$3.CODIGO_DOCUMENTO) AND 
            (C1$3.EJECUTIVOCLIENTE = O1$3.CODOFICIAL) AND 
            (C1$3.SEGMENTOCLIENTE = S1$3.COD_SEGMENTO) AND 
            ((C1$3.TZ_LOCK < 300000000000000 OR C1$3.TZ_LOCK >= 400000000000000) 
				AND (C1$3.TZ_LOCK < 100000000000000 OR C1$3.TZ_LOCK >= 200000000000000)) AND 
            ((CP1$3.TZ_LOCK < 300000000000000 OR CP1$3.TZ_LOCK >= 400000000000000) 
				AND (CP1$3.TZ_LOCK < 100000000000000 OR CP1$3.TZ_LOCK >= 200000000000000)) AND 
            ((O1$3.TZ_LOCK < 300000000000000 OR O1$3.TZ_LOCK >= 400000000000000) 
				AND (O1$3.TZ_LOCK < 100000000000000 OR O1$3.TZ_LOCK >= 200000000000000)) AND 
            ((S1$3.TZ_LOCK < 300000000000000 OR S1$3.TZ_LOCK >= 400000000000000) 
				AND (S1$3.TZ_LOCK < 100000000000000 OR S1$3.TZ_LOCK >= 200000000000000)) AND 
            ((D1$3.TZ_LOCK < 300000000000000 OR D1$3.TZ_LOCK >= 400000000000000) 
				AND (D1$3.TZ_LOCK < 100000000000000 OR D1$3.TZ_LOCK >= 200000000000000)) AND 
            ((DOC1$3.TZ_LOCK < 300000000000000 OR DOC1$3.TZ_LOCK >= 400000000000000) 
				AND (DOC1$3.TZ_LOCK < 100000000000000 OR DOC1$3.TZ_LOCK >= 200000000000000)) AND 
            ((TD1$2.TZ_LOCK < 300000000000000 OR TD1$2.TZ_LOCK >= 400000000000000) 
				AND (TD1$2.TZ_LOCK < 100000000000000 OR TD1$2.TZ_LOCK >= 200000000000000)) AND 
            CP1$3.NUMEROPERSONA NOT IN 
            (
               SELECT FIN.PERSONA_JURIDICA
               FROM dbo.CRE_INFO_FINANCIERA  AS FIN WITH(NOLOCK)
               WHERE ((FIN.TZ_LOCK < 300000000000000 OR FIN.TZ_LOCK >= 400000000000000) 
				AND (FIN.TZ_LOCK < 100000000000000 OR FIN.TZ_LOCK >= 200000000000000))
            )
          UNION
         /* No Tiene Documentos Por Tipo Deudor*/
         SELECT 
            C1$4.EJECUTIVOCLIENTE AS OFICIAL, 
            O1$4.NOMBREOFIC AS NOM_OFICIAL, 
            C1$4.CODIGOCLIENTE AS CLIENTE, 
            C1$4.NOMBRECLIENTE AS NOM_CLIENTE, 
            C1$4.TIPO_DEUDOR, 
            C1$4.SEGMENTOCLIENTE AS SEGMENTO, 
            S1$4.DESCRIPCION_SEGMENTO AS DESC_SEGMENTO, 
            D1$4.CODIGO_DOCUMENTO AS CODIGO_DOC, 
            DOC1$4.DESCRIPCION_DOCUMENTO AS DESC_DOC, 
            D1$4.FECHA_PRESENTACION, 
            D1$4.FECHA_VENCIMIENTO, 
            NULL AS REQUERIDA_EVALUACION, 
            CAST(NULL AS DATETIME) AS FECHA_BALANCE
         FROM 
            dbo.CLI_CLIENTES  AS C1$4 WITH(NOLOCK), 
            dbo.CLI_CLIENTEPERSONA  AS CP1$4 WITH(NOLOCK), 
            dbo.CLI_OFICUENTA  AS O1$4 WITH(NOLOCK), 
            dbo.CLI_SEGMENTOS  AS S1$4 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS_PERSONAS  AS D1$4 WITH(NOLOCK), 
            dbo.CLI_DOCUMENTOS  AS DOC1$4 WITH(NOLOCK)
         WHERE 
            (C1$4.CODIGOCLIENTE = CP1$4.CODIGOCLIENTE) AND 
            (CP1$4.TITULARIDAD = ''T'') AND 
            (CP1$4.NUMEROPERSONA = D1$4.CODIGO_PERSONA) AND 
            (D1$4.CODIGO_DOCUMENTO = DOC1$4.CODIGO_DOCUMENTO) AND 
            (C1$4.EJECUTIVOCLIENTE = O1$4.CODOFICIAL) AND 
            (C1$4.SEGMENTOCLIENTE = S1$4.COD_SEGMENTO) AND 
            ((C1$4.TZ_LOCK < 300000000000000 OR C1$4.TZ_LOCK >= 400000000000000) 
				AND (C1$4.TZ_LOCK < 100000000000000 OR C1$4.TZ_LOCK >= 200000000000000)) AND 
            ((CP1$4.TZ_LOCK < 300000000000000 OR CP1$4.TZ_LOCK >= 400000000000000) 
				AND (CP1$4.TZ_LOCK < 100000000000000 OR CP1$4.TZ_LOCK >= 200000000000000)) AND 
            ((O1$4.TZ_LOCK < 300000000000000 OR O1$4.TZ_LOCK >= 400000000000000) 
				AND (O1$4.TZ_LOCK < 100000000000000 OR O1$4.TZ_LOCK >= 200000000000000)) AND 
            ((S1$4.TZ_LOCK < 300000000000000 OR S1$4.TZ_LOCK >= 400000000000000) 
				AND (S1$4.TZ_LOCK < 100000000000000 OR S1$4.TZ_LOCK >= 200000000000000)) AND 
            ((D1$4.TZ_LOCK < 300000000000000 OR D1$4.TZ_LOCK >= 400000000000000) 
				AND (D1$4.TZ_LOCK < 100000000000000 OR D1$4.TZ_LOCK >= 200000000000000)) AND 
            ((DOC1$4.TZ_LOCK < 300000000000000 OR DOC1$4.TZ_LOCK >= 400000000000000) 
				AND (DOC1$4.TZ_LOCK < 100000000000000 OR DOC1$4.TZ_LOCK >= 200000000000000)) AND 
            D1$4.CODIGO_DOCUMENTO NOT IN 
            (
               SELECT DT1$2.COD_DOCUMENTO
               FROM dbo.CRE_DOC_TIPO_DEUDOR  AS DT1$2
               WHERE (	(DT1$2.TZ_LOCK < 300000000000000 OR DT1$2.TZ_LOCK >= 400000000000000) 
					AND (DT1$2.TZ_LOCK < 100000000000000 OR DT1$2.TZ_LOCK >= 200000000000000)) 
				AND C1$4.TIPO_DEUDOR = DT1$2.TIPO_DEUDOR
            ) AND 
            CP1$4.NUMEROPERSONA NOT IN 
            (
               SELECT FIN$2.PERSONA_JURIDICA
               FROM dbo.CRE_INFO_FINANCIERA  AS FIN$2 WITH(NOLOCK)
               WHERE (	(FIN$2.TZ_LOCK < 300000000000000 OR FIN$2.TZ_LOCK >= 400000000000000) 
					AND (FIN$2.TZ_LOCK < 100000000000000 OR FIN$2.TZ_LOCK >= 200000000000000))
            )
      )  AS fci
 ; ')
 execute('
ALTER VIEW [dbo].[VAY_FORMULASBASICAS] (
									   CAMPOTOPAZ, 
									   DESCRIPCION, 
									   CAMPO, 
									   IDENTIFICACION, 
									   DESCRTABLA)
AS 
   SELECT 
      CAST(CAST(''C'' + ISNULL(CAST(D.NUMERODECAMPO AS nvarchar(max)), '''') AS varchar(max)) AS varchar(6)) AS CAMPOTOPAZ, 
      K.DESCRIPCION, 
      D.CAMPO, 
      ''     '' AS IDENTIFICACION, 
      '' '' AS DESCRTABLA
   FROM dbo.DICCIONARIO  AS D WITH(NOLOCK), 
		dbo.ME_OPERANDOS  AS K WITH(NOLOCK)
   WHERE D.NUMERODECAMPO = K.CODIGO 
		AND K.TZ_LOCK = 0
 ; ')
 execute(' 
 ALTER VIEW [dbo].[VW_CLI_PERSONAS_SUM_ING] (
										   NUMEROPERSONA, 
										   NOMBRE, 
										   TIPODOCUMENTO, 
										   NUMERODOCUMENTO)
AS 
   SELECT	fci.NUMEROPERSONA, 
			fci.NOMBRE, 
			fci.TIPODOCUMENTO, 
			fci.NUMERODOCUMENTO
   FROM 
      (
         SELECT PF.NUMEROPERSONAFISICA AS NUMEROPERSONA, 
				ISNULL(PF.PRIMERNOMBRE, '''') + '' '' + ISNULL(PF.APELLIDOPATERNO, '''') + '' '' + ISNULL(PF.APELLIDOMATERNO, '''') AS NOMBRE, DOC.TIPODOCUMENTO, 
				DOC.NUMERODOCUMENTO
         FROM	dbo.CLI_DOCUMENTOSPFPJ  AS DOC WITH(NOLOCK), 
				dbo.CLI_PERSONASFISICAS  AS PF WITH(NOLOCK)
         WHERE 
            (		(DOC.TZ_LOCK < 300000000000000 OR DOC.TZ_LOCK >= 400000000000000) 
				AND (DOC.TZ_LOCK < 100000000000000 OR DOC.TZ_LOCK >= 200000000000000)) AND 
            (		(PF.TZ_LOCK < 300000000000000 OR PF.TZ_LOCK >= 400000000000000) 
				AND (PF.TZ_LOCK < 100000000000000 OR PF.TZ_LOCK >= 200000000000000)) AND 
            PF.NUMEROPERSONAFISICA = DOC.NUMEROPERSONAFJ AND 
            DOC.REPORTAAORGANISMOCONTROL = ''S''
          UNION
         SELECT PJ.NUMEROPERSONAJURIDICA AS NUMEROPERSONA, 
				PJ.RAZONSOCIAL AS NOMBRE, 
				DOC$2.TIPODOCUMENTO, 
				DOC$2.NUMERODOCUMENTO
         FROM	dbo.CLI_DOCUMENTOSPFPJ  AS DOC$2 WITH(NOLOCK), 
				dbo.CLI_PERSONASJURIDICAS  AS PJ WITH(NOLOCK)
         WHERE 
            (		(DOC$2.TZ_LOCK < 300000000000000 OR DOC$2.TZ_LOCK >= 400000000000000) 
				AND (DOC$2.TZ_LOCK < 100000000000000 OR DOC$2.TZ_LOCK >= 200000000000000)) AND 
            ((PJ.TZ_LOCK < 300000000000000 OR PJ.TZ_LOCK >= 400000000000000) 
				AND (PJ.TZ_LOCK < 100000000000000 OR PJ.TZ_LOCK >= 200000000000000)) AND 
            PJ.NUMEROPERSONAJURIDICA = DOC$2.NUMEROPERSONAFJ AND 
            DOC$2.REPORTAAORGANISMOCONTROL = ''S''
      )  AS fci
; ')
 execute(' 
ALTER VIEW [dbo].[VW_CLIENTES_PAQUETES_VISTA] (
											   CLIENTEPR, 
											   PRODUCTOCL, 
											   MONEDAPR, 
											   GRUPO, 
											   PAQUETEPQ, 
											   ACTIVOPQ)
AS 
   SELECT TOP 9223372036854775807 WITH TIES 
      V.COD_CLIENTE AS CLIENTEPR, 
      P.PRODUCTO AS PRODUCTOCL, 
      P.MONEDA AS MONEDAPR, 
      P.GRUPO, 
      V.COD_PAQUETE AS PAQUETEPQ, 
      V.ACTIVO AS ACTIVOPQ
   FROM dbo.CLI_CLIENTES_PAQUETES  AS V WITH (NOLOCK), 
		dbo.CLI_PAQUETE_PRODUCTOS  AS P WITH (NOLOCK)
   WHERE 
      V.COD_PAQUETE = P.COD_PAQUETE AND 
      P.ACTIVO = 1 AND 
      V.ACTIVO = 1 AND 
      ((V.TZ_LOCK < 300000000000000 OR V.TZ_LOCK >= 400000000000000) 
		AND (V.TZ_LOCK < 100000000000000 OR V.TZ_LOCK >= 200000000000000)) AND 
      ((P.TZ_LOCK < 300000000000000 OR P.TZ_LOCK >= 400000000000000) 
		AND (P.TZ_LOCK < 100000000000000 OR P.TZ_LOCK >= 200000000000000))
   ORDER BY CLIENTEPR
 ; ')
  execute(' 
ALTER VIEW [dbo].[VW_CLIENTESDEUDA] (SALDO_ACTUAL, 
									COD_CLIENTE, 
									NRO_OPERACION)
AS 
   SELECT (	SALDOS.C1604 * -1) AS SALDO_ACTUAL, 
			SALDOS.C1803 AS COD_CLIENTE, 
			SALDOS.OPERACION AS NRO_OPERACION
   FROM dbo.SALDOS WITH(NOLOCK)
   WHERE SALDOS.C1604 < 0
 ; ')
  execute('
  ALTER VIEW [dbo].[VW_COBI] (
						   NROCOBRANZA, 
						   CUOTA, 
						   IMPCOBRANZA, 
						   MONCOBRANZA, 
						   VENCIMIENTO, 
						   CODIGOCLIENTE, 
						   NOMBRECLIENTE, 
						   PAGACLIENTE)
AS 
   SELECT 
      C.NROCOBRANZA, 
      C.CUOTA, 
      C.IMPCOBRANZA, 
      C.MONCOBRANZA, 
      C.VENCIMIENTO, 
      CL.CODIGOCLIENTE, 
      CL.NOMBRECLIENTE, 
      C.PAGACLIENTE
   FROM dbo.COBIMPORT  AS C WITH (NOLOCK), 
		dbo.CLI_CLIENTES  AS CL WITH (NOLOCK)
   WHERE 
      ((C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
		AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000)) AND 
      ((CL.TZ_LOCK < 300000000000000 OR CL.TZ_LOCK >= 400000000000000) 
		AND (CL.TZ_LOCK < 100000000000000 OR CL.TZ_LOCK >= 200000000000000)) AND 
      CL.CODIGOCLIENTE = (C.CTAGIRADO / 100) AND 
      C.SOLPROCESADA <> ''P''
 ; ')
  execute('
 ALTER VIEW [dbo].[VW_SOL_LIMITE] (
								   Cliente, 
								   Nombre, 
								   Solicitud, 
								   Estado, 
								   Descripcion, 
								   Tipo)
AS 
   SELECT TOP 9223372036854775807 WITH TIES 
      fci.CLIENTE, 
      fci.NOMBRECLIENTE, 
      fci.SOLICITUD, 
      fci.ESTADO, 
      fci.DESCRIPCION, 
      fci.TIPO
   FROM 
      (
         SELECT 
            SC.CLIENTE, 
            C.NOMBRECLIENTE, 
            SC.NROSOLICITUD AS SOLICITUD, 
            SC.ESTADO, 
            E.DESCRIPCION, 
            ''SC'' AS TIPO
         FROM	dbo.CRE_SOLLICCLIENTE  AS SC WITH (NOLOCK), 
				dbo.CLI_CLIENTES  AS C WITH (NOLOCK), 
				dbo.CRE_ESTADOS_LIMITES  AS E WITH (NOLOCK)
         WHERE SC.TZ_LOCK = 0 
				AND C.TZ_LOCK = 0 
				AND E.TZ_LOCK = 0 
				AND SC.CLIENTE = C.CODIGOCLIENTE 
				AND SC.ESTADO = E.COD_ESTADO
          UNION ALL
         SELECT 
            SI.INSTITUCION AS CLIENTE, 
            C$2.NOMBRECLIENTE, 
            SI.IDSOLICITUD AS SOLICITUD, 
            SI.ESTADO, 
            E$2.DESCRIPCION, 
            ''SF'' AS TIPO
         FROM	dbo.CRE_SOLLICINST  AS SI WITH (NOLOCK), 
				dbo.CLI_CLIENTES  AS C$2 WITH (NOLOCK), 
				dbo.CRE_ESTADOS_LIMITES  AS E$2 WITH (NOLOCK)
         WHERE SI.TZ_LOCK = 0 
				AND C$2.TZ_LOCK = 0 
				AND E$2.TZ_LOCK = 0 
				AND SI.INSTITUCION = C$2.CODIGOCLIENTE 
				AND SI.ESTADO = E$2.COD_ESTADO
      )  AS fci
   ORDER BY fci.SOLICITUD DESC
 ; ')
  execute(' 
  ALTER VIEW [dbo].[VW_CLI_PERSONAS] (
								   [Tipo de Documento],
								   [Numero de Documento],
								   [Numero de Persona],
								   [Tipo de Persona],
								   [Nombre de Persona],
								   [Titularidad],
								   [Codigo de Cliente],
								   [Nombre de Cliente],
								   [Estado],
								   [Nivel de Apertura])
 
AS 
   SELECT 
      V.TIPODOCUMENTO AS TIPODOC, 
      V.NUMERODOCUMENTO AS NUMERODOC, 
      V.NUMEROPERSONAFJ AS NUMEROPERSONA, 
      V.TIPOPERSONA, 
      ISNULL(U.PRIMERNOMBRE, '''') + '' '' + ISNULL(U.APELLIDOPATERNO, '''') + '' '' + ISNULL(U.APELLIDOMATERNO, '''') AS NOMBRE, 
      T.TITULARIDAD, 
      R.CODIGOCLIENTE, 
      R.NOMBRECLIENTE,
      CASE WHEN r.ESTADO=0 THEN ''HABILITADO'' ELSE ''INHABILITADO'' END AS ESTADO,
      CASE WHEN r.NIVEL_APERTURA=1 THEN ''BASICO'' ELSE 
      CASE WHEN R.NIVEL_APERTURA=3 THEN ''ACTIVO'' ELSE 
      CASE WHEN R.NIVEL_APERTURA=4 THEN ''INSTITUCION FINANCIERA'' END END END AS NIVEL_APERTURA
   FROM 
      dbo.CLI_CLIENTES  AS R WITH(NOLOCK), 
      dbo.CLI_CLIENTEPERSONA  AS T WITH(NOLOCK), 
      dbo.CLI_PERSONASFISICAS  AS U WITH(NOLOCK), 
      dbo.CLI_DOCUMENTOSPFPJ  AS V WITH(NOLOCK)
   WHERE 
      (R.CODIGOCLIENTE = T.CODIGOCLIENTE) AND 
      (U.NUMEROPERSONAFISICA = T.NUMEROPERSONA AND U.NUMEROPERSONAFISICA = V.NUMEROPERSONAFJ) AND 
      ((R.TZ_LOCK < 300000000000000 OR R.TZ_LOCK >= 400000000000000) AND (R.TZ_LOCK < 100000000000000 OR R.TZ_LOCK >= 200000000000000)) AND 
      ((T.TZ_LOCK < 300000000000000 OR T.TZ_LOCK >= 400000000000000) AND (T.TZ_LOCK < 100000000000000 OR T.TZ_LOCK >= 200000000000000)) AND 
      ((U.TZ_LOCK < 300000000000000 OR U.TZ_LOCK >= 400000000000000) AND (U.TZ_LOCK < 100000000000000 OR U.TZ_LOCK >= 200000000000000)) AND 
      ((V.TZ_LOCK < 300000000000000 OR V.TZ_LOCK >= 400000000000000) AND (V.TZ_LOCK < 100000000000000 OR V.TZ_LOCK >= 200000000000000))
    UNION ALL
   SELECT 
      V.TIPODOCUMENTO AS TIPODOC, 
      V.NUMERODOCUMENTO AS NUMERODOC, 
      V.NUMEROPERSONAFJ AS NUMEROPERSONA, 
      V.TIPOPERSONA, 
      S.RAZONSOCIAL AS NOMBRE, 
      T.TITULARIDAD, 
      R.CODIGOCLIENTE, 
      R.NOMBRECLIENTE,
      CASE WHEN r.ESTADO=0 THEN ''HABILITADO'' ELSE ''INHABILITADO'' END AS ESTADO,
      CASE WHEN r.NIVEL_APERTURA=1 THEN ''BASICO'' ELSE 
      CASE WHEN R.NIVEL_APERTURA=3 THEN ''ACTIVO'' ELSE 
      CASE WHEN R.NIVEL_APERTURA=4 THEN ''INSTITUCION FINANCIERA'' END END END AS NIVEL_APERTURA
   FROM 
      dbo.CLI_CLIENTES  AS R WITH(NOLOCK), 
      dbo.CLI_PERSONASJURIDICAS  AS S WITH(NOLOCK), 
      dbo.CLI_CLIENTEPERSONA  AS T WITH(NOLOCK), 
      dbo.CLI_DOCUMENTOSPFPJ  AS V WITH(NOLOCK)
   WHERE 
      (R.CODIGOCLIENTE = T.CODIGOCLIENTE) AND 
      (S.NUMEROPERSONAJURIDICA = T.NUMEROPERSONA AND S.NUMEROPERSONAJURIDICA = V.NUMEROPERSONAFJ) AND 
      ((R.TZ_LOCK < 300000000000000 OR R.TZ_LOCK >= 400000000000000) AND (R.TZ_LOCK < 100000000000000 OR R.TZ_LOCK >= 200000000000000)) AND 
      ((T.TZ_LOCK < 300000000000000 OR T.TZ_LOCK >= 400000000000000) AND (T.TZ_LOCK < 100000000000000 OR T.TZ_LOCK >= 200000000000000)) AND 
      ((S.TZ_LOCK < 300000000000000 OR S.TZ_LOCK >= 400000000000000) AND (S.TZ_LOCK < 100000000000000 OR S.TZ_LOCK >= 200000000000000)) AND 
      ((V.TZ_LOCK < 300000000000000 OR V.TZ_LOCK >= 400000000000000) AND (V.TZ_LOCK < 100000000000000 OR V.TZ_LOCK >= 200000000000000))
 ; ')
  execute(' 
  ALTER VIEW [dbo].[VW_CONTROL_CHEQ01] (
									   CLIENTE, 
									   CUENTA, 
									   ESTADO, 
									   CHEQUEDESDE, 
									   CHEQUEHASTA, 
									   CANTIDADCHEQUES, 
									   MONEDA, 
									   PRODUCTO, 
									   SERIE, 
									   NUMEROCHEQUERA, 
									   TIPOLIBRETA, 
									   SUCURSAL, 
									   OPERACION, 
									   CHEQUESUSADOS, 
									   NOMBRECLIENTE)
AS 
   SELECT 
      CHE_CHEQUERAS.CLIENTE, 
      CHE_CHEQUERAS.CUENTA, 
      CHE_CHEQUERAS.ESTADO, 
      CHE_CHEQUERAS.CHEQUEDESDE, 
      CHE_CHEQUERAS.CHEQUEHASTA, 
      CHE_CHEQUERAS.CANTIDADCHEQUES, 
      CHE_CHEQUERAS.MONEDA, 
      CHE_CHEQUERAS.PRODUCTO, 
      CHE_CHEQUERAS.SERIE, 
      CHE_CHEQUERAS.NUMEROCHEQUERA, 
      CHE_CHEQUERAS.TIPOLIBRETA, 
      CHE_CHEQUERAS.SUCURSAL, 
      CHE_CHEQUERAS.OPERACION, 
      CHE_CHEQUERAS.CHEQUESUSADOS, 
      CLI_CLIENTES.NOMBRECLIENTE
   FROM dbo.CHE_CHEQUERAS WITH(NOLOCK), 
		dbo.CLI_CLIENTES WITH(NOLOCK)
   WHERE CHE_CHEQUERAS.SUCURSAL IN ( 1, 7 ) 
		AND CHE_CHEQUERAS.CLIENTE = CLI_CLIENTES.CODIGOCLIENTE
 ; ')
  execute(' 
  ALTER VIEW [dbo].[VW_CONTROL_CHEQUES] (
									   TZ_LOCK, 
									   SUCURSAL, 
									   MONEDA, 
									   CUENTA, 
									   PRODUCTO, 
									   OPERACION, 
									   ORDINAL, 
									   NUMEROCHEQUE, 
									   IMPORTE, 
									   FECHAESTADO, 
									   ESTADO, 
									   JTS_ORIGEN, 
									   NUMEROCHEQREIMPRESO, 
									   MOTIVO, 
									   FECHAINGRESO, 
									   SERIE, 
									   JTS_ACTUAL, 
									   JTS_CHEQUE, 
									   MARCA_JTS, 
									   FECHA_VENCIMIENTO, 
									   ALAORDENDE, 
									   NRO_SOLICITUD, 
									   EST_MIGRACION)
AS 
   SELECT 
      C.TZ_LOCK, 
      C.SUCURSAL, 
      C.MONEDA, 
      C.CUENTA, 
      C.PRODUCTO, 
      C.OPERACION, 
      C.ORDINAL, 
      C.NUMEROCHEQUE, 
      C.IMPORTE, 
      C.FECHAESTADO, 
      C.ESTADO, 
      C.JTS_ORIGEN, 
      C.NUMEROCHEQREIMPRESO, 
      C.MOTIVO, 
      C.FECHAINGRESO, 
      C.SERIE, 
      C.JTS_ACTUAL, 
      C.JTS_CHEQUE, 
      C.MARCA_JTS, 
      C.FECHA_VENCIMIENTO, 
      C.ALAORDENDE, 
      C.NRO_SOLICITUD, 
      C.EST_MIGRACION
   FROM dbo.CHE_CHEQUES  AS C WITH(NOLOCK), 
		dbo.CHE_CHEQUERAS  AS L WITH(NOLOCK)
   WHERE 
      C.ESTADO NOT IN ( ''F'', ''G'' ) AND 
      C.SUCURSAL = L.SUCURSAL AND 
      C.CUENTA = L.CUENTA AND 
      C.MONEDA = L.MONEDA AND 
      C.OPERACION = L.OPERACION AND 
      C.ORDINAL = L.ORDINAL AND 
      C.PRODUCTO = L.PRODUCTO AND 
      C.SERIE = L.SERIE AND 
      C.NUMEROCHEQUE >= L.CHEQUEDESDE AND 
      C.NUMEROCHEQUE <= L.CHEQUEHASTA AND 
      L.TIPOLIBRETA NOT IN ( ''L'', ''P'' )
 ; ')
execute(' 
   ALTER VIEW [dbo].[VW_CONTROL_CLIENTES24] (	CODIGOCLIENTE, 
											CANTIDAD_PERSONAS)
AS 
   SELECT	CLI_CLIENTEPERSONA.CODIGOCLIENTE, 
			count_big(*) AS CANTIDAD_PERSONAS
   FROM dbo.CLI_CLIENTEPERSONA WITH(NOLOCK)
   GROUP BY CLI_CLIENTEPERSONA.CODIGOCLIENTE
 ; ')
   execute('
 ALTER VIEW [dbo].[VW_CONTROL_INV_CLIENTES] (
										   CODIGOCLIENTE, 
										   NOMBRECLIENTE, 
										   TIPOPERSONA, 
										   TIPODOCUMENTO, 
										   PAISDOCUMENTO, 
										   NUMERODOCUMENTO)
AS 
   SELECT 
      C.CODIGOCLIENTE, 
      C.NOMBRECLIENTE, 
      D.TIPOPERSONA, 
      D.TIPODOCUMENTO, 
      D.PAISDOCUMENTO, 
      D.NUMERODOCUMENTO
   FROM dbo.CLI_CLIENTES  AS C WITH(NOLOCK), 
		dbo.CLI_CLIENTEPERSONA  AS P WITH(NOLOCK), 
		dbo.CLI_DOCUMENTOSPFPJ  AS D WITH(NOLOCK)
   WHERE C.CODIGOCLIENTE = P.CODIGOCLIENTE 
		AND P.NUMEROPERSONA = D.NUMEROPERSONAFJ  
 ; ')
   execute(' 
ALTER VIEW [dbo].[VW_CONTROL_LETRAS] (
								   TZ_LOCK, 
								   SUCURSAL, 
								   MONEDA, 
								   CUENTA, 
								   PRODUCTO, 
								   OPERACION, 
								   ORDINAL, 
								   NUMEROCHEQUE, 
								   IMPORTE, 
								   FECHAESTADO, 
								   ESTADO, 
								   JTS_ORIGEN, 
								   NUMEROCHEQREIMPRESO, 
								   MOTIVO, 
								   FECHAINGRESO, 
								   SERIE, 
								   JTS_ACTUAL, 
								   JTS_CHEQUE, 
								   MARCA_JTS, 
								   FECHA_VENCIMIENTO, 
								   ALAORDENDE, 
								   NRO_SOLICITUD, 
								   EST_MIGRACION)
AS 
   SELECT 
      C.TZ_LOCK, 
      C.SUCURSAL, 
      C.MONEDA, 
      C.CUENTA, 
      C.PRODUCTO, 
      C.OPERACION, 
      C.ORDINAL, 
      C.NUMEROCHEQUE, 
      C.IMPORTE, 
      C.FECHAESTADO, 
      C.ESTADO, 
      C.JTS_ORIGEN, 
      C.NUMEROCHEQREIMPRESO, 
      C.MOTIVO, 
      C.FECHAINGRESO, 
      C.SERIE, 
      C.JTS_ACTUAL, 
      C.JTS_CHEQUE, 
      C.MARCA_JTS, 
      C.FECHA_VENCIMIENTO, 
      C.ALAORDENDE, 
      C.NRO_SOLICITUD, 
      C.EST_MIGRACION
   FROM dbo.CHE_CHEQUES  AS C WITH(NOLOCK), 
		dbo.CHE_CHEQUERAS  AS L WITH(NOLOCK)
   WHERE 
      C.ESTADO NOT IN ( ''F'', ''G'' ) AND 
      C.SUCURSAL = L.SUCURSAL AND 
      C.CUENTA = L.CUENTA AND 
      C.MONEDA = L.MONEDA AND 
      C.OPERACION = L.OPERACION AND 
      C.ORDINAL = L.ORDINAL AND 
      C.PRODUCTO = L.PRODUCTO AND 
      C.SERIE = L.SERIE AND 
      C.NUMEROCHEQUE >= L.CHEQUEDESDE AND 
      C.NUMEROCHEQUE <= L.CHEQUEHASTA AND 
      L.TIPOLIBRETA IN ( ''L'', ''P'' )
 ; ')
execute(' 
ALTER VIEW [dbo].[VW_CONTROL_PLAST_CTAS_IMPORTES] (
												   CUENTA_PLASTICO, 
												   MARCA, 
												   MONEDA, 
												   IMPORTE)
AS 
   SELECT	CRE_TARJETA_CREDITO.CUENTA_PLASTICO, 
			CRE_TARJETA_CREDITO.MARCA, 
			CRE_TARJETA_CREDITO.MONEDA, 
			sum(CRE_TARJETA_CREDITO.IMPORTE) AS IMPORTE
   FROM dbo.CRE_TARJETA_CREDITO WITH(NOLOCK)
   GROUP BY 
      CRE_TARJETA_CREDITO.CUENTA_PLASTICO, 
      CRE_TARJETA_CREDITO.MARCA, 
      CRE_TARJETA_CREDITO.MONEDA, 
      CRE_TARJETA_CREDITO.IMPORTE
 ; ')
   execute('
ALTER VIEW [dbo].[VW_CONTROL_PLASTICOS_CUENTAS] (
												   CUENTA_PLASTICO, 
												   MARCA, 
												   PROGRAMA, 
												   CICLO, 
												   COBERTURA, 
												   ESTADO_CUENTA, 
												   VENCIMIENTO, 
												   CATEGORIA_CLIENTE, 
												   CUENTA_DEBITAR_PESOS, 
												   CUENTA_DEBITAR_DOLARES, 
												   NRO_TARJ_CREDITO)
AS 
   SELECT 
      CRE_TARJETA_CREDITO.CUENTA_PLASTICO, 
      max(CRE_TARJETA_CREDITO.MARCA) AS MARCA, 
      max(CRE_TARJETA_CREDITO.PROGRAMA) AS PROGRAMA, 
      max(CRE_TARJETA_CREDITO.CICLO) AS CICLO, 
      max(CRE_TARJETA_CREDITO.COBERTURA) AS COBERTURA, 
      max(CRE_TARJETA_CREDITO.ESTADO_CUENTA) AS ESTADO_CUENTA, 
      max(CRE_TARJETA_CREDITO.VENCIMIENTO) AS VENCIMIENTO, 
      max(CRE_TARJETA_CREDITO.CATEGORIA_CLIENTE) AS CATEGORIA_CLIENTE, 
      max(CRE_TARJETA_CREDITO.CUENTA_DEBITAR_PESOS) AS CUENTA_DEBITAR_PESOS, 
      max(CRE_TARJETA_CREDITO.CUENTA_DEBITAR_DOLARES) AS CUENTA_DEBITAR_DOLARES, 
      max(CRE_TARJETA_CREDITO.NRO_TARJ_CREDITO) AS NRO_TARJ_CREDITO
   FROM dbo.CRE_TARJETA_CREDITO WITH(NOLOCK)
   GROUP BY CRE_TARJETA_CREDITO.CUENTA_PLASTICO
 ; ')
   execute('
ALTER VIEW [dbo].[VW_CONTROl24] (CODIGOCLIENTE, 
								CANTIDAD_PERSONAS)
AS 
   SELECT CLI_CLIENTEPERSONA.CODIGOCLIENTE, 
		count_big(*) AS CANTIDAD_PERSONAS
   FROM dbo.CLI_CLIENTEPERSONA WITH(NOLOCK)
   GROUP BY CLI_CLIENTEPERSONA.CODIGOCLIENTE
 ; ')
    execute('
ALTER VIEW [dbo].[VW_CONTROLES_DOCS] (
									   NUMERO_LOTE, 
									   CLIENTE, 
									   LIBRADOR, 
									   IMPORTE, 
									   IDENTIFICACION, 
									   RESULTADO)
AS 
SELECT 
    C.NUMERO_LOTE, 
    C.CLIENTE, 
    C.LIBRADOR, 
    C.IMPORTE, 
    CAST(C.NUMERO_DOC_REAL AS NVARCHAR(MAX)) AS IDENTIFICACION, 
    C.ACEPTADO_RECHAZADO AS RESULTADO
FROM dbo.CRE_RESULTADOS_CONCENTRACION  AS C WITH(NOLOCK)
WHERE C.TIPO IN ( 1, 3 )
UNION
SELECT 
    D.NUMERO_LOTE, 
    D.CLIENTE, 
    D.LIBRADOR, 
    D.IMPORTE, 
    CAST(
        ''BANCO ''
        + 
        ISNULL(CAST(D.BANCO_GIRADO AS nvarchar(max)), '''')
        + 
        '' SERIE ''
        + 
        ISNULL(D.SERIE_DEL_CHEQUE, '''')
        + 
        '' NUMERO CHEQUE ''
        + 
        ISNULL(CAST(D.NUMERO_CHEQUE AS nvarchar(max)), '''') AS NVARCHAR(MAX)) AS IDENTIFICACION, 
    D.ACEPTADO_RECHAZADO AS RESULTADO
FROM dbo.CRE_RESULTADOS_CONCENTRACION  AS D WITH(NOLOCK)
WHERE D.TIPO = 2
 ; ')
    execute('
ALTER VIEW [dbo].[VW_CONVENIO_GESTION] (ID_CONVENIO, 
										NOMBRE, 
										GESTION)
AS 
SELECT TOP 9223372036854775807 WITH TIES C.ID_CONVENIO, C.NOMBRE_CONVENIO, G.GESTION
FROM	dbo.RCT_CONVENIO_RECAUD  AS C WITH (NOLOCK), 
		dbo.RCT_CONTROL_GESTION  AS G WITH (NOLOCK)
WHERE 
    C.ID_CONVENIO = G.ID_CONVENIO AND 
    G.ESTADO = ''A'' AND 
    (		(C.TZ_LOCK < 3000000000000000 OR C.TZ_LOCK >= 4000000000000000) 
		AND (C.TZ_LOCK < 1000000000000000 OR C.TZ_LOCK >= 2000000000000000))
GROUP BY 
    C.ID_CONVENIO, 
    C.NOMBRE_CONVENIO, 
    G.GESTION
ORDER BY 2, 3
 ; ')
execute('
ALTER VIEW [dbo].[VW_CONVENIO_SALDO_CONCEPTOS] (
											   CONVENIO, 
											   NOMBRE, 
											   GESTION, 
											   COD_MONEDA, 
											   MONEDA, 
											   COD_CONCEPTO, 
											   CONCEPTO, 
											   TIPO)
AS 
SELECT TOP 9223372036854775807 WITH TIES 
    S.ID_CONVENIO AS CONVENIO, 
    R.NOMBRE_CONVENIO AS NOMBRE, 
    NULL AS GESTION, 
    S.MONEDA AS COD_MONEDA, 
    M.C6400 AS MONEDA, 
    S.CONCEPTO AS COD_CONCEPTO, 
    C.DESCRIPCION AS CONCEPTO, 
    S.TIPO_CONVENIO AS TIPO
FROM 
    dbo.RCT_CONVENIO_SALDOS  AS S WITH(NOLOCK), 
    dbo.RCT_CONVENIO_RECAUD  AS R WITH(NOLOCK), 
    dbo.RCT_CONCEPTOS  AS C WITH(NOLOCK), 
    dbo.MONEDAS  AS M WITH(NOLOCK)
WHERE 
    S.ID_CONVENIO = R.ID_CONVENIO AND 
    R.ID_CONVENIO = C.ID_CONVENIO AND 
    S.CONCEPTO = C.CONCEPTO AND 
    M.C6399 = S.MONEDA/*ORDER BY 2*/ AND 
    (		(S.TZ_LOCK < 3000000000000000 OR S.TZ_LOCK >= 4000000000000000) 
		AND (S.TZ_LOCK < 1000000000000000 OR S.TZ_LOCK >= 2000000000000000)) AND 
    (		(R.TZ_LOCK < 3000000000000000 OR R.TZ_LOCK >= 4000000000000000) 
		AND (R.TZ_LOCK < 1000000000000000 OR R.TZ_LOCK >= 2000000000000000)) AND 
    (		(C.TZ_LOCK < 3000000000000000 OR C.TZ_LOCK >= 4000000000000000) 
		AND (C.TZ_LOCK < 1000000000000000 OR C.TZ_LOCK >= 2000000000000000))
ORDER BY 1
 ; ')
    execute('
ALTER VIEW [dbo].[VW_CONYUGE_DE_PERSONA] (	NUMEROPERSONAFISICA, 
											NUMEROCONYUGE)
AS 
   SELECT P.NUMEROPERSONAFISICA, Q.NUMEROPERSONAFISICA AS NUMEROCONYUGE
   FROM dbo.CLI_PERSONASFISICAS  AS P, dbo.CLI_PERSONASFISICAS  AS Q, dbo.CLI_PFCONYUGE  AS R
   WHERE 
      (		(P.NUMEROPERSONAFISICA = R.NUMEROPERSONAFISICA AND R.NUMEROPERSONAFISICACONY = Q.NUMEROPERSONAFISICA) 
		OR	(P.NUMEROPERSONAFISICA = R.NUMEROPERSONAFISICACONY AND R.NUMEROPERSONAFISICA = Q.NUMEROPERSONAFISICA)) AND 
      (		(P.TZ_LOCK < 300000000000000 OR P.TZ_LOCK >= 400000000000000) 
		AND (P.TZ_LOCK < 100000000000000 OR P.TZ_LOCK >= 200000000000000)) AND 
      (		(Q.TZ_LOCK < 300000000000000 OR Q.TZ_LOCK >= 400000000000000) 
		AND (Q.TZ_LOCK < 100000000000000 OR Q.TZ_LOCK >= 200000000000000)) AND 
      (		(R.TZ_LOCK < 300000000000000 OR R.TZ_LOCK >= 400000000000000) 
		AND (R.TZ_LOCK < 100000000000000 OR R.TZ_LOCK >= 200000000000000))
 ; ')
    execute('
ALTER VIEW [dbo].[VW_CONYUGE_PERSONA] (
									   PERSONA, 
									   CONYUGE, 
									   TIPODOCUMENTO, 
									   PAISDOCUMENTO, 
									   NUMERODOCUMENTO, 
									   APELLIDOPATERNO_CONYUGE, 
									   APELLIDOMATERNO_CONYUGE, 
									   PRIMERNOMBRE_CONYUGE, 
									   SEGUNDONOMBRE_CONYUGE)
AS 
   SELECT DISTINCT 
      PFC.NUMEROPERSONAFISICACONY AS PERSONA, 
      PFC.NUMEROPERSONAFISICA AS CONYUGE, 
      DP.TIPODOCUMENTO, 
      DP.PAISDOCUMENTO, 
      DP.NUMERODOCUMENTO, 
      PF.APELLIDOPATERNO AS APELLIDOPATERNO_CONYUGE, 
      PF.APELLIDOMATERNO AS APELLIDOMATERNO_CONYUGE, 
      PF.PRIMERNOMBRE AS PRIMERNOMBRE_CONYUGE, 
      PF.SEGUNDONOMBRE AS SEGUNDONOMBRE_CONYUGE
   FROM dbo.CLI_PFCONYUGE  AS PFC WITH(NOLOCK), 
		dbo.CLI_PERSONASFISICAS  AS PF WITH(NOLOCK), 
		dbo.CLI_DOCUMENTOSPFPJ  AS DP WITH(NOLOCK)
   WHERE 
      (		(PFC.TZ_LOCK < 300000000000000 OR PFC.TZ_LOCK >= 400000000000000) 
		AND (PFC.TZ_LOCK < 100000000000000 OR PFC.TZ_LOCK >= 200000000000000)) AND 
      (		(PF.TZ_LOCK < 300000000000000 OR PF.TZ_LOCK >= 400000000000000) 
		AND (PF.TZ_LOCK < 100000000000000 OR PF.TZ_LOCK >= 200000000000000)) AND 
      (		(DP.TZ_LOCK < 300000000000000 OR DP.TZ_LOCK >= 400000000000000) 
		AND (DP.TZ_LOCK < 100000000000000 OR DP.TZ_LOCK >= 200000000000000)) AND 
      PFC.NUMEROPERSONAFISICA = PF.NUMEROPERSONAFISICA AND 
      PFC.NUMEROPERSONAFISICA = DP.NUMEROPERSONAFJ
    UNION
   SELECT DISTINCT 
      PFC.NUMEROPERSONAFISICA AS PERSONA, 
      PFC.NUMEROPERSONAFISICACONY AS CONYUGE, 
      DP.TIPODOCUMENTO, 
      DP.PAISDOCUMENTO, 
      DP.NUMERODOCUMENTO, 
      PF.APELLIDOPATERNO AS APELLIDOPATERNO_CONYUGE, 
      PF.APELLIDOMATERNO AS APELLIDOMATERNO_CONYUGE, 
      PF.PRIMERNOMBRE AS PRIMERNOMBRE_CONYUGE, 
      PF.SEGUNDONOMBRE AS SEGUNDONOMBRE_CONYUGE
   FROM dbo.CLI_PFCONYUGE  AS PFC WITH(NOLOCK), 
		dbo.CLI_PERSONASFISICAS  AS PF WITH(NOLOCK), 
		dbo.CLI_DOCUMENTOSPFPJ  AS DP WITH(NOLOCK)
   WHERE 
      (		(PFC.TZ_LOCK < 300000000000000 OR PFC.TZ_LOCK >= 400000000000000) 
		AND	(PFC.TZ_LOCK < 100000000000000 OR PFC.TZ_LOCK >= 200000000000000)) AND 
      (		(PF.TZ_LOCK < 300000000000000 OR PF.TZ_LOCK >= 400000000000000) 
		AND (PF.TZ_LOCK < 100000000000000 OR PF.TZ_LOCK >= 200000000000000)) AND 
      (		(DP.TZ_LOCK < 300000000000000 OR DP.TZ_LOCK >= 400000000000000) 
		AND (DP.TZ_LOCK < 100000000000000 OR DP.TZ_LOCK >= 200000000000000)) AND 
      PFC.NUMEROPERSONAFISICACONY = PF.NUMEROPERSONAFISICA AND 
      PFC.NUMEROPERSONAFISICACONY = DP.NUMEROPERSONAFJ
 ; ')
execute('
ALTER VIEW [dbo].[VW_CONYUGECLIENTES] (
								   CODIGOCLIENTE, 
								   NUMEROPERSONA, 
								   TITULARIDAD, 
								   NUMEROPERSONAFISICACONY)
AS 
SELECT	CL.CODIGOCLIENTE, 
		CL.NUMEROPERSONA, 
		CL.TITULARIDAD, 
		Y.NUMEROPERSONAFISICACONY AS NUMEROPERSONAFISICACONY
FROM dbo.CLI_CLIENTEPERSONA  AS CL WITH (NOLOCK), 
	 dbo.CLI_PFCONYUGE  AS Y WITH (NOLOCK)
WHERE 
    Y.NUMEROPERSONAFISICA = CL.NUMEROPERSONA AND 
    CL.TZ_LOCK = 0 AND 
    Y.TZ_LOCK = 0
UNION
SELECT	CL.CODIGOCLIENTE, 
		CL.NUMEROPERSONA, 
		CL.TITULARIDAD, 
		Y.NUMEROPERSONAFISICA AS NUMEROPERSONAFISICACONY
FROM dbo.CLI_CLIENTEPERSONA  AS CL WITH (NOLOCK), 
	 dbo.CLI_PFCONYUGE  AS Y WITH (NOLOCK)
WHERE 
    Y.NUMEROPERSONAFISICACONY = CL.NUMEROPERSONA AND 
    CL.TZ_LOCK = 0 AND 
    Y.TZ_LOCK = 0
  ; ')
execute('
ALTER VIEW [dbo].[VW_COTIZVALCODNBC] (
									CODIGOTITULO, 
									CODINTERNACIONAL, 
									CODIGOBANCO, 
									PRECIO, 
									CALIFICACIONOFICIAL, 
									VTO_EMISION)
AS 
SELECT TOP 9223372036854775807 WITH TIES 
		C.CODIGOTITULO, 
		T.CODINTERNACIONAL, 
		T.CODIGOBCO AS CODIGOBANCO, 
		C.PRECIO, 
		C.CALIFICACIONOFICIAL, 
		C.VTO_EMISION
FROM	dbo.VAL_TITULOS  AS T WITH(NOLOCK), 
		dbo.VAL_COTIZACIONVALORES  AS C WITH(NOLOCK)
WHERE 
    T.CODTITULO = C.CODIGOTITULO AND 
    (		(T.TZ_LOCK < 300000000000000 OR T.TZ_LOCK >= 400000000000000) 
		AND (T.TZ_LOCK < 100000000000000 OR T.TZ_LOCK >= 200000000000000)) AND 
    (		(C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
		AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000))
ORDER BY C.CODIGOTITULO
 ; ')
 execute('
ALTER VIEW [dbo].[VW_CR_CTR_RIESGOS_CAT] (
									   SUCURSAL, 
									   CUENTA, 
									   CALIFICACION, 
									   TITULAR, 
									   MONEDA, 
									   SECTOR_ACTIVIDAD, 
									   IMPORTE_TOTAL, 
									   CAT)
AS 
SELECT 
    CTR_RIESGOS.SUCURSAL, 
    CTR_RIESGOS.CUENTA, 
    CTR_RIESGOS.CALIFICACION, 
    CTR_RIESGOS.TITULAR, 
    CTR_RIESGOS.MONEDA, 
    CTR_RIESGOS.SECTOR_ACTIVIDAD, 
    CTR_RIESGOS.IMPORTE_TOTAL, 
    CTR_RIESGOS.CAT
FROM dbo.CTR_RIESGOS WITH(NOLOCK)
UNION ALL
SELECT 
    CTR_RIESGOS_CAT.SUCURSAL, 
    CTR_RIESGOS_CAT.CUENTA, 
    CTR_RIESGOS_CAT.CALIFICACION, 
    CTR_RIESGOS_CAT.TITULAR, 
    CTR_RIESGOS_CAT.MONEDA, 
    CTR_RIESGOS_CAT.SECTOR_ACTIVIDAD, 
    CTR_RIESGOS_CAT.IMPORTE_TOTAL, 
    1 AS CAT
FROM dbo.CTR_RIESGOS_CAT WITH(NOLOCK)
WHERE CTR_RIESGOS_CAT.TZ_LOCK = 0
 ; ')
 execute('
ALTER VIEW [dbo].[VW_CRE_CAMPANIA_PRESTAMO] (SOLICITUD, 
											CLIENTE, 
											NOMBRECLI)
AS 
SELECT	SOL.SOLICITUD AS SOLICITUD, 
		CLI.CODIGOCLIENTE AS CLIENTE, 
		CLI.NOMBRECLIENTE AS NOMBRECLI
FROM dbo.CLI_CLIENTES  AS CLI WITH(NOLOCK), 
	dbo.CRE_CAMPANIA_PRESTAMO  AS SOL WITH(NOLOCK)
WHERE 
    (		(SOL.TZ_LOCK < 300000000000000 OR SOL.TZ_LOCK >= 400000000000000) 
	AND (SOL.TZ_LOCK < 100000000000000 OR SOL.TZ_LOCK >= 200000000000000)) AND 
    (		(CLI.TZ_LOCK < 300000000000000 OR CLI.TZ_LOCK >= 400000000000000) 
	AND (CLI.TZ_LOCK < 100000000000000 OR CLI.TZ_LOCK >= 200000000000000)) AND 
    CLI.CODIGOCLIENTE = SOL.CLIENTE
 ; ')
 execute('
 ALTER VIEW [dbo].[VW_CLIENTES_PERSONAS] (
									   TIPODOC, 
									   NUMERODOC, 
									   NUMEROPERSONA, 
									   TIPOPERSONA, 
									   NOMBRE, 
									   APE_NOMBRE,
									   TITULARIDAD, 
									   CODIGOCLIENTE, 
									   NOMBRECLIENTE)
AS 
SELECT 
    V.TIPODOCUMENTO AS TIPODOC, 
    V.NUMERODOCUMENTO AS NUMERODOC, 
    V.NUMEROPERSONAFJ AS NUMEROPERSONA, 
    V.TIPOPERSONA, 
    ISNULL(U.PRIMERNOMBRE, '''') + '' '' + ISNULL(U.APELLIDOPATERNO, '''')  AS NOMBRE, 
    ISNULL(U.APELLIDOPATERNO, '''') + '' '' + ISNULL(U.PRIMERNOMBRE, '''') AS APE_NOMBRE,
    T.TITULARIDAD, 
    R.CODIGOCLIENTE, 
    R.NOMBRECLIENTE
FROM 
    dbo.CLI_CLIENTES  AS R WITH(NOLOCK), 
    dbo.CLI_CLIENTEPERSONA  AS T WITH(NOLOCK), 
    dbo.CLI_PERSONASFISICAS  AS U WITH(NOLOCK), 
    dbo.CLI_DOCUMENTOSPFPJ  AS V WITH(NOLOCK)
WHERE 
    (R.CODIGOCLIENTE = T.CODIGOCLIENTE) AND 
    (U.NUMEROPERSONAFISICA = T.NUMEROPERSONA AND U.NUMEROPERSONAFISICA = V.NUMEROPERSONAFJ) AND 
    (	(R.TZ_LOCK < 300000000000000 OR R.TZ_LOCK >= 400000000000000) 
	AND (R.TZ_LOCK < 100000000000000 OR R.TZ_LOCK >= 200000000000000)) AND 
    (	(T.TZ_LOCK < 300000000000000 OR T.TZ_LOCK >= 400000000000000) 
	AND (T.TZ_LOCK < 100000000000000 OR T.TZ_LOCK >= 200000000000000)) AND 
    (	(U.TZ_LOCK < 300000000000000 OR U.TZ_LOCK >= 400000000000000) 
	AND (U.TZ_LOCK < 100000000000000 OR U.TZ_LOCK >= 200000000000000)) AND 
    (	(V.TZ_LOCK < 300000000000000 OR V.TZ_LOCK >= 400000000000000) 
	AND (V.TZ_LOCK < 100000000000000 OR V.TZ_LOCK >= 200000000000000))
UNION ALL
SELECT 
    V.TIPODOCUMENTO AS TIPODOC, 
    V.NUMERODOCUMENTO AS NUMERODOC, 
    V.NUMEROPERSONAFJ AS NUMEROPERSONA, 
    V.TIPOPERSONA, 
    S.RAZONSOCIAL AS NOMBRE, 
    S.RAZONSOCIAL AS APE_NOMBRE,
    T.TITULARIDAD, 
    R.CODIGOCLIENTE, 
    R.NOMBRECLIENTE
FROM 
    dbo.CLI_CLIENTES  AS R WITH(NOLOCK), 
    dbo.CLI_PERSONASJURIDICAS  AS S WITH(NOLOCK), 
    dbo.CLI_CLIENTEPERSONA  AS T WITH(NOLOCK), 
    dbo.CLI_DOCUMENTOSPFPJ  AS V WITH(NOLOCK)
WHERE 
    (R.CODIGOCLIENTE = T.CODIGOCLIENTE) AND 
    (S.NUMEROPERSONAJURIDICA = T.NUMEROPERSONA AND S.NUMEROPERSONAJURIDICA = V.NUMEROPERSONAFJ) AND 
    (	(R.TZ_LOCK < 300000000000000 OR R.TZ_LOCK >= 400000000000000) 
	AND (R.TZ_LOCK < 100000000000000 OR R.TZ_LOCK >= 200000000000000)) AND 
    (	(T.TZ_LOCK < 300000000000000 OR T.TZ_LOCK >= 400000000000000) 
	AND (T.TZ_LOCK < 100000000000000 OR T.TZ_LOCK >= 200000000000000)) AND 
    (	(S.TZ_LOCK < 300000000000000 OR S.TZ_LOCK >= 400000000000000) 
	AND (S.TZ_LOCK < 100000000000000 OR S.TZ_LOCK >= 200000000000000)) AND 
    (	(V.TZ_LOCK < 300000000000000 OR V.TZ_LOCK >= 400000000000000) 
	AND (V.TZ_LOCK < 100000000000000 OR V.TZ_LOCK >= 200000000000000))
 ; ')
 execute('
 ; ')

