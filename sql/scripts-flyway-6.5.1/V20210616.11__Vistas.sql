EXECUTE('
CREATE VIEW VW_AYUDA_CONV_REND
AS
	SELECT L.ID_LIQUIDACION AS "Número Liquidación", L.ESTADO AS "Estado", L.CONVENIO AS "Número Convenio", C.NomConvRec AS "Nombre Convenio",
	L.CONVENIO_PADRE AS "Convenio Padre",C.Cuit AS "Cuit", CLI.NOMBRECLIENTE AS "Nombre Cliente", L.FECHA AS "Fecha Liquidación", L.MONEDA AS "Moneda",L.TOTALREGISTROS AS "Total Registros",
	 L.TOTALIMPORTE AS "Total Importe",	L.COMISION_LIQUIDADA AS "Comisión Liquidada", L.IMPORTE_COMISION AS "Importe Comisión"
	FROM REC_LIQUIDACION L
	JOIN CONV_CONVENIOS_REC C ON L.CONVENIO = C.Id_ConvRec
	JOIN CLI_CLIENTES CLI ON C.Cliente = CLI.CODIGOCLIENTE ')
	
	EXECUTE ('

CREATE VIEW VW_AYUDA_CONV_INFO
AS
	SELECT C.Id_ConvRec AS "Id Convenio Recaudacion", C.NomConvRec AS "Nombre", C.Cuit, C.Cliente AS "Id Cliente", CLI.NOMBRECLIENTE AS "Nombre Cliente", C.Id_TpoConv AS "Id Tipo Convenio", T.DscTpoConv "Descripcion Tipo Convenio", 
	C.Canal, OC.Descripcion AS "Descripcion Canal", C.Estado, OE.DESCRIPCION AS "Descripcion Estado", C.FecAlta AS "Fec. Alta", 
	C.FecVto AS "Fec. Vencimiento", C.FecUltAct AS "Fec. Ult. Actividad", C.Id_RefExt AS "Ref Externa", C.Id_ConvPadre AS "Id Conv. Padre"
	FROM CONV_CONVENIOS_REC C 
	JOIN CLI_CLIENTES CLI ON C.Cliente = CLI.CODIGOCLIENTE
	JOIN CONV_TIPOS T ON C.Id_TpoConv = T.Id_TpoConv
	JOIN OPCIONES OE ON C.Estado = OE.OPCIONINTERNA AND OE.NUMERODECAMPO = 44756
	JOIN OPCIONES OC ON C.Canal = OC.OPCIONINTERNA AND OC.NUMERODECAMPO = 44750
')