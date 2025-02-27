# Release Notes

## 1. Upgrade notes

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

### 1.4. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Hiding comments of moderated resources

We have noticed that when a resource (ex: Proposal, Meeting) is being moderated, the associated comments are left visible in the search. We have added a task that would allow you to automatically remove from search any comment belonging to moderated content:

```bash
bin/rails decidim:upgrade:clean:hidden_resources
```

You can read more about this change on PR [#13554](https://github.com/decidim/decidim/pull/13554).

### 2.2. Add Share via QR

As of this release we have added a new Social Share functionality, that enables you to share any Decidim resource via QR code, enabling you to generate and display any QR code.

To enable this functionality, change your `DECIDIM_SOCIAL_SHARE_SERVICES` environment variable to include `QR`. If you don't have that variable set up, check your `config/secrets.yml` file, and change the key: `social_share_services` so that it includes QR.

```yaml
decidim_default: &decidim_default
  # ...
  social_share_services: <%= Decidim::Env.new("DECIDIM_SOCIAL_SHARE_SERVICES", "X, Facebook, WhatsApp, Telegram").to_array.to_json %>
```

Should become:

```yaml
decidim_default: &decidim_default
  # ...
  social_share_services: <%= Decidim::Env.new("DECIDIM_SOCIAL_SHARE_SERVICES", "X, Facebook, WhatsApp, Telegram, QR").to_array.to_json %>
```

You can read more about this change on PR [#14086](https://github.com/decidim/decidim/pull/14086).

### 2.3. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#xxxx](https://github.com/decidim/decidim/pull/xxx).

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
