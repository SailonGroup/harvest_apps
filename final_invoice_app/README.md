# Final Invoice App

Harvest (www.getHarvest.com) does not include the feature of "Proforma Invoices" or "Request for Payments" alongside its built-in invoices. This may be required for bookkeeping and tax purposes.

In order to resolve this issue, you can configure Harvest to keep "Proforma Invoices" or "Request for Payments" by configuring the invoice translations and messages in Harvest. We shall refer to "Proforma Invoices" or "Request for Payments" as being the standard invoices in Harvest hereto.

Once an invoice is fully paid, you may require to produce a final fiscal invoice, thereon referred to as "Final Invoice", to your client containing all line items as well as payments.

This script periodically checks invoices in Harvest by using the Harvest API (https://github.com/harvesthq/api) and generates "Final Invoices" for clients in PDF format using the same Harvest invoice PDF template. The following sections are used:

1. https://github.com/harvesthq/api/blob/master/Sections/Clients.md
2. https://github.com/harvesthq/api/blob/master/Sections/Invoices.md

The Invoices API is called using the parameter "updated_since" in order to avoid pulling large quantities of data. If any invoices are found, the Clients API is used to pull all client data.

Once the invoices and client data has been populated in the DB, a list of invoice IDs where their "state" is "paid" are retrieved. Since the Invoices API also returns retainer invoices which do not require a "Final Invoice" as these are considered as payments on account, a further check is made where only invoices with the "retainer-id" field empty are retrieved.

Upon retrieval, the Invoices API is used to pull each invoice data individually using the invoice IDs in order to retrieve the "csv-line-items". There is no need to pull payments for the "Final Invoices" as these can be easily calculated with the difference of "amount" and "due-amount". Harvest does not provide detail for retainer payments and therefore these shall appear as normal payments in the generated template.

The "final_invoice_app.sh" script does not cache any data and relies on Harvest as the ultimate source of your data.

## Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. MySQL 5.6.20
3. postfix 2.2.6
4. wkhtmltopdf 0.12.1 (with patched qt)

## Installation Guide

Please follow the instructions in https://github.com/BusuttilGroup/harvest_apps/blob/master/final_invoice_app/INSTALLATION.md.