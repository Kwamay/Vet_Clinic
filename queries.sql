--find all animals
SELECT * FROM animals;

--  Find all animals whose name ends in "mon".
SELECT * FROM animals
WHERE name LIKE '%mon';

--List the name of all animals born between 2016 and 2019.
SELECT name
FROM animals
WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-12-31';


--List the name of all animals that are neutered and have less than 3 escape attempts.
SELECT name
FROM animals
WHERE neutered = true AND escape_attempts < 3;

--List the date of birth of all animals named either "Agumon" or "Pikachu".
SELECT date_of_birth
FROM animals
WHERE name IN ('Agumon', 'Pikachu');

--List name and escape attempts of animals that weigh more than 10.5kg
SELECT name, escape_attempts
FROM animals
WHERE weight_kg > 10.5;

--Find all animals that are neutered.
SELECT *
FROM animals
WHERE neutered = true;

--Find all animals not named Gabumon.
SELECT *
FROM animals
WHERE name <> 'Gabumon';

--Find all animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg)

SELECT *
FROM animals
WHERE weight_kg BETWEEN 10.4 AND 17.3;

-- Inside a transaction update the animals table by setting the species column to unspecified. Verify that change was made. 
BEGIN;
UPDATE animals
SET species = 'unspecified';

-- Verify that change was made. Then roll back the change and verify that the species columns went back to the state before the transaction.
SELECT * FROM animals; -- species column = unspecified
ROLLBACK;
SELECT * FROM animals -- species column = null

--Inside a transaction: Update the animals table by setting the species column to digimon for all animals that have a name ending in mon. Update the animals table by setting the species column to pokemon for all animals that don't have species already set.

BEGIN;

-- Update species to 'digimon' for animals with names ending in "mon"
UPDATE animals
SET species = 'digimon'
WHERE name LIKE '%mon';

-- Update species to 'pokemon' for animals with no species set
UPDATE animals
SET species = 'pokemon'
WHERE species IS NULL;

-- Verification step before COMMIT
SELECT * FROM animals;

COMMIT;

SELECT * FROM animals;

-- Inside a transaction delete all records in the animals table, then roll back the transaction.

BEGIN;

-- Delete all records in the animals table
DELETE FROM animals;

SELECT * FROM animals;


-- Roll back the transaction to undo the deletion
ROLLBACK;

SELECT * FROM animals;



-- Inside a transaction: Delete all animals born after Jan 1st, 2022.Create a savepoint for the transaction.Update all animals' weight to be their weight multiplied by -1. Rollback to the savepoint Update all animals' weights that are negative to be their weight ultiplied by -1. Commit transaction



BEGIN;

-- Delete all animals born after Jan 1st, 2022
DELETE FROM animals
WHERE date_of_birth > '2022-01-01';

-- Create a savepoint
SAVEPOINT savepoint_one;

-- Update all animals' weight to be their weight multiplied by -1
UPDATE animals
SET weight_kg = weight_kg * -1;

-- Rollback to the savepoint
ROLLBACK TO savepoint_one;

-- Update all animals' weights that are negative to be their weight multiplied by -1
UPDATE animals
SET weight_kg = weight_kg * -1
WHERE weight_kg < 0;

-- Commit the transaction
COMMIT;

-- Write queries to answer the following questions: 

--How many animals are there?
SELECT COUNT(*) FROM animals;


-- How many animals have never tried to escape
SELECT COUNT(*) FROM animals WHERE escape_attempts = 0;

-- What is the average weight of animals?
SELECT AVG(weight_kg) FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) as total_escape_attempts
FROM animals
GROUP BY neutered;


-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg) as min_weight, MAX(weight_kg) as max_weight
FROM animals
GROUP BY species;

--What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) as avg_escape_attempts
FROM animals
WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'
GROUP BY species;

-- Write queries (using JOIN) to answer the following questions:
-- What animals belong to Melody Pond?
-- List of all animals that are pokemon (their type is Pokemon).
-- List all owners and their animals, remember to include those 
-- that don't own any animal.
-- How many animals are there per species?
-- List all Digimon owned by Jennifer Orwell.
-- List all animals owned by Dean Winchester that haven't tried 
-- to escape.
-- Who owns the most animals?

SELECT name, full_name FROM animals
JOIN owners ON animals.owner_id = owners.id
where full_name = 'Melody Pond';

