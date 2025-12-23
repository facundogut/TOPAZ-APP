EXECUTE('
CREATE  OR ALTER  PROCEDURE [dbo].[SP_COELSA_EMPRESAS_HOMOLOGADAS]

	@TICKET NUMERIC(16)

AS
BEGIN
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Created : 21/12/2022 10:00 a.m.
	--- Autor: Juan Pedrozo
	--- Se crea sp para registrar cambios entrantes correspondiente al Padron de Empresas Homologadas.
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
	/******** Variables Generales  de registros ********************/
	DECLARE @CantEmp INTEGER;
	
	DECLARE @IdEmpresa VARCHAR(11);
	DECLARE @NombreEmpresa VARCHAR(16);
	DECLARE @DescTransaccion VARCHAR(11); --EN LA BASE EL LARGO ES 10
	DECLARE @EntidadOrigen VARCHAR(8);
	DECLARE @NombreEntidad VARCHAR(30);
	DECLARE @LongClaveCliente VARCHAR(2);
	DECLARE @SegundoVencimiento  VARCHAR(1);
	DECLARE @PeriocidadPago  VARCHAR(1);
	DECLARE @ComisionUsoCuenta VARCHAR(2);
	DECLARE @Filler VARCHAR(13);
	
	
	  
	/******** Variables Generales  de registros ********************/
	
	DECLARE @DD_IdEmpresa NUMERIC(11);
	DECLARE @DD_NombreEmpresa VARCHAR(16);
	DECLARE @DD_DescTransaccion VARCHAR(11);
	DECLARE @DD_EntidadOrigen NUMERIC(8);
	DECLARE @DD_NombreEntidad VARCHAR(30);
	DECLARE @DD_LongClaveCliente NUMERIC(2);
	DECLARE @DD_SegundoVencimiento  VARCHAR(1);
	DECLARE @DD_PeriocidadPago  VARCHAR(1);
	DECLARE @DD_ComisionUsoCuenta VARCHAR(2);
	DECLARE @DD_IdConvenio NUMERIC(15,0);
	
	/*************************************************************************/
  
	DECLARE @LINEA VARCHAR(95);
	
  	TRUNCATE TABLE SNP_PRESTACIONES_EMPRESAS_AUX;  

	DECLARE che_cursor CURSOR FOR 
	
	SELECT LINEA FROM dbo.ITF_DEB_DIR_EMPR_AUX

	OPEN che_cursor

	FETCH NEXT FROM che_cursor INTO @LINEA

	WHILE @@FETCH_STATUS = 0  
	BEGIN

	   		
		SET @IdEmpresa = SUBSTRING(@LINEA, 1, 11); 			--CUIT
		SET @NombreEmpresa   = SUBSTRING(@LINEA, 12, 16);
		SET @DescTransaccion  = SUBSTRING(@LINEA, 28, 10);
		SET @EntidadOrigen  = SUBSTRING(@LINEA, 38, 8);
		SET @NombreEntidad  = SUBSTRING(@LINEA, 46, 30);
		SET @LongClaveCliente  = SUBSTRING(@LINEA, 76, 2);
		SET @SegundoVencimiento  = SUBSTRING(@LINEA, 78, 1);
		SET @PeriocidadPago  = SUBSTRING(@LINEA, 79, 1);
		SET @ComisionUsoCuenta  = SUBSTRING(@LINEA, 80, 2);
		SET @Filler  = SUBSTRING(@LINEA, 81, 14);


		--inserto en la tabla clon para poder comparar y armar el historial
		
		INSERT INTO dbo.SNP_PRESTACIONES_EMPRESAS_AUX
		(CUIT_EO,NOMBRE_EMPRESA,	PRESTACION,			ENTIDAD,	ORIGINANTE,		LARGO_ID,			SEGUNDO_VTO,			PERIODICIDAD_PAGO,ESTADO,FECHA_ALTA,ID_CONVENIO) VALUES
		(@IdEmpresa,@NombreEmpresa ,@DescTransaccion ,@EntidadOrigen ,'''' ,@LongClaveCliente ,@SegundoVencimiento ,@PeriocidadPago ,@ComisionUsoCuenta, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 0);
	   		

		FETCH NEXT FROM che_cursor INTO @LINEA;
	END

	CLOSE che_cursor
	DEALLOCATE che_cursor
	
	---------------------------------------------------------------------------------------
   
	----------BAJA
	DECLARE @Baja INTEGER;
	
	DECLARE baja_cursor CURSOR FOR 
	
	SELECT CUIT_EO ,NOMBRE_EMPRESA,PRESTACION FROM dbo.SNP_PRESTACIONES_EMPRESAS

	OPEN baja_cursor 

	FETCH NEXT FROM baja_cursor INTO @DD_IdEmpresa,@DD_NombreEmpresa ,@DD_DescTransaccion

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		SELECT @Baja = COUNT(*) FROM SNP_PRESTACIONES_EMPRESAS_AUX WHERE CUIT_EO = @DD_IdEmpresa AND PRESTACION = @DD_DescTransaccion;
	
		IF(@Baja = 0)
			INSERT INTO dbo.ITF_COELSA_EMPRESAS_HOMO_HISTORIAL (ID_TICKET, CUIT_EMPRESA, NOMBRE_EMPRESA, PRESTACION, FECHA, TIPO_ACCION)
				VALUES (@TICKET, @DD_IdEmpresa, @DD_NombreEmpresa ,@DD_DescTransaccion,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), ''B'');
	
		FETCH NEXT FROM baja_cursor INTO @DD_IdEmpresa,@DD_NombreEmpresa ,@DD_DescTransaccion;
	END

	CLOSE baja_cursor 
	DEALLOCATE baja_cursor 
	
	
	
	-----------ALTA
	DECLARE @Alta INTEGER;
	
	DECLARE alta_cursor CURSOR FOR 
	
	SELECT CUIT_EO,NOMBRE_EMPRESA,PRESTACION,ENTIDAD,ORIGINANTE,LARGO_ID,SEGUNDO_VTO,PERIODICIDAD_PAGO,ESTADO,ID_CONVENIO FROM dbo.SNP_PRESTACIONES_EMPRESAS_AUX

	OPEN alta_cursor 

	FETCH NEXT FROM alta_cursor INTO @DD_IdEmpresa,@DD_NombreEmpresa ,@DD_DescTransaccion ,@DD_EntidadOrigen ,@DD_NombreEntidad ,@DD_LongClaveCliente ,@DD_SegundoVencimiento ,@DD_PeriocidadPago ,@DD_ComisionUsoCuenta, @DD_IdConvenio

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		SELECT @Alta = COUNT(*) FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO = @DD_IdEmpresa AND PRESTACION = @DD_DescTransaccion;
		
		IF(@Alta = 0) --ALTA
			INSERT INTO dbo.ITF_COELSA_EMPRESAS_HOMO_HISTORIAL (ID_TICKET, CUIT_EMPRESA, NOMBRE_EMPRESA, PRESTACION, FECHA, TIPO_ACCION) VALUES (@TICKET, @DD_IdEmpresa, @DD_NombreEmpresa ,@DD_DescTransaccion,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), ''A'');
		
		ELSE --MODIFICACION
			IF((SELECT COUNT(*) FROM SNP_PRESTACIONES_EMPRESAS WHERE NOMBRE_EMPRESA <> @DD_NombreEmpresa OR ENTIDAD <> @DD_EntidadOrigen OR ORIGINANTE <> @DD_NombreEntidad OR LARGO_ID <> @DD_LongClaveCliente OR SEGUNDO_VTO <> @DD_SegundoVencimiento OR PERIODICIDAD_PAGO <> @DD_PeriocidadPago OR ESTADO <> @DD_ComisionUsoCuenta OR ID_CONVENIO <> @DD_IdConvenio) > 0)
			 	INSERT INTO dbo.ITF_COELSA_EMPRESAS_HOMO_HISTORIAL (ID_TICKET, CUIT_EMPRESA, NOMBRE_EMPRESA, PRESTACION, FECHA, TIPO_ACCION) VALUES (@TICKET, @DD_IdEmpresa, @DD_NombreEmpresa ,@DD_DescTransaccion,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), ''M'');
			
	
		FETCH NEXT FROM alta_cursor INTO @DD_IdEmpresa,@DD_NombreEmpresa ,@DD_DescTransaccion ,@DD_EntidadOrigen ,@DD_NombreEntidad ,@DD_LongClaveCliente ,@DD_SegundoVencimiento ,@DD_PeriocidadPago ,@DD_ComisionUsoCuenta, @DD_IdConvenio;
	END

	CLOSE alta_cursor 
	DEALLOCATE alta_cursor
	
------------------------------------------------------------------------------------------------------------------------------

END;
')