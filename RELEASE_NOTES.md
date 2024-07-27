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

### 3.1. Migration from secrets to credentials

Starting with the rails 7.1 upgrade, we have noticed that the secrets will be removed starting with rails 7.2. In order to upgrade more easy to rails 7.2, we have removed the secrets from our application, converting them to credentials.

If your application is using `Rails.application.secrets` anywhere, please change your code to use `Rails.application.credentials`.

In case you do not want to rely on the old `config/secrets.yml` file, please follow the next steps:

```bash
EDITOR=vim ./bin/rails credentials:edit --environment production
```

This will open a vim editor where you can add your credentials. This will generate you 2 new files:

```bash
config/credentials/production.key
config/credentials/production.yml.enc
```

You will need to repeat the same process for all 3 environments :
```bash
EDITOR=vim ./bin/rails credentials:edit --environment test
EDITOR=vim ./bin/rails credentials:edit --environment development
```

**Please note:** The new credentials files do not support reading environment variables.

You can read more about this change on PR [#13220](https://github.com/decidim/decidim/pull/13220).

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

### 5.1. [[TITLE OF THE CHANGE]]

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
