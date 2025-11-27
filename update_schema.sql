-- Migration to add school_id to existing tables

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create schools table if it doesn't exist
CREATE TABLE IF NOT EXISTS schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    code TEXT UNIQUE NOT NULL,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default school first
INSERT INTO schools (id, name, code, address) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'University of Lagos', 'UNILAG', 'Akoka, Lagos')
ON CONFLICT (code) DO NOTHING;

-- Add school_id to existing tables if not present
ALTER TABLE students ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id) ON DELETE CASCADE;
ALTER TABLE operators ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id) ON DELETE CASCADE;
ALTER TABLE operators ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id) ON DELETE CASCADE;

-- Update existing students to have school_id (assuming default school)
UPDATE students SET school_id = '550e8400-e29b-41d4-a716-446655440001' WHERE school_id IS NULL;

-- Update existing operators to have school_id
UPDATE operators SET school_id = '550e8400-e29b-41d4-a716-446655440001' WHERE school_id IS NULL;

-- Update existing attendance to have school_id
UPDATE attendance SET school_id = '550e8400-e29b-41d4-a716-446655440001' WHERE school_id IS NULL;

-- Drop and recreate the function to ensure correct signature
DROP FUNCTION IF EXISTS mark_attendance(UUID, TEXT, DATE, UUID, TEXT, TEXT);

-- Function for atomic attendance upsert
CREATE OR REPLACE FUNCTION mark_attendance(
    p_school_id UUID,
    p_matric TEXT,
    p_date DATE,
    p_operator_id UUID,
    p_phone TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_student_id UUID;
    v_attendance_id UUID;
BEGIN
    -- Get student_id
    SELECT id INTO v_student_id FROM students WHERE school_id = p_school_id AND matric_number = p_matric;
    IF v_student_id IS NULL THEN
        RAISE EXCEPTION 'Student with matric % not found in school', p_matric;
    END IF;

    -- Upsert attendance
    INSERT INTO attendance (school_id, student_id, matric_number, attendance_date, operator_id, phone_captured, notes)
    VALUES (p_school_id, v_student_id, p_matric, p_date, p_operator_id, p_phone, p_notes)
    ON CONFLICT (school_id, student_id, attendance_date)
    DO UPDATE SET
        ts = NOW(),
        operator_id = EXCLUDED.operator_id,
        phone_captured = COALESCE(EXCLUDED.phone_captured, attendance.phone_captured),
        notes = COALESCE(EXCLUDED.notes, attendance.notes)
    RETURNING id INTO v_attendance_id;

    RETURN v_attendance_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add unique constraints if not present
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'students_school_matric_unique') THEN
        ALTER TABLE students ADD CONSTRAINT students_school_matric_unique UNIQUE (school_id, matric_number);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'attendance_school_student_date_unique') THEN
        ALTER TABLE attendance ADD CONSTRAINT attendance_school_student_date_unique UNIQUE (school_id, student_id, attendance_date);
    END IF;
END $$;