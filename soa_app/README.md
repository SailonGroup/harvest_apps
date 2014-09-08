# Statement of Account App

Harvest (www.getHarvest.com) does not include the feature of issuing "Statement of Accounts" in PDF format. This may be required to send to clients alongside issued invoices.

In our company, we use Harvest to issue "Request for Payments". This is easily achieved by configuring the invoice translations and messages in Harvest. Alongside the "Request for Payments", we also require to issue "Statement of Accounts". There are two types of statements that can be issued:

1. A statement containing all outstanding invoices, "Proforma Invoices" or "Request for Payments" at a particular date.
2. A statement which contains both outstanding as well as paid invoices, "Proforma Invoices" or "Request for Payments" for a particular period.

The "soa_app.sh" script is based on (1). I might revisit (2) with another script in the near future. Although internally we use Harvest to issue "Request for Payments", the "soa_app.sh" script can be used for normal Harvest invoices. We shall refer to such documents as invoices hereto in order to avoid confusion.

This script periodically checks for outstanding invoices in Harvest by using the Harvest API (https://github.com/harvesthq/api) and generates "Statement of Accounts" for clients in PDF format using the same Harvest invoice PDF template. The following sections are used:

1. https://github.com/harvesthq/api/blob/master/Sections/Clients.md
2. https://github.com/harvesthq/api/blob/master/Sections/Invoices.md
3. https://github.com/harvesthq/api/blob/master/Sections/Invoice%20Payments.md

The Invoices API is called using "status=open", "status=partial" and "status=paid" to retrieve recent client fiscal activity. The parameter "updated_since" is used in order to avoid pulling large quantities of data. Invoices with "status=paid" are pulled for two reasons:

1. To update the client's statement.
2. To update the parameter for "updated_since" for the next run.

If any open, partial or paid invoices are found, all client detail is pulled using the Clients API.

The paid invoices are discarded for the rest of the script for the reasons mentioned above.

Bear in mind that thus far we have only pulled outstanding invoices since the "updated_since" date. The "Statement of Account" should also contain any past outstanding invoices. This is achieved by invoking the Invoices API twice, first with "status=open" then with "status=partial". Any "paid" invoices are dropped and the "Statement of Accounts" are generated.

The Invoices Payments API is also used in the case where payments have been effected (this is identified if the "due-amount" is not equal to the "amount" from the data retrieved using the Invoices API).

Harvest only provides detail for retainer invoices, however they do not provide provide detail for retainer payments. The script behaves in the following manner:

1. Invoices where the "retainer-id" is not null are marked as "(Retainer)" in the statement.
2. Payments that do not have any "notes" are marked as "(Retainer)".

Therefore it is important that when you post payments in Harvest other than using Retainer Funds, please ensure to include a note (such as "BANK TRF", "CHQ XXX", "CASH", etc...).

The "soa_app.sh" script does not cache any data and relies on Harvest as the ultimate source of your data.

## Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. MySQL 5.6.20
3. postfix 2.2.6
4. wkhtmltopdf 0.12.1 (with patched qt)

## Installation Guide

Please follow the instructions in https://github.com/SailonGroup/harvest_apps/blob/master/soa_app/INSTALLATION.md.