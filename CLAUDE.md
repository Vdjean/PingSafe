# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PingSafe is a Rails 7.1.6 safety application that allows users to create location-based "pings" with chat functionality and an AI-powered safety system. Users can report their location, receive safety analysis about nearby dangerous sites, and interact with an AI assistant about their pings. The app includes a gamification system with levels and rewards.

**Tech Stack:**
- Ruby 3.3.5
- Rails 7.1.6
- PostgreSQL database
- Hotwire (Turbo + Stimulus)
- Bootstrap 5.3
- Devise for authentication
- RubyLLM gem (v1.2.0) integrated with Azure AI

## Core Data Model

The application is structured around these key relationships:

- **User** (via Devise): has many pings, levels (through user_levels), and rewards (through user_rewards)
- **Ping**: belongs to user, has one chat. Stores location data (latitude/longitude), timestamp (date/heure), photo, and comment
- **Chat**: belongs to ping, has many messages. Created when user interacts with AI about a ping
- **Message**: belongs to chat. Stores conversation content
- **Level/UserLevel**: Gamification - tracks user progression with points
- **Reward/UserReward**: Tracks rewards earned by users

## AI/LLM Integration

The app uses RubyLLM configured to connect to Azure AI:
- Configuration: `config/initializers/ruby_llm.rb`
- API key stored in ENV["GITHUB_TOKEN"] (points to Azure endpoint)
- Two main AI prompts in `app/controllers/messages_controller.rb`:
  - `SYSTEM_PROMPT_PICTURE`: Blurs faces in photos while preserving image quality
  - `SYSTEM_PROMPT_LOCALISATION`: Analyzes GPS coordinates to identify 5 potentially dangerous sites within 500m radius, returning JSON with site name, distance, risk type, and danger level

## Key Routes

```ruby
root to: "pages#home"

devise_for :users

resources :pings, only: [:create, :index, :show] do
  resources :chats, only: :create do
    resources :messages, only: :create
  end
  resources :levels, only: [:index, :show]
  resources :rewards, only: [:index, :show]
end
```

## Common Development Commands

### Setup
```bash
# Initial setup (includes bundle install, db creation, migrations)
bin/setup

# Install dependencies
bundle install

# Database setup
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### Running the App
```bash
# Start Rails server (defaults to port 3000)
bin/rails server
# or
bin/rails s
```

### Database
```bash
# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Reset database (drop, create, migrate, seed)
bin/rails db:reset

# Check migration status
bin/rails db:migrate:status
```

### Console
```bash
# Rails console
bin/rails console
# or
bin/rails c
```

### Testing
```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/user_test.rb

# Run tests with verbose output
bin/rails test -v

# System tests (includes Capybara/Selenium)
bin/rails test:system
```

### Linting
```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-correct offenses
bundle exec rubocop -a

# Auto-correct including unsafe corrections
bundle exec rubocop -A
```

## Architecture Notes

### Controllers Structure
- Standard CRUD controllers for pings, chats, messages, levels, and rewards
- MessagesController contains AI prompt constants and will handle LLM interactions
- PagesController serves static pages (home)

### Services Directory
Two service placeholders exist but are currently empty:
- `app/services/blurred_photo_generator_service.rb`
- `app/services/danger_sites_generator_service.rb`

These likely intended to encapsulate the LLM functionality from MessagesController.

### Frontend
- Uses Hotwire (Turbo + Stimulus) for SPA-like interactions without heavy JavaScript
- Stimulus controllers in `app/javascript/controllers/`:
  - `map_footer_controller.js` - handles map interactions
  - `hello_controller.js` - example controller
- Bootstrap 5.3 for styling with Sass customization
- Asset pipeline via Sprockets and Importmap

### Schema Issues
The schema.rb shows duplicate table definitions for `levels` and `user_levels` tables (lines 24-34 and 73-81), which indicates potential migration conflicts that may need resolution.

## Environment Variables

Required environment variables (set in `.env` for development):
- `GITHUB_TOKEN`: Used as OpenAI API key for Azure AI endpoint
- `PING_SAFE_DATABASE_PASSWORD`: PostgreSQL password for production

## Testing Strategy

Uses standard Rails minitest framework with:
- Model tests in `test/models/`
- Controller tests in `test/controllers/`
- System tests in `test/system/` (Capybara + Selenium)
- Test fixtures in `test/fixtures/`

## Docker Support

Dockerfile present for containerized deployment. Use `bin/docker-entrypoint` for container initialization.

## Code Style

RuboCop configured with relaxed rules:
- Max line length: 120 characters
- Documentation, ABC size metrics, and cyclomatic complexity checks disabled
- String literals style enforcement disabled
- Excludes: bin/, db/, config/, node_modules/, test/
