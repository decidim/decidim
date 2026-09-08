# Release Notes

## 1. Upgrade notes

NOTE: This is the draft for the releases notes. If you are an implementer or someone that is upgrading a Decidim installation, we recommend
checking out the last version of this document in the [GitHub page for the releases of this branch](https://github.com/decidim/decidim/releases/).

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your ruby version

If you're using rbenv, this is done with the following commands:

```console
rbenv install 3.x.x
rbenv local 3.x.x
```

You may need to change your `.ruby-version` file too.

If not, you need to adapt it to your environment, for instance by changing the decidim docker image to use ruby:3.x.x.

### 1.2. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.3. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails data:migrate
```

### 1.4. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Unconfirmed and managed participants are now hidden by default

Participants that have not confirmed their account or accepted the terms of service of the website and managed participants are now hidden by default. This means that these profiles do not appear publicly on the website before the participant has accepted the terms of service. It is assumed that the consent to publish the participant's personal details on the website is mandated by the terms of service.

The profiles will be considered hidden by default and visible after the participant has accepted the terms of service or after a managed participant account is elevated to a regular participant account. The details of the hidden profiles are not displayed on the website and the API.

This change is based on the GDPR regulation:

> [...] In particular, such measures shall ensure that by default personal data are not made accessible without the individual’s intervention to an indefinite number of natural persons.
>
> GDPR Art. 25 (2)

You can read more about this change on PR [#11036](https://github.com/decidim/decidim/pull/11036).

### 2.3. Sidekiq configuration overwrite

As we are doing changes in the default sidekiq.yml configuration and we want to do them automatically, this file will be overwritten during the upgrade process (on the `bin/rails decidim:upgrade` command).

If you have queues or any configuration particular to your environment that you do not want to get overwritten, you can do so by calling another configuration file on the sidekiq daemon call. For instance:

```bash
sidekiq -C config/sidekiq.yml -C config/sidekiq.local.yml
```

You can read more about this change on PR [#17596](https://github.com/decidim/decidim/pull/17596).

### 2.2. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. New Active Storage Sidekiq queue

Active Storage jobs now run in the dedicated Sidekiq queue `active_storage` to avoid blocking the default queue.
Please add this queue to your `config/sidekiq.yml` and ensure at least one Sidekiq process is consuming it.

You can read more about this change on PR [#17520](https://github.com/decidim/decidim/pull/17520).

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

### 5.1. `initFoundation` Javascript function has been removed

In order to fully remove Foundation CSS, we need to remove any dependency to Foundation-Sites. In the latest releases we started to rely more on Stimulus controllers and plain Javascript.

If you are a developer or implementer, and you are upgrading your module or application, make sure that you do not have `foundation-sites` related code.

You can read more about this change on PR [#16889](https://github.com/decidim/decidim/pull/16889).

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
