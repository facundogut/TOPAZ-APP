/****** Object:  StoredProcedure [dbo].[SP_ITF_MOVS_ENTREFECHAS]    Script Date: 02/06/2021 15:50:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_ITF_MOVS_ENTREFECHAS]

  @P_SUCURSAL_CUENTA float(53),
  @P_MONEDA float(53),
  @P_CUENTA float(53),
  @P_PRODUCTO float(53),
  @P_FECHA_DESDE datetime2(0),
  @P_FECHA_HASTA datetime2(0)

as

begin

  begin try

    declare
	  @LINEA_REG$FECHAPROCESO     datetime2,
	  @LINEA_REG$HORASISTEMA      varchar,
	  @LINEA_REG$CLIENTE          float,
	  @LINEA_REG$SUCURSAL_CUENTA  float,
	  @LINEA_REG$CUENTA           float,
	  @LINEA_REG$MONEDA           float,
	  @LINEA_REG$PRODUCTO         float,
	  @LINEA_REG$OPERACION_CUENTA float,
	  @LINEA_REG$SUCURSAL         float,
	  @LINEA_REG$FECHAVALOR       datetime2,
	  @LINEA_REG$ASIENTO          float,
	  @LINEA_REG$CONCEPTO         varchar, 
	  @LINEA_REG$CAPITALREALIZADO float,
	  @LINEA_REG$DEBITOCREDITO    varchar,
	  @LINEA_REG$NUMERO_CHEQUE    float,
	  @LINEA_REG$INIUSR           varchar,
	  @LINEA_REG$OPERACION_TOPAZ  float,
	  @V_FECHACONSULTA            datetime2 = SYSDATETIME(), 
      @V_COMPROBANTE              numeric(12), 
      @V_NROCHEQUE                numeric(12) = 0, 
      @V_ORDINAL_MOVS             numeric(15) = 1, 
      @V_TIPOPRODUCTO             numeric(1), 
      @V_SALDOACTUAL              numeric(15,2), 
      @V_SALDOPENDIENTES          numeric(15,2), 
      @V_SALDODISPONIBLE          numeric(15,2), 
      @V_SALDOCONFIRMAR           numeric(15,2), 
      @V_SALDOSIGUIENTE           numeric(15,2), 
      @V_SALDOGARANTIA            numeric(15,2), 
      @V_CAPITAL                  numeric(15,2), 
      @V_FECHAAPERTURA            datetime2(0), 
      @V_FECHAVTO                 datetime2(0), 
      @V_PLAZO                    numeric(4), 
      @V_TASA                     numeric(10,6), 
      @V_INTDEVENGAR              numeric(15,2), 
      @V_INTDEVENGADO             numeric(15,2), 
      @V_ORDINAL_CUENTA           numeric(3) = 0, 
      @USUARIO_MOV                varchar(4), 
      @V_ORDINAL_DPF              numeric(4) = 0
	  
    delete    ITF_REPORTE_ENTRE_FECHAS
	where     SUCURSAL_CUENTA = @P_SUCURSAL_CUENTA
	          and CUENTA      = @P_CUENTA
			  and MONEDA      = @P_MONEDA
			  and PRODUCTO    = @P_PRODUCTO
			  and FECHA_DESDE = @P_FECHA_DESDE
			  and FECHA_HASTA = @P_FECHA_HASTA

    if @@TRANCOUNT > 0
	  commit WORK 

    declare MOVS_REG cursor local for
	  select    FECHAPROCESO, HORASISTEMA, CLIENTE, 
				SUCURSAL_CUENTA, CUENTA, MONEDA, PRODUCTO, 
				OPERACION_CUENTA, SUCURSAL, FECHAVALOR, ASIENTO, 
				CONCEPTO, CAPITALREALIZADO, DEBITOCREDITO, 
				NUMERO_CHEQUE, INIUSR, OPERACION_TOPAZ
      from      VW_ULTIMOS_10_MOVS WITH (NOLOCK)
      where     SUCURSAL_CUENTA  = @P_SUCURSAL_CUENTA
	            and MONEDA       = @P_MONEDA
				and CUENTA       = @P_CUENTA
				and PRODUCTO     = @P_PRODUCTO
				and FECHAPROCESO >= @P_FECHA_DESDE
				and FECHAPROCESO <= @P_FECHA_HASTA
      order by  FECHAPROCESO

    open MOVS_REG
	
	  while 1 = 1

	    begin
		
		  fetch MOVS_REG into 
            @LINEA_REG$FECHAPROCESO, 
            @LINEA_REG$HORASISTEMA, 
            @LINEA_REG$CLIENTE, 
            @LINEA_REG$SUCURSAL_CUENTA, 
            @LINEA_REG$CUENTA, 
            @LINEA_REG$MONEDA, 
            @LINEA_REG$PRODUCTO, 
            @LINEA_REG$OPERACION_CUENTA, 
            @LINEA_REG$SUCURSAL, 
            @LINEA_REG$FECHAVALOR, 
            @LINEA_REG$ASIENTO, 
            @LINEA_REG$CONCEPTO, 
            @LINEA_REG$CAPITALREALIZADO, 
            @LINEA_REG$DEBITOCREDITO, 
            @LINEA_REG$NUMERO_CHEQUE, 
            @LINEA_REG$INIUSR, 
            @LINEA_REG$OPERACION_TOPAZ

            if @@FETCH_STATUS <> 0
              break

            set @V_NROCHEQUE = @LINEA_REG$NUMERO_CHEQUE

			if @V_NROCHEQUE is NULL
			  set @V_NROCHEQUE = 0
			  set @V_COMPROBANTE = @LINEA_REG$ASIENTO

            if @V_ORDINAL_MOVS < 4000

			  begin
			  
			    insert into ITF_REPORTE_ENTRE_FECHAS(SUCURSAL_CUENTA, CUENTA, MONEDA, PRODUCTO, OPERACION, FECHA_DESDE, FECHA_HASTA, FECHA_PROCESADO, HORASISTEMA, CLIENTE, FECHA_VALOR, DEBITO_CREDITO, MONTO, CONCEPTO, NROCOMPROBANTE, NROCHEQUE, SUCURSAL_MOV, OPERACION_MOV, ORDINAL_MOV, USUARIO_MOV)
                values                              (@P_SUCURSAL_CUENTA, @P_CUENTA, @P_MONEDA, @P_PRODUCTO, @LINEA_REG$OPERACION_CUENTA, @P_FECHA_DESDE, @P_FECHA_HASTA, @LINEA_REG$FECHAPROCESO, @LINEA_REG$HORASISTEMA, @LINEA_REG$CLIENTE, @LINEA_REG$FECHAVALOR, @LINEA_REG$DEBITOCREDITO, @LINEA_REG$CAPITALREALIZADO, upper(@LINEA_REG$CONCEPTO), @V_COMPROBANTE, @V_NROCHEQUE, @LINEA_REG$SUCURSAL, @LINEA_REG$OPERACION_TOPAZ, @V_ORDINAL_MOVS, @LINEA_REG$INIUSR)

                set @V_ORDINAL_MOVS = @V_ORDINAL_MOVS + 1

			  end

            else
			
			  break

	    end

    close MOVS_REG
	
	deallocate MOVS_REG
	
	if @@TRANCOUNT > 0
	  commit WORK 

  end try

  begin catch
  
    declare
	  @ERROR_CODE numeric(4)   = ERROR_NUMBER(),
      @ERROR_MSG  varchar(300) = ERROR_MESSAGE(),
      @BIGERRMSG  varchar(4000)

    begin
	
	  if @@TRANCOUNT > 0
	    rollback WORK
		
	  set @BIGERRMSG = CONCAT(ERROR_NUMBER(), ': at "', ERROR_PROCEDURE(), '", line ', ERROR_LINE())

    end

  end catch

end
