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

### 1.2. Update your application configuration

In this version, we are changing Decidim’s underlying configuration engine. To update your application, make sure to review the changes related to environment variables. (See section 3.4: "Deprecation of Rails.application.secrets" for details.)

Your code and configuration must be updated to remove all references to the `Rails.application.secrets` object.

⚠ **Important**: If you have customized any of the following files:

* config/secrets.yml
* config/initializers/decidim.rb
* config/storage.yml

You will need to adjust your environment to provide the necessary configurations through environment variables.

```bash
git rm config/secrets.yml
git rm config/initializers/decidim.rb
wget https://raw.githubusercontent.com/decidim/decidim/refs/heads/develop/decidim-generators/lib/decidim/generators/app_templates/storage.yml -O config/storage.yml
```

### 1.3. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.4. Rails upgrade

This particular release is deploying a new Rails version 7.2. As a result you need to update your application configuration. Before that, you need to run the following commands:

```console
bundle update decidim
bin/rails decidim:upgrade
```

After that, you will have to patch your `config/environments/production.rb`, and change the logger with:

```ruby
if ENV["RAILS_LOG_TO_STDOUT"].present?
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
end
```

As of this version, we are changing Rails's settings from 6.1 to 7.1. In order to upgrade your app, you will need to patch your `config/application.rb` to load the 7.1 defaults.

```diff
module DevelopDevelopmentApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
-    config.load_defaults 6.1
+    config.load_defaults 7.1
    # ....
  end
end
```

After you have validated that your application still works as expected, you will need to do the next change, to fully finalize the upgrade. You need to change again the `config/application.rb` to load the 7.2 defaults.

```diff
module DevelopDevelopmentApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
-    config.load_defaults 7.1
+    config.load_defaults 7.2
    # ....
  end
end
```

We are recommending to follow the proposed steps, as you may have installed other decidim modules that are not yet ready to be used with 7.2

⚠ **Important**: Local environment variable introduced

Besides of what is already mentioned, you may encounter some encryption-related issues while developing locally, and this is caused by a Rails internal change that it is outside the control of Decidim's Maintainers team.

In the previous Rails versions the `secret_key_base` for local development was stored in a local file `development_app/tmp/development_secret.txt`, which has been remove starting Rails 7.1.
Depending on your environment setup, you will need to define an environment variable named `SECRET_KEY_BASE`.

You can read more about the Rails upgrade process on the following PRs:

