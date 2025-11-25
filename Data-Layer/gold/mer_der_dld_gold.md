# Modelo Entidade-Relacionamento (ME-R) - Camada Gold

## Visão Geral

Este documento apresenta o modelo entidade-relacionamento (ME-R) para a camada Gold do projeto UNB FCTE Data Journey, baseado no modelo dimensional (Star Schema) implementado no Data Warehouse.

## Análise dos Dados Processados

**Schema**: `dw` (Data Warehouse)  
**Modelo**: Star Schema (Modelo Dimensional)  
**Estrutura**: 4 tabelas dimensionais + 1 tabela de fatos  
**Tabela Original**: `public.disciplinas` (tabela desnormalizada de origem)

**Observação Importante**: A camada Gold implementa um modelo dimensional normalizado, separando as informações descritivas (dimensões) das métricas numéricas (fatos), otimizando consultas analíticas e reduzindo redundância de dados.

## Modelo de Dados

O modelo segue o padrão **Star Schema** (Schema Estrela), onde uma tabela central de fatos (`fat_ins_dsc`) é conectada a múltiplas tabelas dimensionais através de chaves estrangeiras. Este modelo é otimizado para consultas analíticas e relatórios.


## Entidades

### Tabelas Dimensionais

#### 1. DIM_DSC

**Descrição**: Representa as disciplinas oferecidas pela universidade, contendo informações descritivas sobre cada disciplina.

**Atributos**:
- **`srk_dsc`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`cod_dsc`** (VARCHAR(100), NOT NULL): Código único da disciplina (ex: MAT0025, CIC0004, FGA0038)
- **`nme_dsc`** (VARCHAR(100), NOT NULL): Nome oficial da disciplina

**Observação**: Cada disciplina é representada uma única vez nesta tabela, eliminando redundância.

#### 2. DIM_TMP

**Descrição**: Representa a dimensão temporal, contendo informações sobre os semestres letivos.

**Atributos**:
- **`srk_tmp`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`ano`** (INT, NOT NULL): Ano do semestre letivo (ex: 2023, 2024, 2025)
- **`sem-ano`** (VARCHAR(100), NOT NULL): Semestre letivo no formato AAAA-S (ex: 2023-2, 2024-1)

**Observação**: Permite análises temporais e agregações por período.

#### 3. DIM_DPT

**Descrição**: Representa os departamentos acadêmicos responsáveis pelas disciplinas.

**Atributos**:
- **`srk_dpt`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`nme_dpt`** (VARCHAR(100), NOT NULL): Nome completo do departamento (ex: MAT, CIC, FGA, IFD)

**Observação**: Centraliza informações sobre departamentos, facilitando manutenção e análises por unidade acadêmica.

#### 4. DIM_CUR

**Descrição**: Representa os cursos aos quais as turmas pertencem.

**Atributos**:
- **`srk_cur`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`nme_cur`** (VARCHAR(100), NOT NULL): Nome do curso (ex: Software, Automotiva)

**Observação**: Permite análises comparativas entre diferentes cursos.

### Tabela de Fatos

#### FAT_INS_DSC

**Descrição**: Tabela central que armazena as métricas de insucesso acadêmico para cada combinação de disciplina, tempo, departamento e curso.

**Atributos de Relacionamento (Chaves Estrangeiras)**:
- **`srk_dsc`** (INT, NOT NULL, FK): Referência a `dim_dsc(srk_dsc)`
- **`srk_tmp`** (INT, NOT NULL, FK): Referência a `dim_tmp(srk_tmp)`
- **`srk_dpt`** (INT, NOT NULL, FK): Referência a `dim_dpt(srk_dpt)`
- **`srk_cur`** (INT, NOT NULL, FK): Referência a `dim_cur(srk_cur)`

**Atributos de Métricas**:
- **`trm`** (INT, DEFAULT 0): Número de turmas ofertadas da disciplina no semestre/curso
- **`dst`** (INT, DEFAULT 0): Número total de estudantes matriculados na disciplina
- **`cnc`** (INT, DEFAULT 0): Número de cancelamentos de matrícula
- **`rpv_med`** (INT, DEFAULT 0): Número de reprovações por média insuficiente
- **`rpv_not`** (INT, DEFAULT 0): Número de reprovações por nota específica
- **`rpv_fal`** (INT, DEFAULT 0): Número de reprovações por excesso de faltas
- **`rpv_med_fal`** (INT, DEFAULT 0): Número de reprovações por média insuficiente e excesso de faltas
- **`rpv_not_fal`** (INT, DEFAULT 0): Número de reprovações por nota específica e excesso de faltas
- **`trc`** (INT, DEFAULT 0): Número de trancamentos de matrícula
- **`ins`** (INT, DEFAULT 0): Soma total de insucessos (calculado)

**Chave Primária**: `srk_fat_ins_dsc` (INT, GENERATED ALWAYS AS IDENTITY)

