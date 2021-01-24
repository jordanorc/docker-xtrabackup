FROM jordanorc/cron:1.1.0

RUN apt-get -y update && \
    apt-get -y install wget curl lsb-release gnupg2 && \
    wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb -P /tmp && \
    dpkg -i /tmp/percona-release_latest.$(lsb_release -sc)_all.deb && \
    percona-release enable-only tools release && \
    apt-get -y update && \
    apt-get -y install percona-xtrabackup-80 && \
    rm -rf /tmp/repo.deb && \
    apt-get -y purge wget curl lsb-release gnupg2 && \
    apt-get -y clean all
RUN mkdir /backup

COPY entrypoint.sh /entrypoint.d/xtrabackup-entrypoint.sh
COPY ./backup.sh /bin/backup