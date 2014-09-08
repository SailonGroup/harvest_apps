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
SENDMAIL_ERROR_SUBJECT="Error from invoice_app.sh on $(hostname)"
SENDMAIL_FROM_NAME="Contoso Group Billing"
SENDMAIL_FROM_EMAIL="billing@contosogroup.com"
SENDMAIL_TO_EMAIL="billing@contosogroup.com"
## HARVEST API CALL PARAMETERS
SLEEP_TIME="0.1s"
CONCURRENT_THREADS="10"
## STATIC FOLDERS
BASE_FOLDER="/home/harvest_apps/invoice_app"
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
INVOICES_DELTA_XML_FILE="${TMP_FOLDER}/invoices_delta.xml"
CLIENTS_XML_FILE="${TMP_FOLDER}/clients.xml"
INVOICES_OPEN_PARTIAL_IDS_TXT_FILE="${TMP_FOLDER}/invoices_open_partial_ids.txt"
INVOICES_XML_FILE="${TMP_FOLDER}/invoices.xml"
INVOICE_LINE_ITEMS_CSV_FILE="${TMP_FOLDER}/invoice_line_items.csv"
### LOG FILE
LOG_FILE="${LOGS_FOLDER}/$(date +%Y%m%d)_invoice_app.log"
#### LOG FILE RETENTION
LOG_FILE_RETENTION="30"
## LOCK FILE
LOCK_FILE="${BASE_FOLDER}/invoice_app.lock"

# CHECK STATIC FOLDERS
if [ ! -d "${BASE_FOLDER}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${BASE_FOLDER}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${BASE_FOLDER}', EXITING" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -d "${CSS_FOLDER}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${CSS_FOLDER}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${CSS_FOLDER}', EXITING" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -d "${FONTS_FOLDER}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTS_FOLDER}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTS_FOLDER}', EXITING" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

# CHECK STATIC FILES
if [ ! -s "${FONTFACE_CSS_FILE}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTFACE_CSS_FILE}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${FONTFACE_CSS_FILE}', EXITING" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -s "${PRINT_CSS_FILE}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${PRINT_CSS_FILE}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${PRINT_CSS_FILE}', EXITING" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

if [ ! -s "${INLINE_CSS_FILE}" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${INLINE_CSS_FILE}', EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${INLINE_CSS_FILE}', EXITING" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
	exit 1
fi

# CHECK LOCK FILE
if [ ! -f "${LOCK_FILE}" ]; then
	touch "${LOCK_FILE}"
elif [ "$(pgrep "${0##*/}" | wc -l)" -eq "0" ]; then
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] FOUND '${LOCK_FILE}' BUT NO PROCESS RUNNING, EXITING" 1>&2
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] FOUND '${LOCK_FILE}' BUT NO PROCESS RUNNING, EXITING" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
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
-e "SELECT \`value\` FROM \`invoice_app_settings\` WHERE \`parameter\` = 'harvest_username';" \
"${MYSQL_DB}")"
HARVEST_PASSWORD="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
-e "SELECT \`value\` FROM \`invoice_app_settings\` WHERE \`parameter\` = 'harvest_password';" \
"${MYSQL_DB}")"
HARVEST_SUBDOMAIN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
-e "SELECT \`value\` FROM \`invoice_app_settings\` WHERE \`parameter\` = 'harvest_subdomain';" \
"${MYSQL_DB}")"

# RETRIEVE LAST RUN UTC FROM DB
LAST_RUN_UTC="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
-e "SELECT DATE_FORMAT(DATE_ADD(\`last_update\`, INTERVAL 1 MINUTE), '%Y-%m-%d+%H:%i') FROM \`invoice_app_settings\` WHERE \`parameter\` = 'last_run_utc';" \
"${MYSQL_DB}" | sed 's/:/%3A/g')"

# PULL DATA FOR INVOICES DELTA FROM HARVEST
curl -H "Content-Type: application/xml" -H "Accept: application/xml" -S -s \
-u "${HARVEST_USERNAME}:${HARVEST_PASSWORD}" \
"https://${HARVEST_SUBDOMAIN}.harvestapp.com/invoices?updated_since=${LAST_RUN_UTC}" \
> "${INVOICES_DELTA_XML_FILE}"

# CHECK NUMBER OF INVOICES DELTA RETRIEVED
INVOICES_DELTA_MATCHES="$(grep -c "<invoice>" "${INVOICES_DELTA_XML_FILE}")"

