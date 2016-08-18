# Decidim

## Installation instructions

We haven't released a gem yet, so you'll have to install and build it yourself. The best way to do so is to create a stray `Gemfile` like this:

```
source 'https://rubygems.org'
gem 'decidim', github: 'codegram/github'
```

And then:

```
$ bundle install
```

Afterwards, you can create an application with the nice `decidim` executable:

```
$ bundle exec decidim decidim_application --edge
$ cd decidim_application
```

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
