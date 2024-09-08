#!/usr/bin/env bash

set -o nounset
set -o errexit

umask 0077

SFTP_USER="anfibrief-cd"
HOST="teri.fsi.uni-tuebingen.de"
PORT="${SSH_PORT}"
TARGET_DIRECTORY="www"
KNOWN_HOSTS="
dGVyaS5mc2kudW5pLXR1ZWJpbmdlbi5kZSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFB\
QkFBQUJBUUR2Zi9ZWExUOGUrT0ZKUGlDbEJoZnlsQ2NhQmsvTGR0YkFETm5YZk5Hczd0R2UxWVZU\
bjNsUysvdVhEQXBScWQ4Tk9WY203ekU0UFRGZEFOZU5PME9NZ09paFNOSHluZWoyTisrRC9TUURx\
blFSajZTNVJIUnhmenJEYU1SNzBlbFFDMmdYQmdlZTduNGxqZDVIdSs2eHNHdWgrTjJOTVZSMENN\
L2QvNWFLWE1iZVlZNmNFODBxYWlrb3ArN25JWDhaMzZraDFBMTRZbnBKQ3FzSTE4NmxaSEhEcGtz\
Qm1JOVZ5ejJVYXJ2S1Fqbkk4aGZqaTUrRTlvTUNQaUlMN2hwK1lyQ3hMVHAzWUlnT2JnejFNNXhx\
ZkRHbDFnNUVpaWNoNlVubVkvZHA2dE9YSUJERXlsSG5IR3pQNHFaWHkzcTZwTlcySHAwb3hteVk2\
YXlkTXlmbgo="

mkdir -p ~/.ssh
echo ${KNOWN_HOSTS} | base64 -d >> ~/.ssh/known_hosts
echo "${SSH_KEY}" | base64 -d >> /tmp/id_rsa

cat <<EOF > sftp-commands
ls -al
-rm *
put anfibrief/*
put anfibrief/.BUILDINFO
chmod 644 *
EOF

sftp -i /tmp/id_rsa -P "${PORT}" -b sftp-commands "${SFTP_USER}@${HOST}:${TARGET_DIRECTORY}"
rm /tmp/id_rsa
