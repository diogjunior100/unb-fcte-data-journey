FROM python:3.11-slim

WORKDIR /app

COPY ../requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY ../silver/lista-insucesso-processed.csv .

CMD sh -c "echo 'Aguardando 10 segundos para inicializar...' && sleep 10 && python scripts/populate.py"