if [ "${INVOICES_DELTA_MATCHES}" -gt "0" ]; then
	
	# SHOW NUMBER OF INVOICES DELTA RETRIEVED
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${INVOICES_DELTA_MATCHES}' INVOICES DELTA RETRIEVED" | tee -a "${LOG_FILE}"
	
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
		sed -i -e '/^<?xml version.*/d' -e 's/ type=".*"//g' \
		-e '/nil="true"/d' -e '/<.*\/>/d' \
		"${INVOICES_DELTA_XML_FILE}"
		
		# CLEAN TABLES IN DB
		mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" \
		-e "DELETE FROM \`invoice_app_clients\`;" \
		"${MYSQL_DB}"
		
		# LOAD DATA TO DB
		mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" -X \
		-e "LOAD XML LOCAL INFILE '${CLIENTS_XML_FILE}' INTO TABLE \`invoice_app_clients\` ROWS IDENTIFIED BY '<client>';
			LOAD XML LOCAL INFILE '${INVOICES_DELTA_XML_FILE}' INTO TABLE \`invoice_app_invoices\` ROWS IDENTIFIED BY '<invoice>';" \
		"${MYSQL_DB}"
		
		# RETRIEVE NEXT LAST RUN UTC FROM DB
		LAST_RUN_UTC="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
		-e "SELECT MAX(\`updated-at\`) FROM \`invoice_app_invoices\`;" \
		"${MYSQL_DB}")"
		
		# RETRIEVE INVOICES OPEN AND PARTIAL IDS
		mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" --batch --skip-column-names \
		-e "SELECT \`id\` FROM \`invoice_app_invoices\` WHERE \`state\` IN ('open','partial');" \
		"${MYSQL_DB}" \
		> "${INVOICES_OPEN_PARTIAL_IDS_TXT_FILE}"
		
		# CHECK NUMBER OF INVOICES OPEN AND PARTIAL IDS
		INVOICES_OPEN_PARTIAL_IDS_MATCHES="$(wc -l < "${INVOICES_OPEN_PARTIAL_IDS_TXT_FILE}")"
		
		if [ "${INVOICES_OPEN_PARTIAL_IDS_MATCHES}" -gt "0" ]; then
			
			# SHOW NUMBER OF INVOICES OPEN AND PARTIAL IDS
			echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${INVOICES_OPEN_PARTIAL_IDS_MATCHES}' INVOICES OPEN AND PARTIAL IDS RETRIEVED" | tee -a "${LOG_FILE}"
			
			# PULL DATA FOR INVOICES FROM HARVEST
			while read ID; do
				
				# PULL DATA FOR INVOICE FROM HARVEST
				curl -H "Content-Type: application/xml" -H "Accept: application/xml" -S -s \
				-u "${HARVEST_USERNAME}:${HARVEST_PASSWORD}" \
				"https://${HARVEST_SUBDOMAIN}.harvestapp.com/invoices/${ID}" \
				>> "${INVOICES_XML_FILE}" &
				
				while [[ "$(jobs -p | wc -l)" -gt "${CONCURRENT_THREADS}" ]]; do
					sleep "${SLEEP_TIME}"
				done
				
			done < "${INVOICES_OPEN_PARTIAL_IDS_TXT_FILE}"
			
			wait
			
			# CHECK NUMBER OF INVOICES RETRIEVED
			INVOICES_MATCHES="$(grep -c "<invoice>" "${INVOICES_XML_FILE}")"
			
			if [ "${INVOICES_MATCHES}" -eq "${INVOICES_OPEN_PARTIAL_IDS_MATCHES}" ]; then
				
				# SHOW NUMBER OF INVOICES RETRIEVED
				echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${INVOICES_MATCHES}' INVOICES RETRIEVED" | tee -a "${LOG_FILE}"
				
				# CLEAN XML FILES
				sed -i -e '/^<?xml version.*/d' -e 's/ type=".*"//g' \
				-e '/nil="true"/d' -e '/<.*\/>/d' \
				"${INVOICES_XML_FILE}"
				sed -i -e 's/^/  /g' -e '1i\<invoices>' -e '$a\<\/invoices>' \
				"${INVOICES_XML_FILE}"
				
				# LOAD INVOICES TO DB
				mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" -X \
				-e "LOAD XML LOCAL INFILE '${INVOICES_XML_FILE}' REPLACE INTO TABLE \`invoice_app_invoices\` ROWS IDENTIFIED BY '<invoice>';" \
				"${MYSQL_DB}"
				
				# RETRIEVE TEMPLATE TRANSLATIONS FROM DB
				ADDRESS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`address\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				ADDRESS_ON_LEFT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`address_on_left\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`amount\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				AMOUNT_DUE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`amount_due\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				CURRENCY_PLACEMENT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`currency_placement\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				DATE_FORMAT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`date_format\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				DESCRIPTION="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`description\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				DISCOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`discount\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				DUE_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`due_date\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				FOR="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`for\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				FROM="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`from\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_AMOUNT_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_amount_column\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_DESCRIPTION_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_description_column\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_QUANTITY_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_quantity_column\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_TYPE_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_type_column\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				HIDE_UNIT_PRICE_COLUMN="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`hide_unit_price_column\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INCLUDE_CURRENCY_CODE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`include_currency_code\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INVOICE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`invoice\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INVOICES="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`invoices\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INVOICE_DOCUMENT_TITLE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`invoice_document_title\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INVOICE_ID="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`invoice_id\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				INVOICE_NOTES="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`invoice_notes\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				ISSUE_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`issue_date\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				NAME="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`name\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				NOTES="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`notes\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`payments\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				PDF_PAGE_NUMBERING="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`pdf_page_numbering\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				PO_NUMBER="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`po_number\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				QUANTITY="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`quantity\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SHOW_DOCUMENT_TITLE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`show_document_title\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SHOW_LOGO="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`show_logo\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SUBJECT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`subject\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				SUBTOTAL="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`subtotal\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				TAX="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`tax\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				TAX2="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`tax2\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				TOTAL_PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`total_payments\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				TYPE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`type\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				UNIT_PRICE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`unit_price\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				UPON_RECEIPT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
				-e "SELECT \`upon_receipt\` FROM \`invoice_app_template_settings\` ORDER BY \`id\` DESC LIMIT 1;" \
				"${MYSQL_DB}")"
				
				# FORMAT TEMPLATE TRANSLATIONS FOR FILE NAMES
				INVOICE_DOCUMENT_TITLE_FILE="${INVOICE_DOCUMENT_TITLE//[[:blank:]]/_}"
				NAME_FILE="${NAME//[[:blank:]]/_}"
				
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
				if [ "${HIDE_QUANTITY_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-quantity-column"
					((COLSPAN--))
				fi
				if [ "${HIDE_TYPE_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-type-column"
					((COLSPAN--))
				fi
				if [ "${HIDE_UNIT_PRICE_COLUMN}" == "true" ]; then
					DOCUMENT_CLASSES="${DOCUMENT_CLASSES} hide-unit_price-column"
					((COLSPAN--))
				fi
				DOCUMENT_CLASSES="${DOCUMENT_CLASSES//^[[:blank:]]\(.*\)/\1}"
				
				# CONSTRUCT HTML TEMPLATES AND PDF FILES FOR INVOICES
				while read ID; do
					
					# RETRIEVE LINE ITEMS FOR INVOICE
					mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set="utf8" --batch --skip-column-names \
					-e "SELECT \`csv-line-items\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
					"${MYSQL_DB}" \
					> "${INVOICE_LINE_ITEMS_CSV_FILE}"
					
					# CLEAN CSV FILE
					sed -i 's/\\n[ ]*/\n/g' \
					"${INVOICE_LINE_ITEMS_CSV_FILE}"
					sed -i -e '/^$/d' -e '1d' -e 's/^/NULL,/g' \
					"${INVOICE_LINE_ITEMS_CSV_FILE}"
					
					# CHECK NUMBER OF LINE ITEMS FOR INVOICE RETRIEVED
					INVOICE_TOTAL_LINE_ITEMS_MATCHES="$(wc -l < ${INVOICE_LINE_ITEMS_CSV_FILE})"
					
					if [ "${INVOICE_TOTAL_LINE_ITEMS_MATCHES}" -gt "0" ]; then
						
						# SHOW NUMBER OF LINE ITEMS FOR INVOICE RETRIEVED
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${INVOICE_TOTAL_LINE_ITEMS_MATCHES}' LINE ITEMS FOR INVOICE '${ID}' RETRIEVED" | tee -a "${LOG_FILE}"
						
						# LOAD LINE ITEMS FOR INVOICE IN DB
						mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "TRUNCATE \`invoice_app_invoice_line_items\`;
							LOAD DATA LOCAL INFILE '${INVOICE_LINE_ITEMS_CSV_FILE}' INTO TABLE \`invoice_app_invoice_line_items\` COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\"' LINES TERMINATED BY '\n';" \
						"${MYSQL_DB}"
									
						# FETCH TEMPLATE PARAMETERS FROM DB FOR INVOICE
						TEMPLATE_CLIENT_NAME="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`name\` FROM \`invoice_app_clients\` WHERE \`id\` = (SELECT \`client-id\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID});" \
						"${MYSQL_DB}")"
						TEMPLATE_CLIENT_ADDRESS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`details\` FROM \`invoice_app_clients\` WHERE \`id\` = (SELECT \`client-id\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID});" \
						"${MYSQL_DB}")"
						TEMPLATE_CLIENT_CURRENCY="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`currency\` FROM \`invoice_app_clients\` WHERE \`id\` = (SELECT \`client-id\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID});" \
						"${MYSQL_DB}")"
						TEMPLATE_CLIENT_CURRENCY_SYMBOL="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`currency-symbol\` FROM \`invoice_app_clients\` WHERE \`id\` = (SELECT \`client-id\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID});" \
						"${MYSQL_DB}")"
						TEMPLATE_NUMBER="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`number\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_PURCHASE_ORDER="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE WHEN \`purchase-order\` IS NOT NULL THEN 'true' ELSE 'false' END FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_PURCHASE_ORDER="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`purchase-order\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_ISSUE_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT DATE_FORMAT(\`issued-at\`, '${DATE_FORMAT}') FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_DUE_DATE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT DATE_FORMAT(\`due-at\`, '${DATE_FORMAT}') FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_DUE_DATE_HUMAN_FORMAT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`due-at-human-format\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_SUBJECT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE WHEN \`subject\` IS NOT NULL THEN 'true' ELSE 'false' END FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_SUBJECT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT \`subject\` FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_SUBTOTAL_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(SUM(\`amount\`),2) FROM \`invoice_app_invoice_line_items\`;" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_DISCOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE WHEN \`discount\` <> 0 THEN 'true' ELSE 'false' END FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_DISCOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`discount\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_DISCOUNT_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`discount-amount\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_TAX="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE WHEN \`tax\` <> 0 THEN 'true' ELSE 'false' END FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_DIFFERENT_TAX="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE COUNT(DISTINCT \`taxed\`) WHEN 1 THEN 'false' WHEN 2 THEN 'true' ELSE NULL END FROM \`invoice_app_invoice_line_items\`;" \
						"${MYSQL_DB}")"
						TEMPLATE_TAX="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`tax\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_TAX_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`tax-amount\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_TAX2="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE WHEN \`tax2\` <> 0 THEN 'true' ELSE 'false' END FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_DIFFERENT_TAX2="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE COUNT(DISTINCT \`taxed2\`) WHEN 1 THEN 'false' WHEN 2 THEN 'true' ELSE NULL END FROM \`invoice_app_invoice_line_items\`;" \
						"${MYSQL_DB}")"
						TEMPLATE_TAX2="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`tax2\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_TAX2_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`tax2-amount\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`amount\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_HAS_PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT CASE WHEN \`amount\` <> \`due-amount\` THEN 'true' ELSE 'false' END FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_PAYMENTS="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`amount\` - \`due-amount\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						TEMPLATE_DUE_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
						-e "SELECT FORMAT(\`due-amount\`,2) FROM \`invoice_app_invoices\` WHERE \`id\` = ${ID};" \
						"${MYSQL_DB}")"
						
						# FORMAT TEMPLATE PARAMETERS FOR FILE NAME
						TEMPLATE_NUMBER_FILE="${TEMPLATE_NUMBER//[^a-zA-Z0-9]/}"
						
						# FORMAT TEMPLATE PARAMETERS FOR CAPITALS
						TEMPLATE_DUE_DATE_HUMAN_FORMAT_FORMATTED="$(
						
						case "${TEMPLATE_DUE_DATE_HUMAN_FORMAT}" in
							"upon receipt")
								echo -n "(${UPON_RECEIPT})"
								;;
							*)
								# CAPITALISE FIRST LETTER OF EACH WORD
								echo -n "($(echo -n "${TEMPLATE_DUE_DATE_HUMAN_FORMAT}" | sed 's/\<./\U&/g'))"
								;;
						esac
						
						)"
						
						# FORMAT TEMPLATE PARAMETERS FOR CURRENCY
						TEMPLATE_AMOUNT_FORMATTED="$(
						
						if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
							if [ "$(echo "${TEMPLATE_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_AMOUNT}"
							else
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
							fi
						else
							echo -n "${TEMPLATE_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
						fi
						
						)$(
						
						if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
							# INCLUDE CURRENCY CODE
							echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
						fi
						
						)"
						TEMPLATE_PAYMENTS_FORMATTED="$(
						
						if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
							if [ "$(echo "${TEMPLATE_PAYMENTS} 0" | awk '{print ($1 > $2)}')" -eq "1" ]; then
								echo -n "-${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_PAYMENTS}"
							else
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_PAYMENTS}" | sed 's/^\(.*\)-\(.*\)$/\1\2/g'
							fi
						else
							if [ "$(echo "${TEMPLATE_PAYMENTS} 0" | awk '{print ($1 > $2)}')" -eq "1" ]; then
								echo -n "-${TEMPLATE_PAYMENTS}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							else
								echo -n "${TEMPLATE_PAYMENTS}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}" | sed 's/^-\(.*\)$/\1/g'
							fi
						fi
						
						)$(
						
						if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
							# INCLUDE CURRENCY CODE
							echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
						fi
						
						)"
						TEMPLATE_DUE_AMOUNT_FORMATTED="$(
						
						if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
							if [ "$(echo "${TEMPLATE_DUE_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_DUE_AMOUNT}"
							else
								echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_DUE_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
							fi
						else
							echo -n "${TEMPLATE_DUE_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
						fi
						
						)$(
						
						if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
							# INCLUDE CURRENCY CODE
							echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
						fi
						
						)"
						
						# CONSTRUCT HTML TEMPLATE FOR INVOICE
						HTML_TEMPLATE="${TMP_FOLDER}/${INVOICE_DOCUMENT_TITLE_FILE}_${TEMPLATE_NUMBER_FILE}_${NAME_FILE}.html"
						echo -e '<!DOCTYPE html>' > "${HTML_TEMPLATE}"
						echo -e "\
<html lang=\"en\">
	<head>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
		<title>
			${INVOICE} ${TEMPLATE_NUMBER} @ ${NAME}
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
							${INVOICE_DOCUMENT_TITLE}
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
											${INVOICE_ID}
										</td>
										<td class=\"definition\">
											<strong>
												${TEMPLATE_NUMBER}
											</strong>
										</td>
									</tr>" >> "${HTML_TEMPLATE}"
						
						# SHOW PURCHASE ORDER
						if [ "${TEMPLATE_HAS_PURCHASE_ORDER}" == "true" ]; then
							echo -e "\
									<tr class=\"purchase-order\">
										<td class=\"label\">
											${PO_NUMBER}
										</td>
										<td class=\"definition\">
											${TEMPLATE_PURCHASE_ORDER}
										</td>
									</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						echo -e "\
									<tr>
										<td class=\"label\">
											${ISSUE_DATE}
										</td>
										<td class=\"definition\">
											${TEMPLATE_ISSUE_DATE}
										</td>
									</tr>
									<tr>
										<td class=\"label\">
											${DUE_DATE}
										</td>
										<td class=\"definition\">
											<span class=\"due-date\">
												${TEMPLATE_DUE_DATE}
												<span class=\"secondary\">
													${TEMPLATE_DUE_DATE_HUMAN_FORMAT_FORMATTED}
												</span>
											</span>
										</td>
									</tr>" >> "${HTML_TEMPLATE}"
						
						# SHOW SUBJECT (RIGHT)
						if [ "${TEMPLATE_HAS_SUBJECT}" == "true" ]; then
							echo -e "\
									<tr class=\"subject subject-address-on-right\">
										<td class=\"label\">
											${SUBJECT}
										</td>
										<td class=\"definition\">
											${TEMPLATE_SUBJECT}
										</td>
									</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						echo -e "\
								</tbody>
							</table>
						</div>
						<div style=\"clear:both;\"></div>"  >> "${HTML_TEMPLATE}"
						
						# SHOW SUBJECT (LEFT)
						if [ "${TEMPLATE_HAS_SUBJECT}" == "true" ]; then
							echo -e "\
						<div class=\"subject-address-on-left client-doc-address\" style=\"display:none\">
							<h3>
								${SUBJECT}
							</h3>
							<div>
								${TEMPLATE_SUBJECT}
							</div>
						</div>" >> "${HTML_TEMPLATE}"
						fi
						
						echo -e "\
					</div>
					<table class=\"client-doc-items\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">
						<thead class=\"client-doc-items-header\">
							<tr>
								<th class=\"item-type first\">
									${TYPE}
								</th>
								<th class=\"item-description\">
									${DESCRIPTION}
								</th>
								<th class=\"item-qty\">
									${QUANTITY}
								</th>
								<th class=\"item-unit-price\">
									${UNIT_PRICE}
								</th>
								<th class=\"item-amount last\">
									${AMOUNT}
								</th>
							</tr>
						</thead>
						<tbody class=\"client-doc-rows\">" >> "${HTML_TEMPLATE}"
						
						# POPULATE LINE ITEMS FOR INVOICE
						for (( LINE_NUMBER=1; LINE_NUMBER<="${INVOICE_TOTAL_LINE_ITEMS_MATCHES}"; LINE_NUMBER++ ));	do
							
							# FETCH TEMPLATE PARAMETERS FROM DB FOR LINE ITEM
							TEMPLATE_LINE_ITEM_TYPE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT \`kind\` FROM \`invoice_app_invoice_line_items\` WHERE \`id\` = ${LINE_NUMBER};" \
							"${MYSQL_DB}")"
							TEMPLATE_LINE_ITEM_DESCRIPTION="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT \`description\` FROM \`invoice_app_invoice_line_items\` WHERE \`id\` = ${LINE_NUMBER};" \
							"${MYSQL_DB}")"
							TEMPLATE_LINE_ITEM_QUANTITY="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT FORMAT(\`quantity\`,2) FROM \`invoice_app_invoice_line_items\` WHERE \`id\` = ${LINE_NUMBER};" \
							"${MYSQL_DB}")"
							TEMPLATE_LINE_ITEM_UNIT_PRICE="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT FORMAT(\`unit_price\`,2) FROM \`invoice_app_invoice_line_items\` WHERE \`id\` = ${LINE_NUMBER};" \
							"${MYSQL_DB}")"
							TEMPLATE_LINE_ITEM_AMOUNT="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT FORMAT(\`amount\`,2) FROM \`invoice_app_invoice_line_items\` WHERE \`id\` = ${LINE_NUMBER};" \
							"${MYSQL_DB}")"
							TEMPLATE_LINE_ITEM_HAS_TAX="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT \`taxed\` FROM \`invoice_app_invoice_line_items\` WHERE \`id\` = ${LINE_NUMBER};" \
							"${MYSQL_DB}")"
							TEMPLATE_LINE_ITEM_HAS_TAX2="$(mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 --batch --skip-column-names \
							-e "SELECT \`taxed2\` FROM \`invoice_app_invoice_line_items\` WHERE \`id\` = ${LINE_NUMBER};" \
							"${MYSQL_DB}")"
							
							echo -e "\
							<tr class=\"$(
							
							# FORMAT LINE ITEM ROW
							if [ "$((LINE_NUMBER%2))" -eq 1 ]; then
								echo -n "row-odd"
							else
								echo -n "row-even"
							fi
							
							)\">
								<td class=\"item-type first desktop\">
									${TEMPLATE_LINE_ITEM_TYPE}
								</td>
								<td class=\"item-description\">
									${TEMPLATE_LINE_ITEM_DESCRIPTION}
								</td>
								<td class=\"item-qty desktop\">
									${TEMPLATE_LINE_ITEM_QUANTITY}
								</td>
								<td class=\"item-unit-price desktop\">
									$(
							
							# FORMAT LINE ITEM UNIT PRICE
							if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
								if [ "$(echo "${TEMPLATE_LINE_ITEM_UNIT_PRICE} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_LINE_ITEM_UNIT_PRICE}"
								else
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_LINE_ITEM_UNIT_PRICE}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
								fi
							else
								echo -n "${TEMPLATE_LINE_ITEM_UNIT_PRICE}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							fi
							
							)
								</td>
								<td class=\"item-amount last\">
									$(
							
							# FORMAT LINE ITEM AMOUNT
							if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
								if [ "$(echo "${TEMPLATE_LINE_ITEM_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_LINE_ITEM_AMOUNT}"
								else
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_LINE_ITEM_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
								fi
							else
								echo -n "${TEMPLATE_LINE_ITEM_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							fi
							
							)
								<span class=\"tax-column-span\">
									$(
							
							# FORMAT LINE ITEM DIFFERENT TAX
							if [ "${TEMPLATE_LINE_ITEM_HAS_TAX}" == "true" ] && [ "${TEMPLATE_HAS_DIFFERENT_TAX}" == "true" ]; then
								echo -n "<sup>*</sup>"
							fi
							
							)
										$(
								
							# FORMAT LINE ITEM DIFFERENT TAX2
							if [ "${TEMPLATE_LINE_ITEM_HAS_TAX2}" == "true" ] && [ "${TEMPLATE_HAS_DIFFERENT_TAX2}" == "true" ]; then
								echo -n "<sup>&#176;</sup>"
							fi
							
							)
									</span>
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
							
						done
						
						echo -e "\
						</tbody>
						<tbody class=\"client-doc-summary\">" >> "${HTML_TEMPLATE}"
						
						# SHOW SUBTOTAL
						if [ "${TEMPLATE_HAS_DISCOUNT}" == "true" ] || [ "${TEMPLATE_HAS_TAX}" == "true" ] || [ "${TEMPLATE_HAS_TAX2}" == "true" ] || [ "${TEMPLATE_HAS_PAYMENTS}" == "true" ]; then
							echo -e "\
							<tr>
								<td class=\"label\" colspan=\"${COLSPAN}\">
									${SUBTOTAL}
								</td>
								<td class=\"subtotal\">
									$(
							
							# FORMAT SUBTOTAL AMOUNT
							if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
								if [ "$(echo "${TEMPLATE_SUBTOTAL_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_SUBTOTAL_AMOUNT}"
								else
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_SUBTOTAL_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
								fi
							else
								echo -n "${TEMPLATE_SUBTOTAL_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							fi
							
							)$(
							
							if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
								# INCLUDE CURRENCY CODE
								echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
							fi
							
							)
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						# SHOW DISCOUNT
						if [ "${TEMPLATE_HAS_DISCOUNT}" == "true" ]; then
							echo -e "\
							<tr>
								<td class=\"label first\" colspan=\"${COLSPAN}\">
									${DISCOUNT}
									<span class=\"tax-percent\">
										(${TEMPLATE_DISCOUNT}%)
									</span>
								</td>
								<td class=\"subtotal\">
									$(
							
							# FORMAT DISCOUNT AMOUNT
							if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
								if [ "$(echo "${TEMPLATE_DISCOUNT_AMOUNT} 0" | awk '{print ($1 > $2)}')" -eq "1" ]; then
									echo -n "-${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_DISCOUNT_AMOUNT}"
								else
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_DISCOUNT_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/\1\2/g'
								fi
							else
								if [ "$(echo "${TEMPLATE_DISCOUNT_AMOUNT} 0" | awk '{print ($1 > $2)}')" -eq "1" ]; then
									echo -n "-${TEMPLATE_DISCOUNT_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
								else
									echo -n "${TEMPLATE_DISCOUNT_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}" | sed 's/^-\(.*\)$/\1/g'
								fi
							fi
							
							)$(
							
							if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
								# INCLUDE CURRENCY CODE
								echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
							fi
							
							)
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						# SHOW TAX
						if [ "${TEMPLATE_HAS_TAX}" == "true" ]; then
							echo -e "\
							<tr>
								<td class=\"label first\" colspan=\"${COLSPAN}\">
									<span>
										${TAX}
											$(
							
							# FORMAT DIFFERENT TAX
							if [ "${TEMPLATE_HAS_DIFFERENT_TAX}" == "true" ]; then
								echo -n "<sup>*</sup>"
							fi
							
							)
										<span class=\"tax-percent\">
											(${TEMPLATE_TAX}%)
										</span>
									</span>
								</td>
								<td class=\"subtotal\">
									$(
							
							# FORMAT TAX AMOUNT
							if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
								if [ "$(echo "${TEMPLATE_TAX_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TAX_AMOUNT}"
								else
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TAX_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
								fi
							else
								echo -n "${TEMPLATE_TAX_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							fi
							
							)$(
							
							if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
								# INCLUDE CURRENCY CODE
								echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
							fi
							
							)
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						# SHOW TAX2
						if [ "${TEMPLATE_HAS_TAX2}" == "true" ]; then
							echo -e "\
							<tr>
								<td class=\"label first\" colspan=\"${COLSPAN}\">
									<span>
										${TAX2}
											$(
							
							# FORMAT DIFFERENT TAX2
							if [ "${TEMPLATE_HAS_DIFFERENT_TAX2}" == "true" ]; then
								echo -n "<sup>&#176;</sup>"
							fi
							
							)
										<span class=\"tax-percent\">
											(${TEMPLATE_TAX2}%)
										</span>
									</span>
								</td>
								<td class=\"subtotal\">
									$(
							
							# FORMAT TAX2 AMOUNT
							if [ "${CURRENCY_PLACEMENT}" == "before" ]; then
								if [ "$(echo "${TEMPLATE_TAX2_AMOUNT} 0" | awk '{print ($1 >= $2)}')" -eq "1" ]; then
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TAX2_AMOUNT}"
								else
									echo -n "${TEMPLATE_CLIENT_CURRENCY_SYMBOL}${TEMPLATE_TAX2_AMOUNT}" | sed 's/^\(.*\)-\(.*\)$/-\1\2/g'
								fi
							else
								echo -n "${TEMPLATE_TAX2_AMOUNT}${TEMPLATE_CLIENT_CURRENCY_SYMBOL}"
							fi
							
							)$(
							
							if [ "${INCLUDE_CURRENCY_CODE}" == "true" ]; then
								# INCLUDE CURRENCY CODE
								echo -n "${TEMPLATE_CLIENT_CURRENCY}" | sed 's/.*\(...\)$/ \1/g'
							fi
							
							)
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						# SHOW PAYMENTS
						if [ "${TEMPLATE_HAS_PAYMENTS}" == "true" ]; then
							echo -e "\
							<tr class=\"payments\">
								<td class=\"label first\" colspan=\"${COLSPAN}\">
									${PAYMENTS}
								</td>
								<td class=\"subtotal\">
									${TEMPLATE_PAYMENTS_FORMATTED}
								</td>
							</tr>" >> "${HTML_TEMPLATE}"
						fi
						
						echo -e "\
							<tr class=\"total\">
								<td class=\"label\" colspan=\"${COLSPAN}\">
									${AMOUNT_DUE}
								</td>
								<td id=\"total-amount\" class=\"total\">
									${TEMPLATE_DUE_AMOUNT_FORMATTED}
								</td>
							</tr>
						</tbody>
					</table>
					<div class=\"client-doc-notes\">
						<h3>
							${NOTES}
						</h3>
						<p class=\"notes\">$(
						
						# FORMAT INVOICE NOTES
						echo -n "${INVOICE_NOTES}" | sed 's/\\n/\n						<br>/g'
						
						)</p>
						<div style=\"clear:both;\"></div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>" >> "${HTML_TEMPLATE}"
						
						# CHECK PDF FOLDER FOR INVOICE OF CLIENT
						CLIENT_PDF_FOLDER="${PDF_FOLDER}/${TEMPLATE_CLIENT_NAME}"
						if [ ! -d "${CLIENT_PDF_FOLDER}" ]; then
							mkdir "${CLIENT_PDF_FOLDER}"
						fi
						INVOICE_PDF_FOLDER="${CLIENT_PDF_FOLDER}/${INVOICES}"
						if [ ! -d "${INVOICE_PDF_FOLDER}" ]; then
							mkdir "${INVOICE_PDF_FOLDER}"
						fi
						
						# CONSTRUCT PDF FILE FOR INVOICE OF CLIENT
						PDF_FILE="${INVOICE_PDF_FOLDER}/${INVOICE_DOCUMENT_TITLE_FILE}_${TEMPLATE_NUMBER_FILE}_${NAME_FILE}.pdf"
						
						# INITIATE WKHTMLTOPDF PROCESS FOR INVOICE OF CLIENT
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] INITIATING WKHTMLTOPDF PROCESS FOR INVOICE '${ID}'" | tee -a "${LOG_FILE}"
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
						
						# CONSTRUCT EMAIL HTML TEMPLATE FOR INVOICE OF CLIENT
						EMAIL_HTML_TEMPLATE="${TMP_FOLDER}/${INVOICE_DOCUMENT_TITLE_FILE}_EMAIL_${TEMPLATE_NUMBER_FILE}_${NAME_FILE}.html"
						EMAIL_HTML_TEMPLATE_BOUNDARY="--=_mimepart_$(uuidgen)"
						echo -e "\
Date: $(date "+%a"), $(date "+%d" | sed 's/^[0]//g') $(date "+%b %Y %T %z")
From: ${SENDMAIL_FROM_NAME} <${SENDMAIL_FROM_EMAIL}>
Reply-To: ${SENDMAIL_FROM_NAME} <${SENDMAIL_FROM_EMAIL}>
To: <${SENDMAIL_TO_EMAIL}>
Message-ID: <$(uuidgen)@$(hostname)>
Subject: ${INVOICE} #${TEMPLATE_NUMBER} for ${TEMPLATE_CLIENT_NAME}
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
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please find hereunder the summary for the attached ${INVOICE} ${TEMPLATE_NUMBER}.</p>
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
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\"><span style=\"font-weight: bold;\">${INVOICE} ${TEMPLATE_NUMBER} Summary</span></p>
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
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${INVOICE_ID}: ${TEMPLATE_NUMBER}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${PO_NUMBER}: $(
							
							if [ "${TEMPLATE_HAS_PURCHASE_ORDER}" == "true" ]; then
								echo -n "${TEMPLATE_PURCHASE_ORDER}"
							fi
							
							)</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${ISSUE_DATE}: ${TEMPLATE_ISSUE_DATE}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${DUE_DATE}: ${TEMPLATE_DUE_DATE} ${TEMPLATE_DUE_DATE_HUMAN_FORMAT_FORMATTED}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${SUBJECT}: $(
							
							if [ "${TEMPLATE_HAS_SUBJECT}" == "true" ]; then
								echo -n "${TEMPLATE_SUBJECT}"
							fi
							
							)</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${AMOUNT}: ${TEMPLATE_AMOUNT_FORMATTED}</p>
					</td>
				</tr>
				<tr>
					<td style=\"margin: 0; padding: 0; width: 450.75pt; height: 9pt; text-align: left; vertical-align: middle;\">
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">${TOTAL_PAYMENTS}: ${TEMPLATE_PAYMENTS_FORMATTED}</p>
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
						<p style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; font-size: 9pt; color: #373737;\">The detailed ${INVOICE} is attached as a PDF.</p>
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
						
						# INITIATE SENDMAIL PROCESS FOR INVOICE OF CLIENT
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] INITIATING SENDMAIL PROCESS FOR INVOICE OF CLIENT '${ID}'" | tee -a "${LOG_FILE}"
						sendmail -t < "${EMAIL_HTML_TEMPLATE}"
						
					else
						# SEND ERROR, REMOVE LOCK FILE AND EXIT
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) NO LINE ITEMS FOR INVOICE '${ID}' RETRIEVED" | tee -a "${LOG_FILE}" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
						rm "${LOCK_FILE}"
						exit 1
					fi
					
				done < "${INVOICES_OPEN_PARTIAL_IDS_TXT_FILE}"
				
				# ARCHIVE INVOICES
				if [ -d "${ARCHIVE_FOLDER}" ]; then
					echo "[$(date +%Y-%m-%d+%H:%M:%S)] ARCHIVING INVOICES" | tee -a "${LOG_FILE}"
					cd "${PDF_FOLDER}"
					tar -czpf "${TMP_FOLDER}/pdf.tar.gz" ./*
					tar -xzpf "${TMP_FOLDER}/pdf.tar.gz" -C "${ARCHIVE_FOLDER}"
					if [ "$?" -eq "0" ]; then
						rm -R "${PDF_FOLDER}"/*
					else
						echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT MOVE INVOICES TO '${ARCHIVE_FOLDER}'." | tee -a "${LOG_FILE}"
					fi
				else
					echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${ARCHIVE_FOLDER}'." | tee -a "${LOG_FILE}"
				fi
				
			else
				# SEND ERROR, REMOVE LOCK FILE AND EXIT
				echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) NUMBER OF INVOICES DO NOT MATCH IDS RETRIEVED" | tee -a "${LOG_FILE}" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
				rm "${LOCK_FILE}"
				exit 1
			fi
			
		else
			echo "[$(date +%Y-%m-%d+%H:%M:%S)] NO INVOICES OPEN AND PARTIAL IDS RETRIEVED" | tee -a "${LOG_FILE}"
		fi
		
		# UPDATE LAST RUN UTC IN DB
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] UPDATING LAST RUN TO '${LAST_RUN_UTC}' UTC IN DB" | tee -a "${LOG_FILE}"
		mysql --login-path="${MYSQL_LOGIN_PATH}" --default-character-set=utf8 -e "UPDATE \`invoice_app_settings\` SET \`last_update\` = '${LAST_RUN_UTC}' WHERE \`parameter\` = 'last_run_utc';" "${MYSQL_DB}"
		
	else
		# SEND ERROR, REMOVE LOCK FILE AND EXIT
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) NO CLIENTS RETRIEVED" | tee -a "${LOG_FILE}" | xargs -I % echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
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