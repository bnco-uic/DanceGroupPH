-- Sayaw Pilipinas: Philippine Dance Group Manager
-- SHARED HOSTING version: no CREATE DATABASE / USE.
-- First select your hosting database in phpMyAdmin, then import this file.
-- All groups and leader names below are FICTIONAL.
DROP TABLE IF EXISTS dance_groups;

CREATE TABLE dance_groups (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  group_name      VARCHAR(100) NOT NULL,
  dance_style     VARCHAR(30)  NOT NULL,   -- Folk, Festival, Street, Contemporary, Cultural, Ballroom
  region          VARCHAR(50)  NOT NULL,
  city            VARCHAR(80)  NOT NULL,   -- also used for the weather lookup
  founded_year    SMALLINT     NULL,
  member_count    INT UNSIGNED NOT NULL,
  leader_name     VARCHAR(100) NULL,
  signature_dance VARCHAR(100) NULL,
  description     TEXT         NULL,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO dance_groups
  (group_name, dance_style, region, city, founded_year, member_count, leader_name, signature_dance, description, is_active, created_at)
VALUES
  ('Kadayawan Indak Collective', 'Festival', 'Davao Region', 'Davao City', 2008, 48, 'Liza Marquez Tan', 'Kadayawan Street Dance', 'A festival troupe that performs every August at the Kadayawan celebration, honoring the harvest and the tribes of Davao.', 1, '2026-01-05 09:00:00'),
  ('Palayan Tinikling Troupe', 'Folk', 'Central Luzon', 'Cabanatuan City', 1995, 32, 'Ramon Villareal', 'Tinikling', 'A community folk group known for fast bamboo-pole routines inspired by the rice fields of Nueva Ecija.', 1, '2026-01-12 09:00:00'),
  ('Singkil Heritage Ensemble', 'Cultural', 'BARMM', 'Marawi City', 1988, 25, 'Amina Dimaporo Lucman', 'Singkil', 'Preserves Maranao court dances with fans, crossed bamboo poles, and royal costumes.', 1, '2026-01-20 09:00:00'),
  ('Sugbo Sinulog Street Crew', 'Festival', 'Central Visayas', 'Cebu City', 2010, 120, 'Paolo Enriquez', 'Sinulog', 'A large contingent that trains all year for the January Sinulog grand parade.', 1, '2026-02-02 09:00:00'),
  ('Metro Groove Collective', 'Street', 'NCR', 'Quezon City', 2015, 18, 'Kevin Sarmiento', 'Hip-hop Tinikling Fusion', 'Mixes modern street dance with Filipino folk steps for school and mall competitions.', 1, '2026-02-14 09:00:00'),
  ('Alon Contemporary Dance Lab', 'Contemporary', 'Western Visayas', 'Iloilo City', 2018, 12, 'Isabel Custodio', 'Alon (The Wave)', 'A small studio group that tells island stories through modern choreography.', 1, '2026-03-01 09:00:00'),
  ('Sampaguita Ballroom Club', 'Ballroom', 'NCR', 'Manila', 2001, 40, 'Teodoro Almazan', 'Cha-cha', 'Social and competitive ballroom dancers who hold weekend classes for senior citizens.', 1, '2026-03-10 09:00:00'),
  ('Liwanag Pandanggo Dancers', 'Folk', 'MIMAROPA', 'Calapan', 1999, 28, 'Rosario Delos Angeles', 'Pandanggo sa Ilaw', 'Balances oil lamps on the head and hands in the traditional Mindoro candle dance.', 1, '2026-03-22 09:00:00'),
  ('Ngiti Maskara Troupe', 'Festival', 'Negros Island Region', 'Bacolod City', 2005, 60, 'Carlo Benitez', 'MassKara Street Dance', 'Colorful smiling masks and upbeat Latin rhythms. Currently on break until next season.', 0, '2026-04-03 09:00:00'),
  ('Cordillera Banga Circle', 'Cultural', 'CAR', 'Baguio City', 1992, 22, 'Grace Pagaddut', 'Banga (Pot Dance)', 'Performs Kalinga dances where women balance stacked clay pots on their heads.', 1, '2026-04-18 09:00:00'),
  ('Hataw Mindanao Street Dancers', 'Street', 'Northern Mindanao', 'Cagayan de Oro', 2012, 15, 'Jericho Lumapas', 'Krumping Kuratsa', 'A youth crew that joined regional street dance battles. Inactive while members finish college.', 0, '2026-05-06 09:00:00'),
  ('Lakas Latik Folk Group', 'Folk', 'CALABARZON', 'Biñan', 1990, 30, 'Dominador Ilagan', 'Maglalatik', 'Male dancers strike coconut-shell halves worn on the body in a mock battle dance.', 1, '2026-05-20 09:00:00');
