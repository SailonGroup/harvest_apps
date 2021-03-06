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
invoice_app_clients \
invoice_app_invoice_line_items \
invoice_app_invoices \
invoice_app_settings \
invoice_app_template_settings"
MYSQL_DUMP_FILE="/home/harvest_apps/invoice_app/sql/invoice_app.sql"

# MYSQLDUMP
CMD="$(echo "mysqldump --login-path=\"${MYSQL_LOGIN_PATH}\" \"${MYSQL_DB}\" \"${MYSQL_TABLES// /\" \"}\" > \"${MYSQL_DUMP_FILE}\"")"
eval "${CMD}"
