FROM postgres

ADD ./scripts/sql/DDL.sql /docker-entrypoint-initdb.d
RUN chmod 755 /docker-entrypoint-initdb.d/DDL.sql