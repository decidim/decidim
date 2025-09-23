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
```

### 1.4. Fix SMTP STARTTLS Configuration

⚠ **Important**: If you are using SMTP for email delivery and have a custom configuration in
`config/environments/production.rb`, you may need to update your SMTP settings.

Previous versions of the Decidim generator created SMTP configurations that could cause errors with some
mail servers due to incorrect boolean value handling for the `:enable_starttls_auto` setting.

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

This change ensures that the mail library receives a proper boolean value instead of a string,
preventing potential SMTP connection errors.

**Note**: This fix only affects installations that use custom SMTP configurations. If you are using
the default mail configuration or a different mail delivery method, no action is required.

### 1.5. Follow the steps and commands detailed in these notes

## 2. General notes

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. [[TITLE OF THE ACTION]]

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
