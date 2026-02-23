-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2026. Feb 23. 12:58
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
-- Adatbázis: `test`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `buntetesek`
--

CREATE TABLE `buntetesek` (
  `id` int(11) NOT NULL,
  `kolcsonzes_id` int(11) NOT NULL,
  `osszeg` decimal(6,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `cimkek`
--

CREATE TABLE `cimkek` (
  `id` int(11) NOT NULL,
  `nev` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ertekelesek`
--

CREATE TABLE `ertekelesek` (
  `id` int(11) NOT NULL,
  `konyv_id` int(11) NOT NULL,
  `felhasznalo_id` int(11) NOT NULL,
  `ertekeles` tinyint(4) NOT NULL CHECK (`ertekeles` between 1 and 5),
  `komment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `felhasznalok`
--

CREATE TABLE `felhasznalok` (
  `id` int(11) NOT NULL,
  `nev` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `regisztracio_datuma` date DEFAULT NULL,
  `role` enum('user','admin') DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kolcsonzesek`
--

CREATE TABLE `kolcsonzesek` (
  `id` int(11) NOT NULL,
  `konyv_id` int(11) NOT NULL,
  `felhasznalo_id` int(11) NOT NULL,
  `kolcsonzes_datum` date NOT NULL,
  `visszahozas_datum` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
  `letrehozas_datuma` datetime DEFAULT current_timestamp(),
  `mufaj` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `konyvek`
--

INSERT INTO `konyvek` (`id`, `cim`, `szerzo`, `kiadas_eve`, `elerheto`, `letrehozas_datuma`, `mufaj`) VALUES
(93, 'The Odyssey', 'Homer', -800, 1, '2026-02-23 12:24:02', 'Epic'),
(94, 'The Iliad', 'Homer', -750, 1, '2026-02-23 12:24:02', 'Epic'),
(95, 'Meditations', 'Marcus Aurelius', 180, 1, '2026-02-23 12:24:02', 'Philosophy'),
(96, 'Hamlet', 'William Shakespeare', 1603, 1, '2026-02-23 12:24:02', 'Drama'),
(97, 'Macbeth', 'William Shakespeare', 1623, 1, '2026-02-23 12:24:02', 'Drama'),
(98, 'Othello', 'William Shakespeare', 1622, 1, '2026-02-23 12:24:02', 'Drama'),
(99, 'King Lear', 'William Shakespeare', 1606, 1, '2026-02-23 12:24:02', 'Drama'),
(100, 'Romeo and Juliet', 'William Shakespeare', 1597, 1, '2026-02-23 12:24:02', 'Drama'),
(101, 'A Tale of Two Cities', 'Charles Dickens', 1859, 1, '2026-02-23 12:24:02', 'Historical Fiction'),
(102, 'David Copperfield', 'Charles Dickens', 1850, 1, '2026-02-23 12:24:02', 'Novel'),
(103, 'Oliver Twist', 'Charles Dickens', 1839, 1, '2026-02-23 12:24:02', 'Novel'),
(104, 'Great Expectations', 'Charles Dickens', 1861, 1, '2026-02-23 12:24:02', 'Novel'),
(105, 'Pride and Prejudice', 'Jane Austen', 1813, 1, '2026-02-23 12:24:02', 'Romance'),
(106, 'Sense and Sensibility', 'Jane Austen', 1811, 1, '2026-02-23 12:24:02', 'Romance'),
(107, 'Emma', 'Jane Austen', 1815, 1, '2026-02-23 12:24:02', 'Romance'),
(108, 'Mansfield Park', 'Jane Austen', 1814, 1, '2026-02-23 12:24:02', 'Romance'),
(109, 'Northanger Abbey', 'Jane Austen', 1817, 1, '2026-02-23 12:24:02', 'Romance'),
(110, 'Persuasion', 'Jane Austen', 1817, 1, '2026-02-23 12:24:02', 'Romance'),
(111, 'Frankenstein', 'Mary Shelley', 1818, 1, '2026-02-23 12:24:02', 'Horror'),
(112, 'Dracula', 'Bram Stoker', 1897, 1, '2026-02-23 12:24:02', 'Horror'),
(113, 'The Picture of Dorian Gray', 'Oscar Wilde', 1890, 1, '2026-02-23 12:24:02', 'Gothic'),
(114, 'The Importance of Being Earnest', 'Oscar Wilde', 1895, 1, '2026-02-23 12:24:02', 'Comedy'),
(115, 'Les Misérables', 'Victor Hugo', 1862, 1, '2026-02-23 12:24:02', 'Historical Fiction'),
(116, 'The Hunchback of Notre-Dame', 'Victor Hugo', 1831, 1, '2026-02-23 12:24:02', 'Historical Fiction'),
(117, 'War and Peace', 'Leo Tolstoy', 1869, 1, '2026-02-23 12:24:02', 'Historical Fiction'),
(118, 'Anna Karenina', 'Leo Tolstoy', 1877, 1, '2026-02-23 12:24:02', 'Romance'),
(119, 'Crime and Punishment', 'Fyodor Dostoevsky', 1866, 1, '2026-02-23 12:24:02', 'Psychological Fiction'),
(120, 'The Brothers Karamazov', 'Fyodor Dostoevsky', 1880, 1, '2026-02-23 12:24:02', 'Philosophical Fiction'),
(121, 'Notes from Underground', 'Fyodor Dostoevsky', 1864, 1, '2026-02-23 12:24:02', 'Psychological Fiction'),
(122, 'The Idiot', 'Fyodor Dostoevsky', 1869, 1, '2026-02-23 12:24:02', 'Psychological Fiction'),
(123, 'The Master and Margarita', 'Mikhail Bulgakov', 1967, 1, '2026-02-23 12:24:02', 'Fantasy'),
(124, 'One Hundred Years of Solitude', 'Gabriel García Márquez', 1967, 1, '2026-02-23 12:24:02', 'Magic Realism'),
(125, 'Love in the Time of Cholera', 'Gabriel García Márquez', 1985, 1, '2026-02-23 12:24:02', 'Romance'),
(126, 'The Old Man and the Sea', 'Ernest Hemingway', 1952, 1, '2026-02-23 12:24:02', 'Fiction'),
(127, 'For Whom the Bell Tolls', 'Ernest Hemingway', 1940, 1, '2026-02-23 12:24:02', 'War Fiction'),
(128, 'The Sun Also Rises', 'Ernest Hemingway', 1926, 1, '2026-02-23 12:24:02', 'Fiction'),
(129, 'A Farewell to Arms', 'Ernest Hemingway', 1929, 1, '2026-02-23 12:24:02', 'War Fiction'),
(130, 'The Great Gatsby', 'F. Scott Fitzgerald', 1925, 1, '2026-02-23 12:24:02', 'Novel'),
(131, 'Tender Is the Night', 'F. Scott Fitzgerald', 1934, 1, '2026-02-23 12:24:02', 'Novel'),
(132, '1984', 'George Orwell', 1949, 1, '2026-02-23 12:24:02', 'Dystopian'),
(133, 'Animal Farm', 'George Orwell', 1945, 1, '2026-02-23 12:24:02', 'Political Fiction'),
(134, 'Brave New World', 'Aldous Huxley', 1932, 1, '2026-02-23 12:24:02', 'Dystopian'),
(135, 'Island', 'Aldous Huxley', 1962, 1, '2026-02-23 12:24:02', 'Science Fiction'),
(136, 'The Hobbit', 'J.R.R. Tolkien', 1937, 1, '2026-02-23 12:24:02', 'Fantasy'),
(137, 'The Lord of the Rings', 'J.R.R. Tolkien', 1954, 1, '2026-02-23 12:24:02', 'Fantasy'),
(138, 'The Silmarillion', 'J.R.R. Tolkien', 1977, 1, '2026-02-23 12:24:02', 'Fantasy'),
(139, 'Harry Potter and the Philosopher\'s Stone', 'J.K. Rowling', 1997, 1, '2026-02-23 12:24:02', 'Fantasy'),
(140, 'Harry Potter and the Chamber of Secrets', 'J.K. Rowling', 1998, 1, '2026-02-23 12:24:02', 'Fantasy'),
(141, 'Harry Potter and the Prisoner of Azkaban', 'J.K. Rowling', 1999, 1, '2026-02-23 12:24:02', 'Fantasy'),
(142, 'Harry Potter and the Goblet of Fire', 'J.K. Rowling', 2000, 1, '2026-02-23 12:24:02', 'Fantasy'),
(143, 'Harry Potter and the Order of the Phoenix', 'J.K. Rowling', 2003, 1, '2026-02-23 12:24:02', 'Fantasy'),
(144, 'Harry Potter and the Half-Blood Prince', 'J.K. Rowling', 2005, 1, '2026-02-23 12:24:02', 'Fantasy'),
(145, 'Harry Potter and the Deathly Hallows', 'J.K. Rowling', 2007, 1, '2026-02-23 12:24:02', 'Fantasy'),
(146, 'The Da Vinci Code', 'Dan Brown', 2003, 1, '2026-02-23 12:24:02', 'Thriller'),
(147, 'Angels & Demons', 'Dan Brown', 2000, 1, '2026-02-23 12:24:02', 'Thriller'),
(148, 'Inferno', 'Dan Brown', 2013, 1, '2026-02-23 12:24:02', 'Thriller'),
(149, 'Origin', 'Dan Brown', 2017, 1, '2026-02-23 12:24:02', 'Thriller'),
(150, 'The Hunger Games', 'Suzanne Collins', 2008, 1, '2026-02-23 12:24:02', 'Dystopian'),
(151, 'Catching Fire', 'Suzanne Collins', 2009, 1, '2026-02-23 12:24:02', 'Dystopian'),
(152, 'Mockingjay', 'Suzanne Collins', 2010, 1, '2026-02-23 12:24:02', 'Dystopian'),
(153, 'Divergent', 'Veronica Roth', 2011, 1, '2026-02-23 12:24:02', 'Dystopian'),
(154, 'Insurgent', 'Veronica Roth', 2012, 1, '2026-02-23 12:24:02', 'Dystopian'),
(155, 'Allegiant', 'Veronica Roth', 2013, 1, '2026-02-23 12:24:02', 'Dystopian'),
(156, 'The Maze Runner', 'James Dashner', 2009, 1, '2026-02-23 12:24:02', 'Dystopian'),
(157, 'The Scorch Trials', 'James Dashner', 2010, 1, '2026-02-23 12:24:02', 'Dystopian'),
(158, 'The Death Cure', 'James Dashner', 2011, 1, '2026-02-23 12:24:02', 'Dystopian'),
(159, 'The Kill Order', 'James Dashner', 2012, 1, '2026-02-23 12:24:02', 'Dystopian'),
(160, 'Dune', 'Frank Herbert', 1965, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(161, 'Dune Messiah', 'Frank Herbert', 1969, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(162, 'Children of Dune', 'Frank Herbert', 1976, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(163, 'Foundation', 'Isaac Asimov', 1951, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(164, 'Foundation and Empire', 'Isaac Asimov', 1952, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(165, 'Second Foundation', 'Isaac Asimov', 1953, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(166, 'I, Robot', 'Isaac Asimov', 1950, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(167, 'Do Androids Dream of Electric Sheep?', 'Philip K. Dick', 1968, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(168, 'Ubik', 'Philip K. Dick', 1969, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(169, 'A Scanner Darkly', 'Philip K. Dick', 1977, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(170, 'Snow Crash', 'Neal Stephenson', 1992, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(171, 'Neuromancer', 'William Gibson', 1984, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(172, 'Count Zero', 'William Gibson', 1986, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(173, 'Mona Lisa Overdrive', 'William Gibson', 1988, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(174, 'The Left Hand of Darkness', 'Ursula K. Le Guin', 1969, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(175, 'The Dispossessed', 'Ursula K. Le Guin', 1974, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(176, 'Hyperion', 'Dan Simmons', 1989, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(177, 'The Fall of Hyperion', 'Dan Simmons', 1990, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(178, 'Ender\'s Game', 'Orson Scott Card', 1985, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(179, 'Speaker for the Dead', 'Orson Scott Card', 1986, 1, '2026-02-23 12:24:40', 'Sci-Fi'),
(180, 'The Name of the Wind', 'Patrick Rothfuss', 2007, 1, '2026-02-23 12:24:40', 'Fantasy'),
(181, 'The Wise Man\'s Fear', 'Patrick Rothfuss', 2011, 1, '2026-02-23 12:24:40', 'Fantasy'),
(182, 'The Way of Kings', 'Brandon Sanderson', 2010, 1, '2026-02-23 12:24:40', 'Fantasy'),
(183, 'Words of Radiance', 'Brandon Sanderson', 2014, 1, '2026-02-23 12:24:40', 'Fantasy'),
(184, 'Oathbringer', 'Brandon Sanderson', 2017, 1, '2026-02-23 12:24:40', 'Fantasy'),
(185, 'Rhythm of War', 'Brandon Sanderson', 2020, 1, '2026-02-23 12:24:40', 'Fantasy'),
(186, 'Mistborn: The Final Empire', 'Brandon Sanderson', 2006, 1, '2026-02-23 12:24:40', 'Fantasy'),
(187, 'The Well of Ascension', 'Brandon Sanderson', 2007, 1, '2026-02-23 12:24:40', 'Fantasy'),
(188, 'The Hero of Ages', 'Brandon Sanderson', 2008, 1, '2026-02-23 12:24:40', 'Fantasy'),
(189, 'The Blade Itself', 'Joe Abercrombie', 2006, 1, '2026-02-23 12:24:40', 'Fantasy'),
(190, 'Before They Are Hanged', 'Joe Abercrombie', 2007, 1, '2026-02-23 12:24:40', 'Fantasy'),
(191, 'Last Argument of Kings', 'Joe Abercrombie', 2008, 1, '2026-02-23 12:24:40', 'Fantasy'),
(192, 'American Gods', 'Neil Gaiman', 2001, 1, '2026-02-23 12:24:40', 'Fantasy'),
(193, 'Neverwhere', 'Neil Gaiman', 1996, 1, '2026-02-23 12:24:40', 'Fantasy'),
(194, 'Good Omens', 'Neil Gaiman & Terry Pratchett', 1990, 1, '2026-02-23 12:24:40', 'Fantasy'),
(195, 'The Colour of Magic', 'Terry Pratchett', 1983, 1, '2026-02-23 12:24:40', 'Fantasy'),
(196, 'Mort', 'Terry Pratchett', 1987, 1, '2026-02-23 12:24:40', 'Fantasy'),
(197, 'Guards! Guards!', 'Terry Pratchett', 1989, 1, '2026-02-23 12:24:40', 'Fantasy'),
(198, 'Small Gods', 'Terry Pratchett', 1992, 1, '2026-02-23 12:24:40', 'Fantasy'),
(199, 'It', 'Stephen King', 1986, 1, '2026-02-23 12:24:40', 'Horror'),
(200, 'Pet Sematary', 'Stephen King', 1983, 1, '2026-02-23 12:24:40', 'Horror'),
(201, 'Carrie', 'Stephen King', 1974, 1, '2026-02-23 12:24:40', 'Horror'),
(202, 'Misery', 'Stephen King', 1987, 1, '2026-02-23 12:24:40', 'Horror'),
(203, 'Salem\'s Lot', 'Stephen King', 1975, 1, '2026-02-23 12:24:40', 'Horror'),
(204, 'The Stand', 'Stephen King', 1978, 1, '2026-02-23 12:24:40', 'Horror'),
(205, 'Bird Box', 'Josh Malerman', 2014, 1, '2026-02-23 12:24:40', 'Horror'),
(206, 'The Haunting of Hill House', 'Shirley Jackson', 1959, 1, '2026-02-23 12:24:40', 'Horror'),
(207, 'We Have Always Lived in the Castle', 'Shirley Jackson', 1962, 1, '2026-02-23 12:24:40', 'Horror'),
(208, 'The Girl on the Train', 'Paula Hawkins', 2015, 1, '2026-02-23 12:24:40', 'Thriller'),
(209, 'Gone Girl', 'Gillian Flynn', 2012, 1, '2026-02-23 12:24:40', 'Thriller'),
(210, 'Sharp Objects', 'Gillian Flynn', 2006, 1, '2026-02-23 12:24:40', 'Thriller'),
(211, 'Dark Places', 'Gillian Flynn', 2009, 1, '2026-02-23 12:24:40', 'Thriller'),
(212, 'The Silent Patient', 'Alex Michaelides', 2019, 1, '2026-02-23 12:24:40', 'Thriller'),
(213, 'Big Little Lies', 'Liane Moriarty', 2014, 1, '2026-02-23 12:24:40', 'Thriller'),
(214, 'The Reversal', 'Michael Connelly', 2010, 1, '2026-02-23 12:24:40', 'Crime'),
(215, 'The Lincoln Lawyer', 'Michael Connelly', 2005, 1, '2026-02-23 12:24:40', 'Crime'),
(216, 'The Godfather', 'Mario Puzo', 1969, 1, '2026-02-23 12:24:40', 'Crime'),
(217, 'Me Before You', 'Jojo Moyes', 2012, 1, '2026-02-23 12:24:40', 'Romance'),
(218, 'After You', 'Jojo Moyes', 2015, 1, '2026-02-23 12:24:40', 'Romance'),
(219, 'Still Me', 'Jojo Moyes', 2018, 1, '2026-02-23 12:24:40', 'Romance'),
(220, 'The Notebook', 'Nicholas Sparks', 1996, 1, '2026-02-23 12:24:40', 'Romance'),
(221, 'Dear John', 'Nicholas Sparks', 2006, 1, '2026-02-23 12:24:40', 'Romance'),
(222, 'The Last Song', 'Nicholas Sparks', 2009, 1, '2026-02-23 12:24:40', 'Romance'),
(223, 'Normal People', 'Sally Rooney', 2018, 1, '2026-02-23 12:24:40', 'Fiction'),
(224, 'Conversations with Friends', 'Sally Rooney', 2017, 1, '2026-02-23 12:24:40', 'Fiction'),
(225, 'Where the Crawdads Sing', 'Delia Owens', 2018, 1, '2026-02-23 12:24:40', 'Fiction'),
(226, 'The Midnight Library', 'Matt Haig', 2020, 1, '2026-02-23 12:24:40', 'Fiction'),
(227, 'The Invisible Life of Addie LaRue', 'V.E. Schwab', 2020, 1, '2026-02-23 12:24:40', 'Fantasy'),
(228, 'Middlemarch', 'George Eliot', 1871, 1, '2026-02-23 12:24:40', 'Classic'),
(229, 'The Mill on the Floss', 'George Eliot', 1860, 1, '2026-02-23 12:24:40', 'Classic'),
(230, 'The Jungle Book', 'Rudyard Kipling', 1894, 1, '2026-02-23 12:24:40', 'Classic'),
(231, 'Kim', 'Rudyard Kipling', 1901, 1, '2026-02-23 12:24:40', 'Classic'),
(232, 'Treasure Island', 'Robert Louis Stevenson', 1883, 1, '2026-02-23 12:24:40', 'Adventure'),
(233, 'Kidnapped', 'Robert Louis Stevenson', 1886, 1, '2026-02-23 12:24:40', 'Adventure'),
(234, 'The Call of the Wild', 'Jack London', 1903, 1, '2026-02-23 12:24:40', 'Adventure'),
(235, 'White Fang', 'Jack London', 1906, 1, '2026-02-23 12:24:40', 'Adventure'),
(236, 'Pál utcai fiúk', 'Molnár Ferenc', 1906, 1, '2026-02-23 12:24:40', 'Klasszikus'),
(237, 'Egri csillagok', 'Gárdonyi Géza', 1899, 1, '2026-02-23 12:24:40', 'Klasszikus'),
(238, 'Abigél', 'Szabó Magda', 1970, 1, '2026-02-23 12:24:40', 'Klasszikus'),
(239, 'Tüskevár', 'Fekete István', 1957, 1, '2026-02-23 12:24:40', 'Ifjúsági'),
(240, 'Sorstalanság', 'Kertész Imre', 1975, 1, '2026-02-23 12:24:40', 'Klasszikus'),
(241, 'Twilight', 'Stephenie Meyer', 2005, 1, '2026-02-23 12:24:40', 'Romance'),
(242, 'New Moon', 'Stephenie Meyer', 2006, 1, '2026-02-23 12:24:40', 'Romance'),
(243, 'Eclipse', 'Stephenie Meyer', 2007, 1, '2026-02-23 12:24:40', 'Romance'),
(244, 'Breaking Dawn', 'Stephenie Meyer', 2008, 1, '2026-02-23 12:24:40', 'Romance');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `konyv_cimke`
--

CREATE TABLE `konyv_cimke` (
  `konyv_id` int(11) NOT NULL,
  `cimke_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `mufajok`
--

CREATE TABLE `mufajok` (
  `id` int(11) NOT NULL,
  `nev` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- A tábla adatainak kiíratása `mufajok`
--

INSERT INTO `mufajok` (`id`, `nev`) VALUES
(4, 'Adventure'),
(2, 'Fantasy'),
(3, 'Romance'),
(1, 'Sci-Fi'),
(5, 'Thriller');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `peldanyok`
--

CREATE TABLE `peldanyok` (
  `id` int(11) NOT NULL,
  `konyv_id` int(11) NOT NULL,
  `allapot` enum('uj','jo','hasznalt','serult') DEFAULT 'uj',
  `elerheto` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `szerzok`
--

CREATE TABLE `szerzok` (
  `id` int(11) NOT NULL,
  `nev` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- A tábla adatainak kiíratása `szerzok`
--

INSERT INTO `szerzok` (`id`, `nev`) VALUES
(1, 'Frank Herbert'),
(3, 'George R.R. Martin'),
(2, 'J.K. Rowling'),
(4, 'Jules Verne');

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
  ADD KEY `konyv_id` (`konyv_id`),
  ADD KEY `felhasznalo_id` (`felhasznalo_id`);

--
-- A tábla indexei `konyvek`
--
ALTER TABLE `konyvek`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cim` (`cim`,`szerzo`),
  ADD UNIQUE KEY `cim_2` (`cim`,`szerzo`),
  ADD KEY `idx_cim` (`cim`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=698;

--
-- AUTO_INCREMENT a táblához `mufajok`
--
ALTER TABLE `mufajok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `peldanyok`
--
ALTER TABLE `peldanyok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `szerzok`
--
ALTER TABLE `szerzok`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  ADD CONSTRAINT `kolcsonzesek_ibfk_1` FOREIGN KEY (`konyv_id`) REFERENCES `konyvek` (`id`),
  ADD CONSTRAINT `kolcsonzesek_ibfk_2` FOREIGN KEY (`felhasznalo_id`) REFERENCES `felhasznalok` (`id`);

--
-- Megkötések a táblához `konyv_cimke`
--
ALTER TABLE `konyv_cimke`
  ADD CONSTRAINT `konyv_cimke_ibfk_1` FOREIGN KEY (`konyv_id`) REFERENCES `konyvek` (`id`),
  ADD CONSTRAINT `konyv_cimke_ibfk_2` FOREIGN KEY (`cimke_id`) REFERENCES `cimkek` (`id`);

--
-- Megkötések a táblához `peldanyok`
--
ALTER TABLE `peldanyok`
  ADD CONSTRAINT `peldanyok_ibfk_1` FOREIGN KEY (`konyv_id`) REFERENCES `konyvek` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
