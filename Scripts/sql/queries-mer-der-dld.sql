-- Consultas analíticas para Data Visualization (baseadas apenas na camada Gold - schema dw)
-- Confirmado no DDL:
--   dw.dim_disc(srk_disc, cod_disc, nm_disc)
--   dw.dim_tmp (srk_tmp, ano, sem_ano)
--   dw.dim_dpt (srk_dpt, nm_dpt)
--   dw.dim_cur (srk_cur, nome_cur)
--   dw.fato_insuc (..., turm, discen, canc, rpv_med, rpv_not, rpv_fal, rpv_med_fal, rpv_not_fal, tranc, insuc)
-- Observação: use cada SELECT como fonte de visual no Power BI. Ajuste LIMITs/HAVING conforme necessidade.


-- 00) (Opcional) Fixar search_path para facilitar execução manual
-- SET search_path TO dw, public;


-- 01) KPIs gerais (visão macro do período completo)
SELECT
    SUM(f.discen)::bigint                                   AS total_discentes,
    SUM(f.insuc)::bigint                                    AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct,
    SUM(f.canc)::bigint                                     AS total_cancelamentos,
    SUM(f.tranc)::bigint                                    AS total_trancamentos,
    (SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal))::bigint AS total_reprovacoes
FROM dw.fato_insuc f;


-- 02) Insucesso por Departamento (ranking por taxa e volume)
SELECT
    d.nm_dpt,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nm_dpt
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC;


-- 03) Insucesso por Curso (ranking por taxa e volume)
SELECT
    c.nome_cur,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_cur c ON c.srk_cur = f.srk_cur
GROUP BY c.nome_cur
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC;


-- 04) Série temporal (por semestre) - evolução da taxa de insucesso
SELECT
    t.ano,
    t.sem_ano,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
GROUP BY t.ano, t.sem_ano
ORDER BY t.ano, t.sem_ano;


-- 05) Top disciplinas por taxa de insucesso (com mínimo de alunos para robustez)
-- Ajuste o mínimo conforme necessidade (ex.: 100, 200...)
SELECT
    dd.cod_disc,
    dd.nm_disc,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_disc dd ON dd.srk_disc = f.srk_disc
GROUP BY dd.cod_disc, dd.nm_disc
HAVING SUM(f.discen) >= 100
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC
LIMIT 20;


-- 06) Top disciplinas por volume de insucesso (com mínimo de alunos)
SELECT
    dd.cod_disc,
    dd.nm_disc,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_disc dd ON dd.srk_disc = f.srk_disc
GROUP BY dd.cod_disc, dd.nm_disc
HAVING SUM(f.discen) >= 100
ORDER BY total_insucessos DESC, taxa_insucesso_pct DESC
LIMIT 20;


-- 07) Distribuição das causas de reprovação (visão geral, proporções)
WITH agg AS (
    SELECT
        SUM(f.rpv_med)      AS rpv_med,
        SUM(f.rpv_not)      AS rpv_not,
        SUM(f.rpv_fal)      AS rpv_fal,
        SUM(f.rpv_med_fal)  AS rpv_med_fal,
        SUM(f.rpv_not_fal)  AS rpv_not_fal
    FROM dw.fato_insuc f
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


-- 08) Causas de reprovação por Departamento (valores e proporções internas)
SELECT
    d.nm_dpt,
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
FROM dw.fato_insuc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nm_dpt
ORDER BY total_reprovacoes DESC;


-- 09) Matriz Departamento x Curso (taxa de insucesso)
SELECT
    d.nm_dpt,
    c.nome_cur,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
JOIN dw.dim_cur c ON c.srk_cur = f.srk_cur
GROUP BY d.nm_dpt, c.nome_cur
ORDER BY d.nm_dpt, taxa_insucesso_pct DESC, c.nome_cur;


-- 10) Evolução da taxa por Departamento com variação semestre a semestre
WITH serie AS (
    SELECT
        d.nm_dpt,
        t.ano,
        t.sem_ano,
        SUM(f.discen) AS discen,
        SUM(f.insuc)  AS insuc
    FROM dw.fato_insuc f
    JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
    JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
    GROUP BY d.nm_dpt, t.ano, t.sem_ano
), taxa AS (
    SELECT
        nm_dpt,
        ano,
        sem_ano,
        ROUND(insuc::numeric / NULLIF(discen, 0) * 100, 2) AS taxa_insucesso_pct
    FROM serie
)
SELECT
    nm_dpt,
    ano,
    sem_ano,
    taxa_insucesso_pct,
    ROUND(taxa_insucesso_pct - LAG(taxa_insucesso_pct) OVER (PARTITION BY nm_dpt ORDER BY ano, sem_ano), 2) AS delta_pct
FROM taxa
ORDER BY nm_dpt, ano, sem_ano;


