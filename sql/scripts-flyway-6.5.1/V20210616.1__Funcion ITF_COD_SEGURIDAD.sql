EXECUTE('CREATE OR ALTER  FUNCTION dbo.ITF_COD_SEGURIDAD (@sucursal NUMERIC(5,0), @nro_caja NUMERIC(3,0), @fecha DATETIME, @asiento NUMERIC(10,0)) 
RETURNS CHAR(6) 
AS
BEGIN		
	
	DECLARE @dia INT;
	DECLARE @var1 INT;
	DECLARE @var2 INT;
	DECLARE @letra CHAR(1);
	DECLARE @asiento_chr CHAR(10);
	DECLARE @longitud INT;
	DECLARE @primeros CHAR(2);
	DECLARE @ultimos CHAR(3);
	
	DECLARE @resultado CHAR(6);
	
	SELECT @dia = day(@fecha);
	
	SET @var1 = (@dia * @nro_caja * @sucursal * 28); -- minutos 28 a fuego
	
	IF @var1 = 0
	   SET @var1 = 1;
	   
	SET @var2 = @var1 % 26;  -- resto de la división entre 26
	
	SET @letra = Char(64 + @var2);
	
	SET @asiento_chr = CONVERT(varchar(10),@asiento);
	SET @longitud = len(@asiento_chr);
	
	SET @primeros  = ltrim(rtrim(substring(@asiento_chr,1,2)));
	SET @ultimos   = ltrim(rtrim(substring(@asiento_chr,(@longitud-2),3)));
	SET @resultado = concat(@primeros,@letra,@ultimos);
	
	RETURN @resultado;
	
END

')