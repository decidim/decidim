# Release Notes

NOTE: This is the draft for the releases notes. If you are an implementer or someone that is upgrading a Decidim installation, you need to follow
the instructions for all the patch releases in GitHub:

- https://github.com/decidim/decidim/releases/tag/v0.31.0.rc1

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your ruby and node versions

If you're using rbenv, this is done with the following commands:

```console
rbenv install 3.3.4
rbenv local 3.3.4
```

You may need to change your `.ruby-version` file too.

If not, you need to adapt it to your environment, for instance by changing the decidim docker image to use ruby:3.3.4.

For node, if you're using nvm, this is done with the following commands:

```console
nvm install 22.14.0
nvm use 22.14.0
```

### 1.2. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.3. Run these commands

Note that there were several big updates in this version, most notably Rails and Shakapacker.

```console
git rm config/secrets.yml # see "2.2. Deprecation of `Rails.application.secrets`"
git rm config/initializers/decidim.rb # see "2.2. Deprecation of `Rails.application.secrets`"
wget https://raw.githubusercontent.com/decidim/decidim/refs/heads/develop/decidim-generators/lib/decidim/generators/app_templates/storage.yml -O config/storage.yml  # see "2.2. Deprecation of `Rails.application.secrets`"
wget https://github.com/decidim/decidim/releases/download/v0.31.0.rc1/production.rb -O config/environments/production.rb # see "2.2. Deprecation of `Rails.application.secrets`"

bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate

sed -i "s/config\.load_defaults 6\.1/config\.load_defaults 7.2/g" config/application.rb # see "2.1. Ruby on Rails update to 7.2"

bin/rails decidim:upgrade:decidim_update_valuators # see "3.1. Change of Valuator for Evaluator"
bin/rails decidim:upgrade:decidim_action_log_valuation_assignment # see "3.1. Change of Valuator for Evaluator"
bin/rails decidim:upgrade:decidim_paper_trail_valuation_assignment # see "3.1. Change of Valuator for Evaluator"
bin/rails decidim:upgrade:fix_nickname_casing # see "3.2. Convert nicknames to lowercase"
bin/rails decidim:upgrade:clean:invalid_private_exports # see "3.3 Removal of invalid user exports"
bin/rails decidim:verifications:revoke:sms # see "3.4. SMS authorization changes"
bin/rails decidim_surveys:upgrade:fix_survey_permissions # see "3.5. Permission rename in surveys module"
bin/rails decidim:upgrade:user_groups:remove # see "3.6. User Groups removal"
```

Update your shakapacker version in your `package.json` file for "2.3 Shakapacker upgrade"
Change your cloud assets storage configuration if you are using one for "3.7. AWS/Azure/Google Cloud assets storage"
Change your crontab and your sidekiq configuration for "4.1. Automatic deletion of inactive accounts"
Change your crontab and your sidekiq configuration for "4.2. Removal of Metrics"

In cases where you have done some developments, please check out these particular sections:

- If you call to `Decidim::UserBaseEntity.nicknamize`, you need to update your code
- If you want to do external integrations using the GraphQL API, read about these changes at:
  - 5.1. Add force_api_authentication configuration options
  - 5.3. Extended OAuth application capabilities for integrating external participant-facing applications
  - 5.4. Changed scopes for OAuth authorization requests
  - 5.5. API users for machine-to-machine integrations
  - 5.6. Possibility to force API authentication
  - 5.7. JWT token based API authentication
- If you use the Initiatives module, we have some improvements in the Signature workflow. Read more about it at:
  - 5.8 Initiatives digital signature process change
  - 5.9. Migrate signature configuration of initiatives types

### 1.6. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Ruby on Rails update to v7.2

This particular release is deploying a new Rails version 7.2. As a result you need to update your application configuration. You need to run the following commands:

```console
sed -i "s/config\.load_defaults 6\.1/config\.load_defaults 7.2/g" config/application.rb # change framework defaults from Rails v6.1 to v7.2
```

We are recommending to follow the proposed steps, as you may have installed other decidim modules that are not yet ready to be used with 7.2

⚠ **Important**: Local environment variable introduced

Besides of what is already mentioned, you may encounter some encryption-related issues while developing locally, and this is caused by a Rails internal change that it is outside the control of Decidim's Maintainers team.

