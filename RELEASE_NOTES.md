# Release Notes

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.2. Run these commands

```console
sudo apt install wkhtmltopdf # or the alternative installation process for your operating system. See "2.7. wkhtmltopdf binary change"
bundle remove spring spring-watcher-listen
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails decidim:upgrade:clean:invalid_records
bin/rails decidim_proposals:upgrade:set_categories
```

### 1.3. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Cleanup invalid resources

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

### 2.2. Refactor of `decidim:upgrade:fix_orphan_categorizations` task

As of [#13380](https://github.com/decidim/decidim/pull/13380), the task named `decidim:upgrade:fix_orphan_categorizations` has been renamed to `decidim:upgrade:clean:categories` and has been included in the main `decidim:upgrade:clean:invalid_records` task.

You can read more about this change on PR [#13380](https://github.com/decidim/decidim/pull/13380).

### 2.3 Cells expiration time

Now the cache expiration time is configurable via initializers/ENV variables.

Decidim uses cache in some HTML views (usually under the `cells/` folder). In the past the cache had no expiration time, now it is configurable using the ENV var `DECIDIM_CACHE_EXPIRATION_TIME` (this var expects an integer specifying the number of minutes for which the cache is valid).

Also note, that now it comes with a default value of 24 hours (1440 minutes).

You can read more about this change on PR [#13402](https://github.com/decidim/decidim/pull/13402).

### 2.4. Ransack upgrade

As part of Rails upgrade to version 7.1, we upgraded Ransack gem to version 4.2. Ransack has introduced a new security policy that requires mandatory allowlisting for the attributes and associations needed by search engine. If you have a regular Decidim installation, you can skip this step.

If you are a plugin developer, you may need to add the following methods to your searchable models.

If your plugins are extending the filters or search, you may need to override the following methods.

```ruby
def self.ransackable_attributes(_auth_object = nil)
  []
end

def self.ransackable_associations(_auth_object = nil)
  []
end
```

You can read more about this change on PR [#13196](https://github.com/decidim/decidim/pull/13196).

### 2.5. Amendments category fix

We have identified a bug in the filtering system, as the amendments created did not share the category with the proposal it amended. This fix aims to fix historic data. To fix it, you need to run:

```shell
bin/rails decidim_proposals:upgrade:set_categories
```

You can read more about this change on PR [#13395](https://github.com/decidim/decidim/pull/13395).

### 2.6. wkhtmltopdf binary change

For improving the support with latest versions of Ubuntu, and keeping a low size in Heroku/Docker images, we removed the `wkhtmltopdf-binary` gem dependency. This means that your package manager should have the `wkhtmltopdf` binary installed.

In the case of Ubuntu/Debian, this is done with the following command:

```bash
sudo apt install wkhtmltopdf
```

You can read more about this change on PR [#13616](https://github.com/decidim/decidim/pull/13616).

### 2.7. Clean deleted user records `decidim:upgrade:clean:clean_deleted_users` task

When a user deleted their account, we mistakenly retained some metadata, such as the personal_url and about fields. Going forward, these fields will be automatically cleared upon deletion. To fix this issue for previously deleted accounts, we've added a new rake task that should be run on your production database.

```ruby
bin/rails decidim:upgrade:clean:clean_deleted_users
```

You can read more about this change on PR [#13624](https://github.com/decidim/decidim/pull/13624).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Remove spring and spring-watcher-listen from your Gemfile

To simplify the upgrade process, we have decided to add `spring` and `spring-watcher-listener` as hard dependencies of `decidim-dev`.

Before upgrading to this version, make sure you run in your console:

```bash
bundle remove spring spring-watcher-listen
```

You can read more about this change on PR [#13235](https://github.com/decidim/decidim/pull/13235).

### 3.2. Clean up orphaned attachment blobs

We have added a new task that helps you clean the orphaned attachment blobs. This task will remove all the attachment blobs that have been created for more than 1 hour and are not yet referenced by any attachment record. This helps cleaning your filesystem of unused files.

You can run the task with the following command:

```bash
bin/rails decidim:upgrade:attachments_cleanup
```

You can see more details about this change on PR [\#11851](https://github.com/decidim/decidim/pull/11851)

### 3.3. Add Meetings' attendees metric

We have added a new metric that indicates how many users have attended your meetings.

If you want to calculate this metric you could run the following command, where 2019-01-01 is the Y-m-d format for the starting date since you want the metric to take effect.

```bash
./bin/rails decidim:metrics:rebuild[meetings,2019-01-01]
```

You can see more details about this change on PR [\#13442](https://github.com/decidim/decidim/pull/13442)

### 3.4. [[TITLE OF THE ACTION]]

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

### 5.1. Decidim version number no longer disclosed through the GraphQL API by default

In previous Decidim versions, you could request the running Decidim version through the following API query against the GraphQL API:

```graphql
query { decidim { version } }
```

This no longer returns the running Decidim version by default and instead it will result to `null` being reported as the version number.

If you would like to re-enable exposing the Decidim version number through the GraphQL API, you may do so by setting the `DECIDIM_API_DISCLOSE_SYSTEM_VERSION` environment variable to `true`. However, this is highly discouraged but may be required for some automation or integrations.

### 5.2 New configuration option for geolocation input forms

Now a button to use the user's device location is enabled by default in Decidim. However this can be disabled with the new configuration option `show_my_location_button`, also available as an ENV var `DECIDIM_SHOW_MY_LOCATION_BUTTON`.

You can decide to enable it in a specific component only (eg "proposals") or everywhere (by default).

Example:

Use only "my location button" in meetings and proposals:

```bash
DECIDIM_SHOW_MY_LOCATION_BUTTON=meetings,proposals
```

or in an initializer:

```ruby
Decidim.configure do |config|
  config.show_my_location_button = [:meetings, :proposals]
end
```

the default value is `:all` equivalent to:

```bash
DECIDIM_SHOW_MY_LOCATION_BUTTON=all
```

or in an initializer:

```ruby
Decidim.configure do |config|
  config.show_my_location_button = [:all]
end
```
