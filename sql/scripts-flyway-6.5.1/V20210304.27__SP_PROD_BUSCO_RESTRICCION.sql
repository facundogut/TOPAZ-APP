

/****** Object:  StoredProcedure [dbo].[SP_PROD_BUSCO_RESTRICCION]    Script Date: 23/02/2021 14:15:31 ******/
DROP PROCEDURE [dbo].[SP_PROD_BUSCO_RESTRICCION]
GO

/****** Object:  StoredProcedure [dbo].[SP_PROD_BUSCO_RESTRICCION]    Script Date: 23/02/2021 14:15:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_PROD_BUSCO_RESTRICCION]
@p_jts_oid    float, /*jts_oid de la cta. */ --YA
@p_importe    float, /*Importe del Movimiento o Saldo */
@p_operacion  float, /*Numero de operación */
@p_tipRestric varchar, /* Tipo de retriccion C Credito y D para debito*/
@p_tipBloqueo varchar output, /*Tipo de Bloqueo (A - Advertencia / B - Bloqueo) */
@p_mensaje    VARCHAR(80) OUTPUT, /*Mensaje a mostrar al usuario*/
@p_Importe_Total numeric(15,2) OUTPUT  /*Importe hasta el momento*/
AS
BEGIN

/*Declaración de variables de trabajo*/
DECLARE @v_CODPRODUCTO NUMERIC(5),
		@v_TIPO_RESTRICCION varchar(1), 
		@v_TIPO_CONTROL varchar(1),
		@v_TIPO_LIMITE varchar(1),
		@v_FORMA_APLICACION varchar(1),
		@v_JTS_OID numeric(10),
		@v_TIPO_BLOQUEO varchar(1) ,
		@v_MENSAJE varchar(80),
		@v_Suma_Total numeric(15,2),
		@v_SALDO numeric(15,2),
		@v_IMPORTE_LIMITE numeric(15,2),
		@v_anio numeric(4) = 0, 
		@v_mes NUMERIC(2)= 0,
		@v_SalidaTipBloqueo  varchar(1)=' ' , 
		@v_SalidaMensaje varchar(80) = ' ',
		@v_fechaSistema DATETIME,
		@v_anio2 VARCHAR(4)

/*Obtengo la fecha de sistema para filtra por mes y dia.*/
SELECT @v_fechaSistema=FECHAPROCESO 
FROM PARAMETROS with (nolock)

--SET @v_anio=DATEPART(year, GETDATE())
--SET @v_mes=DATEPART(month, GETDATE())

SET @v_anio=DATEPART(year, @v_fechaSistema)
SET @v_mes=DATEPART(month, @v_fechaSistema)

/*DECLARACION DE CUSORES*/

/*Declaracion de query de retricciones diarias.*/
DECLARE c_diario CURSOR LOCAL FOR 
		SELECT 
				CODPRODUCTO,
				TIPO_RESTRICCION,
				TIPO_CONTROL,
				TIPO_LIMITE,
				FORMA_APLICACION,
				JTS_OID,
				TIPO_BLOQUEO,
				MENSAJE,
				Suma_Total,
				SALDO,
				IMPORTE_LIMITE
		FROM	( 
				SELECT
					res.CODPRODUCTO,res.TIPO_RESTRICCION,
					res.TIPO_CONTROL,res.TIPO_LIMITE,res.FORMA_APLICACION,
					sal.JTS_OID,res.TIPO_BLOQUEO,res.MENSAJE,SAL.C1604 SALDO,
					ISNULL(SUM(CONT.IMPORTE_MOVIMIENTOS),0) Suma_Total,res.IMPORTE_LIMITE
				FROM SALDOS sal with (nolock)
				INNER JOIN PROD_RESTRICCIONES res with (nolock) ON sal.PRODUCTO = res.CODPRODUCTO 
														AND sal.MONEDA = res.MONEDA 
														AND res.TZ_LOCK = 0
				LEFT JOIN GRL_CONT_DIARIO_MOV cont with (nolock) ON sal.JTS_OID = cont.SALDOS_JTS_OID 
														AND cont.TZ_LOCK = 0 
														AND (CONVERT(varchar,cont.fecha,101)) in (CONVERT(varchar,(@v_fechaSistema),101))		
				LEFT JOIN CODIGO_TRANSACCIONES codtr with (nolock) on codtr.CODIGO_OPERACION= @p_operacion 
														AND codtr.CODIGO_TRANSACCION=cont.CODIGO_TRANSACCION
				WHERE (res.FORMA_APLICACION = 'T' --Validacion de exclusion o inclusion de codigos de trasaccion 
						OR (res.FORMA_APLICACION = 'I' AND CHARINDEX(',' + CONVERT(VARCHAR,cont.CODIGO_TRANSACCION) + ',', ',' + res.DETALLE_CODIGOS + ',') > 0
							AND CHARINDEX(','+ CONVERT(VARCHAR, codtr.CODIGO_TRANSACCION)+',',','+res.DETALLE_CODIGOS+ ',') > 0)
						OR (res.FORMA_APLICACION = 'E' AND CHARINDEX(',' + CONVERT(VARCHAR,cont.CODIGO_TRANSACCION) + ',', ',' + res.DETALLE_CODIGOS + ',') = 0
							AND CHARINDEX(','+ CONVERT(VARCHAR, codtr.CODIGO_TRANSACCION)+',',','+res.DETALLE_CODIGOS+ ',') = 0))		
						AND isnull(res.TIPO_RESTRICCION,' ')= isnull(@p_tipRestric,' ')
						AND res.TIPO_LIMITE= 'D' --Diaria
						AND sal.TZ_LOCK=0  
						AND res.TZ_LOCK=0  
						AND SAL.JTS_OID=@p_jts_oid
				GROUP by	res.CODPRODUCTO,
							res.TIPO_RESTRICCION,
							res.TIPO_CONTROL,
							res.TIPO_LIMITE,
							res.TIPO_BLOQUEO,
							res.FORMA_APLICACION,
							res.TIPO_BLOQUEO,
							res.MENSAJE,
							sal.JTS_OID,
							SAL.C1604,
							res.IMPORTE_LIMITE 
				) z
		where ((TIPO_CONTROL='M' 
				and IMPORTE_LIMITE<=Suma_Total + @p_importe) 
				or (TIPO_CONTROL='S' and IMPORTE_LIMITE<=(SALDO) + @p_importe)) 
		ORDER BY TIPO_BLOQUEO desc

