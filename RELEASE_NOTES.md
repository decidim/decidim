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
# skip this command if you have run it before:
bin/rails decidim:upgrade:clean:remove_private_exports_attachments
bin/rails data:migrate:up # Read more in 2.3. Add data migrations
```

### 1.4. AWS/Azure/Google Cloud assets storage

There is a bug related to the cache expiration using Active Storage (assets, such as images). For fixing this issue, the Rails team added an extra active storage parameter, `public: true` that you can add it to your storage configuration. If you followed the step `3.4. Deprecation of Rails.application.secrets` and changed your `config/storage.yml` file you don't need to do anything else.

This will also change the URL that is used, so you will need to update your [Content Security Policy](https://docs.decidim.org/en/develop/customize/content_security_policy.html), adding the new URL in the policies "default-src", "img-src", "media-src", and "connect-src". For instance, in the case of S3 with AWS, the format of the URL is the following:  `https://BUCKET-NAME.s3.amazonaws.com/ASSET_ID`.

Apart of that, you also need to configure your preferred cloud service provider to support this. We recommend you to follow the Rails official guide for [Active Storage configuration](https://guides.rubyonrails.org/v7.0/active_storage_overview.html#setup).

You can read more about this change on PR [#15005](https://github.com/decidim/decidim/pull/15005/).

### 1.5. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Module deprecations

As part of our ongoing efforts to improve and make simpler Decidim, the following modules will be **deprecated** in this version (v0.31) and **removed** in the next major version (v0.32):

#### Collaborative Drafts

The Collaborative Drafts feature in the Proposals module (`decidim-proposals`) will be removed in v0.32. Organizations using this feature can switch to the new proposal co-authorship feature.

#### Sortitions (decidim-sortitions)

The Sortitions module (`decidim-sortitions`) will be removed in v0.32. This module provided functionality to randomly select participants or proposals. Organizations relying on this feature should consider implementing alternative selection mechanisms.

#### Polls in Meetings (decidim-meetings polls functionality)

The Polls feature within the Meetings module (`decidim-meetings`) will be removed in a future version (to be determined). This feature allowed meeting organizers to create polls during meetings. Organizations using meeting polls should plan to use external polling tools (for instance, through Jitsi) or migrate to other voting mechanisms available in Decidim, such as the new Elections module (`decidim-elections`).

### 2.2. Old private exports are now expired

Due to some data consistency issues with the private exports, we have decided to expire all the previously generated files. Users are able to request and receive a new private export file.

if you are upgrading from a lover version like 0.30, and you have already ran this command, you can skip this step.

Run the following command to expire all the private exports:

```console
bin/rails decidim:upgrade:clean:remove_private_exports_attachments
```

You can read more about this change on PR [#15020](https://github.com/decidim/decidim/pull/15020).

### 2.3. Add data migrations

As the need to migrate data increased, we need a more reliable way to migrate data. We have introduced data migrations, which are similar to schema migrations but they are run only when the database schema is up to date.

To run the data migrations, run the following command:

```console
bin/rails data:migrate:up
```

To see the status of available data migrations, run the following command:

```console
bin/rails data:migrate:status
```

#### 2.3.1. Developer notes

As you may need to run data migrations in your developed plugins, you can hook up to the data migration system by adding the following line to your gem's `engine.rb` file:

```ruby
 initializer "your_gem_name.data_migrate", after: "decidim_core.data_migrate" do
    DataMigrate.configure do |config|
      config.data_migrations_path << root.join("db/data").to_s
    end
  end
```

The migration files should be named following the pattern `YYYYMMDDHHMMSS_your_migration_name.rb`, and should be placed in the `db/data` folder. The structure of the migration should be something like:

```ruby
# frozen_string_literal: true

class YourMigrationName < ActiveRecord::Migration[7.2]

  # your custom classes should be defined here

  def up
    # your migration code
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

You can read more about this change on PR [#15501](https://github.com/decidim/decidim/pull/15501).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Fix incorrect ActionLog entries

The action of hiding a component from a menu was being stored as a public action. These can lead to crashing the application if some related participatory space is removed.

In order to correct the existing entries you should run the following rake task:

```bash
bin/rails decidim:upgrade:fix_action_log
```

You can read more about this change on PR [#15390](https://github.com/decidim/decidim/pull/15390).

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
