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
-- Table structure for table `final_invoice_app_clients`
--

DROP TABLE IF EXISTS `final_invoice_app_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `final_invoice_app_clients` (
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
-- Dumping data for table `final_invoice_app_clients`
--

LOCK TABLES `final_invoice_app_clients` WRITE;
/*!40000 ALTER TABLE `final_invoice_app_clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `final_invoice_app_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `final_invoice_app_invoice_line_items`
--

DROP TABLE IF EXISTS `final_invoice_app_invoice_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `final_invoice_app_invoice_line_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `kind` varchar(100) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `quantity` decimal(20,2) NOT NULL DEFAULT '0.00',
  `unit_price` decimal(20,2) NOT NULL DEFAULT '0.00',
  `amount` decimal(20,2) NOT NULL DEFAULT '0.00',
  `taxed` varchar(5) DEFAULT NULL,
  `taxed2` varchar(5) DEFAULT NULL,
  `project_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `final_invoice_app_invoice_line_items`
--

LOCK TABLES `final_invoice_app_invoice_line_items` WRITE;
/*!40000 ALTER TABLE `final_invoice_app_invoice_line_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `final_invoice_app_invoice_line_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `final_invoice_app_invoices`
--

DROP TABLE IF EXISTS `final_invoice_app_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `final_invoice_app_invoices` (
  `id` bigint(20) NOT NULL,
  `number` varchar(25) NOT NULL,
  `state` varchar(10) DEFAULT NULL,
  `client-id` bigint(20) DEFAULT NULL,
  `subject` varchar(300) DEFAULT NULL,
  `purchase-order` varchar(25) DEFAULT NULL,
  `csv-line-items` blob,
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
  KEY `final_invoice_app_invoices_client-id_idx` (`client-id`),
  CONSTRAINT `final_invoice_app_invoices_client-id` FOREIGN KEY (`client-id`) REFERENCES `final_invoice_app_clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `final_invoice_app_invoices`
--

LOCK TABLES `final_invoice_app_invoices` WRITE;
/*!40000 ALTER TABLE `final_invoice_app_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `final_invoice_app_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `final_invoice_app_settings`
--

DROP TABLE IF EXISTS `final_invoice_app_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `final_invoice_app_settings` (
  `parameter` varchar(50) NOT NULL,
  `value` varchar(50) DEFAULT NULL,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`parameter`),
  UNIQUE KEY `parameter_UNIQUE` (`parameter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `final_invoice_app_settings`
--

LOCK TABLES `final_invoice_app_settings` WRITE;
/*!40000 ALTER TABLE `final_invoice_app_settings` DISABLE KEYS */;
INSERT INTO `final_invoice_app_settings` VALUES ('harvest_password','password','2014-01-01 00:00:00'),('harvest_subdomain','contosogroup','2014-01-01 00:00:00'),('harvest_username','example@contosogroup.com','2014-01-01 00:00:00'),('last_run_utc',NULL,'2014-01-01 00:00:00');
/*!40000 ALTER TABLE `final_invoice_app_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `final_invoice_app_template_settings`
--

DROP TABLE IF EXISTS `final_invoice_app_template_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `final_invoice_app_template_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address` blob NOT NULL,
  `address_on_left` varchar(5) NOT NULL,
  `amount` varchar(25) NOT NULL,
  `amount_due` varchar(25) NOT NULL,
  `currency_placement` varchar(6) NOT NULL,
  `date_format` varchar(25) NOT NULL,
  `description` varchar(25) NOT NULL,
  `discount` varchar(25) NOT NULL,
  `due_date` varchar(25) NOT NULL,
  `for` varchar(25) NOT NULL,
  `from` varchar(25) NOT NULL,
  `hide_amount_column` varchar(5) NOT NULL,
  `hide_description_column` varchar(5) NOT NULL,
  `hide_quantity_column` varchar(5) NOT NULL,
  `hide_type_column` varchar(5) NOT NULL,
  `hide_unit_price_column` varchar(5) NOT NULL,
  `include_currency_code` varchar(5) NOT NULL,
  `invoice` varchar(25) NOT NULL,
  `invoices` varchar(25) NOT NULL,
  `invoice_document_title` varchar(25) NOT NULL,
  `invoice_id` varchar(25) NOT NULL,
  `invoice_notes` blob NOT NULL,
  `issue_date` varchar(25) NOT NULL,
  `name` varchar(250) NOT NULL,
  `notes` varchar(25) NOT NULL,
  `payments` varchar(25) NOT NULL,
  `pdf_page_numbering` varchar(25) NOT NULL,
  `po_number` varchar(25) NOT NULL,
  `quantity` varchar(25) NOT NULL,
  `show_document_title` varchar(5) NOT NULL,
  `show_logo` varchar(5) NOT NULL,
  `subject` varchar(25) NOT NULL,
  `subtotal` varchar(25) NOT NULL,
  `tax` varchar(25) NOT NULL,
  `tax2` varchar(25) NOT NULL,
  `total_payments` varchar(25) NOT NULL,
  `type` varchar(25) NOT NULL,
  `unit_price` varchar(25) NOT NULL,
  `upon_receipt` varchar(25) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `final_invoice_app_template_settings`
--

LOCK TABLES `final_invoice_app_template_settings` WRITE;
/*!40000 ALTER TABLE `final_invoice_app_template_settings` DISABLE KEYS */;
INSERT INTO `final_invoice_app_template_settings` VALUES (1,'Street Name\nLocality Postcode\nCountry','true','Amount','Amount Due','before','%d/%m/%Y','Description','Discount','Due Date','For','From','false','false','true','false','true','true','Invoice','Invoices','INVOICE','Invoice ID','<b>Line 1</b>\n<i>Line 2</i>\nLine 3','Issue Date','Contoso Group','Notes','Payments','Page [page] of [toPage]','PO Number','Quantity','true','true','Subject','Subtotal','VAT','Tax2','Total Payments','Type','Unit Price','Upon Receipt');
/*!40000 ALTER TABLE `final_invoice_app_template_settings` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-08 19:48:09