/*Declaracion de query de retricciones mensual.*/
DECLARE c_mensual CURSOR LOCAL FOR 
		SELECT 
			CODPRODUCTO,
			TIPO_RESTRICCION,
			TIPO_CONTROL,
			TIPO_LIMITE,
			FORMA_APLICACION,
			JTS_OID,
			TIPO_BLOQUEO,
			MENSAJE,
			Suma_Total,
			SALDO,
			IMPORTE_LIMITE,
			ANIO
		FROM ( 
				SELECT 
					res.CODPRODUCTO,res.TIPO_RESTRICCION,res.TIPO_CONTROL,res.TIPO_LIMITE,res.FORMA_APLICACION,
					sal.JTS_OID,res.TIPO_BLOQUEO,res.MENSAJE,SAL.C1604 SALDO,ISNULL(CONT.IMPORTE_MOVIMIENTOS,0) Suma_Total,res.IMPORTE_LIMITE,
					cont.ANIO
				FROM SALDOS sal with (nolock)
				INNER JOIN PROD_RESTRICCIONES res with (nolock) ON sal.PRODUCTO = res.CODPRODUCTO
																	AND sal.MONEDA = res.MONEDA 
																	AND res.TZ_LOCK = 0
				LEFT JOIN GRL_CONTADOR_MOVIMIENTOS cont with (nolock) ON cont.SALDOS_JTS_OID = sal.JTS_OID  
																	and anio=@v_anio 
																	and mes=@v_mes  
																	AND cont.TZ_LOCK = 0
				LEFT JOIN CODIGO_TRANSACCIONES codtr with (nolock) on codtr.CODIGO_OPERACION= @p_operacion 
																	AND codtr.CODIGO_TRANSACCION=cont.CODIGO_TRANSACCION
				WHERE (res.FORMA_APLICACION = 'T' --Validacion de exclusion o inclusion de codigos de trasaccion 
						OR (res.FORMA_APLICACION = 'I' AND CHARINDEX(',' + CONVERT(VARCHAR,cont.CODIGO_TRANSACCION) + ',', ',' + res.DETALLE_CODIGOS + ',') > 0
							AND CHARINDEX(','+ CONVERT(VARCHAR, codtr.CODIGO_TRANSACCION)+',',','+res.DETALLE_CODIGOS+ ',') > 0)
						OR (res.FORMA_APLICACION = 'E' AND CHARINDEX(',' + CONVERT(VARCHAR,cont.CODIGO_TRANSACCION) + ',', ',' + res.DETALLE_CODIGOS + ',') = 0
							AND CHARINDEX(','+ CONVERT(VARCHAR, codtr.CODIGO_TRANSACCION)+',',','+res.DETALLE_CODIGOS+ ',') = 0))
						AND isnull(res.TIPO_RESTRICCION,' ')= isnull(@p_tipRestric,' ')
						AND res.TIPO_LIMITE= 'M' -- Mensual
						AND sal.TZ_LOCK=0
						AND res.TZ_LOCK=0  
						AND SAL.JTS_OID=@p_jts_oid
				GROUP by	res.CODPRODUCTO,
							res.TIPO_RESTRICCION,
							res.TIPO_CONTROL,
							res.TIPO_LIMITE,
							res.TIPO_BLOQUEO,
							res.FORMA_APLICACION,
							res.TIPO_BLOQUEO,
							res.MENSAJE,
							sal.JTS_OID,
							SAL.C1604,
							res.IMPORTE_LIMITE,
							IMPORTE_MOVIMIENTOS ,
							cont.ANIO
				) z
		where ((TIPO_CONTROL='M' and IMPORTE_LIMITE<=Suma_Total + @p_importe) or (TIPO_CONTROL='S' and IMPORTE_LIMITE<=(SALDO) + @p_importe)
				OR ANIO IS NOT NULL)
		ORDER BY TIPO_BLOQUEO desc

