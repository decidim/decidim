# Decidim - Participatory Democracy Framework

Decidim is a Ruby on Rails application with JavaScript frontend components, supporting multiple modules for participatory democracy processes. The codebase consists of multiple gem modules and requires specific setup procedures.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### System Requirements
- **CRITICAL**: Ruby **3.3.4** (NOT 3.2.3 - will fail with dependency errors)
- **CRITICAL**: Node.js **22.14.0** (NOT 20.x - specified in .node-version)
- PostgreSQL (any recent version)
- Redis server (required for background jobs)
- Build tools (installed automatically by rbenv)

### Bootstrap, Build, and Test Commands

Run these commands in sequence from the repository root:

1. **Install system dependencies:**
   ```bash
   # Install Redis and PostgreSQL
   sudo apt-get update
   sudo apt-get install -y redis-server postgresql postgresql-contrib
   sudo systemctl start redis-server
   sudo systemctl start postgresql
   
   # Create database user
   sudo -u postgres psql -c "CREATE USER runner WITH SUPERUSER CREATEDB NOCREATEROLE PASSWORD 'password';"
   
   # Set environment variables
   export DATABASE_USERNAME=runner
   export DATABASE_PASSWORD=password
   ```

2. **Install correct Ruby 3.3.4 (CRITICAL):**
   ```bash
   # Install rbenv and Ruby 3.3.4
   curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
   echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
   export PATH="$HOME/.rbenv/bin:$PATH"
   eval "$(rbenv init - bash)"
   rbenv install 3.3.4
   rbenv global 3.3.4
   rbenv rehash
   ```

3. **Install correct Node.js 22.14.0 (CRITICAL):**
   ```bash
   # Install nvm and Node.js 22.14.0
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
   nvm install 22.14.0
   nvm use 22.14.0
   ```

4. **Install Ruby dependencies (1 minute 11 seconds):**
   ```bash
   gem install bundler
   bundle install
   # Expected time: ~71 seconds
   ```

5. **Install JavaScript dependencies (1 minute 39 seconds):**
   ```bash
   npm ci
   # Expected time: ~99 seconds
   ```

6. **Create test application (3 minutes 36 seconds - NEVER CANCEL):**
   ```bash
   bundle exec rake test_app
   # Expected time: ~216 seconds - NEVER CANCEL
   # NEVER CANCEL: This build takes 3+ minutes. Set timeout to 600+ seconds.
   # Creates spec/decidim_dummy_app/ with full Rails application for testing
   ```

### Running Tests

**NEVER CANCEL TESTS** - They may take several minutes to complete.

- **Main test suite (1 minute 49 seconds - NEVER CANCEL):**
  ```bash
  bundle exec rspec
  # Expected time: ~109 seconds - NEVER CANCEL
  # Set timeout to 300+ seconds
  ```

- **JavaScript tests (13 seconds):**
  ```bash
  npm run test
  # Expected time: ~13 seconds
  # Some vendor test failures are expected (shakapacker dependencies)
  ```

- **Individual module tests:**
  ```bash
  bundle exec rake test_core        # Test decidim-core
  bundle exec rake test_admin       # Test decidim-admin
  bundle exec rake test_proposals   # Test decidim-proposals
  # Each module test can take 10-30 minutes - NEVER CANCEL
  ```

### Linting and Code Quality

- **JavaScript linting (5.9 seconds):**
  ```bash
  npm run lint
  # Expected time: ~6 seconds
  # May show warnings about React version and import paths - this is normal
  ```

- **Ruby linting (1.5 seconds):**
  ```bash
  bundle exec rubocop
  # Expected time: ~1.5 seconds
  # Use --parallel for faster execution
  # Use -a flag for auto-correction
  ```

- **ERB linting:**
  ```bash
  bundle exec erblint --lint-all --autocorrect
  ```

- **CSS/SCSS linting:**
  ```bash
  npm run stylelint
  npm run prettier     # Check formatting
  npm run prettify     # Fix formatting
  ```

## Development Workflow

### Creating a Development App

```bash
# Create development app for active development
bundle exec rake development_app
cd development_app
bin/dev  # Starts Rails server with webpack dev server
```

### Key Development Files and Locations

