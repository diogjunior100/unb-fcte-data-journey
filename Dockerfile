FROM postgres

ADD ./Data-Layer/silver/sql/DDL.sql /docker-entrypoint-initdb.d/DDL_silver.sql
ADD ./Data-Layer/gold/sql/DDL.sql /docker-entrypoint-initdb.d/DDL_gold.sql