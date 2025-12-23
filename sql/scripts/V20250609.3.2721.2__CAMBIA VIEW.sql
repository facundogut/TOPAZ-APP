EXECUTE('
CREATE or ALTER VIEW VW_CONV_CB_CAMPOS_CONV
as 
select c.id_codigo_barras Formulario ,CAMPO  , id_convenio , e.descripcion , c.nombre, c.posicion, c.largo, c.obligatorio, c.editable, c.prompt, c.Posicion_rendicion, c.orden_voucher
, c.id_codigo_barras Formulario_k
 from CONV_CB_CAMPOS c join CONV_CB_ESTRUCTURA e on c.ID_CODIGO_BARRAS =e.ID_CODIGO_BARRAS where c.TZ_LOCK =0 and e.TZ_LOCK=0 ;
');