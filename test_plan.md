# Test Plan for School Attendance System

## Overview
This test plan covers functional, performance, security, and usability testing for the school attendance web app.

## Test Environment
- Browser: Chrome 120+, Firefox 120+, Safari 17+
- Devices: Desktop, Tablet (iPad), Mobile (iPhone/Android)
- Network: Fast 3G, 4G, WiFi
- Supabase: Latest version with PostgreSQL 15+

## Functional Tests

### Authentication
- [ ] Sign up new operator
- [ ] Sign in existing operator
- [ ] Sign out
- [ ] Auto-create operator on first sign-in
- [ ] Admin access for admin users
- [ ] Non-admin cannot access admin features

### Student Lookup
- [ ] Enter valid matric number → student name appears
- [ ] Enter invalid matric number → no name appears
- [ ] Phone pre-fills from student master
- [ ] Phone editable at mark time
- [ ] Lookup completes in <200ms for 30k students

### Attendance Marking
- [ ] Mark attendance for valid student
- [ ] Prevent duplicate marks for same student same day
- [ ] Update phone number during marking
- [ ] Add notes during marking
- [ ] Keyboard navigation: Tab to matric, Enter to lookup, Tab to phone, Enter to mark
- [ ] Mark operation completes in <300ms
- [ ] Optimistic UI feedback
- [ ] Error handling for network issues

### Concurrency
- [ ] 5 operators marking simultaneously
- [ ] No race conditions or duplicates
- [ ] Atomic upsert prevents conflicts

### Import Students
- [ ] Upload CSV file with 1000+ rows
- [ ] Upload XLSX file with 1000+ rows
- [ ] Column mapping works correctly
- [ ] Batch upload (500 rows per batch)
- [ ] Progress indicator updates
- [ ] Error reporting for malformed rows
- [ ] Duplicate matric numbers handled (upsert)
- [ ] Import completes in reasonable time for 30k rows

### Realtime Counters
- [ ] Today count updates when attendance marked
- [ ] Per-operator count updates
- [ ] Realtime updates across multiple browser tabs
- [ ] Counters accurate after page refresh

### Reports & Export
- [ ] View attendance table for selected date
- [ ] Export CSV downloads correctly
- [ ] Export XLSX downloads correctly
- [ ] Exported data matches table data
- [ ] Large exports (3000+ rows) work

### Admin Features
- [ ] Add new operator
- [ ] View list of operators
- [ ] Re-run last import
- [ ] Rotate API keys (placeholder)

## Performance Tests

### Load Testing
- [ ] 30k student lookup under 200ms
- [ ] 3k daily marks without degradation
- [ ] Concurrent marking by 5 operators
- [ ] Large import (30k rows) completes in <5 minutes
- [ ] Page load time <2 seconds
- [ ] Time to interactive <3 seconds

### Stress Testing
- [ ] Network interruptions during marking
- [ ] Browser refresh during operations
- [ ] Multiple tabs open simultaneously
- [ ] Large file uploads

## Security Tests

### Authentication
- [ ] Cannot access app without sign-in
- [ ] RLS prevents unauthorized data access
- [ ] Operators can only see their own records (except admins)
- [ ] Admins can see all records

### Data Validation
- [ ] SQL injection prevented
- [ ] XSS prevented in user inputs
- [ ] File upload restrictions (CSV/XLSX only)
- [ ] Input sanitization

## Usability Tests

### Keyboard Navigation
- [ ] Full keyboard operation without mouse
- [ ] Logical tab order
- [ ] Enter key submits forms
- [ ] Escape key cancels operations

### Mobile Responsiveness
- [ ] Layout adapts to phone screen
- [ ] Touch targets appropriately sized
- [ ] Forms usable on mobile
- [ ] No horizontal scrolling

### Accessibility
- [ ] High contrast in dark theme
- [ ] Screen reader compatible
- [ ] Focus indicators visible
- [ ] Alt text for images (if any)

## Browser Compatibility
- [ ] Chrome desktop and mobile
- [ ] Firefox desktop and mobile
- [ ] Safari desktop and mobile
- [ ] Edge desktop

## Edge Cases
- [ ] Empty matric number
- [ ] Very long matric numbers
- [ ] Special characters in names/phones
- [ ] Network timeout during operations
- [ ] Supabase service outage
- [ ] Large CSV files (>10MB)
- [ ] Malformed CSV/XLSX files
- [ ] Browser back/forward navigation
- [ ] Page refresh during operations

## Automated Tests
- Unit tests for utility functions
- Integration tests for API calls
- E2E tests with Playwright/Cypress

## Test Data
- Use demo_data.sql for baseline
- Create test users in Supabase Auth
- Prepare test CSV/XLSX files with various scenarios

## Success Criteria
- All functional tests pass
- Performance meets <300ms requirement
- No security vulnerabilities
- Usable on all target devices/browsers
- Handles 30k students and 3k daily marks