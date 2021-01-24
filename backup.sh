#!/bin/bash
#
# Backup Mode. Possible values:
# - SIMPLE: Create ${TARGET_PREFIX}/${DATE}
# - FULL: Create ${TARGET_PREFIX}/full-${DATE}
# - INCREMENTAL: Create ${TARGET_PREFIX}/full-{LASTDATE}-inc-${DATE} based on the last full-${DATE}
#
MYSQL_USER="${MYSQL_USER:-}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
MYSQL_HOST="${MYSQL_HOST:-}"
MYSQL_PORT="${MYSQL_PORT}"
BACKUP_DIRECTORY="/backup"
DATA_DIRECTORY="/var/lib/mysql"
ENCRYPT_KEY="${ENCRYPT_KEY:-}"
BACKUP_BIN="/usr/bin/xtrabackup"

find_last_full_backup() {
    #FILES=( $(ls -d * | sort -r | head -1) )
    FILE=($(find ${BACKUP_DIRECTORY} -maxdepth 1 ! -path ${BACKUP_DIRECTORY} -type d | cut -sd / -f 3- | sort -r | head -1))
    echo "${FILE}"
    return
}

do_incremental() {
    if [ -z "${BASE_BACKUP_NAME}" ]; then
        echo "ERROR: Full backup not found."
        echo
        exit 1
    fi

    BASE_BACKUP_PATH="${BACKUP_DIRECTORY}/${BASE_BACKUP_NAME}/${BASE_BACKUP_NAME}-full"
    BACKUP_NAME="${BASE_BACKUP_NAME}/$DATE-inc"
    BACKUP_PATH="${BACKUP_DIRECTORY}/${BACKUP_NAME}"

    echo "=============================="
    echo "=     Incremental backup     ="
    echo "=============================="
    echo ""
    echo "Base backup: ${BASE_BACKUP_PATH}"
    echo "Backup dir: ${BACKUP_PATH}"

    ${BACKUP_BIN} --backup --incremental-basedir=${BASE_BACKUP_PATH} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} --target-dir=${BACKUP_PATH} --encrypt-key=${ENCRYPT_KEY} --compress
}

do_full() {
    BACKUP_NAME="${DATE}-full"
    BACKUP_BASE_PATH="${BACKUP_DIRECTORY}/${DATE}"
    BACKUP_PATH="${BACKUP_BASE_PATH}/$BACKUP_NAME"

    echo "=============================="
    echo "=         Full backup        ="
    echo "=============================="
    echo ""
    echo "Backup dir: ${BACKUP_PATH}"

    mkdir -p ${BACKUP_BASE_PATH}
    ${BACKUP_BIN} --backup --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} --target-dir=${BACKUP_PATH} --encrypt-key=${ENCRYPT_KEY} --compress
}

cleanup() {
    find ${BACKUP_DIRECTORY} -maxdepth 1 ! -path ${BACKUP_DIRECTORY} -empty -type d -delete
}

main() {
    DATE=$(date '+%Y-%m-%d-%H%M%S')
    BASE_BACKUP_NAME="$(find_last_full_backup)"
    # echo "Base backup: ${BASE_BACKUP_NAME}"
    cleanup
    while [ "$#" -gt 0 ]; do
        case $1 in
        -i) do_incremental ;;
        -f) do_full ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
        esac
        shift
    done
}

main "$@"
