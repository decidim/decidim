# Release Notes

NOTE: This is the draft for the releases notes. If you are an implementer or someone that is upgrading a Decidim installation, we recommend
checking out the last version of this document in the GitHub page for the releases of this branch:

- https://github.com/decidim/decidim/releases/tag/v0.29.0
- https://github.com/decidim/decidim/releases/tag/v0.29.1

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your ruby version

If you're using rbenv, this is done with the following commands:

```console
rbenv install 3.2.2
rbenv local 3.2.2
```

If not, you need to adapt it to your environment. See "2.1. Ruby update to 3.2"

### 1.2. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.3. Run these commands

```console
sudo apt install p7zip # or the alternative installation process for your operating system. See "2.1. 7zip dependency introduction"
sudo apt install wkhtmltopdf # or the alternative installation process for your operating system. See "2.7. wkhtmltopdf binary change"
bundle remove spring spring-watcher-listen
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails decidim:upgrade:clean:invalid_records
bin/rails decidim_proposals:upgrade:set_categories
```

### 1.4. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Ruby update to 3.2

We have updated the Ruby version to 3.2.2. Upgrading to this version will require either to install this Ruby version on your host, or change the decidim docker image to use ruby:3.2.2.
You can read more about this change on PR [#12199](https://github.com/decidim/decidim/pull/12199).

### 2.2. Rails update to 7.0

We have updated the Rails version to 7.0.8.1. You do not need to do anything.

You can read more about this change on PR [#12616](https://github.com/decidim/decidim/pull/12616).

### 2.3. Removal of the accountability naming customization

We have removed the ability to customize the labels from the Accountability component, as it was not following the recommended way of handling these text customizations. If you want to migrate your current customizations, you can read about [Text customizations in Decidim Documentation](https://docs.decidim.org/en/develop/customize/texts)

You can read more about this change on PR [#12853](https://github.com/decidim/decidim/pull/12853).

### 2.4 Removal of useless fields

We are removing some useless fields that are leftovers from the Redesign.

For the moment we are leaving the information in your database in case that you want to save it, but in v0.30 these fields we'll be fully removed.

- participatory process table: banner_image. You can read more about this change on PR [#13119](https://github.com/decidim/decidim/pull/13119).
- assemblies table: show_statistics. You can read more about this change on PR [#13123](https://github.com/decidim/decidim/pull/13123).
- participatory process table: show_statistics. You can read more about this change on PR [#13123](https://github.com/decidim/decidim/pull/13123).
- participatory process table: show_metrics. You can read more about this change on PR [#13123](https://github.com/decidim/decidim/pull/13123).

### 2.5. 7zip dependency introduction

We had to migrate from an unmaintained dependency and do a wrapper for the 7zip command line. This means that you need to install 7zip in your system. You can do it by running:

```bash
sudo apt install p7zip
```

This works for Ubuntu Linux, other operating systems would need to do other command/package.

You can read more about this change on PR [#13185](https://github.com/decidim/decidim/pull/13185).

### 2.6. Cleanup invalid resources

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

### 2.7. Allow Cell's cache to expire

Now the cache expiration time is configurable via initializers/ENV variables.

Decidim uses cache in some HTML views (usually under the `cells/` folder). In the past the cache had no expiration time, now it is configurable using the ENV var `DECIDIM_CACHE_EXPIRATION_TIME` (this var expects an integer specifying the number of minutes for which the cache is valid).

Also note, that now it comes with a default value of 24 hours (1440 minutes).

### 2.8. Amendments category fix

We have identified a bug in the filtering system, as the amendments created did not share the category with the proposal it amended. This fix aims to fix historic data. To fix it, you need to run:

```shell
bin/rails decidim_proposals:upgrade:set_categories
```

You can read more about this change on PR [#13395](https://github.com/decidim/decidim/pull/13395).

### 2.9. wkhtmltopdf binary change

For improving the support with latest versions of Ubuntu, and keeping a low size in Heroku/Docker images, we removed the `wkhtmltopdf-binary` gem dependency. This means that your package manager should have the `wkhtmltopdf` binary installed.

In the case of Ubuntu/Debian, this is done with the following command:

```bash
sudo apt install wkhtmltopdf
```

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

### 2.10. Clean deleted user records `decidim:upgrade:clean:clean_deleted_users` task

When a user deleted their account, we mistakenly retained some metadata, such as the personal_url and about fields. Going forward, these fields will be automatically cleared upon deletion. To fix this issue for previously deleted accounts, we've added a new rake task that should be run on your production database.

```ruby
bin/rails decidim:upgrade:clean:clean_deleted_users
```

You can read more about this change on PR [#13624](https://github.com/decidim/decidim/pull/13624).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. CarrierWave removal

Back in Decidim 0.25 we have added ActiveStorage (via [\#7902](https://github.com/decidim/decidim/pull/7902)) as main uploader instead of CarrierWave.

We've left some code to ease-up with the migration process during these last versions.

In your application, you need to remove the initializer:

```console
rm config/initializers/carrierwave.rb
```

You can read more about this change on PR [\#12200](https://github.com/decidim/decidim/pull/12200).

### 3.2. Verifications documents configurations

Until now we have hard-coded the document types for verifications with types from Spain legislation ("DNI, NIE and passport"). We have change it to "Identification number and passport", and allow installations to adapt them to their own needs.

If you want to go back to the old setting, you need to follow these steps:

#### 3.2.1. Add to your config/secrets.yml the `decidim.verifications.document_types` key

```erb
decidim_default: &decidim_default
  application_name: <%%= Decidim::Env.new("DECIDIM_APPLICATION_NAME", "My Application Name").to_json %>
  (...)
  verifications:
    document_types: <%%= Decidim::Env.new("VERIFICATIONS_DOCUMENT_TYPES", %w(identification_number passport)).to_array %>
```

#### 3.2.2. Add to your `config/initializers/decidim.rb` the following snippet in the bottom of the file

```ruby
if Decidim.module_installed? :verifications
  Decidim::Verifications.configure do |config|
    config.document_types = Rails.application.secrets.dig(:verifications, :document_types).presence || %w(identification_number passport)
  end
end
```

#### 3.2.3. Add the values that you want to define using the environment variable `VERIFICATIONS_DOCUMENT_TYPES`

```env
VERIFICATIONS_DOCUMENT_TYPES="dni,nie,passport"
```

#### 3.2.4. Add the translation of these values to your i18n files (i.e. `config/locales/en.yml`)

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

### 3.3. esbuild migration

In order to speed up the asset compilation, we have migrated from babel to esbuild.

There are some small changes that needs to be performed in your application code.

- Remove `babel.config.js`
- Replace `config/webpack/custom.js` with the new version.

```console
wget https://raw.githubusercontent.com/decidim/decidim/develop/decidim-core/lib/decidim/webpacker/webpack/custom.js -O config/webpack/custom.js
```

In case you have modifications in your application's webpack configuration, adapt it by [checking out the diff of the changes](https://github.com/decidim/decidim/pull/12238/files#diff-0e64008beaded63d6fbb9696d091751b4a81cd29432cc608e9381c4fb054c980).

You can read more about this change on PR [\#12238](https://github.com/decidim/decidim/pull/12238).

### 3.4. Allow removal of orphan categories

A bug was identified that prevented the deletion of categories lacking associated resources. This action is a one-time task that must be performed directly in the production database.

```console
bin/rails decidim:upgrade:fix_orphan_categorizations
```

You can read more about this change on PR [\#12143](https://github.com/decidim/decidim/pull/12143).

### 3.5. Improved CSS overrides

We have improved the CSS overriding mechanism. This is what allows you to change the CSS of decidim in your application in a more granular way.

Previously, you could do this by adding CSS rules in the `app/packs/stylesheets/decidim/decidim_application.scss` file. This file remains in place but is loaded as the last file in the application, so it will take precedence over all the CSS rules from the Decidim modules.

Additionally, if you need, you can also customize the `admin` and `system` interfaces by creating in your application the following files:

- `app/packs/stylesheets/decidim/admin/decidim_application.scss` for admin interface
- `app/packs/stylesheets/decidim/system/decidim_application.scss` for system interface

You can read more about this change on PR [\#12646](https://github.com/decidim/decidim/pull/12646).

### 3.6. Update to Footer Topic and Pages functionality

We have changed the behavior of the footer pages and topics links:

- Removed the "show in the footer" checkbox for pages.
- Removed duplicate "Terms of Service" link.
- Always show the link to the "Terms of Service" page.
- Only show links in footer to topics.

You can read more about this change on PR [\#12592](https://github.com/decidim/decidim/pull/12592).

### 3.8. Remove spring and spring-watcher-listen from your Gemfile

To simplify the upgrade process, we have decided to add `spring` and `spring-watcher-listener` as hard dependencies of `decidim-dev`.

Before upgrading to this version, make sure you run in your console:

```bash
bundle remove spring spring-watcher-listen
```

You can read more about this change on PR [#13235](https://github.com/decidim/decidim/pull/13235).

### 3.9. Clean up orphaned attachment blobs

We have added a new task that helps you clean the orphaned attachment blobs. This task will remove all the attachment blobs that have been created for more than 1 hour and are not yet referenced by any attachment record. This helps cleaning your filesystem of unused files.

You can run the task with the following command:

```bash
bin/rails decidim:upgrade:attachments_cleanup
```

You can see more details about this change on PR [\#11851](https://github.com/decidim/decidim/pull/11851)

### 3.10. [[TITLE OF THE ACTION]]

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

### 5.1 Migration of Proposal states in own table

As of [\#12052](https://github.com/decidim/decidim/pull/12052) all the proposals states are kept in a separate database table, enabling end users to customize the states of the proposals. By default we will create for any proposal component that is being installed in the project 5 default states that cannot be disabled nor deleted. These states are:

- Not Answered ( default state for any new created proposal )
- Evaluating
- Accepted
- Rejected
- Withdrawn ( special states for proposals that have been withdrawn by the author )

For any of the above states you can customize the name, description, css class used by labels. You can also decide which states the user can receive a notification or an answer.

You do not need to run any task to migrate the existing states, as we will automatically migrate the existing states to the new table.

You can see more details about this change on PR [\#12052](https://github.com/decidim/decidim/pull/12052)

### 5.2. Seeds require assets precompiling

In order to successfully showcase the features of the application, we have added as a mandatory step the assets precompiling, as the seeds will now fire the notification system. That allows any Decidim demo instance to display user notifications.

if you previously seeded your database using:

```bash
bin/rails db:drop db:create db:migrate db:seed
```

You are required to run using:

```bash
bin/rails db:drop db:create db:migrate assets:precompile db:seed
```

You can see more details about this change on PR [\#12828](https://github.com/decidim/decidim/pull/12828)

### 5.3. Verifications need a help text

In order to explain better to administrators what authorizations they have available we have added a new internationalization (i18n) key to the verifications workflows.

If you have a custom authorization handler, you need to add the help text to the `config/locales/en.yml` file, where `en.yml` is the locale file for the language you are using.

For instance, for the SMS authorization handler, you need to add the following key:

```yaml
en:
  decidim:
    authorization_handlers:
      admin:
        sms:
          help:
          - This is the help text for the SMS authorization handler
          - This is the second line of the help text
```

You can see more details about this change on PR [\#13029](https://github.com/decidim/decidim/pull/13029)

### 5.4. [[TITLE OF THE CHANGE]]

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
