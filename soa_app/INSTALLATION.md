# Statement of Account App Installation Guide

Please ensure that all criteria specified below is met.

## Linux Machine

Before proceeding, either make sure that you have a Linux machine or VM up and running. Please read https://github.com/SailonGroup/harvest_apps/blob/master/requirements/centos_azure.md if you wish to deploy a CentOS Linux VM on Windows Azure with reserved public IP address.

## Folders and Files

Before proceeding, please read this guide https://github.com/SailonGroup/harvest_apps/blob/master/requirements/username.md.

Download all folders and files in the git hub repository and place them on your machine. A zip file has been compiled to expedite the process and download it directly with "wget". Make sure to do so using the machine account that shall execute the "soa_app.sh" script. First check that you are in the correct path.

```bash
pwd
/home/harvest_apps/
```

Then proceed with the rest of the commands.

```bash
mkdir soa_app
cd soa_app
wget https://github.com/SailonGroup/harvest_apps/blob/master/soa_app/soa_app.zip?raw=true
mv soa_app.zip\?raw\=true soa_app.zip
unzip soa_app.zip
```

Check that you have all files and folders in place.

```bash
ls
css  fonts  images  logs  pdf  soa_app.sh  soa_app.zip  sql
```

Remove the downloaded file.

```bash
rm soa_app.zip
```

The "soa_app.sh" script requires that several folders and files to be available:

1. The static folders "/css/" and "/fonts/" are required. These should contain the "fontface.css", "print.css" and "inline.css" files as well as the fonts used in "fontface.css".
2. The static folder "/images/" and the logo file are optional, depending if you shall use the logo in the template.
3. The work folders "/logs/", "/pdf/" and "/tmp/" will be created if not found. The output PDFs will be stored in the "/pdf/".
4. An archive folder is optional, and files will be stored there once the process completes.

The folder structure generated is:

1. "[Client Name]/[Statement of Accounts]/[STATEMENT_OF_ACCOUNT]\_[Client_Name]\_DDMMYYYY\_[Company_Name].pdf", or
2. "[Statement of Accounts]/[STATEMENT_OF_ACCOUNT]\_[Client_Name]\_DDMMYYYY\_[Company_Name].pdf".

The selection between the above can be changed by commenting and uncommenting the respective lines within the script. Note that all elements are configurable from the DB. We shall get to that in a moment.

Ensure that all variables in the "soa_app.sh" script for folders and files are configured properly.

```bash
## STATIC FOLDERS
BASE_FOLDER="/home/harvest_apps/soa_app"
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
```

The folders and files can be placed elsewhere as long as they are configured properly in the "soa_app.sh" script. Also ensure that the "soa_app.sh" script:

1. Has proper read, write and execute permissions to the base folder.
2. Has proper read permissions to the "/css/", "/fonts/" and "/images/" folders.
3. Has proper read permissions to the "/css/\*", "/fonts/\*" and "/images/\*" files.
4. Has proper write permissions to the "/logs/", "/pdf/" and "/tmp/" base folders.
5. Has proper write permissions to the archive folder, if any.

Also ensure that the script itself is executable.

```bash
chmod 750 soa_app.sh
```

*Note that the "/tmp/" folder is removed on each run.*

If the archive folder exists however the "soa_app.sh" application has insufficient rights to write in the folder, a non-critical error is given and the files are left in "/pdf/". Once sufficient privileges are obtained, the files will be archived in the next complete run (when there is data to process) of the script.

The default log retention period is of 30 days, however you can change this by editing the "soa_app.sh" script.

```bash
#### LOG FILE RETENTION
LOG_FILE_RETENTION="30"
```

## MySQL

Before proceeding, please read this guide https://github.com/SailonGroup/harvest_apps/blob/master/requirements/mysql.md.

Create the table structure in your MySQL DB by loading the mysqldump in the provided "/sql/" folder (remember to change DB in the "soa_app.sql" SQL file).

```bash
cd sql/
mysql --login-path="harvest_apps" "harvest" < soa_app.sql
```

Login to the DB to check that the tables have been loaded.

