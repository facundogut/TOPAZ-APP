EXECUTE('
/****** Object:  StoredProcedure [dbo].[SP_DETERMINACION_TARIFA]    Script Date: 02/06/2021 10:45:55 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
')
EXECUTE('
ALTER procedure [dbo].[SP_DETERMINACION_TARIFA]

  @P_PAQUETE  float,
  @P_CAMPANIA float,
  @P_SEGMENTO float,
  @P_CANAL    float,
  @P_PRODUCTO float,
  @P_MONEDA   float,
  @P_TARIFA   float output,
  @P_CANTIDAD float output

as

begin

  set @P_TARIFA = NULL
  set @P_CANTIDAD = NULL

  declare @V_TARIFA           float,
          @V_CANTIDAD         float,
		  @V_TARIFAENCONTRADA float

  set @V_TARIFA           = 0
  set @V_CANTIDAD         = 0
  set @V_TARIFAENCONTRADA = 0

  begin
  
    select    @V_TARIFA = TARIFA
    from      DETERMINACION_TARIFAS WITH (NOLOCK)
    where     COD_PAQUETE		= @P_PAQUETE
	          AND CAMPANIA		= @P_CAMPANIA
			  AND AGRUPTARIFA	= @P_SEGMENTO
			  AND CANAL			= @P_CANAL
			  AND TZ_LOCK		= 0

    if @@ROWCOUNT = 0
	
	begin
	
	  set @V_TARIFA = 0
	  
	end

  end

--Tasas1
  if @V_TARIFA <> 0
  
    begin
	
	  begin

	    set @V_TARIFAENCONTRADA = @V_TARIFA

	    select    @V_CANTIDAD = count_big(*)
        from      TASAS WITH (NOLOCK)
		where     PRODUCTO    = @P_PRODUCTO
		          and MONEDA  = @P_MONEDA
				  and TARIFA  = @V_TARIFA
				  and TZ_LOCK = 0

	    if @@ROWCOUNT = 0
	    
	    begin
		
		  set @V_TARIFA   = 0
		  set @V_CANTIDAD = 0

	    end
		
	  end
	  
	  if @V_CANTIDAD = 0
	    set @V_TARIFA = 0

    end

-- Tasas1
-- 2o grupo

  if @V_TARIFA = 0
  
    begin
	
	  begin

	    select    @V_TARIFA = TARIFA
        from      DETERMINACION_TARIFAS WITH (NOLOCK)
        where     COD_PAQUETE		= @P_PAQUETE
		          AND CAMPANIA		= @P_CAMPANIA
				  AND AGRUPTARIFA	= @P_SEGMENTO
				  AND CANAL			= @P_CANAL
				  AND TZ_LOCK		= 0

	    if @@ROWCOUNT = 0
	    
	      begin
		  
		    set @V_TARIFA = 0

	      end

	  end

-- Tasas2
  if @V_TARIFA <> 0
  
    begin
	
	  begin
	  
	    set @V_TARIFAENCONTRADA = @V_TARIFA
	    
	    select    @V_CANTIDAD = count_big(*)
	    from      TASAS WITH (NOLOCK)
	    where     PRODUCTO    = @P_PRODUCTO
	              and MONEDA  = @P_MONEDA
				  and TARIFA  = @V_TARIFA
				  and TZ_LOCK = 0

        if @@ROWCOUNT = 0
		
		  begin
		  
		    set @V_TARIFA   = 0
			SET @V_CANTIDAD = 0
	  
	      end

	  end
	  
	  if @V_CANTIDAD = 0
	    set @V_TARIFA = 0

    end

--Tasas2
  end

--3er grupo
  if @V_TARIFA = 0
  
    begin
	
	  begin
		
		select    @V_TARIFA = TARIFA
		from      DETERMINACION_TARIFAS WITH (NOLOCK)
		where     COD_PAQUETE		= @P_PAQUETE
		          AND CAMPANIA		= @P_CAMPANIA
				  AND AGRUPTARIFA	= 0
				  AND CANAL			= @P_CANAL
				  AND TZ_LOCK		= 0

		if @@ROWCOUNT = 0

		  begin
		  
		    set @V_TARIFA = 0

		end

      end

-- Tasas3
	  if @V_TARIFA <> 0
	  
	    begin
		
		  begin
			
			set @V_TARIFAENCONTRADA = @V_TARIFA
			
			select    @V_CANTIDAD = count_big(*)
			from      TASAS WITH (NOLOCK)
			where     PRODUCTO    = @P_PRODUCTO
			          and MONEDA  = @P_MONEDA
					  and TARIFA  = @V_TARIFA
					  and TZ_LOCK = 0
			
			if @@ROWCOUNT = 0
			
			  begin
			
			    set @V_TARIFA   = 0
			    set @V_CANTIDAD = 0
				
		    end

		  end
		  
		    if @V_CANTIDAD = 0
			  set @V_TARIFA = 0

    end
-- Tasas3
  end

-- 4o. grupo
  if @V_TARIFA = 0
	
	begin
	
	  begin
		
		select    @V_TARIFA = DETERMINACION_TARIFAS.TARIFA
		from      DETERMINACION_TARIFAS WITH (NOLOCK)
		where     COD_PAQUETE		= @P_PAQUETE
		          AND CAMPANIA		= @P_CAMPANIA
				  AND AGRUPTARIFA	= 0
				  AND CANAL			= @P_CANAL
				  AND TZ_LOCK		= 0
		
		if @@ROWCOUNT = 0

		  begin
		  
		    set @V_TARIFA = 0

          end
		
    end

-- Tasas4
	  if @V_TARIFA <> 0
	  
	  begin
	  
	    begin

		  set @V_TARIFAENCONTRADA = @V_TARIFA
		  
		  select    @V_CANTIDAD = count_big(*)
		  from      TASAS WITH (NOLOCK)
		  where     PRODUCTO    = @P_PRODUCTO
		            and MONEDA  = @P_MONEDA
					and TARIFA  = @V_TARIFA
					and TZ_LOCK = 0

		  if @@ROWCOUNT = 0

		  begin
		  
		      set @V_TARIFA   = 0
			  set @V_CANTIDAD = 0
			  
		  end
		  
	    end
		
		if @V_CANTIDAD = 0
		  set @V_TARIFA = 0

    end
--Tasas4
  end

      /* 5o. grupo*/
  if @V_TARIFA = 0
  
    begin
	
	  begin
		
		select    @V_TARIFA = TARIFA
		from      DETERMINACION_TARIFAS WITH (NOLOCK)
		where     COD_PAQUETE		= @P_PAQUETE
		          AND CAMPANIA		= 0
				  AND AGRUPTARIFA	= @P_SEGMENTO
				  AND CANAL			= @P_CANAL
				  AND TZ_LOCK		= 0

	    if @@ROWCOUNT = 0
		
		  begin
		  
		    set @V_TARIFA = 0

          end
		
	  end

-- Tasas5

    if @V_TARIFA <> 0
	
	  begin
	  
	    begin
		  
		  set @V_TARIFAENCONTRADA = @V_TARIFA
		  
		  select    @V_CANTIDAD = count_big(*)
		  from      TASAS WITH (NOLOCK)
		  where     PRODUCTO    = @P_PRODUCTO
		            and MONEDA  = @P_MONEDA
					and TARIFA  = @V_TARIFA
					and TZ_LOCK = 0

		  if @@ROWCOUNT = 0
		  
		    begin
			
			  set @V_TARIFA   = 0
			  set @V_CANTIDAD = 0

		    end
			
	    end
		
		if @V_CANTIDAD = 0
		  set @V_TARIFA = 0

	  end
--Tasas5

  end

-- 6o. grupo
  if @V_TARIFA = 0
  
    begin
	
	  begin
		
		select    @V_TARIFA = TARIFA
		from      DETERMINACION_TARIFAS WITH (NOLOCK)
		where     COD_PAQUETE		= @P_PAQUETE
		          AND CAMPANIA		= 0
				  AND AGRUPTARIFA	= @P_SEGMENTO
				  AND CANAL			= @P_CANAL
				  AND TZ_LOCK		= 0

	    if @@ROWCOUNT = 0
		
		  begin
		  
		    SET @V_TARIFA = 0

		  end

	  end

-- Tasas6
    if @V_TARIFA <> 0
	
	  begin
	  
	    begin
		  
		  set @V_TARIFAENCONTRADA = @V_TARIFA
		  
		  select    @V_CANTIDAD = count_big(*)
		  from      TASAS WITH (NOLOCK)
		  where     PRODUCTO    = @P_PRODUCTO
		            and MONEDA  = @P_MONEDA
					and TARIFA  = @V_TARIFA
					and TZ_LOCK = 0

		  if @@ROWCOUNT = 0
		  
		    begin

			  set @V_TARIFA   = 0
			  set @V_CANTIDAD = 0

		    end
			
	    end
		
		if @V_CANTIDAD = 0
		
		  set @V_TARIFA = 0

      end
-- Tasas6

  end

-- 7o.grupo*/

  if @V_TARIFA = 0
  
    begin
	
	  begin
		
		select    @V_TARIFA = TARIFA
		from      DETERMINACION_TARIFAS WITH (NOLOCK)
		where     COD_PAQUETE		= @P_PAQUETE
		          AND CAMPANIA		= 0
				  AND AGRUPTARIFA	= 0
				  AND CANAL			= @P_CANAL
				  AND TZ_LOCK		= 0
				  
	    if @@ROWCOUNT = 0
		
		  begin
		  
		    set @V_TARIFA = 0

	      end

	  end

-- Tasas7*/
    if @V_TARIFA <> 0
	
	  begin
	  
	    begin
		  
		  set @V_TARIFAENCONTRADA = @V_TARIFA
		  
		  select    @V_CANTIDAD = count_big(*)
		  from      TASAS WITH (NOLOCK)
		  where     PRODUCTO    = @P_PRODUCTO
			        and MONEDA  = @P_MONEDA
					and TARIFA  = @V_TARIFA
					and TZ_LOCK = 0

		  if @@ROWCOUNT = 0
		  
		    begin
			
			  set @V_TARIFA   = 0
			  set @V_CANTIDAD = 0

		    end

	    end
		
		if @V_CANTIDAD = 0
		  set @V_TARIFA = 0

      end
-- Tasas7

  end

-- 8o. grupo
  if @V_TARIFA = 0
  
    begin
	
	  begin
		
		select    @V_TARIFA = TARIFA
		from      DETERMINACION_TARIFAS WITH (NOLOCK)
		where     COD_PAQUETE		= @P_PAQUETE
		          AND CAMPANIA		= 0
				  AND AGRUPTARIFA	= 0
				  AND CANAL			= @P_CANAL
				  AND TZ_LOCK		= 0

	    if @@ROWCOUNT = 0
		
		  begin
		  
		    set @V_TARIFA = 0
			
	      end
		  
	  end

-- Tasas8
    if @V_TARIFA <> 0
	
	  begin
	  
	    begin
		  
		  SET @V_TARIFAENCONTRADA = @V_TARIFA
		  
		  select    @V_CANTIDAD = count_big(*)
		  from      TASAS WITH (NOLOCK)
		  where     PRODUCTO    = @P_PRODUCTO
		            and MONEDA  = @P_MONEDA
					and TARIFA  = @V_TARIFA
					and TZ_LOCK = 0
					
		  if @@ROWCOUNT = 0
		  
		    begin
		    
		      set @V_TARIFA   = 0
			  set @V_CANTIDAD = 0
			  
		    end

	    end
		
        if @V_CANTIDAD = 0
	      set @V_TARIFA = 0
		
	  end

-- Tasas8
  end
  
  if @V_TARIFAENCONTRADA <> 0
    set @P_TARIFA = @V_TARIFAENCONTRADA
  else
    set @P_TARIFA = 0
	
  if @V_CANTIDAD <> 0
    set @P_CANTIDAD = @V_CANTIDAD
  else
    set @P_CANTIDAD = 0

end
')