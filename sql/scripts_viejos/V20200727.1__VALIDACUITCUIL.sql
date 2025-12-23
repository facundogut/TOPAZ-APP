CREATE PROC SP_ValidaCUITL 
@Cuitl AS varchar(50),
@ResultVar int OUTPUT
AS
BEGIN
	
	DECLARE @TempCuitl varchar(50),
			@factmult varchar(6) ='234567',
			@i int ,
			@j int,
			@suma int

	/*
		Se crea el Store Procedure para la Validacion de CUIT/CUIL
		Retorna Codigo:	
		  0	->	Error 
		  1	->	OK		  
	*/
	set @ResultVar=0
	if len(@Cuitl)>13
	begin 
		set  @ResultVar=0
	end
	else 
	begin 
		if  len(substring(@Cuitl,1,CHARINDEX('-',@Cuitl)-1))>2 
		begin 
			set  @ResultVar=0
		end
		else 
		begin
			if  len(substring(reverse(@Cuitl),1,CHARINDEX('-',reverse(@Cuitl))-1))>1 
			begin 				
				set  @ResultVar=0
			end 
			else 
			begin 
				set @TempCuitl =reverse(substring(reverse(substring(reverse(@Cuitl), charindex('-',REVERSE(@Cuitl))+1,50)),1,CHARINDEX('-',reverse(substring(reverse(@Cuitl), charindex('-',REVERSE(@Cuitl))+1,50)))-1)+   substring(reverse(substring(reverse(@Cuitl), charindex('-',REVERSE(@Cuitl))+1,50)),charindex('-',reverse(substring(reverse(@Cuitl), charindex('-',REVERSE(@Cuitl))+1,50)))+1,50))

				set @i=1
				set @j=1
				set @suma =0
				while @i<=len (@TempCuitl)
				begin 
					set @suma =@suma+ Cast((substring(@TempCuitl,@i,1)) as int) *Cast((substring(@factmult,@j,1)) as int) 

					 set @i=@i+1
					 set @j=@j+1

					 if @j>6 
						set @j=1
				end 
			end 
		end 
	end 
	
	if Cast(substring(reverse(@Cuitl),1,CHARINDEX('-',reverse(@Cuitl))-1) as int) =11-(@suma % 11)
		set @ResultVar=1

	RETURN @ResultVar
	

END
GO
