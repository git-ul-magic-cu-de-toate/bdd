CREATE DATABASE parc_eco_db;

USE parc_eco_db;

CREATE TABLE Habitat (
    habitat_id INT PRIMARY KEY,
	habitat_name VARCHAR(100),
    size DECIMAL(10, 2) CHECK (size > 0),
	diversity INT NOT NULL CHECK (diversity >= 0)
);

CREATE TABLE Animal (
    animal_species VARCHAR(100) PRIMARY KEY,
    habitat_id INT NOT NULL REFERENCES Habitat(habitat_id),
    animal_count INT CHECK (animal_count >= 0),
	conservation_level VARCHAR(2) CHECK (conservation_level in ('EX', 'EW', 'CR', 'EN', 'VU', 'NT', 'LC'))
);

CREATE TABLE Plant (
    plant_species VARCHAR(100) PRIMARY KEY,
    habitat_id INT NOT NULL REFERENCES Habitat(habitat_id),
	plant_count INT CHECK (plant_count >= 0),
	conservation_level VARCHAR(2) CHECK (conservation_level in ('EX', 'EW', 'CR', 'EN', 'VU', 'NT', 'LC')),
	photosynthetic_efficiency DECIMAL(5, 2) CHECK (photosynthetic_efficiency > 0 AND photosynthetic_efficiency < 1)
);

CREATE TABLE JobDetails (
    job_id INT PRIMARY KEY,
	job_name VARCHAR(50) NOT NULL,
    habitat_id INT REFERENCES Habitat(habitat_id),
    animal_species VARCHAR(100) REFERENCES Animal(animal_species),
    plant_species VARCHAR(100) REFERENCES Plant(plant_species),
	administrative INT NOT NULL CHECK (administrative = 1 OR administrative = 0)
);

CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    employee_first_name VARCHAR(100) NOT NULL,
	employee_last_name VARCHAR(100) NOT NULL,
    job_id INT NOT NULL REFERENCES JobDetails(job_id),
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL CHECK (salary > 0)
);

CREATE TABLE Visitor (
    visitor_id INT PRIMARY KEY,
    visitor_first_name VARCHAR(100),
	visitor_last_name VARCHAR(100),
    visit_date DATE NOT NULL,
    total_duration TIME NOT NULL,
    visitor_age INT CHECK (visitor_age > 0)
);

CREATE TABLE VisitorActivity (
    activity_id INT PRIMARY KEY,
    habitat_id INT NOT NULL REFERENCES Habitat(habitat_id),
    duration TIME NOT NULL,
    visitor_id INT NOT NULL REFERENCES Visitor(visitor_id)
);