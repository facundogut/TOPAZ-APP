EXECUTE('
UPDATE a
SET a.ESTADO=''I''
FROM AUT_SOLICITUDES a
INNER JOIN cle_cheques_Saliente ch ON a.NROSOLICITUD=ch.NRO_SOLICITUD
INNER JOIN saldos s ON a.jts_oid_saldo=s.jts_oid
WHERE a.estado=''A''  
AND a.producto=26000 AND s.c1621 < ''20250301''  
AND ch.BANCO_GIRADO<>311 AND s.C1604<>0
')