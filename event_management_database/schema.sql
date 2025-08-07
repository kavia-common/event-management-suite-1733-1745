-- ========================================================================================
-- Event Management System - PostgreSQL Schema
-- This schema covers core entities and relationships:
-- - users:         Authentication and event participation
-- - events:        Details of events (CRUD)
-- - registrations: Join table connecting users <-> events with role and status info
-- - event_categories (optional): Categorize events
-- - user_profiles (optional): Store extended user info
-- Fully defined with primary, foreign keys, constraints, and helpful indexes.
-- ========================================================================================

-- =========================
-- 1. USERS
-- =========================
CREATE TABLE IF NOT EXISTS users (
    id              SERIAL PRIMARY KEY,
    username        VARCHAR(50) UNIQUE NOT NULL,
    email           VARCHAR(320) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    is_admin        BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email CHECK (position('@' IN email) > 1)
);

COMMENT ON TABLE users IS 'Platform user accounts for authentication and attendance';
COMMENT ON COLUMN users.password_hash IS 'Hashed password using a secure algorithm';

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- =========================
-- 2. EVENT_CATEGORIES (optional)
-- =========================
CREATE TABLE IF NOT EXISTS event_categories (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT
);

COMMENT ON TABLE event_categories IS 'Categories to classify events (e.g., Conference, Workshop)';

-- =========================
-- 3. EVENTS
-- =========================
CREATE TABLE IF NOT EXISTS events (
    id                  SERIAL PRIMARY KEY,
    creator_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title               VARCHAR(200) NOT NULL,
    description         TEXT,
    location            VARCHAR(250),
    start_time          TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time            TIMESTAMP WITH TIME ZONE NOT NULL,
    capacity            INTEGER CHECK (capacity > 0),
    category_id         INTEGER REFERENCES event_categories(id),
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE events IS 'Scheduled events, owned by a user';
COMMENT ON COLUMN events.creator_id IS 'The user who created/owns the event';

CREATE INDEX IF NOT EXISTS idx_events_start_time ON events(start_time);
CREATE INDEX IF NOT EXISTS idx_events_category_id ON events(category_id);

-- =========================
-- 4. REGISTRATIONS (User <-> Event)
-- =========================
CREATE TABLE IF NOT EXISTS registrations (
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id        INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    registration_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status VARCHAR(20) NOT NULL DEFAULT 'registered', -- registered, attended, cancelled
    role            VARCHAR(30) DEFAULT 'attendee', -- attendee, organizer, speaker, etc.
    UNIQUE (user_id, event_id)
);

COMMENT ON TABLE registrations IS 'Enrollment of a user in an event, with status/roles';
CREATE INDEX IF NOT EXISTS idx_registrations_event_id ON registrations(event_id);
CREATE INDEX IF NOT EXISTS idx_registrations_user_id ON registrations(user_id);

-- =========================
-- 5. USER_PROFILES (optional)
-- =========================
CREATE TABLE IF NOT EXISTS user_profiles (
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    full_name       VARCHAR(150),
    bio             TEXT,
    avatar_url      VARCHAR(255),
    phone           VARCHAR(20),
    -- Add custom profile fields as required
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE user_profiles IS 'Additional profile data for users';

-- =========================
-- 6. TRIGGERS / UPDATED_AT management
-- =========================
-- Simple trigger to update 'updated_at' on row update for core tables

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_timestamp_users ON users;
CREATE TRIGGER set_timestamp_users
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE PROCEDURE trigger_set_timestamp();

DROP TRIGGER IF EXISTS set_timestamp_events ON events;
CREATE TRIGGER set_timestamp_events
    BEFORE UPDATE ON events
    FOR EACH ROW
    EXECUTE PROCEDURE trigger_set_timestamp();

-- =========================
-- 7. SEED DATA (OPTIONAL) - can be commented
-- =========================
-- INSERT INTO event_categories (name, description) VALUES ('Conference','Multi-session conference'), ('Workshop','Hand-on workshop'), ('Meetup','Casual gathering');

-- ============================================
-- End of schema.sql
-- ============================================