SELECT animals.name AS animal_name, species.name AS species FROM animals
JOIN species ON animals.species_id = species.id  
WHERE species.name = 'Pokemon';

SELECT full_name, name FROM owners
left JOIN animals ON owners.id = animals.owner_id;

SELECT species.name, count(species_id) AS species_count FROM species
JOIN animals ON species.id = animals.species_id 
GROUP BY species.name;

SELECT species.name AS species, full_name, animals.name AS animal_name FROM animals 
JOIN species ON animals.id = species.id 
JOIN owners ON animals.id = owners.id 
WHERE full_name = 'Jennifer Orwell'  AND species.name = 'Digimon';

SELECT animals.name, full_name, escape_attempts FROM animals 
JOIN owners ON animals.owner_id = owners.id 
WHERE full_name = 'Dean Winchester' and escape_attempts = 0;

SELECT full_name, count(owner_id) AS animals_count FROM animals 
JOIN owners ON animals.owner_id = owners.id 
GROUP BY full_name 
ORDER BY animals_count DESC 
LIMIT 1;

-- Who was the last animal seen by William Tatcher?
-- How many different animals did Stephanie Mendez see?
-- List all vets and their specialties, including vets with no specialties.
-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
-- What animal has the most visits to vets?
-- Who was Maisy Smith's first visit?
-- Details for most recent visit: animal information, vet information, and date of visit.
-- How many visits were with a vet that did not specialize in that animal's species?
-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.

SELECT animals.name AS animal_name, vets.name, date_of_visitation FROM animals 
 JOIN visits ON animals.id = visits.animal_id 
 JOIN vets ON vets.id = visits.vet_id 
 WHERE vets.name = 'William Tatcher' 
 ORDER BY date_of_visitation DESC 
 LIMIT 1;

 SELECT vets.name, COUNT(DISTINCT animal_id) FROM vets 
 JOIN visits ON vets.id = visits.vet_id 
 WHERE vets.name = 'Stephanie Mendez' 
 GROUP BY vets.name;

SELECT vets.name, species.name FROM vets 
LEFT JOIN specializations ON vets.id = specializations.vets_id 
LEFT JOIN species ON species.id = specializations.species_id;

SELECT animals.name AS animal_name, vets.name AS visitor, date_of_visitation FROM animals 
JOIN visits ON animals.id = visits.animal_id 
JOIN vets ON vets.id = visits.vet_id 
WHERE vets.name = 'Stephanie Mendez' AND date_of_visitation BETWEEN '2020-03-01' AND '2020-08-30';

 SELECT animals.name AS animal_name, count(visits.animal_id) AS visits_count FROM animals 
 JOIN visits ON animals.id = visits.animal_id 
 GROUP BY animals.name 
 ORDER BY visits_count DESC;
 
SELECT animals.name AS animal_name, count(visits.animal_id) AS visits_count FROM animals 
 JOIN visits ON animals.id = visits.animal_id 
 GROUP BY animals.name 
 ORDER BY visits_count DESC LIMIT 3;

 SELECT vets.name AS vet_name, animals.name AS animal_name, date_of_visitation FROM vets 
 JOIN visits ON vets.id = visits.vet_id 
 JOIN animals ON animals.id = visits.animal_id 
 WHERE vets.name = 'Maisy Smith' 
 ORDER BY date_of_visitation ASC LIMIT 1;

SELECT vets.name AS vet_name, animals.name AS animal_name,
date_of_birth, escape_attempts,weight_kg, date_of_visitation FROM vets 
JOIN visits ON vets.id = visits.vet_id 
JOIN animals ON animals.id = visits.animal_id
ORDER BY date_of_visitation DESC LIMIT 1;

SELECT vets.name AS vet_name, count(date_of_visitation) AS visit_numbers FROM vets 
LEFT JOIN specializations ON vets.id = specializations.vets_id 
LEFT JOIN visits ON vets.id = visits.vet_id 
LEFT JOIN species ON species.id = specializations.species_id 
JOIN animals ON animals.id = visits.animal_id 
WHERE species.name IS NULL 
GROUP BY vets.name;

SELECT species.name AS speciality, COUNT(species.name) as species_count FROM visits
JOIN vets ON visits.vet_id = vets.id
JOIN animals ON animals.id = visits.animal_id
JOIN species ON species.id = animals.species_id
WHERE vets.name = 'Maisy Smith'
GROUP BY speciality
ORDER BY species_count DESC
LIMIT 1;