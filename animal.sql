BEGIN;
--
CREATE TABLE animal (
    id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(50) NOT NULL,
    owner BIGINT REFERENCES user_account(id)
);
--
INSERT INTO animal (name, owner)
SELECT CASE
        firstname || lastname
        WHEN 'jeandupont' THEN 'foo'
        WHEN 'johndoe' THEN 'bar'
        ELSE 'unknown'
    END,
    id
FROM user_account;
--
INSERT INTO animal(name, owner)
values('foobar', 2);
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
SELECT 3,
    'SICK',
    NOW() - INTERVAL '1 year'
UNION
SELECT 4,
    'SICK',
    NOW() - INTERVAL '2 day'
UNION
SELECT 4,
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
    ast.status,
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
COMMIT;