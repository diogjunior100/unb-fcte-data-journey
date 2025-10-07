FROM postgres

ADD ./scripts/sql/DDL.sql /docker-entrypoint-initdb.d