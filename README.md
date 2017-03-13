# Decidim [![Gem](https://img.shields.io/gem/v/decidim.svg)](https://rubygems.org/gems/decidim) [![Gem](https://img.shields.io/gem/dt/decidim.svg)](https://rubygems.org/gems/decidim) [![GitHub contributors](https://img.shields.io/github/contributors/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/graphs/contributors) [![License: AGPL v3](https://img.shields.io/github/license/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/blob/master/LICENSE-AGPLv3.txt)

[![Demo](https://img.shields.io/badge/demo-staging-orange.svg?style=flat)](http://staging.decidim.codegram.com)
[[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/AjuntamentdeBarcelona/decidim/master)](http://www.rubydoc.info/github/AjuntamentdeBarcelona/decidim/master)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/AjuntamentdeBarcelona/decidim)


### Code quality
[![Build Status](https://img.shields.io/travis/AjuntamentdeBarcelona/decidim/master.svg)](https://travis-ci.org/AjuntamentdeBarcelona/decidim)
[![Code Climate](https://img.shields.io/codeclimate/github/AjuntamentdeBarcelona/decidim.svg)](https://codeclimate.com/github/AjuntamentdeBarcelona/decidim/trends)
[![codecov](https://img.shields.io/codecov/c/github/AjuntamentdeBarcelona/decidim.svg)](https://codecov.io/gh/AjuntamentdeBarcelona/decidim)
[![Dependency Status](https://img.shields.io/gemnasium/AjuntamentdeBarcelona/decidim.svg)](https://gemnasium.com/github.com/AjuntamentdeBarcelona/decidim)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/decidim/localized.svg)](https://crowdin.com/project/decidim/invite)
[![Inline docs](http://inch-ci.org/github/AjuntamentdeBarcelona/decidim.svg?branch=master)](http://inch-ci.org/github/AjuntamentdeBarcelona/decidim)

### Project management [[See on Waffle.io]](https://waffle.io/AjuntamentdeBarcelona/decidim)
[![Stories in Discussion](https://img.shields.io/waffle/label/AjuntamentdeBarcelona/decidim/discussion.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Adiscussion)
[![Stories in Ready](https://img.shields.io/waffle/label/AjuntamentdeBarcelona/decidim/ready.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Aready)
[![Bugs](https://img.shields.io/waffle/label/AjuntamentdeBarcelona/decidim/bug.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Abug)
[![In Progress](https://img.shields.io/waffle/label/AjuntamentdeBarcelona/decidim/in-progress.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Ain-progress)
[![In Review](https://img.shields.io/waffle/label/AjuntamentdeBarcelona/decidim/in-review.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Ain-review)

---

Decidim is a participatory democracy framework written on Ruby on Rails originally developed for the Barcelona City government online and offline participation website. Installing this libraries you'll get a generator and gems to help you develop web applications like the ones found on [example applications](#example-applications).

## What do you need to do?

- [Contribute to the project](#how-to-contribute)
- [Create & browse development app](#browse-decidim)
- [Install "Decidim" for an organization](#installation-instructions)
- [Upgrade an already existing "Decidim" installation](#upgrade-instructions)
- [Use Docker to deploy "Decidim"](#docker-instructions)
- [Check current components](#components)
- [Further configuration](#further-configuration)
- [Technical tradeoffs](#technical-tradeoffs)

---

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

* A `Decidim::System::Admin` with email `system@example.org` and password
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
`docker run --rm -v $(pwd):/tmp -it codegram/decidim bundle exec bin/decidim /tmp/<app-name>`

Now you have a new Decidim app created at `<app-name>` 🎉

## How to contribute

In order to develop on decidim, you'll need:

* **PostgreSQL** 9.4+
* **Ruby** 2.4.0
* **NodeJS** with **yarn** (JavaScript dependency manager, can be installed with `npm install yarn`)
* **ImageMagick**
* **PhantomJS**

The easiest way to work on decidim is to clone decidim's repository and install its dependencies

```bash
$ git clone git@github.com:AjuntamentdeBarcelona/decidim.git
$ cd decidim
$ bundle install
$ yarn install
```

You have several rake tasks available for you:

* `bundle exec rake development_app`: Creates a development app inside `decidim_development` which you can use to run an application with the gems in your path.
* `bundle exec rake test_all`: Generates a test app for every engine and runs their tests.
* `bundle exec rake generate_all`: Generates all the tests apps but doesn't run the tests - this is useful is you want to run them manually afterwards.
* `cd <component>` and do `bundle exec rspec spec` to run those particular tests.


### Browse Decidim

After you create a development app (`bundle exec rake development_app`):
- `cd development_app`
- `bundle exec rails s`
- Go to 'http://localhost:3000'

Optionally, you can log in as: user@decidim.org | decidim123456

Also, if you want to verify yourself against the default authorization handler use a document number ended with "X".


### Browse Admin Interface

After you create a development app (`bundle exec rake development_app`):
- `cd development_app`
- `bundle exec rails s`
- Go to 'http://localhost:3000/admin'
- Login data: admin@decidim.org | decidim123456


## Components


| Component        | Description           |
| ------------- |-------------|
| [Admin](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-admin)      | This library adds an administration dashboard so users can manage their organization, participatory processes and all other entities. |
| [API](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-api)      | This library exposes a GraphQL API to programatically interact with the Decidim platform via HTTP      |
| [Comments](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-comments) | The Comments module adds the ability to include comments to any resource which can be commentable by users.      |
| [Core](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-core) | The basics of Decidim: users, participatory processes, etc. This is the only required engine to run Decidim, all the others are optional. |
| [Dev](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-dev) | This gem aids the local development of Decidim's features. |
| [Meeting](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-meetings) | The Meeeting module adds meeting to any participatory process. It adds a CRUD engine to the admin and public view scoped inside the participatory process. |
| [Pages](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-pages) | The Pages module adds static page capabilities to any participatory process. It basically provides an interface to include arbitrary HTML content to any step. |
| [Proposals](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-proposals) | The Proposals module adds one of the main features of Decidim: allows users to contribute to a participatory process by creating proposals. |
| [System](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-system) | Multitenant Admin to manage multiple organizations in a single installation |

## Further configuration

- [Social providers integration](https://github.com/AjuntamentdeBarcelona/decidim/blob/master/docs/social_providers.md): Enable sign up from social networks.
- [Analytics](https://github.com/AjuntamentdeBarcelona/decidim/blob/master/docs/analytics.md): How to enable analytics

## Technical tradeoffs

### Architecture

This is not your tipical Ruby on Rails Vanilla App. We've tried that using [Consul](http://decide.es) but we've found some problems on reutilization, adaptation, modularization and configuration. You can read more about that on "[Propuesta de Cambios de Arquitectura de Consul](https://www.gitbook.com/book/alabs/propuesta-de-cambios-en-la-arquitectura-de-consul/details)".

### Turbolinks

Decidim doesn't support `turbolinks` so it isn't included on our generated apps and it's removed for existing Rails applications which install the Decidim engine.

The main reason for this is we are injecting some scripts into the body for some individual pages and Turbolinks loads the scripts in parallel. For some libraries like [leaflet](http://leafletjs.com/) it's very inconvenient because its plugins extend an existing global object.

The support of Turbolinks was dropped in [d8c7d9f](https://github.com/AjuntamentdeBarcelona/decidim/commit/d8c7d9f63e4d75307e8f7a0360bef977fab209b6). If you're interested in bringing turbolinks back, further discussion is welcome.

## Following our license

If you plan to release your application you'll need to publish it using the same license: GPL Affero 3. We recommend doing that on Github before publishing, you can read more on "[Being Open Source From Day One is Especially Important for Government Projects](http://producingoss.com/en/governments-and-open-source.html#starting-open-for-govs)". If you have any trouble doing that you can contact us on [Gitter](https://gitter.im/AjuntamentdeBarcelona/decidim).


## Example applications

* [Demo](http://staging.decidim.codegram.com)
* [Decidim Barcelona](https://decidim.barcelona)
* [L'H ON dels barris](https://www.lhon-participa.cat)