In the previous Rails versions the `secret_key_base` for local development was stored in a local file `tmp/development_secret.txt`, which has been remove starting Rails 7.1.
Depending on your environment setup, you will need to define an environment variable named `SECRET_KEY_BASE`, or you can rename the file `tmp/development_secret.txt` to `tmp/local_secret.txt` so that you can continue the same secret.
If you see errors related to encryption changes (like `ActiveSupport::MessageEncryptor::InvalidMessage` exceptions), is probably related to this change (see [#15405](https://github.com/decidim/decidim/issues/15405) for more details).

You can read more about the Rails upgrade process on the following PRs:

- [Change framework defaults from Rails v6.1 to v7.0](https://github.com/decidim/decidim/pull/13267).
- [Update Rails to v7.1](https://github.com/decidim/decidim/pull/13267)
- [Update Rails to v7.2](https://github.com/decidim/decidim/pull/14784)
- [Change framework defaults from Rails v7.1 to v7.2](https://github.com/decidim/decidim/pull/14829)
- [Rails official documentation about secret change for development and test environments](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#development-and-test-environments-secret-key-base-file-changed)

### 2.2. Deprecation of `Rails.application.secrets`

In this version, we are changing Decidim’s underlying configuration engine. To update your application, make sure to review the changes related to environment variables.

If you were already using the Environment Variables for the configuration of your application, then you can remove both the config/secrets.yml and also the decidim initializer:
If you are not using the ENV system, you will need to adjust your application settings to use it.

Before actually removing the initializer, just make sure you do not have any custom configuration.

```bash
git rm config/secrets.yml
git rm config/initializers/decidim.rb
wget https://raw.githubusercontent.com/decidim/decidim/refs/heads/develop/decidim-generators/lib/decidim/generators/app_templates/storage.yml -O config/storage.yml
wget https://github.com/decidim/decidim/releases/download/v0.31.0.rc1/production.rb -O config/environments/production.rb # change production.rb so it does not use the deprecated secrets API
```

### 2.3. Shakapacker upgrade

In our efforts to continuously upgrade the platform, we are upgrading Shakapacker to the latest version available. That is v8.3.0 at the time of this release. If you encounter any error similar to this one:

```console
**ERROR** Shakapacker: Shakapacker gem and node package versions do not match
Detected: 7.x.x
     gem: 8.3.0
Ensure the installed version of the gem is the same as the version of
your installed node package.
Do not use >= or ~> in your Gemfile for shakapacker without a lockfile.
Do not use ^ or ~ in your package.json for shakapacker without a lockfile.
```

Please check if you have the following file `package.json`, and edit the version:

```json
    "shakapacker": "~8.3.0",
```

If the file does not exist, check and perform the same changes in the `packages/webpacker/package.json`

You can read more about this change on PR [#15016](https://github.com/decidim/decidim/pull/15016).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Change of Valuator for Evaluator

We have updated the terminology of Valuator at a code base level throughout the platform. The role of Valuator is now Evaluator. With this change also affects strings, i18n translations and so on.

Implementors must run the following 3 tasks:

```bash
bin/rails decidim:upgrade:decidim_update_valuators
bin/rails decidim:upgrade:decidim_action_log_valuation_assignment
bin/rails decidim:upgrade:decidim_paper_trail_valuation_assignment
```

These tasks migrate the old data to the new names.

More information about this change can be found on PR [#13684](https://github.com/decidim/decidim/pull/13684).

### 3.2. Convert nicknames to lowercase

As of [#14272](https://github.com/decidim/decidim/pull/14272) we are migrating all the nicknames to lowercase fix performance issues which affects large databases having many participants.

To apply the fix on your application, you need to run the below command.

```bash
bin/rails decidim:upgrade:fix_nickname_casing
```

You can read more about this change on PR [#14272](https://github.com/decidim/decidim/pull/14272).

### 3.3. Removal of invalid user exports

We have noticed an edge case when using private export functionality, in which the page becomes inaccessible if the user in question is using export single survey answer functionality.

You can run the following rake task to ensure your system is not corrupted.

```bash
bin/rails decidim:upgrade:clean:invalid_private_exports
```

For ease of in operations, we also added the above command to the main `decidim:upgrade:clean:invalid_records` rake task.

You can read more about this change on PR [#14638](https://github.com/decidim/decidim/pull/14638).

### 3.4. SMS authorization changes

As we have changed the authorization signature method for SMS, you will need to remove any authorizations that you may have. We are asking you to do this, in order to force your user base to reauthorize.

To remove it, you just need to run the below task.

```bash
bin/rails decidim:verifications:revoke:sms
```

You can read more about this change on PR [#14426](https://github.com/decidim/decidim/pull/14426)

### 3.5. Permission rename in surveys module

As we have changed the terminology surveys from "answer" to "respond", we need to make sure that your already set permissions are still working.

To ensure that, you just need to run the below task.

```bash
bin/rails decidim_surveys:upgrade:fix_survey_permissions
```

You can read more about this change on PR [#14940](https://github.com/decidim/decidim/pull/14940).

### 3.6. User Groups removal

As part of our efforts to simplify the experience for organizations, the "User Groups" feature has been deprecated. All previously existing User Groups has been converted into regular participants able to sign in providing the email and a password. The users with access to the email associated with the User Group will be able to set a password.

There are some tasks to notify users affected by the changes, transfer authorships and remove deprecated references to groups. All of them can be executed in a main task:

```bash
bin/rails decidim:upgrade:user_groups:remove
```

The tasks can also be executed one by one:

|------|------|
|Task  | Description |
|------|------|
| `bin/rails decidim:upgrade:user_groups:send_reset_password_instructions` | An email will be sent to the email address associated with the User Group, informing them of the deprecation of User Groups and instructing them to define a password for the newly converted profile. |
| `bin/rails decidim:upgrade:user_groups:send_user_group_changes_notification_to_members` | To notify group members and admins associated with the User Group with an email explaining the changes and how to access the shared profile |
| `bin/rails decidim:upgrade:user_groups:transfer_user_groups_authorships` | To migrate the authorships and coauthorships of the old groups and assign to the new regular users |
| `bin/rails decidim:upgrade:user_groups:fix_user_groups_action_logs` | To avoid exceptions accessing to the activities log in the admin panel displaying activities associated with user groups |
| `bin/rails decidim:upgrade:user_groups:remove_groups_notifications` | To avoid exceptions trying to display notifications associated with deprecated groups events |
|------|------|

You can read more about this change on PR [#14130](https://github.com/decidim/decidim/pull/14130).

### 3.7. AWS/Azure/Google Cloud assets storage

There is a bug related to the cache expiration using Active Storage (assets, such as images). For fixing this issue, the Rails team added an extra active storage parameter, `public: true` that you can add it to your storage configuration. If you followed the step `2.2. Deprecation of Rails.application.secrets` and changed your `config/storage.yml` file you don't need to do anything else.

This will also change the URL that is used, so you will need to update your [Content Security Policy](https://docs.decidim.org/en/develop/customize/content_security_policy.html), adding the new URL in the policies "default-src", "img-src", "media-src", and "connect-src". For instance, in the case of S3 with AWS, the format of the URL is the following:  `https://BUCKET-NAME.s3.amazonaws.com/ASSET_ID`.

Apart of that, you also need to configure your preferred cloud service provider to support this. We recommend you to follow the Rails official guide for [Active Storage configuration](https://guides.rubyonrails.org/v7.0/active_storage_overview.html#setup).

You can read more about this change on PR [#15005](https://github.com/decidim/decidim/pull/15005/).

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. Automatic deletion of inactive accounts

To reduce database clutter and automatically manage inactive user accounts, we have introduced a scheduled task to delete accounts that have been inactive for a configurable period (default: 365 days).

Before deletion, the system will send two notification emails:

- The first email is sent **30 days** before the scheduled deletion.
- The second email is sent **7 days** before the deletion deadline.

Participants can prevent their account from being deleted by logging in before the deadline. A final email will be sent to inform the user once their account has been permanently deleted.

To enable automatic deletion, add the following scheduled task to your cron jobs:

```bash
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:participants:delete_inactive_participants
```

By default, the inactivity period is set to 365 days, but it can be customized by passing a parameter to the task. For example:

```bash
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:participants:delete_inactive_participants[500]
```

Make sure your `sidekiq.yml` includes the `delete_inactive_participants` queue. If it is missing, patch your `config/sidekiq.yml`:

```yaml
:concurrency: <%= ENV.fetch("SIDEKIQ_CONCURRENCY", 5) %>
:queues:
  - [default, 2]
  - [delete_inactive_participants, 2]
  - (...)
```

You can read more about this change on PR [#13816](https://github.com/decidim/decidim/issues/13816).

### 4.2. Removal of Metrics

The **Metrics** feature has been completely removed. Use the **Statistics** feature instead.

If your application includes the `metrics` queue in `config/sidekiq.yml` or scheduled tasks in `config/schedule.yml`, make sure to remove them. Additionally make sure you remove the metrics crons from your crontab.

You can read more about this change on PR [#14387](https://github.com/decidim/decidim/pull/14387)

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

### 5.3. Extended OAuth application capabilities for integrating external participant-facing applications

Decidim has been able to act as the authentication authority for external applications through the OAuth applications
feature available at the `/system` panel. The OAuth features have been extended by adding the capability to integrate
external participant-facing third party applications to Decidim with OAuth. The external applications are able to
provide OAuth authentication for their users as well as utilize the issued OAuth tokens to perform certain actions
through the Decidim API representing the signed in user (such as creating a new comment from an external application).

By default, the OAuth access tokens are valid for 120 minutes. You can change this setting through
`DECIDIM_OAUTH_ACCESS_TOKEN_EXPIRES_IN` environment variable to make these tokens valid for a longer period. You can
also enable refresh tokens for the OAuth applications from the `/system` panel in case you need to access the API as the
signed in user for a longer time period.

You can read more about these changes on PR [#14225](https://github.com/decidim/decidim/pull/14225).

### 5.4. Changed scopes for OAuth authorization requests

In previous versions, there was only a single OAuth scope defined for external OAuth applications to request during the
[OAuth authorization request](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.1). The scope was previously
named `public` indicating that it allows the external application to fetch information about the signed in user through
the `/oauth/me` endpoint in order to use these details in the integrated application.

This scope was misleadingly named as this information is not public. This information is very private and sensitive user
information, and contains also the user's email address which is not public information.

This scope has been renamed to `profile`, so if you have defined the `scope` parameter in the external application's
OAuth authorization request, you need to change `public` to `profile` within that parameter. If you have not defined the
`scope` parameter for the authorization request, you do not have to make any changes as the `profile` scope is
automatically assigned as the default scope in case it is not defined within the authorization request.

Additionally, the following OAuth scopes have been introduced in order to allow external applications to represent the
user through the API:

- `user` - The authenticated user is able to perform actions within Decidim representing themselves when authenticated
  with the API.
- `api:read` - The authenticated user is able to read data through the Decidim API when authenticated with the API.
- `api:write` - The authenticated user is able to write data through the Decidim API when authenticated with the API.

Note that for the `api:write` scope to work, you additionally need to request the `user` scope as well in order to
represent the user which is necessary for most writing operations within Decidim. It is also highly recommended to
request the `api:read` scope because otherwise the responses from the API mutations would be otherwise empty, even if
the mutation itself was successful.

The Decidim system administrator defines which of these scopes are available to the external applications when
configuring the OAuth application through the Decidim `/system` panel. By default, only the `profile` scope is enabled,
so there is no changes to the capabilities of existing OAuth applications.

You can read more about these changes on PR [#14225](https://github.com/decidim/decidim/pull/14225).

### 5.5. API users for machine-to-machine integrations

This version provides a new concept of API users that can be used to integrate automations with Decidim, i.e.
applications where a Decidim user is not directly interacting with the application. Such integrations could include, for
example, external application publishing proposal answers or meeting reports in Decidim automatically based on data
available in an external system without requiring a Decidim administrator to manually copy-paste this data to the
Decidim administration interface.

In order to create such integrations, create API credentials (i.e. an API key and secret) through the `/system` panel,
sign in to the API with these credentials, perform the required automation through the API, and finally sign out from
the API. Such machine-to-machine integrations should only perform automated administrative tasks without any user
interaction. In case you need the end user to represent themselves through the API, please create an OAuth integration
instead, where the user authorizes the external application to represent them within Decidim.

You can read more about these changes on PR [#14225](https://github.com/decidim/decidim/pull/14225).

### 5.6. Possibility to force API authentication

There are times that we need to let only authenticated users to use the API. This configuration option filters out unauthenticated users from accessing the API endpoint. You need to add `DECIDIM_API_FORCE_API_AUTHENTICATION=1` to your environment variables if you want to enable this feature.

You can read more about this change on PR [#14225](https://github.com/decidim/decidim/pull/14225).

### 5.7. JWT token based API authentication

This change provides a new endpoint for API authentication and a method to check for an active authentication token
header for each request, based on [Devise::JWT](https://github.com/waiting-for-dev/devise-jwt).

For this to work, you need to add a secret key that will be used by devise-jwt to sign the tokens. Add
`DECIDIM_API_JWT_SECRET` environment variable to enable the JWT based API authentication for your users. In case you do
not need API authentication, this is not required.

Also, you can set the JWT expiration time through `DECIDIM_API_JWT_EXPIRES_IN` environment variable. This defines the
validity period for the tokens in minutes. The default is set to the same value as
`DECIDIM_OAUTH_ACCESS_TOKEN_EXPIRES_IN`.

You can generate the key from the console by running:

```ruby
bundle exec rails secret
```

You can read more about this change on PR [#14225](https://github.com/decidim/decidim/pull/14225).

### 5.8 Initiatives digital signature process change

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

### 5.9. Migrate signature configuration of initiatives types

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
