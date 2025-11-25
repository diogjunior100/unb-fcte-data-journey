# Dicionário de Dados - Camada Bronze

## Visão Geral

Este dicionário descreve detalhadamente cada campo presente nos dados brutos da camada Bronze, incluindo tipos de dados, formatos, valores possíveis e regras de negócio.

## Estrutura Geral

**Formato**: Excel (.xlsx) com abas por semestre  
**Encoding**: UTF-8  
**Separador**: Vírgula (CSV) / Planilha (Excel)  
**Total de Colunas**: 13  
**Total de Registros**: 610 (4 semestres)

## Campos do Dicionário

### 1. Código
- **Tipo**: String/Texto
- **Formato**: [DEPARTAMENTO][NÚMERO] (ex: MAT0025, CIC0004)
- **Tamanho**: 7 caracteres
- **Obrigatório**: Sim
- **Descrição**: Código único da disciplina no sistema acadêmico
- **Exemplos**: 
  - `MAT0025` (Cálculo 1)
  - `CIC0004` (Algoritmos e Programação)
  - `FGA0083` (Aprendizado de Máquina)
- **Regras de Negócio**:
  - Primeiros 3 caracteres identificam o departamento
  - Últimos 4 caracteres são numéricos sequenciais
  - Deve ser único por disciplina
- **Validação**: Não pode ser nulo ou vazio

### 2. Nome
- **Tipo**: String/Texto
- **Formato**: Nome completo da disciplina
- **Tamanho**: Variável
- **Obrigatório**: Sim
- **Descrição**: Nome oficial da disciplina conforme catálogo acadêmico
- **Exemplos**:
  - `CÁLCULO 1`
  - `ALGORITMOS E PROGRAMAÇÃO DE COMPUTADORES`
  - `APRENDIZADO DE MÁQUINA`
- **Regras de Negócio**:
  - Deve corresponder ao nome oficial no catálogo
  - Pode conter acentos e caracteres especiais
  - Case-sensitive
- **Validação**: Não pode ser nulo

### 3. Pólo
- **Tipo**: Float/Vazio
- **Formato**: Sempre vazio
- **Obrigatório**: Não
- **Descrição**: Campo destinado a identificar o pólo/campus, mas não utilizado
- **Valores**: Sempre vazio (NULL)
- **Regras de Negócio**: Será removido na camada Silver
- **Observação**: Campo obsoleto, mantido apenas por compatibilidade

### 4. Turmas
- **Tipo**: Integer
- **Formato**: Número inteiro positivo
- **Obrigatório**: Sim
- **Descrição**: Número total de turmas ofertadas da disciplina no semestre
- **Exemplos**: `1`, `6`, `8`, `13`
- **Regras de Negócio**:
  - Deve ser >= 1
  - Representa a oferta da disciplina
- **Validação**: Número inteiro positivo

### 5. Discentes
- **Tipo**: Integer
- **Formato**: Número inteiro positivo
- **Obrigatório**: Sim
- **Descrição**: Número total de estudantes matriculados na disciplina
- **Exemplos**: `1`, `35`, `249`, `306`
- **Regras de Negócio**:
  - Deve ser >= 1
  - Representa o total de matrículas
  - Inclui todos os estudantes ativos
- **Validação**: Número inteiro positivo

### 6. Cancelamentos
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Número de estudantes que cancelaram a matrícula
- **Exemplos**: `0`, `2`, `5`, `14`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Cancelamento = desistência antes do período de avaliação
- **Validação**: Número inteiro não-negativo

### 7. Reprovações Média
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Número de reprovações por nota insuficiente (média < 6.0)
- **Exemplos**: `0`, `2`, `71`, `103`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Média final < 6.0
  - Não inclui reprovações por falta
- **Validação**: Número inteiro não-negativo

### 8. Reprovações Nota
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Número de reprovações por nota específica (ex: prova final)
- **Exemplos**: `0`, `1`, `5`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Critério específico de nota
  - Diferente de reprovação por média
