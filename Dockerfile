FROM postgres

ADD ./Data-Layer/gold/sql/DDL.sql /docker-entrypoint-initdb.d
RUN chmod 755 /docker-entrypoint-initdb.d/DDL.sql