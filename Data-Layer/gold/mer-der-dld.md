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
        sem-ano - semestre do ano
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

#### 1. DIM_DISCIPLINAS

**Descrição**: Representa as disciplinas oferecidas pela universidade, contendo informações descritivas sobre cada disciplina.

**Atributos**:
- **`id_disciplina`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`codigo`** (VARCHAR(100), NOT NULL): Código único da disciplina (ex: MAT0025, CIC0004, FGA0038)
- **`nome`** (VARCHAR(100), NOT NULL): Nome oficial da disciplina

**Observação**: Cada disciplina é representada uma única vez nesta tabela, eliminando redundância.

#### 2. DIM_TEMPO

**Descrição**: Representa a dimensão temporal, contendo informações sobre os semestres letivos.

**Atributos**:
- **`id_tempo`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`ano`** (INT, NOT NULL): Ano do semestre letivo (ex: 2023, 2024, 2025)
- **`semestre`** (VARCHAR(100), NOT NULL): Semestre letivo no formato AAAA-S (ex: 2023-2, 2024-1)

**Observação**: Permite análises temporais e agregações por período.

#### 3. DIM_DEPARTAMENTO

**Descrição**: Representa os departamentos acadêmicos responsáveis pelas disciplinas.

**Atributos**:
- **`id_departamento`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`nome_departamento`** (VARCHAR(100), NOT NULL): Nome completo do departamento (ex: MAT, CIC, FGA, IFD)

**Observação**: Centraliza informações sobre departamentos, facilitando manutenção e análises por unidade acadêmica.

#### 4. DIM_CURSO

**Descrição**: Representa os cursos aos quais as turmas pertencem.

**Atributos**:
- **`id_curso`** (INT, PK): Identificador único autoincrementado (GENERATED ALWAYS AS IDENTITY)
- **`nome_curso`** (VARCHAR(100), NOT NULL): Nome do curso (ex: Software, Automotiva)

**Observação**: Permite análises comparativas entre diferentes cursos.

### Tabela de Fatos

#### FATO_DISCIPLINAS

**Descrição**: Tabela central que armazena as métricas de insucesso acadêmico para cada combinação de disciplina, tempo, departamento e curso.

**Atributos de Relacionamento (Chaves Estrangeiras)**:
- **`id_disciplina`** (INT, NOT NULL, FK): Referência a `dim_disciplinas(id_disciplina)`
- **`id_tempo`** (INT, NOT NULL, FK): Referência a `dim_tempo(id_tempo)`
- **`id_departamento`** (INT, NOT NULL, FK): Referência a `dim_departamento(id_departamento)`
- **`id_curso`** (INT, NOT NULL, FK): Referência a `dim_curso(id_curso)`

**Atributos de Métricas**:
- **`turmas`** (INT, DEFAULT 0): Número de turmas ofertadas da disciplina no semestre/curso
- **`discentes`** (INT, DEFAULT 0): Número total de estudantes matriculados na disciplina
- **`cancelamentos`** (INT, DEFAULT 0): Número de cancelamentos de matrícula
- **`reprovacoesmedia`** (INT, DEFAULT 0): Número de reprovações por média insuficiente
- **`reprovacoesnota`** (INT, DEFAULT 0): Número de reprovações por nota específica
- **`reprovacoesfalta`** (INT, DEFAULT 0): Número de reprovações por excesso de faltas
- **`reprovacoesmediafalta`** (INT, DEFAULT 0): Número de reprovações por média insuficiente e excesso de faltas
- **`reprovacoesnotafalta`** (INT, DEFAULT 0): Número de reprovações por nota específica e excesso de faltas
- **`trancamentos`** (INT, DEFAULT 0): Número de trancamentos de matrícula
- **`insucessos`** (INT, DEFAULT 0): Soma total de insucessos (calculado)

**Chave Primária**: `id` (INT, GENERATED ALWAYS AS IDENTITY)

**Observação**: Cada registro representa uma combinação única de disciplina, tempo, departamento e curso, com suas respectivas métricas de insucesso.

## Relacionamentos

