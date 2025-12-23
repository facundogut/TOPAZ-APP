EXECUTE('
-- Vistas
CREATE   VIEW [VW_AYUDA_CONV_REND_DA]
AS
SELECT L.ID_LIQUIDACION AS ''Número Liquidación'', 
		L.ESTADO AS ''Estado'', 
		L.CONVENIO AS ''Número Convenio'', 
		C.NomConvRec AS ''Nombre Convenio'', 
		L.CONVENIO_PADRE AS ''Convenio Padre'',
		C.Cuit AS ''Cuit'', 
		CLI.NOMBRECLIENTE AS ''Nombre Cliente'', 
		L.FECHA AS ''Fecha Liquidación'', 
		L.MONEDA AS ''Moneda'',
		L.TOTALREGISTROS AS ''Total Registros'', 
		L.TOTALIMPORTE AS ''Total Importe'',	
		L.COMISION_LIQUIDADA AS ''Comisión Liquidada'', 
		L.IMPORTE_COMISION AS ''Importe Comisión''
FROM REC_LIQUIDACION L WITH (NOLOCK)
JOIN CONV_CONVENIOS_REC C WITH (NOLOCK) ON L.CONVENIO = C.Id_ConvRec 
										AND C.Id_TpoConv =2
JOIN CLI_CLIENTES CLI  WITH (NOLOCK)ON C.Cliente = CLI.CODIGOCLIENTE

')