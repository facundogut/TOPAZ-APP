CREATE OR ALTER       PROCEDURE [dbo].[MIG_CASTIGADORTARJETERO]

/*********************************************************************************
Modulo  : CUENTASVISTA
Tabla   : SALDOS
Version : 22/08/2024 
Tarea   : MIGNBCAR-2651
***********************************************************************************/

@P_ID_PROCESO INT,
@P_DT_PROCESO DATE,

@P_RET_PROCESO INT OUTPUT,
@P_MSG_PROCESO VARCHAR(500) OUTPUT

AS
BEGIN


----------Definicion Variables Intermedias----

DECLARE @p_MODULO VARCHAR(30)
DECLARE @v_FECHASYS datetime
DECLARE @p_NomScr VARCHAR(30)
DECLARE @v_CICLO smallint
DECLARE @v_PROCESO smallint

DECLARE @v_CANT_FINAL numeric(8)

--------------------------------------------
SET @v_FECHASYS=SYSDATETIME()
SET @v_CICLO = 1
SET @v_PROCESO = 1
SET @p_MODULO = 'CUENTASVISTA'
SET @p_NomScr = 'CASTIGADOR'
--


--Contabilizo
	SELECT @v_CANT_FINAL=count(*)
	FROM SALDOS S
		INNER JOIN CargaCL0004 CL ON S.C1803 = CL.CODIGOCLIENTE
		INNER JOIN PRODUCTOS p ON p.C6250 = s.PRODUCTO
	WHERE p.C6800 = 'T' AND CL.MARCA_OC='S';
--

--Castigo
	UPDATE s
	SET s.C1734 = 'C',
		s.C1728 = 'C'
	FROM SALDOS s
	INNER JOIN CargaCL0004 CL ON S.C1803 = CL.CODIGOCLIENTE
	INNER JOIN PRODUCTOS p ON p.C6250 = s.PRODUCTO
	WHERE p.C6800 = 'T' AND CL.MARCA_OC = 'S';
--


---
	 SET @P_RET_PROCESO = 1
	 SET @P_MSG_PROCESO = 'CASTIGADOS CON EXITO.' + STR(@v_CANT_FINAL)
---	 


   BEGIN TRANSACTION
		INSERT INTO MIG_RESULTADOS
					(CICLO, PROCESO, MODULO, FECHAINICIO, FECHAFIN, ESTADO, ERRORES, MENSAJE, ARCHIVO)
				VALUES
				   (@v_CICLO,
					@v_PROCESO,
					@p_MODULO,
					@v_FECHASYS,
					SYSDATETIME(),
					'A',
					'N', 
				        'OK',
					@p_NomScr)
		COMMIT;


END;


