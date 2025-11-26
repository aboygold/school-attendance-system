-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Schools table
CREATE TABLE schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    code TEXT UNIQUE NOT NULL,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Students table
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
    matric_number TEXT NOT NULL,
    last_name TEXT NOT NULL,
    other_names TEXT NOT NULL,
    name TEXT GENERATED ALWAYS AS (last_name || ' ' || other_names) STORED,
    faculty TEXT NOT NULL,
    department TEXT NOT NULL,
    grade TEXT NOT NULL,
    source TEXT NOT NULL,
    next_of_kin TEXT NOT NULL,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(school_id, matric_number)
);

-- Operators table
CREATE TABLE operators (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
    auth_uid UUID UNIQUE,
    name TEXT NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Attendance table
CREATE TABLE attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    matric_number TEXT NOT NULL,
    attendance_date DATE NOT NULL,
    ts TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    operator_id UUID REFERENCES operators(id) ON DELETE SET NULL,
    phone_captured TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(school_id, student_id, attendance_date)
);

-- Indexes for performance
CREATE INDEX idx_students_school_matric ON students(school_id, matric_number);
CREATE INDEX idx_attendance_school_date ON attendance(school_id, attendance_date);
CREATE INDEX idx_attendance_school_student_date ON attendance(school_id, student_id, attendance_date);
CREATE INDEX idx_attendance_operator ON attendance(operator_id);
CREATE INDEX idx_operators_school ON operators(school_id);

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

-- RLS Policies
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE operators ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- Schools: allow public access
CREATE POLICY "Schools are viewable by everyone" ON schools FOR SELECT USING (true);
CREATE POLICY "Everyone can manage schools" ON schools FOR ALL USING (true);

-- Students: allow public access for demo (no auth required)
CREATE POLICY "Students are viewable by everyone" ON students
    FOR SELECT USING (true);

CREATE POLICY "Everyone can insert students" ON students
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Everyone can update students" ON students
    FOR UPDATE USING (true);

CREATE POLICY "Everyone can delete students" ON students
    FOR DELETE USING (true);

-- Operators: allow public read access
CREATE POLICY "Operators are viewable by everyone" ON operators
    FOR SELECT USING (true);

-- Allow authenticated users to manage operators (for admin features if auth is added later)
CREATE POLICY "Authenticated users can manage operators" ON operators
    FOR ALL USING (auth.role() = 'authenticated');

-- Attendance: allow public access
CREATE POLICY "Everyone can insert attendance" ON attendance
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Everyone can update attendance" ON attendance
    FOR UPDATE USING (true);

CREATE POLICY "Everyone can view attendance" ON attendance
    FOR SELECT USING (true);

-- Realtime publication
-- Note: Enable realtime for attendance table in Supabase dashboard or via API

-- View for today's attendance count per school
CREATE VIEW today_attendance_count AS
SELECT school_id, COUNT(*) as count
FROM attendance
WHERE attendance_date = CURRENT_DATE
GROUP BY school_id;

-- View for per-operator today count
CREATE VIEW operator_today_count AS
SELECT school_id, operator_id, COUNT(*) as count
FROM attendance
WHERE attendance_date = CURRENT_DATE
GROUP BY school_id, operator_id;