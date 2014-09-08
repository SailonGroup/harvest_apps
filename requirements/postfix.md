# postfix

The ".sh" script requires "postfix" to be installed on your machine and "sendmail" to be in the PATH of your account. It is used for both sending errors as well as mailing the generated PDF files to a particular address. The feature to mail the document directly to the clients shall be enabled in the near future.

Please follow the guide https://www.zulius.com/how-to/set-up-postfix-with-a-remote-smtp-relay-host/ on how to install "postfix" properly.

## Office 365 SMTP Relay and Client SMTP Submission

There are many tutorials on how to get "postfix" up and running with common SMTP relays, including Gmail. However if you wish to simply use the Office 365 SMTP server in client submission mode, the configuration is not trivial.

Office 365 allows to use the SMTP server using 3 methods (http://technet.microsoft.com/en-us/library/dn554323(v=exchg.150).aspx):

1. SMTP Relay
2. Client SMTP Submission
3. Direct Send

### SMTP Relay

For SMTP Relay, you will require that your machine has a static public IP. Please follow the steps detailed in http://technet.microsoft.com/en-us/library/dn554323(v=exchg.150).aspx to setup the inbound connector. Take note of the MX record.

In this type of setup, Office 365 is only used as a relay and does not imply that the originating address needs to be an account, alias, distribution list, etc. created in Office 365. Office 365 will not authenticate any parameters in the header.

Execute the steps below once the connector is setup.

```bash
sudo yum install postfix
sudo /etc/init.d/sendmail stop
sudo chkconfig --del sendmail
```

You have the option to use TLS in order to encrypt the information being sent. We shall be using TLS in this setup.

Locate your CA root certificate. On CentOS 6.5, it is located at "/etc/pki/tls/certs/ca-bundle.crt".

Configure your "main.cf" as illustrated in the following steps.

```bash
sudo vi /etc/postfix/main.cf
```

Ensure the following configurations in "main.cf".

```bash
myhostname = host.domain.com
mydomain = domain.com
myorigin = $mydomain
...
inet_interfaces = localhost
inet_protocols = ipv4
...
relayhost = [mxrecord]:25
```

The "mxrecord" is the MX record obtained earlier. This would look similar to "contosogroup-com.mail.protection.outlook.com".

Add the followings lines to "main.cf".

```bash
# SMTP (Client Side)
smtp_sasl_auth_enable = no
smtp_use_tls = yes
smtp_sasl_security_options = encrypt
smtp_tls_CAfile = /etc/pki/tls/certs/ca-bundle.crt
smtp_generic_maps = hash:/etc/postfix/generic
```

Edit the "generic" file.

```bash
sudo vi /etc/postfix/generic
```

Add the following to "generic". Change "domain" to what you have setup as "mydomain" in "main.cf". Change "contoso" to correspond to your Office 365 account domain. You can set "username" to anything you would like to, such as "no-reply". If you wish to receive email for the said "username", you will have to configure that account (either as a user, an alias, distribution list, etc.) in Office 365.

```bash
harvet_apps@domain.com				username@contoso.com
```

Execute the following commands.

```bash
sudo postmap /etc/postfix/sasl_password
sudo postmap /etc/postfix/generic
sudo chmod 600 sasl_password sasl_password.db generic generic.db
sudo chkconfig postfix on
sudo service postfix start
```

If the "chkconfig" command returns an error, execute this command prior to its execution.

```bash
sudo chkconfig --add postfix
```

Ensure that "sendmail" is using "postfix" as the default MTA.

```bash
sudo alternatives --config mta

There is 1 program that provides 'mta'.

  Selection    Command
-----------------------------------------------
*+ 1           /usr/sbin/sendmail.postfix

Enter to keep the current selection[+], or type selection number: 1
```

Test it out.

```bash
echo -e "To: example@contosogroup.com\n\
From: CentOS APPS.MACHINE <centos.apps.machine@contosogroup.com>\n\
Subject: Test\n\
MIME-Version: 1.0\n\
Content-Type: text/plain\n\
\n\
Test!" | sendmail -t
```

### Client SMTP Submission

For Client SMTP Submission, execute the steps below.

```bash
sudo yum install postfix cyrus-sasl cyrus-sasl-plain
sudo /etc/init.d/sendmail stop
sudo chkconfig --del sendmail
```

Check where is "postfix" and if it has SSL configured.

```bash
sudo whereis -b postfix
postfix: /usr/sbin/postfix /etc/postfix /usr/libexec/postfix
sudo ldd /usr/sbin/postfix
...
        libssl.so.10 => /usr/lib64/libssl.so.10 (0x00007f967fd34000)
...
```

Locate your CA root certificate. On CentOS 6.5, it is located at "/etc/pki/tls/certs/ca-bundle.crt".

Configure your "main.cf" as illustrated in the following steps.

```bash
sudo vi /etc/postfix/main.cf
```

Ensure the following configurations in "main.cf".

```bash
myhostname = host.domain.com
mydomain = domain.com
myorigin = $mydomain
...
inet_interfaces = localhost
inet_protocols = ipv4
...
relayhost = [smtp.office365.com]:587
```

Add the followings lines to "main.cf".

```bash
# SASL (Client Side)
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_password
smtp_sasl_security_options = noanonymous

# SMTP (Client Side)
smtp_send_dummy_mail_auth = yes
smtp_always_send_ehlo = yes
smtp_use_tls = yes
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/pki/tls/certs/ca-bundle.crt
smtp_generic_maps = hash:/etc/postfix/generic
```

Edit (or create) the "sasl_password" file.

```bash
sudo vi /etc/postfix/sasl_password
```

Add the following to "sasl_password". Change "username", "contoso" and "password" to correspond to your Office 365 account.

```bash
smtp.office365.com			username@contoso.com:password
```

Edit the "generic" file. *This is very important for Office 365.*

```bash
sudo vi /etc/postfix/generic
```

Add the following to "generic". Change "domain" to what you have setup as "mydomain" in "main.cf". Change "username" and "contoso" to correspond to your Office 365 account.

```bash
harvest_apps@domain.com		username@contoso.com
```

Execute the following commands.

```bash
sudo postmap /etc/postfix/sasl_password
sudo postmap /etc/postfix/generic
sudo chmod 600 sasl_password sasl_password.db generic generic.db
sudo chkconfig postfix on
sudo service postfix start
```

If the "chkconfig" command returns an error, execute this command prior to its execution.

```bash
sudo chkconfig --add postfix
```

Ensure that "sendmail" is using "postfix" as the default MTA.

```bash
sudo alternatives --config mta

There is 1 program that provides 'mta'.

  Selection    Command
-----------------------------------------------
*+ 1           /usr/sbin/sendmail.postfix

Enter to keep the current selection[+], or type selection number: 1
```

Test it out.

```bash
echo -e "To: example@contosogroup.com\n\
From: CentOS APPS.MACHINE <centos.apps.machine@contosogroup.com>\n\
Subject: Test\n\
MIME-Version: 1.0\n\
Content-Type: text/plain\n\
\n\
Test!" | sendmail -t
```

If you are planning to mail send from an Office 365 Distribution List, make sure that the account used in the "/etc/postfix/sasl_password" file has the proper "Send As" privilege (http://support.microsoft.com/common/survey.aspx?scid=sw%3Ben%3B3618&showpage=1).