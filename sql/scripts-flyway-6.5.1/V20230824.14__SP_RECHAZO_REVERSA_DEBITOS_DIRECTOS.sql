EXECUTE('
CREATE OR ALTER PROCEDURE SP_RECHAZO_REVERSA_DEBITOS_DIRECTOS
   
   @SUCURSAL  NUMERIC(5),
   @P_ESTADO  VARCHAR(1),
   @CANTIDAD  NUMERIC(12) OUTPUT,
   @RESPUESTA VARCHAR(6) OUTPUT
  
    
   
  AS 
   BEGIN

      BEGIN     
         
      	 
         DECLARE
         
          
         
         @FECHA_ESTADO DATETIME
         
         SELECT @FECHA_ESTADO = FECHAPROCESO FROM PARAMETROS 
         
         IF @P_ESTADO = ''R'' 
          BEGIN 
           
           SELECT @CANTIDAD = count(*) FROM SNP_DEBITOS
            WHERE ESTADO = ''PP'' 
              AND SALDO_JTS_OID IN (SELECT JTS_OID 
                                      FROM saldos 
                                     WHERE TZ_LOCK = 0 
                                       AND SUCURSAL = @SUCURSAL) 
              AND TZ_LOCK = 0;
          
          
           UPDATE SNP_DEBITOS
              SET ESTADO         = ''RC'',
                  FECHA_ESTADO   = @FECHA_ESTADO,
                  MOTIVO_RECHAZO = ''R93''
            WHERE ESTADO = ''PP'' 
              AND SALDO_JTS_OID IN (SELECT JTS_OID 
                                      FROM saldos 
                                     WHERE TZ_LOCK = 0 
                                       AND SUCURSAL = @SUCURSAL) 
              AND TZ_LOCK = 0; 
              
              SET @RESPUESTA =''A''
                   
          END
          
          IF @P_ESTADO = ''P'' 
          BEGIN 
           
           SELECT @CANTIDAD = count(*) FROM SNP_DEBITOS
            WHERE ESTADO = ''RC'' 
              AND SALDO_JTS_OID IN (SELECT JTS_OID 
                                      FROM saldos 
                                     WHERE TZ_LOCK = 0 
                                       AND SUCURSAL = @SUCURSAL) 
              AND TZ_LOCK = 0
              AND FECHA_ESTADO = @FECHA_ESTADO;
          
           UPDATE SNP_DEBITOS
              SET ESTADO         = ''PP'',
                  FECHA_ESTADO   = NULL,
                  MOTIVO_RECHAZO = NULL
            WHERE ESTADO = ''RC'' 
              AND SALDO_JTS_OID IN (SELECT JTS_OID 
                                      FROM saldos 
                                     WHERE TZ_LOCK = 0 
                                       AND SUCURSAL = @SUCURSAL) 
              AND TZ_LOCK = 0
              AND FECHA_ESTADO = @FECHA_ESTADO; 
              SET @RESPUESTA =''B''     
          END
          
         

      END

   END
')
