BEGIN;
--
CREATE TABLE event (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    animal_id INT REFERENCES animal(id),
    date TIMESTAMPTZ NOT NULL
);
--
INSERT INTO event (name, animal_id, date)
VALUES ('vaccin', 4, NOW() + INTERVAL '1 month'),
    ('vaccin 2', 4, NOW() + INTERVAL '3 months'),
    ('vaccin 3', 4, NOW() + INTERVAL '4 months'),
    ('vermifuge', 4, NOW() + INTERVAL '4 month'),
    ('vermifuge 2', 4, NOW() + INTERVAL '6 months'),
    ('vermifuge 3', 4, NOW() + INTERVAL '8 months');
--
INSERT INTO event (name, animal_id, date)
VALUES ('vaccin', 3, NOW() + INTERVAL '1 month'),
    ('vaccin 2', 3, NOW() + INTERVAL '3 months'),
    ('vaccin 3', 3, NOW() + INTERVAL '4 months'),
    ('vermifuge', 3, NOW() + INTERVAL '4 month'),
    ('vermifuge 2', 3, NOW() + INTERVAL '6 months'),
    ('vermifuge 3', 3, NOW() + INTERVAL '8 months');
--
INSERT INTO event (name, animal_id, date)
VALUES ('vaccin', 4, NOW() - INTERVAL '1 month'),
    ('vaccin 2', 4, NOW() - INTERVAL '3 months'),
    ('vaccin 3', 3, NOW() - INTERVAL '4 months'),
    ('vermifuge', 3, NOW() - INTERVAL '4 month');
--
ALTER TABLE event
ADD COLUMN category VARCHAR(9);
--
UPDATE event
set category = split_part(name, ' ', 1);
--
ALTER TABLE event
ALTER COLUMN category
SET NOT NULL;
-- Récupérer le prochain event pour chaque animaux actuellement malades
--  de l'utilisateur Jean Dupont
WITH animal_last_status AS (
    SELECT animal_id,
        status,
        date,
        row_number() OVER (
            PARTITION BY animal_id
            ORDER BY date DESC
        ) AS row_number
    FROM animal_status
        INNER JOIN animal ON animal.id = animal_id
        INNER JOIN user_account on user_account.id = owner
    WHERE lastname = 'dupont'
        and firstname = 'jean'
),
next_event AS (
    SELECT animal_id,
        name,
        event.date,
        row_number() OVER (
            PARTITION BY animal_id
            ORDER BY event.date ASC
        ) AS row_number
    FROM event
        INNER JOIN animal_last_status USING (animal_id)
    WHERE event.date > NOW()
        AND animal_last_status.row_number = 1
        AND animal_last_status.status = 'SICK'
        AND animal_last_status.date < NOW()
)
select *
from next_event
WHERE row_number = 1;
-- Récupérer le prochain event
--   de chaque categorie d'event
--   pour chaque animal
--   qui sont liés (owner ou follower) à john doe
WITH animal_of_johndoe AS (
    SELECT animal_id
    FROM community.follower
        INNER JOIN user_account ON user_account_id = id
    WHERE firstname || lastname = 'johndoe'
    UNION
    SELECT animal.id as animal_id
    FROM animal
        INNER JOIN user_account ON animal.owner = user_account.id
    WHERE firstname || lastname = 'johndoe'
),
event_of_animal_of_johndoe AS (
    SELECT animal_id,
        name,
        event.date,
        category,
        row_number() OVER (
            PARTITION BY animal_id,
            category
            ORDER BY event.date ASC
        ) AS row_number
    FROM event
        RIGHT JOIN animal_of_johndoe USING(animal_id)
    WHERE event.date > NOW()
        OR event.date IS NULL
)
SELECT animal_id,
    name,
    date,
    category
FROM event_of_animal_of_johndoe
WHERE row_number = 1;
--
COMMIT;