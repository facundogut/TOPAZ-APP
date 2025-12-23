ALTER PROCEDURE SaldosContabilidad
AS
DECLARE 
@w_c6399 numeric(4,0),
@w_c6437 numeric(15,0),
@w_c7500 numeric(15,0),
@w_c6433 numeric(15,0),
@w_c6435 numeric(15,0),
@w_c6403 varchar(1),
@w_sucur numeric(5,0)

DECLARE	cur_Monedas CURSOR LOCAL FORWARD_ONLY FOR
SELECT c6399, c6437, c7500, c6433, c6435, c6403 FROM MONEDAS where tz_lock = 0
DECLARE cur_sucursales CURSOR LOCAL FORWARD_ONLY FOR
SELECT SUCURSAL FROM SUCURSALES WHERE tz_lock = 0

BEGIN
	OPEN cur_Monedas --recorro monedas
	FETCH NEXT FROM cur_Monedas INTO @w_c6399, @w_c6437, @w_c7500, @w_c6433, @w_c6435, @w_c6403
	WHILE @@fetch_status = 0
	BEGIN
		OPEN cur_sucursales --recorro sucursales
		FETCH NEXT FROM cur_sucursales INTO @w_sucur
		WHILE @@fetch_status = 0
		BEGIN
			IF (@w_c6403 <> 'I')
			BEGIN
				---RUBROS DE CAJA ABRIR PARA TODAS LAS SUCURSALES
				INSERT INTO SALDOS (Sucursal, Moneda, Producto, Cuenta, Operacion, Ordinal, c1785, c1692, c1730, c1604)
				values (@w_sucur, @w_c6399, 0, @w_c6437, 0, 0, 1, @w_c6437, @w_c6437, -1000000)
				
				---RUBROS DE EXTORNO DE CAJAS ABRIR PARA TODAS LAS SUCURSALES
				INSERT INTO SALDOS (Sucursal, Moneda, Producto, Cuenta, Operacion, Ordinal, c1785, c1692, c1730, c1604)
				values (@w_sucur, @w_c6399, 0, @w_c7500, 0, 0, 1, @w_c7500, @w_c7500, -1000000)
			END
			
			
			IF(@w_c6399 <> 1)
			BEGIN
				---RUBROS DE POSICION
				INSERT INTO SALDOS (Sucursal, Moneda, Producto, Cuenta, Operacion, Ordinal, c1785, c1692, c1730)
				values (@w_sucur, @w_c6399, 0, @w_C6433, 0, 0, 1, @w_C6433 , @w_C6433)
				
				---RUBROS DE EQUIVALENTE POSICION
				INSERT INTO SALDOS (Sucursal, Moneda, Producto, Cuenta, Operacion, Ordinal, c1785, c1692, c1730)
				values (@w_sucur, 1, 0, @w_C6435, @w_c6399, 0, 1, @w_C6435  , @w_C6435)
			END
			FETCH NEXT FROM cur_sucursales INTO @w_sucur
		END
		CLOSE cur_sucursales --fin recorrida sucursales
		FETCH NEXT FROM cur_Monedas INTO @W_c6399, @w_c6437, @w_c7500, @w_c6433, @w_c6435, @w_c6403
	END
	CLOSE cur_Monedas --fin recorrida monedas
	DEALLOCATE cur_Monedas
END
GO

EXECUTE SaldosContabilidad
