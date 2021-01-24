# xtrabackup wrapper
This script wraps xtrabackup with some little automation. With the same script, only changes 1 parameters, a full or incremental can be done. The backup are compressed and encrypted (encryption key have to be passed as environment variable).

## backup.sh
``` backup.sh -f|-i ```
* ```-f```: process a full backup
* ```-i```: process an incremental backup

## docker image
the main goal of this image is to be run as a side-car container to a mysql server instance. The datadir should be shared between both.

This image runs cron for periodicall running `backup.sh`.

Usage:
```
docker run --rm -it \
  -v <mysql_datadir>:/var/lib/mysql \
  -v <backup_dir>:/backup \
  -e 'ENCRYPT_KEY=123456'
  -e 'MYSQL_HOST=mysql'
  -e 'MYSQL_PORT=3306'
  -e 'MYSQL_USER=root'
  -e 'MYSQL_PASSWORD=password'
  -e 'MYSQL_DB=db'
  -e 'CRON_FULL=*/5 * * * *'
  -e 'CRON_INCREMENTAL=* * * * *'
  -e 'TZ=America/Sao_Paulo'
jordanorc/xtrabackup:1.0.0

```
An incremental backup is made according to CRON_INCREMENTAL variable and a full one is made according to CRON_FULL variable.