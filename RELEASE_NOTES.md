# Release Notes

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your Gemfile

```ruby
gem "decidim", "0.28.0.rc1"
gem "decidim-dev", "0.28.0.rc1"
```

### 1.2. Run commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
```

## 2. General notes

## 3. One time actions

### 3.1. Improved CSS overrides

We have improved the CSS overriding mechanism. This is what allows you to change the CSS of decidim in your application in a more granular way.

Previously, you could do this by adding CSS rules in the `app/packs/stylesheets/decidim/decidim_application.scss` file. This file remains in place but is loaded as the last file in the application, so it will take precedence over all the CSS rules from the Decidim modules.

Additionally, if you need, you can also customize the `admin` and `system` interfaces by creating in your application the following files:

- `app/packs/stylesheets/decidim/admin/decidim_application.scss` for admin interface
- `app/packs/stylesheets/decidim/system/decidim_application.scss` for system interface

You can read more about this change on PR [\#12646](https://github.com/decidim/decidim/pull/12646).

## 4. Scheduled tasks

## 5. Changes in APIs
