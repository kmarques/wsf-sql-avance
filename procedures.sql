BEGIN;
-- id BIGINT NOT NULL,
--     firstname VARCHAR(255) NOT NULL,
--     lastname VARCHAR(255) NOT NULL,
--     address TEXT,
--     email_confirmed BOOLEAN NOT NULL DEFAULT false,
--     creation_date TIMESTAMPTZ NOT NULL DEFAULT NOW()
CREATE OR REPLACE PROCEDURE createUser(
        _firstname VARCHAR(255),
        _lastname VARCHAR(255),
        _address TEXT,
        _config JSONB
    ) AS $$
INSERT INTO public.user_account(firstname, lastname, address, password)
VALUES (
        _firstname,
        _lastname,
        _address,
        LEFT(gen_random_uuid()::text, 30)
    );
WITH config_exploded AS (
    SELECT *
    FROM jsonb_to_record(
            '{"tos_accepted":false,"newsletter_accepted":false}'::jsonb || _config
        ) AS x(
            tos_accepted boolean,
            newsletter_accepted boolean
        )
)
INSERT INTO public.user_config
SELECT (
        SELECT id
        FROM user_account
        WHERE firstname = _firstname
            AND lastname = _lastname
    ),
    tos_accepted,
    newsletter_accepted
FROM config_exploded;
$$ LANGUAGE SQL;
--
CREATE OR REPLACE PROCEDURE deleteUser(_id BIGINT) AS $$
UPDATE animal
SET owner = (
        SELECT user_account_id
        FROM community.follower
        WHERE animal_id = id
        LIMIT 1
    )
WHERE owner = _id;
DELETE FROM community.follower
WHERE user_account_id = _id;
DELETE FROM user_config
WHERE user_id = _id;
DELETE FROM user_account
WHERE id = _id;
$$ LANGUAGE SQL;
--
CREATE OR REPLACE PROCEDURE createUserPL(
        _firstname VARCHAR(255),
        _lastname VARCHAR(255),
        _address TEXT,
        _config JSONB
    ) AS $$
DECLARE
    _id BIGINT;
BEGIN
SELECT nextval('public.user_account_id_seq') INTO _id;
INSERT INTO public.user_account(id,firstname, lastname, address, password)
VALUES (
        _id,
        _firstname,
        _lastname,
        _address,
        LEFT(gen_random_uuid()::text, 30)
    );
WITH config_exploded AS (
    SELECT *
    FROM jsonb_to_record(
            '{"tos_accepted":false,"newsletter_accepted":false}'::jsonb || _config
        ) AS x(
            tos_accepted boolean,
            newsletter_accepted boolean
        )
)
INSERT INTO public.user_config
SELECT _id,
    tos_accepted,
    newsletter_accepted
FROM config_exploded;
END
$$ LANGUAGE plpgsql;
--
CREATE OR REPLACE PROCEDURE checkAnimals(
        _id in BIGINT,
        _includeFollower in BOOLEAN,
        _animals inout jsonb
    ) AS $$
DECLARE
    _nbAnimalsOwner SMALLINT;
    _nbAnimalsFollower SMALLINT;

BEGIN
    SELECT COUNT(1) INTO _nbAnimalsOwner FROM animal where owner = _id;

    IF _includeFollower IS true THEN
        SELECT COUNT(1) INTO _nbAnimalsFollower FROM community.follower WHERE user_account_id = _id;
    ELSE
        _nbAnimalsFollower := 0;
    END IF;

    IF (_nbAnimalsFollower + _nbAnimalsOwner) > 3 THEN
        RAISE EXCEPTION 'Nb animals exceeded for user #%',_id;
    END IF;

    WITH animals as (
        SELECT id, name, 'owned' as type FROM animal WHERE owner = _id
        UNION
        SELECT animal.id as id, animal.name as name, 'followed' as type
        FROM community.follower 
        JOIN animal ON animal_id = animal.id 
        WHERE user_account_id = _id AND _includeFollower IS TRUE
    )
    SELECT jsonb_agg(jsonb_build_object('id', id, 'name', name, 'type',type))
    INTO _animals
    FROM animals;
END
$$ LANGUAGE plpgsql;
COMMIT;