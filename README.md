<img src="https://cdn.rawgit.com/decidim/decidim/master/logo.svg" alt="Decidim Logo" width="400">

The participatory democracy framework.

> Democracy never felt so real.

[Decidim](https://decidim.org) is a participatory democracy framework, written in Ruby on Rails, originally developed for the Barcelona City government online and offline participation website. Installing these libraries will provide you a generator and gems to help you develop web applications like the ones found on [example applications](#example-applications) or like [our demo application](http://staging.decidim.codegram.com).

All members of the Decidim community agree with [Decidim Social Contract or Code of Democratic Guarantees](http://www.decidim.org/contract/).

---

[![Gem](https://img.shields.io/gem/v/decidim.svg)](https://rubygems.org/gems/decidim)
[![Gem](https://img.shields.io/gem/dt/decidim.svg)](https://rubygems.org/gems/decidim)
[![GitHub contributors](https://img.shields.io/github/contributors/decidim/decidim.svg)](https://github.com/decidim/decidim/graphs/contributors)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/decidim/decidim/master)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/decidim/decidim)

Code quality

[![Build Status](https://img.shields.io/circleci/project/github/decidim/decidim/master.svg)](https://circleci.com/gh/decidim/decidim)
[![Code Climate](https://img.shields.io/codeclimate/github/decidim/decidim.svg)](https://codeclimate.com/github/decidim/decidim/trends)
[![codecov](https://img.shields.io/codecov/c/github/decidim/decidim.svg)](https://codecov.io/gh/decidim/decidim)
[![Dependency Status](https://img.shields.io/gemnasium/decidim/decidim.svg)](https://gemnasium.com/github.com/decidim/decidim)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/decidim/localized.svg)](https://crowdin.com/project/decidim)
[![Inline docs](http://inch-ci.org/github/decidim/decidim.svg?branch=master)](http://inch-ci.org/github/decidim/decidim)
[![Accessibility issues](https://rocketvalidator.com/badges/a11y_issues.svg?url=http://staging.decidim.codegram.com/)](https://rocketvalidator.com/badges/link?url=http://staging.decidim.codegram.com/&report=a11y)
[![HTML issues](https://rocketvalidator.com/badges/html_issues.svg?url=http://staging.decidim.codegram.com/)](https://rocketvalidator.com/badges/link?url=http://staging.decidim.codegram.com/&report=html)

Project management [[See on Waffle.io]](https://waffle.io/decidim/decidim)

[![Stories in Discussion](https://img.shields.io/waffle/label/decidim/decidim/discussion.svg)](https://github.com/decidim/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Adiscussion)
[![Stories in Planned](https://img.shields.io/waffle/label/decidim/decidim/planned.svg)](https://github.com/decidim/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Aplanned)
[![Bugs](https://img.shields.io/waffle/label/decidim/decidim/bug.svg)](https://github.com/decidim/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Abug)
[![In Progress](https://img.shields.io/waffle/label/decidim/decidim/in-progress.svg)](https://github.com/decidim/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Ain-progress)
[![In Review](https://img.shields.io/waffle/label/decidim/decidim/in-review.svg)](https://github.com/decidim/decidim/issues?q=is%3Aopen+is%3Aissue+label%3Ain-review)

---

# What do you need to do?

* [Get started with Decidim](#getting-started-with-decidim)
* [Contribute to the project](#how-to-contribute)
* [Decidim components](#officially-supported-libraries)
* [How to test Decidim engines](docs/testing.md)
* [Create & browse development app](#browse-decidim)
* [Technical tradeoffs](#technical-tradeoffs)

---

## Getting started with Decidim

We've set up a guide on how to install, set up and upgrade Decidim. See the [Getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md).

## How to contribute

### As a Translator

Decidim is already translated on multiple languages (English, Spanish, Catalan, Basque, Italian, Finnish, Dutch, French, Russian and Ukrainian). You can help us at [Crowdin, the translation service](https://crowdin.com/project/decidim), reviewing these translations or proposing a new language to add to the platform.

### As a Developer

In order to develop on decidim, you'll need:

* **PostgreSQL** 9.4+
* **Ruby** 2.4.1
* **NodeJS** 8.x.x
* **ImageMagick**
* **PhantomJS**. If you're on Ubuntu, make sure you download it from the [official website](http://phantomjs.org/download.html) instead of using the version of the Ubuntu repositories

The easiest way to work on decidim is to clone decidim's repository and install its dependencies

```bash
git clone git@github.com:decidim/decidim.git
cd decidim
bundle install
npm install
```

You have several rake tasks available:

* `bundle exec rake development_app`: Creates a development app which you can use to run an application with the gems in your path.
* `bundle exec rake decidim:generate_test_app`: Generates a dummy application
  to be used for testing.
* `bundle exec rake test_all`: Runs the tests of every engine using the dummy
  application

#### Browse Decidim

After you create a development app (`bundle exec rake development_app`):

* `cd development_app`
* `bundle exec rails s`
* Go to 'http://localhost:3000'

Optionally, you can log in as: user@example.org | decidim123456

Also, if you want to verify yourself against the default authorization handler use a document number ended with "X".

#### Browse Admin Interface

After you create a development app (`bundle exec rake development_app`):

* `cd development_app`
* `bundle exec rails s`
* Go to 'http://localhost:3000/admin'
* Login data: admin@example.org | decidim123456

## Officially supported libraries

| Library        | Description           |
| ------------- |-------------|
| [Admin](https://github.com/decidim/decidim/tree/master/decidim-admin)      | This library adds an administration dashboard so users can manage their organization and all other entities. |
| [API](https://github.com/decidim/decidim/tree/master/decidim-api)      | This library exposes a GraphQL API to programatically interact with the Decidim platform via HTTP      |
| [Assemblies](https://github.com/decidim/decidim/tree/master/decidim-assemblies) | Permanent participatory spaces. Currently in beta as an optional feature, can be included by explicitly adding `decidim-assemblies` to the Gemfile. |
| [Budgets](https://github.com/decidim/decidim/tree/master/decidim-budgets) | Adds a participatory budgets system to any participatory space. |
| [Comments](https://github.com/decidim/decidim/tree/master/decidim-comments) | The Comments module adds the ability to include comments to any resource which can be commentable by users.      |
| [Core](https://github.com/decidim/decidim/tree/master/decidim-core) | The basics of Decidim: users, organizations, etc. This is the only required engine to run Decidim, all the others are optional. |
| [Participatory Processes](https://github.com/decidim/decidim/tree/master/decidim-participatory_processes) | The main concept of a Decidim installation: participatory processes. |
| [Dev](https://github.com/decidim/decidim/tree/master/decidim-dev) | This gem aids the local development of Decidim's features. |
| [Meeting](https://github.com/decidim/decidim/tree/master/decidim-meetings) | The Meeting module adds meeting to any participatory space. It adds a CRUD engine to the admin and public view scoped inside the participatory space. |
| [Pages](https://github.com/decidim/decidim/tree/master/decidim-pages) | The Pages module adds static page capabilities to any participatory space. It basically provides an interface to include arbitrary HTML content to any step. |
| [Proposals](https://github.com/decidim/decidim/tree/master/decidim-proposals) | The Proposals module adds one of the main features of Decidim: allows users to contribute to a participatory space by creating proposals. |
| [Accountability](https://github.com/decidim/decidim/tree/master/decidim-accountability) | Adds an accountability section to any participatory space so users can follow along the state of the accepted proposals. |
| [Surveys](https://github.com/decidim/decidim/tree/master/decidim-surveys) | Adds the ability for admins to create arbitrary surveys. |
| [System](https://github.com/decidim/decidim/tree/master/decidim-system) | Multitenant Admin to manage multiple organizations in a single installation |

## Technical tradeoffs

### Architecture

This is not your typical Ruby on Rails Vanilla App. We've tried using [Consul](http://decide.es) but we found some problems on reutilization, adaptation, modularization and configuration. You can read more about that on "[Propuesta de Cambios de Arquitectura de Consul](https://www.gitbook.com/book/alabs/propuesta-de-cambios-en-la-arquitectura-de-consul/details)".

### Turbolinks

Decidim doesn't support `turbolinks` so it isn't included on our generated apps and it's removed for existing Rails applications which install the Decidim engine.

The main reason is we are injecting some scripts into the body for some individual pages and Turbolinks loads the scripts in parallel. For some libraries like [leaflet](http://leafletjs.com/) it's very inconvenient because its plugins extend an existing global object.

The support of Turbolinks was dropped in [d8c7d9f](https://github.com/decidim/decidim/commit/d8c7d9f63e4d75307e8f7a0360bef977fab209b6). If you're interested in bringing turbolinks back, further discussion is welcome.

## Following our license

If you plan to release your application you'll need to publish it using the same license: GPL Affero 3. We recommend doing that on GitHub before publishing, you can read more on "[Being Open Source From Day One is Especially Important for Government Projects](http://producingoss.com/en/governments-and-open-source.html#starting-open-for-govs)". If you have any trouble you can contact us on [Gitter](https://gitter.im/decidim/decidim).

## Example applications

Since Decidim is a ruby gem, you can check out the [dependent repositories](https://github.com/decidim/decidim/network/dependents?type=application) to see how many applications are on the wild or tests that other developers have made. Here's a partial list with some of the projects that have used Decidim:

* [Demo](http://staging.decidim.codegram.com)
* [Decidim Barcelona](https://decidim.barcelona) - [View code](https://github.com/AjuntamentdeBarcelona/decidim-barcelona)
* [L'H ON Participa](https://www.lhon-participa.cat) - [View code](https://github.com/HospitaletDeLlobregat/decidim-hospitalet)
* [Decidim Terrassa](https://participa.terrassa.cat) - [View code](https://github.com/AjuntamentDeTerrassa/decidim-terrassa)
* [Decidim Sabadell](https://decidim.sabadell.cat) - [View code](https://github.com/AjuntamentDeSabadell/decidim-sabadell)
* [Decidim Gavà](https://participa.gavaciutat.cat) - [View code](https://github.com/AjuntamentDeGava/decidim-gava)
* [Decidim Sant Cugat](https://decidim.santcugat.cat/) - [View code](https://github.com/AjuntamentdeSantCugat/decidim-sant_cugat)
* [Vilanova Participa](http://participa.vilanova.cat) - [View code](https://github.com/vilanovailageltru/decidim-vilanova)
* [Erabaki Pamplona](https://erabaki.pamplona.es) - [View code](https://github.com/ErabakiPamplona/erabaki)
* [Decidim Mataró](https://www.decidimmataro.cat) - [View code](https://github.com/AjuntamentDeMataro/decidim-mataro)
* [Commission Nationale du Débat Public (France)](https://cndp.opensourcepolitics.eu/)
