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
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
```

### 1.3. Follow the steps and commands detailed in these notes

#### 1.3.1 Config Parameter change

Prior to 0.28, Decidim offered the possibility of configuring the a list of disallowed domains used to restrict user access using either `Decidim.password_blacklist` or environment variable `DECIDIM_PASSWORD_BLACKLIST`. While upgrading to 0.28, those methods have been renamed as follows:

`Decidim.password_blacklist` becomes `Decidim.denied_passwords`
`DECIDIM_PASSWORD_BLACKLIST` becomes `DECIDIM_DENIED_PASSWORDS`

## 2. General notes

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Tailwind CSS introduction

Decidim redesign has introduced Tailwind CSS framework to compile CSS. It integrates with Webpacker, which generates Tailwind configuration dynamically when Webpacker is invoked.

You'll need to add `tailwind.config.js` to your app `.gitignore`. If you generate a new Decidim app from scratch, that entry will already be included in the `.gitignore`.

You can read more about this change on PR [\#9480](https://github.com/decidim/decidim/pull/9480).

### 3.2. Added Procfile support

In [\#10519](https://github.com/decidim/decidim/pull/10519) we have added Procfile support to ease up the development of Decidim instances. In order to install `foreman` and the `Procfile.dev`, you need to run the following command:

```console
bundle exec rake decidim:procfile:install
```

After this command has been ran, a new command will be available in your `bin/`, so in order to boot up your application you will just need to run

```console
bin/dev
```

Additional notes on Procfile:

In some cases, when running in a containerized environment, you may need to manually edit the `config/webpacker.yml` to edit the host parameter from `host: localhost` to `host: 0.0.0.0`

In some other cases when you run your application on a custom port (other than 3000), you will need to edit the `Procfile`, and add the parameter. `web: bin/rails server -b 0.0.0.0 -p 3000`

### 3.3 User moderation panel changes

In older Decidim installations, when blocking an user directly from the participants menu, without being previously reported, it will hide that user, making it unavailable in the Reported Participants section. You will need to run this command once to make sure there are no users or entities that got blocked but are not visible in the participants listing.

```console
bundle exec rake decidim:upgrade:moderation:fix_blocked_user_panel
```

You can read more about this change on PR [\#10521](https://github.com/decidim/decidim/pull/10521).

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
 with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. Automatically change active step in participatory processes

We have added the ability to automatically change the active step of participatory processess. This is an optional behavior that system admins can enable by configuring a cron job. The frequency of the cron task should be decided by the system admin and depends on each platform's use cases. A precision of 15min is enough for most cases. An example of a crontab job may be:

```bash
*/15 * * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim_participatory_processes:change_active_step
```

Each time the job executes it checks all currently active and published participatory processes and for each, it checks the steps with the date range in the current date. If a change should be made, it deactivates the previous step and activates the next step.

Platform administrators will always have the possibility to manually change phases, although if a cron job is configured the change may be undone.

This feature also changes the step `start_date` and `end_date`  fields to timestamps.

You can read more about this change on PR [\#9026](https://github.com/decidim/decidim/pull/9026).

### 4.2. Social Share Button change

As the gem that we were using for sharing to Social Network do not support Webpacker, we have implemented the same functionality in `decidim-core`.

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

### 4.3. Password validator configuration

Decidim implements several password strength checks that ensure the platforms participants and admins are not using weak passwords. One of these validation rules includes checking the user's password against the domain parts of the website, such as `foo.example.org`. The validation ensures that in this case the user's password does not contain the words `foo` or `example`.

This check turned out to be problematic for short subdomains, such as the one in the presented example. Because of this, a new configuration was added to configure the minimum length of a domain part to match against the user's password. The default configuration for this is four characters meaning any domain part shorter than this limit will not be included in this validation rule.

The default value is 4 characters, to change this value you can change the configuration:

```ruby
# In config/initializers/decidim.org

Decidim.configure do |config|
  config.password_similarity_length = 4
