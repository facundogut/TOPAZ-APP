EXECUTE('

ALTER PROCEDURE [SP_RETORNO_CB] 
								   @CODIGO_BARRAS       varchar(max),
								   @P_RETORNO varchar(max)  OUTPUT
   
AS 

   BEGIN

      DECLARE

         @CANTIDAD NUMERIC(15)
         
         SELECT @CANTIDAD = count(*) 
		 FROM CONV_CB_ESTRUCTURA WITH (NOLOCK)
		 WHERE LARGO=len(@CODIGO_BARRAS) 
			AND ID_REFERENCIA = substring(@CODIGO_BARRAS,1,LARGO_ID)
            AND TZ_LOCK = 0
   		 IF	@CANTIDAD= 0
   		 	SET @P_RETORNO = ''E''
      
      	 ELSE
      	 	
      	 	IF @CANTIDAD= 1	
      	 	      	 		
      	 	  SELECT @P_RETORNO = ID_REFERENCIA 
			  FROM CONV_CB_ESTRUCTURA WITH (NOLOCK)
			  WHERE LARGO=len(@CODIGO_BARRAS) 
				AND ID_REFERENCIA = substring(@CODIGO_BARRAS,1,LARGO_ID)
      	 	  	AND TZ_LOCK = 0
      	 ELSE
      	 	
			SET @P_RETORNO = ''M''
	
	END
')