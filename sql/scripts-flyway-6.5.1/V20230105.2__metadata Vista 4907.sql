EXECUTE('
IF OBJECT_ID (''VW_CAJ_CAJAS_SIN_TESORO'') IS NOT NULL
	DROP VIEW VW_CAJ_CAJAS_SIN_TESORO
')

EXECUTE('
CREATE   VIEW [VW_CAJ_CAJAS_SIN_TESORO] (
                                           NRO_CAJA,
                                           USUARIO,
                                           INICIALES,
                                           NOMBRE,
                                           ESTADO,
                                           SUCURSAL,
                                           MINIFILIAL,
                                           DESCRIPCION,
                                           EsTesoro)
AS
SELECT 
	c.NRO_CAJA ''NRO_CAJA'', 
	u.CLAVE ''USUARIO'',
	u.INICIALES ''INICIALES'',
	u.NOMBRE ''NOMBRE'', 
	(CASE 
		WHEN c.ESTADO = ''A'' THEN ''Abierta''
		ELSE ''Cerrada''
	END) AS ESTADO,
	c.SUCURSAL,
	(CASE WHEN cc.Mini_Filial IS NULL THEN ''0''
	ELSE CONVERT(varchar(3),cc.Mini_Filial)
	END) AS ''MINIFILIAL'',
	cc.Descripcion AS ''DESCRIPCION'',
	cm.EsTesoro AS ''EsTesoro''
FROM TABLA_CAJAS c WITH(NOLOCK)
INNER JOIN USUARIOS u WITH(NOLOCK) ON c.NRO_CAJA = u.NRODECAJA 
						AND c.SUCURSAL=u.NROSUCURSAL 
						AND
							(	(c.TZ_LOCK < 300000000000000 OR c.TZ_LOCK >= 400000000000000) 	
							AND (c.TZ_LOCK < 100000000000000 OR c.TZ_LOCK >= 200000000000000)) 
						AND(	(u.TZ_LOCK < 300000000000000 OR u.TZ_LOCK >= 400000000000000) 	
						AND		(u.TZ_LOCK < 100000000000000 OR u.TZ_LOCK >= 200000000000000))
INNER JOIN CAJ_MiniFiliales cc WITH(NOLOCK) ON 
cc.SUCURSAL = c.SUCURSAL 	
INNER JOIN CAJ_Cajas_MiniFiliales cm WITH(NOLOCK) ON
cm.Mini_Filial = cc.Mini_Filial 
AND cm.EsTesoro = ''N''
AND cm.NRO_CAJA = c.NRO_CAJA 
AND (	(cm.TZ_LOCK < 300000000000000 OR cm.TZ_LOCK >= 400000000000000) 
AND (cm.TZ_LOCK < 100000000000000 OR cm.TZ_LOCK >= 200000000000000))
')