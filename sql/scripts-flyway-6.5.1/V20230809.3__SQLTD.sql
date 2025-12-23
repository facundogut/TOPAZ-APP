Execute('CREATE OR ALTER PROCEDURE SP_ITF_LINK_TRX_FULL
    @Error VARCHAR(250) OUTPUT, @ErrorMaestroCuenta VARCHAR(250) OUTPUT
AS
BEGIN
    SET @Error = '' '';
      
  BEGIN TRY

      DELETE FROM TJD_ITF_TARJETA_RAIZ;
      DELETE FROM TJD_ITF_PERSONAS;
      DELETE FROM TJD_ITF_TARJETAS_COMPLETAS;
      DELETE FROM TJD_ITF_PERSONAS_CONTACTO;
      DELETE FROM TJD_LINK_MAESTRO;
      truncate table TJD_TARJETAS;
      
      /* Se comenta ya que no se va a requerir su uso, con esta nueva versión, el insert a TJD_TARJETAS se hace acá
      INSERT INTO TJD_LINK_MAESTRO (ID_TARJETA, COD_TRAN, TIPO_TARJETA, ESTADO_TARJETA, FECHA_ENTREGA_TARJ, VENCIMIENTO_TARJETA,
      LIMITE_MONTO_TARJETA, NUM_VERSION_TARJ, DIGITO_VERIFICADOR_TARJ, NRO_PERSONA, NRO_CLIENTE, PRODUCTO,NOMBRE_TARJETA, 
      LIMITE_CREDITO, TARJETA_TITULAR)
        SELECT SUBSTRING(Linea, 731, 19), SUBSTRING(Linea, 1, 6), SUBSTRING(Linea, 771, 2), SUBSTRING(Linea, 780, 1),
      SUBSTRING(Linea, 825, 8), SUBSTRING(Linea, 776, 4), SUBSTRING(Linea, 767, 2), SUBSTRING(Linea, 763, 1),
      SUBSTRING(Linea, 764, 1), ISNULL(NUMEROPERSONAFJ,0), ISNULL(CODIGOCLIENTE,0),SUBSTRING(Linea, 178, 4), CONCAT(TRIM(SUBSTRING(Linea, 548, 15)), '' '', TRIM(SUBSTRING(Linea, 563, 15))),
      SUBSTRING(Linea, 769, 2), SUBSTRING(Linea, 132, 19)
      FROM ITF_LINK_TRK
      LEFT JOIN CLI_DocumentosPFPJ ON NUMERODOCUMENTO = CAST(substring(Linea,539,9) AS numeric)
      LEFT JOIN CLI_ClientePersona ON NUMEROPERSONAFJ = NUMEROPERSONA 
      WHERE SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      AND SUBSTRING(Linea, 132, 19) <> ''0000000000000000000'' AND SUBSTRING(Linea, 132, 19) <> ''                   '';
      */
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
      FROM ITF_LINK_TRK TRX
      JOIN VTA_SALDOS VS ON VS.CTA_REDLINK = substring(TRX.Linea, 185, 19)
      JOIN SALDOS S ON VS.JTS_OID_SALDO = S.JTS_OID AND S.C1785 = CASE WHEN substring(TRX.Linea, 183, 2) = ''01'' THEN 2 ELSE 3 END
      JOIN TJD_TIPO_TARJETA TTT ON TTT.CODIGO_PRODUCTO = substring(TRX.Linea, 178, 4)
      JOIN CLI_DocumentosPFPJ DPFJ ON DPFJ.NUM_DOC_FISICO = CAST(CAST(substring(Linea,539,9) AS numeric) AS VARCHAR)
      JOIN CLI_ClientePersona CCP ON CCP.CODIGOCLIENTE = S.C1803 AND CCP.NUMEROPERSONA = DPFJ.NUMEROPERSONAFJ
      WHERE isnumeric(substring(Linea,539,9)) = 1;
      
  END TRY

  BEGIN CATCH
    -- Captura la excepción y almacena el mensaje de error en la variable @Error
    SET @Error = ERROR_MESSAGE();
    print @Error;
  END CATCH;
     
END;')


Execute('CREATE OR ALTER PROCEDURE SP_ITF_LINK_TRX_TARJETA_CUENTA  @Error VARCHAR(250)

AS 

BEGIN
      delete from TJD_ITF_TARJETAS_CUENTAS;
      delete from TJD_LINK_MAESTRO_CUENTA;
      truncate table TJD_REL_TARJETA_CUENTA;
      SET @Error = '' '';
      BEGIN TRY
            --Sección 5
            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),1,substring(Linea,853,2) ,substring(Linea,855,19),substring(Linea,874,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,855,19) <> ''                   '' and  substring(Linea,855,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,853,2) ,substring(Linea,855,19),substring(Linea,874,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,855,19) <> ''                   '' and  substring(Linea,855,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),2,substring(Linea,875,2) ,substring(Linea,877,19),substring(Linea,896,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,877,19) <> ''                   '' and  substring(Linea,877,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,875,2) ,substring(Linea,877,19),substring(Linea,896,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,877,19) <> ''                   '' and  substring(Linea,877,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),3,substring(Linea,897,2) ,substring(Linea,899,19),substring(Linea,918,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,899,19) <> ''                   '' and  substring(Linea,899,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,897,2) ,substring(Linea,899,19),substring(Linea,918,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,899,19) <> ''                   '' and  substring(Linea,899,19) <> ''0000000000000000000'');
            

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),4,substring(Linea,919,2) ,substring(Linea,921,19),substring(Linea,940,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,921,19) <> ''                   '' and  substring(Linea,921,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,919,2) ,substring(Linea,921,19),substring(Linea,940,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,921,19) <> ''                   '' and  substring(Linea,921,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),5,substring(Linea,941,2) ,substring(Linea,943,19),substring(Linea,962,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,943,19) <> ''                   '' and  substring(Linea,943,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,941,2) ,substring(Linea,943,19),substring(Linea,962,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,943,19) <> ''                   '' and  substring(Linea,943,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),6,substring(Linea,963,2) ,substring(Linea,965,19),substring(Linea,984,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,965,19) <> ''                   '' and  substring(Linea,965,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,963,2) ,substring(Linea,965,19),substring(Linea,984,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,965,19) <> ''                   '' and  substring(Linea,965,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),7,substring(Linea,985,2) ,substring(Linea,987,19),substring(Linea,1006,1)
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,987,19) <> ''                   '' and  substring(Linea,987,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,985,2) ,substring(Linea,987,19),substring(Linea,1006,1)
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,987,19) <> ''                   '' and  substring(Linea,987,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),8,substring(Linea,1007,2) ,substring(Linea,1009,19),substring(Linea,1028,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1009,19) <> ''                   '' and  substring(Linea,1009,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1007,2) ,substring(Linea,1009,19),substring(Linea,1028,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1009,19) <> ''                   '' and  substring(Linea,1009,19) <> ''0000000000000000000'');
           

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),9,substring(Linea,1029,2) ,substring(Linea,1031,19),substring(Linea,1050,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1031,19) <> ''                   '' and  substring(Linea,1031,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1029,2) ,substring(Linea,1031,19),substring(Linea,1050,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1031,19) <> ''                   '' and  substring(Linea,1031,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),10,substring(Linea,1051,2) ,substring(Linea,1053,19),substring(Linea,1072,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1053,19) <> ''                   '' and  substring(Linea,1053,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1051,2) ,substring(Linea,1053,19),substring(Linea,1072,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1053,19) <> ''                   '' and  substring(Linea,1053,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),11,substring(Linea,1073,2) ,substring(Linea,1075,19),substring(Linea,1094,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1075,19) <> ''                   '' and  substring(Linea,1075,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1073,2) ,substring(Linea,1075,19),substring(Linea,1094,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1075,19) <> ''                   '' and  substring(Linea,1075,19) <> ''0000000000000000000'');
            

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),12, substring(Linea,1095,2) , substring(Linea,1097,19), substring(Linea,1116,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1097,19) <> ''                   '' and  substring(Linea,1097,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1095,2) , substring(Linea,1097,19), substring(Linea,1116,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1097,19) <> ''                   '' and  substring(Linea,1097,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),13,substring(Linea,1117,2) ,substring(Linea,1119,19),substring(Linea,1138,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1119,19) <> ''                   '' and  substring(Linea,1119,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1117,2) ,substring(Linea,1119,19),substring(Linea,1138,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1119,19) <> ''                   '' and  substring(Linea,1119,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),14,substring(Linea,1139,2) ,substring(Linea,1141,19),substring(Linea,1160,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1141,19) <> ''                   '' and  substring(Linea,1141,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1139,2) ,substring(Linea,1141,19),substring(Linea,1160,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1141,19) <> ''                   '' and  substring(Linea,1141,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),15,substring(Linea,1161,2) ,substring(Linea,1163,19),substring(Linea,1182,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1163,19) <> ''                   '' and  substring(Linea,1163,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1161,2) ,substring(Linea,1163,19),substring(Linea,1182,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1163,19) <> ''                   '' and  substring(Linea,1163,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),16,substring(Linea,1183,2) ,substring(Linea,1185,19),substring(Linea,1204,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1185,19) <> ''                   '' and  substring(Linea,1185,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1183,2) ,substring(Linea,1185,19),substring(Linea,1204,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1185,19) <> ''                   '' and  substring(Linea,1185,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_REL_TARJETA_CUENTA (TZ_LOCK,ID_TARJETA,SALDO_JTS_OID,TIPO_CUENTA,PRIORITARIA,PRODUCTO,CUENTA,MONEDA,
            SUCURSAL,ORDINAL_PREFERENCIA,ESTADO)
            SELECT 0, NroTarjeta,S.JTS_OID,Tipo_Cuenta,0,S.PRODUCTO,S.CUENTA,S.MONEDA,S.SUCURSAL,0,Estado_Cuenta
            FROM TJD_ITF_TARJETAS_CUENTAS 
            JOIN VTA_SALDOS VS ON NUMERO_CUENTA = CTA_REDLINK 
            JOIN SALDOS S ON S.JTS_OID = VS.JTS_OID_SALDO AND S.C1785 = CASE WHEN Tipo_Cuenta = ''01'' THEN 2 ELSE 3 END;             
            
      END TRY

      BEGIN CATCH
         -- Captura la excepción y almacena el mensaje de error en la variable @Error
         SET @Error = ERROR_MESSAGE();
         print @Error;
      END CATCH;
END;')

