# Decidim [![Gem](https://img.shields.io/gem/v/decidim.svg)](https://rubygems.org/gems/decidim) [![Gem](https://img.shields.io/gem/dt/decidim.svg)](https://rubygems.org/gems/decidim) [![license](https://img.shields.io/github/license/codegram/decidim.svg)](https://github.com/codegram/decidim/blob/master/LICENSE.txt)

### Code quality
[![Build Status](https://img.shields.io/travis/codegram/decidim.svg)](https://travis-ci.org/codegram/decidim)
[![Code Climate](https://img.shields.io/codeclimate/github/codegram/decidim.svg)](https://codeclimate.com/github/codegram/decidim/trends)
[![Issue Count](https://img.shields.io/codeclimate/issues/github/codegram/decidim.svg)](https://codeclimate.com/github/codegram/decidim/issues)
[![codecov](https://img.shields.io/codecov/c/github/codegram/decidim.svg)](https://codecov.io/gh/codegram/decidim)
[![Dependency Status](https://img.shields.io/gemnasium/codegram/decidim.svg)](https://gemnasium.com/github.com/codegram/decidim)

### Project management
[![GitHub pull requests](https://img.shields.io/github/issues-pr/codegram/decidim.svg)](https://github.com/codegram/decidim/pulls)
[![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/codegram/decidim.svg)](https://github.com/codegram/decidim/pulls?utf8=%E2%9C%93&q=is%3Apr%20is%3Aclosed)
[![GitHub issues](https://img.shields.io/github/issues/codegram/decidim.svg)](https://github.com/codegram/decidim/issues)
[![GitHub closed issues](https://img.shields.io/github/issues-closed/codegram/decidim.svg)](https://github.com/codegram/decidim/issues?utf8=%E2%9C%93&q=is%3Aissue%20is%3Aclosed)
[![GitHub contributors](https://img.shields.io/github/contributors/codegram/decidim.svg)](https://github.com/codegram/decidim/graphs/contributors)

## Requirements

* Ruby 2.3.1
* PostgreSQL 9.5 or newer with the `hstore` extension (should already be installed by default)
* Redis (only in production), required by Rails 5's `ActionCable`

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

## Notes

* You can use your own application layout - hooks have automatically been installed.
* You can append your own `js` and `css`, files have automatically been replaced.
