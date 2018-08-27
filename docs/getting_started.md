# Getting started with Decidim

## What is and what isn't Decidim?

Decidim is a set of Ruby on Rails engines to create a participatory democracy framework on top of a Ruby on Rails app. This system allows having Decidim code separated from custom code for each installation and still enabling easy updates.

These libraries are published to Rubygems.org, so you can add Decidim to your Ruby on Rails app as external dependencies.

If you want to start your own installation of Decidim, you don't need to clone this repo. Keep reading to find out how to install Decidim.

## Creating your Decidim app

### A. Recommended: manual installation

If you know Ruby and have already worked with Ruby on Rails, you
need to know that decidim is a gem and a command line that generates
an appllication that consumes this gem 😅. 

The flow is: install gem, generate a Ruby on Rails app, enjoy.

```bash
gem install decidim
decidim decidim_application
```

You can see the [official manual installation tutorial](/docs/manual-installation.md), 
and also you have [another manual installation tutorial](https://github.com/Platoniq/decidim-install) 
made by the nice people of [Platoniq](http://www.platoniq.net/).

### B. Using installation script [experimental]

> *Please note that this is **experimental***

We've made an script for Ubuntu 16.04 LTS and macos sierra 10.2. 
It's a BETA and as such you should be aware that this could break 
your environment (if you have any). It'll install rbenv, postgresql, 
nodejs and install decidim on this directory. It should take 15 
minutes depending on your network connection.

```console
wget http://get.decidim.org -O install_decidim.bash
bash install_decidim.bash
```

Read more about the [installation script](https://github.com/alabs/decidim-install).

### C. Using Docker [experimental]

You can also use [docker] && [docker-compose] to develop decidim. You'll
need to install those but in exchange you don't need to install any other
dependency in your computer, not even Ruby!

To get started, first clone the decidim repo

```console
git clone https://github.com/decidim/decidim
```

Switch to the cloned folder

```console
cd decidim
```

Then create a development application

```console
d/bundle install
d/rake development_app
d/rails server
```

In general, to use the docker development environment, change any instruction in
the docs to use its equivalent docker binstub.  So for example, instead of
running `bundle install`, you would run `d/bundle install`.


## Initializing your app for local development

You should now setup your database:

```console
bin/rails db:create db:migrate db:seed
```

This will also create some default data so you can start testing the app:

* A `Decidim::System::Admin` with email `system@example.org` and password `decidim123456`, to log in at `/system`.
* A `Decidim::Organization` named `Decidim Staging`. You probably want to change its name and hostname to match your needs.
* A `Decidim::User` acting as an admin for the organization, with email `admin@example.org` and password `decidim123456`.
* A `Decidim::User` that also belongs to the organization but it's a regular user, with email `user@example.org` and password `decidim123456`.

This data won't be created in production environments, if you still want to do it, run: ``` $ SEED=true rails db:setup ```

You can now start your server!

```console
bin/rails s
```

Visit [http://localhost:3000](http://localhost:3000) to see your app running.

## Configuration & setup

Decidim comes pre-configured with some safe defaults, but can be changed through the `config/initializers/decidim.rb` file in your app. Check the comments there or read the comments in [the source file](https://github.com/decidim/decidim/blob/master/decidim-core/lib/decidim/core.rb) (the part with the `config_accessor` calls) for more up-to-date info.

If you want to run the automatic rake task to delete data portability files, write in `crontab -e`
`0 0 * * * cd /Users/you/projects/myrailsapp && /usr/local/bin/rake RAILS_ENV=production decidim:delete_data_portability_files`

We also have other guides on how to configure some extra components:

* [ActiveJob](https://github.com/decidim/decidim/blob/master/docs/services/activejob.md)
* [Analytics](https://github.com/decidim/decidim/blob/master/docs/services/analytics.md): How to enable analytics
* [Geocoding](https://github.com/decidim/decidim/blob/master/docs/services/geocoding.md): How to enable geocoding for proposals and meetings
* [Social providers integration](https://github.com/decidim/decidim/blob/master/docs/services/social_providers.md): Enable sign up from social networks.

## Deploy

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

```console
SEED=true rails db:seed
```

You'll need to login as system user and edit the host for the organization. Set it to you production host, without the protocol and the port (so if your host is `https://my.host:3001`, you need to write `my.host`).

## Keeping your app up-to-date

We keep releasing new versions of Decidim. In order to get the latest one, update your dependencies:

```console
bundle update decidim
```

And make sure you get all the latest migrations:

```console
bin/rails decidim:upgrade
bin/rails db:migrate
```

You can also make sure new translations are complete for all languages in your
application with:

```console
bin/rails decidim:check_locales
```

Be aware that this task might not be able to detect everything, so make sure you
also manually check your application before upgrading.

## Checklist

There are several things you need to check before making your putting your application on production. See the [checklist](checklist.md).

[docker]: https://docs.docker.com/engine/installation/
[docker-compose]: https://docs.docker.com/compose/install/

## Contributing

We always welcome new contributors of all levels to the project. If you are not confident enough with Ruby or web development you can look for [issues](https://github.com/decidim/decidim/issues) labeled `good first issue` to start contibuting and learning the internals of the project by doing easy jobs.

We also have a [developer's reference](/docs/development_guide.md) that will help you getting started with your environment and our daily commands, routines, etc.

Finally, you can also find other ways of helping us on our [contribution guide](/CONTRIBUTING.md).
