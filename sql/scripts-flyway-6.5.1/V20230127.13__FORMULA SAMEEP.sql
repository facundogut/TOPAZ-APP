--FORMULA SAMEEP

EXECUTE('IF EXISTS (SELECT * FROM CONV_FORMULAS_MORA WHERE ID_FORMULA = 4)
BEGIN

 DELETE FROM CONV_FORMULAS_MORA WHERE ID_FORMULA = 4;
 
INSERT INTO CONV_FORMULAS_MORA (ID_FORMULA, FORMULA_IMPORTE, DESCRIPCION_IMPORTE, NOMBRE, TIPO_FORMULA, FORMULA_MORA, DESCRIPCION_MORA, TZ_LOCK)
VALUES (
4, 
''F(IfNumeric,C9500<C44863 O C9500=C44863  ,C44861 ,F(IfNumeric,C9500<C44863 +10 O C9500=C44863 + 10 ,C44861+C44862 ,C44861+C44862))'',
''ifNumeric(Fecha Sistema<Primer Vencimiento||Fecha Sistema==Primer Vencimiento,Primer Importe,ifNumeric(Fecha Sistema<Primer Vencimiento+10||Fecha Sistema==Primer Vencimiento+10,Primer Importe,Primer Importe+Segundo Importe))'', 
''Formula SAMEEP'', 
''G'', 
''F(IfNumeric,C9500<C44863 O C9500=C44863  ,0 ,F(IfNumeric,C9500<C44863 +10 O C9500=C44863 +10 ,C44862 ,((C9500-C44863)*(C44861+C44862)*0.06/100) +(((C9500-C44863)*(C44861+C44862)*0.06/100)*C45237/100)  ) )'', 
''ifNumeric(Fecha Sistema>Primer Vencimiento||Fecha Sistema==Primer Vencimiento,0,ifNumeric(Fecha Sistema<Primer Vencimiento+10||Fecha Sistema==Primer Vencimiento+10,Segundo Importe,((Fecha Sistema-Primer Vencimiento)*(Primer Importe+Segundo Importe)*0'', 
0)

END
ELSE
BEGIN

INSERT INTO CONV_FORMULAS_MORA (ID_FORMULA, FORMULA_IMPORTE, DESCRIPCION_IMPORTE, NOMBRE, TIPO_FORMULA, FORMULA_MORA, DESCRIPCION_MORA, TZ_LOCK)
VALUES (
4, 
''F(IfNumeric,C9500<C44863 O C9500=C44863  ,C44861 ,F(IfNumeric,C9500<C44863 +10 O C9500=C44863 + 10 ,C44861+C44862 ,C44861+C44862))'',
''ifNumeric(Fecha Sistema<Primer Vencimiento||Fecha Sistema==Primer Vencimiento,Primer Importe,ifNumeric(Fecha Sistema<Primer Vencimiento+10||Fecha Sistema==Primer Vencimiento+10,Primer Importe,Primer Importe+Segundo Importe))'', 
''Formula SAMEEP'', 
''G'', 
''F(IfNumeric,C9500<C44863 O C9500=C44863  ,0 ,F(IfNumeric,C9500<C44863 +10 O C9500=C44863 +10 ,C44862 ,((C9500-C44863)*(C44861+C44862)*0.06/100) +(((C9500-C44863)*(C44861+C44862)*0.06/100)*C45237/100)  ) )'', 
''ifNumeric(Fecha Sistema>Primer Vencimiento||Fecha Sistema==Primer Vencimiento,0,ifNumeric(Fecha Sistema<Primer Vencimiento+10||Fecha Sistema==Primer Vencimiento+10,Segundo Importe,((Fecha Sistema-Primer Vencimiento)*(Primer Importe+Segundo Importe)*0'', 
0)
END

')