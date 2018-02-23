FROM mysql:8.0

EXPOSE 3306
ENV MYSQL_USER=mysql \
    MYSQL_PASSWORD='dwdstudent2015'

RUN echo '[mysqld]\nskip-host-cache\nskip-name-resolve\nuser=mysql' > /etc/mysql/conf.d/docker.cnf
RUN echo 'bind-address = 0.0.0.0' >> /etc/mysql/my.cnf
RUN mysqld --initialize-insecure --user=mysql
