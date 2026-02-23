DROP DATABASE IF EXISTS konyvek_adatbazis;
CREATE DATABASE konyvek_adatbazis
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE konyvek_adatbazis;

-- ===============================
-- FELHASZNALOK
-- ===============================
CREATE TABLE felhasznalok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    jelszo_hash VARCHAR(255) NOT NULL,
    regisztracio_datuma DATETIME DEFAULT CURRENT_TIMESTAMP,
    role ENUM('user','admin','superadmin') DEFAULT 'user'
) ENGINE=InnoDB;

-- ===============================
-- MUFAJOK
-- ===============================
CREATE TABLE mufajok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ===============================
-- SZERZOK
-- ===============================
CREATE TABLE szerzok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ===============================
-- KONYVEK
-- ===============================
CREATE TABLE konyvek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cim VARCHAR(200) NOT NULL,
    szerzo_id INT NOT NULL,
    mufaj_id INT,
    kiadas_eve INT,
    letrehozas_datuma DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (cim, szerzo_id),
    FOREIGN KEY (szerzo_id) REFERENCES szerzok(id),
    FOREIGN KEY (mufaj_id) REFERENCES mufajok(id)
) ENGINE=InnoDB;

-- ===============================
-- CIMKEK
-- ===============================
CREATE TABLE cimkek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ===============================
-- KONYV_CIMKE (N:M)
-- ===============================
CREATE TABLE konyv_cimke (
    konyv_id INT,
    cimke_id INT,
    PRIMARY KEY (konyv_id, cimke_id),
    FOREIGN KEY (konyv_id) REFERENCES konyvek(id) ON DELETE CASCADE,
    FOREIGN KEY (cimke_id) REFERENCES cimkek(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ===============================
-- PELDANYOK
-- ===============================
CREATE TABLE peldanyok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    konyv_id INT NOT NULL,
    allapot ENUM('uj','jo','hasznalt','serult') DEFAULT 'uj',
    elerheto BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (konyv_id) REFERENCES konyvek(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ===============================
-- KOLCSONZESEK
-- ===============================
CREATE TABLE kolcsonzesek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    peldany_id INT NOT NULL,
    felhasznalo_id INT NOT NULL,
    kolcsonzes_datum DATE NOT NULL,
    visszahozas_datum DATE,
    FOREIGN KEY (peldany_id) REFERENCES peldanyok(id),
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalok(id)
) ENGINE=InnoDB;

-- ===============================
-- ERTEKELESEK
-- ===============================
CREATE TABLE ertekelesek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    konyv_id INT NOT NULL,
    felhasznalo_id INT NOT NULL,
    ertekeles TINYINT CHECK (ertekeles BETWEEN 1 AND 5),
    komment TEXT,
    FOREIGN KEY (konyv_id) REFERENCES konyvek(id),
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalok(id)
) ENGINE=InnoDB;

-- ===============================
-- BUNTETESEK
-- ===============================
CREATE TABLE buntetesek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kolcsonzes_id INT NOT NULL,
    osszeg DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (kolcsonzes_id) REFERENCES kolcsonzesek(id)
) ENGINE=InnoDB;