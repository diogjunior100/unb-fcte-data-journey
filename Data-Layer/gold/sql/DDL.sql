BEGIN;

SAVEPOINT create_dw;

-- SCHEMA DO DATA WAREHOUSE 

CREATE SCHEMA IF NOT EXISTS dw AUTHORIZATION postgres;
SET search_path TO dw;

-- DIMENSÃO

CREATE TABLE IF NOT EXISTS dw.dim_dsc (
    srk_dsc INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cod_dsc VARCHAR(100) NOT NULL,
    nme_dsc VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_tmp (
    srk_tmp INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ano INT NOT NULL,
    sem_ano VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_dpt (
    srk_dpt INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nme_dpt VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_cur (
    srk_cur INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nme_cur VARCHAR(100) NOT NULL
);

-- FATO

CREATE TABLE IF NOT EXISTS dw.fat_ins_dsc (
    srk_fat_ins_dsc INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    srk_dsc INT NOT NULL REFERENCES dw.dim_dsc(srk_dsc) ON DELETE CASCADE,
    srk_tmp INT NOT NULL REFERENCES dw.dim_tmp(srk_tmp) ON DELETE CASCADE,
    srk_dpt INT NOT NULL REFERENCES dw.dim_dpt(srk_dpt) ON DELETE CASCADE,
    srk_cur INT NOT NULL REFERENCES dw.dim_cur(srk_cur) ON DELETE CASCADE,
    trm INT DEFAULT 0,           -- Número de turmas ofertadas
    dst INT DEFAULT 0,           -- Número total de estudantes
    cnc INT DEFAULT 0,           -- Número de cancelamentos
    rpv_med INT DEFAULT 0,       -- Reprovações por média insuficiente
    rpv_not INT DEFAULT 0,       -- Reprovações por nota específica
    rpv_fal INT DEFAULT 0,       -- Reprovações por faltas
    rpv_med_fal INT DEFAULT 0,   -- Reprovações por média e faltas
    rpv_not_fal INT DEFAULT 0,   -- Reprovações por nota e faltas
    trc INT DEFAULT 0,           -- Trancamentos
    ins INT DEFAULT 0            -- Soma total de insucessos
);


COMMIT;