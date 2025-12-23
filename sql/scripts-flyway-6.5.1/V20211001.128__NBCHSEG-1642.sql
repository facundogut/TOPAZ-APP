EXECUTE('

ALTER PROCEDURE 
[dbo].[sp_dj_validar_causa]
@pJuzgado NUMERIC(12),
@pAnio	NUMERIC(4),
@pExpediente VARCHAR(12),
@pValido NUMERIC(6) OUT,
@pMensaje VARCHAR(200) OUT
AS
BEGIN
	DECLARE
	@vValido NUMERIC(6),
	@vEstadoCausa VARCHAR(1),
	@vCausaTransferida NUMERIC(12),
	@vCausa VARCHAR(12)
	
	SET @vValido = 0;
	
	SELECT TOP 1 @vValido = 1, @vEstadoCausa = C.ESTADO, @vCausaTransferida = C.CAUSA_DESTINO, @vCausa=C.NRO_CAUSA
	FROM DJ_CAUSAS C WITH (NOLOCK)
	WHERE C.JUZGADO=@pJuzgado 
			AND C.ANO=@pAnio 
			AND C.EXPEDIENTE=@pExpediente 
			AND C.TZ_LOCK=0;
	
	IF @vValido = 1 AND @vEstadoCausa = ''A'' BEGIN
		SET @pValido = 1;
		SET @pMensaje = ''La causa existe con el mismo Juzgado + Año + Expediente. Nro. Causa: '';
		SET @pMensaje = @pMensaje+@vCausa;
	END
	ELSE IF @vValido = 1 AND @vEstadoCausa = ''I'' BEGIN
		SET @pValido = 1;
		SET @pMensaje = ''La causa se encuentra Inactiva. Nro. Causa: '';
		SET @pMensaje = @pMensaje+@vCausa;
	END
	ELSE IF @vValido = 1 AND @vEstadoCausa = ''T'' BEGIN
		SET @pValido = 1;
		SET @pMensaje = ''La causa fue transferida a la causa número '' + CONVERT(VARCHAR, @vCausaTransferida);
	END
	ELSE IF @vValido = 0 BEGIN
		SET @pValido = 0;
	END
END

')

EXECUTE('

CREATE   VIEW [dbo].[VW_DJ_CAUSAS_COMPLETO] (
											[Nro. Causa],
											[Juzgado],
											[Año],
											[Expediente],
											[Tipo Causa],
											[Fecha Causa],
											[Estado],
											[Caratula],
											[Cuenta],
											[Alta de la Cuenta],
											[Bloqueo de la Cuenta])
AS
SELECT
		c.NRO_CAUSA,
		c.JUZGADO,
		c.ANO,
		c.EXPEDIENTE,
		c.TIPO_CAUSA,
		c.FECHA_CAUSA,
		(	SELECT DESCRIPCION 
			FROM OPCIONES WITH (NOLOCK) 
			WHERE NUMERODECAMPO=33141 
			AND OPCIONINTERNA=c.ESTADO) AS ESTADO,
		c.CARATULA,
		s.CUENTA,
		a.FECHA_OFICIO,
		b.DESCRIPCION
FROM DJ_CAUSAS c WITH (NOLOCK)
LEFT JOIN DJ_CAUSA_CUENTA a WITH (NOLOCK) ON c.NRO_CAUSA=a.NRO_CAUSA 
											AND (	(c.TZ_LOCK < 300000000000000 OR c.TZ_LOCK >= 400000000000000) 
												AND (c.TZ_LOCK < 100000000000000 OR c.TZ_LOCK >= 200000000000000)) 
											AND(	(a.TZ_LOCK < 300000000000000 OR a.TZ_LOCK >= 400000000000000) 
												AND (a.TZ_LOCK < 100000000000000 OR a.TZ_LOCK >= 200000000000000)) 
LEFT JOIN saldos s WITH (NOLOCK) ON a.JTS_OID_CUENTA=s.JTS_OID 
								AND C1651<>1 
								AND(	(s.TZ_LOCK < 300000000000000 OR s.TZ_LOCK >= 400000000000000) 
									AND (s.TZ_LOCK < 100000000000000 OR s.TZ_LOCK >= 200000000000000)) 
LEFT JOIN GRL_BLOQUEOS b WITH (NOLOCK) ON s.JTS_OID=b.SALDO_JTS_OID 
									AND b.ESTADO<>2

')

EXECUTE('
INSERT INTO dbo.AYUDAS (NUMERODEARCHIVO, NUMERODEAYUDA, DESCRIPCION, FILTRO, MOSTRARTODOS, CAMPOS, CAMPOSVISTA, BASEVISTA, NOMBREVISTA, AYUDAGRANDE)
VALUES (0, 1819, ''Ayuda Causa - Cuentas'', NULL, 0, ''2615R;2616;661;44871;4898;112;4073;9208;3325;2844;5011;'', ''Nro. Causa;Juzgado;Año;Expediente;Tipo Causa;Fecha Causa;Estado;Caratula;Cuenta;Alta de la Cuenta;Bloqueo de la Cuenta;'', ''TOP/CLIENTES'', ''VW_DJ_CAUSAS'', 0)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (37096, '' '', 0, ''Numerador Causas'', ''Nro. Causa'', 12, ''N'', 0, NULL, 0, 0, 0, 0, 0, 1816, 0, 0, NULL, 0, NULL)



')