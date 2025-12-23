EXECUTE('
CREATE OR ALTER   PROCEDURE [dbo].[SP_ITF_LINK_TRX_TARJETA_CUENTA]  
  @Error VARCHAR(500) OUTPUT
AS
DECLARE @accion VARCHAR(1);

BEGIN
	BEGIN TRY
	
      delete from TJD_ITF_TARJETAS_CUENTAS;
      truncate table TJD_REL_TARJETA_CUENTA;
    
    
      SET @Error = '' '';
    
            --Seccion 5
            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),1,substring(Linea,853,2) ,substring(Linea,855,19),substring(Linea,874,1) 
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

 

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),3,substring(Linea,897,2) ,substring(Linea,899,19),substring(Linea,918,1) 
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

 

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),5,substring(Linea,941,2) ,substring(Linea,943,19),substring(Linea,962,1) 
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

 

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),7,substring(Linea,985,2) ,substring(Linea,987,19),substring(Linea,1006,1)
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

 

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),9,substring(Linea,1029,2) ,substring(Linea,1031,19),substring(Linea,1050,1) 
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

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),11,substring(Linea,1073,2) ,substring(Linea,1075,19),substring(Linea,1094,1) 
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

 

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),13,substring(Linea,1117,2) ,substring(Linea,1119,19),substring(Linea,1138,1) 
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

 

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),15,substring(Linea,1161,2) ,substring(Linea,1163,19),substring(Linea,1182,1) 
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

            INSERT INTO TJD_REL_TARJETA_CUENTA (TZ_LOCK,ID_TARJETA,SALDO_JTS_OID,TIPO_CUENTA,PRIORITARIA,PRODUCTO,CUENTA,MONEDA,
            SUCURSAL,ORDINAL_PREFERENCIA,ESTADO, CUENTA_PBF)
            SELECT 0, NroTarjeta,S.JTS_OID,Tipo_Cuenta, (CASE WHEN (ROW_NUMBER() OVER(PARTITION BY NroTarjeta  ORDER by NroTarjeta)) = 1 THEN 1 ELSE 0 END),S.PRODUCTO,S.CUENTA,S.MONEDA,
            S.SUCURSAL,0,Estado_Cuenta, Numero_Cuenta
            FROM TJD_ITF_TARJETAS_CUENTAS TJD_CTA (nolock)
            JOIN VTA_SALDOS VS (nolock) ON CONCAT(TIPO_CUENTA, NUMERO_CUENTA) = CTA_REDLINK 
            JOIN SALDOS S (nolock) ON S.JTS_OID = VS.JTS_OID_SALDO 
              AND S.C1785 = CASE WHEN Tipo_Cuenta = ''01'' THEN 2 ELSE 3 END
              AND s.MONEDA = CASE WHEN Tipo_Cuenta = ''01'' THEN 1 WHEN Tipo_Cuenta = ''11'' THEN 1 ELSE 2 END
            ;             

      END TRY

 

      BEGIN CATCH
         -- Captura la excepcion y almacena el mensaje de error en la variable @Error
         SET @Error = CONCAT(''Linea '',ERROR_LINE(), '' - '' , ERROR_MESSAGE());
         print @Error;
      END CATCH;
END;
')