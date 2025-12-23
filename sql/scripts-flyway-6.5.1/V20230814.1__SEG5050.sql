Execute('CREATE OR ALTER  PROCEDURE SP_ITF_LINK_TRX_REFRESH  @Error VARCHAR(250) OUTPUT
AS
BEGIN
    SET @Error = '' '';

  	BEGIN TRY

  		--Tablas base replicada
		UPDATE TJD_LINK_MAESTRO
		SET
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
		FROM TJD_LINK_MAESTRO 
		    JOIN ITF_LINK_TRK ON ID_TARJETA = SUBSTRING(Linea, 731, 19) AND COD_TRAN = SUBSTRING(Linea, 1, 6)
		WHERE ID_TARJETA = SUBSTRING(Linea, 731, 19) and COD_TRAN = SUBSTRING(Linea, 1, 6) ;


		UPDATE TJD_ITF_TARJETA_RAIZ
		SET 
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
		FROM TJD_ITF_TARJETA_RAIZ JOIN ITF_LINK_TRK ON SUBSTRING(Linea, 132, 19) = NumRaiz
		WHERE SUBSTRING(Linea, 132, 19) = NumRaiz AND TimestampModif < substring(Linea,72,16) AND TimestampConfir < substring(Linea,116,16) ;

		UPDATE TJD_ITF_PERSONAS
		SET 	
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
		FROM TJD_ITF_PERSONAS 
		JOIN ITF_LINK_TRK ON NroDocumento = substring(Linea,539,9) And TipoDocumento = substring(Linea,536,3)
		WHERE NroDocumento = substring(Linea,539,9) And TipoDocumento = substring(Linea,536,3) And TimestampModif < substring(Linea,476,16)
		AND TimestampConfir < substring(Linea,520,16);

		UPDATE TJD_ITF_PERSONAS_CONTACTO
		SET 
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
		FROM TJD_ITF_PERSONAS_CONTACTO
		JOIN ITF_LINK_TRK ON Tipo_Doc = substring(Linea,536,3) AND Num_Doc = substring(Linea,539,9)
		WHERE Tipo_Doc = substring(Linea,536,3) AND Num_Doc = substring(Linea,539,9) And Timestamp_Modif < substring(Linea,1255,16);

		UPDATE TJD_ITF_TARJETAS_COMPLETAS
		SET 
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
		    Meses_Vigencia = substring(Linea,773,2) ,
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
		    Grp_Afinidad = substring(Linea,849,4) 
		FROM TJD_ITF_TARJETAS_COMPLETAS
		JOIN ITF_LINK_TRK ON Nro_Tarjeta = substring(Linea,731,19)
		WHERE Nro_Tarjeta = substring(Linea,731,19) And Timestamp_Modif < substring(Linea,671,16) AND Timestamp_Conf < substring(Linea,715,16);
  		
		--Tablas del módulo

		--Baja
  		UPDATE TJD_TARJETAS SET ESTADO = ''X''
  		From TJD_TARJETAS TJD 
  		JOIN ITF_LINK_TRK ON ID_TARJETA = substring(Linea,731,19)
  		where SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND ACCION = ''B'' AND TZ_LOCK = 0) 
     	AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

     	UPDATE TJD_REL_TARJETA_CUENTA SET ESTADO = ''X''
		FROM TJD_REL_TARJETA_CUENTA TJD
		JOIN ITF_LINK_TRK ON ID_TARJETA = substring(Linea,731,19)
		where SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND ACCION = ''B'' AND TZ_LOCK = 0) 
		AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

		--Bloqueo
		UPDATE TJD_TARJETAS SET ESTADO = ''9''
  		From TJD_TARJETAS TJD 
  		JOIN ITF_LINK_TRK ON ID_TARJETA = substring(Linea,731,19)
  		where SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND ACCION = ''BLQ'' AND TZ_LOCK = 0) 
     	AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

     	UPDATE TJD_REL_TARJETA_CUENTA SET ESTADO = ''9''
		FROM TJD_REL_TARJETA_CUENTA TJD
		JOIN ITF_LINK_TRK ON ID_TARJETA = substring(Linea,731,19)
		where SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND ACCION = ''BLQ'' AND TZ_LOCK = 0) 
		AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

		--Desbloqueo
		UPDATE TJD_TARJETAS SET ESTADO = ''1''
  		From TJD_TARJETAS TJD 
  		JOIN ITF_LINK_TRK ON ID_TARJETA = substring(Linea,731,19)
  		where SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND ACCION = ''D'' AND TZ_LOCK = 0) 
     	AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

     	UPDATE TJD_REL_TARJETA_CUENTA SET ESTADO = ''1''
		FROM TJD_REL_TARJETA_CUENTA TJD
		JOIN ITF_LINK_TRK ON ID_TARJETA = substring(Linea,731,19)
		where SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND ACCION = ''D'' AND TZ_LOCK = 0) 
		AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');
		
		MERGE TJD_TARJETAS AS A
		USING (SELECT * FROM ITF_LINK_TRK 
				WHERE SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S''
				AND ACCION = ''M'' 
				AND TZ_LOCK = 0) 
				AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
			  ) AS B
		ON A.ID_TARJETA = substring(B.Linea,731,19)
		WHEN MATCHED THEN
			UPDATE SET A.TIPO_TARJETA = substring(B.Linea,771,2), A.LIMITE_CREDITO = substring(Linea,769,2),
				A.LIMITE_DEBITO = substring(Linea,767,2), A.NOMBRE_TARJETA = Concat(trim(substring(Linea, 548, 15)), '' '', substring(Linea, 563, 15)),
				A.DIGITO_VERIFICADOR = substring(Linea,764,1);	


	END TRY

    BEGIN CATCH
         -- Captura la excepción y almacena el mensaje de error en la variable @Error
         SET @Error = ERROR_MESSAGE();
    END CATCH;	

