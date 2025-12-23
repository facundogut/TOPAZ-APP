EXECUTE(' IF OBJECT_ID (''VW_ITF_INSSSEP'') IS NOT NULL
	DROP VIEW VW_ITF_INSSSEP')
EXECUTE(' 

CREATE VIEW VW_ITF_INSSSEP AS
SELECT 
	dbo.NCADENAS(''16'',2,''0'',''P'') AS juridiccion      /* 2 */,
	
	(CASE
		WHEN cd.TIPO_DOC_FISICO = ''LE'' THEN  dbo.NCADENAS(''1'',1,''0'',''P'')
		WHEN cd.TIPO_DOC_FISICO = ''LC'' THEN  dbo.NCADENAS(''2'',1,''0'',''P'')
		WHEN cd.TIPO_DOC_FISICO = ''DNI'' THEN dbo.NCADENAS(''3'',1,''0'',''P'')
		ELSE dbo.NCADENAS(''X'',1,''0'',''P'')
	END) AS tpo_doc_fisico    /* 1 */,
	 
	dbo.NCADENAS(cd.NUM_DOC_FISICO,8,''0'',''P'') AS nro_doc_fisico  /* 8 */,
	
	dbo.NCADENAS(''052'',3,''0'',''P'') AS asociacion      /* 1 */, 
	
	dbo.NCADENAS(p.c2300,3,''0'',''P'') AS nro_cuota        /* 3 */,  
	 
	dbo.NCADENAS(FLOOR((dbo.ITF_INSSSEP_IMPORTE(s.JTS_OID,p.C2300))*100),10,''0'',''P'') AS importe         /* 10 */,
	
	convert(CHAR(8),p.C2302,112) AS fch_prim_vto     /* 8 */,
	
	dbo.NCADENAS(''3'',1,''0'',''P'') AS tpo_concepto      /* 1 siempre fijo "3" */,
	
	dbo.NCADENAS(''1'',4,''0'',''P'') AS tpo_producto      /* 4 siempre fijo "1" */,
	
	concat(dbo.NCADENAS(s.OPERACION,9,''0'',''P''), dbo.NCADENAS(s.ORDINAL,6,''0'',''P''),
	dbo.NCADENAS(''00'',2,''0'',''P''),dbo.NCADENAS(s.PRODUCTO,8,''0'',''P'') )  AS datos_prod     /* 25 se forma de: nroPrestamo(15) + nroDesglose(2) + Producto(8) */,
	
	convert(CHAR(8),s.C1620,112) AS fch_alta_oper    /* 8 AAAAMMDD */,
	
	(CASE
		WHEN bs.FECHAHORAINGRESO IS null THEN ''080000''  
		ELSE concat(substring(convert(varchar,bs.FECHAHORAINGRESO,108),1,2), substring(convert(varchar,bs.FECHAHORAINGRESO,108),4,2),
			 substring(convert(varchar,bs.FECHAHORAINGRESO,108),7,2))
	END) AS hora_alta_oper /* 6 HHMMSS */,
	
	s.C1620 AS fch_valor /* dejo este campo por si se filtra por fecha valor en un futuro */,
	
	s.JTS_OID  /* dejo el id de la operación por si lo precisamos mas adelante */
FROM 
	SALDOS s 
	LEFT JOIN 	GASTOS_POR_CUOTA g ON s.JTS_OID = g.SALDOS_JTS_OID
	INNER JOIN PLANPAGOS p ON s.JTS_OID = p.SALDO_JTS_OID
	INNER JOIN CLI_ClientePersona cp ON s.C1803 = cp.CODIGOCLIENTE
	INNER JOIN CLI_DocumentosPFPJ cd ON cp.NUMEROPERSONA = cd.NUMEROPERSONAFJ
	LEFT JOIN BS_HISTORIA_PLAZO bs ON s.JTS_OID = bs.JTS_OID and bs.TIPOMOV=''A''
WHERE 
	s.C1785=5 AND cp.TITULARIDAD=''T'' AND cp.TZ_LOCK=0 AND cd.TZ_LOCK=0 
	AND s.TZ_LOCK=0;



')