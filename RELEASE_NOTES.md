# Release Notes

⚠️  Mind that our last stable version (v0.27.0) is more than one year old. Lots of things have happened in Decidim, so we recommend that you follow all the steps in this guide for updating your application. Enjoy the new design and features!

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your ruby and node versions

For ruby, if you're using rbenv, this is done with the following commands:

```console
rbenv install 3.1.1
rbenv local 3.1.1
```

If not, you need to adapt it to your environment. See "2.1. Ruby update to 3.1"

For node, if you're using nvm, this is done with the following commands:

```console
nvm install 18.17.1
nvm use 18.17.1
```

If not, you need to adapt it to your environment. See "2.2. Node update to 18.17"

### 1.2. Update your Gemfile

```ruby
gem "decidim", "0.28.0.rc1"
gem "decidim-dev", "0.28.0.rc1"
```

Comment out any of the 3rd party decidim modules that you're using in your Gemfile. You can uncomment them later after you've updated them.
Before upgrading to decidim 0.28.0.rc1, you need to manually comment out the `decidim-consulations` if you have it installed. This gem has been removed from the core and you need to remove it from your Gemfile as well.

Please note that sometimes you may get some errors, so please make sure you fully understand the output of the commands before continuing.

When running `bundle update decidim`, you may get some errors like the one below:

```console
Bundler could not find compatible versions for gem "faker":
  In snapshot (Gemfile.lock):
    faker (= 2.23.0)  # <<< This is the name of the name of the gem that you need to add to bundle update command

  In Gemfile:
    faker

    decidim-dev (= 0.28.0.rc1) was resolved to 0.28.0.rc1, which depends on
      faker (~> 3.2)
```

Please repeat the bundle command adding gems to the list until there the above error type disappears.

```console
bundle update decidim faker
```

### 1.3. Manual changes

In order to successfully run decidim 0.28.0.rc1, you will need to manually edit the following files:

#### 1.3.1. package.json

Edit the engines key to :

```json
  "engines": {
    "node": "18.17.1",
    "npm": ">=9.6.7"
  }
```

#### 1.3.2. babel.config.json

Edit the file, and remove, if present, the following lines:

```json
    [ "@babel/plugin-proposal-private-property-in-object", { "loose": true }],
    ["@babel/plugin-proposal-private-methods", { "loose": true }],
    ["@babel/plugin-proposal-class-properties", { "loose": true }]
```

##### 1.3.3. postcss.config.js

Replace the file content with:

```javascript
module.exports = {
  syntax: 'postcss-scss',
  plugins: [
    // postcss-import must be the very first plugin https://tailwindcss.com/docs/using-with-preprocessors#build-time-imports
    require('postcss-import'),
    require('tailwindcss'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }),
    require('autoprefixer')
  ]
}
```

### 1.4. Commands to run

```console
bundle update decidim
rm config/initializers/social_share_button.rb # for "4.2. Social Share Button change"
bin/rails decidim:upgrade
npm install
wget https://docs.decidim.org/en/develop/develop/consultations_removal.bash -O consultations_removal.bash  # For "2.4. Consultation module removal"
bash consultations_removal.bash # For "2.4. Consultation module removal"
bin/rails db:migrate
bin/rails decidim:procfile:install # For "3.3. Added Procfile support"
bin/rails decidim:robots:replace # for "3.11. Anti-spam measures in the robots.txt"
sed -i -e "/rackup      DefaultRackup/d" config/puma.rb # for "3.14. Puma syntax change"
```

Then there are some actions that needs to be done that depend in your customizations and configurations:

* Do you have any custom design in your application or a custom module? If yes, then you'll need to adapt your design to the new framework, Tailwind CSS. Check out "5.1. Tailwind CSS instead of Foundation"
* Do you have the decidim-consultations module installed in your application? If yes, you need to remove it and change some migrations. Check out "2.4. Consultation module removal"
* Do you have any custom module or external javascript/font/stylesheet/assets? If yes, you need to configure it. Check out "3.10. Add Content Security Policy (CSP) support"

