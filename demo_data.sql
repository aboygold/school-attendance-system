-- Demo data for School Attendance System
-- Run after migrations.sql

-- Sample schools
INSERT INTO schools (id, name, code, address) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'University of Lagos', 'UNILAG', 'Akoka, Lagos'),
('550e8400-e29b-41d4-a716-446655440002', 'Lagos State University', 'LASU', 'Ojo, Lagos')
ON CONFLICT (code) DO NOTHING;

-- Sample students (small set for demo)
INSERT INTO students (school_id, matric_number, last_name, other_names, faculty, department, grade, source, next_of_kin, phone) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'STU001', 'Johnson', 'Alice Mary', 'Science', 'Computer Science', '100L', 'UTME', 'John Johnson', '+1234567890'),
('550e8400-e29b-41d4-a716-446655440001', 'STU002', 'Smith', 'Bob James', 'Engineering', 'Electrical Engineering', '200L', 'Direct Entry', 'Mary Smith', '+1234567891'),
('550e8400-e29b-41d4-a716-446655440002', 'STU003', 'Brown', 'Charlie William', 'Arts', 'English Literature', '300L', 'UTME', 'Sarah Brown', '+1234567892'),
('550e8400-e29b-41d4-a716-446655440002', 'STU004', 'Prince', 'Diana Rose', 'Social Sciences', 'Psychology', '400L', 'Direct Entry', 'Charles Prince', '+1234567893'),
('550e8400-e29b-41d4-a716-446655440001', 'STU005', 'Wilson', 'Eve Elizabeth', 'Science', 'Biology', '100L', 'UTME', 'David Wilson', '+1234567894'),
('550e8400-e29b-41d4-a716-446655440001', 'STU006', 'Miller', 'Frank Thomas', 'Engineering', 'Mechanical Engineering', '200L', 'UTME', 'Anna Miller', '+1234567895'),
('550e8400-e29b-41d4-a716-446655440002', 'STU007', 'Lee', 'Grace Sophia', 'Arts', 'History', '300L', 'Direct Entry', 'Michael Lee', '+1234567896'),
('550e8400-e29b-41d4-a716-446655440002', 'STU008', 'Davis', 'Henry Oliver', 'Social Sciences', 'Sociology', '400L', 'UTME', 'Emma Davis', '+1234567897'),
('550e8400-e29b-41d4-a716-446655440001', 'STU009', 'Chen', 'Ivy Lily', 'Science', 'Chemistry', '100L', 'Direct Entry', 'Robert Chen', '+1234567898'),
('550e8400-e29b-41d4-a716-446655440001', 'STU010', 'Taylor', 'Jack Benjamin', 'Engineering', 'Civil Engineering', '200L', 'UTME', 'Lisa Taylor', '+1234567899')
ON CONFLICT (school_id, matric_number) DO NOTHING;
('STU001', 'Johnson', 'Alice Mary', 'Science', 'Computer Science', '100L', 'UTME', 'John Johnson', '+1234567890'),
('STU002', 'Smith', 'Bob James', 'Engineering', 'Electrical Engineering', '200L', 'Direct Entry', 'Mary Smith', '+1234567891'),
('STU003', 'Brown', 'Charlie William', 'Arts', 'English Literature', '300L', 'UTME', 'Sarah Brown', '+1234567892'),
('STU004', 'Prince', 'Diana Rose', 'Social Sciences', 'Psychology', '400L', 'Direct Entry', 'Charles Prince', '+1234567893'),
('STU005', 'Wilson', 'Eve Elizabeth', 'Science', 'Biology', '100L', 'UTME', 'David Wilson', '+1234567894'),
('STU006', 'Miller', 'Frank Thomas', 'Engineering', 'Mechanical Engineering', '200L', 'UTME', 'Anna Miller', '+1234567895'),
('STU007', 'Lee', 'Grace Sophia', 'Arts', 'History', '300L', 'Direct Entry', 'Michael Lee', '+1234567896'),
('STU008', 'Davis', 'Henry Oliver', 'Social Sciences', 'Sociology', '400L', 'UTME', 'Emma Davis', '+1234567897'),
('STU009', 'Chen', 'Ivy Lily', 'Science', 'Chemistry', '100L', 'Direct Entry', 'Robert Chen', '+1234567898'),
('STU010', 'Taylor', 'Jack Benjamin', 'Engineering', 'Civil Engineering', '200L', 'UTME', 'Lisa Taylor', '+1234567899')
ON CONFLICT (matric_number) DO NOTHING;

-- Sample operators
-- Default operator for no-auth mode
INSERT INTO operators (id, school_id, auth_uid, name, is_admin) VALUES
('00000000-0000-0000-0000-000000000001', '550e8400-e29b-41d4-a716-446655440001', '00000000-0000-0000-0000-000000000000', 'SOLUSCIPHER', true),
('00000000-0000-0000-0000-000000000002', '550e8400-e29b-41d4-a716-446655440001', '00000000-0000-0000-0000-000000000001', 'Admin User', true),
('00000000-0000-0000-0000-000000000003', '550e8400-e29b-41d4-a716-446655440001', '00000000-0000-0000-0000-000000000002', 'Operator 1', false),
('00000000-0000-0000-0000-000000000004', '550e8400-e29b-41d4-a716-446655440002', '00000000-0000-0000-0000-000000000003', 'Operator 2', false)
ON CONFLICT (auth_uid) DO NOTHING;

-- Sample attendance data for today
INSERT INTO attendance (school_id, student_id, matric_number, attendance_date, operator_id, phone_captured, notes)
SELECT
    s.school_id,
    s.id,
    s.matric_number,
    CURRENT_DATE,
    o.id,
    s.phone,
    'Demo attendance'
FROM students s
CROSS JOIN (SELECT id FROM operators WHERE is_admin = false LIMIT 1) o
WHERE s.matric_number IN ('STU001', 'STU002', 'STU003')
ON CONFLICT (school_id, student_id, attendance_date) DO NOTHING;

-- Sample attendance data for yesterday
INSERT INTO attendance (school_id, student_id, matric_number, attendance_date, operator_id, phone_captured, notes)
SELECT
    s.school_id,
    s.id,
    s.matric_number,
    CURRENT_DATE - INTERVAL '1 day',
    o.id,
    s.phone,
    'Demo attendance yesterday'
FROM students s
CROSS JOIN (SELECT id FROM operators WHERE is_admin = false LIMIT 1) o
WHERE s.matric_number IN ('STU004', 'STU005')
ON CONFLICT (school_id, student_id, attendance_date) DO NOTHING;