* [Change framework defaults from Rails v6.1 to v7.0](https://github.com/decidim/decidim/pull/13267).
* [Update Rails to v7.1](https://github.com/decidim/decidim/pull/13267)
* [Update Rails to v7.2](https://github.com/decidim/decidim/pull/14784)
* [Change framework defaults from Rails v7.1 to v7.2](https://github.com/decidim/decidim/pull/14829)

### 1.5. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails decidim:upgrade:user_groups:remove
bin/rails decidim:upgrade:fix_nickname_casing
bin/rails decidim:verifications:revoke:sms
```

### 1.6. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. User Groups removal

As part of our efforts to simplify the experience for organizations, the "User Groups" feature has been deprecated. All previously existing User Groups has been converted into regular participants able to sign in providing the email and a password. The users with access to the email associated with the User Group will be able to set a password.

There are some tasks to notify users affected by the changes, transfer authorships and remove deprecated references to groups. All of them can be executed in a main task:

```bash
bin/rails decidim:upgrade:user_groups:remove
```

The tasks can also be executed one by one:

* An email will be sent to the email address associated with the User Group, informing them of the deprecation of User Groups and instructing them to define a password for the newly converted profile. For this run:

```bash
bin/rails decidim:upgrade:user_groups:send_reset_password_instructions
```

* To notify group members and admins associated with the User Group with an email explaining the changes and how to access the shared profile run:

```bash
bin/rails decidim:upgrade:user_groups:send_user_group_changes_notification_to_members
```

* To migrate the authorships and coauthorships of the old groups and assign to the new regular users:

```bash
bin/rails decidim:upgrade:user_groups:transfer_user_groups_authorships
```

* To avoid exceptions accessing to the activities log in the admin panel displaying activities associated with user groups:

```bash
bin/rails decidim:upgrade:user_groups:fix_user_groups_action_logs
```

* To avoid exceptions trying to display notifications associated with deprecated groups events:

```bash
bin/rails decidim:upgrade:user_groups:remove_groups_notifications
```

You can read more about this change on PR [#14130](https://github.com/decidim/decidim/pull/14130).

### 2.2. Automatic deletion of inactive accounts

To reduce database clutter and automatically manage inactive user accounts, we have introduced a scheduled task to delete accounts that have been inactive for a configurable period (default: 365 days).

Before deletion, the system will send two notification emails:

* The first email is sent **30 days** before the scheduled deletion.
* The second email is sent **7 days** before the deletion deadline.

Participants can prevent their account from being deleted by logging in before the deadline. A final email will be sent to inform the user once their account has been permanently deleted.

To enable automatic deletion, add the following scheduled task to your cron jobs:

```bash
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:participants:delete_inactive_participants
```

By default, the inactivity period is set to 365 days, but it can be customized by passing a parameter to the task. For example:

```bash
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:participants:delete_inactive_participants[500]
```

If you want to enable this, make sure your `sidekiq.yml` includes the `delete_inactive_participants` queue. If it is missing, patch your `config/sidekiq.yml`:

```yaml
:concurrency: <%= ENV.fetch("SIDEKIQ_CONCURRENCY", 5) %>
:queues:
  - [default, 2]
  - [delete_inactive_participants, 2]
  - [mailers, 4]
  - [reminders, 2]
  - [newsletter, 2]
```

You can read more about this change on PR [#13816](https://github.com/decidim/decidim/issues/13816).

### 2.3. Removal of Metrics

The **Metrics** feature has been completely removed

Use the **Statistics** feature instead.

If your application includes the `metrics` queue in `config/sidekiq.yml` or scheduled tasks in `config/schedule.yml`, make sure to remove them. Additionally make sure you remove the metrics crons from your crontab.

You can read more about this change on PR [#14387](https://github.com/decidim/decidim/pull/14387)

### 2.4. SMS authorization changes

As we have changed the authorization signature method for SMS, you will need to remove any authorizations that you may have. We are asking you to do this, in order to force your user base to reauthorize.

To remove it, you just need to run the below task.

```bash
bin/rails decidim:verifications:revoke:sms
```

You can read more about this change on PR [#14426](https://github.com/decidim/decidim/pull/14426)

### 2.5. Initiatives digital signature process change

The application changes the configuration of initiatives signature in initiatives types to allow developers to define the process in a flexible way. This is achieved by introducing signature workflows [#13729](https://github.com/decidim/decidim/pull/13729).

To define a signature workflow create an initializer in your application and register it:

For example, in `config/initializers/decidim_initiatives.rb`:

```ruby
Decidim::Initiatives::Signatures.register_workflow(:dummy_signature_handler) do |workflow|
  workflow.form = "DummySignatureHandler"
  workflow.authorization_handler_form = "DummyAuthorizationHandler"
  workflow.action_authorizer = "DummySignatureHandler::DummySignatureActionAuthorizer"
  workflow.promote_authorization_validation_errors = true
  workflow.sms_verification = true
  workflow.sms_mobile_phone_validator = "DummySmsMobilePhoneValidator"
end

Decidim::Initiatives::Signatures.register_workflow(:dummy_signature_with_sms_handler) do |workflow|
  workflow.form = "Decidim::Initiatives::SignatureHandler"
  workflow.sms_verification = true
end

Decidim::Initiatives::Signatures.register_workflow(:dummy_signature_with_personal_data_handler) do |workflow|
  workflow.form = "DummySignatureHandler"
  workflow.authorization_handler_form = "DummyAuthorizationHandler"
  workflow.action_authorizer = "DummySignatureHandler::DummySignatureActionAuthorizer"
  workflow.promote_authorization_validation_errors = true
  workflow.save_authorizations = false
end

Decidim::Initiatives::Signatures.register_workflow(:legacy_signature_handler) do |workflow|
  workflow.form = "Decidim::Initiatives::LegacySignatureHandler"
  workflow.authorization_handler_form = "DummyAuthorizationHandler"
  workflow.save_authorizations = false
  workflow.sms_verification = true
end
```

All the attributes of a workflow are optional except the registered name with which the workflow is registered. A flow without attributes uses default values that generate a direct signature process without steps.

Signature workflows can be defined as ephemeral, in which case users can sign initiatives without prior registration. For a workflow of this type to work correctly, an authorization handler form must be defined in `authorization_handler_form` and authorizations saving must not be disabled using the `save_authorizations` setting, in order to ensure that user verifications are saved based on the personal data they provide.

To migrate old signature configurations review the One time actions section.

In the process to extract the old initiatives vote form to a base handler a new secret has been added to extract the key used to encrypt the user metadata in the vote. This secret is available in the application calling `Decidim::Initiatives.signature_handler_encryption_secret` and is used in the base class `Decidim::Initiatives::SignatureHandler`.

For more information about the definition of a signature workflow read the documentation of `Decidim::Initiatives::SignatureWorkflowManifest`.

### 2.6. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#xxxx](https://github.com/decidim/decidim/pull/xxx).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Changes in Static maps configuration when using HERE.com

As of [#14180](https://github.com/decidim/decidim/pull/14180) we are migrating to here.com api V3, as V1 does not work anymore. In case your application uses Here.com as static map tile provider, you will need to change your `config/initializers/decidim.rb` to use the new url `https://image.maps.hereapi.com/mia/v3/base/mc/overlay`:

```ruby
  static_url = "https://image.maps.ls.hereapi.com/mia/1.6/mapview" if static_provider == "here" && static_url.blank?
```

to

```ruby
  static_url = "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" if static_provider == "here" && static_url.blank?
```

You can read more about this change on PR [#14180](https://github.com/decidim/decidim/pull/14180).

### 3.2. Change of Valuator for Evaluator

We have updated the terminology of Valuator at a code base level throughout the platform. The role of Valuator is now Evaluator. With this change also affects strings, i18n translations and so on.

Implementors must run the following 3 tasks:

```bash
./bin/rails decidim:upgrade:decidim_update_valuators
./bin/rails decidim:upgrade:decidim_action_log_valuation_assignment
./bin/rails decidim:upgrade:decidim_paper_trail_valuation_assignment
```

These tasks migrate the old data to the new names.

More information about this change can be found on PR [#13684](https://github.com/decidim/decidim/pull/13684).

### 3.3. Convert nicknames to lowercase

As of [#14272](https://github.com/decidim/decidim/pull/14272) we are migrating all the nicknames to lowercase fix performance issues which affects large databases having many participants.

To apply the fix on your application, you need to run the below command.

```bash
bin/rails decidim:upgrade:fix_nickname_casing
```

You can read more about this change on PR [#14272](https://github.com/decidim/decidim/pull/14272).

### 3.4. Deprecation of `Rails.application.secrets`

If you were already using the Environment Variables for the configuration of your application, then you can remove both the config/secrets.yml and also the decidim initializer:
If you are not using the ENV system, you will need to adjust your application settings to use it.

Before actually removing the initializer, just make sure you do not have any custom configuration.

```bash
git rm config/secrets.yml
git rm config/initializers/decidim.rb
wget https://raw.githubusercontent.com/decidim/decidim/refs/heads/develop/decidim-generators/lib/decidim/generators/app_templates/storage.yml -O config/storage.yml
```

### 3.5. Migrate signature configuration of initiatives types

If there is any type of initiative with online signature enabled, you will have to reproduce the configuration by defining signature workflows. For direct signing is not necessary to define one or define an empty workflow.

Use the following definition scheme and adapt the values as indicated in the comments:

```ruby
Decidim::Initiatives::Signatures.register_workflow(:legacy_signature_handler) do |workflow|
  # Enable this form to enable the same user data collection and store the same
  # fields in the vote metadata when the "Collect participant personal data on
  # signature" were checked
  workflow.form = "Decidim::Initiatives::LegacySignatureHandler"

  # Change this form and use the same handler selected in the "Authorization to
  # verify document number on signatures" field
  workflow.authorization_handler_form = "DummyAuthorizationHandler"

  # This setting prevents the automatic creation of authorizations as in the
  # old feature. You can remove this setting if the workflow does not use an
  # authorization handler form. The default value is true.
  workflow.save_authorizations = false

  # Set this setting to false or remove to skip SMS verification step
  workflow.sms_verification = true
end
```

Register a workflow for each different signature configuration and select them in the initiative type admin "Signature workflow" field

You can read more about this change on PR [#13729](https://github.com/decidim/decidim/pull/13729).

### 3.6. Removal of invalid user exports

We have noticed an edge case when using private export functionality, in which the page becomes inaccessible if the user in question is using export single survey answer functionality.

You can run the following rake task to ensure your system is not corrupted.

```bash
./bin/rails decidim:upgrade:clean:invalid_private_exports
```

For ease of in operations, we also added the above command to the main `decidim:upgrade:clean:invalid_records` rake task.

You can read more about this change on PR [#14638](https://github.com/decidim/decidim/pull/14638).

### 3.7. Removal of linking Proposals to certain modules

We have removed the ability of linking Proposals to the Meetings, Accountability and Budgets module, by removing the setting `enable_proposal_linking`.

The rhetoric reasoning of this removal is due to extending and improving the settings usage with proposed features such as: [#13067] & [#14289].

You can read more about this change on PR [#14453](https://github.com/decidim/decidim/pull/14453).

### 3.8. Change form endorsements to likes

We have replaced the terminology of `endorsements` with `likes` throughout the platform, meaning that endorsement buttons and counters have been changed to likes.

Implementers will notice this transition once they run the needed migrations on the platform. Additionally some of the translation keys have changed, and this may affect your instance.

You can read more about this change on PR [#14666](https://github.com/decidim/decidim/pull/14666).

### 3.9. [[TITLE OF THE ACTION]]

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

### 5.1. Add force_api_authentication configuration options

There are times that we need to let only authenticated users to use the API. This configuration option filters out unauthenticated users from accessing the api endpoint. You need to add `DECIDIM_API_FORCE_API_AUTHENTICATION` to your environment variables if you want to enable this feature.

### 5.2. Require organization in nicknamize method

In order to avoid potential performance issues, we have changed the `nicknamize` method by requiring the organization as a parameter.

If you have used code as such:

```ruby
# We were including the organization in an optional scope
Decidim::UserBaseEntity.nicknamize(nickname, decidim_organization_id: user.decidim_organization_id)
```

You need to change it, to something like:

```ruby
# Now the organization is the required second parameter of the method
Decidim::UserBaseEntity.nicknamize(nickname, user.decidim_organization_id)
```

You can read more about this change on PR [#14669](https://github.com/decidim/decidim/pull/14669).

### 5.3. [[TITLE OF THE CHANGE]]

In order to [[REASONING (e.g. improve the maintenance of the code base)]] we have changed...

If you have used code as such:

```ruby
# Explain the usage of the API as it was in the previous version
result = 1 + 1 if before
```

```ruby
# Explain the usage of the API as it is in the new version
result = 1 + 1 if after
```

You can read more about this change on PR [#xxxx](https://github.com/decidim/decidim/pull/xxxxx).
