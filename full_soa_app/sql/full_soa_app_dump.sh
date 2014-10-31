#!/bin/bash
#
# v1.0

# EXIT PARAMETER (BE CAUTIOUS WITH THE LOCK FILE)
## EXIT ON ERRORS
#set -e
## DO NOT EXIT ON ERRORS
set +e

# VARIABLES
## MYSQL DB PARAMETERS
MYSQL_LOGIN_PATH="harvest_apps"
MYSQL_DB="harvest"
MYSQL_TABLES="\
full_soa_app_clients \
full_soa_app_invoice_payments \
full_soa_app_invoices \
full_soa_app_settings \
full_soa_app_template_settings"
MYSQL_DUMP_FILE="/home/harvest_apps/full_soa_app/sql/full_soa_app.sql"

# MYSQLDUMP
CMD="$(echo "mysqldump --login-path=\"${MYSQL_LOGIN_PATH}\" \"${MYSQL_DB}\" \"${MYSQL_TABLES// /\" \"}\" > \"${MYSQL_DUMP_FILE}\"")"
eval "${CMD}"
