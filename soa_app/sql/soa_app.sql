-- MySQL dump 10.13  Distrib 5.6.20, for Linux (x86_64)
--
-- Host: lion.centos6.contosogroup.com    Database: harvest
-- ------------------------------------------------------
-- Server version	5.6.20

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `soa_app_clients`
--

DROP TABLE IF EXISTS `soa_app_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `soa_app_clients` (
  `id` bigint(20) NOT NULL,
  `name` varchar(250) NOT NULL,
  `details` blob,
  `active` varchar(10) DEFAULT NULL,
  `currency` varchar(100) DEFAULT NULL,
  `currency-symbol` varchar(5) DEFAULT NULL,
  `default-invoice-timeframe` varchar(50) DEFAULT NULL,
  `last-invoice-kind` varchar(50) DEFAULT NULL,
  `highrise-id` bigint(20) DEFAULT NULL,
  `cache-version` bigint(20) DEFAULT NULL,
  `created-at` datetime DEFAULT NULL,
  `updated-at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`name`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soa_app_clients`
--

LOCK TABLES `soa_app_clients` WRITE;
/*!40000 ALTER TABLE `soa_app_clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `soa_app_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `soa_app_invoice_payments`
--

DROP TABLE IF EXISTS `soa_app_invoice_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `soa_app_invoice_payments` (
  `id` bigint(20) NOT NULL,
  `notes` varchar(250) DEFAULT NULL,
  `amount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `recorded-by` varchar(250) DEFAULT NULL,
  `recorded-by-email` varchar(250) DEFAULT NULL,
  `invoice-id` bigint(20) DEFAULT NULL,
  `paid-at` datetime DEFAULT NULL,
  `created-at` datetime DEFAULT NULL,
  `updated-at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `soa_app_invoice_payments_invoice-id_idx` (`invoice-id`),
  CONSTRAINT `soa_app_invoice_payments_invoice-id` FOREIGN KEY (`invoice-id`) REFERENCES `soa_app_invoices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soa_app_invoice_payments`
--

LOCK TABLES `soa_app_invoice_payments` WRITE;
/*!40000 ALTER TABLE `soa_app_invoice_payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `soa_app_invoice_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `soa_app_invoices`
--

DROP TABLE IF EXISTS `soa_app_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `soa_app_invoices` (
  `id` bigint(20) NOT NULL,
  `number` varchar(25) NOT NULL,
  `state` varchar(10) DEFAULT NULL,
  `client-id` bigint(20) DEFAULT NULL,
  `subject` varchar(300) DEFAULT NULL,
  `purchase-order` varchar(25) DEFAULT NULL,
  `notes` blob,
  `amount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `due-amount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(100) NOT NULL DEFAULT 'Euro - EUR',
  `tax` decimal(20,2) NOT NULL DEFAULT '0.00',
  `tax2` decimal(20,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `tax-amount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `tax2-amount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `discount-amount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `issued-at` date DEFAULT NULL,
  `due-at` date DEFAULT NULL,
  `due-at-human-format` varchar(50) DEFAULT NULL,
  `period-start` date DEFAULT NULL,
  `period-end` date DEFAULT NULL,
  `created-by-id` bigint(20) DEFAULT NULL,
  `estimate-id` bigint(20) DEFAULT NULL,
  `retainer-id` bigint(20) DEFAULT NULL,
  `recurring-invoice-id` bigint(20) DEFAULT NULL,
  `client-key` varchar(50) DEFAULT NULL,
  `created-at` datetime DEFAULT NULL,
  `updated-at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`number`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `number_UNIQUE` (`number`),
  KEY `soa_app_invoices_client-id_idx` (`client-id`),
  CONSTRAINT `soa_app_invoices_client-id` FOREIGN KEY (`client-id`) REFERENCES `soa_app_clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soa_app_invoices`
--

LOCK TABLES `soa_app_invoices` WRITE;
/*!40000 ALTER TABLE `soa_app_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `soa_app_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `soa_app_settings`
--

DROP TABLE IF EXISTS `soa_app_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `soa_app_settings` (
  `parameter` varchar(50) NOT NULL,
  `value` varchar(50) DEFAULT NULL,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`parameter`),
  UNIQUE KEY `parameter_UNIQUE` (`parameter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soa_app_settings`
--

LOCK TABLES `soa_app_settings` WRITE;
/*!40000 ALTER TABLE `soa_app_settings` DISABLE KEYS */;
INSERT INTO `soa_app_settings` VALUES ('harvest_password','password','2014-01-01 00:00:00'),('harvest_subdomain','contosogroup','2014-01-01 00:00:00'),('harvest_username','example@contosogroup.com','2014-01-01 00:00:00'),('last_run_utc',NULL,'2014-01-01 00:00:00');
/*!40000 ALTER TABLE `soa_app_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `soa_app_template_settings`
--

DROP TABLE IF EXISTS `soa_app_template_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `soa_app_template_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address` blob NOT NULL,
  `address_on_left` varchar(5) NOT NULL,
  `amount` varchar(25) NOT NULL,
  `currency_placement` varchar(6) NOT NULL,
  `date_format` varchar(25) NOT NULL,
  `description` varchar(25) NOT NULL,
  `for` varchar(25) NOT NULL,
  `from` varchar(25) NOT NULL,
  `hide_amount_column` varchar(5) NOT NULL,
  `hide_description_column` varchar(5) NOT NULL,
  `hide_issue_date_column` varchar(5) NOT NULL,
  `hide_payments_column` varchar(5) NOT NULL,
  `hide_status_column` varchar(5) NOT NULL,
  `include_currency_code` varchar(5) NOT NULL,
  `invoice` varchar(25) NOT NULL,
  `issue_date` varchar(25) NOT NULL,
  `name` varchar(250) NOT NULL,
  `notes` varchar(25) NOT NULL,
  `payment_for` varchar(25) NOT NULL,
  `payments` varchar(25) NOT NULL,
  `pdf_page_numbering` varchar(25) NOT NULL,
  `received` varchar(25) NOT NULL,
  `retainer` varchar(25) NOT NULL,
  `show_document_title` varchar(5) NOT NULL,
  `show_logo` varchar(5) NOT NULL,
  `soa` varchar(25) NOT NULL,
  `soas` varchar(25) NOT NULL,
  `soa_document_title` varchar(25) NOT NULL,
  `soa_notes` blob NOT NULL,
  `statement_date` varchar(25) NOT NULL,
  `status` varchar(25) NOT NULL,
  `total_amount` varchar(25) NOT NULL,
  `total_amount_due` varchar(25) NOT NULL,
  `total_payments` varchar(25) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soa_app_template_settings`
--

LOCK TABLES `soa_app_template_settings` WRITE;
/*!40000 ALTER TABLE `soa_app_template_settings` DISABLE KEYS */;
INSERT INTO `soa_app_template_settings` VALUES (1,'Street Name\nLocality Postcode\nCountry','true','Amount','before','%d/%m/%Y','Description','For','From','false','false','false','false','false','true','Request for Payment','Issue Date','Contoso Group','Notes','Payment for','Payments','Page [page] of [toPage]','Received','Retainer','true','true','Statement of Account','Statement of Accounts','STATEMENT OF ACCOUNT','<b>Line 1</b>\n<i>Line 2</i>\nLine 3','Statement Date','Status','Total Amount','Total Amount Due','Total Payments');
/*!40000 ALTER TABLE `soa_app_template_settings` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-08 19:47:49
