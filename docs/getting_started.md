# Getting started with Decidim

## What is and what isn't Decidim?

Decidim is a set of Ruby on Rails engines to create a participatory democracy framework on top of a Ruby on Rails app. This system allows having Decidim code separated from custom code for each installation and still enabling easy updates.

These libraries are published to Rubygems.org, so you can add Decidim to your Ruby on Rails app as external dependencies.

If you want to start your own installation of Decidim, you don't need to clone this repo. Keep reading to find out how to install Decidim.

## Creating your Decidim app

### Using Docker [experimental]

> *Please note that this is **experimental***

Make sure you [have Docker v17 at least](https://docs.docker.com/engine/installation/). `cd` to your preferred folder and run this command:

```
docker run --rm -v $(pwd):/tmp codegram/decidim bash -c "bundle exec decidim /tmp/decidim_application"
```

This will create a `decidim_application` Ruby on Rails app using Decidim in the current folder. It will install the latest released version of the gem.

### Step by step

First of all, you need to install the `decidim` gem:

```
$ gem install decidim
```

Afterwards, you can create an application with the nice `decidim` executable:

```
$ decidim decidim_application
$ cd decidim_application
```

### Initializing your app for local development

You should now setup your database:

```
$ bin/rails db:create db:migrate db:seed
```

This will also create some default data so you can start testing the app:

* A `Decidim::System::Admin` with email `system@example.org` and password `decidim123456`, to log in at `/system`.
* A `Decidim::Organization` named `Decidim Staging`. You probably want to change its name and hostname to match your needs.
* A `Decidim::User` acting as an admin for the organization, with email `admin@example.org` and password `decidim123456`.
* A `Decidim::User` that also belongs to the organization but it's a regular user, with email `user@example.org` and password `decidim123456`.

This data won't be created in production environments, if you still want to do it, run:

```
$ SEED=true rails db:setup
```

You can now start your server!

```
$ bin/rails s
```

Visit [http://localhost:3000](http://localhost:3000) to see your app running.

## Configuration & setup

Decidim comes pre-configured with some safe defaults, but can be changed through the `config/initializers/decidim.rb` file in your app. Check the comments there or read the comments in [the source file](https://github.com/decidim/decidim/blob/master/decidim-core/lib/decidim/core.rb) (the part with the `config_accessor` calls) for more up-to-date info.

We also have other guides on how to configure some extra features:

- [Social providers integration](https://github.com/decidim/decidim/blob/master/docs/social_providers.md): Enable sign up from social networks.
- [Analytics](https://github.com/decidim/decidim/blob/master/docs/analytics.md): How to enable analytics
- [Geocoding](https://github.com/decidim/decidim/blob/master/docs/geocoding.md): How to enable geocoding for proposals and meetings

## Deploy

Once you've generated the Decidim app you might need to do some changes in order to deploy it. You can check [`codegram/decidim-deploy-heroku`](https://github.com/codegram/decidim-deploy-heroku) for an opinionated example of things to do before deploying to Heroku, for example.

Once you've successfully deployed your app to your favorite platform, you'll need to create your `System` user. First you'll need to create your `Decidim::System` user in your production Ruby on Rails console:

```ruby
email = <your email>
password = <a secure password>
user = Decidim::System::Admin.new(email: email, password: password, password_confirmation: password)
user.save!
```

This will create a system user with the email and password you set. We recommend using a random password generator and saving it to a password manager, so you have a more secure login.

Then, visit the `/system` dashboard and login with the email and passwords you just entered and create your organization. You're done! :tada:

You can check the [`decidim-system` README file](https://github.com/decidim/decidim/tree/master/decidim-system/README.md) for more info on how organizations work.

### Seed data in production

If you want, you can create seed data in production. Run this command in your production console:

```
$ SEED=true rails db:seed
```

If you used Codegram's [`decidim-deploy-heroku`](https://github.com/codegram/decidim-deploy-heroku), then you're all set. Otherwise you'll need to login as system user and edit the host for the organization. Set it to you production host, without the protocol and the port (so if your host is `https://my.host:3001`, you need to write `my.host`).

## Keeping your app up-to-date

We keep releasing new versions of Decidim. In order to get the latest one, update your dependencies:

```
$ bundle update decidim
```

And make sure you get all the latest migrations:

```
$ bin/rails decidim:upgrade
$ bin/rails db:migrate
```

You can also make sure new translations are complete for all languages in your
application with:

```
$ bin/rails decidim:check_locales
```

Be aware that this task might not be able to detect everything, so make sure you
also manually check your application before upgrading.
