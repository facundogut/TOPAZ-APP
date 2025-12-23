EXECUTE('
CREATE or ALTER VIEW VW_CONV_CB_CAMPOS_CONV
as 
select c.id_codigo_barras Formulario ,CAMPO  , id_convenio , e.descripcion , c.nombre, c.posicion, c.largo, c.obligatorio, c.editable, c.prompt, c.Posicion_rendicion, c.orden_voucher
, c.id_codigo_barras Formulario_k
 from CONV_CB_CAMPOS c join CONV_CB_ESTRUCTURA e on c.ID_CODIGO_BARRAS =e.ID_CODIGO_BARRAS ;
');

EXECUTE('
DELETE dbo.DICCIONARIO where NUMERODECAMPO=8485;
');

EXECUTE('
insert into dbo.DICCIONARIO (NUMERODECAMPO,USODELCAMPO,REFERENCIA,DESCRIPCION,PROMPT,LARGO,TIPODECAMPO,DECIMALES,CONTABILIZA,CONCEPTO,CALCULO,VALIDACION,TABLADEVALIDACION,TABLADEAYUDA,OPCIONES,TABLA,CAMPO,BASICO) 
	values 
		(8485,'' '',0,''Ayuda Campos CB'',''Ayuda Campos CB'',5,''A'',0,0,0,0,0,0,6,0,0,''AY_CAMPOS_CB'',0);
');

EXECUTE('
DELETE dbo.AYUDAS where numerodeayuda=6;
');

EXECUTE('
insert into dbo.AYUDAS (NUMERODEARCHIVO,NUMERODEAYUDA,DESCRIPCION,FILTRO,MOSTRARTODOS,CAMPOS,CAMPOSVISTA,BASEVISTA,NOMBREVISTA,AYUDAGRANDE) 
	values (0,6,''Campos Convenio con Convenio'','''',0,''288ROA1;4184OA2;612;753;755;620;62R;549;669R;433;556;4183;2970R;536R;'' ,
''Formulario;Orden_Voucher;posicion;Campo;Prompt;Nombre;Descripcion;id_Convenio;Largo;Obligatorio;Editable;Posicion_Rendicion;Campo;Formulario_k;'',''TOP/CLIENTES'',''VW_CONV_CB_CAMPOS_CONV'',0);
');