-- 11) Contribuição de cada Departamento para o insucesso total
SELECT
    d.nm_dpt,
    SUM(f.insuc)                                            AS insucessos,
    SUM(SUM(f.insuc)) OVER ()                               AS insucessos_total,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(SUM(f.insuc)) OVER (), 0) * 100, 2) AS pct_contribuicao
FROM dw.fato_insuc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nm_dpt
ORDER BY pct_contribuicao DESC;


-- 12) Volatilidade da taxa por Disciplina (estabilidade ao longo do tempo)
-- Útil para identificar disciplinas com taxa muito irregular entre semestres.
WITH por_sem AS (
    SELECT
        dd.cod_disc,
        dd.nm_disc,
        t.ano,
        t.sem_ano,
        SUM(f.discen) AS discen,
        SUM(f.insuc)  AS insuc
    FROM dw.fato_insuc f
    JOIN dw.dim_disc dd ON dd.srk_disc = f.srk_disc
    JOIN dw.dim_tmp  t  ON t.srk_tmp  = f.srk_tmp
    GROUP BY dd.cod_disc, dd.nm_disc, t.ano, t.sem_ano
), taxas AS (
    SELECT
        cod_disc,
        nm_disc,
        ano,
        sem_ano,
        CASE WHEN discen > 0 THEN insuc::numeric / discen * 100 ELSE NULL END AS taxa_pct
    FROM por_sem
), aggr AS (
    SELECT
        cod_disc,
        nm_disc,
        COUNT(taxa_pct)                                      AS semestres_com_dados,
        ROUND(AVG(taxa_pct)::numeric, 2)                     AS taxa_media_pct,
        ROUND(STDDEV_POP(taxa_pct)::numeric, 2)              AS volatilidade_pct
    FROM taxas
    GROUP BY cod_disc, nm_disc
    HAVING COUNT(taxa_pct) >= 2 AND SUM(1) >= 2
)
SELECT *
FROM aggr
ORDER BY volatilidade_pct DESC, taxa_media_pct DESC
LIMIT 30;


-- 13) Ranking de Disciplinas dentro de cada Curso (por taxa, com mínimo de alunos)
-- Útil para visuais com slicer de curso.
SELECT
    c.nome_cur,
    dd.cod_disc,
    dd.nm_disc,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct,
    RANK() OVER (PARTITION BY c.nome_cur ORDER BY SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) DESC NULLS LAST) AS rank_taxa_no_curso
FROM dw.fato_insuc f
JOIN dw.dim_cur c  ON c.srk_cur  = f.srk_cur
JOIN dw.dim_disc dd ON dd.srk_disc = f.srk_disc
GROUP BY c.nome_cur, dd.cod_disc, dd.nm_disc
HAVING SUM(f.discen) >= 80
ORDER BY c.nome_cur, rank_taxa_no_curso;


-- 14) Painel por Disciplina (evolução temporal, para gráfico de linha)
-- Filtre por cod_disc/nm_disc no Power BI (slicer).
SELECT
    dd.cod_disc,
    dd.nm_disc,
    t.ano,
    t.sem_ano,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_disc dd ON dd.srk_disc = f.srk_disc
JOIN dw.dim_tmp  t  ON t.srk_tmp  = f.srk_tmp
GROUP BY dd.cod_disc, dd.nm_disc, t.ano, t.sem_ano
ORDER BY dd.cod_disc, t.ano, t.sem_ano;


-- 15) Painel por Curso (evolução temporal)
SELECT
    c.nome_cur,
    t.ano,
    t.sem_ano,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.insuc)                                            AS total_insucessos,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_cur c ON c.srk_cur = f.srk_cur
JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
GROUP BY c.nome_cur, t.ano, t.sem_ano
ORDER BY c.nome_cur, t.ano, t.sem_ano;


-- 16) Cancelamentos e Trancamentos por Departamento (taxas sobre discentes)
SELECT
    d.nm_dpt,
    SUM(f.discen)                                           AS total_discentes,
    SUM(f.canc)                                             AS total_cancelamentos,
    SUM(f.tranc)                                            AS total_trancamentos,
    ROUND(SUM(f.canc)::numeric  / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_cancelamento_pct,
    ROUND(SUM(f.tranc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_trancamento_pct
FROM dw.fato_insuc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nm_dpt
ORDER BY taxa_cancelamento_pct DESC;


-- 17) Top semestres por maior insucesso absoluto (picos do período)
SELECT
    t.ano,
    t.sem_ano,
    SUM(f.insuc) AS total_insucessos,
    SUM(f.discen) AS total_discentes,
    ROUND(SUM(f.insuc)::numeric / NULLIF(SUM(f.discen), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fato_insuc f
JOIN dw.dim_tmp t ON t.srk_tmp = f.srk_tmp
GROUP BY t.ano, t.sem_ano
ORDER BY total_insucessos DESC
LIMIT 10;