* Have you integrated the SMS gateway? Then you may be interested in "5.5. Extra context argument added to SMS gateway implementations"
* Have you customized the `Decidim.password_blacklist` configuration or `DECIDIM_PASSWORD_BLACKLIST`. Then you need to adapt it, check out "5.6. Configuration parameter change"
* Are you using the print feature in Initaitives? Then you need to enable it manually, check out "5.7. Change in Initiatives configuration"

* Do you have any custom module or component that uses Decidim permissions? If yes, we recommend checking out the "5.2. Automated authorization conflict handling for deleted users" so it's consistent with the rest of the modules.
* Do you have any custom configuration/code with the WYSIWYG editor used until now (Quill.js)? If yes, then you'll need to adapt it to the new library (TipTap). Check out "5.3. Tiptap rich text editor"
* Do you have any custom module that implements the Report functionality? If yes, we recommend checking out "5.4. Ability to hide content of a user from the public interface" so it's consistent with the rest of the modules.

In the production environment there are some data migrations that need to be done:

```console
bin/rails decidim:upgrade:migrate_wysiwyg_content  # for "3.2. Content migration for rich text editor"
bin/rails decidim:upgrade:moderation:fix_blocked_user_panel # for "3.4. User moderation panel changes"
bin/rails decidim:content_blocks:initialize_default_content_blocks # for "3.6. Initialize content blocks on spaces or resources with landing page"
bin/rails decidim:proposals:upgrade:remove_valuator_orphan_records # for "3.8. Orphans valuator assignments cleanup"
bin/rails decidim:initiatives:upgrade:fix_broken_pages # for "3.9. Initiatives pages exception fix"
bin/rails decidim:upgrade:fix_duplicate_endorsements # for "3.12. Deduplicating endorsements"
bin/rails decidim:upgrade:fix_short_urls # for "3.13. Fix component short links"
```

In the production server, add the following scheduling task if you want to have participatory processes steps changing automatically

```crontab
*/15 * * * * cd /home/user/decidim_application && RAILS_ENV=production bin/rails decidim_participatory_processes:change_active_step # for "4.1. Automatically change active step in participatory processes"
```

For running the application in the development application you now have the command:

```console
./bin/dev
```

This is just a summary of all the most relevant changes done in this version. Keep reading to know the details of the relevant changes for your environmnet.

## 2. General notes

## 2.1. Ruby update to 3.1

We have updated the Ruby version to 3.1.1. Upgrading to this version will require either to install this Ruby version on your host, or change the decidim docker image to use ruby:3.1.1.

