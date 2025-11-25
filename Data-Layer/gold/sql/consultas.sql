
SELECT
    SUM(f.dst)::bigint                                   AS total_discentes,
    SUM(f.ins)::bigint                                    AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct,
    SUM(f.cnc)::bigint                                     AS total_cancelamentos,
    SUM(f.trc)::bigint                                    AS total_trancamentos,
    (SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal))::bigint AS total_reprovacoes
FROM dw.fat_ins_dsc f;


SELECT
    d.nme_dpt,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nme_dpt
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC;


SELECT
    c.nme_cur,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_cur c ON c.srk_cur = f.srk_cur
GROUP BY c.nme_cur
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC;


SELECT
    t.ano,
    t."sem_ano",
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
GROUP BY t.ano, t."sem_ano"
ORDER BY t.ano, t."sem_ano";


SELECT
    dd.cod_dsc,
    dd.nme_dsc,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_dsc dd ON dd.srk_dsc = f.srk_dsc
GROUP BY dd.cod_dsc, dd.nme_dsc
HAVING SUM(f.dst) >= 100
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC
LIMIT 20;


SELECT
    dd.cod_dsc,
    dd.nme_dsc,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_dsc dd ON dd.srk_dsc = f.srk_dsc
GROUP BY dd.cod_dsc, dd.nme_dsc
HAVING SUM(f.dst) >= 100
ORDER BY total_insucessos DESC, taxa_insucesso_pct DESC
LIMIT 20;


WITH agg AS (
    SELECT
        SUM(f.rpv_med)      AS rpv_med,
        SUM(f.rpv_not)      AS rpv_not,
        SUM(f.rpv_fal)      AS rpv_fal,
        SUM(f.rpv_med_fal)  AS rpv_med_fal,
        SUM(f.rpv_not_fal)  AS rpv_not_fal
    FROM dw.fat_ins_dsc f
), tot AS (
    SELECT (rpv_med + rpv_not + rpv_fal + rpv_med_fal + rpv_not_fal) AS total FROM agg
)
SELECT
    a.rpv_med,
    a.rpv_not,
    a.rpv_fal,
    a.rpv_med_fal,
    a.rpv_not_fal,
    t.total AS total_reprovacoes,
    ROUND(a.rpv_med::numeric     / NULLIF(t.total, 0) * 100, 2) AS pct_rpv_med,
    ROUND(a.rpv_not::numeric     / NULLIF(t.total, 0) * 100, 2) AS pct_rpv_not,
    ROUND(a.rpv_fal::numeric     / NULLIF(t.total, 0) * 100, 2) AS pct_rpv_fal,
    ROUND(a.rpv_med_fal::numeric / NULLIF(t.total, 0) * 100, 2) AS pct_rpv_med_fal,
    ROUND(a.rpv_not_fal::numeric / NULLIF(t.total, 0) * 100, 2) AS pct_rpv_not_fal
FROM agg a
CROSS JOIN tot t;


SELECT
    d.nme_dpt,
    SUM(f.rpv_med)     AS rpv_med,
    SUM(f.rpv_not)     AS rpv_not,
    SUM(f.rpv_fal)     AS rpv_fal,
    SUM(f.rpv_med_fal) AS rpv_med_fal,
    SUM(f.rpv_not_fal) AS rpv_not_fal,
    (SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal)) AS total_reprovacoes,
    ROUND(SUM(f.rpv_med)::numeric     / NULLIF((SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal)), 0) * 100, 2) AS pct_rpv_med,
    ROUND(SUM(f.rpv_not)::numeric     / NULLIF((SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal)), 0) * 100, 2) AS pct_rpv_not,
    ROUND(SUM(f.rpv_fal)::numeric     / NULLIF((SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal)), 0) * 100, 2) AS pct_rpv_fal,
    ROUND(SUM(f.rpv_med_fal)::numeric / NULLIF((SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal)), 0) * 100, 2) AS pct_rpv_med_fal,
    ROUND(SUM(f.rpv_not_fal)::numeric / NULLIF((SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal)), 0) * 100, 2) AS pct_rpv_not_fal
FROM dw.fat_ins_dsc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nme_dpt
ORDER BY total_reprovacoes DESC;


SELECT
    d.nme_dpt,
    c.nme_cur,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
JOIN dw.dim_cur c ON c.srk_cur = f.srk_cur
GROUP BY d.nme_dpt, c.nme_cur
ORDER BY d.nme_dpt, taxa_insucesso_pct DESC, c.nme_cur;


