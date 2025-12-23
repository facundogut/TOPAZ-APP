EXECUTE('



CREATE OR ALTER FUNCTION Fn_NumberToWords (@Number as BIGINT)

    RETURNS VARCHAR(1024)

AS

BEGIN
    -- Crear tablas temporales para guardar numeros y palabras especificas
      DECLARE @Below20 TABLE (ID int identity(0,1), Word varchar(32))
      DECLARE @Below100 TABLE (ID int identity(2,1), Word varchar(32))
      DECLARE @Below1000 TABLE (ID int identity(1,1), Word varchar(32))
    -- Insertar los numero del 0 al 19 en la primera tabla
      INSERT @Below20 (Word) VALUES
                        ( ''cero''), (''uno''),( ''dos'' ), ( ''tres''),
                        ( ''cuatro'' ), ( ''cinco'' ), ( ''seis'' ), ( ''siete'' ),
                        ( ''ocho''), ( ''nueve''), ( ''diez''), ( ''once'' ),
                        ( ''doce'' ), ( ''trece'' ), ( ''catorce''),
                        ( ''quince'' ), (''dieciseis'' ), ( ''diecisiete''),
                        (''dieciocho'' ), ( ''diecinueve'' )
    -- Insertar los multiplos de 10 hasta el 90 en la segunda tabla
       INSERT @Below100 VALUES (''veinte''), (''treinta''),(''cuarenta''), (''cincuenta''),
                               (''sesenta''), (''setenta''), (''ochenta''), (''noventa'')
    -- Inserte los multiplos de 100 hasta el 900 en la tercera tabla
       INSERT @Below1000 VALUES (''ciento''), (''docientos''), (''trecientos''), (''cuatrocientos''),
                               (''quinientos''), (''seiscientos''), (''setecientos''), (''cchocientos'') , (''novecientos'')

DECLARE @Words varchar(1024) =
(

  SELECT CASE
    WHEN @Number = 0 THEN  ''''

    WHEN @Number BETWEEN 1 AND 19
      THEN (SELECT Word FROM @Below20 WHERE ID=@Number)

    WHEN @Number BETWEEN 20 AND 99  
     THEN CASE WHEN @Number BETWEEN 21 AND 29
               THEN ''veinti'' + dbo.fn_NumberToWords( @Number % 10)
               WHEN @Number%10 = 0
               THEN (SELECT Word FROM @Below100 WHERE ID=@Number/10)
               ELSE (SELECT Word FROM @Below100 WHERE ID=@Number/10)+ '' y '' +
               dbo.fn_NumberToWords( @Number % 10)
           END

   WHEN @Number BETWEEN 100 AND 999  
     THEN  CASE WHEN @Number = 100 
                THEN ''cien'' 
                ELSE (SELECT Word FROM @Below1000 WHERE ID=@Number/100)+'' ''+
                dbo.fn_NumberToWords( @Number % 100)
           END

   WHEN @Number BETWEEN 1000 AND 999999  
     THEN  CASE WHEN @Number BETWEEN 1000 AND 1199 
                THEN ''mil '' + dbo.fn_NumberToWords( @Number % 1000) 
                ELSE (dbo.fn_NumberToWords( @Number / 1000))+'' mil ''+
                dbo.fn_NumberToWords( @Number % 1000) 
           END

   WHEN @Number BETWEEN 1000000 AND 999999999  
     THEN CASE WHEN @Number BETWEEN 1000000 AND 1999999 
               THEN ''Un Million ''+
                    dbo.fn_NumberToWords( @Number % 1000000)
               ELSE (dbo.fn_NumberToWords( @Number / 1000000))+'' milliones ''+
                    dbo.fn_NumberToWords( @Number % 1000000)
          END

   WHEN @Number BETWEEN 1000000000 AND 999999999999  
    THEN  (dbo.fn_NumberToWords( @Number / 1000000000))+'' billion ''+
         dbo.fn_NumberToWords( @Number % 1000000000)
   ELSE ''NUMERO INVALIDO'' 
   END
)

SELECT @Words = RTRIM(@Words)
SELECT @Words = RTRIM(LEFT(@Words,len(@Words)-1))
                 WHERE RIGHT(@Words,1)=''-''
RETURN (@Words)
END

')
