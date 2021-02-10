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
    INNER JOIN user_account ON animal.owner = user_account.id