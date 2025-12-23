Execute('
DELETE FROM ITF_MASTER_PARAMETROS WHERE CODIGO IN (170,171,172,173,174)
')

Execute('
INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (170, 0, ''MAIL AD USU'', ''Mail envia 1.3.6'', '' '', ''nbchtesting@outlook.com'', 0, 0, NULL, 0, 0, 0)
')
Execute('
INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (171, 0, ''MAIL AD USU'', ''Mail recibe 1.3.6'', '' '', ''nbchtesting@outlook.com'', 0, 0, NULL, 0, 0, 0)
')
Execute('
INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (172, 0, ''MAIL AD USU'', ''Pass envia 1.3.6'', '' '', ''BancoChaco123'', 0, 0, NULL, 0, 0, 0)
')
Execute('
INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (173, 0, ''MAIL AD USU'', ''Nombre envia 1.3.6'', '' '', ''NBCH'', 0, 0, NULL, 0, 0, 0)
')
Execute('
INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (174, 0, ''MAIL AD USU'', ''Server Mail 1.3.6'', '' '', ''outlook.office365.com'', 587, 0, NULL, 0, 0, 0)
')




Execute('
IF OBJECT_ID (''dbo.BITACORA_TJC_MAESTRO_USUARIO'') IS NOT NULL
	DROP TABLE dbo.BITACORA_TJC_MAESTRO_USUARIO
')
Execute('
CREATE TABLE dbo.BITACORA_TJC_MAESTRO_USUARIO
	(
	ADMINISTRADORA     NUMERIC (2) DEFAULT ((0)) NOT NULL,
	USUARIO            NUMERIC (20) DEFAULT ((0)) NOT NULL,
	NUM_TJC            NUMERIC (20) DEFAULT ((0)),
	TIPO_PAGO          VARCHAR (1) DEFAULT ('' ''),
	LIMITE_COMPRA      NUMERIC (15, 2) DEFAULT ((0)),
	LIMITE_CUOTAS      NUMERIC (15, 2) DEFAULT ((0)),
	FECHA_ALTA_USU     DATETIME,
	FECHA_BAJA_USU     DATETIME,
	CLIENTE            NUMERIC (12) DEFAULT ((0)),
	SUC_USUARIO        NUMERIC (5) DEFAULT ((0)),
	TIPO_USU           NUMERIC (1) DEFAULT ((0)),
	CODIGO_CIERRE      NUMERIC (3) DEFAULT ((0)),
	TIPO_TJC           VARCHAR (1) DEFAULT ('' ''),
	SUC_CUENTA_COBRO   NUMERIC (5) DEFAULT ((0)),
	CUENTA_COBRO       NUMERIC (11) DEFAULT ((0)),
	JTS_CUENTA_COBRO   NUMERIC (15) DEFAULT ((0)),
	TIPO_COBRO         NUMERIC (2) DEFAULT ((0)),
	CORREO             VARCHAR (50) DEFAULT ('' ''),
	TZ_LOCK            NUMERIC (15) DEFAULT ((0)) NOT NULL,
	DESCRIPCION_CIERRE VARCHAR (20) DEFAULT ('' ''),
	MOTIVO_ERROR       VARCHAR (100) DEFAULT ('' ''),
	FECHA_PROC         DATE NOT NULL,
	HORA_PROC          VARCHAR (10) NOT NULL,
	TICKET             NUMERIC (16), 
	CONSTRAINT PK_BITACORA_TJC_MAESTRO_USUARIO_01 PRIMARY KEY (ADMINISTRADORA, NUM_TJC , USUARIO, FECHA_PROC, HORA_PROC)
	)
')

Execute('
CREATE OR ALTER PROCEDURE ITF_AD_USU_MAIL
	@ticket NUMERIC(19),
	@mail_completo VARCHAR(max) OUTPUT
AS
BEGIN
	SET @mail_completo = ''<html lang="es"><head><title>Errores tarjetas</title></head><body><h1>Listado de Tarjetas con errores</h1><br><h4> Las siguientes tarjetas tienen errores que requieren tratamiento operativo.</h4><br><table border="1"><tr><th> <p>Código de Administradora</p> </th>  <th> <p>Número de usuario</p></th> <th>  <p>Número de tarjeta</p> </th> <th><p>Cuit</p> </th>  <th><p>Descripción del Error</p></th></tr> '';
	
	DECLARE @table_row VARCHAR(max);
	
	DECLARE @admin VARCHAR(2);
	DECLARE @user VARCHAR(20);
	DECLARE @nroTarj VARCHAR(20);
	DECLARE @cliente VARCHAR(12);
	DECLARE @errorDesc VARCHAR(100);
	
	
	DECLARE cursore CURSOR FOR
	
	SELECT ADMINISTRADORA,USUARIO,NUM_TJC,CLIENTE, MOTIVO_ERROR FROM BITACORA_TJC_MAESTRO_USUARIO WHERE TZ_LOCK=0 AND MOTIVO_ERROR <> '''' AND TICKET = @ticket
	
	OPEN cursore
	
	FETCH NEXT FROM cursore INTO @admin, @user, @nroTarj, @cliente, @errorDesc 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SET @mail_completo += concat(''<tr><td><p>'',@admin,''</p></td><td><p>'',@user,''</p></td><td><p>'',@nroTarj,''</p></td><td><p>'',@cliente,''</p></td><td> <p>'',@errorDesc ,''</p></td></tr>'');    
	    FETCH NEXT FROM cursore INTO @admin, @user, @nroTarj, @cliente, @errorDesc 
	END
	
	CLOSE cursore 
	DEALLOCATE cursore
	
	SET @mail_completo += ''</table><br><p>Atte: <b>equipo NBCH.</b></p></body></html>'';
  
END
')