WITH serie AS (
    SELECT
        d.nme_dpt,
        t.ano,
        t."sem_ano",
        SUM(f.dst) AS dst,
        SUM(f.ins)  AS ins
    FROM dw.fat_ins_dsc f
    JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
    JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
    GROUP BY d.nme_dpt, t.ano, t."sem_ano"
), taxa AS (
    SELECT
        nme_dpt,
        ano,
        "sem_ano",
        ROUND(ins::numeric / NULLIF(dst, 0) * 100, 2) AS taxa_insucesso_pct
    FROM serie
)
SELECT
    nme_dpt,
    ano,
    "sem_ano",
    taxa_insucesso_pct,
    ROUND(taxa_insucesso_pct - LAG(taxa_insucesso_pct) OVER (PARTITION BY nme_dpt ORDER BY ano, "sem_ano"), 2) AS delta_pct
FROM taxa
ORDER BY nme_dpt, ano, "sem_ano";


SELECT
    d.nme_dpt,
    SUM(f.ins)                                            AS insucessos,
    SUM(SUM(f.ins)) OVER ()                               AS insucessos_total,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(SUM(f.ins)) OVER (), 0) * 100, 2) AS pct_contribuicao
FROM dw.fat_ins_dsc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nme_dpt
ORDER BY pct_contribuicao DESC;


WITH por_sem AS (
    SELECT
        dd.cod_dsc,
        dd.nme_dsc,
        t.ano,
        t."sem_ano",
        SUM(f.dst) AS dst,
        SUM(f.ins)  AS ins
    FROM dw.fat_ins_dsc f
    JOIN dw.dim_dsc dd ON dd.srk_dsc = f.srk_dsc
    JOIN dw.dim_tmp  t  ON t.srk_tmp  = f.srk_tmp
    GROUP BY dd.cod_dsc, dd.nme_dsc, t.ano, t."sem_ano"
), taxas AS (
    SELECT
        cod_dsc,
        nme_dsc,
        ano,
        "sem_ano",
        CASE WHEN dst > 0 THEN ins::numeric / dst * 100 ELSE NULL END AS taxa_pct
    FROM por_sem
), aggr AS (
    SELECT
        cod_dsc,
        nme_dsc,
        COUNT(taxa_pct)                                      AS semestres_com_dados,
        ROUND(AVG(taxa_pct)::numeric, 2)                     AS taxa_media_pct,
        ROUND(STDDEV_POP(taxa_pct)::numeric, 2)              AS volatilidade_pct
    FROM taxas
    GROUP BY cod_dsc, nme_dsc
    HAVING COUNT(taxa_pct) >= 2 AND SUM(1) >= 2
)
SELECT *
FROM aggr
ORDER BY volatilidade_pct DESC, taxa_media_pct DESC
LIMIT 30;


SELECT
    c.nme_cur,
    dd.cod_dsc,
    dd.nme_dsc,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct,
    RANK() OVER (PARTITION BY c.nme_cur ORDER BY SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) DESC NULLS LAST) AS rank_taxa_no_curso
FROM dw.fat_ins_dsc f
JOIN dw.dim_cur c  ON c.srk_cur  = f.srk_cur
JOIN dw.dim_dsc dd ON dd.srk_dsc = f.srk_dsc
GROUP BY c.nme_cur, dd.cod_dsc, dd.nme_dsc
HAVING SUM(f.dst) >= 80
ORDER BY c.nme_cur, rank_taxa_no_curso;


SELECT
    dd.cod_dsc,
    dd.nme_dsc,
    t.ano,
    t."sem_ano",
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_dsc dd ON dd.srk_dsc = f.srk_dsc
JOIN dw.dim_tmp  t  ON t.srk_tmp  = f.srk_tmp
GROUP BY dd.cod_dsc, dd.nme_dsc, t.ano, t."sem_ano"
ORDER BY dd.cod_dsc, t.ano, t."sem_ano";


SELECT
    c.nme_cur,
    t.ano,
    t."sem_ano",
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_cur c ON c.srk_cur = f.srk_cur
JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
GROUP BY c.nme_cur, t.ano, t."sem_ano"
ORDER BY c.nme_cur, t.ano, t."sem_ano";


SELECT
    d.nme_dpt,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.cnc)                                             AS total_cancelamentos,
    SUM(f.trc)                                            AS total_trancamentos,
    ROUND(SUM(f.cnc)::numeric  / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_cancelamento_pct,
    ROUND(SUM(f.trc)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_trancamento_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nme_dpt
ORDER BY taxa_cancelamento_pct DESC;


SELECT
    t.ano,
    t."sem_ano",
    SUM(f.ins) AS total_insucessos,
    SUM(f.dst) AS total_discentes,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
GROUP BY t.ano, t."sem_ano"
ORDER BY total_insucessos DESC
LIMIT 10;


