# Migration from 0.7.0 to 0.8.0

## Note about this guide

This is a work-in-progress guide for all those people that needs to adapt his existing source code from Decidim
0.7.0 to Decidim 0.8.0. If you find a mistake or missing parts in this document do not hesitate to make a pull request
and add your discoveries.

## Upgrading the gem

You need to alter the following files:

### Gemspec file

You must set the decidim version to 0.8.0 or higher in your gemspec.

```ruby
s.add-dependency "decidim-core", "~> 0.8.0"
```

### Gemfile

You must adjust the decidim version in your gem file as well. You also need to add the new engine 'decidim-verifications':

```ruby
...
gem "decidim", "~> 0.8.0"
gem "decidim-verifications"
...
```

### bundle update

Finally run _bundle update_ to get the required gems updated.

```bash
$ bundle update --full-index
# Will update all gems and dependencies to the latest versions.
```

## Updating your sources

### Factories

Decidim 0.8.0 has migratied from FactoryGirl gem to FactoryBot. Cause this you need to update your factories. Usually the _factories.rb_ file looks like this:

```ruby
# frozen_string_literal: true

require 'decidim/faker/localized'
require 'decidim/dev'

FactoryGirl.define do
  ...
end
```

You must replace FactoryGirl by FactoryBot. After the change it should look like this:

```ruby
# frozen_string_literal: true

require 'decidim/faker/localized'
require 'decidim/dev'

FactoryBot.define do
  ...
end
```

### Spec tests examples

Some examples have changed its name to be more descriptive. In order to have your tests up and running again you must perform the following substitions in the specs folder:

* _include_context "feature"_ now is _include_context "with a feature"_

* _include_context "feature admin"_ now is _include_context "when managing a feature as an admin"_

### Capybara

After I have upgraded to the last version of decidim I have realized that some test that were valid in the previous version now were failing. The reason was the following exception:

```ruby
RSpec::Core::MultipleExceptionError: unexpected alert open: {Alert text : Are you sure?}
```

That was caused by a confirmation dialog. In order to get rid of these issue I had to add the following line in the point
where the dialog was supposed to be accepted:

```ruby
accept_confirm { click_button "Submit" }
```

## Steps to do after migrating your source code

### Adapting code for an existing engine

You must remove the external test app and regenerate it:

```bash
$ rm -Rf spec/decidim_dummy_app
# Erases the dummy app.
$ bundle exec rails decidim:generate_external_test_app
# Generates a new test app, applying the migrations from scratch.
```

After regenerating the test app you should recreate the test database as well:

```bash
$ cd spec/decidim_dummy_app
$ bundle exec rails db:drop
# Drops the current databases
$ bundle exec rails db:setup
# Re-creates the databases and seeds them.
```

### Adapting code for an existing Decidim implementation

After updating the decidim gems you should import the new migrations and execute them:

```bash
$ rails decidim:upgrade
# Copies the latest migrations
$ rails db:migrate
# Applies the latest migrations
```

Additionally you should change the way uglifier is used in your app:

Edit the file _config/environments/production.rb_ and make the following changes:

```ruby
# Original value
# config.assets.js_compressor = :uglifier

# Enable ES6 support
config.assets.js_compressor = Uglifier.new(harmony: true)
```

## To sum it up

Take a cold beer and enjoy democracy.
