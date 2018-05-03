# Developing Decidim

## Create a development_app

In order to start developing you will need what is called a `development_app`. This is nearly the same as a new Decidim app (that you can create with `decidim app_name`) but with a Gemfile pre-configured for local development and some other small config modifications.
You need it in order to have a Rails application configured to lookup Decidim modules from your filesystem. This way changes in your modules will be directly observed by this `development_app`.

You can create a `development_app` from inside the project's root folder with the command:

```console
git clone https://github.com/decidim/decidim.git
cd decidim
bundle install
bundle exec rake development_app
cd development_app
```

A development_app/ entry appears in the .gitignore file, so you don't have to worry about commiting the development app by mistake.

On creation, this steps are automatically invoked by the generator:

- create a `config/database.yml`
- `bundle install`
- `bin/rails db:migrate db:seed`

If the default database.yml does not suit your needs you can always configure it at your will and run this steps manually.

Once created you are ready to:

- `bin/rails s`



## Useful commands

### erb-lint

We use erblint gem to ensure homogeneous formatting of erb files.

```console
bundle exec erblint --lint-all --autocorrect
# shortest
bundle exec erblint --lint-all -a
# even shortest
bundle exec erblint -la -a
```

### I18n

We use i18n-tasks gem to keep translations ordered and without missing/unused keys.

```console
# from the root of the project
bundle exec i18n-tasks normalize --locales en
```

### JavaScript linter

We use JavaScript's lint library to ensure homogeneous formatting of JavaScrip code.

```console
yarn install
yarn run lint --fix
```

### Rubocop

RuboCop is a code analyzer tool we use at Decidim to enforce our code formatting guidelines.

```console
# Run Rubocop
bundle exec rubocop
# Run Rubocop and automatically correct offenses
bundle exec rubocop -a
```

## Good to know

- There is an application with current designs at: https://decidim-design.herokuapp.com/

## Testing

Refer to the `advanced/testing.md` document.
