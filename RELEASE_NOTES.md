# Release Notes

NOTE: This is the draft for the releases notes. If you are an implementer or someone that is upgrading a Decidim installation, you need to follow
the instructions for all the patch releases in GitHub:

- <https://github.com/decidim/decidim/releases/tag/v0.31.0>
- <https://github.com/decidim/decidim/releases/tag/v0.31.1>
- <https://github.com/decidim/decidim/releases/tag/v0.31.2>
- <https://github.com/decidim/decidim/releases/tag/v0.31.3>

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

### 1.1. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim", branch: "release/0.31-stable"
gem "decidim-dev", github: "decidim/decidim", branch: "release/0.31-stable"
```

### 1.3. Run these commands

Note that there were several big updates in this version, most notably Rails and Shakapacker.

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
sed -i 's/Env.new("SMTP_STARTTLS_AUTO").to_boolean_string/Env.new("SMTP_STARTTLS_AUTO", true).present?/' config/environments/production.rb
bin/rails data:migrate
```

### 1.4. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Fix the "SMTP_STARTTLS_AUTO" env var in `production.rb`

It was detected a bug with the enable_starttls_auto configuration for the Action Mailer (SMTP) configuration. For fixing it you need to replace in `config/environments/production.rb`

If your `config/environments/production.rb` contains an SMTP configuration like this:

```ruby
config.action_mailer.smtp_settings = {
  # ... other settings ...
  :enable_starttls_auto => Decidim::Env.new("SMTP_STARTTLS_AUTO").to_boolean_string,
  # ... other settings ...
}
```

You should update it to:

```ruby
config.action_mailer.smtp_settings = {
  # ... other settings ...
  :enable_starttls_auto => Decidim::Env.new("SMTP_STARTTLS_AUTO", true).present?,
  # ... other settings ...
}
```

You can do this with the following command:

```bash
sed -i 's/Env.new("SMTP_STARTTLS_AUTO").to_boolean_string/Env.new("SMTP_STARTTLS_AUTO", true).present?/' config/environments/production.rb
```

You can read more about this change on PR [#16491](https://github.com/decidim/decidim/pull/16491).

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
