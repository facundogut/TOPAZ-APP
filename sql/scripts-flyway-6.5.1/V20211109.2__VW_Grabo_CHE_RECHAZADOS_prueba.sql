EXECUTE('
create view VW_Grabo_CHE_RECHAZADOS_prueba as
SELECT
--1
(select NUMERICO from PARAMETROSGENERALES where CODIGO =2) as Codigo_Entidad,
--2
cbr.SUCURSAL as Nro_Sucursal,
--3
cbr.CUENTA as Nro_Cuenta_Corriente,
--4
cbr.NRO_CHEQUE as Numero_Cheque,
--5.1
(select right(Cast(Year(cbr.FECHA_CHEQUE) As Char(4)),2)) as Año,
--5.2
cbr.NRO_AVISO as Nro_Aviso,
--6
''A'' as Codigo_Movimiento,
--7 Clase_Registro
--8
cbr.FECHA_NOTIFICACION as Fecha_Notificacion,
--9
cbr.CODIGO_DE_CAUSAL as Causal,
--10
''80'' as Codigo_Moneda,
--11
cbr.IMPORTE_CHEQUE as Importe,
--12
cbr.FECHA_RECHAZO as Fecha_Rechazo
/*--13 as Fecha_Registracion
--CASE 
--		WHEN cbr.COD_MOVIMIENTO = ''A'' AND cbr.CAUSAL in (6,7,8) 
--		THEN --fecha de presentacion al cobro
--		WHEN cbr.NRO_CHEQUE in /*en rango chequera, tabla cle_chequera?*/  AND --TipoLibreta=''D''  
--		THEN cbr.FECHA_REGISTRACION
--		END Fecha_Registracion
--14 as Plazo_Diferimiento,*/  FROM CHE_BCO_RECHAZADOS cbr ')