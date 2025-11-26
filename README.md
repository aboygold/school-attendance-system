# School Attendance System

A fast, dark-theme, mobile-responsive, keyboard-first HTML web app for marking student attendance using Supabase backend.

## Features

- **Keyboard-first design**: Tab through fields, Enter to submit
- **Mobile-responsive**: Works on phone, tablet, desktop
- **Dark theme**: Modern UI with CSS variables
- **Realtime counters**: Live updates of attendance counts
- **Atomic operations**: Prevents duplicate marks per student per day
- **Concurrent safe**: Supports up to 5 operators marking simultaneously
- **Fast lookup**: Server-side search for 30k+ students
- **Batch import**: Upload CSV/XLSX files with column mapping
- **Export reports**: CSV and XLSX downloads
- **Admin panel**: Manage operators, re-import data, rotate keys

## Setup

1. Create a Supabase project at https://supabase.com
2. Run the SQL migrations from `migrations.sql` in your Supabase SQL editor
3. Update the Supabase URL and anon key in `index.html`:
   ```javascript
   const SUPABASE_URL = 'your-project-url';
   const SUPABASE_ANON_KEY = 'your-anon-key';
   ```
4. Enable Row Level Security and Realtime for the `attendance` table in Supabase dashboard
5. Deploy `index.html` to static hosting (Netlify, Vercel, etc.)

## Usage

### Authentication
- Operators sign in via Supabase Auth (email/password or OAuth)
- First sign-in auto-creates operator record
- Admins can be set via database

### Marking Attendance
1. Enter matric number (autofocus)
2. Student name auto-fills if found
3. Edit phone if needed
4. Press Enter in phone field or click "Mark Attendance"
5. Operation completes in <300ms

### Importing Students
1. Upload CSV or XLSX file
2. Map columns for matric, name, phone
3. Batch upload in chunks of 500-1000 rows
4. View import status and errors

### Reports
- Select date and view attendance table
- Export as CSV or XLSX

### Admin Features
- Add/manage operators
- Re-run imports
- Rotate API keys

## Performance

- Handles 30k+ student lookups
- 3k+ daily captures
- <300ms response time
- Realtime updates via Supabase

## Tech Stack

- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **Libraries**: Supabase JS, SheetJS (XLSX)

## Database Schema

- `students`: matric_number (unique), name, phone
- `operators`: auth_uid (unique), name, is_admin
- `attendance`: student_id, matric_number, attendance_date, ts, operator_id, phone_captured, notes
- Unique constraint: (student_id, attendance_date)
- RPC function: `mark_attendance` for atomic upsert

## Security

- Row Level Security enabled
- Authenticated users only
- Operators can only mark their own attendance records
- Admins have full access

## Deployment

The app is a single `index.html` file that can be deployed to any static hosting service. No build process required.

## Demo Data

See `demo_data.sql` for sample students and operators.

## Testing

See `test_plan.md` for testing procedures.