INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('society_vigneron', 'Vigneron', 1);

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('society_vigneron', 'Vigneron', 1);

INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
('society_vigneron', 'Vigneron', 1);

INSERT INTO `jobs` (`name`, `label`) VALUES
('vigneron', 'Vigneron');


INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('vigneron', 0, 'recrue', 'Stagiaire', 10, '{}', '{}'),
('vigneron', 1, 'novice', 'Serveur', 20, '{}', '{}'),
('vigneron', 2, 'experimente', 'Responsable', 30, '{}', '{}'),
('vigneron', 3, 'chief', 'Co-Patron', 40, '{}', '{}'),
('vigneron', 4, 'boss', 'Patron', 50, '{}', '{}');

INSERT INTO `items` (`name`, `label`) VALUES
	('raisin', 'Raisin'),
	('vin', 'Vin')
;