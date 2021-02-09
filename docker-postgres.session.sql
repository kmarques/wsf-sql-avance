CREATE TABLE public.user_account (
    id BIGINT NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    address TEXT,
    email_confirmed BOOLEAN NOT NULL DEFAULT false,
    creation_date TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE SEQUENCE public.user_account_id_seq START WITH 1 INCREMENT BY 1;
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
    );