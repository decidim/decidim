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

### 2.1. Verification code security hardening

The verification code confirmation flow has been enhanced with multiple security improvements. Failed attempt tracking has been moved from client-side session to server-side database storage, with three layers of protection:

1. **Server-side failed attempt tracking**: Failed attempts are now tracked in the database with automatic lockout after 5 failed attempts (configurable via `DECIDIM_VERIFICATION_MAX_FAILED_ATTEMPTS`) and automatic unlock after 30 minutes (configurable via `DECIDIM_VERIFICATION_UNLOCK_IN`).

2. **Code expiration**: SMS verification codes now expire after 10 minutes (configurable via `DECIDIM_VERIFICATION_CODE_EXPIRY_MINUTES`), reducing the window of opportunity for unauthorized access.

3. **HTTP-level rate limiting**: Rack::Attack now throttles verification confirmation endpoints to 10 requests per minute per IP.

Server-side failed attempt tracking applies to all verification handlers (SMS, postal letter, ID documents, CSV census). Code expiration applies only to SMS verification. HTTP-level rate limiting applies only to SMS and postal letter authorization paths.

We strongly recommend that implementers review any custom authorization handlers for code that may still rely on the old session-based attempt tracking patterns, which have been replaced by the new server-side mechanism.

You can read more about this change on PR [#17639](https://github.com/decidim/decidim/pull/17639).

### 2.2. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

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
