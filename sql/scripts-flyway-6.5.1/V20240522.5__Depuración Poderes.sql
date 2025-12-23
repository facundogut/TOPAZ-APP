EXECUTE('

DELETE from PYF_TIPOPODERES where tipo_poder in (0,8,9,16,17,23,24,33,34,35,36,44)
DELETE from pyf_apoderados where tipo_poder in (0,8,9,16,17,23,24,33,34,35,36,44)
 
DELETE from pyf_apoderamiento where codpoder in (0,8,9,16,17,23,24,33,34,35,36,44)
DELETE from PYF_TIPOPODER_X_TIPOENTIDAD where TIPO_PODER in (0,8,9,16,17,23,24,33,34,35,36,44)

')