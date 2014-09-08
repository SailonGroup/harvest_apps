# Harvest Apps

Harvest (www.getHarvest.com) is a great web app for tracking time and job costing/billing.

In the endeavour to implement Harvest in our organisation, we had to add functionality not yet available through the use of bash scripts that run in the background.

We use Harvest to store "Request for Payments" rather than invoices per se. This is for book keeping and tax purposes as required by law.

## Final Invoice App

https://github.com/SailonGroup/harvest_apps/tree/master/final_invoice_app.

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

### Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. MySQL 5.6.20
3. postfix 2.2.6
4. wkhtmltopdf 0.12.1 (with patched qt)

## Invoice App

https://github.com/SailonGroup/harvest_apps/tree/master/invoice_app.

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

### Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. MySQL 5.6.20
3. postfix 2.2.6
4. wkhtmltopdf 0.12.1 (with patched qt)

## Statement of Account App

https://github.com/SailonGroup/harvest_apps/tree/master/soa_app.

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

### Version History

v1.0 has been built and tested on:

1. CentOS 6.5
2. MySQL 5.6.20
3. postfix 2.2.6
4. wkhtmltopdf 0.12.1 (with patched qt)

# Bash Scripting

Bash Scripting can be very plain, or very complex with functions and the parade it brings with it. These scripts have been generated with simplicity. However comments are welcome on improvements and I do hope Harvest integrates these features in the near future as it is better to have everything in one place.