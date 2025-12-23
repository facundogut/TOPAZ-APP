
execute ('
CREATE OR ALTER VIEW [dbo].[VW_CLI_DOCUMENTOSPFPJ_MEJORADA] (
														TZ_LOCK, 
														NUMEROPERSONAFJ, 
														TIPODOCUMENTO, 
														NUMERODOCUMENTO, 
														PAISDOCUMENTO, 
														FECHAPRESENTACION, 
														FECHAVENCIMIENTO, 
														REPORTAAORGANISMOCONTROL, 
														TIPOPERSONA)
AS 
   SELECT 
      CLI_DOCUMENTOSPFPJ1.TZ_LOCK, 
      CLI_DOCUMENTOSPFPJ1.NUMEROPERSONAFJ, 
      CLI_DOCUMENTOSPFPJ1.TIPODOCUMENTO, 
      CLI_DOCUMENTOSPFPJ1.NUMERODOCUMENTO, 
      CLI_DOCUMENTOSPFPJ1.PAISDOCUMENTO, 
      CLI_DOCUMENTOSPFPJ1.FECHAPRESENTACION, 
      CLI_DOCUMENTOSPFPJ1.FECHAVENCIMIENTO, 
      CLI_DOCUMENTOSPFPJ1.REPORTAAORGANISMOCONTROL, 
      CLI_DOCUMENTOSPFPJ1.TIPOPERSONA
   FROM dbo.CLI_DOCUMENTOSPFPJ  AS CLI_DOCUMENTOSPFPJ1 WITH(NOLOCK)
   WHERE 
      (CLI_DOCUMENTOSPFPJ1.TZ_LOCK < 300000000000000 OR CLI_DOCUMENTOSPFPJ1.TZ_LOCK >= 400000000000000) AND 
      (CLI_DOCUMENTOSPFPJ1.TZ_LOCK < 100000000000000 OR CLI_DOCUMENTOSPFPJ1.TZ_LOCK >= 200000000000000) AND 
      CLI_DOCUMENTOSPFPJ1.TIPOPERSONA = ''F'' AND 
      CLI_DOCUMENTOSPFPJ1.TIPODOCUMENTO = ''IDE''
    UNION ALL
   SELECT 
      CLI_DOCUMENTOSPFPJ2.TZ_LOCK, 
      CLI_DOCUMENTOSPFPJ2.NUMEROPERSONAFJ, 
      CLI_DOCUMENTOSPFPJ2.TIPODOCUMENTO, 
      CLI_DOCUMENTOSPFPJ2.NUMERODOCUMENTO, 
      CLI_DOCUMENTOSPFPJ2.PAISDOCUMENTO, 
      CLI_DOCUMENTOSPFPJ2.FECHAPRESENTACION, 
      CLI_DOCUMENTOSPFPJ2.FECHAVENCIMIENTO, 
      CLI_DOCUMENTOSPFPJ2.REPORTAAORGANISMOCONTROL, 
      CLI_DOCUMENTOSPFPJ2.TIPOPERSONA
   FROM dbo.CLI_DOCUMENTOSPFPJ  AS CLI_DOCUMENTOSPFPJ2 WITH(NOLOCK)
   WHERE 
      (CLI_DOCUMENTOSPFPJ2.TZ_LOCK < 300000000000000 OR CLI_DOCUMENTOSPFPJ2.TZ_LOCK >= 400000000000000) AND 
      (CLI_DOCUMENTOSPFPJ2.TZ_LOCK < 100000000000000 OR CLI_DOCUMENTOSPFPJ2.TZ_LOCK >= 200000000000000) AND 
      CLI_DOCUMENTOSPFPJ2.TIPOPERSONA = ''J'' AND 
      CLI_DOCUMENTOSPFPJ2.TIPODOCUMENTO = ''RUC''
    UNION ALL
   SELECT 
      D01.TZ_LOCK, 
      D01.NUMEROPERSONAFJ, 
      D01.TIPODOCUMENTO, 
      D01.NUMERODOCUMENTO, 
      D01.PAISDOCUMENTO, 
      D01.FECHAPRESENTACION, 
      D01.FECHAVENCIMIENTO, 
      D01.REPORTAAORGANISMOCONTROL, 
      D01.TIPOPERSONA
   FROM dbo.CLI_DOCUMENTOSPFPJ  AS D01 WITH(NOLOCK)
   WHERE 
      EXISTS 
         (
            SELECT il.ilc, il.ilc$2
            FROM 
               (
                  SELECT fci.TIPODOCUMENTO1, fci.NUMEROPERSONAFJ1
                  FROM 
                     (
                        SELECT D1.NUMEROPERSONAFJ AS NUMEROPERSONAFJ1, max(D1.TIPODOCUMENTO) AS TIPODOCUMENTO1
                        FROM dbo.CLI_DOCUMENTOSPFPJ  AS D1 WITH(NOLOCK)
                        WHERE 
                           (D1.TZ_LOCK < 300000000000000 OR D1.TZ_LOCK >= 400000000000000) AND 
                           (D1.TZ_LOCK < 100000000000000 OR D1.TZ_LOCK >= 200000000000000) AND 
                           D1.TIPOPERSONA = ''F'' AND 
                           NOT EXISTS 
                           (
                              SELECT 
                                 D11.TZ_LOCK, 
                                 D11.NUMEROPERSONAFJ, 
                                 D11.TIPODOCUMENTO, 
                                 D11.NUMERODOCUMENTO, 
                                 D11.PAISDOCUMENTO, 
                                 D11.FECHAPRESENTACION, 
                                 D11.FECHAVENCIMIENTO, 
                                 D11.REPORTAAORGANISMOCONTROL, 
                                 D11.TIPOPERSONA
                              FROM dbo.CLI_DOCUMENTOSPFPJ  AS D11 WITH(NOLOCK)
                              WHERE 
                                 (D11.TZ_LOCK < 300000000000000 OR D11.TZ_LOCK >= 400000000000000) AND 
                                 (D11.TZ_LOCK < 100000000000000 OR D11.TZ_LOCK >= 200000000000000) AND 
                                 D11.TIPOPERSONA = ''F'' AND 
                                 D11.TIPODOCUMENTO = ''IDE'' AND 
                                 D1.NUMEROPERSONAFJ = D11.NUMEROPERSONAFJ
                           )
                        GROUP BY D1.NUMEROPERSONAFJ
                     )  AS fci
               )  AS il(ilc, ilc$2) 
            WHERE (il.ilc = ( D01.TIPODOCUMENTO )) AND (il.ilc$2 = ( D01.NUMEROPERSONAFJ ))
         )
    UNION ALL
   SELECT 
      D02.TZ_LOCK, 
      D02.NUMEROPERSONAFJ, 
      D02.TIPODOCUMENTO, 
      D02.NUMERODOCUMENTO, 
      D02.PAISDOCUMENTO, 
      D02.FECHAPRESENTACION, 
      D02.FECHAVENCIMIENTO, 
      D02.REPORTAAORGANISMOCONTROL, 
      D02.TIPOPERSONA
   FROM dbo.CLI_DOCUMENTOSPFPJ  AS D02 WITH(NOLOCK)
   WHERE 
      EXISTS 
         (
            SELECT ilc, ilc$2
            FROM 
               (
                  SELECT fci.TIPODOCUMENTO1, fci.NUMEROPERSONAFJ1
                  FROM 
                     (
                        SELECT D2.NUMEROPERSONAFJ AS NUMEROPERSONAFJ1, max(D2.TIPODOCUMENTO) AS TIPODOCUMENTO1
                        FROM dbo.CLI_DOCUMENTOSPFPJ  AS D2 WITH(NOLOCK)
                        WHERE 
                           (D2.TZ_LOCK < 300000000000000 OR D2.TZ_LOCK >= 400000000000000) AND 
                           (D2.TZ_LOCK < 100000000000000 OR D2.TZ_LOCK >= 200000000000000) AND 
                           D2.TIPOPERSONA = ''J'' AND 
                           NOT EXISTS 
                           (
                              SELECT 
                                 D12.TZ_LOCK, 
                                 D12.NUMEROPERSONAFJ, 
                                 D12.TIPODOCUMENTO, 
                                 D12.NUMERODOCUMENTO, 
                                 D12.PAISDOCUMENTO, 
                                 D12.FECHAPRESENTACION, 
                                 D12.FECHAVENCIMIENTO, 
                                 D12.REPORTAAORGANISMOCONTROL, 
                                 D12.TIPOPERSONA
                              FROM dbo.CLI_DOCUMENTOSPFPJ  AS D12 WITH(NOLOCK)
                              WHERE 
                                 (D12.TZ_LOCK < 300000000000000 OR D12.TZ_LOCK >= 400000000000000) AND 
                                 (D12.TZ_LOCK < 100000000000000 OR D12.TZ_LOCK >= 200000000000000) AND 
                                 D12.TIPOPERSONA = ''J'' AND 
                                 D12.TIPODOCUMENTO = ''RUC'' AND 
                                 D2.NUMEROPERSONAFJ = D12.NUMEROPERSONAFJ
                           )
                        GROUP BY D2.NUMEROPERSONAFJ
                     )  AS fci
               )  AS il(ilc, ilc$2)
            WHERE (il.ilc = ( D02.TIPODOCUMENTO )) AND (il.ilc$2 = ( D02.NUMEROPERSONAFJ ))
         )

')




