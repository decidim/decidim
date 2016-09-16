# Decidim

[![Gem Version](https://badge.fury.io/rb/decidim.svg)](https://badge.fury.io/rb/decidim)
[![Code Climate](https://codeclimate.com/github/codegram/decidim/badges/gpa.svg)](https://codeclimate.com/github/codegram/decidim)
[![Circle CI](https://circleci.com/gh/codegram/decidim.svg?style=svg)](https://circleci.com/gh/codegram/decidim/tree/master)
[![codecov](https://codecov.io/gh/codegram/decidim/branch/master/graph/badge.svg)](https://codecov.io/gh/codegram/decidim)

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

You should now create your database and migrate:

```
$ rails db:create
$ rails db:migrate
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

## Notes

* You can use your own application layout - hooks have automatically been installed.
* You can append your own `js` and `css`, files have automatically been replaced.
