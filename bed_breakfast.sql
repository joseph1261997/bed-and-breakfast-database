-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Apr 29, 2024 alle 17:20
-- Versione del server: 10.4.21-MariaDB
-- Versione PHP: 8.0.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bed&breakfast`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `camera`
--

CREATE TABLE `camera` (
  `numero_camera` int(11) NOT NULL,
  `tipo` varchar(10) NOT NULL,
  `prezzo` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `camera`
--

INSERT INTO `camera` (`numero_camera`, `tipo`, `prezzo`) VALUES
(1, 'singola', '80.00'),
(2, 'doppia', '160.00'),
(3, 'singola', '50.00'),
(4, 'doppia', '100.00');

-- --------------------------------------------------------

--
-- Struttura della tabella `comprende`
--

CREATE TABLE `comprende` (
  `service_id` int(11) NOT NULL,
  `prenotazione_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `ospite`
--

CREATE TABLE `ospite` (
  `ospite_id` int(11) NOT NULL,
  `nome` varchar(25) NOT NULL,
  `cognome` varchar(25) NOT NULL,
  `numero_documento` varchar(20) NOT NULL,
  `telefono` varchar(10) NOT NULL,
  `email` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `pagamento`
--

CREATE TABLE `pagamento` (
  `pagamento_id` int(11) NOT NULL,
  `prenotazione_id` int(11) NOT NULL,
  `data_pagamento` date DEFAULT NULL,
  `importo` decimal(10,2) NOT NULL,
  `stato` varchar(20) NOT NULL DEFAULT 'non pagato'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `prenotazione`
--

CREATE TABLE `prenotazione` (
  `prenotazione_id` int(11) NOT NULL,
  `ospite_id` int(11) NOT NULL,
  `data_arrivo` date NOT NULL,
  `data_partenza` date NOT NULL,
  `numero_ospiti` int(11) NOT NULL,
  `numero_camera` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `prenotazione`
--
DELIMITER $$
CREATE TRIGGER `controllo_disponibilità_camera` BEFORE INSERT ON `prenotazione` FOR EACH ROW BEGIN
    DECLARE occupata INT;

    SELECT COUNT(*) INTO occupata
    FROM Prenotazione
    WHERE numero_camera = NEW.numero_camera
        AND ((NEW.data_arrivo >= data_arrivo AND NEW.data_arrivo < data_partenza)
            OR (NEW.data_partenza > data_arrivo AND NEW.data_partenza <= data_partenza)
            OR (NEW.data_arrivo <= data_arrivo AND NEW.data_partenza >= data_partenza));

    IF occupata > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La camera selezionata è già occupata nel periodo specificato.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verifica_data_partenza` BEFORE INSERT ON `prenotazione` FOR EACH ROW BEGIN
IF NEW.data_partenza < NEW.data_arrivo + INTERVAL 1 DAY THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'La data di partenza deve essere almeno un giorno dopo la data di arrivo.';
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verifica_numero_ospiti` BEFORE INSERT ON `prenotazione` FOR EACH ROW BEGIN
  DECLARE tipo_camera VARCHAR(10);

  SELECT tipo INTO tipo_camera
  FROM Camera
  WHERE numero_camera = NEW.numero_camera;

  IF (tipo_camera = "singola" AND NEW.numero_ospiti <> 1) OR (tipo_camera = "doppia" AND NEW.numero_ospiti > 2) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Numero di ospiti non valido";
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `servizi`
--

CREATE TABLE `servizi` (
  `service_id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `prezzo` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `servizi`
--

INSERT INTO `servizi` (`service_id`, `nome`, `prezzo`) VALUES
(1, 'colazione', '10.00'),
(2, 'wifi', '10.00'),
(3, 'sky', '5.00'),
(4, 'parcheggio', '15.00');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `camera`
--
ALTER TABLE `camera`
  ADD PRIMARY KEY (`numero_camera`);

--
-- Indici per le tabelle `comprende`
--
ALTER TABLE `comprende`
  ADD PRIMARY KEY (`service_id`,`prenotazione_id`),
  ADD KEY `prenotazione_id` (`prenotazione_id`);

--
-- Indici per le tabelle `ospite`
--
ALTER TABLE `ospite`
  ADD PRIMARY KEY (`ospite_id`);

--
-- Indici per le tabelle `pagamento`
--
ALTER TABLE `pagamento`
  ADD PRIMARY KEY (`pagamento_id`),
  ADD KEY `pagamento_ibfk_1` (`prenotazione_id`);

--
-- Indici per le tabelle `prenotazione`
--
ALTER TABLE `prenotazione`
  ADD PRIMARY KEY (`prenotazione_id`),
  ADD KEY `ospite_id` (`ospite_id`),
  ADD KEY `numero_camera` (`numero_camera`);

--
-- Indici per le tabelle `servizi`
--
ALTER TABLE `servizi`
  ADD PRIMARY KEY (`service_id`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `ospite`
--
ALTER TABLE `ospite`
  MODIFY `ospite_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT per la tabella `pagamento`
--
ALTER TABLE `pagamento`
  MODIFY `pagamento_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT per la tabella `servizi`
--
ALTER TABLE `servizi`
  MODIFY `service_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `comprende`
--
ALTER TABLE `comprende`
  ADD CONSTRAINT `comprende_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `servizi` (`service_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `comprende_ibfk_2` FOREIGN KEY (`prenotazione_id`) REFERENCES `prenotazione` (`prenotazione_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `pagamento`
--
ALTER TABLE `pagamento`
  ADD CONSTRAINT `pagamento_ibfk_1` FOREIGN KEY (`prenotazione_id`) REFERENCES `prenotazione` (`prenotazione_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `prenotazione`
--
ALTER TABLE `prenotazione`
  ADD CONSTRAINT `prenotazione_ibfk_1` FOREIGN KEY (`ospite_id`) REFERENCES `ospite` (`ospite_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `prenotazione_ibfk_2` FOREIGN KEY (`numero_camera`) REFERENCES `camera` (`numero_camera`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
