# Release Notes

NOTE: This is the draft for the releases notes. If you are an implementer or someone that is upgrading a Decidim installation, you need to follow
the instructions for all the patch releases in GitHub:

- https://github.com/decidim/decidim/releases/tag/v0.30.0
- https://github.com/decidim/decidim/releases/tag/v0.30.1

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

### 1.1 Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim", branch: "release/0.30-stable"
gem "decidim-dev", github: "decidim/decidim", branch: "release/0.30-stable"
```

### 1.2. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
```

### 1.3. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. [[TITLE OF THE ACTION]]

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 3. One time actions

### 3.1. [[TITLE OF THE ACTION]]

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
 with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. [[TITLE OF THE TASK]]

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rails decidim:TASK
```

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/XXXX).

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
