import psycopg2
import pandas as pd

csv_path = "../silver/lista-insucesso-processed.csv"

df = pd.read_csv(csv_path, sep=";")

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="postgres",
    user="postgres",
    password="postgres123"
)

cursor = conn.cursor()

for _, row in df.iterrows():
    cursor.execute("""
        INSERT INTO disciplinas (
            codigo, nome, turmas, discentes, cancelamentos,
            reprovacoesMedia, reprovacoesNota, reprovacoesFalta,
            reprovacoesMediaFalta, reprovacoesNotaFalta, trancamentos,
            insucessos, semestre, departamento
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
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
        row['Departamento']
    ))

conn.commit()
cursor.close()
conn.close()

