-----------------
-- Alter tables--
-----------------
--Agrego Columna SNP_STOP_DEBIT

   
EXECUTE('
ALTER TABLE SNP_STOP_DEBIT
        ADD CUENTA_VISTA NUMERIC(12)
')      