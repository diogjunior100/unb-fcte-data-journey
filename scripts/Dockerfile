FROM python:3.11-slim

WORKDIR /app

COPY ../requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY ../silver/lista-insucesso-processed.csv .

CMD ["python", "scripts/populate.py"]