### DIM_DISCIPLINAS → FATO_DISCIPLINAS
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Uma disciplina pode ter múltiplos registros de fatos (em diferentes semestres, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se uma disciplina for removida, todos os fatos relacionados são removidos

### DIM_TEMPO → FATO_DISCIPLINAS
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um período de tempo pode ter múltiplos registros de fatos (diferentes disciplinas, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um período for removido, todos os fatos relacionados são removidos

### DIM_DEPARTAMENTO → FATO_DISCIPLINAS
- **Cardinalidade**: 1:N (Um para Muitos)
- **Descrição**: Um departamento pode ter múltiplos registros de fatos (diferentes disciplinas, semestres, cursos, etc.)
- **Integridade Referencial**: `ON DELETE CASCADE` - Se um departamento for removido, todos os fatos relacionados são removidos

### DIM_CURSO → FATO_DISCIPLINAS
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
    DIM_DISCIPLINAS {
        int id_disciplina PK "Identificador único"
        string codigo "Código da disciplina"
        string nome "Nome da disciplina"
    }
    
    DIM_TEMPO {
        int id_tempo PK "Identificador único"
        int ano "Ano do semestre"
        string semestre "Semestre letivo (AAAA-S)"
    }
    
    DIM_DEPARTAMENTO {
        int id_departamento PK "Identificador único"
        string nome_departamento "Nome do departamento"
    }
    
    DIM_CURSO {
        int id_curso PK "Identificador único"
        string nome_curso "Nome do curso"
    }
    
    FATO_DISCIPLINAS {
        int id PK "Identificador único"
        int id_disciplina FK "Referência à disciplina"
        int id_tempo FK "Referência ao tempo"
        int id_departamento FK "Referência ao departamento"
        int id_curso FK "Referência ao curso"
        int turmas "Número de turmas"
        int discentes "Total de estudantes"
        int cancelamentos "Cancelamentos"
        int reprovacoesmedia "Reprovações por média"
        int reprovacoesnota "Reprovações por nota"
        int reprovacoesfalta "Reprovações por falta"
        int reprovacoesmediafalta "Reprovações por média e falta"
        int reprovacoesnotafalta "Reprovações por nota e falta"
        int trancamentos "Trancamentos"
        int insucessos "Total de insucessos"
    }
    
    DIM_DISCIPLINAS ||--o{ FATO_DISCIPLINAS : "tem"
    DIM_TEMPO ||--o{ FATO_DISCIPLINAS : "ocorre em"
    DIM_DEPARTAMENTO ||--o{ FATO_DISCIPLINAS : "pertence a"
    DIM_CURSO ||--o{ FATO_DISCIPLINAS : "oferecido para"
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
    d.nome_departamento,
    SUM(f.insucessos) AS total_insucessos
FROM dw.fato_disciplinas f
JOIN dw.dim_departamento d ON f.id_departamento = d.id_departamento
GROUP BY d.nome_departamento
ORDER BY total_insucessos DESC;
```

### Exemplo 2: Evolução Temporal de Disciplina
```sql
SELECT 
    t.ano,
    t.semestre,
    disc.nome,
    f.discentes,
    f.insucessos
FROM dw.fato_disciplinas f
JOIN dw.dim_tempo t ON f.id_tempo = t.id_tempo
JOIN dw.dim_disciplinas disc ON f.id_disciplina = disc.id_disciplina
WHERE disc.codigo = 'MAT0025'
ORDER BY t.ano, t.semestre;
```

### Exemplo 3: Comparação entre Cursos
```sql
SELECT 
    c.nome_curso,
    COUNT(DISTINCT f.id_disciplina) AS total_disciplinas,
    SUM(f.discentes) AS total_discentes,
    SUM(f.insucessos) AS total_insucessos,
    ROUND(SUM(f.insucessos)::NUMERIC / SUM(f.discentes) * 100, 2) AS taxa_insucesso
FROM dw.fato_disciplinas f
JOIN dw.dim_curso c ON f.id_curso = c.id_curso
GROUP BY c.nome_curso;
```

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

