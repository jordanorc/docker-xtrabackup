#!/bin/bash
set -e

initialize_system() {
  printenv >> /etc/environment
  export CRONTAB_ENTRY="${CRON_FULL} /bin/bash -l /bin/backup -f >> /var/log/backup.log 2>&1\n ${CRON_INCREMENTAL} /bin/bash -l /bin/backup -i >> /var/log/backup.log 2>&1"
}

initialize_system