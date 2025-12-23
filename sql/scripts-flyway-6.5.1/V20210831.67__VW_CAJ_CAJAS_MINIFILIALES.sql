EXECUTE('
create OR ALTER VIEW VW_CAJ_CAJAS_MINIFILIALES as
SELECT 
	cm.Mini_Filial AS Minifilial, 
	cm.NRO_CAJA AS ''Número de Caja'',
		(SELECT DESCRIPCION 
		FROM OPCIONES WITH (NOLOCK)
		WHERE NUMERODECAMPO = 5586 
			AND OPCIONINTERNA = cm.EsTesoro) as ''Es Tesoro''
from CAJ_Cajas_Minifiliales cm WITH (NOLOCK)
where cm.TZ_LOCK = 0
')

