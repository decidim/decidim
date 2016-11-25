# Decidim [![Gem](https://img.shields.io/gem/v/decidim.svg)](https://rubygems.org/gems/decidim) [![Gem](https://img.shields.io/gem/dt/decidim.svg)](https://rubygems.org/gems/decidim) [![License: AGPL v3](https://img.shields.io/github/license/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/blob/master/LICENSE-AGPLv3.txt)

### Code quality
[![Build Status](https://img.shields.io/travis/AjuntamentdeBarcelona/decidim/master.svg)](https://travis-ci.org/AjuntamentdeBarcelona/decidim)
[![Code Climate](https://img.shields.io/codeclimate/github/AjuntamentdeBarcelona/decidim.svg)](https://codeclimate.com/github/AjuntamentdeBarcelona/decidim/trends)
[![Issue Count](https://img.shields.io/codeclimate/issues/github/AjuntamentdeBarcelona/decidim.svg)](https://codeclimate.com/github/AjuntamentdeBarcelona/decidim/issues)
[![codecov](https://img.shields.io/codecov/c/github/AjuntamentdeBarcelona/decidim.svg)](https://codecov.io/gh/AjuntamentdeBarcelona/decidim)
[![Dependency Status](https://img.shields.io/gemnasium/AjuntamentdeBarcelona/decidim.svg)](https://gemnasium.com/github.com/AjuntamentdeBarcelona/decidim)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/decidim/localized.svg)](https://crowdin.com/project/decidim/invite)

### Project management
[![GitHub pull requests](https://img.shields.io/github/issues-pr/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/pulls)
[![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/pulls?utf8=%E2%9C%93&q=is%3Apr%20is%3Aclosed)
[![GitHub issues](https://img.shields.io/github/issues/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues)
[![GitHub closed issues](https://img.shields.io/github/issues-closed/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues?utf8=%E2%9C%93&q=is%3Aissue%20is%3Aclosed)
[![GitHub contributors](https://img.shields.io/github/contributors/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/graphs/contributors)

## Installation instructions

First of all, you need to install the `decidim` gem, which currently is in a *prerelease* status.

```
$ gem install decidim decidim-core --pre
```

Afterwards, you can create an application with the nice `decidim` executable:

```
$ decidim decidim_application
$ cd decidim_application
```

**Note**: *These steps will be replaced by a simple `gem install decidim && decidim decidim_application` once the gem is released.*

You should now setup your database:

```
$ rails db:setup
```

This will also create some default data so you can start testing the app:

* A `Decidim::System::Admin` with email `system@decidim.org` and password
 `decidim123456`, to log in at `/system`.
* A `Decidim::Organization` named `Decidim Staging`. You probably want to
  change its name and hostname to match your needs.
* A `Decidim::User` acting as an admin for the organization, with email
 `admin@decidim.org` and password `decidim123456`.
* A `Decidim::User` that also belongs to the organization but it's a regular
  user, with email `user@decidim.org` and password `decidim123456`.

This data won't be created in production environments, if you still want to do it, run:

```
$ SEED=true rails db:setup
```

You can now start your server!

```
$ rails s
```

## Upgrade instructions

```
$ bundle update decidim
```

And don't forget to run the upgrade script:

```
$ rails decidim:upgrade
```

If new migrations appear, remember to:

```
$ rails db:migrate
```

## Docker instructions

You can use Docker instead of installing the gems yourself. Run `docker-compose build` and then you can generate a new decidim application using `docker-compose run --rm decidim bundle exec bin/decidim <app-name>`.

Also you can run it as a standalone container like this:
`docker run --rm codegram/decidim bundle exec bin/decidim <app-name>`.

## How to contribute

In order to develop on decidim, you'll need:

* **PostgreSQL** 9.4+
* **Ruby** 2.3.3
* **NodeJS** with **yarn** (JavaScript dependency manager, can be installed with `npm install yarn`)
* **ImageMagick**

The easiest way to work on decidim is to clone decidim's repository and install its dependencies

```bash
$ git clone git@github.com:AjuntamentdeBarcelona/decidim.git
$ cd decidim
$ bundle install
$ yarn install
```

You have several rake tasks available for you:

* `rake development_app`: Creates a development app inside `decidim_development` which you can use to run an application with the gems in your path.
* `rake test_all`: Generates a test app for every engine and runs their tests.
* `rake generate_all`: Generates all the tests apps but doesn't run the tests - this is useful is you want to run them manually afterwards.

TODO: Improve guide.
