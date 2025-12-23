EXECUTE('
ALTER TABLE CRE_RECIBOACUMULADOR ADD TIPO VARCHAR(1)

ALTER TABLE CRE_SALDOS ALTER COLUMN JURISDICCION VARCHAR(20)

ALTER TABLE CRE_SOLICITUDCREDITO ADD TIPO_CONVENIO NUMERIC (5)

ALTER TABLE CRE_SOLICITUDCREDITO ADD JURISDICCION VARCHAR(20)
')

EXECUTE('
CREATE PROCEDURE dbo.SP_CALCULO_RECIBO
   @P_SOLICITUD numeric(15),
   @P_DOCUMENTO varchar(20)
AS 
   BEGIN

      BEGIN     
      
      	 UPDATE CRE_SOL_RECIBO_SUELDO 
      	 SET HABERES = 0, DESCUENTOS = 0, DEDUCCIONES = 0, LIQUIDO = 0, NETO = 0
      	 WHERE SOLICITUD = @P_SOLICITUD AND DOCUMENTO =  @P_DOCUMENTO AND TZ_LOCK = 0
      	 
         DECLARE
         @LINEA_REG$RECIBO numeric(12), 
         @LINEA_REG$TIPO varchar(1),         
         @LINEA_REG$IMPORTE numeric(15,2)
         
         /*
         *   -----------------------------
         *    CURSOR REGISTROS
         *   -----------------------------
         */                  
         
         DECLARE
             CUR_REGISTROS CURSOR LOCAL FOR 
               	SELECT r.NUMERO_RECIBO, a.TIPO, sum(r.IMPORTE) AS importe
				FROM CRE_SOL_RECIBO_SUELDO_DET r
				INNER JOIN CRE_RECIBOCONCEPTO c ON r.CONCEPTO = c.CODIGO AND c.TZ_LOCK = 0
				INNER JOIN CRE_RECIBOACUMULADOR a ON c.COD_ACUMULADOR = a.CODIGO AND a.TZ_LOCK = 0
				WHERE r.SOLICITUD = @P_SOLICITUD AND r.DOCUMENTO =  @P_DOCUMENTO AND r.TZ_LOCK = 0
				GROUP BY a.TIPO, r.NUMERO_RECIBO

         OPEN CUR_REGISTROS

         WHILE 1 = 1
         
            BEGIN
               FETCH CUR_REGISTROS
                   INTO 
			         @LINEA_REG$RECIBO, 
			         @LINEA_REG$TIPO,         
			         @LINEA_REG$IMPORTE
			         
               IF @@FETCH_STATUS <> 0
               	BREAK
               	
                  
                IF @LINEA_REG$TIPO = ''H''
                	BEGIN
                		UPDATE CRE_SOL_RECIBO_SUELDO SET HABERES = @LINEA_REG$IMPORTE WHERE SOLICITUD = @P_SOLICITUD AND NUMERO_RECIBO = @LINEA_REG$RECIBO AND DOCUMENTO =  @P_DOCUMENTO AND TZ_LOCK = 0
                	END
                IF @LINEA_REG$TIPO = ''D''
                	BEGIN
                		UPDATE CRE_SOL_RECIBO_SUELDO SET DESCUENTOS = @LINEA_REG$IMPORTE WHERE SOLICITUD = @P_SOLICITUD AND NUMERO_RECIBO = @LINEA_REG$RECIBO AND DOCUMENTO =  @P_DOCUMENTO AND TZ_LOCK = 0
                	END
                IF @LINEA_REG$TIPO = ''E''
                	BEGIN
                		UPDATE CRE_SOL_RECIBO_SUELDO SET DEDUCCIONES = @LINEA_REG$IMPORTE WHERE SOLICITUD = @P_SOLICITUD AND NUMERO_RECIBO = @LINEA_REG$RECIBO AND DOCUMENTO =  @P_DOCUMENTO AND TZ_LOCK = 0
                	END                	
            END

         CLOSE CUR_REGISTROS

         DEALLOCATE CUR_REGISTROS

      END

   END
')

EXECUTE('
CREATE PROCEDURE dbo.SP_ACTUALIZA_RECIBO
   @P_SOLICITUD numeric(15),
   @P_DOCUMENTO varchar(20)
AS 
   BEGIN

      BEGIN     
      	 
         DECLARE
         @LINEA_REG$RECIBO numeric(12),         
         @LINEA_REG$IMPORTENETO numeric(15,2),
         @LINEA_REG$IMPORTELIQUIDO numeric(15,2)
         
         /*
         *   -----------------------------
         *    CURSOR REGISTROS
         *   -----------------------------
         */                  
         
         DECLARE
             CUR_REGISTROS CURSOR LOCAL FOR 
				SELECT NUMERO_RECIBO, HABERES - DESCUENTOS AS NETO, HABERES - DESCUENTOS - DEDUCCIONES AS LIQUIDO
				FROM CRE_SOL_RECIBO_SUELDO WHERE SOLICITUD = @P_SOLICITUD AND DOCUMENTO = @P_DOCUMENTO AND TZ_LOCK = 0

         OPEN CUR_REGISTROS

         WHILE 1 = 1
         
            BEGIN
               FETCH CUR_REGISTROS
                   INTO 
			         @LINEA_REG$RECIBO, 
			         @LINEA_REG$IMPORTENETO,         
			         @LINEA_REG$IMPORTELIQUIDO
			         
               IF @@FETCH_STATUS <> 0
               	BREAK
                
                BEGIN
                	UPDATE CRE_SOL_RECIBO_SUELDO SET NETO = @LINEA_REG$IMPORTENETO, LIQUIDO = @LINEA_REG$IMPORTELIQUIDO WHERE SOLICITUD = @P_SOLICITUD AND NUMERO_RECIBO = @LINEA_REG$RECIBO AND DOCUMENTO = @P_DOCUMENTO AND TZ_LOCK = 0
               	END               	
            END

         CLOSE CUR_REGISTROS

         DEALLOCATE CUR_REGISTROS

      END

   END
')


