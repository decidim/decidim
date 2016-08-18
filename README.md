# Decidim

## Installation instructions

```
$ rails new my_application
```

Then, edit the `Gemfile` and add:

```ruby
gem 'decidim', github: 'codegram/decidim'
```

Install the gems:

```
$ bundle install
```

Then, run the installation:

```
$ rails generate decidim:install
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
