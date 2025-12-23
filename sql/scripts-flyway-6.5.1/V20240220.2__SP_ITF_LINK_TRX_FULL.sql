EXECUTE('
CREATE OR ALTER     PROCEDURE SP_ITF_LINK_TRX_FULL
    @Error VARCHAR(250) OUTPUT, 
    @ErrorMaestroCuenta VARCHAR(250) OUTPUT
AS
DECLARE @accion VARCHAR(1)

BEGIN
  
  
    SET @Error = '' '';

  BEGIN TRY
      
      DELETE FROM TJD_ITF_TARJETA_RAIZ;
      DELETE FROM TJD_ITF_PERSONAS;
      DELETE FROM TJD_ITF_TARJETAS_COMPLETAS;
      DELETE FROM TJD_ITF_PERSONAS_CONTACTO;
      truncate table TJD_TARJETAS;
    
      --Seccion 2
      INSERT INTO TJD_ITF_TARJETA_RAIZ (NumRaiz, Prefijo, NumCliente, Sucursal, Producto, EstadoRaiz, TipoCuentaPrincipal, 
          NumCuentaPrincipal, TipoDocApoderado, NumDocApoderado, Apellido,Nombre, CodEnte, CantMiembros, DomicilioPin, DomicilioPlastico, 
          CalleParticular, NumParticular, PisoParticular, DeptoParticular,LocalidadParticular, CodPostalParticular, CodProvinciaParticular,
          TelParticular, CalleLaboral, NumLaboral, PisoLaboral, DeptoLaboral,LocalidadLaboral, CodPostalLaboral, CodProvinciaLaboral, 
          TelLaboral, GrupoOperadorModif, TimestampModif, GrupoOperadorAlta, TimestampAlta, GrupoOperadorConfir, TimestampConfir)
      SELECT Max(substring(Linea,132,19)),substring(Linea,151,11),CAST(substring(Linea,162,12) AS NUMERIC(12)),substring(Linea,174,4) ,
          substring(Linea,178,4) ,substring(Linea,182,1) , substring(Linea,183,2),CAST(substring(Linea,185,19) AS NUMERIC(19)),
          substring(Linea,204,3) ,substring(Linea,207,9) ,substring(Linea,216,15),substring(Linea,231,15),substring(Linea,246,6) ,
          substring(Linea,252,2),substring(Linea,254,1),substring(Linea,255,1) ,substring(Linea,256,45),substring(Linea,301,5) ,
          substring(Linea,306,2),substring(Linea,308,3),substring(Linea,311,20),substring(Linea,331,15),substring(Linea,346,2) ,
          substring(Linea,348,15),substring(Linea,363,45),substring(Linea,408,5),substring(Linea,413,2),substring(Linea,415,3),
          substring(Linea,418,20),substring(Linea,438,15),substring(Linea,453,2),substring(Linea,455,15),substring(Linea,66,6),
          substring(Linea,72,16),substring(Linea,88,6),substring(Linea,94,16),substring(Linea,110,6),substring(Linea,116,16)
      FROM ITF_LINK_TRK  WHERE SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      AND SUBSTRING(Linea, 132, 19) <> ''0000000000000000000'' AND SUBSTRING(Linea, 132, 19) <> ''                   ''
      GROUP BY substring(Linea,132,19),substring(Linea,151,11),CAST(substring(Linea,162,12) AS NUMERIC(12)),substring(Linea,174,4) ,
          substring(Linea,178,4) ,substring(Linea,182,1) , substring(Linea,183,2),CAST(substring(Linea,185,19) AS NUMERIC(19)),
          substring(Linea,204,3) ,substring(Linea,207,9) ,substring(Linea,216,15),substring(Linea,231,15),substring(Linea,246,6) ,
          substring(Linea,252,2),substring(Linea,254,1),substring(Linea,255,1) ,substring(Linea,256,45),substring(Linea,301,5) ,
          substring(Linea,306,2),substring(Linea,308,3),substring(Linea,311,20),substring(Linea,331,15),substring(Linea,346,2) ,
          substring(Linea,348,15),substring(Linea,363,45),substring(Linea,408,5),substring(Linea,413,2),substring(Linea,415,3),
          substring(Linea,418,20),substring(Linea,438,15),substring(Linea,453,2),substring(Linea,455,15),substring(Linea,66,6),
          substring(Linea,72,16),substring(Linea,88,6),substring(Linea,94,16),substring(Linea,110,6),substring(Linea,116,16);

      --Seccion 3
      MERGE INTO TJD_ITF_PERSONAS AS TJD
		USING (
			SELECT
				CAST(REPLACE (substring(Linea,539,9), ''.'', '''') AS NUMERIC) AS NroDocumento,
				substring(Linea,536,3) AS TipoDocumento,
				Max(CAST(substring(Linea,470,6) AS NUMERIC(6))) AS GrupoOperadorModif,
				Max(CAST(substring(Linea,476,16) AS NUMERIC(16))) AS TimestampModif,
				Max(CAST(substring(Linea,492,6) AS NUMERIC(6))) AS Auditoria_Alta,
				Max(CAST(substring(Linea,498,16) AS NUMERIC(16))) AS Timestamp_Alta,
				Max(CAST(substring(Linea,514,6) AS NUMERIC(6))) AS GrupoOperadorConfir,
				Max(CAST(substring(Linea,520,16) AS NUMERIC(16))) AS TimestampConfir,
				Max(substring(Linea,548,15)) AS Apellido,
				Max(substring(Linea,563,15)) AS Nombre,
				Max(substring(Linea,578,1)) AS Sexo,
				Max(substring(Linea,579,2)) AS Codigo_CUIL,
				Max(substring(Linea,581,9)) AS NroDocumentoCuil,
				Max(substring(Linea,590,1)) AS DigVerificadorCuil,
				Max(substring(Linea,591,20)) AS Ocupacion,
				Max(substring(Linea,611,8)) AS FechaNacimiento,
				Max(substring(Linea,619,1)) AS EstadoCivil,
				Max(substring(Linea,620,15)) AS Nacionalidad,
				Max(substring(Linea,635,30)) AS Observaciones
			FROM ITF_LINK_TRK
			WHERE SUBSTRING(Linea, 1, 6) IN (
				SELECT CODIGO_LINK
				FROM TJD_TIPOS_NOVEDADES_LINK
				WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0
			)
			AND (substring(Linea,539,9) <> ''         '' AND substring(Linea,539,9) <> ''000000000'') 
			AND (substring(Linea,536,3) <> ''   '' AND substring(Linea,536,3) <> ''000'')
			GROUP BY CAST(REPLACE (substring(Linea,539,9), ''.'', '''') AS NUMERIC),
				substring(Linea,536,3)
		) AS B
		ON TJD.NroDocumento = B.NroDocumento AND TJD.TipoDocumento = B.TipoDocumento
		WHEN MATCHED THEN
			UPDATE SET 
				GrupoOperadorModif = B.GrupoOperadorModif,TimestampModif = B.TimestampModif,
				Auditoria_Alta = B.Auditoria_Alta, Timestamp_Alta = B.Timestamp_Alta,GrupoOperadorConfir = B.GrupoOperadorConfir, 
				TimestampConfir = B.TimestampConfir, 
				Apellido = B.Apellido, Nombre = B.Nombre, Sexo = B.Sexo, Código_CUIL = B.Codigo_CUIL, 
				NroDocumentoCuil = B.NroDocumentoCuil,DigVerificadorCuil = B.DigVerificadorCuil
		WHEN NOT MATCHED THEN
			INSERT (
				NroDocumento, TipoDocumento, GrupoOperadorModif, TimestampModif, Auditoria_Alta, Timestamp_Alta,
				GrupoOperadorConfir, TimestampConfir, Apellido, Nombre, Sexo, Código_CUIL, NroDocumentoCuil,
				DigVerificadorCuil, Ocupación, FechaNacimiento, EstadoCivil, Nacionalidad, Observaciones
			)
			VALUES (
				B.NroDocumento, B.TipoDocumento, B.GrupoOperadorModif, B.TimestampModif, B.Auditoria_Alta, B.Timestamp_Alta,
				B.GrupoOperadorConfir, B.TimestampConfir, B.Apellido, B.Nombre, B.Sexo, B.Codigo_CUIL, B.NroDocumentoCuil,
				B.DigVerificadorCuil, B.Ocupacion, B.FechaNacimiento, B.EstadoCivil, B.Nacionalidad, B.Observaciones
			);

     --Seccion 6      
	 INSERT INTO TJD_ITF_PERSONAS_CONTACTO 
	  (Tipo_Doc, Num_Doc, Grupo_Oper_Alta, Timestamp_Alta, Grupo_Oper_Modif, Timestamp_Modif, Calle_Contacto, Num_Contacto, 
	  Piso_Contacto, Depto_Contacto, Provincia_Contacto, Localidad_Contacto, Tel_Personal_Area, Tel_Personal_Num,
	  Tel_Laboral_Area, Tel_Laboral_Num, Tel_Laboral_Interno, Tel_Celular_Area, Tel_Celular_Num, Email)
	SELECT 
		Tipo_Doc,
		Num_Doc,
		Max(Grupo_Oper_Alta) AS Grupo_Oper_Alta,
		Max(Timestamp_Alta) AS Timestamp_Alta,
		Max(Grupo_Oper_Modif) AS Grupo_Oper_Modif,
		Max(Timestamp_Modif) AS Timestamp_Modif,
		Max(Calle_Contacto) AS Calle_Contacto,
		Max(Num_Contacto) AS Num_Contacto,
		Max(Piso_Contacto) AS Piso_Contacto,
		Max(Depto_Contacto) AS Depto_Contacto,
		Max(Provincia_Contacto) AS Provincia_Contacto,
		Max(Localidad_Contacto) AS Localidad_Contacto,
		Max(Tel_Personal_Area) AS Tel_Personal_Area,
		Max(Tel_Personal_Num) AS Tel_Personal_Num,
		Max(Tel_Laboral_Area) AS Tel_Laboral_Area,
		Max(Tel_Laboral_Num) AS Tel_Laboral_Num,
		Max(Tel_Laboral_Interno) AS Tel_Laboral_Interno,
		Max(Tel_Celular_Area) AS Tel_Celular_Area,
		Max(Tel_Celular_Num) AS Tel_Celular_Num,
		Max(Email) AS Email
	FROM (
		SELECT
			substring(Linea,536,3) AS Tipo_Doc,
			CAST(REPLACE (substring(Linea,539,9), ''.'', '''') AS NUMERIC) AS Num_Doc,
			substring(Linea,1227,6) AS Grupo_Oper_Alta,
			substring(Linea,1233,16) AS Timestamp_Alta,
			substring(Linea,1249,6) AS Grupo_Oper_Modif,
			substring(Linea,1255,16) AS Timestamp_Modif,
			substring(Linea,1271,60) AS Calle_Contacto,
			substring(Linea,1331,10) AS Num_Contacto,
			substring(Linea,1341,2) AS Piso_Contacto,
			substring(Linea,1343,3) AS Depto_Contacto,
			substring(Linea,1346,2) AS Provincia_Contacto,
			substring(Linea,1376,3) AS Localidad_Contacto,
			substring(Linea,1416,2) AS Tel_Personal_Area,
			substring(Linea,1420,10) AS Tel_Personal_Num,
			substring(Linea,1430,4) AS Tel_Laboral_Area,
			substring(Linea,1434,10) AS Tel_Laboral_Num,
			substring(Linea,1444,5) AS Tel_Laboral_Interno,
			substring(Linea,1449,4) AS Tel_Celular_Area,
			substring(Linea,1453,10) AS Tel_Celular_Num,
			substring(Linea,1463,100) AS Email
		FROM ITF_LINK_TRK
		WHERE SUBSTRING(Linea, 1, 6) 
		IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0) 
		AND (substring(Linea,539,9) <> ''         '' AND substring(Linea,539,9) <> ''000000000'') 
		AND (substring(Linea,536,3) <> ''   '' AND substring(Linea,536,3) <> ''000'')
		AND (substring(Linea,1227,6) IS NOT NULL AND substring(Linea,1227,6) <> ''      '')
		AND (substring(Linea,1233,16) IS NOT NULL AND substring(Linea,1233,16) <> ''                '')
		AND (substring(Linea,1249,6) IS NOT NULL AND substring(Linea,1249,6) <> ''      '')
		AND (substring(Linea,1255,16) IS NOT NULL AND substring(Linea,1255,16) <> ''                '')
	) AS X
	GROUP BY Tipo_Doc, Num_Doc;

	--Seccion 4
	INSERT INTO TJD_ITF_TARJETAS_COMPLETAS (Nro_Tarjeta,Tipo_Doc,Nro_Doc,Nro_Raiz,Grp_Op_Modif,Timestamp_Modif,Aud_Alta,
		Timestamp_Alta,Grp_Op_Conf,Timestamp_Conf,Miembro,Nro_Version,Dig_Verif,Cat_Comision,Cod_Lim_Debito,Cod_Lim_Credito,
		Tipo_Tarj,Meses_Vigencia,Fec_Vencimiento,Estado,Cant_Cuentas_Asociadas,Ref_Cliente,Cant_Pin_Impresos,Marca_Pin,Fec_Emi_Pin,
		Fec_Ent_Pin,Cant_Plasticos_Imp,Marca_Plastico,Fec_Emi_Plast,Fec_Ent_Plast,Cod_Denuncia,Grp_Afinidad) 
	SELECT substring(Linea,731,19),substring(Linea,751,3) ,CAST(CAST(REPLACE (substring(Linea,754,9), ''.'', '''') AS NUMERIC) AS VARCHAR(9)),substring(Linea,132,19),substring(Linea,665,6) ,
		substring(Linea,671,16),substring(Linea,687,6) ,substring(Linea,693,16),substring(Linea,709,6) ,substring(Linea,715,16),
		substring(Linea,750,1) ,substring(Linea,763,1) ,substring(Linea,764,1) ,substring(Linea,765,2) ,substring(Linea,767,2) ,
		substring(Linea,769,2) ,substring(Linea,771,2) ,substring(Linea,773,3) ,substring(Linea,776,4) ,substring(Linea,780,1) ,
		substring(Linea,781,2) ,substring(Linea,783,12),substring(Linea,795,2) ,substring(Linea,797,1) ,substring(Linea,798,8) ,
		substring(Linea,806,8) ,substring(Linea,814,2) ,substring(Linea,816,1) ,substring(Linea,817,8) ,substring(Linea,825,8) ,
		substring(Linea,833,16),substring(Linea,849,4) 
	FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
	IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0) 
	AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

      --Graba TJD_ITF_TARJETAS_CUENTAS y TJD_LINK_MAESTRO_CUENTA Y TJD_REL_TARJETA_CUENTA
      EXEC SP_ITF_LINK_TRX_TARJETA_CUENTA @ErrorMaestroCuenta OUTPUT;
	  
	  IF LEN(LTRIM(@ErrorMaestroCuenta)) > 0
	  BEGIN
	    RETURN
	  END
	  
	  INSERT INTO TJD_TARJETAS (JTS_OID_GTOS,TIPO_TARJETA,ID_TARJETA,NRO_CLIENTE,TITULARIDAD,ESTADO,FECHA_ENTREGA,VENCIMIENTO,
		NOMBRE_TARJETA,SUCURSAL,ID_TARJETA_TITULAR,NRO_PERSONA,PERMISO,LIMITE_CREDITO,LIMITE_DEBITO,NUM_VERSION,DIGITO_VERIFICADOR,ID_TARJETA_BASE)
	  SELECT S.JTS_OID,TTT.TIPO_TARJETA,substring(Linea, 731, 19) NroTar,S.C1803, (CASE WHEN substring(TRX.Linea,750,1) = ''0'' THEN ''T'' ELSE ''C'' END), --CCP.TITULARIDAD,
		substring(Linea, 780, 1) Estado,CASE WHEN substring(Linea, 825, 8) <> ''00000000'' THEN CAST(substring(Linea, 825, 8) AS DATETIME) ELSE NULL End FecEnt,
		CAST(DATEFROMPARTS(substring(Linea, 776, 2) + 2000, substring(Linea, 778, 2), 1) AS DATETIME) AS FecVto,
		Concat(trim(substring(Linea, 548, 14)), '' '', substring(Linea, 563, 15)) nombreTarjeta,
		S.SUCURSAL,substring(Linea, 731, 19),DPFJ.NUMEROPERSONAFJ, substring(Linea,771,2) Permiso,substring(Linea,769,2) LimCre, substring(Linea,767,2) LimDeb,
		substring(Linea,763,1) Version,substring(Linea,764,1) Verificador, substring(Linea, 132, 19) TarjetaBase
	  FROM ITF_LINK_TRK TRX (nolock)
	  JOIN VTA_SALDOS VS (nolock) ON VS.CTA_REDLINK = substring(TRX.Linea, 185, 19)
	  JOIN SALDOS S (nolock) ON VS.JTS_OID_SALDO = S.JTS_OID AND S.C1785 = CASE WHEN substring(TRX.Linea, 183, 2) = ''01'' THEN 2 ELSE 3 END
	  JOIN TJD_TIPO_TARJETA TTT (nolock) ON TTT.CODIGO_PRODUCTO = substring(TRX.Linea, 178, 4)
	  JOIN CLI_DocumentosPFPJ DPFJ (nolock) ON DPFJ.NUM_DOC_FISICO = CAST(CAST(REPLACE(substring(Linea,539,9),''.'' ,'''') AS NUMERIC) AS VARCHAR(20)) AND DPFJ.TIPO_DOC_FISICO = substring(Linea,536,3)
	  --JOIN CLI_ClientePersona CCP (nolock) ON CCP.CODIGOCLIENTE = S.C1803 AND CCP.NUMEROPERSONA = DPFJ.NUMEROPERSONAFJ
      WHERE EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6) AND ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      
      --Caso Especial para cuando no exista Cuenta Vista en Topaz
	  EXECUTE dbo.SP_ITF_LINK_TRX_SINDATO @Error OUTPUT

  END TRY

  BEGIN CATCH
    -- Captura la excepcion y almacena el mensaje de error en la variable @Error
    SET @Error = CONCAT(''Linea '',ERROR_LINE(), '' - '' , ERROR_MESSAGE());
    print @Error;
  END CATCH;
     
END;
')