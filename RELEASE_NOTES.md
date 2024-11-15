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
sudo apt install p7zip # or the alternative installation process for your operating system. See "2.1. 7zip dependency introduction"
sudo apt install wkhtmltopdf # or the alternative installation process for your operating system. See "2.5. wkhtmltopdf binary change"
bundle remove spring spring-watcher-listen
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails decidim:upgrade:clean:invalid_records
bin/rails decidim_proposals:upgrade:set_categories
```

## 2. General notes

### 2.1. 7zip dependency introduction

We had to migrate from an unmaintained dependency and do a wrapper for the 7zip command line. This means that you need to install 7zip in your system. You can do it by running:

```bash
sudo apt install p7zip
```

This works for Ubuntu Linux, other operating systems would need to do other command/package.

You can read more about this change on PR [#13185](https://github.com/decidim/decidim/pull/13185).

### 2.2. Cleanup invalid resources

While upgrading various instances to latest Decidim version, we have noticed there are some records that may not be present anymore. As a result, the application would generate a lot of errors, in both frontend and Backend.

In order to fix these errors, we have introduced a new rake task, aiming to fix the errors by removing invalid data.

In your console you can run:

```bash
bin/rails decidim:upgrade:clean:invalid_records
```

If you have a big installation having multiple records, many users etc, you can split the clean up task as follows:

```bash
bin/rails decidim:upgrade:clean:searchable_resources
bin/rails decidim:upgrade:clean:notifications
bin/rails decidim:upgrade:clean:follows
bin/rails decidim:upgrade:clean:action_logs
```

You can read more about this change on PR [#13237](https://github.com/decidim/decidim/pull/13237).

### 2.3 Allow Cell's cache to expire

Now the cache expiration time is configurable via initializers/ENV variables.

Decidim uses cache in some HTML views (usually under the `cells/` folder). In the past the cache had no expiration time, now it is configurable using the ENV var `DECIDIM_CACHE_EXPIRATION_TIME` (this var expects an integer specifying the number of minutes for which the cache is valid).

Also note, that now it comes with a default value of 24 hours (1440 minutes).

### 2.4. Amendments category fix

We have identified a bug in the filtering system, as the amendments created did not share the category with the proposal it amended. This fix aims to fix historic data. To fix it, you need to run:

```shell
bin/rails decidim_proposals:upgrade:set_categories
```

You can read more about this change on PR [#13395](https://github.com/decidim/decidim/pull/13395).

### 2.5. wkhtmltopdf binary change

For improving the support with latest versions of Ubuntu, and keeping a low size in Heroku/Docker images, we removed the `wkhtmltopdf-binary` gem dependency. This means that your package manager should have the `wkhtmltopdf` binary installed.

In the case of Ubuntu/Debian, this is done with the following command:

```bash
sudo apt install wkhtmltopdf
```

You can read more about this change on PR [#13616](https://github.com/decidim/decidim/pull/13616).

### 2.6. Clean deleted user records `decidim:upgrade:clean:clean_deleted_users` task

When a user deleted their account, we mistakenly retained some metadata, such as the personal_url and about fields. Going forward, these fields will be automatically cleared upon deletion. To fix this issue for previously deleted accounts, we've added a new rake task that should be run on your production database.

```ruby
bin/rails decidim:upgrade:clean:clean_deleted_users
```

You can read more about this change on PR [#13624](https://github.com/decidim/decidim/pull/13624).

## 3. One time actions

### 3.1. Verifications documents configurations

Until now we have hard-coded the document types for verifications with types from Spain legislation ("DNI, NIE and passport"). We have change it to "Identification number and passport", and allow installations to adapt them to their own needs.

If you want to go back to the old setting, you need to follow these steps:

#### 3.1.1. Add to your config/secrets.yml the `decidim.verifications.document_types` key

```erb
decidim_default: &decidim_default
  application_name: <%%= Decidim::Env.new("DECIDIM_APPLICATION_NAME", "My Application Name").to_json %>
  (...)
  verifications:
    document_types: <%%= Decidim::Env.new("VERIFICATIONS_DOCUMENT_TYPES", %w(identification_number passport)).to_array %>
```

#### 3.1.2. Add to your `config/initializers/decidim.rb` the following snippet in the bottom of the file

```ruby
if Decidim.module_installed? :verifications
  Decidim::Verifications.configure do |config|
    config.document_types = Rails.application.secrets.dig(:verifications, :document_types).presence || %w(identification_number passport)
  end
end
```

#### 3.1.3. Add the values that you want to define using the environmnet variable `VERIFICATIONS_DOCUMENT_TYPES`

```env
VERIFICATIONS_DOCUMENT_TYPES="dni,nie,passport"
```

#### 3.1.4. Add the translation of these values to your i18n files (i.e. `config/locales/en.yml`)

```yaml
en:
  decidim:
    verifications:
        id_documents:
          dni: DNI
          nie: NIE
          passport: Passport
```

You can read more about this change on PR [\#12306](https://github.com/decidim/decidim/pull/12306)

### 3.2. Allow removal of orphan categories

A bug was identified that prevented the deletion of categories lacking associated resources. This action is a one-time task that must be performed directly in the production database.

```console
bin/rails decidim:upgrade:fix_orphan_categorizations
```

You can read more about this change on PR [\#12143](https://github.com/decidim/decidim/pull/12143).

### 3.3. Improved CSS overrides

We have improved the CSS overriding mechanism. This is what allows you to change the CSS of decidim in your application in a more granular way.

Previously, you could do this by adding CSS rules in the `app/packs/stylesheets/decidim/decidim_application.scss` file. This file remains in place but is loaded as the last file in the application, so it will take precedence over all the CSS rules from the Decidim modules.

Additionally, if you need, you can also customize the `admin` and `system` interfaces by creating in your application the following files:

- `app/packs/stylesheets/decidim/admin/decidim_application.scss` for admin interface
- `app/packs/stylesheets/decidim/system/decidim_application.scss` for system interface

You can read more about this change on PR [\#12646](https://github.com/decidim/decidim/pull/12646).

### 3.4. Remove spring and spring-watcher-listen from your Gemfile

To simplify the upgrade process, we have decided to add `spring` and `spring-watcher-listener` as hard dependencies of `decidim-dev`.

Before upgrading to this version, make sure you run in your console:

```bash
bundle remove spring spring-watcher-listen
```

You can read more about this change on PR [#13235](https://github.com/decidim/decidim/pull/13235).

### 3.5. Clean up orphaned attachment blobs

We have added a new task that helps you clean the orphaned attachment blobs. This task will remove all the attachment blobs that have been created for more than 1 hour and are not yet referenced by any attachment record. This helps cleaning your filesystem of unused files.

You can run the task with the following command:

```bash
bin/rails decidim:upgrade:attachments_cleanup
```

You can see more details about this change on PR [\#11851](https://github.com/decidim/decidim/pull/11851)

### 3.6. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 4. Scheduled tasks

## 5. Changes in APIs
