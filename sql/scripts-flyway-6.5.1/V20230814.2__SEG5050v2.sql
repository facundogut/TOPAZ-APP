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
			UPDATE SET A.TIPO_TARJETA = (SELECT TIPO_TARJETA FROM TJD_TIPO_TARJETA (nolock) where CODIGO_PRODUCTO = substring(Linea, 178, 4)), A.LIMITE_CREDITO = substring(Linea,769,2),
				A.LIMITE_DEBITO = substring(Linea,767,2), A.NOMBRE_TARJETA = Concat(trim(substring(Linea, 548, 15)), '' '', substring(Linea, 563, 15)),
				A.DIGITO_VERIFICADOR = substring(Linea,764,1);	


	END TRY

    BEGIN CATCH
         -- Captura la excepción y almacena el mensaje de error en la variable @Error
         SET @Error = ERROR_MESSAGE();
    END CATCH;	

END;')
