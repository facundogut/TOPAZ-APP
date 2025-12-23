Execute('CREATE OR ALTER PROCEDURE SP_ITF_LINK_TRX_FULL
    @Error VARCHAR(150) OUTPUT, @ErrorMaestroCuenta VARCHAR(150) OUTPUT
AS
BEGIN
    SET @Error = '' '';
      
  BEGIN TRY

      DELETE FROM TJD_ITF_TARJETA_RAIZ;
      DELETE FROM TJD_ITF_PERSONAS;
      DELETE FROM TJD_ITF_TARJETAS_COMPLETAS;
      DELETE FROM TJD_ITF_PERSONAS_CONTACTO;
      DELETE FROM TJD_LINK_MAESTRO;

      INSERT INTO TJD_LINK_MAESTRO (ID_TARJETA, COD_TRAN, TIPO_TARJETA, ESTADO_TARJETA, FECHA_ENTREGA_TARJ, VENCIMIENTO_TARJETA,
      LIMITE_MONTO_TARJETA, NUM_VERSION_TARJ, DIGITO_VERIFICADOR_TARJ, NRO_PERSONA, NRO_CLIENTE, PRODUCTO,NOMBRE_TARJETA, 
      LIMITE_CREDITO, TARJETA_TITULAR)
	  SELECT SUBSTRING(Linea, 731, 19), SUBSTRING(Linea, 1, 6), SUBSTRING(Linea, 771, 2), SUBSTRING(Linea, 780, 1),
      SUBSTRING(Linea, 825, 8), SUBSTRING(Linea, 776, 4), SUBSTRING(Linea, 767, 2), SUBSTRING(Linea, 763, 1),
      SUBSTRING(Linea, 764, 1), ISNULL(NUMEROPERSONAFJ,0), ISNULL(CODIGOCLIENTE,0),SUBSTRING(Linea, 178, 4), CONCAT(TRIM(SUBSTRING(Linea, 548, 15)), '' '', TRIM(SUBSTRING(Linea, 563, 15))),
      SUBSTRING(Linea, 769, 2), SUBSTRING(Linea, 132, 19)
      FROM ITF_LINK_TRK
      LEFT JOIN CLI_DocumentosPFPJ ON NUM_DOC_FISICO = CAST(CAST(substring(Linea,539,9) AS NUMERIC(9)) AS VARCHAR)
      LEFT JOIN CLI_ClientePersona ON NUMEROPERSONAFJ = NUMEROPERSONA 
      WHERE SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      AND SUBSTRING(Linea, 132, 19) <> ''0000000000000000000'' AND SUBSTRING(Linea, 132, 19) <> ''                   '';
      
      --Sección 2
      INSERT INTO TJD_ITF_TARJETA_RAIZ    (NumRaiz, Prefijo, NumCliente, Sucursal, Producto, EstadoRaiz, TipoCuentaPrincipal, 
      NumCuentaPrincipal, TipoDocApoderado, NumDocApoderado, Apellido,Nombre, CodEnte, CantMiembros, DomicilioPin, DomicilioPlastico, 
      CalleParticular, NumParticular, PisoParticular, DeptoParticular,LocalidadParticular, CodPostalParticular, CodProvinciaParticular,
      TelParticular, CalleLaboral, NumLaboral, PisoLaboral, DeptoLaboral,LocalidadLaboral, CodPostalLaboral, CodProvinciaLaboral, 
      TelLaboral, GrupoOperadorModif, TimestampModif, GrupoOperadorAlta, TimestampAlta, GrupoOperadorConfir, TimestampConfir)
      SELECT substring(Linea,132,19),substring(Linea,151,11),CAST(substring(Linea,162,12) AS NUMERIC),substring(Linea,174,4) ,
      substring(Linea,178,4) ,substring(Linea,182,1) , substring(Linea,183,2),CAST(substring(Linea,185,19) AS NUMERIC),
      substring(Linea,204,3) ,substring(Linea,207,9) ,substring(Linea,216,15),substring(Linea,231,15),substring(Linea,246,6) ,
      substring(Linea,252,2),substring(Linea,254,1),substring(Linea,255,1) ,substring(Linea,256,45),substring(Linea,301,5) ,
      substring(Linea,306,2),substring(Linea,308,3),substring(Linea,311,20),substring(Linea,331,15),substring(Linea,346,2) ,
      substring(Linea,348,15),substring(Linea,363,45),substring(Linea,408,5),substring(Linea,413,2),substring(Linea,415,3),
      substring(Linea,418,20),substring(Linea,438,15),substring(Linea,453,2),substring(Linea,455,15),substring(Linea,66,6),
      substring(Linea,72,16),substring(Linea,88,6),substring(Linea,94,16),substring(Linea,110,6),substring(Linea,116,16) 
      FROM ITF_LINK_TRK  WHERE SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      AND SUBSTRING(Linea, 132, 19) <> ''0000000000000000000'' AND SUBSTRING(Linea, 132, 19) <> ''                   '';

      --Sección 3
      INSERT INTO TJD_ITF_PERSONAS (NroDocumento,TipoDocumento,GrupoOperadorModif,TimestampModif,Auditoria_Alta,Timestamp_Alta,
      GrupoOperadorConfir, TimestampConfir,Apellido,Nombre,Sexo,Código_CUIL,NroDocumentoCuil,DigVerificadorCuil,Ocupación,
      FechaNacimiento,EstadoCivil, Nacionalidad,Observaciones)
      SELECT CAST(substring(Linea,539,9) AS NUMERIC(9)) ,substring(Linea,536,3),CAST(substring(Linea,470,6) AS NUMERIC(6)) ,
      CAST(substring(Linea,476,16) AS NUMERIC(16)),CAST(substring(Linea,492,6) AS NUMERIC(6)) , CAST(substring(Linea,498,16) AS NUMERIC(16)),
      CAST(substring(Linea,514,6) AS NUMERIC(6)) ,CAST(substring(Linea,520,16) AS NUMERIC(16)),
      substring(Linea,548,15),substring(Linea,563,15), substring(Linea,578,1) ,substring(Linea,579,2) ,substring(Linea,581,9) ,
      substring(Linea,590,1) ,substring(Linea,591,20),
      substring(Linea,611,8) ,substring(Linea,619,1) ,substring(Linea,620,15),substring(Linea,635,30) 
      FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      And (substring(Linea,539,9) <> ''         '' And substring(Linea,539,9) <> ''000000000'') 
      And (substring(Linea,536,3) <> ''   '' And substring(Linea,536,3) <> ''000'');

      --Sección 6
      INSERT INTO TJD_ITF_PERSONAS_CONTACTO 
      (Tipo_Doc, Num_Doc, Grupo_Oper_Alta, Timestamp_Alta,Grupo_Oper_Modif,Timestamp_Modif, Calle_Contacto, Num_Contacto, 
      Piso_Contacto, Depto_Contacto, Provincia_Contacto, Localidad_Contacto, Tel_Personal_Area, Tel_Personal_Num,
       Tel_Laboral_Area, Tel_Laboral_Num, Tel_Laboral_Interno, Tel_Celular_Area, Tel_Celular_Num, Email)
      SELECT substring(Linea,536,3) ,substring(Linea,539,9) ,substring(Linea,1227,6) ,substring(Linea,1233,16),
      substring(Linea,1249,6) ,substring(Linea,1255,16),substring(Linea,1271,60),substring(Linea,1331,10),
      substring(Linea,1341,2) ,substring(Linea,1343,3) ,substring(Linea,1346,2) ,substring(Linea,1376,3) ,substring(Linea,1416,2) ,
      substring(Linea,1420,10),substring(Linea,1430,4) ,substring(Linea,1434,10),substring(Linea,1444,5) ,substring(Linea,1449,4) ,
      substring(Linea,1453,10),substring(Linea,1463,100) 
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
      
  END TRY

  BEGIN CATCH
    -- Captura la excepción y almacena el mensaje de error en la variable @Error
    SET @Error = ERROR_MESSAGE();
    print @Error;
  END CATCH;
     
END;')
Execute('
Delete DESCRIPTORES where IDENTIFICACION = 3478;
INSERT INTO dbo.DESCRIPTORES (TITULO, IDENTIFICACION, TIPODEARCHIVO, DESCRIPCION, GRUPODELMAPA, NOMBREFISICO, TIPODEDBMS, LARGODELREGISTRO, INICIALIZACIONDELREGISTRO, BASE, SELECCION, ACEPTA_MOVS_DIFERIDO)
VALUES (930, 3478, NULL, ''Solicitud Link Maestro'', 0, ''TJD_LINK_MAESTRO'', ''D'', NULL, NULL, ''Top/Clientes'', NULL, ''N'')

Delete diccionario where numerodecampo in(41287,41288,41289);
INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41287, '' '', 0, ''NRO_REGISTRO'', ''NRO_REGISTRO'', 10, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 3478, ''NRO_REGISTRO'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41288, '' '', 0, ''ID_TARJETA'', ''Id Tarjeta'', 19, ''A'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 3478, ''ID_TARJETA'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41289, '' '', 0, ''COD_TRAN'', ''Código de Transacción'', 6, ''A'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 3478, ''COD_TRAN'', 0, NULL)

delete indices where numerodearchivo = 3478;
INSERT INTO dbo.INDICES (NUMERODEARCHIVO, NUMERODEINDICE, DESCRIPCION, CLAVESREPETIDAS, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5, CAMPO6, CAMPO7, CAMPO8, CAMPO9, CAMPO10, CAMPO11, CAMPO12, CAMPO13, CAMPO14, CAMPO15, CAMPO16, CAMPO17, CAMPO18, CAMPO19, CAMPO20)
VALUES (3478, 1, ''Índice Por Tarjeta y Cod Trans'', 0, 41287, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
')

