EXECUTE('

ALTER procedure dbo.SP_CLIENTES_DUPLICADOS
(
  @p_personas  varchar(max),
  @pTitular NUMERIC(12),
  @p_proceso   float OUTPUT
)
as

-- Variables para la lectura de datos de entradas
declare @persona    varchar(255) = ''''
declare @personas   table (numeropersona int)
declare @longitud   int = len(@p_personas)
declare @i          int = 1

-- Variables para la busqueda de clientes duplicados
declare @query      nvarchar(255)
declare @sentencia  nvarchar(255) = ''select distinct(CODIGOCLIENTE) from CLI_CLIENTEPERSONA''
declare @cliente    int = 0
declare @duplicado  int = 0

DECLARE @vCantIntCliA NUMERIC(6)
DECLARE @vCantIntCliB NUMERIC(6)
DECLARE @vCantIntDif NUMERIC(6)
DECLARE @vNroIntTitularA NUMERIC(12) = @pTitular
DECLARE @vNroIntTitularB NUMERIC(12)


begin
  
  set NOCOUNT on
  
  -- Lectura de datos de entradas
  while @i <= @longitud
    begin
      if (substring(@p_personas, @i, 1) <> '','')
        set @persona = @persona + substring(@p_personas, @i, 1)
      else
        begin
          insert into @personas select @persona
          set @persona = ''''
        end
      set @i = @i + 1
    end
  insert into @personas select @persona
  
  SELECT @vCantIntCliA = COUNT(DISTINCT numeropersona) FROM @personas;
  
  -- Busqueda de clientes duplicados
  set @query = ''declare clip cursor for '' + @sentencia + '' where NUMEROPERSONA in ('' + @p_personas + '') and (tz_lock < 300000000000000 or tz_lock >= 400000000000000);''
  exec sp_executesql @query
  open clip
  fetch next from clip into @cliente
  while @@FETCH_STATUS = 0 AND @duplicado = 0
    begin
      
      SELECT @vCantIntCliB = COUNT(*) FROM CLI_CLIENTEPERSONA CP WHERE CP.CODIGOCLIENTE = @cliente AND (CP.tz_lock < 300000000000000 or CP.tz_lock >= 400000000000000);
      
      IF @vCantIntCliB = @vCantIntCliA 
      BEGIN
      	SELECT @vCantIntDif = COUNT(*)
      	FROM
      	(
	      	SELECT numeropersona FROM @personas 
	      		EXCEPT
	      	SELECT CP.NUMEROPERSONA FROM CLI_CLIENTEPERSONA CP WHERE CP.CODIGOCLIENTE = @cliente AND (CP.tz_lock < 300000000000000 or CP.tz_lock >= 400000000000000)
      	) X
      	IF @vCantIntDif = 0
      	BEGIN
      		SELECT @vNroIntTitularB = CP.NUMEROPERSONA FROM CLI_CLIENTEPERSONA CP WHERE CP.CODIGOCLIENTE = @cliente AND CP.TITULARIDAD = ''T'' AND (CP.tz_lock < 300000000000000 or CP.tz_lock >= 400000000000000)
      		IF @vNroIntTitularA = @vNroIntTitularB
      		BEGIN
      			SET @duplicado = @cliente
      		END
      	END 
      END
      
      fetch next from clip into @cliente
    
    end
  close clip
  deallocate clip
  
  -- Retorno de valores del proceso
  set @p_proceso = @duplicado
end

')