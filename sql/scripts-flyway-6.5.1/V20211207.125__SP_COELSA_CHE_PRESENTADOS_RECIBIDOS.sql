EXECUTE('DROP PROCEDURE IF EXISTS dbo.SP_COELSA_CHE_PRESENTADOS_RECIBIDOS;')
EXECUTE('
CREATE  PROC  dbo.SP_COELSA_CHE_PRESENTADOS_RECIBIDOS
   @Fecha VARCHAR(50),
   @Arch_Id VARCHAR(20)
 
AS 
BEGIN TRY
	SET NOCOUNT ON;
	
   	DELETE FROM NACHA_CA WHERE Arch_Id = @Arch_Id AND CA_Cor = @Fecha
    DELETE FROM NACHA_CL WHERE Arch_Id = @Arch_Id AND CA_Cor = @Fecha
    DELETE FROM NACHA_RI WHERE Arch_Id = @Arch_Id AND CA_Cor = @Fecha
    DELETE FROM NACHA_RA WHERE Arch_Id = @Arch_Id AND CA_Cor = @Fecha
    DELETE FROM NACHA_FL WHERE Arch_Id = @Arch_Id AND CA_Cor = @Fecha
    DELETE FROM NACHA_FA WHERE Arch_Id = @Arch_Id AND CA_Cor = @Fecha

--variables NACHA_ARCH
DECLARE @T_Arch_Id VARCHAR(10);
DECLARE @T_Arch_Cor NUMERIC(15,0);
DECLARE @T_Correlativo NUMERIC(15,0);
DECLARE @T_Arch_Dat VARCHAR(250);
DECLARE @IdReg VARCHAR(1);

--variables NACHA_CA
DECLARE @T_CA_DI NUMERIC(10,0);
DECLARE @T_CA_OI NUMERIC(10,0);
DECLARE @T_CA_FP DATETIME;
DECLARE @T_CA_HP VARCHAR(6);
DECLARE @T_CA_Ida VARCHAR(1);
DECLARE @T_CA_NDI VARCHAR(23);
DECLARE @T_CA_NOI VARCHAR(23);
DECLARE @T_CA_Ref VARCHAR(8);

--variables NACHA_CL
DECLARE @T_CL_Cor NUMERIC(9,0);
DECLARE @T_CL_DTr VARCHAR(10);
DECLARE @T_CL_FVT DATETIME;
DECLARE @T_CL_IEO NUMERIC(8,0);
DECLARE @T_CL_NrL NUMERIC(7,0);

--variables NACHA_RI
DECLARE @T_RI_Cor NUMERIC(9,0);
DECLARE @T_RI_CTr NUMERIC(2,0);
DECLARE @T_RI_InfAdi VARCHAR(2);
DECLARE @T_RI_EntDC NUMERIC(8,0);
DECLARE @T_RI_Cta NUMERIC(17,0);
DECLARE @T_RI_Imp NUMERIC(15,2);
DECLARE @T_RI_RgAdi NUMERIC(1,0);
DECLARE @T_RI_ContReg NUMERIC(15,0);
DECLARE @T_RI_NroChe NUMERIC(15,0);
DECLARE @T_RI_CodPostal varchar(6);
DECLARE @T_RI_PtoIntercbio varchar(16);

--variables NACHA_RA
DECLARE @RA_TpoReg VARCHAR(2);
DECLARE @RA_Rech VARCHAR(3);
DECLARE @RA_ContROri NUMERIC(15,0);
DECLARE @RA_ETO NUMERIC(8,0);
DECLARE @RA_InfAdi VARCHAR(44);
DECLARE @RA_ContReg NUMERIC(15,0);

--variables NACHA_FL
DECLARE @T_FL_CantRIRA NUMERIC(6,0);
DECLARE @T_FL_TotCtrl NUMERIC(15,2);
DECLARE @T_FL_TotDB NUMERIC(15,2);
DECLARE @T_FL_TotCR NUMERIC(15,2);
DECLARE @T_FL_IdOri NUMERIC(8,0);
DECLARE @T_FL_NL NUMERIC(7,0);

--variables NACHA_FA
DECLARE @T_FA_CantL NUMERIC(6,0);
DECLARE @T_FA_NroB NUMERIC(6,0);
DECLARE @T_FA_CntRIRA NUMERIC(8,0);
DECLARE @T_FA_SumDB NUMERIC(15,2);
DECLARE @T_FA_SumCR NUMERIC(15,2);
DECLARE @T_FA_TotCtrl NUMERIC(10,0);

DECLARE @lote INT = 0;
DECLARE @correlativoRi INT = 0;
DECLARE @correlativoRa INT = 0;

DECLARE CursorUno CURSOR FOR --Declarar el CURSOR
SELECT Arch_Id, Arch_Cor, Correlativo, Arch_Dat 
FROM NACHA_ARCH 
WHERE Arch_Id = @Arch_Id AND Arch_Cor = @Fecha   ----20201007 --Consulta de datos, el resultado será recorrido por el CURSOR
 
OPEN CursorUno --Abrir el CURSOR
    FETCH NEXT FROM CursorUno INTO @T_Arch_Id, @T_Arch_Cor, @T_Correlativo, @T_Arch_Dat --Leer primera fila de la consulta SELECT
 
    WHILE @@FETCH_STATUS = 0 
    	BEGIN
    		SET @IdReg =  SUBSTRING(@T_Arch_Dat, 1, 1) 
    		IF (@IdReg = ''1'')
    			BEGIN
        		   SET @T_CA_DI = SUBSTRING(@T_Arch_Dat, 4, 10)  
        		   SET @T_CA_OI = SUBSTRING(@T_Arch_Dat, 14, 10)        		   
        		   SET @T_CA_FP =  SUBSTRING(@T_Arch_Dat, 24, 6) 
        		   SET @T_CA_HP =  SUBSTRING(@T_Arch_Dat, 30, 4)   
        		   SET @T_CA_Ida =  SUBSTRING(@T_Arch_Dat, 34, 1) 
        		   SET @T_CA_NDI =  SUBSTRING(@T_Arch_Dat, 41, 23)
        		   SET @T_CA_NOI =  SUBSTRING(@T_Arch_Dat, 64, 23) 
        		   SET @T_CA_Ref =  SUBSTRING(@T_Arch_Dat, 87, 8) 
        		   
        		   INSERT INTO NACHA_CA
        		   		(
        		   		Arch_Id, 
        		   		CA_Cor,
        		   		CA_DI,
        		   		CA_OI,
        		   		CA_FP,
        		   		CA_HP,
        		   		CA_Ida,
        		   		CA_NDI,
        		   		CA_NOI,
        		   		CA_Ref
        		   		)                                                      /* delete NACHA_CA */
        		   VALUES
        		   		( 
        		   		@T_Arch_Id, 
        		   		@T_Arch_Cor,
        		   		@T_CA_DI,
        		   		@T_CA_OI,
        		   		@T_CA_FP,
        		   		@T_CA_HP,
        		   		@T_CA_Ida,
        		   		@T_CA_NDI,
        		   		@T_CA_NOI,
        		   		@T_CA_Ref
        		   	    )  
    			END
    		ELSE IF (@IdReg = ''5'')
    			BEGIN
        		    SET @T_CL_Cor = SUBSTRING(@T_Arch_Dat, 88, 7) 
					SET @T_CL_DTr = SUBSTRING(@T_Arch_Dat, 54, 10) 
					SET @T_CL_FVT = SUBSTRING(@T_Arch_Dat, 70, 6)  
					SET @T_CL_IEO = SUBSTRING(@T_Arch_Dat, 80, 8) 
					SET @T_CL_NrL = SUBSTRING(@T_Arch_Dat, 88, 7) 
					SET @lote = @lote + 1
        		    INSERT INTO NACHA_CL
        		   		(
        		   		Arch_Id, 
        		   		CA_Cor,
        		   		CL_Cor,
        		   		CL_DTr,
        		   		CL_FVT,
        		   		CL_IEO,
        		   		CL_NrL 
        		   		)                                                      /* delete NACHA_CL */
        		    VALUES
        		   		( 
        		   		@T_Arch_Id, 
        		   		@T_Arch_Cor,
        		   		@lote,
        		   		@T_CL_DTr,
        		   		@T_CL_FVT,
        		   		@T_CL_IEO,
        		   		@T_CL_NrL
        		   	    )                                               
    			END
    		
    		ELSE IF (@IdReg = ''6'')
    			BEGIN
					SET @T_RI_CTr = SUBSTRING(@T_Arch_Dat, 2, 2)
					SET @T_RI_InfAdi = SUBSTRING(@T_Arch_Dat, 77, 2)
					SET @T_RI_EntDC = SUBSTRING(@T_Arch_Dat, 4, 8)
					SET @T_RI_Cta = SUBSTRING(@T_Arch_Dat, 13, 17)
					SET @T_RI_Imp = SUBSTRING(@T_Arch_Dat, 30, 10)
					SET @T_RI_RgAdi = SUBSTRING(@T_Arch_Dat, 79, 1)
					SET @T_RI_ContReg = SUBSTRING(@T_Arch_Dat, 80, 15)
					SET @T_RI_NroChe = SUBSTRING(@T_Arch_Dat, 40, 15)
					SET @T_RI_CodPostal = SUBSTRING(@T_Arch_Dat, 55, 6)
					SET @T_RI_PtoIntercbio = SUBSTRING(@T_Arch_Dat, 61, 16)
					SET @correlativoRi = @correlativoRi + 1
					
        		    INSERT INTO NACHA_RI 
        		   		(
        		   		Arch_Id, 
        		   		CA_Cor,
        		   		CL_Cor,
        		   		RI_Cor,
        		   		RI_CTr,
        		   		RI_InfAdi,
        		   		RI_EntDC,
        		   		RI_Cta,
        		   		RI_Imp,
        		   		RI_RgAdi,
        		   		RI_ContReg,
        		   		RI_NroChe,
        		   		RI_CodPostal,
        		   		RI_PtoIntercbio
        		   		
        		   		)                                                      /* delete NACHA_RI */
        		    VALUES
        		   		( 
        		   		 @T_Arch_Id, 
        		   		 @T_Arch_Cor,
        		   		 @lote,
        		   		 @correlativoRi, 
						 @T_RI_CTr, 
						 @T_RI_InfAdi, 
						 @T_RI_EntDC, 
				   		 @T_RI_Cta, 
						 @T_RI_Imp, 
						 @T_RI_RgAdi, 
						 @T_RI_ContReg, 
				   		 @T_RI_NroChe, 
						 @T_RI_CodPostal, 
						 @T_RI_PtoIntercbio 
        		   	    )    
        		   	            		   	                                               
    			END;  
    			 		
    		ELSE IF (@IdReg = ''7'' AND @T_RI_RgAdi = ''1'')
    			BEGIN
					SET @RA_TpoReg = SUBSTRING(@T_Arch_Dat, 2, 2)
					SET @RA_Rech = SUBSTRING(@T_Arch_Dat, 4, 3)
					SET @RA_ContROri = SUBSTRING(@T_Arch_Dat, 7, 15)
					SET @RA_ETO = SUBSTRING(@T_Arch_Dat, 28, 8)
					SET @RA_InfAdi = SUBSTRING(@T_Arch_Dat, 36, 4)
					SET @RA_ContReg = SUBSTRING(@T_Arch_Dat, 80, 15)
					SET @correlativoRa = @correlativoRa + 1
					
        		    INSERT INTO NACHA_RA
        		   		(
        		   		Arch_Id, 
        		   		CA_Cor,
        		   		CL_Cor,
        		   		RI_Cor,
        		   		RA_Cor,
        		   		RA_TpoReg,
        		   		RA_Rech,
        		   		RA_ContROri,
        		   		RA_ETO,
        		   		RA_InfAdi,
        		   		RA_ContReg
        		   		)
        		   		                                                      --delete NACHA_RA 
        		    VALUES
        		   		( 
        		   		 @T_Arch_Id, 
        		   		 @T_Arch_Cor,
        		   		 @lote,
        		   		 @correlativoRi, 
        		   		 @correlativoRa,
        		   		 @RA_TpoReg,
        		   		 @RA_Rech,
        		   		 @RA_ContROri,
        		   		 @RA_ETO,
        		   		 @RA_InfAdi,
        		   	     @RA_ContReg
        		   	    )                                               
    			END;	 
    			
    			ELSE IF (@IdReg = ''8'')
    			BEGIN
					SET @T_FL_CantRIRA = SUBSTRING(@T_Arch_Dat, 5, 6)
        		   	SET @T_FL_TotCtrl = SUBSTRING(@T_Arch_Dat, 11, 10)
        		   	SET @T_FL_TotDB = SUBSTRING(@T_Arch_Dat, 21, 12)
        		    SET	@T_FL_TotCR = SUBSTRING(@T_Arch_Dat, 33, 12)
        		   	SET @T_FL_IdOri = SUBSTRING(@T_Arch_Dat, 80, 8)
        		   	SET @T_FL_NL = SUBSTRING(@T_Arch_Dat, 88, 7)
					
        		    INSERT INTO NACHA_FL
        		   		(
        		   		Arch_Id, 
        		   		CA_Cor,
        		   		CL_Cor,
        		   		FL_CantRIRA,
        		   		FL_TotCtrl,
        		   		FL_TotDB,
        		   		FL_TotCR,
        		   		FL_IdOri,
        		   		FL_NL
        		   		)
        		   		                                                      --delete NACHA_FL 
        		    VALUES
        		   		( 
        		   		 @T_Arch_Id, 
        		   		 @T_Arch_Cor,
        		   		 @lote,
        		   		 @T_FL_CantRIRA,
        		   		 @T_FL_TotCtrl,
        		   		 @T_FL_TotDB,
        		   		 @T_FL_TotCR,
        		   		 @T_FL_IdOri,
        		   		 @T_FL_NL
        		   	    )                                              
    			END;   
    			
    			ELSE IF (@IdReg = ''9'')
    			BEGIN
					SET @T_FA_CantL = SUBSTRING(@T_Arch_Dat, 2, 7)
        		   	SET @T_FA_NroB = SUBSTRING(@T_Arch_Dat, 8, 6)
        		   	SET @T_FA_CntRIRA = SUBSTRING(@T_Arch_Dat, 14, 8)
        		    SET	@T_FA_SumDB = SUBSTRING(@T_Arch_Dat, 32, 12)
        		   	SET @T_FA_SumCR = SUBSTRING(@T_Arch_Dat, 44, 12)
        		   	SET @T_FA_TotCtrl = SUBSTRING(@T_Arch_Dat, 22, 10)
					
        		    INSERT INTO NACHA_FA
        		   		(
        		   		Arch_Id, 
        		   		CA_Cor,
        		   		FA_CantL,
        		   		FA_NroB,
        		   		FA_CntRIRA,
        		   		FA_SumDB,
        		   		FA_SumCR,
        		   		FA_TotCtrl
        		   		)
        		   		                                                      --delete NACHA_FA 
        		    VALUES
        		   		( 
        		   		 @T_Arch_Id, 
        		   		 @T_Arch_Cor,
         			 	 @T_FA_CantL,
        		   		 @T_FA_NroB,
        		   		 @T_FA_CntRIRA,
        		         @T_FA_SumDB,
        		   	 	 @T_FA_SumCR,
        		   	 	 @T_FA_TotCtrl  	   		 
        		   	    )                                              
    			END;					
        	FETCH NEXT FROM CursorUno INTO @T_Arch_Id, @T_Arch_Cor, @T_Correlativo, @T_Arch_Dat --Leer la fila siguiente de la consulta SELECT
    	END --Fin del WHILE
    	
CLOSE CursorUno --Cerrar el CURSOR
DEALLOCATE CursorUno --Liberar recursos


   
END TRY 

BEGIN CATCH
	Print error_message()
END CATCH;')

