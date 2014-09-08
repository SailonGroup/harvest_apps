# MySQL

The ".sh" script requires "mysql" to be installed on your machine and in the PATH of your account. MySQL server is required and the server can be hosted elsewhere. If you are installing the MySQL DB on CentOS please follow this guide http://dev.mysql.com/doc/mysql-repo-excerpt/5.6/en/linux-installation-yum-repo.html. Also ensure that MySQL starts automatically on startup.

```bash
chkconfig mysqld on
```

If you run the "mysql_secure_installation" as per guide (which I recommend you do), it will set "sql_mode" to be in strict mode. This will produce an error for columns that are marked as "NOT NULL" but have a default value. You need to disable it.

```bash
vi /etc/my.cnf
```

Comment out the following line.

```bash
#sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
```

Enter this line below and save.

```bash
sql_mode=NO_ENGINE_SUBSTITUTION
```

Restart the MySQL server.

```bash
sudo service mysqld restart
```

A MySQL DB (schema) is also required which can be hosted on the MySQL server mentioned above (host of DB). Ensure that you have all privileges (except "GRANT") in the DB tables for the username and machine (host of app) that you are executing the ".sh" script from. In this example the database is called "harvest" and the username is "harvest_apps".

```mysql
CREATE SCHEMA `harvest` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'harvest_apps'@'[host of app]' IDENTIFIED BY '[password]';
GRANT ALL PRIVILEGES ON `harvest`.* TO 'harvest_apps'@'[host of app]';
```

The ".sh" script uses the "--login-path" feature of "mysql" to access the MySQL DB. You can configure the login path using the "mysql\_config\_editor" for your account.

```bash
mysql_config_editor set --login-path="harvest_apps" --host="[host of DB]" --user="harvest_apps" --password
Enter password: [password]
```