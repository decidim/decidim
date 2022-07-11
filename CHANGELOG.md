# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

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

### Fixed

### Removed

## Previous versions

Please check [release/0.27-stable](https://github.com/decidim/decidim/blob/release/0.27-stable/CHANGELOG.md) for previous changes.
