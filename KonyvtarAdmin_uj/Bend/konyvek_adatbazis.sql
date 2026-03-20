-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2026. Már 20. 08:38
-- Kiszolgáló verziója: 10.4.32-MariaDB
-- PHP verzió: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `konyvek_adatbazis`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `buntetesek`
--

CREATE TABLE `buntetesek` (
  `id` int(11) NOT NULL,
  `kolcsonzes_id` int(11) NOT NULL,
  `osszeg` decimal(8,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `cimkek`
--

CREATE TABLE `cimkek` (
  `id` int(11) NOT NULL,
  `nev` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ertekelesek`
--

CREATE TABLE `ertekelesek` (
  `id` int(11) NOT NULL,
  `konyv_id` int(11) NOT NULL,
  `felhasznalo_id` int(11) NOT NULL,
  `ertekeles` tinyint(4) DEFAULT NULL CHECK (`ertekeles` between 1 and 5),
  `komment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `felhasznalok`
--

CREATE TABLE `felhasznalok` (
  `id` int(11) NOT NULL,
  `nev` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `jelszo_hash` varchar(255) NOT NULL,
  `regisztracio_datuma` datetime DEFAULT current_timestamp(),
  `role` enum('user','admin','superadmin') DEFAULT 'user',
  `torolt` tinyint(1) DEFAULT 0,
  `score` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `felhasznalok`
--

INSERT INTO `felhasznalok` (`id`, `nev`, `email`, `jelszo_hash`, `regisztracio_datuma`, `role`, `torolt`, `score`) VALUES
(2, 'Teszt Felhasználó', 'teszt@teszt.hu', '123', '2026-03-16 13:28:34', 'user', 1, 0),
(5, 'admin', 'admin@gmail.com', '$2b$12$GIcjq0zfQaMB/8X.rXoKSOZzlvYquiLoT2JemmarWw6L1py1fsjZe', '2026-03-18 10:08:43', 'admin', 0, 0),
(6, 'Vég Béla', 'veg.bela@gmail.com', '$2b$12$0I9vUV1weeOyk95rUX0zVOp50cU0aK/QMUb/F7MfBwjdAaS1kQgEi', '2026-03-18 10:09:11', 'user', 0, 0),
(7, 'pamkutya', 'pama@gmail.com', '$2b$12$vVrhrg/SZMIpYanqbFzEKOtgwC087lvQKaMVhtHS/FPuAnd6Dcz/S', '2026-03-18 13:08:29', 'user', 0, 0),
(8, 'asd', 'asd@gmail.com', '$2b$12$62wKVnjrmxMVQ1ijxxJAiODK8.PtCKYvh5hiKu.indz/3f.8BfeTy', '2026-03-18 13:08:43', 'user', 0, 0),
(9, 'Naplemente', 'friedlevente78@gmail.com', '$2b$12$pT71GI/cqC2Y/ffYe31v8eU1GcELNxgMaVb7ewYl6rYWPOekCEQKu', '2026-03-18 14:56:17', 'user', 0, 0),
(11, 'atypaty', 'tirolpatrik2007@gmail.com', '$2b$12$shmKynHMstfeS52ILQ3ElOS1UURuf9VtsVuIJqRFHCKT4DLduOfUq', '2026-03-18 15:10:48', 'user', 0, 14);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kolcsonzesek`
--

CREATE TABLE `kolcsonzesek` (
  `id` int(11) NOT NULL,
  `peldany_id` int(11) NOT NULL,
  `felhasznalo_id` int(11) NOT NULL,
  `kolcsonzes_datum` date NOT NULL,
  `visszahozas_datum` date DEFAULT NULL,
  `visszahozva` datetime DEFAULT NULL,
  `hosszabbitva` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `kolcsonzesek`
--

INSERT INTO `kolcsonzesek` (`id`, `peldany_id`, `felhasznalo_id`, `kolcsonzes_datum`, `visszahozas_datum`, `visszahozva`, `hosszabbitva`) VALUES
(3, 3, 2, '2026-03-18', '2026-03-18', '2026-03-18 09:55:53', 0),
(4, 4, 2, '2026-03-18', '2026-03-22', '2026-03-18 09:55:59', 0),
(5, 4, 6, '2026-03-18', '2026-03-28', '2026-03-18 10:31:52', 0),
(6, 4, 6, '2026-03-18', '2026-03-31', '2026-03-18 11:55:43', 0),
(7, 3, 6, '2026-03-18', '2026-03-19', '2026-03-18 11:56:33', 0),
(8, 4, 2, '2026-03-18', '2026-03-17', '2026-03-18 11:56:31', 0),
(9, 20, 2, '2026-03-18', '2026-03-20', '2026-03-18 12:37:47', 0),
(10, 21, 2, '2026-03-18', '2026-03-27', '2026-03-18 12:37:46', 0),
(11, 22, 2, '2026-03-18', '2026-03-18', '2026-03-18 12:37:44', 0),
(12, 23, 2, '2026-03-18', '2026-03-11', '2026-03-18 12:37:40', 0),
(13, 30, 6, '2026-03-18', '2026-04-01', '2026-03-19 09:58:54', 1),
(14, 25, 7, '2026-03-18', '2026-03-25', '2026-03-19 09:58:58', 0),
(15, 28, 6, '2026-03-18', '2026-03-31', '2026-03-19 09:58:56', 1),
(16, 47, 9, '2026-03-18', '2026-03-18', '2026-03-19 09:59:00', 0),
(17, 31, 11, '2026-03-18', '2026-03-26', '2026-03-19 09:58:51', 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `konyvek`
--

CREATE TABLE `konyvek` (
  `id` int(11) NOT NULL,
  `cim` varchar(200) NOT NULL,
  `szerzo_id` int(11) NOT NULL,
  `mufaj_id` int(11) DEFAULT NULL,
  `kiadas_eve` int(11) DEFAULT NULL,
  `letrehozas_datuma` datetime DEFAULT current_timestamp(),
  `torolt` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `konyvek`
--

INSERT INTO `konyvek` (`id`, `cim`, `szerzo_id`, `mufaj_id`, `kiadas_eve`, `letrehozas_datuma`, `torolt`) VALUES
(2, 'almafa', 1, NULL, 2026, '2026-03-16 12:35:51', 1),
(4, 'sybau', 3, NULL, 2007, '2026-03-18 09:31:36', 1),
(5, 'sybau', 4, NULL, 2007, '2026-03-18 12:32:11', 0),
(8, 'almafas', 1, NULL, 2026, '2026-03-18 12:40:07', 0),
(9, 'Miazma', 5, NULL, 2019, '2026-03-18 14:57:20', 0),
(10, 'Elképesztő trükkök hétköznapi tárgyakkal', 6, NULL, 2019, '2026-03-19 10:04:23', 0),
(11, 'Én, a kétarcú', 7, NULL, 2026, '2026-03-19 10:05:18', 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `konyv_cimke`
--

CREATE TABLE `konyv_cimke` (
  `konyv_id` int(11) NOT NULL,
  `cimke_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `mufajok`
--

CREATE TABLE `mufajok` (
  `id` int(11) NOT NULL,
  `nev` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `peldanyok`
--

CREATE TABLE `peldanyok` (
  `id` int(11) NOT NULL,
  `konyv_id` int(11) NOT NULL,
  `allapot` enum('uj','jo','hasznalt','serult') DEFAULT 'uj',
  `elerheto` tinyint(1) DEFAULT 1,
  `aktiv` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `peldanyok`
--

INSERT INTO `peldanyok` (`id`, `konyv_id`, `allapot`, `elerheto`, `aktiv`) VALUES
(3, 2, 'jo', 1, 0),
(4, 4, 'uj', 1, 0),
(5, 2, 'uj', 1, 0),
(6, 4, 'uj', 1, 0),
(7, 4, 'uj', 1, 0),
(8, 4, 'uj', 1, 0),
(9, 4, 'uj', 1, 0),
(10, 4, 'uj', 1, 0),
(11, 4, 'uj', 1, 0),
(12, 4, 'uj', 1, 0),
(13, 4, 'uj', 1, 0),
(14, 4, 'uj', 1, 0),
(15, 4, 'uj', 1, 0),
(16, 4, 'uj', 1, 0),
(17, 5, 'uj', 1, 0),
(18, 5, 'uj', 1, 0),
(19, 5, 'uj', 1, 1),
(20, 2, 'uj', 1, 0),
(21, 2, 'uj', 1, 0),
(22, 2, 'uj', 1, 0),
(23, 2, 'uj', 1, 0),
(24, 2, 'uj', 1, 0),
(25, 8, 'uj', 1, 1),
(26, 2, 'uj', 1, 0),
(27, 2, 'uj', 1, 0),
(28, 8, 'uj', 1, 1),
(29, 8, 'uj', 1, 1),
(30, 8, 'uj', 1, 1),
(31, 5, 'uj', 1, 1),
(32, 8, 'uj', 1, 1),
(33, 5, 'uj', 1, 1),
(34, 8, 'uj', 1, 1),
(35, 5, 'uj', 1, 1),
(36, 8, 'uj', 1, 1),
(37, 5, 'uj', 1, 1),
(38, 8, 'uj', 1, 1),
(39, 5, 'uj', 1, 1),
(40, 8, 'uj', 1, 1),
(41, 5, 'uj', 1, 1),
(42, 8, 'uj', 1, 1),
(43, 5, 'uj', 1, 1),
(44, 8, 'uj', 1, 1),
(45, 5, 'uj', 1, 1),
(46, 5, 'uj', 1, 1),
(47, 9, 'uj', 1, 0),
(48, 5, 'uj', 1, 1),
(49, 10, 'uj', 1, 1),
(50, 11, 'uj', 1, 1),
(51, 9, 'uj', 1, 0),
(52, 9, 'uj', 1, 1),
(53, 9, 'uj', 1, 1),
(54, 9, 'uj', 1, 1),
(55, 9, 'uj', 1, 1),
(56, 9, 'uj', 1, 1),
(57, 9, 'uj', 1, 1),
(58, 9, 'uj', 1, 1),
(59, 9, 'uj', 1, 1),
(60, 9, 'uj', 1, 1),
(61, 9, 'uj', 1, 1),
(62, 9, 'uj', 1, 1),
(63, 10, 'uj', 1, 1),
(64, 10, 'uj', 1, 1),
(65, 10, 'uj', 1, 1),
(66, 10, 'uj', 1, 1),
(67, 10, 'uj', 1, 1),
(68, 10, 'uj', 1, 1),
(69, 10, 'uj', 1, 1),
(70, 10, 'uj', 1, 1),
(71, 10, 'uj', 1, 1),
(72, 10, 'uj', 1, 1),
(73, 11, 'uj', 1, 1),
(74, 11, 'uj', 1, 1),
(75, 11, 'uj', 1, 1),
(76, 11, 'uj', 1, 1),
(77, 11, 'uj', 1, 1),
(78, 11, 'uj', 1, 1),
(79, 11, 'uj', 1, 1),
(80, 11, 'uj', 1, 1),
(81, 11, 'uj', 1, 1),
(82, 11, 'uj', 1, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `szerzok`
--

CREATE TABLE `szerzok` (
  `id` int(11) NOT NULL,
  `nev` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `szerzok`
--

INSERT INTO `szerzok` (`id`, `nev`) VALUES
(7, 'Ambrózy Áron György'),
(6, 'Hajnóczy Soma'),
(1, 'Ismeretlen szerző'),
(3, 'patick'),
(4, 'patrick'),
(5, 'Pierrot'),
(2, 'sdds');

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `buntetesek`
--
ALTER TABLE `buntetesek`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kolcsonzes_id` (`kolcsonzes_id`);

--
-- A tábla indexei `cimkek`
--
ALTER TABLE `cimkek`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nev` (`nev`);

--
-- A tábla indexei `ertekelesek`
--
ALTER TABLE `ertekelesek`
  ADD PRIMARY KEY (`id`),
  ADD KEY `konyv_id` (`konyv_id`),
  ADD KEY `felhasznalo_id` (`felhasznalo_id`);

--
-- A tábla indexei `felhasznalok`
--
ALTER TABLE `felhasznalok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- A tábla indexei `kolcsonzesek`
--
ALTER TABLE `kolcsonzesek`
  ADD PRIMARY KEY (`id`),
  ADD KEY `peldany_id` (`peldany_id`),
  ADD KEY `felhasznalo_id` (`felhasznalo_id`);

--
-- A tábla indexei `konyvek`
--
ALTER TABLE `konyvek`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cim` (`cim`,`szerzo_id`),
  ADD KEY `szerzo_id` (`szerzo_id`),
  ADD KEY `mufaj_id` (`mufaj_id`);

--
-- A tábla indexei `konyv_cimke`
--
ALTER TABLE `konyv_cimke`
  ADD PRIMARY KEY (`konyv_id`,`cimke_id`),
  ADD KEY `cimke_id` (`cimke_id`);

--
-- A tábla indexei `mufajok`
--
ALTER TABLE `mufajok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nev` (`nev`);

--
-- A tábla indexei `peldanyok`
--
ALTER TABLE `peldanyok`
  ADD PRIMARY KEY (`id`),
  ADD KEY `konyv_id` (`konyv_id`);

--
-- A tábla indexei `szerzok`
--
ALTER TABLE `szerzok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nev` (`nev`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `buntetesek`
--
ALTER TABLE `buntetesek`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `cimkek`
--
ALTER TABLE `cimkek`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `ertekelesek`
--
ALTER TABLE `ertekelesek`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `felhasznalok`
--
ALTER TABLE `felhasznalok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT a táblához `kolcsonzesek`
--
ALTER TABLE `kolcsonzesek`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT a táblához `konyvek`
--
ALTER TABLE `konyvek`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT a táblához `mufajok`
--
ALTER TABLE `mufajok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `peldanyok`
--
ALTER TABLE `peldanyok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT a táblához `szerzok`
--
ALTER TABLE `szerzok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `buntetesek`
--
ALTER TABLE `buntetesek`
  ADD CONSTRAINT `buntetesek_ibfk_1` FOREIGN KEY (`kolcsonzes_id`) REFERENCES `kolcsonzesek` (`id`);

--
-- Megkötések a táblához `ertekelesek`
--
ALTER TABLE `ertekelesek`
  ADD CONSTRAINT `ertekelesek_ibfk_1` FOREIGN KEY (`konyv_id`) REFERENCES `konyvek` (`id`),
  ADD CONSTRAINT `ertekelesek_ibfk_2` FOREIGN KEY (`felhasznalo_id`) REFERENCES `felhasznalok` (`id`);

--
-- Megkötések a táblához `kolcsonzesek`
--
ALTER TABLE `kolcsonzesek`
  ADD CONSTRAINT `kolcsonzesek_ibfk_1` FOREIGN KEY (`peldany_id`) REFERENCES `peldanyok` (`id`),
  ADD CONSTRAINT `kolcsonzesek_ibfk_2` FOREIGN KEY (`felhasznalo_id`) REFERENCES `felhasznalok` (`id`);

--
-- Megkötések a táblához `konyvek`
--
ALTER TABLE `konyvek`
  ADD CONSTRAINT `konyvek_ibfk_1` FOREIGN KEY (`szerzo_id`) REFERENCES `szerzok` (`id`),
  ADD CONSTRAINT `konyvek_ibfk_2` FOREIGN KEY (`mufaj_id`) REFERENCES `mufajok` (`id`);

--
-- Megkötések a táblához `konyv_cimke`
--
ALTER TABLE `konyv_cimke`
  ADD CONSTRAINT `konyv_cimke_ibfk_1` FOREIGN KEY (`konyv_id`) REFERENCES `konyvek` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `konyv_cimke_ibfk_2` FOREIGN KEY (`cimke_id`) REFERENCES `cimkek` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `peldanyok`
--
ALTER TABLE `peldanyok`
  ADD CONSTRAINT `peldanyok_ibfk_1` FOREIGN KEY (`konyv_id`) REFERENCES `konyvek` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
