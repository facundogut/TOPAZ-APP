EXECUTE('
CREATE OR ALTER FUNCTION NUMEROALETRAS (
  @Numero   numeric(18,2),
  @Tipo     varchar(1)
)
RETURNS Varchar(180)
AS
BEGIN
declare @ImpLetra    varchar(250)
declare @lnEntero    int
declare @lcRetorno   varchar(512)
declare @lnTerna     int
declare @lcMiles     varchar(512)
declare @lcCadena    varchar(512)
declare @lnUnidades  int
declare @lnDecenas   int
declare @lnCentenas  int
declare @lnFraccion  int
declare @lnLen       int

  select  @lnEntero   = cast(@Numero as int),
          @lnFraccion = (@Numero - @lnEntero) * 100,
          @lcRetorno  = '''',
          @lnTerna    = 1,
          @lnLen      = len(cast(@Numero as int))
          
  while @lnEntero > 0
  
    begin
    
      -- Recorro terna por terna
      select @lcCadena   = ''''
      select @lnUnidades = @lnEntero % 10
      select @lnEntero   = cast(@lnEntero/10 as int)
      select @lnDecenas  = @lnEntero % 10
      select @lnEntero   = cast(@lnEntero/10 as int)
      select @lnCentenas = @lnEntero % 10
      select @lnEntero   = cast(@lnEntero/10 as int)
      
      -- Analizo las unidades
      select @lcCadena =
      case /* UNIDADES */
        when @lnUnidades = 1 and ((@lnTerna <> 2) OR (@lnDecenas <> 0 OR @lnCentenas <> 0))  then ''UN '' + @lcCadena
        when @lnUnidades = 1 and @lnTerna = 2 and @lnDecenas = 0 and @lnCentenas = 0 then @lcCadena
        when @lnUnidades = 2 then ''DOS '' + @lcCadena
        when @lnUnidades = 3 then ''TRES '' + @lcCadena
        when @lnUnidades = 4 then ''CUATRO '' + @lcCadena
        when @lnUnidades = 5 then ''CINCO '' + @lcCadena
        when @lnUnidades = 6 then ''SEIS '' + @lcCadena
        when @lnUnidades = 7 then ''SIETE '' + @lcCadena
        when @lnUnidades = 8 then ''OCHO '' + @lcCadena
        when @lnUnidades = 9 then ''NUEVE '' + @lcCadena
        else @lcCadena
      end
      
      -- Analizo las decenas
      select @lcCadena =
        case
          when @lnDecenas = 1 then
            case @lnUnidades
              when 0 then ''DIEZ ''
              when 1 then ''ONCE ''
              when 2 then ''DOCE ''
              when 3 then ''TRECE ''
              when 4 then ''CATORCE ''
              when 5 then ''QUINCE ''
              when 6 then ''DIECISÉIS ''
              when 7 then ''DIECISIETE ''
              when 8 then ''DIECIOCHO ''
              when 9 then ''DIECINUEVE ''
            end
          when @lnDecenas = 2 then case @lnUnidades when 0 then ''VEINTE '' else ''VEINTI'' + @lcCadena end
          when @lnDecenas = 3 then case @lnUnidades when 0 then ''TREINTA '' else ''TREINTA Y '' + @lcCadena end
          when @lnDecenas = 4 then case @lnUnidades when 0 then ''CUARENTA'' else ''CUARENTA Y '' + @lcCadena end
          when @lnDecenas = 5 then case @lnUnidades when 0 then ''CINCUENTA '' else ''CINCUENTA Y '' + @lcCadena end
          when @lnDecenas = 6 then case @lnUnidades when 0 then ''SESENTA '' else ''SESENTA Y '' + @lcCadena end
          when @lnDecenas = 7 then case @lnUnidades when 0 then ''SETENTA '' else ''SETENTA Y '' + @lcCadena end
          when @lnDecenas = 8 then case @lnUnidades when 0 then ''OCHENTA '' else  ''OCHENTA Y '' + @lcCadena end
          when @lnDecenas = 9 then case @lnUnidades when 0 then ''NOVENTA '' else ''NOVENTA Y '' + @lcCadena end
          else @lcCadena
        end
        
      -- Analizo las centenas
      select @lcCadena =
        case
          --when @lnCentenas = 1 and @lnTerna = 3 then ''CIEN '' + @lcCadena
          when @lnCentenas = 1 and @lnUnidades = 0 and @lnDecenas = 0 then ''CIEN '' + @lcCadena
          when @lnCentenas = 1 and (@lnUnidades <> 0 or @lnDecenas <> 0) then ''CIENTO '' + @lcCadena
          when @lnCentenas = 1 and @lnTerna <> 3 then ''CIENTO '' + @lcCadena
          when @lnCentenas = 2 then ''DOSCIENTOS '' + @lcCadena
          when @lnCentenas = 3 then ''TRESCIENTOS '' + @lcCadena
          when @lnCentenas = 4 then ''CUATROCIENTOS '' + @lcCadena
          when @lnCentenas = 5 then ''QUINIENTOS '' + @lcCadena
          when @lnCentenas = 6 then ''SEISCIENTOS '' + @lcCadena
          when @lnCentenas = 7 then ''SETECIENTOS '' + @lcCadena
          when @lnCentenas = 8 then ''OCHOCIENTOS '' + @lcCadena
          when @lnCentenas = 9 then ''NOVECIENTOS '' + @lcCadena
          else @lcCadena
        end
        
      -- Analizo la terna
      
      
      
      select @lcCadena =
        case
          when @lnTerna = 1 then @lcCadena
		  WHEN @lnTerna = 2 THEN @lcCadena + ''MIL ''
          when @lnTerna = 3 and @lnLen = 7 and @lnUnidades = 1 then @lcCadena + ''MILLON ''
          when @lnTerna = 3 and @lnLen = 7 and @lnUnidades > 1 then @lcCadena + ''MILLONES ''
		  when @lnTerna = 3 and @lnLen > 7 then @lcCadena + ''MILLONES ''
          when @lnTerna = 4 then @lcCadena + ''MIL ''
          else ''''
        end
      
      -- Armo el retorno terna a terna
      select @lcRetorno = @lcCadena  + @lcRetorno
      select @lnTerna = @lnTerna + 1
      
    end
    
  if @lnTerna = 1
    select @lcRetorno = ''CERO''
    
  set @ImpLetra = @lcRetorno
  
  
      declare @sFraccion varchar(15)
      set @sFraccion = ''00'' + ltrim(cast(@lnFraccion as varchar))
      select @ImpLetra = rtrim(@lcRetorno) + '' CON '' + substring(@sFraccion, len(@sFraccion)-1,2) + ''/100''
   
    
  

RETURN @ImpLetra
  
end
')

