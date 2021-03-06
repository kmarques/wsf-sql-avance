BEGIN;
--
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
UPDATE user_account
SET email_confirmed = true;
--
CREATE TABLE user_config (
    user_id BIGINT REFERENCES user_account(id),
    tos_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    newsletter_accepted BOOLEAN NOT NULL DEFAULT FALSE
);
--
COMMIT;