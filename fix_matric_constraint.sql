-- Fix matric number constraint issue
-- Drop any old constraint that might be just on matric_number

DO $$
BEGIN
    -- Drop the old constraint if it exists (just on matric_number)
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'students_matric_number_key') THEN
        ALTER TABLE students DROP CONSTRAINT students_matric_number_key;
    END IF;

    -- Ensure the correct constraint exists (school_id, matric_number)
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'students_school_matric_unique') THEN
        ALTER TABLE students ADD CONSTRAINT students_school_matric_unique UNIQUE (school_id, matric_number);
    END IF;
END $$;