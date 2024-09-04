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

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.


### 3.1. Remove spring and spring-watcher-listen from your Gemfile


To simplify the upgrade process, we have decided to add `spring` and `spring-watcher-listener` as hard dependencies of `decidim-dev`.

Before upgrading to this version, make sure you run in your console:

```bash
bundle remove spring spring-watcher-listen
```

You can read more about this change on PR [#13235](https://github.com/decidim/decidim/pull/13235).

### 3.2. Remove the follows of ex private users


To delete the follows of ex private users of non transparent assemblies or processes, run

```console
bundle exec rake decidim:upgrade:fix_deleted_private_follows
```

You can read more about this change on PR [#12878](https://github.com/decidim/decidim/pull/12878).

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
