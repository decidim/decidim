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
bin/rails decidim:upgrade:fix_nickname_casing
```

### 1.4. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Hiding comments of moderated resources

We have noticed that when a resource (ex: Proposal, Meeting) is being moderated, the associated comments are left visible in the search. We have added a task that would allow you to automatically remove from search any comment belonging to moderated content:

```bash
bin/rails decidim:upgrade:clean:hidden_resources
```

### 2.2. User Groups removal

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

### 2.3. [[TITLE OF THE ACTION]]

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

### 3.2. Convert nicknames to lowercase

As of [#14272](https://github.com/decidim/decidim/pull/14272) we are migrating all the nicknames to lowercase fix performance issues which affects large databases having many participants.

To apply the fix on your application, you need to run the below command.

```bash
bin/rails decidim:upgrade:fix_nickname_casing
```

You can read more about this change on PR [#14272](https://github.com/decidim/decidim/pull/14272).

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

```ruby
# Explain the usage of the API as it is in the new version
result = 1 + 1 if after
```

### 5.2. Add force_api_authentication configuration options

There are times that we need to let only authenticated users to use the API. This configuration option filters out unauthenticated users from accessing the api endpoint. You need to add `DECIDIM_API_FORCE_API_AUTHENTICATION` to your environment variables if you want to enable this feature.