/*Declaracion de query de retricciones por operación.*/
DECLARE c_ope CURSOR LOCAL FOR 
		SELECT 
		CODPRODUCTO,
		TIPO_RESTRICCION,
		TIPO_CONTROL,
		TIPO_LIMITE,
		FORMA_APLICACION,
		JTS_OID,
		TIPO_BLOQUEO,
		MENSAJE,
		Suma_Total,
		SALDO,
		IMPORTE_LIMITE
		FROM ( 
				SELECT 
						res.CODPRODUCTO,res.TIPO_RESTRICCION,res.TIPO_CONTROL,res.TIPO_LIMITE,res.FORMA_APLICACION,
						sal.JTS_OID,res.TIPO_BLOQUEO,res.MENSAJE,SAL.C1604 SALDO, @p_importe Suma_Total,res.IMPORTE_LIMITE
				FROM SALDOS sal with (nolock)
				INNER JOIN PROD_RESTRICCIONES res with (nolock) ON sal.PRODUCTO = res.CODPRODUCTO 
																	AND sal.MONEDA = res.MONEDA 
																	AND res.TZ_LOCK = 0
				INNER JOIN CODIGO_TRANSACCIONES codtr with (nolock) on codtr.CODIGO_OPERACION= @p_operacion 
				WHERE (res.FORMA_APLICACION = 'T' --Validacion de exclusion o inclusion de codigos de trasaccion 
						OR (res.FORMA_APLICACION = 'I' AND CHARINDEX(',' + CONVERT(VARCHAR,codtr.CODIGO_TRANSACCION) + ',', ',' + res.DETALLE_CODIGOS + ',') > 0)
						OR (res.FORMA_APLICACION = 'E' AND CHARINDEX(',' + CONVERT(VARCHAR,codtr.CODIGO_TRANSACCION) + ',', ',' + res.DETALLE_CODIGOS + ',') = 0))
						AND isnull(res.TIPO_RESTRICCION,' ')= isnull(@p_tipRestric,' ')
						AND res.TIPO_LIMITE= 'O' --Por  Operacion 
						AND sal.TZ_LOCK=0  
						AND res.TZ_LOCK=0  
						AND SAL.JTS_OID=@p_jts_oid
				GROUP by	res.CODPRODUCTO,
							res.TIPO_RESTRICCION,
							res.TIPO_CONTROL,
							res.TIPO_LIMITE,
							res.TIPO_BLOQUEO,
							res.FORMA_APLICACION,
							res.TIPO_BLOQUEO,
							res.MENSAJE,sal.JTS_OID,
							SAL.C1604,
							res.IMPORTE_LIMITE
			) z
		where	(TIPO_CONTROL='M' and IMPORTE_LIMITE<=Suma_Total ) 
				or (TIPO_CONTROL='S' and IMPORTE_LIMITE<=(SALDO+Suma_Total)) 
		ORDER BY TIPO_BLOQUEO desc

/*---EJECUCION DE CURSORES---*/ 
/*
La prioridad para la ejecución  es primero las retricciones diarias, luego las mensuales y las de por operación.
- Si en una de las ejecuciones se encontrará un bloqueo se cortará las ejecuciones y se retornara el tipo de Bloqueo B y el mensaje relacionado.
- Si solo se encontrará Advertencias se retornara la primera interación.
- La logica seguirá ejecutando los cursores siempre y cuando no encuentre bloqueos en el retorno.
- Si no existira restriciones se devolvera el campo tipo de Bloque vacio y en el mensaje retornara NO EXISTE RESTRICCIONES PARA ESTOS PARAMETROS.
*/ 

--Ejecución del curso de Diario
OPEN c_diario
FETCH c_diario INTO @v_CODPRODUCTO ,
	@v_TIPO_RESTRICCION , 
	@v_TIPO_CONTROL ,
	@v_TIPO_LIMITE ,
	@v_FORMA_APLICACION ,
	@v_JTS_OID ,
	@v_TIPO_BLOQUEO ,
	@v_MENSAJE,
	@v_Suma_Total,
	@v_SALDO,
	@v_IMPORTE_LIMITE
