# Developing Decidim

## Create a development_app
In order to start developing you will need what is called a `development_app`. This is nearly the same as a new Decidim app (that you can create with `decidim app_name`) but with a Gemfile pre-configured for local development and some other small config modifications.
You need it in order to have a Rails application configured to lookup Decidim modules from your filesystem. This way changes in your modules will be directly observed by this `development_app`.

You can create a `development_app` from inside the project's root folder with the command:
```
rake development_app
cd development_app
```

This new application is .gitignored so you don't have to care about not commiting it.

Once created, you will have only to
- configure its `config/database.yml`
- `bundle install`
- `bin/rails db:migrate`
- and run!

## Useful commands
### erb-lint
```
bundle exec erblint --lint-all --autocorrect
# shortest
bundle exec erblint --lint-all -a
# event shortest
bundle exec erblint -la -a
```

### I18n
```
# from the root of the project
bundle exec i18n-tasks normalize --locales en
```

### Rubocop
```
# Run Rubocop
rubocop
# Run Rubocop and automatically correct offenses
rubocop -a

```
## Good to know
- There is an application with current designs at: https://decidim-design.herokuapp.com/

## Testing
Refer to the `advanced/testing.md` document.