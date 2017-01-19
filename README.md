# Decidim [![Gem](https://img.shields.io/gem/v/decidim.svg)](https://rubygems.org/gems/decidim) [![Gem](https://img.shields.io/gem/dt/decidim.svg)](https://rubygems.org/gems/decidim) [![License: AGPL v3](https://img.shields.io/github/license/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/blob/master/LICENSE-AGPLv3.txt)

[[Documentation](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/doc)] - [[Demo](http://staging.decidim.codegram.com)]

### Code quality
[![Build Status](https://img.shields.io/travis/AjuntamentdeBarcelona/decidim/master.svg)](https://travis-ci.org/AjuntamentdeBarcelona/decidim)
[![Code Climate](https://img.shields.io/codeclimate/github/AjuntamentdeBarcelona/decidim.svg)](https://codeclimate.com/github/AjuntamentdeBarcelona/decidim/trends)
[![Issue Count](https://img.shields.io/codeclimate/issues/github/AjuntamentdeBarcelona/decidim.svg)](https://codeclimate.com/github/AjuntamentdeBarcelona/decidim/issues)
[![codecov](https://img.shields.io/codecov/c/github/AjuntamentdeBarcelona/decidim.svg)](https://codecov.io/gh/AjuntamentdeBarcelona/decidim)
[![Dependency Status](https://img.shields.io/gemnasium/AjuntamentdeBarcelona/decidim.svg)](https://gemnasium.com/github.com/AjuntamentdeBarcelona/decidim)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/decidim/localized.svg)](https://crowdin.com/project/decidim/invite)
[![Inline docs](http://inch-ci.org/github/AjuntamentdeBarcelona/decidim.svg?branch=master)](http://inch-ci.org/github/AjuntamentdeBarcelona/decidim)

### Project management
[![GitHub pull requests](https://img.shields.io/github/issues-pr/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/pulls)
[![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/pulls?utf8=%E2%9C%93&q=is%3Apr%20is%3Aclosed)
[![GitHub issues](https://img.shields.io/github/issues/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues)
[![GitHub closed issues](https://img.shields.io/github/issues-closed/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/issues?utf8=%E2%9C%93&q=is%3Aissue%20is%3Aclosed)
[![GitHub contributors](https://img.shields.io/github/contributors/AjuntamentdeBarcelona/decidim.svg)](https://github.com/AjuntamentdeBarcelona/decidim/graphs/contributors)

---

## What do you need to do?

- [Contribute to the project](#how-to-contribute)
- [Create & browse development app](#browse-decidim)
- [Install "Decidim" for an organization](#installation-instructions)
- [Upgrade an already existing "Decidim" installation](#upgrade-instructions)
- [Use Docker to deploy "Decidim"](#docker-instructions)
- [Check current components](#components)

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

### (Optional) Social providers integration

If you want to enable sign up through social providers like Facebook you will need to generate app credentials and write them into the Rails secrets file: `config/secrets.yml`.

#### Facebook

1. Navigate to [Facebook Developers Page](https://developers.facebook.com/)
2. Follow the "Add a New App" link.
3. Click the "Website" option.
4. Fill in your application name and click "Create New Facebook App ID" button.
5. Fill in the contact email info and category.
6. Validate the captcha.
7. Ignore the source code and fill in the URL field.
8. Navigate to the application dashboard and copy the APP_ID and APP_SECRET
9. Paste credentials in `config/secrets.yml`. Ensure the `enabled` attribute is `true`.

#### Twitter

1. Navigate to [Twitter Developers Page](https://dev.twitter.com/)
2. Follow the "My apps" link.
3. Click the "Create New App" button.
4. Fill in the `Name`, `Description` fields. 
5. Fill in the `Website` and `Callback URL` fields with the same value. If you are working on a development app you need to use `http://127.0.0.1:3000/` instead of `http://localhost:3000/`.
5. Check the 'Developer Agreement' checkbox and click the 'Create your Twitter application' button.
6. Navigate to the "Keys and Access Tokens" tab and copy the API_KEY and API_SECRET.
8. (Optional) Navigate to the "Permissions" tab and check the "Request email addresses from users" checkbox.
9. Paste credentials in `config/secrets.yml`. Ensure the `enabled` attribute is `true`.

#### Google

1. Navigate to [Google Developers Page](https://console.developers.google.com)
2. Follow the 'Create projecte' link.
3. Fill in the name of your app.
4. Navigate to the projecte dashboard and click on "Enable API"
5. Click on `Google+ API` and then "Enable"
6. Navigate to the project credentials page and click on `OAuth consent screen`.
7. Fill in the `Product name` field
8. Click on `Credentials` tab and click on "Create credentials" button. Select `OAuth client ID`.
9. Select `Web applications`. Fill in the `Authorized Javascript origins` with your url. Then fill in the `Authorized redirect URIs` with your url and append the path `/users/auth/google_oauth2/callback`.
10. Copy the CLIENT_ID AND CLIENT_SECRET
11. Paste credentials in `config/secrets.yml`. Ensure the `enabled` attribute is `true`.

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


TODO: Improve guide.
