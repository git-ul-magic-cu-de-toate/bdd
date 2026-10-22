USE parc_eco_db
GO
INSERT INTO Animal (animal_species, habitat_id, animal_count, conservation_level) VALUES
('Zander', 1, 11, 'LC'),
('Pike', 1, 3, 'LC'),
('Trout', 1, 7, 'LC'),
('Rainbow Trout', 1, 8, 'NT'),
('Carp', 1, 9, 'LC'),
('Perch', 2, 16,'LC'),
('Prussian Carp', 3, 2, 'VU'),
('Wels Catfish', 2, 1, 'VU'),
('Bighead Carp', 3, 14, 'LC'),
('Koi Fish', 2, 5, 'LC'),
('Aspete', 3, 7, 'CR'),
('European Mink', 5, 10, 'EN'),
('European Ground Sqirrel', 4, 22, 'EN'),
('Saker Falcon', 5, 9, 'EW'),
('Chicken', 4, 22, 'LC');
