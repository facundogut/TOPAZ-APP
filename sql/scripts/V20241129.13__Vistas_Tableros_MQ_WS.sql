execute('
IF EXISTS (SELECT name 
           FROM sys.indexes 
           WHERE name = ''IX_DATETIME_INIT_DESC'' 
             AND object_id = OBJECT_ID(''dbo.BITACORA_QUEUEMANAGER''))
BEGIN
    DROP INDEX IX_DATETIME_INIT_DESC ON dbo.BITACORA_QUEUEMANAGER;
END;

IF EXISTS (SELECT name 
           FROM sys.indexes 
           WHERE name = ''IX_DATETIME_INIT_DESC'' 
             AND object_id = OBJECT_ID(''dbo.BITACORA_WS''))
BEGIN
    DROP INDEX IX_DATETIME_INIT_DESC ON dbo.BITACORA_WS;
END;
');

execute('
create nonclustered index IX_DATETIME_INIT_DESC on dbo.BITACORA_WS (DATETIME_INIT desc); 
create nonclustered index IX_DATETIME_INIT_DESC on dbo.BITACORA_QUEUEMANAGER (DATETIME_INIT desc); 
');

execute('
create or alter function dbo.PARSE_RESPONSE_MQ 
( 
	@Mensaje varchar(max), -- El mensaje completo 
	@Objeto varchar(50)    -- El nombre del objeto a buscar (por ejemplo, ''COD_RETORNO'') 
) 
returns varchar(max) 
as 
begin 
	declare @Inicio int; 
	declare @Fin int; 
	declare @Valor varchar(max); 
	
	-- Encontrar el inicio del valor del objeto 
	set @Inicio = CHARINDEX(@Objeto + '':'', @Mensaje) + LEN(@Objeto + '':''); 
	
	-- Validar si el objeto existe en el mensaje 
	if @Inicio > LEN(@Objeto + '':'') 
	begin 
		-- Encontrar el final del valor (hasta la coma siguiente o el final del mensaje) 
		set @Fin = CHARINDEX('','', @Mensaje, @Inicio); 
		-- Si es el Final del mensaje Corrije 
		if @Fin = 0 SET @Fin = LEN(@Mensaje) + 1; 
		
		-- Extraer el valor del objeto 
		set @Valor = SUBSTRING(@Mensaje, @Inicio, @Fin - @Inicio); 
	end 
	else 
	begin 
		set @Valor = NULL; -- Si el objeto no existe, devolver NULL 
	end 
	
	return LTRIM(RTRIM(@Valor)); -- Eliminar espacios en blanco 
end 
;
');

execute('
create or alter view dbo.VW_TOPAZ_MQ_HISTORICO 
as
select 
bq.TRANSACTION_ID 
, bq.CHANNEL 
, bq.ASIENTO 
, convert(date, bq.PROCESS_DATE) as ''PROCESS_DATE'' 
, bq.SUCURSAL 
, convert(varchar(5), bq.OPE_NUMBER) as ''OPE_NUMBER'' 
, bq.REQUEST 
, REPLACE(bq.RESPONSE, '', '', '','' + CHAR(13) + CHAR(10)) as ''RESPONSE'' 
, bq.DATETIME_INIT 
, bq.DATETIME_END 
, bq.STATUS as ''MQ_RESPONSE_CODE'' 
, convert(date, bq.DATETIME_INIT) as ''DATE_INIT'' 
, convert(int, replace(convert(varchar(8), bq.DATETIME_INIT, 108), '':'', '''')) as ''TIME_INIT'' 
, --Logica Status Respuesta MQ 
  case 
  	--Logica para Pago Electronico EPAGO (OPE7939) 
	when bq.OPE_NUMBER = 7939 and dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') is not null then case 
		when dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') = ''0'' then ''OK'' 
		else ''ERROR'' 
	end 
	--FIN Logica para Pago Electronico EPAGO (OPE7939) 
	--Logica para Ordenes de Debito ORDDEB (OPE7927) 
	when bq.OPE_NUMBER = 7927 and dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') is not null then case 
		when dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') = ''0'' then ''OK'' 
		else ''ERROR'' 
	end 
	--FIN Logica para Ordenes de Debito ORDDEB (OPE7927) 
	--Logica para Recaudaciones Soporte DJP - Recaudaciones Soporte (OPE9918) 
	when bq.OPE_NUMBER = 9918 and dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') is not null then case 
		when dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') = ''0'' then ''OK'' 
		else ''ERROR'' 
	end 
	--FIN Logica para Recaudaciones Soporte DJP - Recaudaciones Soporte (OPE9918) 
	--Logica para Debitos Automaticos Soporte DJP - DebAut Soporte (OPE9919) 
	when bq.OPE_NUMBER = 9919 and dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') is not null then case 
		when dbo.PARSE_RESPONSE_MQ(bq.RESPONSE, ''COD_RETORNO'') = ''0'' then ''OK'' 
		else ''ERROR'' 
	end 
	--FIN Logica para Debitos Automaticos Soporte DJP - DebAut Soporte (OPE9919) 
	--Por Defecto usar Codigo Respuesta del MQ 
	else case 
		 	when bq.STATUS = 1 then ''OK'' 
		 	when bq.STATUS is null then ''RUNNING'' 
		 	else ''ERROR'' 
		 end 
	--FIN Por Defecto usar Codigo Respuesta del MQ 
  end as ''STATUS'' 
  --FIN Logica Status Respuesta MQ 
from BITACORA_QUEUEMANAGER bq (nolock) 
');

execute('
create or alter view dbo.VW_TOPAZ_WS_HISTORICO 
as 
	select 
	bw.TRANSACTION_ID 
	, bw.CHANNEL 
	, bw.USUARIO 
	, bw.EMPRESA 
	, bw.SUCURSAL_EMPRESA 
	, bw.OPE_NUMBER 
	, case 
		when bw.SERVICE_TYPE = 1 then ''POST'' 
		when bw.SERVICE_TYPE = 2 then ''GET'' 
		else convert(varchar(1), bw.SERVICE_TYPE) 
	  end as ''SERVICE_TYPE'' 
	, bw.SERVICE_METHOD 
	, bw.REQUEST 
	, bw.RESPONSE_HTTP_CODE 
	, bw.DATETIME_INIT 
	, bw.DATETIME_END 
	, bw.RESPONSE 
	, bw.SERVERIP 
	, convert(date, bw.DATETIME_INIT) as ''DATE_INIT'' 
	, convert(int, replace(convert(varchar(8), bw.DATETIME_INIT, 108), '':'', '''')) as ''TIME_INIT'' 
	, --Logica Status Respuesta Servicios 
	  case 
		--Logica para Asiento Cuenta Vista (OPE8908) 
		when bw.SERVICE_METHOD = ''/saldos/AsientoCuentaVista'' and JSON_VALUE(bw.RESPONSE, ''$.resultado.codigoResultado'') is not null then case 
			when JSON_VALUE(bw.RESPONSE, ''$.resultado.codigoResultado'') = ''200'' then ''OK'' 
			else ''ERROR'' 
		end 
		--FIN Logica para Asiento Cuenta Vista (OPE8908) 
		--Logica para Reversa de Asiento Cuenta Vista (OPE7934) 
		when bw.SERVICE_METHOD = ''/vinculacion/extornoAsientos'' and JSON_VALUE(bw.RESPONSE, ''$.respuesta.codigoResultado'') is not null then case 
			when JSON_VALUE(bw.RESPONSE, ''$.respuesta.codigoResultado'') = ''200'' then ''OK'' 
			else ''ERROR'' 
		end 
		--FIN Logica para Reversa de Asiento Cuenta Vista (OPE7934) 
		--Por Defecto usar Codigo Respuesta del Servicio 
		else case 
			 	when bw.RESPONSE_HTTP_CODE = 200 then ''OK'' 
			 	when bw.RESPONSE_HTTP_CODE is null then ''RUNNING'' 
			 	else ''ERROR'' 
			 end 
		--FIN Por Defecto usar Codigo Respuesta del Servicio 
	  end as ''STATUS'' 
	  --FIN Logica Status Respuesta Servicios 
	from BITACORA_WS bw (nolock) 
');
