# Release Notes

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.2. Run these commands

```console
sudo apt install p7zip # or the alternative installation process for your operating system. See "2.1. 7zip dependency introduction"
bundle remove spring spring-watcher-listen
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails decidim:upgrade:clean:invalid_records
```

### 1.3. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. 7zip dependency introduction

We had to migrate from an unmaintained dependency and do a wrapper for the 7zip command line. This means that you need to install 7zip in your system. You can do it by running:

```bash
sudo apt install p7zip
```

This works for Ubuntu Linux, other operating systems would need to do other command/package.

You can read more about this change on PR [#13185](https://github.com/decidim/decidim/pull/13185).

### 2.2. Cleanup invalid resources

While upgrading various instances to latest Decidim version, we have noticed there are some records that may not be present anymore. As a result, the application would generate a lot of errors, in both frontend and Backend.

In order to fix these errors, we have introduced a new rake task, aiming to fix the errors by removing invalid data.

In your console you can run:

```bash
bin/rails decidim:upgrade:clean:invalid_records
```

If you have a big installation having multiple records, many users etc, you can split the clean up task as follows:

```bash
bin/rails decidim:upgrade:clean:searchable_resources
bin/rails decidim:upgrade:clean:notifications
bin/rails decidim:upgrade:clean:follows
bin/rails decidim:upgrade:clean:action_logs
```

You can read more about this change on PR [#13237](https://github.com/decidim/decidim/pull/13237).

### 2.3. Refactor of `decidim:upgrade:fix_orphan_categorizations` task

As of [#13380](https://github.com/decidim/decidim/pull/13380), the task named `decidim:upgrade:fix_orphan_categorizations` has been renamed to `decidim:upgrade:clean:categories` and has been included in the main `decidim:upgrade:clean:invalid_records` task.

You can read more about this change on PR [#13380](https://github.com/decidim/decidim/pull/13380).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Remove spring and spring-watcher-listen from your Gemfile

To simplify the upgrade process, we have decided to add `spring` and `spring-watcher-listener` as hard dependencies of `decidim-dev`.

Before upgrading to this version, make sure you run in your console:

```bash
bundle remove spring spring-watcher-listen
```

You can read more about this change on PR [#13235](https://github.com/decidim/decidim/pull/13235).

### 3.2. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. [[TITLE OF THE TASK]]

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rails decidim:TASK
```

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 5. Changes in APIs

### 5.1. Decidim version number no longer disclosed through the GraphQL API by default

In previous Decidim versions, you could request the running Decidim version through the following API query against the GraphQL API:

```graphql
query { decidim { version } }
```

This no longer returns the running Decidim version by default and instead it will result to `null` being reported as the version number.

If you would like to re-enable exposing the Decidim version number through the GraphQL API, you may do so by setting the `DECIDIM_API_DISCLOSE_SYSTEM_VERSION` environment variable to `true`. However, this is highly discouraged but may be required for some automation or integrations.

### 5.2. [[TITLE OF THE CHANGE]]

In order to [[REASONING (e.g. improve the maintenance of the code base)]] we have changed...

If you have used code as such:

```ruby
# Explain the usage of the API as it was in the previous version
result = 1 + 1 if before
```

You need to change it to:

```ruby
# Explain the usage of the API as it is in the new version
result = 1 + 1 if after
        ```
