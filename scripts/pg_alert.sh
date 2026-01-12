#!/bin/bash

TYPE="$1"      # SUCCESS | FAILURE
MESSAGE="$2"

HOSTNAME=$(hostname -f)
DATE=$(date)

# Email
EMAIL_ENABLED=true
EMAIL_TO="dba-team@company.com"
EMAIL_FROM="postgres@${HOSTNAME}"

# Slack
SLACK_ENABLED=true
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T000/B000/XXXX"

SUBJECT="[PostgreSQL Backup ${TYPE}] ${HOSTNAME}"

##############################################
# Email Alert
##############################################
if [ "$EMAIL_ENABLED" = true ]; then
  echo -e "Host: ${HOSTNAME}\nDate: ${DATE}\n\n${MESSAGE}" \
    | mailx -s "${SUBJECT}" -r "${EMAIL_FROM}" "${EMAIL_TO}"
fi

##############################################
# Slack Alert
##############################################
if [ "$SLACK_ENABLED" = true ]; then
  COLOR="good"
  [ "$TYPE" = "FAILURE" ] && COLOR="danger"

  curl -s -X POST -H 'Content-type: application/json' \
    --data "{
      \"attachments\": [{
        \"color\": \"${COLOR}\",
        \"title\": \"PostgreSQL Backup ${TYPE}\",
        \"text\": \"${MESSAGE}\",
        \"footer\": \"${HOSTNAME}\",
        \"ts\": $(date +%s)
      }]
    }" \
    "$SLACK_WEBHOOK_URL" >/dev/null
fi
