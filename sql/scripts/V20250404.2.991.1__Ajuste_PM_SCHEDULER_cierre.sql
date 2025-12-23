EXECUTE('
--VACIO LA SCHEDULER para el cierre

DELETE FROM PM_SCHEDULER where NOMBREGRUPO=''     DIA - Procesos de Cierre Integrada '';
')

EXECUTE('
-------------
----CIERRE
-------------

INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 1
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Baja de asientos al cierre centralizado''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 2
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''PROCESO: Cambio de fecha sucursal virtual''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 3
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Cierre de Sucursales''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 4
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Marca Inicio de Cierre''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 5
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CAJ - Carga Saldos Caja Historico''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 6
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CAJ - Carga Saldos ATM Historico''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 7
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''REM - Reporte Movimiento Transportadora''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 8
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''REM - Reporte Movimiento Tesorero''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 9
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Actualizacion Diaria Historico de Tipos de Cambio''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 10
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CLI - Servicio Financiero Personas Juridicas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 11
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CLI - Servicio Financiero Personas Fisicas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 12
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CLI - Perfil Documental''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 13
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CLI - Rechazar Solicitud Integrante Juzgado''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 14
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CLI - Rechazar Solicitud Activar-Inactivar Causa''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 15
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Convenios Pago - Inactivacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 16
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Convenios Recaudacion - Inactivacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 17
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Convenios Pago - Baja''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 18
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Convenios Pago - Renovacion Baja''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 19
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Convenios Recaudacion - Baja''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 20
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Convenios Recaudacion - Renovacion Baja''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 21
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Liquidacion Debito Automatico''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 22
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Rendicion Debitos Automaticos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 23
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Servicio CV Remunerada''
	, ''f''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 24
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Analiza Cuentas Remuneradas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 25
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Comision mantenimiento Convenios''
	, ''f''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 26
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CVN - Liquidacion Recaudos Por Caja''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 27
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Reversa de letras y cheques''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 28
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cobertura entre Grupos de Cuentas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 29
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Bitacora Credeb para nuevas cuentas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 30
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Reservas Sobre Saldos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 31
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cobranza Cargos Diferidos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 32
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cobranza Cargos Diferidos FUCO''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 33
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Comision Mantenimiento de Cuentas Vista''
	, ''f''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 34
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Comision Mantenimiento Banca Empresa''
	, ''f''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 35
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Control de Paquete y Campanias''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 36
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cargos por Mantenimiento de Paquete''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 37
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Instrucciones de Traspaso entre Cuentas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 38
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cargo Estado de Cuenta ESPECIAL''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 39
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Cobranza Automatica Preparacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 40
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Cobranza Automatica Cuota por Cuota''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 41
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Cobranza Automatica''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 42
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA: Reservas Para Cobranza Automatica''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 43
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Adelanto haberes''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 44
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Baja Pendientes Topaz POS''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 45
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Baja Reserva Topaz POS''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 46
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Cobro Comisiones Garantia Otorgadas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 47
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Seguro Saldo Deudor''
	, ''m''
	, 2
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 48
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Vencimiento de Fianza''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 49
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Aviso de Vencimiento de Garantia''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 50
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Cambio de Rubro Vista''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 51
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cargo cuenta inmovilizada''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 52
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Bloqueo Cuentas Vista inmovilizadas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 53
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cancelacion de cuentas''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 54
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''Proceso - Corrimiento Vencimiento DPF''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 55
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''DPF - Inmovilizar saldos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 56
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''DPF - Cancela DPF UVAUVI''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 57
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''DPF - Cancela DPF Titulo Valor''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 58
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Saldos Diarios y Mensuales sin Promedio para Intereses Vista''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 59
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Intereses Vista Saldo o Promedio Pago''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 60
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Caida Automatica de Solicitudes de Asistencias''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 61
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Crea Cronograma Devengado Diferente Tasa Interes''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 62
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Devengar diferencia intereses tasa contractual/tasa mercado''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 63
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE- Crea Comision Desembolso''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 64
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL- DevengamientoComisionDesembolso''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 65
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Renovacion Subsidios''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 66
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualiza Riesgo Dolarizado''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 67
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualiza Cliente Dolarizado''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 68
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Asignacion de Credito Adicional''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 69
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Cancelacion Acuerdos y Sobregiros''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 70
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Extorno Contabilizacion Acuerdos en cuenta no utilizados''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 71
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Consumo de Acuerdos y Sobregiros''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 72
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Devengado Intereses Deudores N Acuerdos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 73
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''VTA - Cobro Intereses Deudores N Acuerdos''
	, ''m''
	, 2
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 74
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizar Tam-Empresa''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 75
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Recategorizacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 76
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Categoria Comercial del Cliente''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 77
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Categoria Comercial del Cliente Sin Categoria''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 78
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Devengamiento Saldo Proporcional al Plazo''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 79
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Analisis de devengado en suspenso''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 80
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Cambio de Rubro por Vencido o Forzado''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 81
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Devengamiento Plazo Extorno Contabilizacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 82
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Devengamiento Plazo Calculo''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 83
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Devengamiento Plazo Contabilizacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 84
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Genera IVA Financiado''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 85
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Certificados de Retencion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 86
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GAR - Borrado tabla''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 87
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GAR - Calculo Afectacion Garantias''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 88
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GAR - Calculo Afectacion Prestamos sin Garantias''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 89
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GAR - Extorno Contabilizacion Afectacion Garantias''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 90
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GAR - Contabilizacion Afectacion de Garantias''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 91
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Prepara Clasificacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 92
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Clasificacion Deuda No Refinanciada''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 93
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Calificacion Objetiva Deuda Refinanciada''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 94
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion detalle CENDEU''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 95
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion CENDEU Nuevos Clientes''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 96
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion Situacion Sistema Financiero''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 97
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion detalle de Morosos Ex Entidades''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 98
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion detalle de Morosos Ex Entidades nuevos clientes''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 99
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion Situacion Morosos Ex Entidades''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 100
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Borrado de situacion juridica''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 101
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Imputacion situacion juridica''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 102
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Borrado de discrepancia''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 103
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion de Discrepancia''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 104
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actualizacion Situacion Resultante''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 105
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Exposicion de Sobregiros''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 106
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Calculo de Prevision''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 107
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Actulizacion De Cuotas Prestamos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 108
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CRE - Sistema Interno de Calificacion''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 109
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Actualizar Movimientos ajustes UVA UVI''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 110
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Contabilizacion de ajustes UVA UVI''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 111
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Registro historico fin de mes UVA UVI''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 112
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Calculo Impuesto Movimiento Moneda Extranjera''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 113
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Operaciones cambio retroactiva''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 114
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Resultados por Tenencia de Moneda Extranjera''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 115
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Resultados por Operaciones de Cambio''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 116
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Reaplica movimientos fecha valor en Saldos Diarios_Procesa todos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 117
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Solo Saldos Diarios''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 118
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Saldos Diarios Contabilidad Actualizar - Fecha Valor''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 119
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Saldos Diarios Contabilidad''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 120
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''BAL - Generacion de Balance Diario''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 121
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Reporte Saldos Diarios Inconsistentes''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 122
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''CBL - Reporte Asientos Abiertos''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)


INSERT INTO dbo.PM_SCHEDULER
	(
	TZ_LOCK
	, ORDINAL
	, NOMBREGRUPO
	, NOMBREHIJO
	, PERIODICIDAD
	, DIA
	, FECHAPROXEJECUCION
	, HABILES
	)
VALUES
	(
	0
	, 123
	, ''     DIA - Procesos de Cierre Integrada ''
	, ''GRL - Marca Fin de Cierre''
	, ''d''
	, 0
	, ''20990101''
	, 1
	)
')

EXECUTE('
--A TODOS FECHA PROX PROCESO = 20250404
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20250404''
WHERE NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--CVN - Servicio CV Remunerada - CORRE MENSUAL
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20250430''
WHERE ORDINAL = 23 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--CVN - Comision mantenimiento Convenios - CORRE MENSUAL
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20250430''
WHERE ORDINAL = 25 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''VTA - Comision Mantenimiento de Cuentas Vista'' - CORRE MENSUAL
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20250430''
WHERE ORDINAL = 33 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''VTA - Comision Mantenimiento Banca Empresa'' - CORRE MENSUAL
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20250430''
WHERE ORDINAL = 34 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''VTA - Seguro Saldo Deudor'' - CORRE 2do dia habil
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20250505''
WHERE ORDINAL = 47 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''VTA - Cobro Intereses Deudores N Acuerdos'' - CORRE EL 2do DIA DEL MES
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20250505''
WHERE ORDINAL = 73 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''VTA - Cargo Estado de Cuenta ESPECIAL'' - NO CORRE
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20990101''
WHERE ORDINAL = 38 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''VTA: Reservas Para Cobranza Automatica'' - NO CORRE
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20990101''
WHERE ORDINAL = 42 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''CRE - Asignacion de Credito Adicional'' - NO CORRE
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20990101''
WHERE ORDINAL = 68 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''

--''CRE - Sistema Interno de Calificacion'' - NO CORRE
UPDATE dbo.PM_SCHEDULER
SET FECHAPROXEJECUCION = ''20990101''
WHERE ORDINAL = 108 AND NOMBREGRUPO = ''     DIA - Procesos de Cierre Integrada ''
')