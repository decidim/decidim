# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

#### 1.1. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

#### 1.2. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
```

#### 1.3. Follow the steps and commands detailed in these notes

### 2. General notes

### 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

#### 3.1. Tailwind CSS introduction

Decidim redesign has introduced Tailwind CSS framework to compile CSS. It integrates with Webpacker, which generates Tailwind configuration dynamically when Webpacker is invoked.

You'll need to add `tailwind.config.js` to your app `.gitignore`. If you generate a new Decidim app from scratch, that entry will already be included in the `.gitignore`.

You can read more about this change on PR [\#9480](https://github.com/decidim/decidim/pull/9480).

### 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
 with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

#### 4.1. Automatically change active step in participatory processes

We have added the ability to automatically change the active step of participatory processess. This is an optional behavior that system admins can enable by configuring a cron job. The frequency of the cron task should be decided by the system admin and depends on each platform's use cases. A precision of 15min is enough for most cases. An example of a crontab job may be:

```bash
*/15 * * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim_participatory_processes:change_active_step
```

Each time the job executes it checks all currently active and published participatory processes and for each, it checks the steps with the date range in the current date. If a change should be made, it deactivates the previous step and activates the next step.

Platform administrators will always have the possibility to manually change phases, although if a cron job is configured the change may be undone.

This feature also changes the step `start_date` and `end_date`  fields to timestamps.

You can read more about this change on PR [\#9026](https://github.com/decidim/decidim/pull/9026).

#### 4.2. Social Share Button change

As the gem that we were using for sharing to Social Network don't support Webpacker, we have implemented the same functionality in `decidim-core`.

If you want to have the default social share services enabled (Twitter, Facebook, WhatsApp and Telegram), then you can just remove the initializer in your application:

```console
rm config/initializers/social_share_button.rb
```

If you want to change the default social share services, you'll need to remove this initializer and add it to the Decidim initializer. We recommend doing it with the environment variables and secrets to be consistent with the rest of configurations.

```console
rm config/initializers/social_share_button.rb
```

```ruby
# In config/initializers/decidim.rb
Decidim.configure do |config|
(...)
  config.social_share_services = Rails.application.secrets.decidim[:social_share_services]
end
```

```ruby
# In config/secrets.yml
decidim_default: &decidim_default
(...)
  social_share_services: <%= Decidim::Env.new("DECIDIM_SOCIAL_SHARE_SERVICES", "Twitter, Facebook, WhatsApp, Telegram").to_array.to_json %>
```

And define your own services in the environment variable `DECIDIM_SOCIAL_SHARE_SERVICES` with the services that you want.

With this change you can also define your own services. See [documentation for social share services customization](https://docs.decidim.org/en/customize/social_shares/).

### 5. Changes in APIs

#### 5.1. Tailwind CSS instead of Foundation

In this version we are introducing Tailwind CSS as the underlying layer to build the user interface on. In the previous versions, we used Foundation but its development stagnated which led to changing the whole layer that we are using to build user interfaces on.

This means that in case you have done any changes in the Decidim user interface or developed any modules with participant facing user interfaces, you need to do changes in all your views, partials and view components (aka cells).

Tailwind is quite different from Foundation and it cannot

You can read more about this change on PR [\#9480](https://github.com/decidim/decidim/pull/9480).

You can read more about Tailwind from the [Tailwind documentation](https://tailwindcss.com/docs/utility-first).

### Detailed changes

#### Added

#### Changed

#### Fixed

#### Removed

## Previous versions

Please check [release/0.27-stable](https://github.com/decidim/decidim/blob/release/0.27-stable/CHANGELOG.md) for previous changes.
