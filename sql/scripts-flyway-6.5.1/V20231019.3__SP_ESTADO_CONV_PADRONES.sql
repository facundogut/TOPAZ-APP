EXECUTE('
CREATE OR ALTER PROCEDURE SP_ESTADO_CONV_PADRONES
   @P_ID_TICKET             NUMERIC(10),
   @P_CONVENIO	            NUMERIC(15),
   @P_ESTADO                VARCHAR(1),
   @P_OPCION				VARCHAR(1),	
   @P_ASIENTO				NUMERIC(7),
   @P_RESULTADO             VARCHAR(5) OUTPUT
   
AS 

   BEGIN
   
     SET @P_RESULTADO = ''ERROR''
     
     DECLARE @P_ENTE NUMERIC(15)
     
     SELECT @P_ENTE = COD_ENTE FROM CONV_REL_ENTECONV WHERE ID_CONVREC =@P_CONVENIO
     
          
    BEGIN 
      IF @P_ESTADO = ''P'' AND @P_OPCION = ''A''
      
	      UPDATE CONV_PADRONES
	         SET ESTADO = ''C'',
	             REF_TOPAZ = @P_ASIENTO
	       WHERE CONVENIO = @P_ENTE 
			 AND id_ticket = @P_ID_TICKET
	       
	      SET @P_RESULTADO = ''OK''
      
    END
    
    BEGIN 
      IF @P_ESTADO = ''P'' AND @P_OPCION = ''R''
      
	      UPDATE CONV_PADRONES
	         SET ESTADO = ''R'',
	             REF_TOPAZ = @P_ASIENTO
	       WHERE CONVENIO = @P_ENTE 
			 AND id_ticket = @P_ID_TICKET
	       
	      SET @P_RESULTADO = ''OK''
      
    END
    
     BEGIN 
      IF @P_ESTADO = ''C'' AND @P_OPCION = ''P''
      
          UPDATE CONV_PADRONES
	         SET ESTADO = ''P'',
	             REF_TOPAZ = @P_ASIENTO
	       WHERE CONVENIO = @P_ENTE 
			 AND id_ticket = @P_ID_TICKET
	       
	      SET @P_RESULTADO = ''OK''
        END
        
        BEGIN IF @P_ESTADO = ''R'' AND @P_OPCION = ''P'' 
      
	      UPDATE CONV_PADRONES
	         SET ESTADO = ''P'',
	             REF_TOPAZ = @P_ASIENTO
	       WHERE CONVENIO = @P_ENTE 
			 AND id_ticket = @P_ID_TICKET
	       
	      SET @P_RESULTADO = ''OK''
        END
    END

')
