EXECUTE('
---------------------
--Che_CheqSolicitud--
---------------------
ALTER TABLE Che_CheqSolicitud ALTER COLUMN PRODUCTO NUMERIC (5, 0)
-----------------------
--CHE_CHEQUESIMPRENTA--
-----------------------
ALTER TABLE CHE_CHEQUESIMPRENTA ALTER COLUMN Producto NUMERIC (5, 0)
------
')