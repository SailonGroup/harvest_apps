# Full Statement of Account App

Harvest (www.getHarvest.com) does not include the feature of issuing "Statement of Accounts" in PDF format. This may be required to send to clients alongside issued invoices.

In our company, we use Harvest to issue "Request for Payments". This is easily achieved by configuring the invoice translations and messages in Harvest. Alongside the "Request for Payments", we also require to issue "Statement of Accounts". There are two types of statements that can be issued:

1. A statement containing all outstanding invoices, "Proforma Invoices" or "Request for Payments" at a particular date.
2. A statement which contains both outstanding as well as paid invoices, "Proforma Invoices" or "Request for Payments" for a particular period.

The "full_soa_app.sh" script is based on (1). We might revisit (2) with another script in the near future. Although internally we use Harvest to issue "Request for Payments", the "full_soa_app.sh" script can be used for normal Harvest invoices. We shall refer to such documents as invoices hereto in order to avoid confusion.

This script generates a "Statement of Account" for each client having any outstanding invoices in Harvest by using the Harvest API (https://github.com/harvesthq/api). The "Statement of Accounts" are generated in the same PDF format used for Harvest invoices. The following sections are used:

1. https://github.com/harvesthq/api/blob/master/Sections/Clients.md
2. https://github.com/harvesthq/api/blob/master/Sections/Invoices.md
3. https://github.com/harvesthq/api/blob/master/Sections/Invoice%20Payments.md

The Clients API is used to retrieve all of the clients. For each client, open or partial invoices are then retrieved using the Invoices API.

The Invoices Payments API is also used in the case where payments have been effected (this is identified if the "due-amount" is not equal to the "amount" from the data retrieved using the Invoices API).

Harvest only provides detail for retainer invoices, however they do not provide provide detail for retainer payments. The script behaves in the following manner:

1. Invoices where the "retainer-id" is not null are marked as "(Retainer)" in the statement.
2. Payments that do not have any "notes" are marked as "(Retainer)".

Therefore it is important that when you post payments in Harvest other than using Retainer Funds, please ensure to include a note (such as "BANK TRF", "CHQ XXX", "CASH", etc...).

The "full_soa_app.sh" script does not cache any data and relies on Harvest as the ultimate source of your data.

## Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. MySQL 5.6.20
3. postfix 2.2.6
4. wkhtmltopdf 0.12.1 (with patched qt)

## Installation Guide

Please follow the instructions in https://github.com/SailonGroup/harvest_apps/blob/master/full_soa_app/INSTALLATION.md.