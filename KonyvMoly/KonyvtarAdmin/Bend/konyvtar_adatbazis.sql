-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2026. Feb 20. 13:11
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
-- Adatbázis: `konyvtar`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `felhasznalok`
--

CREATE TABLE `felhasznalok` (
  `id` int(11) NOT NULL,
  `nev` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `letrehozas_datuma` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kolcsonzesek`
--

CREATE TABLE `kolcsonzesek` (
  `id` int(11) NOT NULL,
  `felhasznalo_id` int(11) NOT NULL,
  `konyv_id` int(11) NOT NULL,
  `kolcsonzes_datuma` date NOT NULL,
  `visszahozas_datuma` date DEFAULT NULL,
  `statusz` varchar(20) DEFAULT 'aktiv'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `konyvek`
--

CREATE TABLE `konyvek` (
  `id` int(11) NOT NULL,
  `cim` varchar(200) NOT NULL,
  `szerzo` varchar(150) NOT NULL,
  `kiadas_eve` int(11) DEFAULT NULL,
  `elerheto` tinyint(1) DEFAULT 1,
  `letrehozas_datuma` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `konyvek`
--

INSERT INTO `konyvek` (`id`, `cim`, `szerzo`, `kiadas_eve`, `elerheto`, `letrehozas_datuma`) VALUES
(3, 'Don Quijote', 'Miguel de Cervantes', 1605, 1, '2026-02-18 14:29:46'),
(4, 'Pride and Prejudice', 'Jane Austen', 1813, 1, '2026-02-18 14:29:46'),
(5, 'War and Peace', 'Leo Tolstoy', 1869, 1, '2026-02-18 14:29:46'),
(6, 'Moby-Dick', 'Herman Melville', 1851, 1, '2026-02-18 14:29:46'),
(7, 'Great Expectations', 'Charles Dickens', 1861, 1, '2026-02-18 14:29:46'),
(8, 'Crime and Punishment', 'Fyodor Dostoevsky', 1866, 1, '2026-02-18 14:29:46'),
(9, 'The Brothers Karamazov', 'Fyodor Dostoevsky', 1880, 1, '2026-02-18 14:29:46'),
(10, 'The Adventures of Huckleberry Finn', 'Mark Twain', 1884, 1, '2026-02-18 14:29:46'),
(11, 'Dracula', 'Bram Stoker', 1897, 1, '2026-02-18 14:29:46'),
(12, 'The Great Gatsby', 'F. Scott Fitzgerald', 1925, 1, '2026-02-18 14:29:46'),
(13, 'Ulysses', 'James Joyce', 1922, 1, '2026-02-18 14:29:46'),
(14, 'The Hobbit', 'J.R.R. Tolkien', 1937, 1, '2026-02-18 14:29:46'),
(15, '1984', 'George Orwell', 1949, 1, '2026-02-18 14:29:46'),
(16, 'Animal Farm', 'George Orwell', 1945, 1, '2026-02-18 14:29:46'),
(17, 'The Catcher in the Rye', 'J.D. Salinger', 1951, 1, '2026-02-18 14:29:46'),
(18, 'To Kill a Mockingbird', 'Harper Lee', 1960, 1, '2026-02-18 14:29:46'),
(19, 'One Hundred Years of Solitude', 'Gabriel Garcia Marquez', 1967, 1, '2026-02-18 14:29:46'),
(20, 'The Lord of the Rings', 'J.R.R. Tolkien', 1954, 1, '2026-02-18 14:29:46'),
(21, 'Brave New World', 'Aldous Huxley', 1932, 1, '2026-02-18 14:29:46'),
(22, 'The Grapes of Wrath', 'John Steinbeck', 1939, 1, '2026-02-18 14:29:46'),
(23, 'The Alchemist', 'Paulo Coelho', 1988, 1, '2026-02-18 14:29:46'),
(24, 'The Name of the Rose', 'Umberto Eco', 1980, 1, '2026-02-18 14:29:46'),
(25, 'Harry Potter and the Philosopher\'s Stone', 'J.K. Rowling', 1997, 1, '2026-02-18 14:29:46'),
(26, 'The Da Vinci Code', 'Dan Brown', 2003, 1, '2026-02-18 14:29:46'),
(27, 'The Little Prince', 'Antoine de Saint-Exupery', 1943, 1, '2026-02-18 14:29:46'),
(28, 'Les Miserables', 'Victor Hugo', 1862, 1, '2026-02-18 14:29:46'),
(29, 'The Picture of Dorian Gray', 'Oscar Wilde', 1890, 1, '2026-02-18 14:29:46'),
(30, 'Fahrenheit 451', 'Ray Bradbury', 1953, 1, '2026-02-18 14:29:46'),
(31, 'The Chronicles of Narnia', 'C.S. Lewis', 1950, 1, '2026-02-18 14:29:46'),
(32, 'The Kite Runner', 'Khaled Hosseini', 2003, 1, '2026-02-18 14:29:46'),
(33, 'Egri csillagok', 'Gárdonyi Géza', 1899, 1, '2026-02-18 14:35:17'),
(34, 'A Pál utcai fiúk', 'Molnár Ferenc', 1906, 1, '2026-02-18 14:35:17'),
(35, 'Az ember tragédiája', 'Madách Imre', 1861, 1, '2026-02-18 14:35:17'),
(36, 'Abigél', 'Szabó Magda', 1970, 1, '2026-02-18 14:35:17'),
(37, 'Légy jó mindhalálig', 'Móricz Zsigmond', 1920, 1, '2026-02-18 14:35:17'),
(38, 'Tüskevár', 'Fekete István', 1957, 1, '2026-02-18 14:35:17'),
(39, 'Sorstalanság', 'Kertész Imre', 1975, 1, '2026-02-18 14:35:17'),
(40, 'Iskola a határon', 'Ottlik Géza', 1959, 1, '2026-02-18 14:35:17'),
(41, 'A kőszívű ember fiai', 'Jókai Mór', 1869, 1, '2026-02-18 14:35:17'),
(42, 'Esti Kornél', 'Kosztolányi Dezső', 1933, 1, '2026-02-18 14:35:17'),
(49, 'Utazás a koponyám körül', 'Karinthy Frigyes', 1937, 1, '2026-02-19 10:22:10'),
(52, 'A Pendragon legenda', 'Szerb Antal', 1934, 1, '2026-02-19 10:22:10'),
(53, 'Pride and Prejudice', 'Jane Austen', 1813, 1, '2026-02-19 10:22:10'),
(54, '1984', 'George Orwell', 1949, 1, '2026-02-19 10:22:10'),
(55, 'Animal Farm', 'George Orwell', 1945, 1, '2026-02-19 10:22:10'),
(56, 'The Great Gatsby', 'F. Scott Fitzgerald', 1925, 1, '2026-02-19 10:22:10'),
(57, 'To Kill a Mockingbird', 'Harper Lee', 1960, 1, '2026-02-19 10:22:10'),
(58, 'Moby-Dick', 'Herman Melville', 1851, 1, '2026-02-19 10:22:10'),
(59, 'War and Peace', 'Leo Tolstoy', 1869, 1, '2026-02-19 10:22:10'),
(60, 'Crime and Punishment', 'Fyodor Dostoevsky', 1866, 1, '2026-02-19 10:22:10'),
(61, 'The Brothers Karamazov', 'Fyodor Dostoevsky', 1880, 1, '2026-02-19 10:22:10'),
(62, 'The Catcher in the Rye', 'J.D. Salinger', 1951, 1, '2026-02-19 10:22:10'),
(63, 'The Hobbit', 'J.R.R. Tolkien', 1937, 1, '2026-02-19 10:22:10'),
(64, 'The Lord of the Rings', 'J.R.R. Tolkien', 1954, 1, '2026-02-19 10:22:10'),
(65, 'Harry Potter and the Philosopher\'s Stone', 'J.K. Rowling', 1997, 1, '2026-02-19 10:22:10'),
(66, 'The Little Prince', 'Antoine de Saint-Exupéry', 1943, 1, '2026-02-19 10:22:10'),
(67, 'Don Quixote', 'Miguel de Cervantes', 1605, 1, '2026-02-19 10:22:10'),
(68, 'The Divine Comedy', 'Dante Alighieri', 1320, 1, '2026-02-19 10:22:10'),
(69, 'The Alchemist', 'Paulo Coelho', 1988, 1, '2026-02-19 10:22:10'),
(70, 'One Hundred Years of Solitude', 'Gabriel García Márquez', 1967, 1, '2026-02-19 10:22:10'),
(71, 'The Old Man and the Sea', 'Ernest Hemingway', 1952, 1, '2026-02-19 10:22:10'),
(72, 'Brave New World', 'Aldous Huxley', 1932, 1, '2026-02-19 10:22:10'),
(73, 'Fahrenheit 451', 'Ray Bradbury', 1953, 1, '2026-02-19 10:22:10'),
(74, 'The Picture of Dorian Gray', 'Oscar Wilde', 1890, 1, '2026-02-19 10:22:10'),
(75, 'Dracula', 'Bram Stoker', 1897, 1, '2026-02-19 10:22:10'),
(76, 'Frankenstein', 'Mary Shelley', 1818, 1, '2026-02-19 10:22:10'),
(77, 'The Trial', 'Franz Kafka', 1925, 1, '2026-02-19 10:22:10'),
(78, 'The Stranger', 'Albert Camus', 1942, 1, '2026-02-19 10:22:10'),
(79, 'The Name of the Rose', 'Umberto Eco', 1980, 1, '2026-02-19 10:22:10'),
(80, 'The Count of Monte Cristo', 'Alexandre Dumas', 1844, 1, '2026-02-19 10:22:10'),
(81, 'Les Misérables', 'Victor Hugo', 1862, 1, '2026-02-19 10:22:10'),
(82, 'The Chronicles of Narnia', 'C.S. Lewis', 1950, 1, '2026-02-19 10:22:10'),
(83, 'Jane Eyre', 'Charlotte Brontë', 1847, 1, '2026-02-19 10:22:10'),
(84, 'Wuthering Heights', 'Emily Brontë', 1847, 1, '2026-02-19 10:22:10'),
(85, 'The Shining', 'Stephen King', 1977, 1, '2026-02-19 10:22:10'),
(86, 'The Da Vinci Code', 'Dan Brown', 2003, 1, '2026-02-19 10:22:10'),
(87, 'The Hunger Games', 'Suzanne Collins', 2008, 1, '2026-02-19 10:22:10'),
(88, 'The Book Thief', 'Markus Zusak', 2005, 1, '2026-02-19 10:22:10'),
(89, 'Life of Pi', 'Yann Martel', 2001, 1, '2026-02-19 10:22:10'),
(90, 'The Girl with the Dragon Tattoo', 'Stieg Larsson', 2005, 1, '2026-02-19 10:22:10'),
(91, 'The Fault in Our Stars', 'John Green', 2012, 1, '2026-02-19 10:22:10'),
(92, 'A Game of Thrones', 'George R.R. Martin', 1996, 1, '2026-02-19 10:22:10');

--
-- Indexek a kiírt táblákhoz
--

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
  ADD KEY `felhasznalo_id` (`felhasznalo_id`),
  ADD KEY `konyv_id` (`konyv_id`);

--
-- A tábla indexei `konyvek`
--
ALTER TABLE `konyvek`
  ADD PRIMARY KEY (`id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `felhasznalok`
--
ALTER TABLE `felhasznalok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `kolcsonzesek`
--
ALTER TABLE `kolcsonzesek`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `konyvek`
--
ALTER TABLE `konyvek`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `kolcsonzesek`
--
ALTER TABLE `kolcsonzesek`
  ADD CONSTRAINT `kolcsonzesek_ibfk_1` FOREIGN KEY (`felhasznalo_id`) REFERENCES `felhasznalok` (`id`),
  ADD CONSTRAINT `kolcsonzesek_ibfk_2` FOREIGN KEY (`konyv_id`) REFERENCES `konyvek` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