```bash
mysql --login-path="harvest_apps" "harvest"
mysql> SHOW TABLES;
+--------------------------------+
| Tables_in_harvest              |
+--------------------------------+
| soa_app_clients                |
| soa_app_invoice_payments       |
| soa_app_invoices               |
| soa_app_settings               |
| soa_app_template_settings      |
+--------------------------------+
5 rows in set (0.00 sec)

mysql> exit
```

Ensure that all variables in the "soa_app.sh" script for "mysql" are configured properly.

```bash
## MYSQL DB PARAMETERS
MYSQL_LOGIN_PATH="harvest_apps"
MYSQL_DB="harvest"
```

Also ensure that:

1. The table "final\_invoice\_app\_settings" is configured properly with your Harvest credentials and subdomain.
2. The table "final\_invoice\_app\_template_settings" is configured according to your needs and translations.

In particular (2) will also affect the names in the folder structure created in "/pdf/" which is optionally archived elsewhere.

## postfix

Before proceeding, please read this guide https://github.com/SailonGroup/harvest_apps/blob/master/requirements/postfix.md.

Ensure that the variables for "sendmail" in the "soa_app.sh" script are configured appropriately.

```bash
## SENDMAIL PARAMETERS
SENDMAIL_ERROR_FROM_NAME="CentOS APPS.MACHINE"
SENDMAIL_ERROR_FROM_EMAIL="centos.apps.machine@contosogroup.com"
SENDMAIL_ERROR_TO_EMAIL="it@contosogroup.com"
SENDMAIL_ERROR_SUBJECT="Error from soa_app.sh on $(hostname)"
SENDMAIL_FROM_NAME="Contoso Group Billing"
SENDMAIL_FROM_EMAIL="billing@contosogroup.com"
SENDMAIL_TO_EMAIL="billing@contosogroup.com"
```

## wkhtmltopdf

The "soa_app.sh" script requires "wkhtmltopdf" to be installed on your machine and in the PATH of your account.

Please follow the guide https://code.google.com/p/openesignforms/wiki/wkhtmltopdf on how to install "wkhtmltopdf" properly, in particular:

1. Follow the prerequisites for "wkhtmltopdf" as per guide.
2. Copy the fonts in the provided "/fonts/" folder to "/usr/share/fonts/local/" as per guide.
3. Create the file "/etc/fonts/conf.avail/10-wkhtmltopdf.conf" as per guide.
4. Create the softlink "/etc/fonts/conf.d/10-wkhtmltopdf.conf" to "/etc/fonts/conf.avail/10-wkhtmltopdf.conf" as per guide.

Ensure that all variables in the "soa_app.sh" script for "wkhtmltopdf" are configured properly (in particular the font name).

```bash
## WKHTMLTOPDF PARAMETERS
WKHTMLTOPDF_MARGIN_BOTTOM="12.8mm"
WKHTMLTOPDF_MARGIN_LEFT="15.4mm"
WKHTMLTOPDF_MARGIN_RIGHT="15.4mm"
WKHTMLTOPDF_MARGIN_TOP="20.5mm"
WKHTMLTOPDF_ENCODING="utf8"
WKHTMLTOPDF_FOOTER_FONT_NAME="HelveticaNeueLTW1G"
WKHTMLTOPDF_FOOTER_FONT_SIZE="9"
```

# Using the Statement of Account App

Having completed all of the steps in the Installation Guide, you can run the "soa_app.sh" script through bash or shell.

```bash
/home/harvest_apps/soa_app/soa_app.sh
```

The "soa_app.sh" script can be run as often as required. Simply add a cronjob to your crontab. Remember to set PATH, SHELL and MAIL (just in case an error occurs before the log file can be created). First retrieve the PATH variable for the user account, then just copy it to the crontab of "harvest_apps".

```bash
echo $PATH
/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/harvest_apps//bin
crontab -e
crontab -l
SHELL=/bin/sh
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/harvest_apps//bin
MAILFROM=centos.apps.machine@contosogroup.com
MAILTO=it@contosogroup.com

* * * * * /home/harvest_apps/soa_app/soa_app.sh 1> /dev/null
```

The "soa_app.sh" script uses a simple but efficient locking mechanism that does not allow 2 instances to run simultaneously. In the event that the lockfile is found but there is no process instance running, an error email notification is sent. 

Enjoy!