**Observação**: Cada registro representa uma combinação única de disciplina, tempo, departamento e curso, com suas respectivas métricas de insucesso.

## Relacionamentos

### DIM_DSC → FAT_INS_DSC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Uma disciplina pode ter múltiplos registros de fatos (em diferentes semestres, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se uma disciplina for removida, todos os fatos relacionados são removidos

### DIM_TMP → FAT_INS_DSC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um período de tempo pode ter múltiplos registros de fatos (diferentes disciplinas, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um período for removido, todos os fatos relacionados são removidos

### DIM_DPT → FAT_INS_DSC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um departamento pode ter múltiplos registros de fatos (diferentes disciplinas, semestres, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um departamento for removido, todos os fatos relacionados são removidos

### DIM_CUR → FAT_INS_DSC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um curso pode ter múltiplos registros de fatos (diferentes disciplinas, semestres, departamentos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um curso for removido, todos os fatos relacionados são removidos

## Chaves Primárias

- **DIM_DSC**: `srk_dsc` (INT, autoincrementado)
- **DIM_TMP**: `srk_tmp` (INT, autoincrementado)
- **DIM_DPT**: `srk_dpt` (INT, autoincrementado)
- **DIM_CUR**: `srk_cur` (INT, autoincrementado)
- **FAT_INS_DSC**: `srk_fat_ins_dsc` (INT, autoincrementado)

## Diagrama Entidade-Relacionamento (DER)

O modelo segue o padrão Star Schema, onde a tabela de fatos está no centro, conectada às tabelas dimensionais.

O **Diagrama Entidade-Relacionamento (DER)** representa o modelo conceitual do banco de dados, mostrando as entidades, seus atributos e os relacionamentos entre elas de forma abstrata, sem detalhes de implementação física.

![Diagrama Entidade-Relacionamento](./assets/der.png)

### Diagrama Mermaid

```mermaid
erDiagram
    DIM_DSC {
        int srk_dsc PK "Identificador único"
        string cod_dsc "Código da disciplina"
        string nme_dsc "Nome da disciplina"
    }
    
    DIM_TMP {
        int srk_tmp PK "Identificador único"
        int ano "Ano do semestre"
        string sem_ano "Semestre letivo (AAAA-S)"
    }
    
    DIM_DPT {
        int srk_dpt PK "Identificador único"
        string nme_dpt "Nome do departamento"
    }
    
    DIM_CUR {
        int srk_cur PK "Identificador único"
        string nme_cur "Nome do curso"
    }
    
    FAT_INS_DSC {
        int srk PK "Identificador único"
        int srk_dsc FK "Referência à disciplina"
        int srk_tmp FK "Referência ao tempo"
        int srk_dpt FK "Referência ao departamento"
        int srk_cur FK "Referência ao curso"
        int trm "Número de turmas"
        int dst "Total de estudantes"
        int cnc "Cancelamentos"
        int rpv_med "Reprovações por média"
        int rpv_not "Reprovações por nota"
        int rpv_fal "Reprovações por falta"
        int rpv_med_fal "Reprovações por média e falta"
        int rpv_not_fal "Reprovações por nota e falta"
        int trc "Trancamentos"
        int ins "Total de insucessos"
    }
    
    DIM_DSC ||--o{ FAT_INS_DSC : "tem"
    DIM_TMP ||--o{ FAT_INS_DSC : "ocorre em"
    DIM_DPT ||--o{ FAT_INS_DSC : "pertence a"
    DIM_CUR ||--o{ FAT_INS_DSC : "oferecido para"
```

## Diagrama Lógico de Dados (DLD)

O **Diagrama Lógico de Dados (DLD)** representa a estrutura física do banco de dados, mostrando detalhes de implementação como tipos de dados, tamanhos de campos, chaves primárias, chaves estrangeiras, constraints, índices e outros elementos técnicos específicos do SGBD (Sistema Gerenciador de Banco de Dados).

**Diferenças entre DER e DLD**:
- **DER**: Foco no modelo conceitual, relacionamentos e cardinalidades
- **DLD**: Foco na implementação física, tipos de dados, constraints e detalhes técnicos

O DLD abaixo representa a implementação do modelo no PostgreSQL, conforme definido no arquivo `DDL.sql`.

![Diagrama Lógico de Dados](./assets/dld.png)

## Exemplos de Consultas

### Exemplo 1: Visão geral de insucessos, cancelamentos e trancamentos por departamento
```sql
SELECT
    SUM(f.dst)::bigint                                   AS total_discentes,
    SUM(f.ins)::bigint                                    AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct,
    SUM(f.cnc)::bigint                                     AS total_cancelamentos,
    SUM(f.trc)::bigint                                    AS total_trancamentos,
    (SUM(f.rpv_med)+SUM(f.rpv_not)+SUM(f.rpv_fal)+SUM(f.rpv_med_fal)+SUM(f.rpv_not_fal))::bigint AS total_reprovacoes
FROM dw.fat_ins_dsc f;
```
![Consulta-1](./assets/Query-1.png)

