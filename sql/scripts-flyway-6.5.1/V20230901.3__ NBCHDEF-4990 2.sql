
execute('
INSERT INTO dbo.AYUDAS (NUMERODEARCHIVO, NUMERODEAYUDA, DESCRIPCION, FILTRO, MOSTRARTODOS, CAMPOS, CAMPOSVISTA, BASEVISTA, NOMBREVISTA, AYUDAGRANDE)
VALUES (0, 124, ''Ayuda total remesas domicilio'', '''', 0, ''401R;75;42;622;60;1063;531;56;470;532'', ''Id soporte;Fecha débito;Moneda;Descripción moneda;Importe a transp.;Estado;Descripción Estado;Fecha crédito;Importe desde transp.;Nro remesa'', ''TOP/CLIENTES'', ''VW_TOTAL_REMESAS_DOM'', 0)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (70099, '' '', 0, ''Ayuda total remesas domicilio'', ''Ayuda total remesas domicilio'', 10, ''N'', 0, NULL, 0, 0, 0, 0, 0, 124, 0, 0, ''Ayuda total remesas domicilio'', 0, NULL)
')