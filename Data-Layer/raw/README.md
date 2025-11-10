# Camada Bronze - Dados Brutos

## Visão Geral

A camada Bronze representa a primeira etapa do pipeline de dados do projeto UNB FCTE Data Journey, contendo os dados brutos obtidos. Esta camada mantém os dados em seu formato original, preservando a integridade e rastreabilidade das informações de insucesso acadêmico.

## Objetivo

Armazenar e preservar os dados originais de insucesso acadêmico por disciplina e semestre, fornecendo uma base confiável para as transformações subsequentes na camada Silver.

## Estrutura dos Dados

### Arquivos Principais

| Arquivo | Descrição | Tamanho | Período |
|---------|-----------|---------|---------|
| `Relatorio-Lista-Insucesso.xlsx` | Dados específicos de Engenharia de Software | 45.7 KB | 2023.2 - 2025.1 |
| `Relatorio-Lista-Insucesso-Automotiva.xlsx` | Dados específicos de Engenharia Automotiva | 26.5 KB | Específico |

### Arquivos CSV por Semestre

| Semestre | Arquivo CSV | Registros | Linhas |
|----------|-------------|-----------|--------|
| 2023.2 | `Relatorio-Lista-Insucesso - 2023.2.csv` | 153 | 154 |
| 2024.1 | `Relatorio-Lista-Insucesso - 2024.1.csv` | 145 | 146 |
| 2024.2 | `Relatorio-Lista-Insucesso - 2024.2.csv` | 163 | 164 |
| 2025.1 | `Relatorio-Lista-Insucesso - 2025.1.csv` | 149 | 150 |

**Total**: 610 registros de disciplinas (614 linhas incluindo cabeçalhos)

## Estrutura do Arquivo Excel

O arquivo principal `Relatorio-Lista-Insucesso.xlsx` contém:

- **4 abas** correspondentes aos semestres: `2023.2`, `2024.1`, `2024.2`, `2025.1`
- **13 colunas** por aba com dados de insucesso acadêmico
- **Formato original** preservado do sistema institucional

## Características dos Dados

### Granularidade
- **Por disciplina e semestre**: Cada registro representa uma disciplina em um semestre específico
- **Identificação única**: Combinação de Código da disciplina + Semestre

### Cobertura Temporal
- **Período**: 4 semestres consecutivos (2023.2 a 2025.1)
- **Frequência**: Dados por semestre letivo
- **Atualização**: Manual, conforme disponibilidade dos relatórios institucionais

### Departamentos Cobertos
Os dados incluem disciplinas de diversos departamentos da FCTE/UnB, identificados pelo prefixo do código da disciplina:
- FGA (Faculdade do Gama)
- MAT (Matemática)
- CIC (Ciência da Computação)
- IFD (Física)
- DSC (Estatística)
- CEM (Química)
- E outros departamentos

## Qualidade dos Dados

### Características Observadas
- **Coluna Pólo**: Sempre vazia (será removida na camada Silver)
- **Linha de total**: Última linha de cada aba contém totais (será removida)
- **Consistência**: Estrutura uniforme entre semestres
- **Completude**: Dados completos para métricas de insucesso

## Próximos Passos

Os dados da camada Bronze são processados na **camada Silver** através do notebook `silver/etl.ipynb`, que:

1. Remove linhas de total/rodapé
2. Elimina coluna "Pólo" (vazia)
3. Padroniza tipos de dados
4. Cria colunas derivadas (Semestre, Departamento)
5. Consolida dados de todos os semestres
6. Exporta para CSV processado
7. Cria coluna Curso

---

*Última atualização: $(date)*
*Versão: 1.0*