end
```

## 5. Changes in APIs

### 5.1. Tailwind CSS instead of Foundation

In this version we are introducing Tailwind CSS as the underlying layer to build the user interface on. In the previous versions, we used Foundation but its development stagnated which led to changing the whole layer that we are using to build user interfaces on.

This means that in case you have done any changes in the Decidim user interface or developed any modules with participant facing user interfaces, you need to do changes in all your views, partials and view components (aka cells).

Tailwind is quite different from Foundation and it does not support the old classes and markup that we used to use with Foundation. You will need to update all your views according to the new user interface conventions. You should always aim to follow the styling in the core and utilize the same components that the core provides in order to provide a consistent user experience.

You can read more about this change on PR [\#9480](https://github.com/decidim/decidim/pull/9480).

You can read more about Tailwind from the [Tailwind documentation](https://tailwindcss.com/docs/utility-first).

### 5.2. Automated authorization conflict handling for deleted users

In previous Decidim versions authorization conflicts (i.e. authorizing the user with the same unique data as a previous user) needed to be always handled manually. Now these are automatically handled for cases where the original user had authorized their account, then deleted their account and finally authorized the new account with the same details as the previous account.

This means that some participation data bound to the previous deleted user account is now automatically transferred over to the new account during the authorization process to prevent e.g. duplicate votes in budgeting votings (note that duplicate votes have never been possible but this PR improves the participant experience for any person trying to do that). This includes any data that may or may not require an authorization through the component permissions because in Decidim we cannot be always perfectly sure when an authorization is required for the action or not. As an example, budget voting can start without an authorization and if the admin decides to configure an authorization for the component one day after the voting started, we need to assume that the all votes in that component required an authorization. Otherwise we would potentially allow multiple votes from the users that voted before the authorization was configured if they decided to create a new account to vote for a second time or deleted their original account and did that.

The transferred data can differ between the different modules but the official modules handle the following data automatically:

- **decidim-core**
  - Amendments (meaning any amendments for amendable records in different modules, such as proposals at `decidim-proposals`)
  - Coauthorships (meaning any coauthorable records in different modules, such as proposals and collaborative drafts at `decidim-proposals`)
  - Endorsements (for any records, e.g. blog posts at `decidim-blogs`, debates at `decidim-debates` and proposals at `decidim-proposals`)
- **decidim-blogs**
  - Blog posts
  - Endorsements for blog posts (through endorsement transfers at `decidim-core`)
- **decidim-budgets**
  - Budgeting votes (or orders as we call them in the code)
- **decidim-comments**
  - Comments
  - Comment votes
- **decidim-consultations**
  - Consultation votes
- **decidim-debates**
  - Debates
  - Endorsements for debates (through endorsement transfers at `decidim-core`)
- **decidim-elections**
  - Election votes
  - Election form answers (through form answer transfers at `decidim-forms`)
  - Feedback form answers (through form answer transfers at `decidim-forms`)
- **decidim-forms**
  - Form answers (for different forms, such as survey form answers at `decidim-surveys` or registration form answers at `decidim-meetings`)
- **decidim-initiatives**
  - Initiatives
  - Initiative votes/signatures
- **decidim-meetings**
  - Meetings
  - Meeting registrations
  - Meeting poll answers
  - Meeting registration form answers (through form answer transfers at `decidim-forms`)
- **decidim-proposals**
  - Proposal votes/supports
  - Proposals (through coauthorship transfers at `decidim-core`)
  - Collaborative drafts (through coauthorship transfers at `decidim-core`)
  - Proposal amendments (through amendment transfers at `decidim-core`)
  - Endorsements for proposals (through endorsement transfers at `decidim-core`)
- **decidim-surveys**
  - Survey form answers (through form answer transfers at `decidim-forms`)

If external modules need to transfer records between accounts during the authorization transfers, module developers can define the following initializer at their modules (note that coauthorable records are automatically already handled):

```ruby
module Decidim
  module YourModule
    class Engine < ::Rails::Engine
      # ...
      initializer "decidim_your_module.authorization_transfer" do
        Decidim::AuthorizationTransfer.register(:your_module) do |transfer, auth_hander|
          # Define the record class as the first argument to be moved to the
          # new user and the column name as the second argument that maps the
          # record to the original user. This will update all records that match
          # the old deleted account to the new user that was authorized using
          # conflicting authorization data. If you need access to the
          # authorization handler that caused the transfer to be initiated, it
          # is available as the second yielded argument (auth_hander).
          transfer.move_records(Decidim::YourModule::Foo, :decidim_author_id)
        end
      end
      # ...
    end
  end
end
```

By default you should handle transfer of all records that can require an authorization and leave instance implementers the possibility to disable those transfers if they want to as explained below.

If you would like to disable the authorization transfers feature altogether, you can define the following code in your application class located at `config/application.rb` of your instance:

```ruby
module DecidimYourCity
  class Application < Rails::Application
    # ...
    config.to_prepare do
      Decidim::AuthorizationTransfer.disable!
    end
    # ...
  end
end
```

Note that when the functionality is disabled, the authorization transfers work as they used to, i.e. a conflict is registered, admin users are notified about the conflict situation and the conflict needs to be manually handled.

If you would like to disable the authorization transfers only for specific modules, you can define the following code in your application class located at `config/application.rb` of your instance (pick only the modules you want to disable):

```ruby
module DecidimYourCity
  class Application < Rails::Application
    # ...
    config.after_initialize do
      Decidim::AuthorizationTransfer.unregister(:core) # any coauthorable records, e.g. proposals and collaborative drafts
      Decidim::AuthorizationTransfer.unregister(:blogs) # blog posts
      Decidim::AuthorizationTransfer.unregister(:budgets) # budgets
      Decidim::AuthorizationTransfer.unregister(:comments) # comments
      Decidim::AuthorizationTransfer.unregister(:consultations) # consultation votes
      Decidim::AuthorizationTransfer.unregister(:debates) # debates
      Decidim::AuthorizationTransfer.unregister(:elections) # elections
      Decidim::AuthorizationTransfer.unregister(:forms) # form answers, e.g. survey form answers or meeting registrations
      Decidim::AuthorizationTransfer.unregister(:initiatives) # initiatives and initiative votes/signatures
      Decidim::AuthorizationTransfer.unregister(:meetings) # meetings, meeting registrations and meeting poll answers
      Decidim::AuthorizationTransfer.unregister(:proposals) # proposal votes/supports

      # Or if you want to unregister multiple modules at once
      Decidim::AuthorizationTransfer.unregister(:blogs, :forms, :comments)
    end
    # ...
  end
end
```

Note that when unregistering an authorization transfer handler, the transfers will still work normally for the other transfer handlers and no conflicts are reported for the admin users in case of conflict situation between a new authorization and a previous authorization for a deleted user. In this case, the authorization is transferred to the new user normally but the unregistered transfer handlers are not called which means those records will not be transferred between the user accounts. For conflicts between normal registered users or managed users, the conflicts are still reported as before. The automated authorization transfers only happen in case the previously authorized conflicting user account was deleted.

You can read more about this change at PR [\#9463](https://github.com/decidim/decidim/pull/9463).
