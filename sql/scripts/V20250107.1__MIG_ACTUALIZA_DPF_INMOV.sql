EXECUTE('
CREATE OR ALTER                                     PROCEDURE [dbo].[MIG_ACTUALIZA_DPF_INMOV]

/*********************************************************************************
Modulo  : PARAMETROS
Tabla   : PARAMETROS
Version : 14/10/2024 
Tarea   : MIGNBCAR-
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


--------------------------------------------
SET @v_FECHASYS=SYSDATETIME()
SET @v_CICLO = 1
SET @v_PROCESO = 1
SET @p_MODULO = ''PARAMETROS''
SET @p_NomScr = ''ACT_DPF_INMOV''
--
DECLARE @v_cantidad numeric(10) = 0 

--Actualizo saldo en 0 para DPF UVA Inmovilizados
UPDATE SALDOS
SET C1604 = 0
WHERE moneda=999 and C1734 = ''U''
--

--Actualizo planpagos DPF UVA Inmovilizados
UPDATE PLANPAGOS
SET C2309 = 0,
    C2310 = 0
WHERE EXISTS (
    SELECT 1 
    FROM saldos s WITH (NOLOCK)
    WHERE PLANPAGOS.saldo_JTS_oid = s.jts_oid and s.moneda=999 and s.C1734 = ''U''
);

--Contabilizo modificaciones
--
Set @v_cantidad = ( select count(*) from saldos(nolock) where c1604=0 and moneda=999 and C1734 = ''U'' )
--
	 SET @P_RET_PROCESO = 1
	 SET @P_MSG_PROCESO = ''Se actualizaron: '' + str(@v_cantidad) + '' registros de DPF Inmovilizados.''
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


END;
')