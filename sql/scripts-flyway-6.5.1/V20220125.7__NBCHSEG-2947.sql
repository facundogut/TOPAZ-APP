EXECUTE('
DROP PROCEDURE IF EXISTS SP_DJ_PARSEAR_CARATULA_CAUSA;
')

EXECUTE('

CREATE PROCEDURE SP_DJ_PARSEAR_CARATULA_CAUSA
@pCaratula VARCHAR(250),
@pActora VARCHAR(250) OUT,
@pDemandante VARCHAR(250) OUT,
@pSobre VARCHAR(250) OUT
AS
BEGIN
	DECLARE
	@vCaratula VARCHAR(250),
	@vActora VARCHAR(250),
	@vDemandante VARCHAR(250),
	@vSobre VARCHAR(250)
	
	SET @vCaratula = @pCaratula;
	SET @vActora = SUBSTRING(@vCaratula, 0, CHARINDEX(''C/'', @vCaratula));
	SET @vCaratula = SUBSTRING(@vCaratula, CHARINDEX(''C/'', @vCaratula) + 2, 250);
	SET @vDemandante = SUBSTRING(@vCaratula, 0, (CHARINDEX(''S/'', @vCaratula)));
	SET @vCaratula = SUBSTRING(@vCaratula, CHARINDEX(''S/'', @vCaratula) + 2, 250);
	SET @vSobre = SUBSTRING(@vCaratula, 0, 250);
	
	SET @pActora = RTRIM(LTRIM(@vActora));
    SET @pDemandante = RTRIM(LTRIM(@vDemandante));
    SET @pSobre = RTRIM(LTRIM(@vSobre));
	
END

')