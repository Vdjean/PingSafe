# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PingSafe is a Rails 7.1 application built using the Le Wagon template. It's a location-based social application with a gamification system where users can send "pings" with geolocation data, earn rewards, and level up.

## Development Commands

### Server
```bash
bin/rails server       # Start development server (default: http://localhost:3000)
```

### Database
```bash
bin/rails db:create    # Create the database
bin/rails db:migrate   # Run pending migrations
bin/rails db:seed      # Seed the database
bin/rails db:reset     # Drop, create, migrate, and seed database
```

### Testing
```bash
bin/rails test                           # Run all tests
bin/rails test test/models/user_test.rb  # Run specific test file
bin/rails test:system                    # Run system tests (requires Chrome/Selenium)
```

### Code Quality
```bash
bundle exec rubocop                      # Run linter
bundle exec rubocop -a                   # Auto-fix linting issues
```

### Console
```bash
bin/rails console      # Open Rails console for debugging
```

## Database Architecture

The application uses PostgreSQL with the following core models:

### User System
- **User**: Core user entity with `first_name`, `last_name`, `pseudo`, `password`, `phone`, `score`
  - Currently stores plain text passwords (needs bcrypt implementation)

### Gamification System
- **Level**: Defines experience levels with `points` threshold
  - Has validations: points must be present, >= 0, and unique
  - Connected to users through `user_levels` join table

- **UserLevel**: Join table linking users to levels with `level_name`

- **Reward**: Reward types (using STI with `type` column)

- **UserReward**: Join table linking users to their earned rewards

### Location & Social Features
- **Ping**: Location check-ins with `date`, `time`, `comment`, `photo`, `latitude`, `longitude`
  - Belongs to a user
  - Has associated chats

- **Chat**: Conversations associated with pings
  - Belongs to a ping
  - Has many messages

- **Message**: Individual chat messages with `content`
  - Belongs to a chat

### Important Note on Foreign Keys
The schema uses non-standard foreign key naming (e.g., `users_id` instead of `user_id`). This affects model associations - always use the full column name when defining `belongs_to` relationships:
```ruby
belongs_to :users  # Not :user
```

## Frontend Stack

- **CSS Framework**: Bootstrap 5.3 with Font Awesome icons
- **Forms**: SimpleForm gem for form helpers
- **JavaScript**: Hotwire (Turbo + Stimulus) with importmap
- **SCSS**: Using sassc-rails with autoprefixer

## Code Style

RuboCop is configured with relaxed rules (see `.rubocop.yml`):
- Line length limit: 120 characters
- Documentation, string literal styles, and many metrics are disabled
- Test files are excluded from linting

## Current Work Context

The `crud_ping` branch is currently active, with recent work on:
- Creating the Pings controller (`app/controllers/pings_controller.rb`)
- Adding controller tests (`test/controllers/pings_controller_test.rb`)
- Schema modifications

The main branch is `master` (not `main`).