You can read more about this change on PR [#9449](https://github.com/decidim/decidim/pull/9449).

## 2.2. Node update to 18.17

We have updated the Node version to 18.17.1 Upgrading to this version will require either to install this Node version on your host, or adapt your decidim docker image.

You can read more about this change on PR [#11564](https://github.com/decidim/decidim/pull/11564).

## 2.3. Redesign

The design of the application has changed radically. The most relevant things to notice are:

* Improvements in the general user interface and experience, both for participants and administrators
* New module decidim-design, available by default in the development_app and optionally in other appllications. Avaialable at /design. I.e.: http://yourdomain.example.org/design
* Replacement of [Foundation CSS](https://get.foundation/) by [Tailwind CSS](https://tailwindcss.com/). You can read more about this change in the section "3.1. Tailwind CSS introduction" and also in "5.1. Tailwind CSS instead of Foundation".
* Introduction of Content Blocks for the Participatory Processes and Assemblies' landing pages. You can read more about this change in the section "3.6. Initialize content blocks on spaces or resources with landing page".
* Introduction of the mega-menu on desktop: improvements of the navigation based on breadcrumbs with extra information while hovering at the element.
* Simplification of the login form.

You can read more about this change by searching the PRs and issues with the label contract: redesign. At the moment we have more than [300 merged Pull Requests with this label](https://github.com/decidim/decidim/pulls?q=is%3Apr+sort%3Aupdated-desc+label%3A%22contract%3A+redesign%22+is%3Amerged).

## 2.4. Consultation module removal

The consultations module has been fully removed from this version, so if you're using it in your application you need to remove it from your Gemfile:

```console
bundle remove decidim-consultations
```

If you're not using it, then you don't need to do anything.

If you're maintaining a version of this module, please share the URL of the git repository by [creating an issue on the decidim.org website repository](https://github.com/decidim/decidim.org) so that we can update the [Modules page](https://decidim.org/modules).

There's an error with the migrations after you've removed this module. Note that this only happens when creating a new database. You'd need to change them like this:

```console
wget https://docs.decidim.org/en/develop/develop/consultations_removal.bash -O consultations_removal.bash
bash consultations_removal.bash
```

You can read more about this change on PR [#11171](https://github.com/decidim/decidim/pull/11171).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Tailwind CSS introduction

The redesign has introduced Tailwind CSS framework to compile CSS. It integrates with Webpacker, which generates Tailwind configuration dynamically when Webpacker is invoked.

There are some actions that you will need to do in your existing application that's already done in new applications:

* Add `tailwind.config.js` to your app's `.gitignore`.

```console
echo tailwind.config.js >> .gitignore
```

* Migrate your settings from your applications's `_decidim-settings.scss` file, available at `app/packs/stylesheets/decidim/_decidim-settings.scss`.
If you want to define the colors and other Tailwind related configurations, you can do it following the instructions on the documentation on how to [customize Tailwind](https://docs.decidim.org/en/develop/customize/styles.html#_tailwind_css).

* After that's done, remove your `_decidim-settings.scss` file.

```console
rm app/packs/stylesheets/decidim/_decidim-settings.scss
```

* Remove this comment from your `decidim-application.scss` file, available at `app/packs/stylesheets/decidim/decidim_application.scss`.

```javascript
// To override CSS variables or Foundation settings use _decidim-settings.scss
```

You can read more about this change on PR [\#9480](https://github.com/decidim/decidim/pull/9480).

### 3.2. Content migration for rich text editor

The rich text editor has been changed to a new editor named Tiptap. This change causes some changes in the HTML content structure stored in the database as well as in the CSS to display this content. We have introduced a new task to take care of the content migration for all components and models managed by the Decidim core modules. To migrate the content to the new structure, you need to run this task as follows:

```console
bin/rails decidim:upgrade:migrate_wysiwyg_content
```

Module developers may need to register their own models for the content migration or implement custom content migrations in case their modules contain any content that is managed through the rich text editors. To learn how to do this, please refer to the "Changes in APIs" section of this document.

In case you have done any customizations to the old editor, you will need to remove those customizations and re-do then on the APIs provided by Tiptap. You will also need to do changes in any CSS you have added or customized for displaying the editor content. To learn more about these new APIs, please refer to the "Changes in APIs" section of this document.

You can read more about this change on PR [\#10196](https://github.com/decidim/decidim/pull/10196).

### 3.3. Added Procfile support

We have added Procfile support to ease up the development of Decidim instances. In order to install `foreman` and the `Procfile.dev`, you need to run the following command:

```console
bin/rails decidim:procfile:install
```

After this command has been ran, a new command will be available in your `bin/`, so in order to boot up your application you will just need to run

```console
./bin/dev
```

Additional notes on Procfile:

In some cases, when running in a containerized environment, you may need to manually edit the `config/webpacker.yml` to edit the host parameter from `host: localhost` to `host: 0.0.0.0`

In some other cases when you run your application on a custom port (other than 3000), you will need to edit the `Procfile`, and add the parameter. `web: bin/rails server -b 0.0.0.0 -p 3000`

You can read more about this change on PR [\#10519](https://github.com/decidim/decidim/pull/10519).

### 3.4. User moderation panel changes

In older Decidim installations, when blocking an user directly from the participants menu, without being previously reported, it will hide that user, making it unavailable in the Reported Participants section. You will need to run this command once to make sure there are no users or entities that got blocked but are not visible in the participants listing.

```console
bin/rails decidim:upgrade:moderation:fix_blocked_user_panel
```

You can read more about this change on PR [\#10521](https://github.com/decidim/decidim/pull/10521).

### 3.5. Change Webpacker to Shakapacker

Since the Rails team has retired the Webpacker in favour or importmap-rails or js-bundling, we got ouserlves in a situation where performance improvements could not be performed.
In order to continue having support for Webpacker like syntax, we have switched to Shakapacker.

In order to perform the update, you will need to make sure that you **do not have webpacker in your Gemfile**.
If you have it, please remove it, and allow Decidim to handle the webpacker / shakapacker dependency.

#### Note for development

If you are using the `Procfile.dev` file, you will need to make sure that you have the following line in your configuration. If you have not altered the `Procfile.dev` file, you will not need to do anything, as we covered that part:

```console
shakapacker: ./bin/shakapacker-dev-server
```

In order to run your development server, you will need to run the following command:

```console
./bin/dev
```

Also, by migrating to Shakapacker, we no longer use `config/webpacker.yml`. All the webpack configuration will be done through `config/shakapacker.yml`

You can read more about this change on PR

* [\#10389](https://github.com/decidim/decidim/pull/10389)
* [\#11728](https://github.com/decidim/decidim/pull/11728)

### 3.6. Initialize content blocks on spaces or resources with landing page

The processes and assemblies participatory spaces have changed the show page and now is composed using content blocks. For the new spaces created in this version a callback is executed creating the content blocks marked as `default!` in the engine for the corresponding homepage scope. To have the same initialization in the existing spaces there is a task to generate those blocks if not present already. Run the below command to generate default content blocks when not present for all spaces and resources with content blocks homepage (participatory processes, participatory process groups and assemblies):

```console
bin/rails decidim:content_blocks:initialize_default_content_blocks
```

The task has some optional arguments:

* The first to specify the manifest name and generate the default content blocks only on the spaces or resources with the manifest name (`participatory_processes`, `participatory_process_group` or `assemblies`).
* The second can be the id of a resource o space to apply only on the space or resource with the id. This argument is considered only if the manifest name argument is present.
* The last argument only works on participatory spaces (assemblies and participatory processes) and when set as true the task also creates a content block for each published component on the space unless a block already exists for that component or the block exists for the component type and configured to display resources from all components of the same type.

For example, to generate the default content blocks and also the components blocks on participatory spaces run the command with arguments:

```console
bin/rails decidim:content_blocks:initialize_default_content_blocks[,,true]
```

### 3.7. Graphql upgrade

In [\#10606](https://github.com/decidim/decidim/pull/10606) we have upgraded the GraphQL gem to version 2.0.19. This upgrade introduces some breaking changes, so you will need to update your GraphQL queries to match the new API. This change should be transparent for most of the users, but if you have custom GraphQL queries, you will need to update them. Also, please note, there might be some issues with community plugins that offer support for GraphQL, so you might need to update them as well.

Please see the [change log](https://github.com/rmosolgo/graphql-ruby/blob/master/CHANGELOG.md) for graphql gem for more information.

### 3.8. Orphans valuator assignments cleanup

We have added a new task that helps you clean the valuator assignements records of roles that have been deleted.

You can run the task with the following command:

```console
bin/rails decidim:proposals:upgrade:remove_valuator_orphan_records
```

You can see more details about this change on PR [\#10607](https://github.com/decidim/decidim/pull/10607)

### 3.9. Initiatives pages exception fix

We have added a new tasks to fix a bug related to the pages component inside of the Initiatives module (`decidim-initiatives`).

You can run the task with the following command:

```console
bin/rails decidim:initiatives:upgrade:fix_broken_pages
```

You can see more details about this change on PR [\#10928](https://github.com/decidim/decidim/pull/10928)

### 3.10. Add Content Security Policy (CSP) support

We have introduced support for Content Security Policy (CSP). This is a security feature that helps to detect and mitigate certain types of attacks, including Cross Site Scripting (XSS) and data injection attacks.
By default, the CSP is enabled, and is configured to be as restrictive as possible, having the following default configuration:

```ruby
{
        "default-src" => %w('self' 'unsafe-inline'),
        "script-src" => %w('self' 'unsafe-inline' 'unsafe-eval'),
        "style-src" => %w('self' 'unsafe-inline'),
        "img-src" => %w('self' *.hereapi.com data:),
        "font-src" => %w('self'),
        "connect-src" => %w('self' *.hereapi.com *.jsdelivr.net),
        "frame-src" => %w('self'),
        "media-src" => %w('self')
}
```

In order to customize the CSP we are providing, have 2 options, either by using a configuration key the initializer `config/initializers/decidim.rb` or by setting values in the Organization's system admin.

Please read more in the docs:

* [Customize Content Security Policy](https://docs.decidim.org/en/develop/customize/content_security_policy)
* [Using Content Security Policy initializer](https://docs.decidim.org/en/develop/configure/initializer#_content_security_policy)

You can check more about the implementation in the [\#10700](https://github.com/decidim/decidim/pull/10700) pull request.

### 3.11. Anti-spam measures in the robots.txt

In order to improve the fight against spam attacks in Decidim applications, we have added a new task that helps you replace yours. Take into account that this will override your robots.txt, so if you have done any change you need to make a backup before running this task.

```bash
bin/rails decidim:robots:replace
```

You can see more details about this change on PR [\#11693](https://github.com/decidim/decidim/pull/11693)

### 3.12. Deduplicating endorsements

We have identified a case when the same user can endorse the same resource multiple times. This is a bug that we have fixed in this release, but we need to clean up the existing duplicated endorsements. We have added a new task that helps you clean the duplicated endorsements.

```bash
bin/rails decidim:upgrade:fix_duplicate_endorsements
```

You can see more details about this change on PR [\#11853](https://github.com/decidim/decidim/pull/11853)

### 3.13. Fix component short links

We have identified that some of the short links for components are not working properly. We have added a new task that helps you fix the short links for components.

```bash
bin/rails decidim:upgrade:fix_short_urls
```

You can see more details about this change on PR [\#12004](https://github.com/decidim/decidim/pull/12004)

### 3.14. Puma syntax change

There's a change in the puma syntax, and you need to remove a line in the configuration (`rackup      DefaultRackup`)

```console
sed -i -e "/rackup      DefaultRackup/d" config/puma.rb
```

You can see more details about this change in issue [puma/puma#2989](https://github.com/puma/puma/issues/2989#issuecomment-1279331520)

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. Automatically change active step in participatory processes

We have added the ability to automatically change the active step of participatory processess. This is an optional behavior that system admins can enable by configuring a cron job. The frequency of the cron task should be decided by the system admin and depends on each platform's use cases. A precision of 15min is enough for most cases. An example of a crontab job may be:

```bash
*/15 * * * * cd /home/user/decidim_application && RAILS_ENV=production bin/rails decidim_participatory_processes:change_active_step
```

Each time the job executes it checks all currently active and published participatory processes and for each, it checks the steps with the date range in the current date. If a change should be made, it deactivates the previous step and activates the next step.

Platform administrators will always have the possibility to manually change phases, although if a cron job is configured the change may be undone.

This feature also changes the step `start_date` and `end_date`  fields to timestamps.

You can read more about this change on PR [\#9026](https://github.com/decidim/decidim/pull/9026).

### 4.2. Social Share Button change

As the gem that we were using for sharing to Social Network do not support Webpacker, we have implemented the same functionality in `decidim-core`.

If you want to have the default social share services enabled (X/Twitter, Facebook, WhatsApp and Telegram), then you can just remove the initializer in your application:

```console
rm config/initializers/social_share_button.rb
```

If you want to change the default social share services, you will need to remove this initializer and add it to the Decidim initializer. We recommend doing it with the environment variables and secrets to be consistent with the rest of configurations.

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

You can read more about this change on PR [\#10201](https://github.com/decidim/decidim/pull/10201).

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

* **decidim-core**
  * Amendments (meaning any amendments for amendable records in different modules, such as proposals at `decidim-proposals`)
  * Coauthorships (meaning any coauthorable records in different modules, such as proposals and collaborative drafts at `decidim-proposals`)
  * Endorsements (for any records, e.g. blog posts at `decidim-blogs`, debates at `decidim-debates` and proposals at `decidim-proposals`)
* **decidim-blogs**
  * Blog posts
  * Endorsements for blog posts (through endorsement transfers at `decidim-core`)
* **decidim-budgets**
  * Budgeting votes (or orders as we call them in the code)
* **decidim-comments**
  * Comments
  * Comment votes
* **decidim-debates**
  * Debates
  * Endorsements for debates (through endorsement transfers at `decidim-core`)
* **decidim-elections**
  * Election votes
  * Election form answers (through form answer transfers at `decidim-forms`)
  * Feedback form answers (through form answer transfers at `decidim-forms`)
* **decidim-forms**
  * Form answers (for different forms, such as survey form answers at `decidim-surveys` or registration form answers at `decidim-meetings`)
* **decidim-initiatives**
  * Initiatives
  * Initiative votes/signatures
* **decidim-meetings**
  * Meetings
  * Meeting registrations
  * Meeting poll answers
  * Meeting registration form answers (through form answer transfers at `decidim-forms`)
* **decidim-proposals**
  * Proposal votes/supports
  * Proposals (through coauthorship transfers at `decidim-core`)
  * Collaborative drafts (through coauthorship transfers at `decidim-core`)
  * Proposal amendments (through amendment transfers at `decidim-core`)
  * Endorsements for proposals (through endorsement transfers at `decidim-core`)
* **decidim-surveys**
  * Survey form answers (through form answer transfers at `decidim-forms`)

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

### 5.3. Tiptap rich text editor

The WYSIWYG ("What You See Is What You Get") rich text editor has been replaced with a new editor named Tiptap to improve the rich text editing experience in Decidim and to ensure that the codebase remains maintained. This change may affect developers that have customized the rich text editor or who are storing rich text editable content in the database.

You can read more about this change on PR [\#10196](https://github.com/decidim/decidim/pull/10196).

#### 5.3.1. New rich text editing API

The new rich text editor is built on the [Tiptap](https://tiptap.dev/) editor which uses the [ProseMirror](https://prosemirror.net/) toolkit for managing the editor's functionality and the content it produces. These frameworks allow the content to be stored in multiple different formats but in Decidim we store them in HTML format because the content is being displayed in an HTML based website.

Tiptap is a headless WYSIWYG editor which does not include a user interface by itself. The user interface is custom built in to Decidim which also allows us to provide a deeper integration and make the editing experience more integrated with the Decidim user interface. This means that Decidim itself ships quite a lot of custom code to add functionality to the editor itself.

Tiptap is well documented and you can find more information about it from its website at:

https://tiptap.dev/introduction

As Tiptap utilizes ProseMirror as its "engine", you can also use any APIs directly that ProseMirror provides. You can learn more about these APIs at:

https://prosemirror.net/docs/ref/

When extending the editor or adding new features to it, you should always primarily rely on the APIs provided by Tiptap. If that is not enough, then look into ProseMirror. Also, take a look at the already implemented Decidim Tiptap extensions to learn how to utilize the APIs in action.

#### 5.3.2. Updated rich text editor JavaScript

The new rich text editor is bundled into its own JavaScript "pack" named `decidim_editor`. You will find the entrypoint file for that from the `decidim-core` gem at `app/packs/entrypoints/decidim_editor.js` and all the editor related JavaScript from the same gem at the `app/packs/src/decidim/editor` folder in case you want to modify any of its functionality.

The initialization of the editor has also changed. In case you are using the `form.editor` or `form.translated :editor` method to generate the rich text editing fields, there is nothing extra you need to do. Those fields should be automatically initialized by the core. But in case you need to initialize the editor for some custom editor elements, you will need to do the following change in your JavaScript code:

```js
// This is what you did in previous Decidim versions (0.27 and earlier)
import createQuillEditor from "src/decidim/editor"

window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".your-custom-editor-container").forEach((container) => {
    createQuillEditor(container);
  });
});

// This is what you need to do in newer Decidim versions (0.28 and newer)
// Note that you do not need to import anything as the `createEditor` method is
// exposed through the window object.
window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".your-custom-editor-container").forEach((container) => {
    window.createEditor(container);
  });
});
```

The editor JS is automatically included in the normal Decidim layout when you display editors using the default form builder shipped with Decidim.

#### 5.3.3. New CSS to display the rich text content

The new version of Decidim ships with rewritten CSS for displaying the rich text editor content. This CSS has been written in Tailwind as this is the new CSS framework used in Decidim. You will need to revisit any CSS that you had previously written for the editor and preferrably rewrite it based on the updated content structure and CSS class names.

The editor CSS is automatically included in the normal Decidim layout when you display editors using the default form builder shipped with Decidim.

#### 5.3.4. Registering rich text content for the content migration

Before running the content migration task explained at the "One time actions" section of this document, the modules that store rich text content may need to register their own records for the content migration. This can be done by shipping a custom rake task with the module that does this when when the content migration task is through the task provided by the core.

In case your module ships any models that stores rich text content, you can register that model and its rich text content columns for this migration by creating a new task in the module's `lib/tasks/upgrade` folder and adding the following contents to the new rake task:

```ruby
# frozen_string_literal: true

# Replace `decidim_yourmodule` with the actual name of your module.
namespace :decidim_yourmodule do
  namespace :upgrade do
    desc "Registers YourModule records for the WYSIWYG content migration"
    task :register_wysiwyg_migration do
      # Register here all the models with their column names that need to be
      # included in the content migration. The first argument is the model's
      # class name as string and the second argument is an array of the columns
      # to be updated. The columns in the database can be either text columns
      # or JSONB columns that store text for multiple languages.
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::YourModule::Record", [:body])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::YourModule::AnotherRecord", [:short_description, :description])
    end
  end
end

# NOTE:
# The line below is important as it tells Decidim to run your custom task as
# part of the core migration registration.
Rake::Task["decidim:upgrade:register_wysiwyg_migration"].enhance ["decidim_yourmodule:upgrade:register_wysiwyg_migration"]
```

In case you have some extremely custom content stored outside of models, you can also migrate the content manually by adding the following custom migration code to the rake task shipped with your module:

```ruby
# frozen_string_literal: true

# Replace `decidim_yourmodule` with the actual name of your module.
namespace :decidim_yourmodule do
  namespace :upgrade do
    desc "Updates YourModule content entered through the WYSIWYG editors"
    task :migrate_wysiwyg_content do
      Decidim::YourModule::SomeVeryCustomContentRecord.find_each do |record|
        record.update!(
          content: Decidim::Upgrade::WysiwygMigrator.convert(record.content)
        )
      end
    end
  end
end

# NOTE:
# The line below is important as it tells Decidim to run your custom task as
# part of the core migration.
Rake::Task["decidim:upgrade:migrate_wysiwyg_content"].enhance ["decidim_yourmodule:upgrade:migrate_wysiwyg_content"]
```

Note that the component settings are already automatically handled by the core as long as you have defined `editor: true` on the component attribute. This marks those attributes to be editable through the rich text editor. There is nothing you need to do regarding the components to get their content migrated to the new format.

### 5.4. Ability to hide content of a user from the public interface

As of [\#10111](https://github.com/decidim/decidim/pull/10111), the administrators have the ability of blocking the user from the public interface.
In order to do so, the administrator needs to go to the user's profile and click on the "Report user" button. If the reporting user is a system wide admin, a new "Block this participant" checkbox will appear. If the checkbox is checked, then the reporting user will have the ability as well to check "Hide all their contents". The first checkbox will force the reporting user to admin area where he can add a justification for blocking the offending Participant. The second checkbox will hide all the content of the user from the public interface.

In order to hide all the Participant resources, keeping a separation of concerns, we have started to use `ActiveSupport::Notifications.publish` to notify the modules that the admin user has chosen to hide all the Participant's contributions.

As of [\#11064](https://github.com/decidim/decidim/pull/11064) we are dispatching the following event:

```ruby
event_name = "decidim.admin.block_user:after"
ActiveSupport::Notifications.publish(event_name, {
  resource: form.user, # user to be blocked
  extra: {
    event_author: form.current_user, # current admin user
    locale:, # current locale
    justification: form.justification, # reason for blocking the user
    hide: form.hide? # true if the admin user has chosen to hide all the user's content
  }
})
```

The plugin creators could subscribe to this event and hide the content of the user. For example, in order to hide the content of a user in the `decidim-comments` module, you could add the following in your engine initializer file:

```ruby
initializer "decidim_comments.moderation_content" do
  ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
    Decidim::Comments::HideAllCreatedByAuthorJob.perform_later(**data)
  end
end
```

The `Decidim::Comments::HideAllCreatedByAuthorJob` is a job that uses the base `Decidim::HideAllCreatedByAuthorJob` job, having the following content:

```ruby
module Decidim
  module Comments
    class HideAllCreatedByAuthorJob < ::Decidim::HideAllCreatedByAuthorJob
      protected

      def base_query
        Decidim::Comments::Comment.not_hidden.where(author: )
      end
    end
  end
end
```

For more complex scenarios, you could override the `perform` method of the job and add your own logic, following the patern:

```ruby
module Decidim
  module YourModule
    class HideAllCreatedByAuthorJob < ::Decidim::HideAllCreatedByAuthorJob
      protected

      def perform(resource:, extra: {})
        return unless extra.fetch(:hide, false)

        Decidim::YourModule::YourModel.not_hidden.from_author(resource).find_each do |content|
          hide_content(content, extra[:event_author], extra[:justification])
        end

        Decidim::YourModule::YourSecondModel.not_hidden.from_author(resource).find_each do |content|
          hide_content(content, extra[:event_author], extra[:justification])
        end
      end
    end
  end
end
```

You can read more about this change at PRs:

* [\#10111](https://github.com/decidim/decidim/pull/10111)
* [\#11064](https://github.com/decidim/decidim/pull/11064)

### 5.5. Extra context argument added to SMS gateway implementations

If you have integrated any [SMS gateways](https://docs.decidim.org/en/develop/services/sms), there is a small change in the API that needs to be reflected to the SMS integrations. An extra `context` attribute is passed to the SMS gateway's initializer which can be used to pass e.g. the correct organization for the gateway to utilize.

In previous versions your SMS gateway initializer might have looked like the following:

```ruby
class MySMSGatewayService
  attr_reader :mobile_phone_number, :code
  def initialize(mobile_phone_number, code)
    @mobile_phone_number = mobile_phone_number
    @code = code
  end
  # ...
end
```

From now on, you will need to change it as follows (note the extra `context` attribute):

```ruby
class MySMSGatewayService
  attr_reader :mobile_phone_number, :code, :context
  def initialize(mobile_phone_number, code, context = {})
    @mobile_phone_number = mobile_phone_number
    @code = code
    @context = context
  end
  # ...
end
```

You can read more about this change at PR [\#10760](https://github.com/decidim/decidim/pull/10760).

### 5.6. Configuration parameter change

Prior to 0.28, there was the possibility of configuring a list of disallowed passwords using the configuration parameter `Decidim.password_blacklist` or the environment variable `DECIDIM_PASSWORD_BLACKLIST`. These methods have been renamed as follows:

* `Decidim.password_blacklist` becomes `Decidim.denied_passwords`
* `DECIDIM_PASSWORD_BLACKLIST` becomes `DECIDIM_DENIED_PASSWORDS`

You can read more about this change on PR [\#10288](https://github.com/decidim/decidim/pull/10288).

### 5.7. Change in Initiatives configuration

Initiatives configuration has a setting to enable a form to be printed for the creation of Initiatives.

This used to be enabled by default, and now it's disabled.

If you need to enable back, you can do so by setting the `INITIATIVES_PRINT_ENABLED` environment variable to `true`
or if you have not migrated to the environment variables configurations (the default since v0.25.0), then you can do
so by adding the following snippet in `config/initializers/decidim.rb`

```ruby
Decidim::Initiatives.configure do |config|
  config.print_enabled = true
end
```
