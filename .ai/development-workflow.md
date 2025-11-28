# Development Workflow

## Creating a Development App

As decidim is a gem, we need to create a rails application to test it. That's why we have the `development_app`. When you generate it, you create a rails application with the decidim gem using the local files. You only need to generate it once. So if the directory already exists you don't need to generate it again unless a reset is required.

You should not change anything inside this development app as it's a local directory that won't be persisted.

```bash
# Install dependencies first (if not already done)
bundle install
npm install

# Create development app for active development
bundle exec rake development_app
cd development_app
bin/dev  # Starts Rails server with webpack dev server
```

## Key Development Files and Locations

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

## Common Development Tasks

Running the development server:

```bash
cd development_app
bin/dev  # Starts Rails + webpack dev server
# Access at http://localhost:3000
# Admin panel: http://localhost:3000/admin (after creating admin user)
```

Database operations:

```bash
cd development_app
bin/rails db:create     # Create database
bin/rails db:migrate    # Run migrations
bin/rails db:seed       # Load sample data
bin/rails db:reset      # Reset and reseed database
```

Asset compilation:

```bash
cd development_app
bin/rails assets:precompile
```

## Database Migrations

When creating new features that require database changes, migrations belong in the appropriate `decidim-*` module, not in the development app.

### Creating a Migration

```bash
cd decidim-<module>
bin/rails generate migration AddFieldToTableName field_name:type
```

### Migration File Location

Migrations are stored in each gem's `db/migrate/` directory:

```text
decidim-<module>/
└── db/
    └── migrate/
        └── YYYYMMDDHHMMSS_migration_name.rb
```

### Applying Migrations

After creating a migration, regenerate the development or test app to apply it:

```bash
# For development
bundle exec rake development_app

# For testing
bundle exec rake test_app
```

Or apply migrations directly in an existing app:

```bash
cd development_app  # or spec/decidim_dummy_app
bin/rails decidim:upgrade
bin/rails db:migrate
```

### Migration Best Practices

- Use reversible migrations when possible
- Add indexes for foreign keys and frequently queried columns
- Use `change_column_null` with a default value for non-nullable columns
- Test migrations in both directions: `bin/rails db:migrate` and `bin/rails db:rollback`