### Exemplo 2: Taxa de insucesso por departamento
```sql
SELECT
    d.nme_dpt,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nme_dpt
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC;
```
![Consulta-2](./assets/Query-2.png)

### Exemplo 3: Taxa de insucesso por curso
```sql
SELECT
    c.nme_cur,
    SUM(f.dst)                                           AS total_discentes,
    SUM(f.ins)                                            AS total_insucessos,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(f.dst), 0) * 100, 2) AS taxa_insucesso_pct
FROM dw.fat_ins_dsc f
JOIN dw.dim_cur c ON c.srk_cur = f.srk_cur
GROUP BY c.nme_cur
ORDER BY taxa_insucesso_pct DESC, total_insucessos DESC;
```
![Consulta-3](./assets/Query-3.png)


### Exemplo 4: Evolução temporal de insucesso por semestre
```sql
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
```
![Consulta-4](./assets/Query-4.png)

### Exemplo 5: Disciplinas com mais de 100 discentes ordenadas por taxa de insucesso
```sql
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
```
![Consulta-5](./assets/Query-5.png)

### Exemplo 6: Disciplinas com mais de 100 discentes ordenadas por total de insucessos
```sql
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
```
![Consulta-6](./assets/Query-6.png)

### Exemplo 7: 
**Nome:** Disciplinas com mais de 100 discentes ordenadas por insucessos e taxa
```sql
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
```
![Consulta-7](./assets/Query-7.png)

### Exemplo 8: Detalhamento de tipos de reprovação por departamento
```sql
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
```
![Consulta-8](./assets/Query-8.png)

### Exemplo 9: Taxa de insucesso por departamento e curso
```sql
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
```
![Consulta-9](./assets/Query-9.png)

### Exemplo 10: Variação da taxa de insucesso por departamento ao longo dos semestres
```sql
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
```
![Consulta-10](./assets/Query-10.png)

### Exemplo 11: Contribuição percentual de insucessos por departamento
```sql
SELECT
    d.nme_dpt,
    SUM(f.ins)                                            AS insucessos,
    SUM(SUM(f.ins)) OVER ()                               AS insucessos_total,
    ROUND(SUM(f.ins)::numeric / NULLIF(SUM(SUM(f.ins)) OVER (), 0) * 100, 2) AS pct_contribuicao
FROM dw.fat_ins_dsc f
JOIN dw.dim_dpt d ON d.srk_dpt = f.srk_dpt
GROUP BY d.nme_dpt
ORDER BY pct_contribuicao DESC;
```
![Consulta-11](./assets/Query-11.png)

### Exemplo 12: Disciplinas com maior volatilidade na taxa de insucesso
```sql
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
```
![Consulta-12](./assets/Query-12.png)

### Exemplo 13: Ranking de taxa de insucesso por disciplina dentro de cada curso
```sql
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
```
![Consulta-13](./assets/Query-13.png)

### Exemplo 14: Evolução da taxa de insucesso por disciplina e semestre
```sql
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
```
![Consulta-14](./assets/Query-14.png)


### Exemplo 15: Evolução da taxa de insucesso por curso e semestre
```sql
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
```
![Consulta-15](./assets/Query-15.png)

### Exemplo 16: Taxa de cancelamento e trancamento por departamento
```sql
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
```
![Consulta-16](./assets/Query-16.png)

### Exemplo 17: Top 10 semestres com maior número de insucessos
```sql
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
```
![Consulta-17](./assets/Query-17.png)



## Tabela Original

A tabela `public.disciplinas` serve como fonte de dados para o Data Warehouse. Esta tabela contém os dados desnormalizados originais, que são transformados e distribuídos entre as dimensões e a tabela de fatos durante o processo de ETL.

**Estrutura da Tabela Original**:
- `id` (INT, PK): Identificador único autoincrementado
- `codigo` (VARCHAR(100)): Código da disciplina
- `nome` (VARCHAR(100)): Nome da disciplina
- `turmas` (INT): Número de turmas
- `discentes` (INT): Total de estudantes
- `cancelamentos` (INT): Cancelamentos
- `reprovacoesMedia` (INT): Reprovações por média
- `reprovacoesNota` (INT): Reprovações por nota
- `reprovacoesFalta` (INT): Reprovações por falta
- `reprovacoesMediaFalta` (INT): Reprovações por média e falta
- `reprovacoesNotaFalta` (INT): Reprovações por nota e falta
- `trancamentos` (INT): Trancamentos
- `insucessos` (INT): Total de insucessos
- `semestre` (VARCHAR(100)): Semestre letivo
- `departamento` (VARCHAR(100)): Departamento
- `curso` (VARCHAR(100)): Curso

---

*Última atualização: 2025*  
*Versão: 1.0 - Modelo Dimensional (Star Schema)*

