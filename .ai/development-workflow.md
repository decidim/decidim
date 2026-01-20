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
bin/rails db:drop       # Drop database
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

## Data Migrations (data-migrate)

Decidim uses the `data-migrate` gem for data changes that should not live in schema migrations (e.g. backfilling data, transforming existing records, one-off fixes).

Use data migrations when:

- Modifying existing data
- Backfilling new columns
- Migrating values between columns or tables
- Fixing production data inconsistencies

Do **not** use schema migrations for these cases.

### Creating a Data Migration

From the appropriate decidim-* module:

```bash
cd decidim-<module> bin/rails generate data_migration BackfillSomething
```

This creates a file under:

```text
decidim-<module>/
└── db/
    └── data/
        └── YYYYMMDDHHMMSS_backfill_something.rb
```

### Running Data Migrations

In a development or test app:

```bash
bin/rails data:migrate
```

To check status:

```bash
bin/rails data:migrate:status
```

### Data Migration Best Practices

- Never reference application models directly.
- Define a minimal ActiveRecord::Base class inside the migration.
- Always pin the table name to avoid breakage if models change:

```ruby
class LegacyProposal < ActiveRecord::Base
  self.table_name = "decidim_proposals_proposals"
end
```

- Avoid callbacks, validations, and scopes.
- Make migrations idempotent (safe to re-run).
- Prefer find_each for large datasets.
- Keep data migrations small and focused.

### Example Pattern

```ruby
class BackfillPublishedAt < ActiveRecord::Migration[6.1]
  class Proposal < ActiveRecord::Base
    self.table_name = "decidim_proposals_proposals"
  end

  def up
    Proposal.where(published_at: nil).find_each do |proposal|
      proposal.update_column(:published_at, proposal.created_at)
    end
  end

  def down
    # no-op (data migrations are usually irreversible)
  end
end
```

### When in Doubt

- Schema change? → regular migration
- Data change? → data-migrate
