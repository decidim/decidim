# Documentation

We have comprehensive documentation in `docs/` using AsciiDoc format. When making changes, check if related documentation needs updating.

## When to Read Which Docs

### `docs/modules/install/` - Installation Guide

**Read when:** Setting up Decidim, troubleshooting installation, updating versions, deploying to production.

| File                  | Content                                               |
|-----------------------|-------------------------------------------------------|
| `index.adoc`          | Overview, creating apps, scheduled tasks, seed data   |
| `manual.adoc`         | Step-by-step installation (Ruby, PostgreSQL, Node.js) |
| `checklist.adoc`      | Production deployment checklist                       |
| `update.adoc`         | Updating Decidim versions, compatibility matrix       |
| `empty-database.adoc` | Setup without seed data                               |

### `docs/modules/develop/` - Developer Guide

**Read when:** Developing features, understanding architecture, writing tests, contributing to core.

| File                         | Content                                            |
|------------------------------|----------------------------------------------------|
| `guide.adoc`                 | Entry point for development                        |
| `guide_architecture.adoc`    | C4 diagrams, system architecture                   |
| `guide_conventions.adoc`     | GitFlow, branch naming, commit messages            |
| `modules.adoc`               | Creating external modules                          |
| `components.adoc`            | Creating components (manifests, settings, exports) |
| `testing.adoc`               | RSpec, Jest, parallel testing                      |
| `permissions.adoc`           | Permission system, adding actions                  |
| `notifications.adoc`         | Events, email/notification generation              |
| `content_blocks.adoc`        | Registering content blocks                         |
| `api.adoc`                   | GraphQL API                                        |
| `view_models_aka_cells.adoc` | Cells pattern                                      |

**`docs/modules/develop/pages/classes/`** - Class patterns:

| File               | Pattern                                         |
|--------------------|-------------------------------------------------|
| `commands.adoc`    | Command pattern (Create/Update/DestroyResource) |
| `forms.adoc`       | Form objects (Decidim::Form)                    |
| `cells.adoc`       | View components (Decidim::ViewModel)            |
| `events.adoc`      | Event classes for notifications                 |
| `permissions.adoc` | Permission classes                              |
| `queries.adoc`     | Query objects                                   |
| `presenters.adoc`  | ResourcePresenter, AdminLogPresenter            |
| `jobs.adoc`        | ActiveJob background jobs                       |
| `mailers.adoc`     | Mailers with locale handling                    |
| `controllers.adoc` | Controller patterns                             |
| `models.adoc`      | ActiveRecord models and concerns                |

### `docs/modules/configure/` - Configuration Guide

**Read when:** Configuring Decidim options, environment variables, system panel.

| File                         | Content                                  |
|------------------------------|------------------------------------------|
| `index.adoc`                 | Configuration overview, CLI flags        |
| `initializer.adoc`           | All Decidim.configure options            |
| `system.adoc`                | System panel, multi-tenant organizations |
| `environment_variables.adoc` | Environment variable reference           |

### `docs/modules/services/` - External Services

**Read when:** Integrating maps, email, storage, or other external services.

| File                     | Content                               |
|--------------------------|---------------------------------------|
| `activejob.adoc`         | Background jobs (Sidekiq, DelayedJob) |
| `activestorage.adoc`     | File storage (S3, GCS, Azure)         |
| `maps.adoc`              | Maps/geocoding (HERE Maps, OSM)       |
| `smtp.adoc`              | Email server configuration            |
| `sms.adoc`               | SMS gateway for verification          |
| `social_providers.adoc`  | OAuth providers                       |
| `etherpad.adoc`          | Real-time collaborative editing       |
| `aitools.adoc`           | AI tools integration                  |

### `docs/modules/customize/` - Customization Guide

**Read when:** Customizing appearance, overriding behavior, extending functionality.

| File                 | Content                                           |
|----------------------|---------------------------------------------------|
| `code.adoc`          | Monkey patching, decorators, modules              |
| `views.adoc`         | Overriding views (filename method, Deface, cells) |
| `styles.adoc`        | CSS (Tailwind, SCSS, organization colors)         |
| `javascript.adoc`    | Custom JavaScript                                 |
| `authorizations.adoc`| Custom verification handlers                      |
| `menu.adoc`          | Navigation menu customization                     |
| `localization.adoc`  | Translations                                      |

## Quick Reference by Task

| Task                         | Read                                                                 |
|------------------------------|----------------------------------------------------------------------|
| Creating a new command       | `develop/pages/classes/commands.adoc`                                |
| Creating a new form          | `develop/pages/classes/forms.adoc`                                   |
| Adding a new cell            | `develop/pages/classes/cells.adoc`                                   |
| Adding notifications/events  | `develop/notifications.adoc`, `develop/pages/classes/events.adoc`    |
| Adding permissions           | `develop/permissions.adoc`, `develop/pages/classes/permissions.adoc` |
| Creating a module            | `develop/modules.adoc`                                               |
| Creating a component         | `develop/components.adoc`                                            |
| Overriding views             | `customize/views.adoc`                                               |
| Customizing styles           | `customize/styles.adoc`                                              |
| Running tests                | `develop/testing.adoc`                                               |
| Configuring maps             | `services/maps.adoc`                                                 |
| Configuring storage          | `services/activestorage.adoc`                                        |
| Production deployment        | `install/checklist.adoc`                                             |
