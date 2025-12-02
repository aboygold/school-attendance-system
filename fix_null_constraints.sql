-- Allow nullable fields for flexible importing
-- Users can fill in missing fields when marking attendance

ALTER TABLE students ALTER COLUMN faculty DROP NOT NULL;
ALTER TABLE students ALTER COLUMN department DROP NOT NULL;
ALTER TABLE students ALTER COLUMN grade DROP NOT NULL;
ALTER TABLE students ALTER COLUMN source DROP NOT NULL;
ALTER TABLE students ALTER COLUMN next_of_kin DROP NOT NULL;

-- Update existing records that have empty strings to NULL for consistency
UPDATE students SET faculty = NULL WHERE faculty = '';
UPDATE students SET department = NULL WHERE department = '';
UPDATE students SET grade = NULL WHERE grade = '';
UPDATE students SET source = NULL WHERE source = '';
UPDATE students SET next_of_kin = NULL WHERE next_of_kin = '';