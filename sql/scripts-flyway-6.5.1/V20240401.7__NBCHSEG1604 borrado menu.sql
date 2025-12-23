-------------------------------------------------------------------------------------
----- Script depuración para aplicar en caso de que no los utilice el banco	   ------
----- y que no afectan el funcionamiento del core 							   ------
----- (110 Navegador, 111 Identificacion Persona, 113 Catalogador y 116 Firmas)------
-------------------------------------------------------------------------------------

EXECUTE ('DELETE MENU WHERE identificacion IN (110, 111, 113, 116)')


------------------------------------------------------------------------------------------------
--------- 						ELIMINAR RESTRICCIONES 								   ---------
------------------------------------------------------------------------------------------------


------ Borrado para identifiacion (110, 111, 113, 116) ---

EXECUTE ('DELETE RESTRICCIONES WHERE IDENTIFICACION IN (''01000110'', ''01000111'', ''01000113'', ''01000116'') 
AND TIPO=''M'' ')

