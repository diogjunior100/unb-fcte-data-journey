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

O modelo segue o padrão **Star Schema** (Schema Estrela), onde uma tabela central de fatos (`fato_disciplinas`) é conectada a múltiplas tabelas dimensionais através de chaves estrangeiras. Este modelo é otimizado para consultas analíticas e relatórios.

### Mnemonicos:

```
    -- DIMENSÃO

    dw.dim_disc - Dimensão disciplina
    (
        srk_disc - srk disciplina,
        cod_disc - código da disciplina,
        nm_disc - nome da disciplina
    );

    dw.dim_tmp - dimensão tempo
    (
        srk_tmp - srk tempo,
        ano - ano,
        sem_ano - semestre do ano
    );

    dw.dim_dpt dimensão departamento (
        srk_dpt srk departamento,
        nm_dpt - nome departamento
    );

    dw.dim_cur dimensão curso 
    (
        srk_cur - srk curso,
        nm_cur nome curso
    );

    -- FATO

    dw.fato_insuc fato insucesso
    (
        srk ,
        srk_disc ,
        srk_tmp ,
        srk_dpt ,
        srk_cur ,
        turm - turmas,
        discen - discentes,
        canc - cancelamentos,
        rpv_med - reprovacoes media,
        rpv_not reprovacoes nota,
        rpv_fal reprovacoes falta,
        rpv_med_fal - reprovacoes media falta,
        rpv_not_fal - reprovacoes nota falta,
        tranc - trancamentos,
        insuc - insucessos
    );
```
## Entidades

### Tabelas Dimensionais

#### 1. DIM_DISC

**Descrição**: Representa as disciplinas oferecidas pela universidade, contendo informações descritivas sobre cada disciplina.

**Atributos**:
- **`srk_disc`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`cod_disc`** (VARCHAR(100), NOT NULL): Código único da disciplina (ex: MAT0025, CIC0004, FGA0038)
- **`nm_disc`** (VARCHAR(100), NOT NULL): Nome oficial da disciplina

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
- **`nm_dpt`** (VARCHAR(100), NOT NULL): Nome completo do departamento (ex: MAT, CIC, FGA, IFD)

**Observação**: Centraliza informações sobre departamentos, facilitando manutenção e análises por unidade acadêmica.

#### 4. DIM_CUR

**Descrição**: Representa os cursos aos quais as turmas pertencem.

**Atributos**:
- **`srk_cur`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`nm_cur`** (VARCHAR(100), NOT NULL): Nome do curso (ex: Software, Automotiva)

**Observação**: Permite análises comparativas entre diferentes cursos.

### Tabela de Fatos

#### FATO_INSUC

**Descrição**: Tabela central que armazena as métricas de insucesso acadêmico para cada combinação de disciplina, tempo, departamento e curso.

**Atributos de Relacionamento (Chaves Estrangeiras)**:
- **`srk_disc`** (INT, NOT NULL, FK): Referência a `dim_disc(srk_disc)`
- **`srk_tmp`** (INT, NOT NULL, FK): Referência a `dim_tmp(srk_tmp)`
- **`srk_dpt`** (INT, NOT NULL, FK): Referência a `dim_dpt(srk_dpt)`
- **`srk_cur`** (INT, NOT NULL, FK): Referência a `dim_cur(srk_cur)`

**Atributos de Métricas**:
- **`turm`** (INT, DEFAULT 0): Número de turmas ofertadas da disciplina no semestre/curso
- **`disc`** (INT, DEFAULT 0): Número total de estudantes matriculados na disciplina
- **`canc`** (INT, DEFAULT 0): Número de cancelamentos de matrícula
- **`rpv_med`** (INT, DEFAULT 0): Número de reprovações por média insuficiente
- **`rpv_not`** (INT, DEFAULT 0): Número de reprovações por nota específica
- **`rpv_fal`** (INT, DEFAULT 0): Número de reprovações por excesso de faltas
- **`rpv_med_fal`** (INT, DEFAULT 0): Número de reprovações por média insuficiente e excesso de faltas
- **`rpv_not_fal`** (INT, DEFAULT 0): Número de reprovações por nota específica e excesso de faltas
- **`tranc`** (INT, DEFAULT 0): Número de trancamentos de matrícula
- **`insuc`** (INT, DEFAULT 0): Soma total de insucessos (calculado)

**Chave Primária**: `id` (INT, GENERATED ALWAYS AS IDENTITY)

**Observação**: Cada registro representa uma combinação única de disciplina, tempo, departamento e curso, com suas respectivas métricas de insucesso.

## Relacionamentos

### DIM_DISC → FATO_INSUC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Uma disciplina pode ter múltiplos registros de fatos (em diferentes semestres, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se uma disciplina for removida, todos os fatos relacionados são removidos

### DIM_TMP → FATO_INSUC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um período de tempo pode ter múltiplos registros de fatos (diferentes disciplinas, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um período for removido, todos os fatos relacionados são removidos

### DIM_DPT → FATO_INSUC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um departamento pode ter múltiplos registros de fatos (diferentes disciplinas, semestres, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um departamento for removido, todos os fatos relacionados são removidos