**Gem Structure:** Each `decidim-*` directory is a separate gem:
- `decidim-core/` - Main framework and shared components
- `decidim-admin/` - Administrative interface  
- `decidim-proposals/` - Proposal management component
- `decidim-participatory_processes/` - Process management
- `decidim-assemblies/` - Assembly management
- `decidim-meetings/` - Meeting management
- `decidim-surveys/` - Survey component
- And many more...

**Important Files:**
- `Rakefile` - Main build tasks and gem management
- `Gemfile` - Root dependency specification
- `package.json` - JavaScript dependencies and scripts
- `.github/workflows/` - CI/CD pipeline definitions
- `docs/` - Comprehensive documentation in AsciiDoc format

**JavaScript Assets:** Located in each gem's `app/packs/` directory
**Stylesheets:** Located in each gem's `app/packs/stylesheets/` directory

### Common Development Tasks

**Running the development server:**
```bash
cd development_app
bin/dev  # Starts Rails + webpack dev server
# Access at http://localhost:3000
# Admin panel: http://localhost:3000/admin (after creating admin user)
```

**Database operations:**
```bash
cd development_app
bin/rails db:create     # Create database
bin/rails db:migrate    # Run migrations  
bin/rails db:seed       # Load sample data
bin/rails db:reset      # Reset and reseed database
```

**Asset compilation:**
```bash
cd development_app
bin/rails assets:precompile
```

## Validation Scenarios

**CRITICAL**: Always test actual functionality after making changes:

### User Registration and Login Flow
```bash
cd development_app
bin/dev
# 1. Visit http://localhost:3000
# 2. Click "Sign up"
# 3. Create a new user account
# 4. Verify email confirmation process works
# 5. Log in with the new account
# 6. Navigate to user profile and edit settings
```

### Admin Panel Access
```bash
cd development_app
bin/rails console
# Create admin user:
user = Decidim::User.create!(
  email: "admin@example.org",
  password: "decidim123456",
  name: "System Admin",
  organization: Decidim::Organization.first,
  confirmed_at: Time.current,
  admin: true
)
# Visit http://localhost:3000/admin with these credentials
```

### Creating a Participatory Process
1. Log in as admin
2. Go to Admin Panel > Participatory Processes  
3. Create new process with basic information
4. Add components (proposals, meetings, surveys)
5. Publish the process
6. Test public access and participation features

## Build Pipeline Integration

**CI Requirements:** The `.github/workflows/` contain the production CI setup:
- Tests run on Ubuntu 22.04
- Requires PostgreSQL and Redis services
- Uses specific Ruby and Node versions
- Runs parallel tests across multiple modules
- **Each module CI can timeout at 30-60 minutes - NEVER CANCEL**

**Before committing, ALWAYS run:**
```bash
npm run lint      # JavaScript linting
bundle exec rubocop  # Ruby linting  
bundle exec rspec    # Main test suite - NEVER CANCEL (1m49s)
npm run test      # JavaScript tests (13s)
```

## Troubleshooting Common Issues

**Bundle install fails:** Usually Ruby version mismatch. Must use Ruby 3.3.4.

**Test app creation fails:** Check Redis and PostgreSQL are running with correct credentials.

**Asset compilation errors:** Ensure Node 22.14.0 is active and npm dependencies installed.

**Permission errors during gem installs:** Ensure rbenv is properly installed and configured. Run `rbenv rehash` after installing new gems.

**Database connection errors:** Set `DATABASE_USERNAME` and `DATABASE_PASSWORD` environment variables.

## Important Notes

- **NEVER CANCEL** builds or tests that take more than 2 minutes - builds can take 3+ minutes, full test suites 15+ minutes
- Always use the exact Ruby (3.3.4) and Node (22.14.0) versions specified
- The development app (`rake development_app`) is the primary way to create a working Decidim application for development
- Each `decidim-*` directory is an independent gem with its own tests and dependencies
- Always run full validation scenarios after making changes to ensure functionality works end-to-end
- **Changes to decidim-generator**: When making changes to `decidim-generators` that affect application configuration (files like `config/application.rb`, `config/environments/*`, etc) or other generated files, also document these changes in `RELEASE_NOTES.md`