# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

#### 1.1. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

#### 1.2. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
```

#### 1.3. Follow the steps and commands detailed in these notes

### 2. General notes

### 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

#### 3.1. [[TITLE OF THE ACTION]]

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/XXXX).

### 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
 with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

#### 4.1. [[TITLE OF THE TASK]]

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rails decidim:TASK
```

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/XXXX).

### 5. Changes in APIs

### Added

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.27-stable](https://github.com/decidim/decidim/blob/release/0.27-stable/CHANGELOG.md) for previous changes.
