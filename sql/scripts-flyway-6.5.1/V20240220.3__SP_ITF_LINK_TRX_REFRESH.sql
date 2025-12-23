EXECUTE('
CREATE OR ALTER        PROCEDURE SP_ITF_LINK_TRX_REFRESH 
	@Error VARCHAR(250) OUTPUT,
	@erroresCta VARCHAR(250) OUTPUT
AS
BEGIN
    SET @Error = '' '';

  	BEGIN TRY

  		--Tablas base replicada
  		MERGE INTO TJD_LINK_MAESTRO AS A
  		USING (
  		       SELECT ID_TARJETA = SUBSTRING(Linea, 731, 19),
  		    COD_TRAN = SUBSTRING(Linea, 1, 6),
  		    TIPO_TARJETA = SUBSTRING(Linea, 771, 2),
		    ESTADO_TARJETA = SUBSTRING(Linea, 780, 1),
		    FECHA_ENTREGA_TARJ = SUBSTRING(Linea, 825, 8),
		    VENCIMIENTO_TARJETA = SUBSTRING(Linea, 776, 4),
		    LIMITE_MONTO_TARJETA = SUBSTRING(Linea, 767, 2),
		    NUM_VERSION_TARJ = SUBSTRING(Linea, 763, 1),
		    DIGITO_VERIFICADOR_TARJ = SUBSTRING(Linea, 764, 1),
		    PRODUCTO = SUBSTRING(Linea, 178, 4),
		    NOMBRE_TARJETA = CONCAT(TRIM(SUBSTRING(Linea, 548, 15)), '' '', TRIM(SUBSTRING(Linea, 563, 15))),
		    LIMITE_CREDITO = SUBSTRING(Linea, 769, 2), 
		    TARJETA_TITULAR = SUBSTRING(Linea, 132, 19),
		    PROCESADO = ''N''
		    FROM ITF_LINK_TRK
		    WHERE EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK (nolock) WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6)  AND ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
		    AND (SUBSTRING(Linea, 731, 19) <> ''                   '' AND SUBSTRING(Linea, 731, 19) <> ''0000000000000000000'')
  			) AS B
  		  ON A.ID_TARJETA = b.ID_TARJETA AND A.COD_TRAN = b.COD_TRAN
  		WHEN MATCHED THEN
  		   UPDATE SET A.TIPO_TARJETA = B.TIPO_TARJETA,
		    A.ESTADO_TARJETA = B.ESTADO_TARJETA,
		    A.FECHA_ENTREGA_TARJ = B.FECHA_ENTREGA_TARJ,
		    A.VENCIMIENTO_TARJETA = B.VENCIMIENTO_TARJETA,
		    A.LIMITE_MONTO_TARJETA = B.LIMITE_MONTO_TARJETA,
		    A.NUM_VERSION_TARJ = B.NUM_VERSION_TARJ,
		    A.DIGITO_VERIFICADOR_TARJ = B.DIGITO_VERIFICADOR_TARJ,
		    A.PRODUCTO = B.PRODUCTO,
		    A.NOMBRE_TARJETA = B.NOMBRE_TARJETA,
		    A.LIMITE_CREDITO = B.LIMITE_CREDITO, 
		    A.TARJETA_TITULAR = B.TARJETA_TITULAR,
		    A.PROCESADO = B.PROCESADO
		WHEN NOT MATCHED THEN
		  INSERT (ID_TARJETA, COD_TRAN, TIPO_TARJETA, ESTADO_TARJETA, FECHA_ENTREGA_TARJ, VENCIMIENTO_TARJETA,
		    LIMITE_MONTO_TARJETA, NUM_VERSION_TARJ, DIGITO_VERIFICADOR_TARJ, PRODUCTO, NOMBRE_TARJETA, LIMITE_CREDITO,
		    TARJETA_TITULAR, PROCESADO)
		  VALUES (B.ID_TARJETA, B.COD_TRAN, B.TIPO_TARJETA, B.ESTADO_TARJETA, B.FECHA_ENTREGA_TARJ, B.VENCIMIENTO_TARJETA, 
		    B.LIMITE_MONTO_TARJETA ,B.NUM_VERSION_TARJ, B.DIGITO_VERIFICADOR_TARJ, B.PRODUCTO, B.NOMBRE_TARJETA, B.LIMITE_CREDITO,
		    B.TARJETA_TITULAR, B.PROCESADO);
		
		MERGE INTO TJD_ITF_TARJETA_RAIZ AS A
		USING (
			SELECT DISTINCT NumRaiz = SUBSTRING(Linea, 132, 19),
			Prefijo = substring(Linea,151,11),
		    NumCliente = CAST(substring(Linea,162,12) AS NUMERIC),
		    Sucursal = substring(Linea,174,4) ,
      	    Producto =  substring(Linea,178,4) ,
		    EstadoRaiz = substring(Linea,182,1) ,
		    TipoCuentaPrincipal = substring(Linea,183,2),
		    NumCuentaPrincipal = CAST(substring(Linea,185,19) AS NUMERIC),
		    TipoDocApoderado = substring(Linea,204,3) ,
		    NumDocApoderado = substring(Linea,207,9) ,
		    Apellido = substring(Linea,216,15),
		    Nombre = substring(Linea,231,15),
		    CodEnte =substring(Linea,246,6) ,
		    CantMiembros = substring(Linea,252,2),
		    DomicilioPin = substring(Linea,254,1),
		    DomicilioPlastico = substring(Linea,255,1) ,
		    CalleParticular = substring(Linea,256,45),
		    NumParticular = substring(Linea,301,5) ,
		    PisoParticular = substring(Linea,306,2),
		    DeptoParticular = substring(Linea,308,3),
		    LocalidadParticular = substring(Linea,311,20),
		    CodPostalParticular = substring(Linea,331,15),
		    CodProvinciaParticular = substring(Linea,346,2) ,
		    TelParticular = substring(Linea,348,15),
		    CalleLaboral = substring(Linea,363,45),
		    NumLaboral = substring(Linea,408,5),
		    PisoLaboral = substring(Linea,413,2),
		    DeptoLaboral = substring(Linea,415,3),
		    LocalidadLaboral = substring(Linea,418,20),
		    CodPostalLaboral = substring(Linea,438,15),
		    CodProvinciaLaboral = substring(Linea,453,2),
		    TelLaboral = substring(Linea,455,15),
		    GrupoOperadorModif = substring(Linea,66,6),
		    TimestampModif = substring(Linea,72,16),
		    GrupoOperadorAlta = substring(Linea,88,6),
		    TimestampAlta = substring(Linea,94,16),
		    GrupoOperadorConfir = substring(Linea,110,6),
		    TimestampConfir = substring(Linea,116,16) 
		  FROM ITF_LINK_TRK
		  WHERE EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK (nolock)
		  			   WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6)
		  			     AND ACTUALIZA_BD = ''S'' 
		  			     AND TZ_LOCK = 0)
			AND (SUBSTRING(Linea, 132, 19) <> ''                   '' AND SUBSTRING(Linea, 132, 19) <> ''0000000000000000000'')
		   ) AS B
		ON B.NumRaiz = A.NumRaiz
		WHEN MATCHED AND A.TimestampModif <= B.TimestampModif AND A.TimestampConfir <= B.TimestampConfir THEN
			UPDATE SET 
				A.Prefijo = B.Prefijo,
		    A.NumCliente = B.NumCliente,
		    A.Sucursal = B.Sucursal,
      	    A.Producto =  B.Producto,
		    A.EstadoRaiz = B.EstadoRaiz,
		    A.TipoCuentaPrincipal = B.TipoCuentaPrincipal,
		    A.NumCuentaPrincipal = B.NumCuentaPrincipal,
		    A.TipoDocApoderado = B.TipoDocApoderado,
		    A.NumDocApoderado = B.NumDocApoderado,
		    A.Apellido = B.Apellido,
		    A.Nombre = B.Nombre,
		    A.CodEnte = B.CodEnte,
		    A.CantMiembros = B.CantMiembros,
		    A.DomicilioPin = B.DomicilioPin,
		    A.DomicilioPlastico = B.DomicilioPlastico,
		    A.CalleParticular = B.CalleParticular,
		    A.NumParticular = B.NumParticular,
		    A.PisoParticular = B.PisoParticular,
		    A.DeptoParticular = B.DeptoParticular,
		    A.LocalidadParticular = B.LocalidadParticular,
		    A.CodPostalParticular = B.CodPostalParticular,
		    A.CodProvinciaParticular = B.CodProvinciaParticular,
		    A.TelParticular = B.TelParticular,
		    A.CalleLaboral = B.CalleLaboral,
		    A.NumLaboral = B.NumLaboral,
		    A.PisoLaboral = B.PisoLaboral,
		    A.DeptoLaboral = B.DeptoLaboral,
		    A.LocalidadLaboral = B.LocalidadLaboral,
		    A.CodPostalLaboral = B.CodPostalLaboral,
		    A.CodProvinciaLaboral = B.CodProvinciaLaboral,
		    A.TelLaboral = B.TelLaboral,
		    A.GrupoOperadorModif = B.GrupoOperadorModif,
		    A.TimestampModif = B.TimestampModif,
		    A.GrupoOperadorAlta = B.GrupoOperadorAlta,
		    A.TimestampAlta = B.TimestampAlta,
		    A.GrupoOperadorConfir = B.GrupoOperadorConfir,
		    A.TimestampConfir = B.TimestampConfir
		    
		WHEN NOT MATCHED THEN
		  INSERT (NumRaiz, Prefijo, NumCliente, Sucursal, Producto, EstadoRaiz, TipoCuentaPrincipal, 
          NumCuentaPrincipal, TipoDocApoderado, NumDocApoderado, Apellido,Nombre, CodEnte, CantMiembros, DomicilioPin, DomicilioPlastico, 
          CalleParticular, NumParticular, PisoParticular, DeptoParticular,LocalidadParticular, CodPostalParticular, CodProvinciaParticular,
          TelParticular, CalleLaboral, NumLaboral, PisoLaboral, DeptoLaboral,LocalidadLaboral, CodPostalLaboral, CodProvinciaLaboral, 
          TelLaboral, GrupoOperadorModif, TimestampModif, GrupoOperadorAlta, TimestampAlta, GrupoOperadorConfir, TimestampConfir)
          VALUES (B.NumRaiz, B.Prefijo, B.NumCliente, B.Sucursal, B.Producto, B.EstadoRaiz, B.TipoCuentaPrincipal, 
          B.NumCuentaPrincipal, B.TipoDocApoderado, B.NumDocApoderado, B.Apellido, B.Nombre, B.CodEnte, B.CantMiembros, B.DomicilioPin, B.DomicilioPlastico, 
          B.CalleParticular, B.NumParticular, B.PisoParticular, B.DeptoParticular, B.LocalidadParticular, B.CodPostalParticular, B.CodProvinciaParticular,
          B.TelParticular, B.CalleLaboral, B.NumLaboral, B.PisoLaboral, B.DeptoLaboral, B.LocalidadLaboral, B.CodPostalLaboral, B.CodProvinciaLaboral, 
          B.TelLaboral, B.GrupoOperadorModif, B.TimestampModif, B.GrupoOperadorAlta, B.TimestampAlta, B.GrupoOperadorConfir, B.TimestampConfir);
		
		
		MERGE INTO TJD_ITF_PERSONAS AS A
		USING (SELECT DISTINCT NroDocumento = substring(Linea,539,9),
		    TipoDocumento = substring(Linea,536,3),
		    GrupoOperadorModif = substring(Linea,470,6),
	    	TimestampModif = substring(Linea,476,16),
	    	Auditoria_Alta = substring(Linea,492,6),
	    	Timestamp_Alta = substring(Linea,498,16),
	    	GrupoOperadorConfir = substring(Linea,514,6),
	    	TimestampConfir = substring(Linea,520,16),
	    	Apellido = substring(Linea,548,15), 
	    	Nombre = substring(Linea,563,15),
	    	Sexo = substring(Linea,578,1),
	    	Código_CUIL = substring(Linea,579,2),
	    	NroDocumentoCuil = substring(Linea,581,9) ,
	    	DigVerificadorCuil = substring(Linea,590,1) ,      
	    	Ocupación = substring(Linea,591,20),
	    	FechaNacimiento = substring(Linea,611,8) ,
	    	EstadoCivil = substring(Linea,619,1) ,
	    	Nacionalidad = substring(Linea,620,15),
	    	Observaciones = substring(Linea,635,30) 
		FROM ITF_LINK_TRK
		WHERE EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK (nolock) WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6)  AND ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
		  AND (SUBSTRING(Linea, 539, 9) <> ''         '' AND SUBSTRING(Linea, 539, 9) <> ''000000000'')
		  AND (SUBSTRING(Linea, 536, 3) <> ''   '' AND SUBSTRING(Linea, 536, 3) <> ''000'')
		) AS B
		ON A.NroDocumento = B.NroDocumento And A.TipoDocumento = B.TipoDocumento
		WHEN MATCHED AND A.TimestampModif <= B.TimestampModif AND A.TimestampConfir <= B.TimestampConfir THEN
			UPDATE SET A.GrupoOperadorModif = B.GrupoOperadorModif,
	    	A.TimestampModif = B.TimestampModif,
	    	A.Auditoria_Alta = B.Auditoria_Alta,
	    	A.Timestamp_Alta = B.Timestamp_Alta,
	    	A.GrupoOperadorConfir = B.GrupoOperadorConfir,
	    	A.TimestampConfir = B.TimestampConfir,
	    	A.Apellido = B.Apellido, 
	    	A.Nombre = B.Nombre,
	    	A.Sexo = B.Sexo,
	    	A.Código_CUIL = B.Código_CUIL,
	    	A.NroDocumentoCuil = B.NroDocumentoCuil,
	    	A.DigVerificadorCuil = B.DigVerificadorCuil,
	    	A.Ocupación = B.Ocupación,
	    	A.FechaNacimiento = B.FechaNacimiento,
	    	A.EstadoCivil = B.EstadoCivil,
	    	A.Nacionalidad = B.Nacionalidad,
	    	A.Observaciones = B.Observaciones
	    WHEN NOT MATCHED THEN
			INSERT (
				NroDocumento, TipoDocumento, GrupoOperadorModif, TimestampModif, Auditoria_Alta, Timestamp_Alta,
				GrupoOperadorConfir, TimestampConfir, Apellido, Nombre, Sexo, Código_CUIL, NroDocumentoCuil,
				DigVerificadorCuil, Ocupación, FechaNacimiento, EstadoCivil, Nacionalidad, Observaciones
			)
			VALUES (
				B.NroDocumento, B.TipoDocumento, B.GrupoOperadorModif, B.TimestampModif, B.Auditoria_Alta, B.Timestamp_Alta,
				B.GrupoOperadorConfir, B.TimestampConfir, B.Apellido, B.Nombre, B.Sexo, B.Código_CUIL, B.NroDocumentoCuil,
				B.DigVerificadorCuil, B.Ocupación, B.FechaNacimiento, B.EstadoCivil, B.Nacionalidad, B.Observaciones
			);
		
		MERGE INTO TJD_ITF_PERSONAS_CONTACTO AS A
		USING (SELECT Tipo_Doc = substring(Linea,536,3),
			Num_Doc = substring(Linea,539,9),
		    Grupo_Oper_Alta = substring(Linea,1227,6),
		    Timestamp_Alta = substring(Linea,1233,16),
		    Grupo_Oper_Modif = substring(Linea,1249,6),
		    Timestamp_Modif = substring(Linea,1255,16),
		    Calle_Contacto = substring(Linea,1271,60),
		    Num_Contacto = substring(Linea,1331,10),
		    Piso_Contacto = substring(Linea,1341,2) ,
		    Depto_Contacto = substring(Linea,1343,3) ,
		    Provincia_Contacto = substring(Linea,1346,2) ,
		    Localidad_Contacto = substring(Linea,1376,3) ,
		    Tel_Personal_Area = substring(Linea,1416,2) ,
		    Tel_Personal_Num = substring(Linea,1420,10),
		    Tel_Laboral_Area = substring(Linea,1430,4) ,
		    Tel_Laboral_Num = substring(Linea,1434,10),
		    Tel_Laboral_Interno = substring(Linea,1444,5) ,
		    Tel_Celular_Area = substring(Linea,1449,4) ,
		    Tel_Celular_Num = substring(Linea,1453,10),
		    Email = substring(Linea,1463,100) 
		FROM ITF_LINK_TRK
		WHERE EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK (nolock) WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6)  AND ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
		  AND (SUBSTRING(Linea, 539, 9) <> ''         ''  AND SUBSTRING(Linea, 539, 9) <> ''000000000'')
		  AND (SUBSTRING(Linea, 536, 3) <> ''   '' AND SUBSTRING(Linea, 536, 3) <> ''000'')
		  ) B 
		ON A.Tipo_Doc = B.Tipo_Doc AND A.Num_Doc = B.Num_Doc
		WHEN MATCHED AND A.Timestamp_Modif <= B.Timestamp_Modif THEN
			UPDATE SET A.Grupo_Oper_Alta = B.Grupo_Oper_Alta,
		    A.Timestamp_Alta = B.Timestamp_Alta,
		    A.Grupo_Oper_Modif = B.Grupo_Oper_Modif,
		    A.Timestamp_Modif = B.Timestamp_Modif,
		    A.Calle_Contacto = B.Calle_Contacto,
		    A.Num_Contacto = B.Num_Contacto,
		    A.Piso_Contacto = B.Piso_Contacto,
		    A.Depto_Contacto = B.Depto_Contacto,
		    A.Provincia_Contacto = B.Provincia_Contacto,
		    A.Localidad_Contacto = B.Localidad_Contacto,
		    A.Tel_Personal_Area = B.Tel_Personal_Area,
		    A.Tel_Personal_Num = B.Tel_Personal_Num,
		    A.Tel_Laboral_Area = B.Tel_Laboral_Area,
		    A.Tel_Laboral_Num = B.Tel_Laboral_Num,
		    A.Tel_Laboral_Interno = B.Tel_Laboral_Interno,
		    A.Tel_Celular_Area = B.Tel_Celular_Area,
		    A.Tel_Celular_Num = B.Tel_Celular_Num,
		    A.Email = B.Email
			
		WHEN NOT MATCHED THEN
			INSERT (TIPO_DOC, NUM_DOC, Grupo_Oper_Alta, Timestamp_Alta, Grupo_Oper_Modif, Timestamp_Modif, Calle_Contacto, Num_Contacto,
			  Piso_Contacto, Depto_Contacto, Provincia_Contacto, Localidad_Contacto, Tel_Personal_Area, Tel_Personal_Num, Tel_Laboral_Area,
			  Tel_Laboral_Num, Tel_Laboral_Interno, Tel_Celular_Area, Tel_Celular_Num, Email)
			VALUES (B.TIPO_DOC, B.NUM_DOC, B.Grupo_Oper_Alta, B.Timestamp_Alta, B.Grupo_Oper_Modif, B.Timestamp_Modif, B.Calle_Contacto, B.Num_Contacto,
			  B.Piso_Contacto, B.Depto_Contacto, B.Provincia_Contacto, B.Localidad_Contacto, B.Tel_Personal_Area, B.Tel_Personal_Num, B.Tel_Laboral_Area,
			  B.Tel_Laboral_Num, B.Tel_Laboral_Interno, B.Tel_Celular_Area, B.Tel_Celular_Num, B.Email
			);
		
		--Doy de baja la version anterior
		UPDATE TJD_ITF_TARJETAS_COMPLETAS
		SET Estado = ''X''
		WHERE EXISTS(SELECT 1 FROM ITF_LINK_TRK A 
					 WHERE SUBSTRING(A.Linea, 1, 6) IN (190000,190002,190007)
					   AND Nro_Tarjeta = CONCAT(substring(Linea,731,17), CONVERT(NUMERIC,substring(Linea,748,1))-1)
					   AND EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK (nolock)
					              WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6)  
					              AND ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
					   AND (SUBSTRING(Linea, 731, 19) <> ''                   '' AND SUBSTRING(Linea, 731, 19) <> ''0000000000000000000'')
		  )
		
		UPDATE TJD_ITF_TARJETAS_COMPLETAS
		SET Estado = ''3''
		WHERE EXISTS(SELECT 1 FROM ITF_LINK_TRK A 
					 WHERE SUBSTRING(A.Linea, 1, 6) IN (190010)
					   AND Nro_Tarjeta = CONCAT(substring(Linea,731,17), CONVERT(NUMERIC,substring(Linea,748,1))-1)
					   AND EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK (nolock)
					              WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6)  
					              AND ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
					   AND (SUBSTRING(Linea, 731, 19) <> ''                   '' AND SUBSTRING(Linea, 731, 19) <> ''0000000000000000000'')
		  )
		--
		MERGE INTO TJD_ITF_TARJETAS_COMPLETAS AS A
		USING (SELECT Nro_Tarjeta = substring(Linea,731,19),
		    Tipo_Doc = substring(Linea,751,3) ,
			Nro_Doc = CAST(CAST(REPLACE (substring(Linea,754,9), ''.'', '''') AS NUMERIC) AS VARCHAR(9)),
			Nro_Raiz = substring(Linea,132,19),
		    Grp_Op_Modif = substring(Linea,665,6),
		    Timestamp_Modif = substring(Linea,671,16),
		    Aud_Alta = substring(Linea,687,6) ,
		    Timestamp_Alta = substring(Linea,693,16),
		    Grp_Op_Conf = substring(Linea,709,6) ,
		    Timestamp_Conf = substring(Linea,715,16),
		    Miembro = substring(Linea,750,1) ,
		    Nro_Version = substring(Linea,763,1) ,
		    Dig_Verif = substring(Linea,764,1) ,
		    Cat_Comision = substring(Linea,765,2) ,
		    Cod_Lim_Debito = substring(Linea,767,2) ,
		    Cod_Lim_Credito = substring(Linea,769,2) ,
		    Tipo_Tarj = substring(Linea,771,2) ,
		    Meses_Vigencia = substring(Linea,773,3) ,
		    Fec_Vencimiento = substring(Linea,776,4) ,
		    Estado = substring(Linea,780,1) ,
		    Cant_Cuentas_Asociadas = substring(Linea,781,2) ,
		    Ref_Cliente = substring(Linea,783,12),
		    Cant_Pin_Impresos = substring(Linea,795,2) ,
		    Marca_Pin = substring(Linea,797,1) ,
		    Fec_Emi_Pin = substring(Linea,798,8) ,
		    Fec_Ent_Pin = substring(Linea,806,8) ,
		    Cant_Plasticos_Imp = substring(Linea,814,2) ,
		    Marca_Plastico = substring(Linea,816,1) ,
		    Fec_Emi_Plast = substring(Linea,817,8) ,
		    Fec_Ent_Plast = substring(Linea,825,8) ,
		    Cod_Denuncia =  substring(Linea,833,16),
		    Grp_Afinidad = substring(Linea,849,4),
		    CODIGO_LINK = SUBSTRING(Linea, 1, 6)
			FROM ITF_LINK_TRK
			WHERE EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK (nolock) WHERE CODIGO_LINK = SUBSTRING(Linea, 1, 6)  AND ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
			  AND (SUBSTRING(Linea, 731, 19) <> ''                   '' AND SUBSTRING(Linea, 731, 19) <> ''0000000000000000000'')
		) AS B
		ON A.Nro_Tarjeta = B.Nro_Tarjeta
		WHEN MATCHED And A.Timestamp_Modif <= B.Timestamp_Modif AND A.Timestamp_Conf <= B.Timestamp_Conf 
		   --AND EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK N WHERE N.ACTUALIZA_BD = ''S'' AND N.CODIGO_LINK = B.CODIGO_LINK AND TZ_LOCK = 0) 
		   THEN
			UPDATE SET A.Grp_Op_Modif = B.Grp_Op_Modif,
		    A.Timestamp_Modif = B.Timestamp_Modif,
		    A.Aud_Alta = B.Aud_Alta,
		    A.Timestamp_Alta = B.Timestamp_Alta,
		    A.Grp_Op_Conf = B.Grp_Op_Conf,
		    A.Timestamp_Conf = B.Timestamp_Conf,
		    A.Miembro = B.Miembro,
		    A.Nro_Version = B.Nro_Version,
		    A.Dig_Verif = B.Dig_Verif,
		    A.Cat_Comision = B.Cat_Comision,
		    A.Cod_Lim_Debito = B.Cod_Lim_Debito,
		    A.Cod_Lim_Credito = B.Cod_Lim_Credito,
		    A.Tipo_Tarj = B.Tipo_Tarj,
		    A.Meses_Vigencia = B.Meses_Vigencia,
		    A.Fec_Vencimiento = B.Fec_Vencimiento,
		    A.Estado = B.Estado,
		    A.Cant_Cuentas_Asociadas = B.Cant_Cuentas_Asociadas,
		    A.Ref_Cliente = B.Ref_Cliente,
		    A.Cant_Pin_Impresos = B.Cant_Pin_Impresos ,
		    A.Marca_Pin = B.Marca_Pin,
		    A.Fec_Emi_Pin = B.Fec_Emi_Pin,
		    A.Fec_Ent_Pin = B.Fec_Ent_Pin,
		    A.Cant_Plasticos_Imp = B.Cant_Plasticos_Imp,
		    A.Marca_Plastico = B.Marca_Plastico,
		    A.Fec_Emi_Plast = B.Fec_Emi_Plast,
		    A.Fec_Ent_Plast = B.Fec_Ent_Plast,
		    A.Cod_Denuncia =  B.Cod_Denuncia,
		    A.Grp_Afinidad = B.Grp_Afinidad
		WHEN NOT MATCHED THEN
			INSERT (NRO_TARJETA, Tipo_Doc, Nro_Doc, Nro_Raiz, Grp_Op_Modif, Timestamp_Modif, Aud_Alta, Timestamp_Alta,
		    Grp_Op_Conf, Timestamp_Conf, Miembro, Nro_Version, Dig_Verif, Cat_Comision, Cod_Lim_Debito,
		    Cod_Lim_Credito, Tipo_Tarj, Meses_Vigencia, Fec_Vencimiento, Estado, Cant_Cuentas_Asociadas,
		    Ref_Cliente, Cant_Pin_Impresos, Marca_Pin, Fec_Emi_Pin, Fec_Ent_Pin, Cant_Plasticos_Imp,
		    Marca_Plastico, Fec_Emi_Plast, Fec_Ent_Plast, Cod_Denuncia, Grp_Afinidad)
		    VALUES(B.NRO_TARJETA, B.Tipo_Doc, B.Nro_Doc, B.Nro_Raiz, B.Grp_Op_Modif, B.Timestamp_Modif, B.Aud_Alta, B.Timestamp_Alta,
		    B.Grp_Op_Conf, B.Timestamp_Conf, B.Miembro, B.Nro_Version, B.Dig_Verif, B.Cat_Comision, B.Cod_Lim_Debito,
		    B.Cod_Lim_Credito, B.Tipo_Tarj, B.Meses_Vigencia, B.Fec_Vencimiento, B.Estado, B.Cant_Cuentas_Asociadas,
		    B.Ref_Cliente, B.Cant_Pin_Impresos, B.Marca_Pin, B.Fec_Emi_Pin, B.Fec_Ent_Pin, B.Cant_Plasticos_Imp,
		    B.Marca_Plastico, B.Fec_Emi_Plast, B.Fec_Ent_Plast, B.Cod_Denuncia, B.Grp_Afinidad);
  		
		--Tablas del modulo
		
		--Caso especial se elimina para insertar datos
		DELETE TJD_ITF_TARJETAS_CUENTAS
		WHERE NroTarjeta IN (Select substring(Linea,731,19)
            FROM ITF_LINK_TRK 
            where SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1185,19) <> ''                   '' and  substring(Linea,1185,19) <> ''0000000000000000000'')
        	
        )
        
		MERGE INTO TJD_ITF_TARJETAS_CUENTAS AS A
		USING (
			Select NroTarjeta = substring(Linea,731,19),
			  Cuenta = 1, 
			  Tipo_Cuenta = substring(Linea,853,2), 
			  Numero_Cuenta = substring(Linea,855,19),
			  Estado_Cuenta = substring(Linea,874,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,855,19) <> ''                   '' and  substring(Linea,855,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),2,substring(Linea,875,2) ,substring(Linea,877,19),substring(Linea,896,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,877,19) <> ''                   '' and  substring(Linea,877,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),3,substring(Linea,897,2) ,substring(Linea,899,19),substring(Linea,918,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,899,19) <> ''                   '' and  substring(Linea,899,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),4,substring(Linea,919,2) ,substring(Linea,921,19),substring(Linea,940,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,921,19) <> ''                   '' and  substring(Linea,921,19) <> ''0000000000000000000'')
            UNION
             Select substring(Linea,731,19),5,substring(Linea,941,2) ,substring(Linea,943,19),substring(Linea,962,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,943,19) <> ''                   '' and  substring(Linea,943,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),6,substring(Linea,963,2) ,substring(Linea,965,19),substring(Linea,984,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,965,19) <> ''                   '' and  substring(Linea,965,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),7,substring(Linea,985,2) ,substring(Linea,987,19),substring(Linea,1006,1)
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,987,19) <> ''                   '' and  substring(Linea,987,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),8,substring(Linea,1007,2) ,substring(Linea,1009,19),substring(Linea,1028,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1009,19) <> ''                   '' and  substring(Linea,1009,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),9,substring(Linea,1029,2) ,substring(Linea,1031,19),substring(Linea,1050,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1031,19) <> ''                   '' and  substring(Linea,1031,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),10,substring(Linea,1051,2) ,substring(Linea,1053,19),substring(Linea,1072,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1053,19) <> ''                   '' and  substring(Linea,1053,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),11,substring(Linea,1073,2) ,substring(Linea,1075,19),substring(Linea,1094,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1075,19) <> ''                   '' and  substring(Linea,1075,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),12, substring(Linea,1095,2) , substring(Linea,1097,19), substring(Linea,1116,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1097,19) <> ''                   '' and  substring(Linea,1097,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),13,substring(Linea,1117,2) ,substring(Linea,1119,19),substring(Linea,1138,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1119,19) <> ''                   '' and  substring(Linea,1119,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),14,substring(Linea,1139,2) ,substring(Linea,1141,19),substring(Linea,1160,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1141,19) <> ''                   '' and  substring(Linea,1141,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),15,substring(Linea,1161,2) ,substring(Linea,1163,19),substring(Linea,1182,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1163,19) <> ''                   '' and  substring(Linea,1163,19) <> ''0000000000000000000'')
            UNION
            Select substring(Linea,731,19),16,substring(Linea,1183,2) ,substring(Linea,1185,19),substring(Linea,1204,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1185,19) <> ''                   '' and  substring(Linea,1185,19) <> ''0000000000000000000'')
            )B
		ON A.NroTarjeta = B.NroTarjeta AND A.NUMERO_CUENTA = B.NUMERO_CUENTA 
		WHEN MATCHED THEN
			UPDATE SET A.Estado_Cuenta = B.Estado_Cuenta
		
		WHEN NOT MATCHED THEN
			INSERT (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            VALUES(B.NROTARJETA, B.CUENTA, B.TIPO_CUENTA, B.Numero_Cuenta, B.Estado_Cuenta);
		
		MERGE INTO TJD_REL_TARJETA_CUENTA AS A
		USING (SELECT ID_TARJETA = substring(LINK.Linea,731,19),
		    		  CODIGO_LINK = SUBSTRING(LINK.Linea, 1, 6),
		    		  ESTADO = substring(LINK.Linea, 780, 1),
		    		  CUENTA_PBF = TC.NUMERO_CUENTA,
		    		  --
		    		  S.JTS_OID,
		    		  S.PRODUCTO,
		    		  S.CUENTA,
		    		  S.MONEDA,
		    		  S.SUCURSAL,
		    		  TC.Tipo_Cuenta,
		    		  TC.Estado_Cuenta,
		    		  ORDINAL_PREFERENCIA = 0,
		    		  PRIORITARIA = (CASE WHEN TC.CUENTA = 1 THEN 1 ELSE 0 END),
		    		  LINK.LINEA
		    FROM ITF_LINK_TRK LINK
		    JOIN TJD_ITF_TARJETAS_CUENTAS TC ON TC.NROTARJETA = substring(LINK.Linea,731,19)
		    JOIN VTA_SALDOS VS ON TC.NUMERO_CUENTA = CTA_REDLINK
            JOIN SALDOS S ON S.JTS_OID = VS.JTS_OID_SALDO 
              AND S.C1785 = CASE WHEN Tipo_Cuenta = ''01'' THEN 2 ELSE 3 END
              AND s.MONEDA = CASE WHEN Tipo_Cuenta = ''01'' THEN 1 WHEN Tipo_Cuenta = ''11'' THEN 1 ELSE 2 END
              AND EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK N WHERE N.ACTUALIZA_BD = ''S'' AND N.CODIGO_LINK = SUBSTRING(LINK.Linea, 1, 6) AND TZ_LOCK = 0)
              AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'') 
		   )B
		 ON A.ID_TARJETA = B.ID_TARJETA
		WHEN MATCHED
		  THEN
			UPDATE SET A.ESTADO = B.ESTADO
			
		WHEN NOT MATCHED THEN
			INSERT (TZ_LOCK,ID_TARJETA,SALDO_JTS_OID,TIPO_CUENTA,PRIORITARIA,PRODUCTO,CUENTA,MONEDA,
            SUCURSAL,ORDINAL_PREFERENCIA,ESTADO, CUENTA_PBF)
            VALUES(0, ID_TARJETA, JTS_OID, Tipo_Cuenta, PRIORITARIA, PRODUCTO, CUENTA, MONEDA, 
            SUCURSAL, ORDINAL_PREFERENCIA, Estado_Cuenta, CUENTA_PBF);
		
		--Baja
		MERGE INTO TJD_TARJETAS AS A
		USING (SELECT ID_TARJETA = substring(Linea,731,19),
			   	ESTADO = substring(Linea, 780, 1),
			   	FECHA_ENTREGA = CASE WHEN substring(Linea, 825, 8) <> ''00000000'' THEN CAST(substring(Linea, 825, 8) AS DATETIME) ELSE NULL End,
	        	VENCIMIENTO = CAST(DATEFROMPARTS(substring(Linea, 776, 2) + 2000, substring(Linea, 778, 2), 1) AS DATETIME),
	        	NOMBRE_TARJETA = Concat(trim(substring(Linea, 548, 14)), '' '', substring(Linea, 563, 15)),
	        	ID_TARJETA_TITULAR = substring(Linea, 731, 19),
	        	PERMISO = substring(Linea,771,2),
	        	LIMITE_CREDITO = substring(Linea,769,2),
	        	LIMITE_DEBITO = substring(Linea,767,2),
	        	NUM_VERSION = substring(Linea,763,1),
	        	DIGITO_VERIFICADOR = substring(Linea,764,1),
	        	ID_TARJETA_BASE = substring(Linea, 132, 19),
	        	--
	        	CODIGO_PRODUCTO = substring(Linea, 178, 4),
	        	CTA_REDLINK = substring(Linea, 185, 19),
	        	TIPO_PRODUCTO = substring(Linea, 183, 2),
	        	NUM_DOC_FISICO = CAST(CAST(REPLACE(substring(Linea,539,9),''.'' ,'''') AS NUMERIC) AS VARCHAR(20)),
	        	TIPO_DOC_FISICO = substring(Linea,536,3),
	        	CODIGO_LINK = SUBSTRING(Linea, 1, 6),
	        	JTS_OID_GTOS = S.JTS_OID,
	        	TIPO_TARJETA = TTT.TIPO_TARJETA,
	        	NRO_CLIENTE = S.C1803,
	        	TITULARIDAD = (CASE WHEN substring(TRX.Linea,750,1) = ''0'' THEN ''T'' ELSE ''C'' END), --CCP.TITULARIDAD,
	        	SUCURSAL = S.SUCURSAL,
	        	NRO_PERSONA = DPFJ.NUMEROPERSONAFJ, 
	        	LINEA
			   --FROM ITF_LINK_TRK
			   --WHERE SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
			   FROM ITF_LINK_TRK TRX (nolock)
				JOIN VTA_SALDOS VS (nolock) ON VS.CTA_REDLINK = substring(TRX.Linea, 185, 19)
				JOIN SALDOS S (nolock) ON VS.JTS_OID_SALDO = S.JTS_OID AND S.C1785 = CASE WHEN substring(TRX.Linea, 183, 2) = ''01'' THEN 2 ELSE 3 END
				JOIN TJD_TIPO_TARJETA TTT (nolock) ON TTT.CODIGO_PRODUCTO = substring(TRX.Linea, 178, 4)
				JOIN CLI_DocumentosPFPJ DPFJ (nolock) ON DPFJ.NUM_DOC_FISICO = CAST(CAST(REPLACE(substring(Linea,539,9),''.'' ,'''') AS NUMERIC) AS VARCHAR(20)) AND DPFJ.TIPO_DOC_FISICO = substring(Linea,536,3)
				--JOIN CLI_ClientePersona CCP (nolock) ON CCP.CODIGOCLIENTE = S.C1803 AND CCP.NUMEROPERSONA = DPFJ.NUMEROPERSONAFJ
			   WHERE EXISTS(SELECT 1 FROM TJD_TIPOS_NOVEDADES_LINK N (nolock) WHERE N.ACTUALIZA_BD = ''S'' AND N.TZ_LOCK = 0 AND N.CODIGO_LINK = SUBSTRING(TRX.Linea, 1, 6))
			     AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
			   )B
			 ON A.ID_TARJETA = B.ID_TARJETA
		 WHEN MATCHED
		 	THEN
			UPDATE SET A.TIPO_TARJETA = (SELECT TIPO_TARJETA FROM TJD_TIPO_TARJETA (nolock) where CODIGO_PRODUCTO = B.CODIGO_PRODUCTO), 
				A.LIMITE_CREDITO = B.LIMITE_CREDITO,
				A.LIMITE_DEBITO = B.LIMITE_DEBITO, 
				A.NOMBRE_TARJETA = B.NOMBRE_TARJETA,
				A.DIGITO_VERIFICADOR = B.DIGITO_VERIFICADOR,
				A.ESTADO = B.ESTADO
		 WHEN NOT MATCHED AND JTS_OID_GTOS IS NOT NULL THEN
			INSERT (JTS_OID_GTOS,TIPO_TARJETA,ID_TARJETA,NRO_CLIENTE,TITULARIDAD,ESTADO,FECHA_ENTREGA,VENCIMIENTO,
	        NOMBRE_TARJETA,SUCURSAL,ID_TARJETA_TITULAR,NRO_PERSONA,PERMISO,LIMITE_CREDITO,LIMITE_DEBITO,NUM_VERSION,
	        DIGITO_VERIFICADOR,ID_TARJETA_BASE)
	      VALUES(B.JTS_OID_GTOS, B.TIPO_TARJETA, B.ID_TARJETA, B.NRO_CLIENTE, B.TITULARIDAD, B.ESTADO, B.FECHA_ENTREGA,
	        B.VENCIMIENTO, B.NOMBRE_TARJETA, B.SUCURSAL, B.ID_TARJETA_TITULAR, B.NRO_PERSONA, B.PERMISO, B.LIMITE_CREDITO,
	        B.LIMITE_DEBITO, B.NUM_VERSION, B.DIGITO_VERIFICADOR, B.ID_TARJETA_BASE);
		
		--Caso especial para cuando no exista en tabla vta_saldos
		
		EXECUTE dbo.SP_ITF_LINK_TRX_SINDATO @Error OUTPUT
		
	END TRY

    BEGIN CATCH
         -- Captura la excepcion y almacena el mensaje de error en la variable @Error
         SET @Error = CONCAT(''Linea '',ERROR_LINE(), '' - '' , ERROR_MESSAGE());
    END CATCH;	

END;
')