### DIM_CUR → FATO_INSUC
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um curso pode ter múltiplos registros de fatos (diferentes disciplinas, semestres, departamentos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um curso for removido, todos os fatos relacionados são removidos

## Chaves Primárias

- **DIM_DISCIPLINAS**: `id_disciplina` (INT, autoincrementado)
- **DIM_TEMPO**: `id_tempo` (INT, autoincrementado)
- **DIM_DEPARTAMENTO**: `id_departamento` (INT, autoincrementado)
- **DIM_CURSO**: `id_curso` (INT, autoincrementado)
- **FATO_DISCIPLINAS**: `id` (INT, autoincrementado)

## Diagrama Entidade-Relacionamento (DER)

O modelo segue o padrão Star Schema, onde a tabela de fatos está no centro, conectada às tabelas dimensionais.

O **Diagrama Entidade-Relacionamento (DER)** representa o modelo conceitual do banco de dados, mostrando as entidades, seus atributos e os relacionamentos entre elas de forma abstrata, sem detalhes de implementação física.

![Diagrama Entidade-Relacionamento](./assets/der.jpg)

### Diagrama Mermaid

```mermaid
erDiagram
    DIM_DISC {
        int srk_disc PK "Identificador único"
        string cod_disc "Código da disciplina"
        string nm_disc "Nome da disciplina"
    }
    
    DIM_TMP {
        int srk_tmp PK "Identificador único"
        int ano "Ano do semestre"
        string sem_ano "Semestre letivo (AAAA-S)"
    }
    
    DIM_DPT {
        int srk_dpt PK "Identificador único"
        string nm_dpt "Nome do departamento"
    }
    
    DIM_CUR {
        int srk_cur PK "Identificador único"
        string nm_cur "Nome do curso"
    }
    
    FATO_INSUC {
        int srk PK "Identificador único"
        int srk_disc FK "Referência à disciplina"
        int srk_tmp FK "Referência ao tempo"
        int srk_dpt FK "Referência ao departamento"
        int srk_cur FK "Referência ao curso"
        int turm "Número de turmas"
        int discen "Total de estudantes"
        int canc "Cancelamentos"
        int rpv_med "Reprovações por média"
        int rpv_not "Reprovações por nota"
        int rpv_fal "Reprovações por falta"
        int rpv_med_fal "Reprovações por média e falta"
        int rpv_not_fal "Reprovações por nota e falta"
        int tranc "Trancamentos"
        int insuc "Total de insucessos"
    }
    
    DIM_DISC ||--o{ FATO_INSUC : "tem"
    DIM_TMP ||--o{ FATO_INSUC : "ocorre em"
    DIM_DPT ||--o{ FATO_INSUC : "pertence a"
    DIM_CUR ||--o{ FATO_INSUC : "oferecido para"
```

## Diagrama Lógico de Dados (DLD)

O **Diagrama Lógico de Dados (DLD)** representa a estrutura física do banco de dados, mostrando detalhes de implementação como tipos de dados, tamanhos de campos, chaves primárias, chaves estrangeiras, constraints, índices e outros elementos técnicos específicos do SGBD (Sistema Gerenciador de Banco de Dados).

**Diferenças entre DER e DLD**:
- **DER**: Foco no modelo conceitual, relacionamentos e cardinalidades
- **DLD**: Foco na implementação física, tipos de dados, constraints e detalhes técnicos

O DLD abaixo representa a implementação do modelo no PostgreSQL, conforme definido no arquivo `DDL.sql`.

![Diagrama Lógico de Dados](./assets/dld.jpg)

## Exemplos de Consultas

### Exemplo 1: Total de Insucessos por Departamento
```sql
SELECT 
    d.nm_dpt,
    SUM(f.insuc) AS total_insucessos
FROM dw.fato_insuc f
JOIN dw.dim_dpt d ON f.srk_dpt = d.srk_dpt
GROUP BY d.nm_dpt
ORDER BY total_insucessos DESC;
```
![Consulta-1](./assets/Query-1.png)

### Exemplo 2: Evolução Temporal de Disciplina
```sql
SELECT 
    t.ano,
    t.sem_ano,
    disc.nm_disc,
	cur.nome_cur,
    f.discen,
    f.insuc
FROM dw.fato_insuc f
JOIN dw.dim_tmp t ON f.srk_tmp = t.srk_tmp
JOIN dw.dim_disc disc ON f.srk_disc = disc.srk_disc
JOIN dw.dim_cur cur ON f.srk_cur = cur.srk_cur
WHERE disc.cod_disc = 'MAT0025'
ORDER BY t.ano, t.sem_ano, cur.nome_cur;
```
![Consulta-2](./assets/Query-2.png)

### Exemplo 3: Comparação entre Cursos
```sql
SELECT 
    c.nome_cur,
    COUNT(DISTINCT f.srk_disc) AS total_disciplinas,
    SUM(f.discen) AS total_discentes,
    SUM(f.insuc) AS total_insucessos,
    ROUND(SUM(f.insuc)::NUMERIC / SUM(f.discen) * 100, 2) AS taxa_insucesso
FROM dw.fato_insuc f
JOIN dw.dim_cur c ON f.srk_cur = c.srk_cur
GROUP BY c.nome_cur;
```
![Consulta-3](./assets/Query-3.png)

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

