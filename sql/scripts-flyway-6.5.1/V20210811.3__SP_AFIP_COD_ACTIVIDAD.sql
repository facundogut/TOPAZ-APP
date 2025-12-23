EXECUTE('DROP PROCEDURE IF EXISTS dbo.SP_AFIP_COD_ACTIVIDAD;')
EXECUTE('CREATE PROCEDURE dbo.SP_AFIP_COD_ACTIVIDAD @codigo AS VARCHAR(12), @cod_validado VARCHAR(12) OUTPUT  
AS  
BEGIN  
   
 SET @cod_validado = RIGHT (''000000''+ @codigo, 6);  
  
    PRINT @cod_validado;     
END;')
