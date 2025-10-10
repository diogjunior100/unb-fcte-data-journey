import psycopg2
from psycopg2 import sql
import pandas as pd
import os

csv_path = "/app/silver/lista-insucesso-processed.csv"
df = pd.read_csv(csv_path, sep=";")

DB_HOST = os.getenv("DATABASE_HOST", "localhost")
DB_PORT = os.getenv("DATABASE_PORT", "5432")
DB_USER = os.getenv("DATABASE_USER", "postgres")
DB_PASSWORD = os.getenv("DATABASE_PASSWORD", "postgres123")


conn = psycopg2.connect(
    host=DB_HOST,
    port=DB_PORT,
    user=DB_USER,
    password=DB_PASSWORD
)

cursor = conn.cursor()

for _, row in df.iterrows():
    cursor.execute("""
        INSERT INTO disciplinas (
            codigo, nome, turmas, discentes, cancelamentos,
            reprovacoesMedia, reprovacoesNota, reprovacoesFalta,
            reprovacoesMediaFalta, reprovacoesNotaFalta, trancamentos,
            insucessos, semestre, departamento, curso
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        row['Código'],
        row['Nome'],
        row['Turmas'],
        row['Discentes'],
        row['Cancelamentos'],
        row['Reprovações Média'],
        row['Reprovações Nota'],
        row['Reprovações Falta'],
        row['Reprovações Média e Falta'],
        row['Reprovações Nota e Falta'],
        row['Trancamentos'],
        row['Total Insucesso'],
        row['Semestre'],
        row['Departamento'],
        row['Curso']
    ))

conn.commit()
cursor.close()
conn.close()

