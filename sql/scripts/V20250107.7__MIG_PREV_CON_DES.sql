EXECUTE('
CREATE OR ALTER                                PROCEDURE [dbo].[MIG_PREV_CON_DES]

(@p_id_proceso INT,
@p_dt_proceso DATE,
@p_ret_proceso INT OUTPUT,
@p_msg_proceso VARCHAR(500) OUTPUT)
/*********************************************************************************
Modulo  : PRESTAMOS
Tabla   : BS_HISTORIA_PLAZO 
Version : 7/10/2024 
***********************************************************************************/


 
AS
BEGIN


----------Definicion Variables Intermedias----

DECLARE @p_MODULO VARCHAR(30)
DECLARE @v_FECHASYS datetime
DECLARE @p_NomScr VARCHAR(30)
DECLARE @v_CICLO smallint
DECLARE @v_PROCESO smallint

--------------------------------------------
SET @v_FECHASYS=SYSDATETIME()
SET @v_CICLO = 1
SET @v_PROCESO = 1
SET @p_MODULO = ''PRESTAMOS''
SET @p_NomScr = ''PREV_CON_DES''

-- Actualizo campo C50094 con valor CANTIDADCUOTAS --

UPDATE B 
SET B.C50094 = B.CANTIDADCUOTAS
FROM BS_HISTORIA_PLAZO B 
INNER JOIN SALDOS S
	ON B.SALDOS_JTS_OID = S.JTS_OID
WHERE S.C1785 = 5 AND S.C1827 = ''PRE'' AND S.ComisDesemMO <> 0 AND B.TIPOMOV = ''I''


-- Actualizo campo CANTIDADCUOTAS con valor RUBROANTERIOR --

UPDATE B
SET B.CANTIDADCUOTAS = B.RUBROANTERIOR 
FROM BS_HISTORIA_PLAZO B 
INNER JOIN SALDOS S
	ON B.SALDOS_JTS_OID = S.JTS_OID 
WHERE S.C1785 = 5 AND S.C1827 = ''PRE'' AND S.ComisDesemMO <> 0  AND B.TIPOMOV = ''I''

-- FINALIZA SP -- 

	 SET @P_RET_PROCESO = 1

	 SET @P_MSG_PROCESO = ''Ejecutado con exito. ''

--


	 
   BEGIN TRANSACTION
		INSERT INTO MIG_RESULTADOS
					(CICLO, PROCESO, MODULO, FECHAINICIO, FECHAFIN, ESTADO, ERRORES, MENSAJE, ARCHIVO)
				VALUES
				   (@v_CICLO,
					@v_PROCESO,
					@p_MODULO,
					@v_FECHASYS,
					SYSDATETIME(),
					''A'',
					''N'',
				        ''OK'',
					@p_NomScr)
		COMMIT;


END
')