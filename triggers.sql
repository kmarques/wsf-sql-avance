BEGIN;
-- CREATE FUNCTION FOR TRIGGER
CREATE OR REPLACE FUNCTION triggerCheckAnimals()
RETURNS trigger AS
$$
DECLARE
    _animals jsonb;
BEGIN
    _animals := '[]'::jsonb;
    CALL checkAnimals(NEW.owner, true, _animals);
    RETURN NEW;
END
$$
LANGUAGE 'plpgsql';
-- CREATE TRIGGER
CREATE TRIGGER checkAnimals
AFTER UPDATE OR INSERT ON animal
FOR EACH ROW
EXECUTE FUNCTION triggerCheckAnimals();
--
COMMIT;