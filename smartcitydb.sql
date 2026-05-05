-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: May 02, 2026 at 11:38 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smartcitydb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CountSensors` (IN `zoneId` INT)   BEGIN
    SELECT COUNT(*) FROM TrafficSensor WHERE zoneID = zoneId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetZoneReport` (IN `zoneId` INT)   BEGIN
    SELECT COUNT(*) FROM TrafficSensor WHERE zoneID = zoneId;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `alertlog`
--

CREATE TABLE `alertlog` (
  `alertID` int(11) NOT NULL,
  `alertType` varchar(50) DEFAULT NULL,
  `binID` int(11) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `alertTime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alertlog`
--

INSERT INTO `alertlog` (`alertID`, `alertType`, `binID`, `message`, `alertTime`) VALUES
(1, 'WASTE_FULL', 201, 'Bin is full', '2026-05-02 12:18:49');

-- --------------------------------------------------------

--
-- Table structure for table `cityzone`
--

CREATE TABLE `cityzone` (
  `zoneID` int(11) NOT NULL,
  `zoneName` varchar(100) NOT NULL,
  `district` varchar(100) DEFAULT NULL,
  `population` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cityzone`
--

INSERT INTO `cityzone` (`zoneID`, `zoneName`, `district`, `population`) VALUES
(1, 'Central', 'CBD', 50000),
(2, 'North', 'Residential', 75000),
(3, 'South', 'Industrial', 30000);

-- --------------------------------------------------------

--
-- Stand-in structure for view `highwaste`
-- (See below for the actual view)
--
CREATE TABLE `highwaste` (
`binID` int(11)
,`zoneID` int(11)
,`fillLevel` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `trafficsensor`
--

CREATE TABLE `trafficsensor` (
  `sensorID` int(11) NOT NULL,
  `zoneID` int(11) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Active',
  `lastReadingTime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trafficsensor`
--

INSERT INTO `trafficsensor` (`sensorID`, `zoneID`, `location`, `status`, `lastReadingTime`) VALUES
(101, 1, 'Main Street', 'Active', '2026-05-02 11:53:45'),
(102, 2, 'North Avenue', 'Active', '2026-05-02 11:54:01'),
(103, 1, 'Market Road', 'Inactive', '2026-05-02 11:54:21');

-- --------------------------------------------------------

--
-- Stand-in structure for view `urgentwaste`
-- (See below for the actual view)
--
CREATE TABLE `urgentwaste` (
`binID` int(11)
,`zoneID` int(11)
,`fillLevel` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `wastebin`
--

CREATE TABLE `wastebin` (
  `binID` int(11) NOT NULL,
  `zoneID` int(11) NOT NULL,
  `fillLevel` int(11) DEFAULT NULL CHECK (`fillLevel` between 0 and 100),
  `lastEmptied` datetime DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Empty'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wastebin`
--

INSERT INTO `wastebin` (`binID`, `zoneID`, `fillLevel`, `lastEmptied`, `status`) VALUES
(201, 1, 95, '2026-04-27 08:00:00', 'Partial'),
(202, 2, 85, '2026-04-26 15:00:00', 'Full'),
(203, 3, 10, '2026-04-28 09:00:00', 'Empty');

--
-- Triggers `wastebin`
--
DELIMITER $$
CREATE TRIGGER `waste_full_alert` AFTER UPDATE ON `wastebin` FOR EACH ROW BEGIN
    IF NEW.fillLevel > 90 THEN
        INSERT INTO AlertLog(alertType, binID, message, alertTime)
        VALUES ('WASTE_FULL', NEW.binID, 'Bin is full', NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure for view `highwaste`
--
DROP TABLE IF EXISTS `highwaste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `highwaste`  AS SELECT `wastebin`.`binID` AS `binID`, `wastebin`.`zoneID` AS `zoneID`, `wastebin`.`fillLevel` AS `fillLevel` FROM `wastebin` WHERE `wastebin`.`fillLevel` > 70 ;

-- --------------------------------------------------------

--
-- Structure for view `urgentwaste`
--
DROP TABLE IF EXISTS `urgentwaste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `urgentwaste`  AS SELECT `wastebin`.`binID` AS `binID`, `wastebin`.`zoneID` AS `zoneID`, `wastebin`.`fillLevel` AS `fillLevel` FROM `wastebin` WHERE `wastebin`.`fillLevel` > 80 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alertlog`
--
ALTER TABLE `alertlog`
  ADD PRIMARY KEY (`alertID`);

--
-- Indexes for table `cityzone`
--
ALTER TABLE `cityzone`
  ADD PRIMARY KEY (`zoneID`);

--
-- Indexes for table `trafficsensor`
--
ALTER TABLE `trafficsensor`
  ADD PRIMARY KEY (`sensorID`),
  ADD KEY `idx_traffic_zone` (`zoneID`);

--
-- Indexes for table `wastebin`
--
ALTER TABLE `wastebin`
  ADD PRIMARY KEY (`binID`),
  ADD KEY `idx_wastebin_zone` (`zoneID`),
  ADD KEY `idx_wastebin_fill` (`fillLevel`),
  ADD KEY `idx_zone` (`zoneID`),
  ADD KEY `idx_fill` (`fillLevel`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alertlog`
--
ALTER TABLE `alertlog`
  MODIFY `alertID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `trafficsensor`
--
ALTER TABLE `trafficsensor`
  ADD CONSTRAINT `trafficsensor_ibfk_1` FOREIGN KEY (`zoneID`) REFERENCES `cityzone` (`zoneID`);

--
-- Constraints for table `wastebin`
--
ALTER TABLE `wastebin`
  ADD CONSTRAINT `wastebin_ibfk_1` FOREIGN KEY (`zoneID`) REFERENCES `cityzone` (`zoneID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
