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
## WKHTMLTOPDF PARAMETERS
WKHTMLTOPDF_MARGIN_BOTTOM="12.8mm"
WKHTMLTOPDF_MARGIN_LEFT="15.4mm"
WKHTMLTOPDF_MARGIN_RIGHT="15.4mm"
WKHTMLTOPDF_MARGIN_TOP="20.5mm"
WKHTMLTOPDF_ENCODING="utf8"
WKHTMLTOPDF_FOOTER_FONT_NAME="HelveticaNeueLTW1G"
WKHTMLTOPDF_FOOTER_FONT_SIZE="9"
## SENDMAIL PARAMETERS
SENDMAIL_ERROR_FROM_NAME="CentOS APPS.MACHINE"
SENDMAIL_ERROR_FROM_EMAIL="centos.apps.machine@contosogroup.com"
SENDMAIL_ERROR_TO_EMAIL="itss@contosogroup.com"
SENDMAIL_ERROR_SUBJECT="Error from full_soa_app.sh on $(hostname)"
SENDMAIL_FROM_NAME="Contoso Group Billing"
SENDMAIL_FROM_EMAIL="billing@contosogroup.com"
SENDMAIL_TO_EMAIL="billing@contosogroup.com"
## HARVEST API CALL PARAMETERS
SLEEP_TIME="1s"
CONCURRENT_THREADS="2"
## STATIC FOLDERS
BASE_FOLDER="/home/harvest_apps/full_soa_app"
CSS_FOLDER="${BASE_FOLDER}/css"
FONTS_FOLDER="${BASE_FOLDER}/fonts"
IMAGES_FOLDER="${BASE_FOLDER}/images"
ARCHIVE_FOLDER="/home/harvest_apps/clients"
## WORK FOLDERS
LOGS_FOLDER="${BASE_FOLDER}/logs"
PDF_FOLDER="${BASE_FOLDER}/pdf"
TMP_FOLDER="${BASE_FOLDER}/tmp"
## STATIC FILES
FONTFACE_CSS_FILE="${CSS_FOLDER}/fontface.css"
PRINT_CSS_FILE="${CSS_FOLDER}/print.css"
INLINE_CSS_FILE="${CSS_FOLDER}/inline.css"
### LOGO FILE
LOGO_FILE="${IMAGES_FOLDER}/contosogroup_logo_harvest_invoice.png"
### LOGO DIMENSIONS (ACTUAL IMAGE PIXELS SHOULD BE 7.5 TIMES LARGER)
LOGO_HEIGHT="60"
LOGO_WIDTH="200"
## WORK FILES
CLIENTS_XML_FILE="${TMP_FOLDER}/clients.xml"
CLIENT_IDS_TXT_FILE="${TMP_FOLDER}/invoices_open_partial_paid_client_ids.txt"
INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE="${TMP_FOLDER}/invoices_open_partial_for_clients.xml"
INVOICES_OPEN_PARTIAL_CLIENT_IDS_TXT_FILE="${TMP_FOLDER}/invoices_open_partial_client_ids.txt"
SOA_LINE_ITEMS_FOR_CLIENT_TXT_FILE="${TMP_FOLDER}/soa_line_items_for_client.txt"
SOA_INVOICE_PAYMENT_LINE_ITEMS_XML_FILE="${TMP_FOLDER}/soa_invoice_payment_line_items.xml"
SOA_INVOICE_PAYMENT_LINE_ITEMS_IDS_TXT_FILE="${TMP_FOLDER}/soa_invoice_payment_line_items_ids.txt"
### LOG FILE
LOG_FILE="${LOGS_FOLDER}/$(date +%Y%m%d)_full_soa_app.log"
#### LOG FILE RETENTION
LOG_FILE_RETENTION="30"
## LOCK FILE
LOCK_FILE="${BASE_FOLDER}/full_soa_app.lock"

