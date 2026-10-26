-- ================================================================
-- SCRIPT DE BASE DE DONNÉES — DigitSagnse
-- Application : Gestion d'Atelier de Couture & Suivi Client
-- SGBD Compatible : MySQL / MariaDB / PostgreSQL
-- ================================================================

CREATE DATABASE IF NOT EXISTS digitsagnse CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE digitsagnse;

-- 1. Table des Utilisateurs (Couturiers, Gérants, Clients)
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    email VARCHAR(150) UNIQUE NOT NULL,
    telephone VARCHAR(30),
    role ENUM('tailor', 'manager', 'client') DEFAULT 'tailor',
    atelier_id VARCHAR(64),
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Table des Ateliers
CREATE TABLE IF NOT EXISTS ateliers (
    id VARCHAR(64) PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    adresse TEXT,
    telephone VARCHAR(30),
    proprietaire_id VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (proprietaire_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 3. Table des Clients
CREATE TABLE IF NOT EXISTS clients (
    id VARCHAR(64) PRIMARY KEY,
    atelier_id VARCHAR(64) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    telephone VARCHAR(30) NOT NULL,
    email VARCHAR(150),
    adresse TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (atelier_id) REFERENCES ateliers(id) ON DELETE CASCADE
);

-- 4. Table des Mesures Clients
CREATE TABLE IF NOT EXISTS mesures (
    id VARCHAR(64) PRIMARY KEY,
    client_id VARCHAR(64) NOT NULL,
    type_vetement VARCHAR(50) DEFAULT 'complet', -- boubou, costume, robe, etc.
    tour_cou DECIMAL(5,2),
    tour_poitrine DECIMAL(5,2),
    tour_taille DECIMAL(5,2),
    tour_bassin DECIMAL(5,2),
    longueur_epaule DECIMAL(5,2),
    longueur_bras DECIMAL(5,2),
    tour_bras DECIMAL(5,2),
    longueur_pantalon DECIMAL(5,2),
    tour_cuisse DECIMAL(5,2),
    longueur_totale DECIMAL(5,2),
    remarques TEXT,
    date_prise TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

-- 5. Table du Catalogue / Modèles de vêtements
CREATE TABLE IF NOT EXISTS modeles (
    id VARCHAR(64) PRIMARY KEY,
    atelier_id VARCHAR(64) NOT NULL,
    nom VARCHAR(120) NOT NULL,
    categorie VARCHAR(60), -- Homme, Femme, Enfant, Cérémonie
    description TEXT,
    prix_base DECIMAL(10,2) DEFAULT 0.00,
    delai_confection_jours INT DEFAULT 7,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (atelier_id) REFERENCES ateliers(id) ON DELETE CASCADE
);

-- 6. Table des Commandes
CREATE TABLE IF NOT EXISTS commandes (
    id VARCHAR(64) PRIMARY KEY,
    code_suivi VARCHAR(20) UNIQUE NOT NULL, -- Ex: CMD-2026-001
    atelier_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    modele_id VARCHAR(64),
    description_commande TEXT,
    tissu_fourni BOOLEAN DEFAULT TRUE,
    statut ENUM('receptionne', 'coupe', 'couture', 'essayage', 'pret', 'livre') DEFAULT 'receptionne',
    montant_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    montant_paye DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    date_commande TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_livraison_prevue DATE,
    date_livraison_reelle DATE,
    FOREIGN KEY (atelier_id) REFERENCES ateliers(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (modele_id) REFERENCES modeles(id) ON DELETE SET NULL
);

-- 7. Table des Paiements / Acomptes
CREATE TABLE IF NOT EXISTS paiements (
    id VARCHAR(64) PRIMARY KEY,
    commande_id VARCHAR(64) NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    mode_paiement ENUM('especes', 'wave', 'orange_money', 'carte', 'virement') DEFAULT 'wave',
    reference_transaction VARCHAR(100),
    date_paiement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE
);

-- 8. Table des Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    titre VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    est_lu BOOLEAN DEFAULT FALSE,
    date_envoi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ================================================================
-- JEU DE DONNÉES DE DÉMONSTRATION (TEST DATA)
-- ================================================================

INSERT INTO ateliers (id, nom, adresse, telephone) VALUES
('atl_01', 'Atelier DigitSagnse Dakar', 'Rue 10 x Corniche, Dakar, Sénégal', '+221 77 123 45 67');

INSERT INTO users (id, nom, prenom, email, telephone, role, atelier_id) VALUES
('usr_couturier_1', 'Diop', 'Amadou', 'amadou.diop@digitsagnse.sn', '+221 77 123 45 67', 'tailor', 'atl_01'),
('usr_client_1', 'Ndiaye', 'Fatou', 'fatou.ndiaye@gmail.com', '+221 78 987 65 43', 'client', 'atl_01');

INSERT INTO clients (id, atelier_id, nom, prenom, telephone, email, adresse) VALUES
('clt_01', 'atl_01', 'Ndiaye', 'Fatou', '+221 78 987 65 43', 'fatou.ndiaye@gmail.com', 'Mermoz, Dakar'),
('clt_02', 'atl_01', 'Fall', 'Moussa', '+221 76 543 21 09', 'moussa.fall@gmail.com', 'Sacré-Cœur 3, Dakar');

INSERT INTO mesures (id, client_id, type_vetement, tour_cou, tour_poitrine, tour_taille, tour_bassin, longueur_pantalon, longueur_totale) VALUES
('msr_01', 'clt_01', 'Taille Basse / Robe', 36.0, 92.0, 74.0, 102.0, NULL, 145.0),
('msr_02', 'clt_02', 'Grand Boubou 3 pièces', 41.0, 104.0, 88.0, 100.0, 105.0, 155.0);

INSERT INTO modeles (id, atelier_id, nom, categorie, prix_base, delai_confection_jours) VALUES
('mod_01', 'atl_01', 'Grand Boubou Brodé Royal', 'Homme', 45000.00, 7),
('mod_02', 'atl_01', 'Robe de Cérémonie Bazin Riche', 'Femme', 50000.00, 10);

INSERT INTO commandes (id, code_suivi, atelier_id, client_id, modele_id, description_commande, statut, montant_total, montant_paye, date_livraison_prevue) VALUES
('cmd_01', 'CMD-2026-001', 'atl_01', 'clt_01', 'mod_02', 'Robe Bazin Riche bleue avec broderie dorée', 'couture', 50000.00, 30000.00, '2026-11-05'),
('cmd_02', 'CMD-2026-002', 'atl_01', 'clt_02', 'mod_01', 'Boubou 3 pièces blanc col officier', 'receptionne', 45000.00, 45000.00, '2026-11-10');

INSERT INTO paiements (id, commande_id, montant, mode_paiement, reference_transaction) VALUES
('pay_01', 'cmd_01', 30000.00, 'wave', 'WAVE-TX-992384'),
('pay_02', 'cmd_02', 45000.00, 'orange_money', 'OM-SN-883712');
