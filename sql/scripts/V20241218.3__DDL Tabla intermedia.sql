execute('drop table if exists dbo.ITF_IB_CODTR_CODIB;');

execute(
'
create table dbo.ITF_IB_CODTR_CODIB 
(
	CODIGO_TRANSACCION numeric(5,0) not null, 
	CODIGO_INTERBANKING varchar(6) not null, 
	CODIGO_IB_REVERSA varchar(6) null, 
	constraint PK_ITF_IB_CODTR_CODIB primary key (CODIGO_TRANSACCION) 
);
'
);
