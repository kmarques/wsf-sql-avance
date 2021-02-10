CREATE TABLE public.user_account (
    id BIGINT NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    address TEXT,
    email_confirmed BOOLEAN NOT NULL DEFAULT false,
    creation_date TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
--
CREATE SEQUENCE public.user_account_id_seq START WITH 1 INCREMENT BY 1;
--
INSERT INTO public.user_account(id, firstname, lastname, address)
VALUES (
        nextval('public.user_account_id_seq'),
        --id
        'jean',
        -- firstname
        'dupont',
        -- lastname
        NULL -- address
    ),
    (
        nextval('public.user_account_id_seq'),
        'john',
        'doe',
        '25 backer street, london, UK'
    ),
    (
        nextval('public.user_account_id_seq'),
        'jane',
        'doe',
        '25 backer street, london, UK'
    );
--
ALTER TABLE user_account
ADD COLUMN password VARCHAR(30);
--
UPDATE user_account
SET password = CASE
        id
        WHEN 1 THEN 'foofoo'
        WHEN 2 THEN 'barbar'
        WHEN 3 THEN 'foobar'
    END;
--
ALTER TABLE user_account
ALTER COLUMN password
SET NOT NULL;
--
ALTER TABLE user_account
ADD CONSTRAINT check_password CHECK (length(password) >= 6);
--
ALTER TABLE user_account
ADD PRIMARY KEY(id);
--
ALTER TABLE user_account
ALTER COLUMN id
SET DEFAULT nextval('public.user_account_id_seq');
--
CREATE TABLE animal (
    id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(50) NOT NULL,
    owner BIGINT REFERENCES user_account(id)
);
--
BEGIN;
--
UPDATE user_account
SET email_confirmed = true;
--
COMMIT;
--
BEGIN;
--
CREATE SCHEMA community;
CREATE TABLE community.follower(
    user_account_id BIGINT REFERENCES user_account(id),
    animal_id INT REFERENCES animal(id),
    mode CHAR(4) NOT NULL DEFAULT 'view',
    PRIMARY KEY(user_account_id, animal_id)
);
--
COMMIT;
--
INSERT INTO animal (name, owner)
SELECT CASE
        firstname || lastname
        WHEN 'jeandupont' THEN 'foo'
        WHEN 'johndoe' THEN 'bar'
    END,
    id
FROM user_account;
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
    INNER JOIN community.follower ON animal.id = animal_id
    INNER JOIN user_account ua2 ON user_account_id = ua2.id;
--
CREATE TABLE animal_status (
    id SERIAL PRIMARY KEY,
    animal_id INT REFERENCES animal(id),
    status CHAR(5) NOT NULL CHECK (status IN ('BIRTH', 'SICK', 'DEATH')),
    date TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO animal_status(animal_id, status, date)
SELECT id,
    'BIRTH',
    NOW() - INTERVAL '2 years'
FROM animal
UNION
SELECT 4,
    'SICK',
    NOW() - INTERVAL '1 year'
UNION
SELECT 5,
    'SICK',
    NOW() - INTERVAL '2 day'
UNION
SELECT 5,
    'DEATH',
    NOW() - INTERVAL '1 day';
--
SELECT animal_id,
    MAX(date)
FROM animal_status
GROUP BY animal_id;
--
SELECT a.*,
    ast.status,
    max_date
FROM (
        SELECT animal_id,
            MAX(date) AS max_date
        FROM animal_status
        GROUP BY animal_id
    ) as ams
    INNER JOIN animal a ON a.id = ams.animal_id
    INNER JOIN animal_status ast ON ams.animal_id = ast.animal_id
    AND ams.max_date = ast.date;
--
WITH animal_max_status AS (
    SELECT animal_id,
        MAX(date) AS max_date
    FROM animal_status
    GROUP BY animal_id
)
SELECT a.*,
    ams.status,
    max_date
FROM animal_max_status ams
    INNER JOIN animal a ON a.id = ams.animal_id
    INNER JOIN animal_status ast ON ams.animal_id = ast.animal_id
    AND ams.max_date = ast.date;
--
WITH animal_max_status AS (
    SELECT animal_id,
        status,
        date,
        row_number() OVER (
            PARTITION BY animal_id
            ORDER BY date DESC
        ) AS row_number
    FROM animal_status
)
SELECT a.*,
    status,
    date
FROM animal_max_status ams
    INNER JOIN animal a ON a.id = ams.animal_id
WHERE row_number = 1;
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
-- Récupérer le prochain event pour chaque animaux actuellement malades