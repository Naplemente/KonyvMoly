CREATE DATABASE konyvtar CHARACTER SET utf8mb4;
USE konyvtar;

-- FELHASZNALOK
CREATE TABLE felhasznalok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    letrehozas_datuma DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- KONYVEK
CREATE TABLE konyvek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cim VARCHAR(200) NOT NULL,
    szerzo VARCHAR(150) NOT NULL,
    kiadas_eve INT,
    elerheto BOOLEAN DEFAULT 1,
    letrehozas_datuma DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- KOLCSONZESEK
CREATE TABLE kolcsonzesek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    felhasznalo_id INT NOT NULL,
    konyv_id INT NOT NULL,
    kolcsonzes_datuma DATE NOT NULL,
    visszahozas_datuma DATE DEFAULT NULL,
    statusz VARCHAR(20) DEFAULT 'aktiv',

    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalok(id),
    FOREIGN KEY (konyv_id) REFERENCES konyvek(id)
);
