/****** Object:  StoredProcedure [dbo].[SP_DJ_VALIDA_BAJA_CUENTA]    Script Date: 02/06/2021 17:52:47 ******/
ALTER PROCEDURE [dbo].[SP_DJ_VALIDA_BAJA_CUENTA]
@pNroCausa NUMERIC(12),
@pJtsOidCta NUMERIC(12),
@pValido NUMERIC(1) OUT,
@pMsg VARCHAR(200) OUT
AS
BEGIN
	DECLARE 
	@vTipoCausa VARCHAR(2),
	@vProductoCta NUMERIC(5),
	@vProductoCausa NUMERIC(5),
	@vCantCtas NUMERIC(6),
	@vCantBeneficiarios NUMERIC(6),
	@vSaldoCta NUMERIC(15,2),
	@vBloqueo NUMERIC(1),
	@vEstado VARCHAR(1),
	@vValido NUMERIC(1)
	
	SELECT @vTipoCausa = C.TIPO_CAUSA FROM DJ_CAUSAS C WITH (NOLOCK) WHERE C.NRO_CAUSA = @pNroCausa;
	SELECT @vProductoCta = S.PRODUCTO FROM SALDOS S WITH (NOLOCK)  WHERE S.JTS_OID = @pJtsOidCta;
	SELECT @vProductoCausa = TC.PRODUCTO FROM DJ_TIPOS_CAUSAS TC WITH (NOLOCK) WHERE TC.[CODIGO] = @vTipoCausa;
	
	SET @vValido = 1;
		
	--Si Cuenta: con Saldo y estado Activo 
	IF @vValido = 1
		BEGIN
		SELECT @vSaldoCta = S.C1604
		FROM SALDOS S WITH (NOLOCK)
		JOIN DJ_CAUSA_CUENTA F WITH (NOLOCK) ON S.JTS_OID = @pJtsOidCta 
											AND S.JTS_OID=F.JTS_OID_CUENTA 
		JOIN DJ_CAUSAS C WITH (NOLOCK) ON C.NRO_CAUSA=F.NRO_CAUSA 
											AND C.ESTADO='A'
		WHERE 0 = (SELECT COUNT(*) 
					FROM GRL_BLOQUEOS B WITH (NOLOCK) 
					WHERE B.SALDO_JTS_OID=@pJtsOidCta 
						AND ((B.TZ_LOCK < 300000000000000 OR B.TZ_LOCK >= 400000000000000) 
						AND (B.TZ_LOCK < 100000000000000 OR B.TZ_LOCK >= 200000000000000)) );
		
		IF @vSaldoCta > 0
		BEGIN
			SET @vValido = 0; 
			SET @pMsg = 'Sr Usuario, por Favor Verifique: Cuenta seleccionada posee "Saldo".';
		END
	END
	
	--Si Cuenta: con Saldo y estado Transferida 
	IF @vValido = 1
		BEGIN
		SELECT @vSaldoCta = S.C1604
		FROM SALDOS S WITH (NOLOCK)
		JOIN DJ_CAUSA_CUENTA F WITH (NOLOCK) ON S.JTS_OID = @pJtsOidCta 
												AND S.JTS_OID=F.JTS_OID_CUENTA 
		JOIN DJ_CAUSAS C WITH (NOLOCK) ON C.NRO_CAUSA=F.NRO_CAUSA 
											AND C.ESTADO='T'
		WHERE 0 = (SELECT COUNT(*) 
					FROM GRL_BLOQUEOS B WITH (NOLOCK)
					WHERE B.SALDO_JTS_OID=@pJtsOidCta 
							AND ((B.TZ_LOCK < 300000000000000 OR B.TZ_LOCK >= 400000000000000) 
							AND (B.TZ_LOCK < 100000000000000 OR B.TZ_LOCK >= 200000000000000)) );
		
		IF @vSaldoCta > 0
		BEGIN
			SET @vValido = 0; 
			SET @pMsg = 'Sr Usuario, por Favor Verifique: Causa se encuentra en estado "Transferida".';
		END
	END
	
	--Si Cuenta: con Saldo y estado Inactiva 
	IF @vValido = 1
		BEGIN
		SELECT @vSaldoCta = S.C1604
		FROM SALDOS S WITH (NOLOCK)
		JOIN DJ_CAUSA_CUENTA F WITH (NOLOCK)ON S.JTS_OID = @pJtsOidCta 
											AND S.JTS_OID=F.JTS_OID_CUENTA 
		JOIN DJ_CAUSAS C WITH (NOLOCK)ON C.NRO_CAUSA=F.NRO_CAUSA 
										AND C.ESTADO='I'
		WHERE 0 = (SELECT COUNT(*) 
					FROM GRL_BLOQUEOS B WITH (NOLOCK) 
					WHERE B.SALDO_JTS_OID=@pJtsOidCta 
						AND ((B.TZ_LOCK < 300000000000000 OR B.TZ_LOCK >= 400000000000000) 
						AND (B.TZ_LOCK < 100000000000000 OR B.TZ_LOCK >= 200000000000000)) );
		
		IF @vSaldoCta > 0
		BEGIN
			SET @vValido = 0; 
			SET @pMsg = 'Sr Usuario, por Favor Verifique: Causa se encuentra en estado "Inactivo".';
		END
	END
	
	
	--Si Cuenta: Cerrada 
	IF @vValido = 1
		BEGIN
		SELECT @vSaldoCta = COUNT( * )
		FROM SALDOS S  WITH (NOLOCK)
		WHERE S.JTS_OID = @pJtsOidCta 
			AND S.C1651=1 
				
		IF @vSaldoCta > 0
		BEGIN
			SET @vValido = 0; 
			SET @pMsg = 'Sr Usuario, por Favor Verifique: Cuenta seleccionada se encuentra "Cerrada".';
		END
	END
	
	--Si Cuenta:  sin Saldo y Bloqueo distinto a 9 Depósito judicial y Estado de Causa: Activo.
	IF @vValido = 1
		BEGIN
		SELECT @vSaldoCta = S.C1604
		FROM SALDOS S WITH (NOLOCK)
		JOIN DJ_CAUSA_CUENTA F WITH (NOLOCK)ON S.JTS_OID = @pJtsOidCta 
				AND S.JTS_OID=F.JTS_OID_CUENTA 
				AND	((F.TZ_LOCK < 300000000000000 OR F.TZ_LOCK >= 400000000000000) 
				AND (F.TZ_LOCK < 100000000000000 OR F.TZ_LOCK >= 200000000000000)) 
		JOIN DJ_CAUSAS C WITH (NOLOCK) ON C.NRO_CAUSA=F.NRO_CAUSA
										AND C.ESTADO='A' 
										AND	((C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
										AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000)) 
		JOIN GRL_BLOQUEOS B WITH (NOLOCK)ON B.SALDO_JTS_OID=S.JTS_OID 
										AND B.COD_BLOQUEO<>9 
										AND	((B.TZ_LOCK < 300000000000000 OR B.TZ_LOCK >= 400000000000000) 
										AND (B.TZ_LOCK < 100000000000000 OR B.TZ_LOCK >= 200000000000000)) 
		
		IF @vSaldoCta = 0
		BEGIN
			SET @vValido = 0; 
			SET @pMsg = 'Sr Usuario, por Favor Verifique: Cuenta seleccionada se encuentra "Bloqueada". '+(SELECT TOP 1 DESCRIPCION 
																											FROM GRL_BLOQUEOS WITH (NOLOCK)
																											WHERE  SALDO_JTS_OID=@pJtsOidCta 
																											AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) 
																											AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)) );
		END
	END
	
	/*
	Dar de Baja la Cuenta, si se cumple algunas de las condiciones detalladas a continuación:
	Si Cuenta:  sin Saldo y sin Bloqueo y Estado de Causa: Activo.  
	Si Cuenta:  sin Saldo y Bloqueo igual a 9 Depósito Judicial y Estado de Causa: Activo.
	*/
	IF @vValido = 1
		BEGIN
		SELECT @vSaldoCta = S.C1604, @vEstado=C.ESTADO
		FROM SALDOS S WITH (NOLOCK)
		JOIN DJ_CAUSA_CUENTA F WITH (NOLOCK) ON S.JTS_OID = @pJtsOidCta 
												AND S.JTS_OID=F.JTS_OID_CUENTA 
												AND((F.TZ_LOCK < 300000000000000 OR F.TZ_LOCK >= 400000000000000) 
												AND (F.TZ_LOCK < 100000000000000 OR F.TZ_LOCK >= 200000000000000)) 
		JOIN DJ_CAUSAS C WITH (NOLOCK) ON C.NRO_CAUSA=F.NRO_CAUSA 
										AND((C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
										AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000)) 
		
		SELECT @vBloqueo=COD_BLOQUEO 
		FROM GRL_BLOQUEOS B WITH (NOLOCK) 
		WHERE B.SALDO_JTS_OID=@pJtsOidCta 
		AND ((B.TZ_LOCK < 300000000000000 OR B.TZ_LOCK >= 400000000000000) 
		AND (B.TZ_LOCK < 100000000000000 OR B.TZ_LOCK >= 200000000000000)) 
		
		IF @vSaldoCta > 0 OR @vEstado<>'A' OR (@vBloqueo<>9 AND @vBloqueo<>0)
		BEGIN
			SET @vValido = 0; 
			SET @pMsg = 'Sr Usuario, por Favor Verifique: No es posible dar de baja Cuenta seleccionada.';
		END
	END
	
	/*
	IF @vValido = 1
	BEGIN
		SELECT @vCantBeneficiarios = COUNT(*)
		FROM DJ_BENEFICIARIOS B
		WHERE B.NRO_CAUSA = @pNroCausa AND
		B.JTS_OID_CUENTA = @pJtsOidCta AND
		B.TZ_LOCK = 0;
	
		IF @vCantBeneficiarios > 0 
		BEGIN
			SET @vValido = 0; 
			SET @pMsg = 'La cuenta posee beneficiarios asociados';
		END
	END
	*/
	
	SET @pValido = @vValido;
END