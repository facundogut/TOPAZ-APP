/****** Object:  StoredProcedure [dbo].[SP_ITF_PADFYJ]    Script Date: 01/06/2021 14:05:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[SP_ITF_PADFYJ]  

AS    
   BEGIN   	  
		TRUNCATE TABLE ITF_BCRA_PADFYJ;
		
		DELETE FROM ITF_BCRA_PADFYJ_AUX_PRUEBA 
			WHERE CORRELATIVO NOT IN (
										SELECT MIN(CORRELATIVO)
										FROM ITF_BCRA_PADFYJ_AUX_PRUEBA WITH (NOLOCK)
										GROUP BY CUIT);
		
		INSERT INTO ITF_BCRA_PADFYJ
		SELECT 
				CUIT,
				'',
				(CASE
				  WHEN ltrim(rtrim(substring(texto,161,6))) IS NULL THEN 0
				  ELSE ltrim(rtrim(substring(texto,161,6))) 
				END),		
				(CASE
				  WHEN ltrim(rtrim(substring(texto,179,1))) IS NULL THEN 0
				  ELSE ltrim(rtrim(substring(texto,179,1)))
				END),			
				'',
				'', 
				'', 
				0, 
				ltrim(rtrim(substring(texto,1,150)))
		
		FROM ITF_BCRA_PADFYJ_AUX_PRUEBA	WITH (NOLOCK)	 	 
			
   END