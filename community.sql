BEGIN;
--
CREATE SCHEMA community;
--
CREATE TABLE community.follower(
    user_account_id BIGINT REFERENCES user_account(id),
    animal_id INT REFERENCES animal(id),
    mode CHAR(4) NOT NULL DEFAULT 'view',
    PRIMARY KEY(user_account_id, animal_id)
);
--
INSERT INTO community.follower(animal_id, user_account_id)
SELECT animal.id,
    user_account.id
FROM animal,
    user_account
WHERE animal.owner != user_account.id
    AND user_account.id != 3;
--
SELECT animal_id,
    id,
    firstname,
    lastname,
    mode
FROM community.follower
    INNER JOIN user_account ON user_account_id = id;
--
SELECT animal.id,
    user_account.id,
    firstname,
    lastname,
    'edit' as mode
FROM animal
    INNER JOIN user_account ON animal.owner = user_account.id;
--
SELECT animal_id,
    id,
    firstname,
    lastname,
    mode
FROM community.follower
    INNER JOIN user_account ON user_account_id = id
UNION
SELECT animal.id,
    user_account.id,
    firstname,
    lastname,
    'edit' as mode
FROM animal
    INNER JOIN user_account ON animal.owner = user_account.id;
--
SELECT animal.id,
    ua.id,
    ua.firstname,
    ua.lastname,
    ua2.id,
    ua2.firstname,
    ua2.lastname
FROM animal
    INNER JOIN user_account ua ON animal.owner = ua.id
    LEFT JOIN community.follower ON animal.id = animal_id
    LEFT JOIN user_account ua2 ON user_account_id = ua2.id;
--
COMMIT;