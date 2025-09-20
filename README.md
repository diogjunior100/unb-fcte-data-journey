## UNB FCTE Data Journey

Até o momento, temos um pipeline simples para transformar e analisar dados de insucesso acadêmico em disciplinas da FCTE/UnB. A solução organiza o fluxo em camadas, parte de um arquivo Excel com abas por semestre (Bronze), padroniza e enriquece os dados em um CSV consolidado (Silver) e produz análises e visualizações para apoiar a tomada de decisão (Visualização).


### Objetivos

- Organizar dados de insucesso acadêmico por semestre e disciplina de forma padronizada e reproduzível.
- Viabilizar análises descritivas e comparativas por disciplina, semestre e departamento.
- Apoiar a elaboração de evidências para o planejamento acadêmico e pedagógico.


### Visão geral do pipeline

0) Extração/Ingestão
   - Origem: relatório institucional de insucesso acadêmico exportado em formato Excel a partir do sistema fonte.
   - Procedimento: download/exportação do arquivo mantendo o layout original das abas por semestre; armazenamento em bronze/ com controle de versão por data/semestre quando pertinente.
   - Observação: a automação desta etapa é possível, mas nesta versão o processo é manual, garantindo que o arquivo de origem permaneça inalterado.

1) Bronze (dado bruto)
   - Arquivo: bronze/Relatorio-Lista-Insucesso.xlsx
   - Estrutura: uma aba por semestre (2023.2, 2024.1, 2024.2, 2025.1), com 13 colunas de contagens por disciplina.

2) Silver (transformação e consolidação)
   - Notebook: silver/etl.ipynb
   - Principais etapas: remoção de linha de total/rodapé, descarte da coluna Pólo, tipagem de Código e Nome como texto, criação das colunas derivadas Semestre e Departamento, concatenação entre semestres e exportação para CSV.
   - Saída: silver/lista-insucesso-processed.csv (separador ;). No estado atual, contém 610 linhas e 14 colunas.

3) Visualização e análise
   - Notebook: silver/vizualization.ipynb
   - Conteúdo: leitura do CSV consolidado, exploração descritiva e gráficos para rankings por disciplina, evolução temporal por semestre, análise detalhada da disciplina com maior insucesso, rankings por número de discentes por semestre e comparativos por departamento (incluindo taxa de insucesso e alunos por turma).


### Notebooks do projeto

silver/etl.ipynb

- Objetivo: transformar, padronizar e enriquecer o dado oriundo do Excel e consolidar um dataset único para análises.
- Entradas: bronze/Relatorio-Lista-Insucesso.xlsx (abas 2023.2, 2024.1, 2024.2, 2025.1).
- Transformações aplicadas: remoção da última linha por aba quando se trata de somatório/rodapé; remoção da coluna Pólo; tipagem explícita de Código e Nome como string; criação de Semestre e Departamento (prefixo de Código); concatenação entre semestres.
- Saída: silver/lista-insucesso-processed.csv (CSV, separador ;), com 610 registros e 14 colunas, incluindo Código, Nome, Turmas, Discentes, Cancelamentos, Trancamentos, detalhamento das reprovações e Total Insucesso, além de Semestre e Departamento.

silver/vizualization.ipynb

- Objetivo: analisar e comunicar padrões de insucesso por disciplina, semestre e departamento.
- Entradas: silver/lista-insucesso-processed.csv.
- Análises principais: top 10 disciplinas por Total Insucesso; evolução por semestre com linha de tendência; análise detalhada da disciplina com maior insucesso (valor absoluto e taxa sobre Discentes); rankings por semestre por número de Discentes; comparativo por Departamento com taxa de insucesso e indicador de eficiência (alunos por turma), além de sumários e estatísticas textuais.


### Como executar localmente

Pré-requisitos

- Python 3.11+ (recomendado) e pip.
- Ambiente virtual (venv) recomendado.

Instalação

```bash
python -m venv venv
source venv/bin/activate  # Linux/WSL
pip install -r requirements.txt
```

Execução do pipeline

0) Extração/Ingestão
   - Obter o relatório institucional em formato Excel a partir do sistema fonte e salvar como bronze/Relatorio-Lista-Insucesso.xlsx, mantendo as abas por semestre.

1) Transformação (Silver)
   - Abrir e executar todas as células de silver/etl.ipynb.
   - Ao final, o arquivo silver/lista-insucesso-processed.csv será gerado.

2) Visualização
   - Abrir e executar silver/vizualization.ipynb.
   - As células produzem gráficos e sumários textuais que embasam a apresentação.

Observações sobre caminhos

- Os notebooks usam caminhos relativos ao arquivo do próprio notebook. Mantenha a estrutura de pastas conforme este repositório para execução direta.

### Estrutura do repositório

```
bronze/
  Relatorio-Lista-Insucesso.xlsx
silver/
  etl.ipynb
  vizualization.ipynb
  lista-insucesso-processed.csv  # gerado pelo ETL
README.md
requirements.txt
```