- **Validação**: Número inteiro não-negativo

### 9. Reprovações Falta
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Número de reprovações por excesso de faltas
- **Exemplos**: `0`, `1`, `26`, `29`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Faltas > 25% da carga horária
  - Não inclui reprovações por nota
- **Validação**: Número inteiro não-negativo

### 10. Reprovações Média e Falta
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Número de reprovações por ambos os critérios (média + falta)
- **Exemplos**: `0`, `1`, `2`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Média < 6.0 E faltas > 25%
  - Interseção dos critérios
- **Validação**: Número inteiro não-negativo

### 11. Reprovações Nota e Falta
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Número de reprovações por critério específico de nota E falta
- **Exemplos**: `0`, `1`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Critério específico de nota E faltas > 25%
  - Interseção dos critérios
- **Validação**: Número inteiro não-negativo

### 12. Trancamentos
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Número de estudantes que trancaram a disciplina
- **Exemplos**: `0`, `1`, `12`, `23`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Trancamento = suspensão temporária da matrícula
  - Diferente de cancelamento
- **Validação**: Número inteiro não-negativo

### 13. Total Insucesso
- **Tipo**: Integer
- **Formato**: Número inteiro >= 0
- **Obrigatório**: Sim
- **Descrição**: Soma total de todos os tipos de insucesso
- **Exemplos**: `0`, `5`, `118`, `149`
- **Regras de Negócio**:
  - Deve ser >= 0
  - Fórmula: Cancelamentos + Reprovações Média + Reprovações Nota + Reprovações Falta + Reprovações Média e Falta + Reprovações Nota e Falta + Trancamentos
  - Métrica principal de insucesso
- **Validação**: Número inteiro não-negativo
- **Cálculo**: Soma dos campos 6, 7, 8, 9, 10, 11, 12

## Relacionamentos e Dependências

### Chave Primária
- **Composta**: Código + Semestre (identifica unicamente cada registro)

### Relacionamentos
- **Código → Departamento**: Primeiros 3 caracteres do código
- **Disciplina → Semestre**: Relacionamento 1:N (uma disciplina pode aparecer em múltiplos semestres)

### Validações Cruzadas
- **Total Insucesso**: Deve ser igual à soma dos componentes
- **Discentes**: Deve ser >= Total Insucesso (não pode ter mais insucessos que matrículas)
- **Turmas**: Deve ser >= 1 (pelo menos uma turma)

## Mapeamento de Departamentos

| Prefixo | Departamento | Descrição |
|---------|--------------|-----------|
| ADM | Administração | Disciplinas administrativas |
| CEM | Química | Disciplinas de química |
| CIC | Ciência da Computação | Disciplinas de computação |
| DSC | Estatística | Disciplinas de estatística |
| EST | Estatística | Disciplinas estatísticas |
| FDD | Direito | Disciplinas jurídicas |
| FGA | Faculdade do Gama | Engenharias e tecnologia |
| FUP | Agronomia | Disciplinas agronômicas |
| IFD | Física | Disciplinas de física |
| IQD | Química | Disciplinas químicas |
| MAT | Matemática | Disciplinas matemáticas |
| MUS | Música | Disciplinas musicais |

## Qualidade e Limitações

### Limitações Conhecidas
1. **Campo Pólo**: Sempre vazio, será removido
2. **Linha de Total**: Última linha contém totais, será removida

## Transformações na Camada Silver

### Campos Removidos
- **Pólo**: Campo vazio, sem utilidade

### Campos Adicionados
- **Semestre**: Extraído do nome da aba
- **Departamento**: Derivado dos primeiros 3 caracteres do código
- **Curso**: Informação adicional (ex: "Software")

### Campos Transformados
- **Código**: Convertido para string explícita
- **Nome**: Convertido para string explícita
- **Tipos Numéricos**: Mantidos como inteiros

---

*Última atualização: $(date)*  
*Versão: 1.0*  
