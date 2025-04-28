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
bundle remove spring spring-watcher-listen
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails decidim:upgrade:clean:invalid_records
bin/rails decidim_proposals:upgrade:set_categories
bin/rails decidim:upgrade:fix_nickname_casing
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

### 2.6. Clean deleted user records `decidim:upgrade:clean:clean_deleted_users` task

When a user deleted their account, we mistakenly retained some metadata, such as the personal_url and about fields. Going forward, these fields will be automatically cleared upon deletion. To fix this issue for previously deleted accounts, we've added a new rake task that should be run on your production database.

```ruby
bin/rails decidim:upgrade:clean:clean_deleted_users
```

You can read more about this change on PR [#13624](https://github.com/decidim/decidim/pull/13624).

### 2.7. Fixes on migration files

Since we have introduced the "Soft delete for spaces and components" [#13297](https://github.com/decidim/decidim/pull/13297), we have noticed there are some migrations that are failing as a result of defaults scopes we added.
To address the issue, we created a script that will update the migration files in your project so that we can fix any migrations that are potentially broken by the code evolution.
We added as part of the upgrade script, so you do not need to do anything about it.

You can read more about this change on PR [#13690](https://github.com/decidim/decidim/pull/13624).

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

### 3.4. Convert old categorization models (Categories, Scopes, Areas, Participatory Process and Assembly types) into taxonomies

All those models have been deprecated, now a unique entity called "Taxonomies" is used for classifying all the content in Decidim (see https://docs.decidim.org/en/develop/develop/taxonomies.html for reference).

A rake task is available for converting the old classification to the new system composed of taxonomies and taxonomy filters.

In a nutshell, you can run this two-step process with the commands:

First, create the plan for the import:

```bash
bin/rails decidim:taxonomies:make_plan
```

Second, review the created files under the folder `tmp/taxonomies/*.json` (optional).

Finally, import the taxonomies with:

```bash
bin/rails decidim:taxonomies:import_all_plans
```

Once the import has finished, update the metrics:

```bash
bin/rails decidim:taxonomies:update_all_metrics
```

For more information about this process, please refer to the documentation at https://docs.decidim.org/en/develop/develop/taxonomies.html#_importing_taxonomies_from_old_models_categories_scopes_etc

You can see more details about this change on PR [\#13669](https://github.com/decidim/decidim/pull/13669)

### 3.5. Social login changes

We have changed the icons for the social logins so they align better with the social networks guidelines (Twitter/X, Facebook, and Google). If you do not use any of these social logins you can skip this step.

If on the other hand you have set up this social logins, you can change it by replacing them in: `config/secrets.yml`.

For example, where it says:

```secrets.yaml
      icon: google-fill
      icon: facebook-fill
      icon: twitter-x-fill
```

It now needs to say for the correct path name and updated SVG. Keep in mind the name of the path has changed from ```icon``` to ```icon_path```:

```secrets.yaml
      icon_path: "media/images/google.svg"
      icon_path: "media/images/facebook.svg"
      icon_path: "media/images/twitter-x.svg"
```

The CSS of each omniauth button can be found within `decidim-core/app/packs/stylesheets/decidim/_login.scss`, variables are used for specific omniauth button background color according to their pack guidelines.

You can read more about this change on PR [#13481](https://github.com/decidim/decidim/pull/13481).

### 3.6. Changes in Static maps configuration when using HERE.com

As of [#14180](https://github.com/decidim/decidim/pull/14180) we are migrating to here.com api V3, as V1 does not work anymore. In case your application uses Here.com as static map tile provider, you will need to change your `config/initializers/decidim.rb` to use the new url `https://image.maps.hereapi.com/mia/v3/base/mc/overlay`:

```ruby
  static_url = "https://image.maps.ls.hereapi.com/mia/1.6/mapview" if static_provider == "here" && static_url.blank?
```

to

```ruby
  static_url = "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" if static_provider == "here" && static_url.blank?
```

You can read more about this change on PR [#14180](https://github.com/decidim/decidim/pull/14180).

### 3.7. Convert nicknames to lowercase

As of [#14272](https://github.com/decidim/decidim/pull/14272) we are migrating all the nicknames to lowercase fix performance issues which affects large databases having many participants.

To apply the fix on your application, you need to run the below command.

```bash
bin/rails decidim:upgrade:fix_nickname_casing
```

You can read more about this change on PR [#14272](https://github.com/decidim/decidim/pull/14272).

### 3.8. [[TITLE OF THE ACTION]]

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

### 5.2. Changes in the routing

As we were upgrading the application to Rails 7.1, we have noticed there are some changes in the routing system that led us to change the way participatory space mounting points are being used by Decidim. This applies to implementers or developers that define their own routes in their modules. If you do not change the routes in your application nor a module then you do not need to do anything.

Previously, the participatory space routes were mounted like follows in either the Core or Admin.

```ruby
  Decidim.participatory_space_manifests.each do |manifest|
    mount manifest.context(:admin).engine, at: "/", as: "decidim_admin_#{manifest.name}"
  end
```

As of [\#13294](https://github.com/decidim/decidim/pull/13294), we have changed the way of mounting. Now, each one of the Participatory Spaces are being installed specifically from their own modules like follows:

```ruby
  initializer "decidim_assemblies.mount_routes" do
    Decidim::Core::Engine.routes do
      mount Decidim::Assemblies::Engine, at: "/", as: "decidim_assemblies"
    end
  end
```

This particular change in the way we mount things, applies also for `Comments` and `Verifications` modules.

#### 5.2.1. Module developers

As a module developer, when you add a new admin section you should always check if the admin is accessible to registered participants or visitors. If that is the case, you must always wrap your admin routes in a constraint like:

```ruby
  routes do
    constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
      resources :my_module
    end
  end
```

You can read more about this change on PR [#13294](https://github.com/decidim/decidim/pull/13294).

### 5.3. [[TITLE OF THE CHANGE]]

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