# CHECK STATIC FOLDERS
if [ ! -d "${BASE_FOLDER}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${BASE_FOLDER}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${BASE_FOLDER}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -d "${CSS_FOLDER}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${CSS_FOLDER}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${CSS_FOLDER}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -d "${FONTS_FOLDER}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTS_FOLDER}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTS_FOLDER}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

# CHECK STATIC FILES
if [ ! -s "${FONTFACE_CSS_FILE}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTFACE_CSS_FILE}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTFACE_CSS_FILE}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -s "${PRINT_CSS_FILE}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${PRINT_CSS_FILE}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${PRINT_CSS_FILE}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -s "${INLINE_CSS_FILE}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${INLINE_CSS_FILE}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${INLINE_CSS_FILE}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

# CHECK LOCK FILE
if [ ! -f "${LOCK_FILE}" ]; then
	touch "${LOCK_FILE}"
elif [ "$(pgrep "${0##*/}" | wc -l)" -eq "0" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] FOUND '${LOCK_FILE}' BUT NO PROCESS RUNNING, EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] FOUND '${LOCK_FILE}' BUT NO PROCESS RUNNING, EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
else
	exit 0
fi

# CHECK WORK FOLDERS
if [ ! -d "${LOGS_FOLDER}" ]; then
	mkdir "${LOGS_FOLDER}"
else
	find "${LOGS_FOLDER}" -name "*.log" -mtime "+${LOG_FILE_RETENTION}" -exec rm {} \;
fi

if [ ! -d "${PDF_FOLDER}" ]; then
	mkdir "${PDF_FOLDER}"
fi

if [ ! -d "${TMP_FOLDER}" ]; then
	mkdir "${TMP_FOLDER}"
else
	rm -R "${TMP_FOLDER}"
	mkdir "${TMP_FOLDER}"
fi

{ #START

# RETRIEVE HARVEST CREDENTIALS FROM DB
HARVEST_USERNAME="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
-e "SELECT \`value\` FROM \`full_soa_app_settings\` WHERE \`parameter\` = 'harvest_username';" \
"${MYSQL_DB}")"
HARVEST_PASSWORD="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
-e "SELECT \`value\` FROM \`full_soa_app_settings\` WHERE \`parameter\` = 'harvest_password';" \
"${MYSQL_DB}")"
HARVEST_SUBDOMAIN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
-e "SELECT \`value\` FROM \`full_soa_app_settings\` WHERE \`parameter\` = 'harvest_subdomain';" \
"${MYSQL_DB}")"

# PULL DATA FOR CLIENTS FROM HARVEST
curl -H "Content-Type: application/xml" -H "Accept: application/xml" -S -s \
-u "${HARVEST_USERNAME}:${HARVEST_PASSWORD}" \
"https://${HARVEST_SUBDOMAIN}.harvestapp.com/clients" \
> "${CLIENTS_XML_FILE}"

# CHECK NUMBER OF CLIENTS RETRIEVED
CLIENTS_MATCHES="$(grep -c "<client>" "${CLIENTS_XML_FILE}")"

if [ "${CLIENTS_MATCHES}" -gt "0" ]; then
	
	# SHOW NUMBER OF CLIENTS RETRIEVED
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${CLIENTS_MATCHES}' CLIENTS RETRIEVED" | tee -a "${LOG_FILE}"
	
	# CLEAN XML FILES
	sed -i -e '/^<?xml version.*/d' -e 's/ type=".*"//g' \
	-e '/nil="true"/d' -e '/<.*\/>/d' \
	"${CLIENTS_XML_FILE}"
	
	# CLEAN TABLES IN DB
	mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" \
	-e "DELETE FROM \`full_soa_app_clients\`;" \
	"${MYSQL_DB}"
	
	# LOAD DATA TO DB
	mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" -X \
	-e "LOAD XML LOCAL INFILE '${CLIENTS_XML_FILE}' INTO TABLE \`full_soa_app_clients\` ROWS IDENTIFIED BY '<client>';" \
	"${MYSQL_DB}"
	
	# RETRIEVE CLIENT IDS FROM DB
	mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" --batch --skip-column-names \
	-e "SELECT \`id\`FROM \`full_soa_app_clients\`" \
	"${MYSQL_DB}" \
	> "${CLIENT_IDS_TXT_FILE}"
	
	# CHECK NUMBER OF CLIENT IDS RETRIEVED
	CLIENT_IDS_MATCHES="$(wc -l < "${CLIENT_IDS_TXT_FILE}")"
	
	if [ "${CLIENT_IDS_MATCHES}" -gt "0" ]; then
		
		# SHOW NUMBER OF CLIENT IDS RETRIEVED
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${CLIENT_IDS_MATCHES}' CLIENT IDS RETRIEVED" | tee -a "${LOG_FILE}"
		
		# PULL DATA FOR INVOICES OPEN AND PARTIAL FOR CLIENTS FROM HARVEST
		while read ID; do
			
			# PULL DATA FOR INVOICES OPEN FOR CLIENT FROM HARVEST
			curl -H "Content-Type: application/xml" -H "Accept: application/xml" -S -s \
			-u "${HARVEST_USERNAME}:${HARVEST_PASSWORD}" \
			"https://${HARVEST_SUBDOMAIN}.harvestapp.com/invoices?client=${ID}&status=open" \
			>> "${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE}" &
			
			# PULL DATA FOR INVOICES PARTIAL FOR CLIENT FROM HARVEST
			curl -H "Content-Type: application/xml" -H "Accept: application/xml" -S -s \
			-u "${HARVEST_USERNAME}:${HARVEST_PASSWORD}" \
			"https://${HARVEST_SUBDOMAIN}.harvestapp.com/invoices?client=${ID}&status=partial" \
			>> "${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE}" &
			
			while [[ "$(jobs -p | wc -l)" -gt "${CONCURRENT_THREADS}" ]]; do
				sleep "${SLEEP_TIME}"
			done
			
		done < "${CLIENT_IDS_TXT_FILE}"
		
		wait
		
		# CHECK NUMBER OF INVOICES OPEN AND PARTIAL FOR CLIENTS RETRIEVED
		INVOICES_OPEN_PARTIAL_FOR_CLIENTS_MATCHES="$(grep -c "<invoice>" "${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE}")"
		
		if [ "${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_MATCHES}" -gt "0" ]; then
			
			# SHOW NUMBER OF INVOICES OPEN AND PARTIAL FOR CLIENTS RETRIEVED
			echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_MATCHES}' INVOICES OPEN AND PARTIAL FOR CLIENTS RETRIEVED" | tee -a "${LOG_FILE}"
			
			# CLEAN XML FILES
			sed -i -e '/^<?xml version.*/d' -e 's/ type=".*"//g' \
			-e '/nil="true"/d' -e '/<.*\/>/d' \
			"${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE}"
			sed -i -e '/<invoices>/d' -e '/<\/invoices>/d' \
			"${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE}"
			sed -i -e '1i\<invoices>' -e '$a\<\/invoices>' \
			"${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE}"
			
			# LOAD INVOICES TO DB
			mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" -X \
			-e "LOAD XML LOCAL INFILE '${INVOICES_OPEN_PARTIAL_FOR_CLIENTS_XML_FILE}' REPLACE INTO TABLE \`full_soa_app_invoices\` ROWS IDENTIFIED BY '<invoice>';" \
			"${MYSQL_DB}"
			
			# PROCESS DATA IN DB
			mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" --batch --skip-column-names \
			-e "DELETE FROM \`full_soa_app_invoices\` WHERE \`state\` = 'paid';" \
			"${MYSQL_DB}"
			
			# RETRIEVE INVOICES OPEN AND PARTIAL CLIENT IDS FROM DB
			mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" --batch --skip-column-names \
			-e "SELECT DISTINCT \`client-id\`FROM \`full_soa_app_invoices\`;" \
			"${MYSQL_DB}" \
			> "${INVOICES_OPEN_PARTIAL_CLIENT_IDS_TXT_FILE}"
			
			# CHECK NUMBER OF INVOICES OPEN AND PARTIAL CLIENT IDS RETRIEVED
			INVOICES_OPEN_PARTIAL_CLIENT_IDS_MATCHES="$(wc -l < "${INVOICES_OPEN_PARTIAL_CLIENT_IDS_TXT_FILE}")"
			
			if [ "${INVOICES_OPEN_PARTIAL_CLIENT_IDS_MATCHES}" -gt "0" ]; then
				
				# SHOW NUMBER OF INVOICES OPEN AND PARTIAL CLIENT IDS RETRIEVED
				echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${INVOICES_OPEN_PARTIAL_CLIENT_IDS_MATCHES}' INVOICES OPEN AND PARTIAL CLIENT IDS RETRIEVED" | tee -a "${LOG_FILE}"
				
				# RETRIEVE TEMPLATE TRANSLATIONS FROM DB
				ADDRESS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`address\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				ADDRESS_ON_LEFT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`address_on_left\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`amount\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				CURRENCY_PLACEMENT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`currency_placement\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				DATE_FORMAT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`date_format\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				DESCRIPTION="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`description\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				FOR="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`for\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				FROM="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`from\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_AMOUNT_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_amount_column\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_DESCRIPTION_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_description_column\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_ISSUE_DATE_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_issue_date_column\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_PAYMENTS_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_payments_column\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_STATUS_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_status_column\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INCLUDE_CURRENCY_CODE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`include_currency_code\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INVOICE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`invoice\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				ISSUE_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`issue_date\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				NAME="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`name\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				NOTES="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`notes\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				PAYMENT_FOR="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`payment_for\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`payments\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				PDF_PAGE_NUMBERING="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`pdf_page_numbering\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				RECEIVED="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`received\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				RETAINER="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`retainer\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SHOW_DOCUMENT_TITLE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`show_document_title\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SHOW_LOGO="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`show_logo\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SOA="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`soa\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SOAS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`soas\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SOA_DOCUMENT_TITLE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`soa_document_title\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SOA_NOTES="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`soa_notes\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				STATEMENT_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`statement_date\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				STATUS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`status\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				TOTAL_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`total_amount\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				TOTAL_AMOUNT_DUE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`total_amount_due\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				TOTAL_PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`total_payments\` FROM \`full_soa_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				
				# FORMAT TEMPLATE TRANSLATIONS FOR FILE NAMES
				NAME_FILE="${NAME//[[:blank:]]/_}"
				SOA_DOCUMENT_TITLE_FILE="${SOA_DOCUMENT_TITLE//[[:blank:]]/_}"
				
				# RETRIEVE STATEMENT CURRENT DATE
				CURRENT_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT DATE_FORMAT(CURRENT_TIMESTAMP, '${DATE_FORMAT}');" \
				"${MYSQL_DB}")"
				
				# FORMAT STATEMENT CURRENT DATE FOR FILE NAMES
				CURRENT_DATE_FILE="${CURRENT_DATE//[^a-zA-Z0-9]/}"
				
				# GENERATE DOCUMENT CLASSES AND COLSPAN FOR SUMMARY
				COLSPAN="4"
				if [ "${ADDRESS_ON_LEFT}" == "true" ]; then
					DOCUMENT_CLASSES="address-on-left"
				fi
				if [ "${HIDE_AMOUNT_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-amount-column"
				fi
				if [ "${HIDE_DESCRIPTION_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-description-column"
				fi
				if [ "${HIDE_STATUS_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-quantity-column"
					((COLSPAN--))
				fi
				if [ "${HIDE_ISSUE_DATE_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-type-column"
					((COLSPAN--))
				fi
				if [ "${HIDE_PAYMENTS_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-unit_price-column"
					((COLSPAN--))
				fi
				DOCUMENT_CLASSES="${DOCUMENT_CLASSES//^[[:blank:]]\(.*\)/\1}"
				
				# CONSTRUCT HTML TEMPLATES AND PDF FILES FOR STATEMENT OF ACCOUNT FOR CLIENTS
				while read ID; do
					
					# RETRIEVE LINE ITEMS FOR STATEMENT OF ACCOUNT OF CLIENT
					mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" --batch --skip-column-names \
					-e "SELECT \`id\` FROM \`full_soa_app_invoices\` WHERE \`client-id\` = ${ID} ORDER BY \`issued-at\` ASC;" \
					"${MYSQL_DB}" \
					> "${SOA_LINE_ITEMS_FOR_CLIENT_TXT_FILE}"
					
					# CHECK NUMBER OF LINE ITEMS FOR STATEMENT OF ACCOUNT OF CLIENT RETRIEVED
					SOA_TOTAL_LINE_ITEMS_FOR_CLIENT_MATCHES="$(wc -l < ${SOA_LINE_ITEMS_FOR_CLIENT_TXT_FILE})"
					
					if [ "${SOA_TOTAL_LINE_ITEMS_FOR_CLIENT_MATCHES}" -gt "0" ]; then
						
						# SHOW NUMBER OF LINE ITEMS FOR STATEMENT OF ACCOUNT OF CLIENT RETRIEVED
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${SOA_TOTAL_LINE_ITEMS_FOR_CLIENT_MATCHES}' LINE ITEMS FOR STATEMENT OF ACCOUNT OF CLIENT '${ID}' RETRIEVED" | tee -a "${LOG_FILE}"
									
						# FETCH TEMPLATE PARAMETERS FROM DB FOR INVOICE
						TEMPLATE_CLIENT_NAME="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`name\` FROM \`full_soa_app_clients\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_CLIENT_ADDRESS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`details\` FROM \`full_soa_app_clients\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_CLIENT_CURRENCY="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`currency\` FROM \`full_soa_app_clients\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_CLIENT_CURRENCY_SYMBOL="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names -e "SELECT \`currency-symbol\` FROM \`full_soa_app_clients\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_TOTAL_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(SUM(\`amount\`),2) FROM \`full_soa_app_invoices\` WHERE \`client-id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE WHEN SUM(\`amount\`) <> SUM(\`due-amount\`) THEN 'true' ELSE 'false' END FROM \`full_soa_app_invoices\` WHERE \`client-id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_TOTAL_PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(SUM(\`amount\`) - SUM(\`due-amount\`),2) FROM \`full_soa_app_invoices\` WHERE \`client-id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_TOTAL_DUE_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(SUM(\`due-amount\`),2) FROM \`full_soa_app_invoices\` WHERE \`client-id\` = ${ID};" \
						"${MYSQL_DB}")"
						
						# FORMAT TEMPLATE PARAMETERS FOR FILE NAME
						TEMPLATE_CLIENT_NAME_FILE="${TEMPLATE_CLIENT_NAME//[[:blank:]]/_}"
						
						# FORMAT TEMPLATE PARAMETERS FOR CURRENCY
						TEMPLATE_TOTAL_AMOUNT_FORMATTED="$(
						
						if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
							if [ "$(echo "${TEMPLATE_TOTAL_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TOTAL_AMOUNT}"
							else
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TOTAL_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
							fi
						else
							echo -n "${TEMPLATE_TOTAL_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
						fi
						
						)$(
						
						if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
							# INCLUDE CURRENCY CODE
							echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
						fi
						
						)"
						TEMPLATE_TOTAL_PAYMENTS_FORMATTED="$(
						
						if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
							if [ "$(echo "${TEMPLATE_TOTAL_PAYMENTS} 0" | awk '{print ($1 > $2)}')" -eq "1" ]; then
								echo -n "-${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TOTAL_PAYMENTS}"
							else
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TOTAL_PAYMENTS}" | sed 's/^\(.*\)-\(.*\)$/\1\2/g'
							fi
						else
							if [ "$(echo "${TEMPLATE_TOTAL_PAYMENTS} 0" | awk '{print ($1 > $2)}')" -eq "1" ]; then
								echo -n "-${TEMPLATE_TOTAL_PAYMENTS}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							else
								echo -n "${TEMPLATE_TOTAL_PAYMENTS}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}" | sed 's/^-\(.*\)$/\1/g'
							fi
						fi
						
						)$(
						
						if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
							# INCLUDE CURRENCY CODE
							echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
						fi
						
						)"
						TEMPLATE_TOTAL_DUE_AMOUNT_FORMATTED="$(
						
						if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
							if [ "$(echo "${TEMPLATE_TOTAL_DUE_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TOTAL_DUE_AMOUNT}"
							else
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TOTAL_DUE_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
							fi
						else
							echo -n "${TEMPLATE_TOTAL_DUE_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
						fi
						
						)$(
						
						if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
							# INCLUDE CURRENCY CODE
							echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
						fi
						
						)"
						
						# CONSTRUCT HTML TEMPLATE FOR STATEMENT OF ACCOUNT OF CLIENT
						HTML_TEMPLATE="${TMP_FOLDER}/${SOA_DOCUMENT_TITLE_FILE}_${TEMPLATE_CLIENT_NAME_FILE}_${CURRENT_DATE_FILE}_${NAME_FILE}.html"
						echo -e '<!DOCTYPE html>' > "${HTML_TEMPLATE}"
						echo -e "\
<html lang=\"en\">
	<head>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
		<title>
			${SOA} ${CURRENT_DATE} @ ${NAME}
		</title>
		<link href=\"${FONTFACE_CSS_FILE}\" rel=\"stylesheet\" type=\"text/css\">
		<link href=\"${PRINT_CSS_FILE}\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">
		<link href=\"${INLINE_CSS_FILE}\" rel=\"stylesheet\" type=\"text/css\">
	</head>
	<body id=\"invoice-show\">
		<div id=\"new_client_view_shell\" class=\"client-shell-web\">
			<div class=\"client-document-container\">
				<div id=\"client-document\" class=\"${DOCUMENT_CLASSES}\">
					<div id=\"client-document-status\" class=\"client-doc-header\">" >> "${HTML_TEMPLATE}"
						
						# SHOW LOGO
						if [ "${SHOW_LOGO}" == "true" ]; then
							echo -e "\
						<div class=\"client-doc-name\">
							<img alt=\"Logo for ${NAME}\" id=\"client-document-logo\" src=\"${LOGO_FILE}\" height=\"${LOGO_HEIGHT}\" width=\"${LOGO_WIDTH}\">
						</div>" >> "${HTML_TEMPLATE}"
						fi
						
						# SHOW DOCUMENT TITLE
						if [ "${SHOW_DOCUMENT_TITLE}" == "true" ]; then
							echo -e "\
						<div class=\"client-doc-doc-type\">
							${SOA_DOCUMENT_TITLE}
						</div>" >> "${HTML_TEMPLATE}"
						fi
						
						echo -e "\
						<div style=\"clear:right;\"></div>
						<div class=\"client-doc-from client-doc-address\">
							<h3>
								${FROM}
							</h3>
							<div>
								<strong>
									${NAME}
								</strong>
								<span class=\"company-address\">
									$(
						
						# FORMAT OWN ADDRESS
						echo -n "${ADDRESS}" | sed 's/\\n/\n									<br>/g'
						
						)
								</span>
							</div>
						</div>
						<div style=\"clear:both;\"></div>
						<div class=\"client-doc-for client-doc-address\">
							<h3>
								${FOR}
							</h3>
							<div>
								<strong>
									${TEMPLATE_CLIENT_NAME}
								</strong>
								<span class=\"company-address\">
									$(
						
						# FORMAT CLIENT ADDRESS
						echo -n "${TEMPLATE_CLIENT_ADDRESS}" | sed 's/\\n/\n									<br>/g'
						
						)
								</span>
							</div>
						</div>
						<div class=\"client-doc-details\">
							<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\">
								<tbody>
									<tr>
										<td class=\"label\">
											${STATEMENT_DATE}
										</td>
										<td class=\"definition\">
											<strong>
												${CURRENT_DATE}
											</strong>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div style=\"clear:both;\"></div>
					</div>
					<table class=\"client-doc-items\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">
						<thead class=\"client-doc-items-header\">
							<tr>
								<th class=\"item-type first\">
									${ISSUE_DATE}
								</th>
								<th class=\"item-description\">
									${DESCRIPTION}
								</th>
								<th class=\"item-qty\">
									${STATUS}
								</th>
								<th class=\"item-unit-price\">
									${PAYMENTS}
								</th>
								<th class=\"item-amount last\">
									${AMOUNT}
								</th>
							</tr>
						</thead>
						<tbody class=\"client-doc-rows\">" >> "${HTML_TEMPLATE}"
						
						# POPULATE LINE ITEMS FOR STATEMENT OF ACCOUNT OF CLIENT
						while read SOA_INVOICE_ID; do
							
							# FETCH TEMPLATE PARAMETERS FROM DB FOR LINE ITEM
							TEMPLATE_INVOICE_LINE_ITEM_ISSUE_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT DATE_FORMAT(\`issued-at\`, '${DATE_FORMAT}') FROM \`full_soa_app_invoices\` WHERE \`id\` = ${SOA_INVOICE_ID};" \
							"${MYSQL_DB}")"
							TEMPLATE_INVOICE_LINE_ITEM_DESCRIPTION="#$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT \`number\` FROM \`full_soa_app_invoices\` WHERE \`id\` = ${SOA_INVOICE_ID};" \
							"${MYSQL_DB}")"
							TEMPLATE_INVOICE_LINE_ITEM_IS_RETAINER="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT CASE WHEN \`retainer-id\` IS NOT NULL THEN 'true' ELSE 'false' END FROM \`full_soa_app_invoices\` WHERE \`id\` = ${SOA_INVOICE_ID};" \
							"${MYSQL_DB}")"
							TEMPLATE_INVOICE_LINE_ITEM_STATUS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT CASE WHEN STR_TO_DATE('${CURRENT_DATE}','${DATE_FORMAT}') > \`due-at\` THEN 'past due' ELSE 'current' END FROM \`full_soa_app_invoices\` WHERE \`id\` = ${SOA_INVOICE_ID};" \
							"${MYSQL_DB}")"
							TEMPLATE_INVOICE_LINE_ITEM_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT FORMAT(\`amount\`,2) FROM \`full_soa_app_invoices\` WHERE \`id\` = ${SOA_INVOICE_ID};" \
							"${MYSQL_DB}")"
							TEMPLATE_INVOICE_LINE_ITEM_HAS_PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT CASE WHEN FORMAT(\`amount\` - \`due-amount\`,2) <> 0  THEN 'true' ELSE 'false' END FROM \`full_soa_app_invoices\` WHERE \`id\` = ${SOA_INVOICE_ID};" \
							"${MYSQL_DB}")"
							
							echo -e "\
							<tr class=\"row-odd\">
								<td class=\"item-type first desktop\">
									${TEMPLATE_INVOICE_LINE_ITEM_ISSUE_DATE}
								</td>
								<td class=\"item-description\">
									${INVOICE} ${TEMPLATE_INVOICE_LINE_ITEM_DESCRIPTION}$(
							
							if [ "${TEMPLATE_INVOICE_LINE_ITEM_IS_RETAINER}" == "true" ]; then
								echo -n " (${RETAINER})"
							fi
							
							)
								</td>
								<td class=\"item-qty desktop\">
									$(echo -n "${TEMPLATE_INVOICE_LINE_ITEM_STATUS}" | sed 's/\<./\U&/g')
								</td>
								<td class=\"item-unit-price desktop\">
									-
								</td>
								<td class=\"item-amount last\">
									$(
							
							# FORMAT LINE ITEM AMOUNT
							if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
								if [ "$(echo "${TEMPLATE_INVOICE_LINE_ITEM_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_INVOICE_LINE_ITEM_AMOUNT}"
								else
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_INVOICE_LINE_ITEM_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
								fi
							else
								echo -n "${TEMPLATE_INVOICE_LINE_ITEM_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							fi
							
							)
									<span class=\"tax-column-span\">
									
									</span>
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
							
							# SHOW INVOICE PAYMENT LINE ITEMS
							if [ "${TEMPLATE_INVOICE_LINE_ITEM_HAS_PAYMENTS}" == "true" ]; then
								
								# PULL DATA FOR INVOICE PAYMENT LINE ITEMS FOR INVOICE FROM HARVEST
								curl -H "Content-Type: application/xml" -H "Accept: application/xml" -S -s \
								-u "${HARVEST_USERNAME}:${HARVEST_PASSWORD}" \
								"https://${HARVEST_SUBDOMAIN}.harvestapp.com/invoices/${SOA_INVOICE_ID}/payments" \
								> "${SOA_INVOICE_PAYMENT_LINE_ITEMS_XML_FILE}"
								
								# CHECK FOR INVOICE PAYMENT LINE ITEMS FOR INVOICE RETRIEVED
								SOA_INVOICE_PAYMENT_LINE_ITEMS_MATCHES="$(grep -c "<payment>" "${SOA_INVOICE_PAYMENT_LINE_ITEMS_XML_FILE}")"
								
								if [ "${SOA_INVOICE_PAYMENT_LINE_ITEMS_MATCHES}" -gt "0" ]; then
									
									# SHOW NUMBER OF INVOICE PAYMENT LINE ITEMS FOR INVOICE RETRIEVED
									echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${SOA_INVOICE_PAYMENT_LINE_ITEMS_MATCHES}' INVOICE PAYMENT LINE ITEMS FOR INVOICE '${SOA_INVOICE_ID}' RETRIEVED" | tee -a "${LOG_FILE}"
									
									# CLEAN XML FILE
									sed -i -e '/^<?xml version.*/d' -e 's/ type=".*"//g' \
									-e '/nil="true"/d' -e '/<.*\/>/d' \
									"${SOA_INVOICE_PAYMENT_LINE_ITEMS_XML_FILE}"
									
									# LOAD INVOICE PAYMENT LINE ITEMS FOR INVOICE TO DB
									mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" -X \
									-e "LOAD XML LOCAL INFILE '${SOA_INVOICE_PAYMENT_LINE_ITEMS_XML_FILE}' INTO TABLE \`full_soa_app_invoice_payments\` ROWS IDENTIFIED BY '<payment>';" \
									"${MYSQL_DB}"
									
									# RETRIEVE INVOICE PAYMENT LINE ITEMS IDS FOR INVOICE FROM DB
									mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" --batch --skip-column-names \
									-e "SELECT \`id\` FROM \`full_soa_app_invoice_payments\` WHERE \`invoice-id\` = ${SOA_INVOICE_ID} ORDER BY \`paid-at\` ASC;" \
									"${MYSQL_DB}" \
									> "${SOA_INVOICE_PAYMENT_LINE_ITEMS_IDS_TXT_FILE}"
									
									# CHECK NUMBER OF INVOICE PAYMENT LINE ITEMS IDS FOR INVOICE RETRIEVED
									SOA_INVOICE_PAYMENTS_FOR_INVOICE_IDS_MATCHES="$(wc -l < "${SOA_INVOICE_PAYMENT_LINE_ITEMS_IDS_TXT_FILE}")"
									
									if [ "${SOA_INVOICE_PAYMENTS_FOR_INVOICE_IDS_MATCHES}" -gt "0" ]; then
										
										# SHOW NUMBER OF INVOICE PAYMENT LINE ITEMS IDS FOR INVOICE RETRIEVED
										echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${SOA_INVOICE_PAYMENTS_FOR_INVOICE_IDS_MATCHES}' INVOICE PAYMENT LINE ITEMS IDS FOR INVOICE '${SOA_INVOICE_ID}' RETRIEVED" | tee -a "${LOG_FILE}"
										
										while read SOA_PAYMENT_ID; do
											TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_ISSUE_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
											-e "SELECT DATE_FORMAT(\`paid-at\`, '${DATE_FORMAT}') FROM \`full_soa_app_invoice_payments\` WHERE \`id\` = ${SOA_PAYMENT_ID};" \
											"${MYSQL_DB}")"
											TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_DESCRIPTION="${PAYMENT_FOR} ${TEMPLATE_INVOICE_LINE_ITEM_DESCRIPTION}"
											TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_HAS_NOTES="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
											-e "SELECT CASE WHEN \`notes\` IS NOT NULL THEN 'true' ELSE 'false' END FROM \`full_soa_app_invoice_payments\` WHERE \`id\` = ${SOA_PAYMENT_ID};" \
											"${MYSQL_DB}")"
											TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_NOTES="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
											-e "SELECT TRIM(\`notes\`) FROM \`full_soa_app_invoice_payments\` WHERE \`id\` = ${SOA_PAYMENT_ID};" \
											"${MYSQL_DB}")"
											TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_PAYMENT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
											-e "SELECT FORMAT(\`amount\`,2) FROM \`full_soa_app_invoice_payments\` WHERE \`id\` = ${SOA_PAYMENT_ID};" \
											"${MYSQL_DB}")"
											
											echo -e "\
							<tr class=\"row-even\">
								<td class=\"item-type first desktop\">
									${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_ISSUE_DATE}
								</td>
								<td class=\"item-description\">
									${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_DESCRIPTION}$(
											
											# SHOW NOTES
											if [ "${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_HAS_NOTES}" == "true" ]; then
												echo -n " (${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_NOTES})"
											else
												echo -n " (${RETAINER})"
											fi
											
											)
								</td>
								<td class=\"item-qty desktop\">
									${RECEIVED}
								</td>
								<td class=\"item-unit-price desktop\">
									$(
											
											# FORMAT LINE ITEM PAYMENT
											if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
												if [ "$(echo "${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_PAYMENT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
													echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_PAYMENT}"
												else
													echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_PAYMENT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
												fi
											else
												echo -n "${TEMPLATE_INVOICE_PAYMENT_LINE_ITEM_PAYMENT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
											fi
											
											)
								</td>
								<td class=\"item-amount last\">
										-
										<span class=\"tax-column-span\">
										
										</span>
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
											
										done < "${SOA_INVOICE_PAYMENT_LINE_ITEMS_IDS_TXT_FILE}"
										
									else
										# SEND ERROR, REMOVE LOCK FILE AND EXIT
										echo "[$(date +%Y-%m-%d+%H:%M:%S)] NO INVOICE PAYMENT LINE ITEMS IDS FOR INVOICE '${SOA_INVOICE_ID}' RETRIEVED" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
										rm "${LOCK_FILE}"
										exit 1
									fi
									
								else
									# SEND ERROR, REMOVE LOCK FILE AND EXIT
									echo "[$(date +%Y-%m-%d+%H:%M:%S)] NO INVOICE PAYMENT LINE ITEMS FOR INVOICE '${SOA_INVOICE_ID}' RETRIEVED" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
									rm "${LOCK_FILE}"
									exit 1
								fi
								
							fi
							
						done < "${SOA_LINE_ITEMS_FOR_CLIENT_TXT_FILE}"
						
						echo -e "\
						</tbody>
						<tbody class=\"client-doc-summary\">" >> "${HTML_TEMPLATE}"
						
						# SHOW TOTAL AMOUNT AND PAYMENTS
						if [ "${TEMPLATE_HAS_PAYMENTS}" == "true" ]; then
							echo -e "\
							<tr>
								<td class=\"label\" colspan=\"${COLSPAN}\">
									${TOTAL_AMOUNT}
								</td>
								<td class=\"subtotal\">
									${TEMPLATE_TOTAL_AMOUNT_FORMATTED}
								</td>
							</tr>
							<tr class=\"payments\">
								<td class=\"label first\" colspan=\"${COLSPAN}\">
									${TOTAL_PAYMENTS}
								</td>
								<td class=\"subtotal\">
									${TEMPLATE_TOTAL_PAYMENTS_FORMATTED}
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						echo -e "\
							<tr class=\"total\">
								<td class=\"label\" colspan=\"${COLSPAN}\">
									${TOTAL_AMOUNT_DUE}
								</td>
								<td id=\"total-amount\" class=\"total\">
									${TEMPLATE_TOTAL_DUE_AMOUNT_FORMATTED}
								</td>
							</tr>
						</tbody>
					</table>
					<div class=\"client-doc-notes\">
						<h3>
							${NOTES}
						</h3>
						<p class=\"notes\">$(
						
						# FORMAT STATEMENT OF ACCOUNT NOTES
						echo -n "${SOA_NOTES}" | sed 's/\\n/\n						<br>/g'
						
						)</p>
						<div style=\"clear:both;\"></div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>" >> "${HTML_TEMPLATE}"
						
						# CHECK PDF FOLDER FOR STATEMENT OF ACCOUNT OF CLIENT
						#CLIENT_PDF_FOLDER="${PDF_FOLDER}/${TEMPLATE_CLIENT_NAME}"
						#if [ ! -d "${CLIENT_PDF_FOLDER}" ]; then
						#	mkdir "${CLIENT_PDF_FOLDER}"
						#fi
						#SOA_PDF_FOLDER="${CLIENT_PDF_FOLDER}/${SOAS}"
						SOA_PDF_FOLDER="${PDF_FOLDER}/${SOAS}"
						if [ ! -d "${SOA_PDF_FOLDER}" ]; then
							mkdir "${SOA_PDF_FOLDER}"
						fi
						
						# CONSTRUCT PDF FILE FOR STATEMENT OF ACCOUNT OF CLIENT
						PDF_FILE="${SOA_PDF_FOLDER}/${SOA_DOCUMENT_TITLE_FILE}_${TEMPLATE_CLIENT_NAME_FILE}_${CURRENT_DATE_FILE}_${NAME_FILE}.pdf"
						
						# INITIATE WKHTMLTOPDF PROCESS FOR STATEMENT OF ACCOUNT OF CLIENT
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] INITIATING WKHTMLTOPDF PROCESS FOR STATEMENT OF ACCOUNT OF CLIENT '${ID}'" | tee -a "${LOG_FILE}"
						wkhtmltopdf \
						--margin-bottom "${WKHTMLTOPDF_MARGIN_BOTTOM}" \
						--margin-left "${WKHTMLTOPDF_MARGIN_LEFT}" \
						--margin-right "${WKHTMLTOPDF_MARGIN_RIGHT}" \
						--margin-top "${WKHTMLTOPDF_MARGIN_TOP}" \
						--quiet \
						--no-outline \
						"${HTML_TEMPLATE}" \
						--encoding "${WKHTMLTOPDF_ENCODING}" \
						--print-media-type \
						--footer-center "${PDF_PAGE_NUMBERING}" \
						--footer-font-name "${WKHTMLTOPDF_FOOTER_FONT_NAME}" \
						--footer-font-size "${WKHTMLTOPDF_FOOTER_FONT_SIZE}" \
						"${PDF_FILE}"
						
						# CONSTRUCT EMAIL HTML TEMPLATE FOR STATEMENT OF ACCOUNT OF CLIENT
						EMAIL_HTML_TEMPLATE="${TMP_FOLDER}/${SOA_DOCUMENT_TITLE_FILE}_EMAIL_${TEMPLATE_CLIENT_NAME_FILE}_${CURRENT_DATE_FILE}_${NAME_FILE}.html"
						EMAIL_HTML_TEMPLATE_BOUNDARY="$(uuidgen)"
						echo -e "\
Date: $(date "+%a"), $(date "+%d" | sed 's/^[0]//g') $(date "+%b %Y %T %z")
From: ${SENDMAIL_FROM_NAME} <${SENDMAIL_FROM_EMAIL}>
Reply-To: ${SENDMAIL_FROM_NAME} <${SENDMAIL_FROM_EMAIL}>
To: <${SENDMAIL_TO_EMAIL}>
Message-ID: <$(uuidgen)@$(hostname)>
Subject: ${SOA} ${CURRENT_DATE} for ${TEMPLATE_CLIENT_NAME}
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary=\"${EMAIL_HTML_TEMPLATE_BOUNDARY}\";
 charset=utf-8
Content-Transfer-Encoding: 7bit

--${EMAIL_HTML_TEMPLATE_BOUNDARY}
Content-Type: text/html;
 charset=utf-8
Content-Disposition: inline

<html>
	<head>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
	</head>
	<body>
		<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"width: 450.75pt;\">
			<tbody>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">Dear Customer,</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please find hereunder the summary for the attached ${SOA} ${CURRENT_DATE}.</p>
					</td>
				</tr>
<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\"><span style=\"font-weight: bold;\">${SOA} ${CURRENT_DATE} Summary</span></p>
					</td>
				</tr>
				<tr style=\"margin: 0; padding: 0; width: 450.75pt;\">
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle; border-bottom: 0.75pt solid #efefef;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${FOR}: ${TEMPLATE_CLIENT_NAME}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${FROM}: ${NAME}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${STATEMENT_DATE}: ${CURRENT_DATE}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${TOTAL_AMOUNT}: ${TEMPLATE_TOTAL_AMOUNT_FORMATTED}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${TOTAL_PAYMENTS}: ${TEMPLATE_TOTAL_PAYMENTS_FORMATTED}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${TOTAL_AMOUNT_DUE}: ${TEMPLATE_TOTAL_DUE_AMOUNT_FORMATTED}</p>
					</td>
				</tr>
				<tr style=\"margin: 0; padding: 0; width: 450.75pt;\">
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle; border-bottom: 0.75pt solid #efefef;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">The detailed ${SOA} is attached as a PDF.</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">Thank you for your business.</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;</p>
					</td>
				</tr>
			</tbody>
		</table>
	</body>
</html>

--${EMAIL_HTML_TEMPLATE_BOUNDARY}
Content-Transfer-Encoding: base64
Content-Type: application/pdf;
 name=${PDF_FILE##*/}
Content-Disposition: attachment;
 filename=${PDF_FILE##*/}

$(base64 "${PDF_FILE}")
--${EMAIL_HTML_TEMPLATE_BOUNDARY}--" > "${EMAIL_HTML_TEMPLATE}"
						
						# INITIATE SENDMAIL PROCESS FOR STATEMENT OF ACCOUNT OF CLIENT
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] INITIATING SENDMAIL PROCESS FOR STATEMENT OF ACCOUNT OF CLIENT '${ID}'" | tee -a "${LOG_FILE}"
						sendmail -t < "${EMAIL_HTML_TEMPLATE}"
						
					else
						# SEND ERROR, REMOVE LOCK FILE AND EXIT
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) NO LINE ITEMS FOR STATEMENT OF ACCOUNT OF CLIENT '${ID}' RETRIEVED" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
						rm "${LOCK_FILE}"
						exit 1
					fi
					
				done < "${INVOICES_OPEN_PARTIAL_CLIENT_IDS_TXT_FILE}"
				
				# ARCHIVE STATEMENT OF ACCOUNT OF CLIENTS
				if [ -d "${ARCHIVE_FOLDER}" ]; then
					echo "[$(date +%Y-%m-%d+%H:%M:%S)] ARCHIVING STATEMENT OF ACCOUNT OF CLIENTS" | tee -a "${LOG_FILE}"
					cd "${PDF_FOLDER}"
					tar -czpf "${TMP_FOLDER}/pdf.tar.gz" ./*
					tar -xzpf "${TMP_FOLDER}/pdf.tar.gz" -C "${ARCHIVE_FOLDER}"
					if [ "$?" -eq "0" ]; then
						rm -R "${PDF_FOLDER}"/*
					else
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT MOVE STATEMENT OF ACCOUNTS TO '${ARCHIVE_FOLDER}'." | tee -a "${LOG_FILE}"
					fi
				else
					echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${ARCHIVE_FOLDER}'." | tee -a "${LOG_FILE}"
				fi
				
			else
				echo "[$(date +%Y-%m-%d+%H:%M:%S)] NO INVOICES OPEN AND PARTIAL CLIENT IDS RETRIEVED" | tee -a "${LOG_FILE}"
			fi
			
		else
			echo "[$(date +%Y-%m-%d+%H:%M:%S)] NO INVOICES OPEN AND PARTIAL FOR CLIENTS RETRIEVED" | tee -a "${LOG_FILE}"
		fi
		
		# UPDATE LAST RUN UTC IN DB
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] UPDATING LAST RUN UTC IN DB" | tee -a "${LOG_FILE}"
		mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 \
		-e "UPDATE \`full_soa_app_settings\` SET \`last_update\` = UTC_TIMESTAMP() WHERE \`parameter\` = 'last_run_utc';" \
		"${MYSQL_DB}"
		
	else
		# SEND ERROR, REMOVE LOCK FILE AND EXIT
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) NO CLIENT IDS RETRIEVED" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		rm "${LOCK_FILE}"
		exit 1
	fi
	
fi

# CLEAN TMP FOLDER
rm -R "${TMP_FOLDER}"

} 2>> "${LOG_FILE}" #END

# CLEAN LOG FILE (^M SHOULD BE DONE THROUGH VI USING CTRL-SHIFT-V CTRL-SHIFT-M)
sed -i 's/^M/\
/g' "${LOG_FILE}"

# REMOVE LOCK FILE AND EXIT
rm "${LOCK_FILE}"
exit 0