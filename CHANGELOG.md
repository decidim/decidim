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

#### Automatically change active step in participatory processes

PR [\#9026](https://github.com/decidim/decidim/pull/9026) adds the ability to automatically change the active step of participatory processess. This is an optional behavior that system admins can enable by configuring a cron job. The frequency of the cron task should be decided by the system admin and depends on each platform's use cases. A precision of 15min is enough for most cases. An example of a crontab job may be:

```bash
*/15 * * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim_participatory_processes:change_active_step
```

Each time the job executes it checks all currently active and published participatory processes and for each, it checks the steps with the date range in the current date. If a change should be made, it deactivates the previous step and activates the next step.

Platform administrators will always have the possibility to manually change phases, although if a cron job is configured the change may be undone.

This PR also changes the Step `start_date` and `end_date`  fields to timestamps.

### Changed

#### Tailwind CSS introduction

Decidim redesign has introduced Tailwind CSS framework to compile CSS. It integrates with Webpacker,
which generates Tailwind configuration dynamically when Webpacker is invoked. More details in the PR [#9480](https://github.com/decidim/decidim/pull/9480/).

You'll need to add `tailwind.config.js` to your app `.gitignore`. If you generate a new Decidim app
from scratch, that entry will already be included in the `.gitignore`.

### Fixed

### Removed

## Previous versions

Please check [release/0.27-stable](https://github.com/decidim/decidim/blob/release/0.27-stable/CHANGELOG.md) for previous changes.
