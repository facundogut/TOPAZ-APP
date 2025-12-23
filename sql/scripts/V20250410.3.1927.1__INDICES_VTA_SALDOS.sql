EXECUTE('
	drop index if exists IDX_VTA_SALDOS_CTA_CBU on dbo.VTA_SALDOS;
	drop index if exists VTA_SALDOS_CTA_REDLINK_IDX on dbo.VTA_SALDOS;
	drop index if exists IDX_CTA_INTERBANK on dbo.VTA_SALDOS;
	drop index if exists IDX_OPERAIB on dbo.VTA_SALDOS;
	drop index if exists IDX_OPERABE on dbo.VTA_SALDOS;
	drop index if exists IDX_CTA_CBU on dbo.VTA_SALDOS;
	drop index if exists IDX_CTA_REDLINK on dbo.VTA_SALDOS;
');

EXECUTE('
	create nonclustered index IDX_CTA_INTERBANK on dbo.VTA_SALDOS (CTA_INTERBANK) include (TZ_LOCK);
	create nonclustered index IDX_OPERAIB on dbo.VTA_SALDOS (OPERAIB) include (TZ_LOCK);
	create nonclustered index IDX_OPERABE on dbo.VTA_SALDOS (OPERABE) include (TZ_LOCK);
	create nonclustered index IDX_CTA_CBU on dbo.VTA_SALDOS (CTA_CBU) include (TZ_LOCK);
	create nonclustered index IDX_CTA_REDLINK on dbo.VTA_SALDOS (CTA_REDLINK) include (TZ_LOCK);
');
