# Invoice App

Harvest (www.getHarvest.com) does not include the feature of "Proforma Invoices" or "Request for Payments" alongside its built-in invoices. This may be required for bookkeeping and tax purposes.

In order to resolve this issue, you can configure Harvest to keep "Proforma Invoices" or "Request for Payments" by configuring the invoice translations and messages in Harvest. Harvest invoices, "Proforma Invoices" and "Request for Payments shall be collectively referred to as invoices hereinafter.

This script periodically checks for such invoices once they are created or updated (e.g. when a payment is registered) by using the Harvest API (https://github.com/harvesthq/api) and generates invoices for clients in PDF format using the same Harvest invoice PDF template. Translations, just as in Harvest, can be configured in order to reflect your organisation needs.

In essence, this script reproduces the same PDFs that are stored in Harvest, and archives them in either local or cloud storage. Moreover, an email is sent (currently only restricted to one email) which can have a different HTML format other than that used by Harvest. The script therefore can be used as:

1. An alternative to generate customised HTML email templates.
2. An automatic backup tool that stores the invoice PDFs elsewhere.

The following sections of the Harvest API are used:

1. https://github.com/harvesthq/api/blob/master/Sections/Clients.md
2. https://github.com/harvesthq/api/blob/master/Sections/Invoices.md

The Invoices API is called using the parameter "updated_since" in order to avoid pulling large quantities of data. If any invoices are found, the Clients API is used to pull all client data.

Once the invoices and client data has been populated in the DB, a list of invoice IDs where their "state" is either "open" or "partial" are retrieved. 

Upon retrieval, the Invoices API is used to pull each invoice data individually using the invoice IDs in order to retrieve the "csv-line-items". There is no need to pull payments for partially paid invoices as these can be easily calculated with the difference of "amount" and "due-amount". Harvest does not provide detail for retainer payments and therefore these shall appear as normal payments in the generated template.

The "invoice_app.sh" script does not cache any data and relies on Harvest as the ultimate source of your data.

You may also find interesting our "Final Invoice App" which is required when using Harvest for "Proforma Invoices" or "Request for Payments". When a "Proforma Invoice" or "Request for Payment" is fully paid, you may require to produce a final fiscal invoice to your client containing all line items as well as payments. You can find more detail about this app at https://github.com/davbusu/harvest_apps/tree/master/final_invoice_app.

## Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. MySQL 5.6.20
3. postfix 2.2.6
4. wkhtmltopdf 0.12.1 (with patched qt)

## Installation Guide

Please follow the instructions in https://github.com/davbusu/harvest_apps/blob/master/invoice_app/INSTALLATION.md.