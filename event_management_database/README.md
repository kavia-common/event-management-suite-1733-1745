# Event Management Database (PostgreSQL)

## Overview

This directory configures the core PostgreSQL schema for the Event Management Suite, covering these entities:

- users:         User accounts with authentication support
- events:        Event creation, editing, and listing
- registrations: Tracks who is attending what event (with roles/status fields)
- event_categories (optional): Categories to classify events (conference, workshop, etc.)
- user_profiles (optional): Extra profile information for users

## Usage

1. **Start PostgreSQL**
   - Use the provided `startup.sh` to initialize the database and user (default port 5000).
   - Connection info will be saved in `db_connection.txt`.

2. **Create the Schema**
   - Connect to the database using the following command (or use details from `db_connection.txt`):
     ```
     psql postgresql://appuser:dbuser123@localhost:5000/myapp
     ```
   - Then run:
     ```
     \i schema.sql
     ```
   - or from shell:
     ```
     psql postgresql://appuser:dbuser123@localhost:5000/myapp -f schema.sql
     ```

3. **Optional**
   - Load demo event categories or add test data if desired (see commented seed section in `schema.sql`).

## Schema Structure

- `users`: Authentication, registration
- `events`: Each event, linked to the creator (user)
- `registrations`: Each user's registration/attendance at a specific event (with roles/status)
- `event_categories`: Names/descriptions for organizing events
- `user_profiles`: Extra user info; extend as needed

## Indices/Performance

- Indexed on user email, event start_time/category, and registrant lookups for performance.

## Extending

- Modify/extend `schema.sql` for additional fields, e.g. ticketing, files, custom event types, etc.

## Environment Variables

See `db_visualizer/postgres.env` for environment variable details for connecting applications.

---

For questions regarding schema design or migrations, consult the backend developer or database administrator.