CLOSE c_diario
DEALLOCATE c_diario

--Guardamos la primera interación de para comparara en las siguientes ejecuciones
 Begin
	SET @v_SalidaTipBloqueo =@v_TIPO_BLOQUEO -- si el valor es B se retorna estos dos valores como parametros de salida en el sp.
	SET @v_SalidaMensaje=@v_MENSAJE
end 	
 
--Ejecución del curso de Mensual
--Verificamos que el valor de @v_TIPO_BLOQUEO se A, Si es A seguimos buscamos Si es B retornamos el valor como parametro de salida.
IF (ISNULL(@v_TIPO_BLOQUEO,' ')like 'A'  or ISNULL(@v_TIPO_BLOQUEO,' ')like ' ' )
		BEGIN
		OPEN c_mensual
		FETCH c_mensual INTO @v_CODPRODUCTO ,
			@v_TIPO_RESTRICCION , 
			@v_TIPO_CONTROL ,
			@v_TIPO_LIMITE ,
			@v_FORMA_APLICACION ,
			@v_JTS_OID ,
			@v_TIPO_BLOQUEO ,
			@v_MENSAJE,
			@v_Suma_Total,
			@v_SALDO,
			@v_IMPORTE_LIMITE,
			@v_anio2
		CLOSE c_mensual
		DEALLOCATE c_mensual
		
		--Guardamos la primera interación de para comparara en las siguientes ejecuciones
 Begin
	SET @v_SalidaTipBloqueo =@v_TIPO_BLOQUEO -- si el valor es B se retorna estos dos valores como parametros de salida en el sp.
	SET @v_SalidaMensaje=@v_MENSAJE
end 

		--Comparamos si la restricción encontrada es B para asignarlo a las variables de retorno del sp
		IF (ISNULL(@v_TIPO_BLOQUEO,' ')like 'B' or ISNULL(@v_TIPO_BLOQUEO,' ')like' ' )
		Begin
			SET @v_SalidaTipBloqueo =@v_TIPO_BLOQUEO
			SET @v_SalidaMensaje=@v_MENSAJE
		end 
		PRINT 'ACÁ ESTAMOS EN MENSUAL'
PRINT @v_TIPO_BLOQUEO
PRINT @v_SalidaMensaje
END


--Ejecución del curso por Operación
--Verificamos que el valor de @v_TIPO_BLOQUEO se A, Si es A seguimos buscamos Si es B retornamos el valor como parametro de salida.
IF (ISNULL(@v_TIPO_BLOQUEO,' ')like'A' or ISNULL(@v_TIPO_BLOQUEO,' ')like' ' )
BEGIN
		OPEN c_ope
		FETCH c_ope INTO @v_CODPRODUCTO ,
			@v_TIPO_RESTRICCION , 
			@v_TIPO_CONTROL ,
			@v_TIPO_LIMITE ,
			@v_FORMA_APLICACION ,
			@v_JTS_OID ,
			@v_TIPO_BLOQUEO ,
			@v_MENSAJE,
			@v_Suma_Total,
			@v_SALDO,
			@v_IMPORTE_LIMITE
		CLOSE c_ope
		DEALLOCATE c_ope
		
		--Guardamos la primera interación de para comparara en las siguientes ejecuciones
 Begin
	SET @v_SalidaTipBloqueo =@v_TIPO_BLOQUEO -- si el valor es B se retorna estos dos valores como parametros de salida en el sp.
	SET @v_SalidaMensaje=@v_MENSAJE
end 
	
	--Comparamos si la restricción encontrada es B para asignarlo a las variables de retorno del sp
	IF (ISNULL(@v_TIPO_BLOQUEO,' ')like 'B' or ISNULL(@v_TIPO_BLOQUEO,' ')like' ' )
		Begin
			SET @v_SalidaTipBloqueo =@v_TIPO_BLOQUEO
			SET @v_SalidaMensaje=@v_MENSAJE
		end 
END 

/*VALIDACION DE LAS VARIABLES DE RETORNO*/
--Validamos no se encontro nada en las ejecuciones 
IF @v_TIPO_BLOQUEO IS NULL 
BEGIN
	SET @p_tipBloqueo = ' '
	SET @p_mensaje  = 'NO EXISTE RESTRICCIONES PARA ESTOS PARAMETROS'  
END
ELSE
--Retornamos el tipo de bloqueo y el mensaje encontrado.
BEGIN 
	SET @p_tipBloqueo = @v_SalidaTipBloqueo
	SET @p_mensaje  = @v_SalidaMensaje  
	SET @p_Importe_Total  = @v_Suma_Total  
END



END;;;
GO


