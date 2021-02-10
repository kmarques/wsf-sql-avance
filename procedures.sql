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