END;')


Execute('CREATE OR ALTER  PROCEDURE SP_ITF_LINK_TRX_FULL
    @Error VARCHAR(250) OUTPUT, @ErrorMaestroCuenta VARCHAR(250) OUTPUT
AS
BEGIN
    SET @Error = '' '';
      
  BEGIN TRY

      DELETE FROM TJD_ITF_TARJETA_RAIZ;
      DELETE FROM TJD_ITF_PERSONAS;
      DELETE FROM TJD_ITF_TARJETAS_COMPLETAS;
      DELETE FROM TJD_ITF_PERSONAS_CONTACTO;
      truncate table TJD_TARJETAS;
      
      --Sección 2
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

      --Sección 3
      INSERT INTO TJD_ITF_PERSONAS (NroDocumento,TipoDocumento,GrupoOperadorModif,TimestampModif,Auditoria_Alta,Timestamp_Alta,
		  GrupoOperadorConfir, TimestampConfir,Apellido,Nombre,Sexo,Código_CUIL,NroDocumentoCuil,DigVerificadorCuil,Ocupación,
		  FechaNacimiento,EstadoCivil, Nacionalidad,Observaciones)
	  SELECT Max(CAST(CAST(REPLACE (substring(Linea,539,9), ''.'', '''') AS NUMERIC) AS VARCHAR (9))),Max(substring(Linea,536,3)),
		  Max(CAST(substring(Linea,470,6) AS NUMERIC(6))) ,
		  Max(CAST(substring(Linea,476,16) AS NUMERIC(16))),
		  Max(CAST(substring(Linea,492,6) AS NUMERIC(6))) , Max(CAST(substring(Linea,498,16) AS NUMERIC(16))),
		  Max(CAST(substring(Linea,514,6) AS NUMERIC(6))) ,Max(CAST(substring(Linea,520,16) AS NUMERIC(16))),
		  Max(substring(Linea,548,15)),Max(substring(Linea,563,15)), Max(substring(Linea,578,1)) ,Max(substring(Linea,579,2)) ,
		  Max(substring(Linea,581,9)) ,Max(substring(Linea,590,1)),Max(substring(Linea,591,20)),Max(substring(Linea,611,8)),
		  Max(substring(Linea,619,1)),Max(substring(Linea,620,15)),Max(substring(Linea,635,30)) 
      FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      And (substring(Linea,539,9) <> ''         '' And substring(Linea,539,9) <> ''000000000'') 
      And (substring(Linea,536,3) <> ''   '' And substring(Linea,536,3) <> ''000'');

      --Sección 6
      
	 INSERT INTO TJD_ITF_PERSONAS_CONTACTO 
	      (Tipo_Doc, Num_Doc, Grupo_Oper_Alta, Timestamp_Alta,Grupo_Oper_Modif,Timestamp_Modif, Calle_Contacto, Num_Contacto, 
	      Piso_Contacto, Depto_Contacto, Provincia_Contacto, Localidad_Contacto, Tel_Personal_Area, Tel_Personal_Num,
	       Tel_Laboral_Area, Tel_Laboral_Num, Tel_Laboral_Interno, Tel_Celular_Area, Tel_Celular_Num, Email)
      SELECT Max(substring(Linea,536,3)) ,Max(substring(Linea,539,9)) ,Max(substring(Linea,1227,6)) ,Max(substring(Linea,1233,16)),
	      Max(substring(Linea,1249,6)) ,Max(substring(Linea,1255,16)),Max(substring(Linea,1271,60)),Max(substring(Linea,1331,10)),
	      Max(substring(Linea,1341,2)) ,Max(substring(Linea,1343,3)) ,Max(substring(Linea,1346,2)),Max(substring(Linea,1376,3)) ,Max(substring(Linea,1416,2)) ,
	      Max(substring(Linea,1420,10)),Max(substring(Linea,1430,4)) ,Max(substring(Linea,1434,10)),Max(substring(Linea,1444,5)) ,Max(substring(Linea,1449,4)) ,
	      Max(substring(Linea,1453,10)),Max(substring(Linea,1463,100)) 
      FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0) 
      AND (substring(Linea,539,9) <> ''         '' And substring(Linea,539,9) <> ''000000000'') 
      And (substring(Linea,536,3) <> ''   '' And substring(Linea,536,3) <> ''000'');

      --Sección 4
      INSERT INTO TJD_ITF_TARJETAS_COMPLETAS (Nro_Tarjeta,Tipo_Doc,Nro_Doc,Nro_Raiz,Grp_Op_Modif,Timestamp_Modif,Aud_Alta,
        Timestamp_Alta,Grp_Op_Conf,Timestamp_Conf,Miembro,Nro_Version,Dig_Verif,Cat_Comision,Cod_Lim_Debito,Cod_Lim_Credito,
        Tipo_Tarj,Meses_Vigencia,Fec_Vencimiento,Estado,Cant_Cuentas_Asociadas,Ref_Cliente,Cant_Pin_Impresos,Marca_Pin,Fec_Emi_Pin,
        Fec_Ent_Pin,Cant_Plasticos_Imp,Marca_Plastico,Fec_Emi_Plast,Fec_Ent_Plast,Cod_Denuncia,Grp_Afinidad) 
      SELECT substring(Linea,731,19),substring(Linea,751,3) ,substring(Linea,754,9) ,substring(Linea,132,19),substring(Linea,665,6) ,
        substring(Linea,671,16),substring(Linea,687,6) ,substring(Linea,693,16),substring(Linea,709,6) ,substring(Linea,715,16),
        substring(Linea,750,1) ,substring(Linea,763,1) ,substring(Linea,764,1) ,substring(Linea,765,2) ,substring(Linea,767,2) ,
        substring(Linea,769,2) ,substring(Linea,771,2) ,substring(Linea,773,2) ,substring(Linea,776,4) ,substring(Linea,780,1) ,
        substring(Linea,781,2) ,substring(Linea,783,12),substring(Linea,795,2) ,substring(Linea,797,1) ,substring(Linea,798,8) ,
        substring(Linea,806,8) ,substring(Linea,814,2) ,substring(Linea,816,1) ,substring(Linea,817,8) ,substring(Linea,825,8) ,
        substring(Linea,833,16),substring(Linea,849,4) 
      FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0) 
      AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

      --Graba TJD_ITF_TARJETAS_CUENTAS y TJD_LINK_MAESTRO_CUENTA Y TJD_REL_TARJETA_CUENTA
      EXEC SP_ITF_LINK_TRX_TARJETA_CUENTA @ErrorMaestroCuenta;

      --TJD_TARJETAS
      INSERT INTO TJD_TARJETAS (JTS_OID_GTOS,TIPO_TARJETA,ID_TARJETA,NRO_CLIENTE,TITULARIDAD,ESTADO,FECHA_ENTREGA,VENCIMIENTO,
        NOMBRE_TARJETA,SUCURSAL,ID_TARJETA_TITULAR,NRO_PERSONA,PERMISO,LIMITE_CREDITO,LIMITE_DEBITO,NUM_VERSION,DIGITO_VERIFICADOR,ID_TARJETA_BASE)
      SELECT S.JTS_OID,TTT.TIPO_TARJETA,substring(Linea, 731, 19) NroTar,S.C1803, CCP.TITULARIDAD,
        1 Estado,CASE WHEN substring(Linea, 825, 8) <> ''00000000'' THEN CAST(substring(Linea, 825, 8) AS DATETIME) ELSE NULL End FecEnt,
        --substring(Linea, 776, 4) fecVto,
        CAST(DATEFROMPARTS(substring(Linea, 776, 2) + 2000, substring(Linea, 778, 2), 1) AS DATETIME) AS FecVto,
        Concat(trim(substring(Linea, 548, 15)), '' '', substring(Linea, 563, 15)) nombreTarjeta,
        S.SUCURSAL,substring(Linea, 731, 19),DPFJ.NUMEROPERSONAFJ,''P'' Permiso,substring(Linea,769,2) LimCre, substring(Linea,767,2) LimDeb,
        substring(Linea,763,1) Version,substring(Linea,764,1) Verificador,substring(Linea, 731, 19) TarjetaBase
      FROM ITF_LINK_TRK TRX (nolock)
      JOIN VTA_SALDOS VS (nolock) ON VS.CTA_REDLINK = substring(TRX.Linea, 185, 19)
      JOIN SALDOS S (nolock) ON VS.JTS_OID_SALDO = S.JTS_OID AND S.C1785 = CASE WHEN substring(TRX.Linea, 183, 2) = ''01'' THEN 2 ELSE 3 END
      JOIN TJD_TIPO_TARJETA TTT (nolock) ON TTT.CODIGO_PRODUCTO = substring(TRX.Linea, 178, 4)
      JOIN CLI_DocumentosPFPJ DPFJ (nolock) ON DPFJ.NUM_DOC_FISICO = CAST(CAST(REPLACE(substring(Linea,539,9),''.'' ,'''') AS NUMERIC) AS VARCHAR(20))
      JOIN CLI_ClientePersona CCP (nolock) ON CCP.CODIGOCLIENTE = S.C1803 AND CCP.NUMEROPERSONA = DPFJ.NUMEROPERSONAFJ
      --WHERE isnumeric(substring(Linea,539,9)) = 1;
      
  END TRY

  BEGIN CATCH
    -- Captura la excepción y almacena el mensaje de error en la variable @Error
    SET @Error = ERROR_MESSAGE();
    print @Error;
  END CATCH;
     
END;')





