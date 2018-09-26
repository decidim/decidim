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
- `bin/rails decidim:upgrade`
- `bin/rails db:migrate db:seed`

If the default database.yml does not suit your needs you can always configure it at your will and run this steps manually.

Once created you are ready to:

- `bin/rails s`

## During development

When creating new migrations in Decidim's modules, you will need to "apply" this migrations to your development_app. The way to do this is by copying the migration from your module into the db/migrate dir of your development_app. Luckily we already have a script that automates this: it copies all missing migrations in development_app/db/migrate. The command is:

```console
bin/rails decidim:upgrade
```

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

### Stylelinter

[stylelint](https://stylelint.io/) is a CSS linter and fixer that helps to avoid errors and enforce consistent conventions in the stylesheets. Is an npm package, install it using:

```console
npm install -g stylelint
```

Linting a `.scss` file:

```console
stylelint [path-to-file]
```

With `--fix` option [stylelint](https://stylelint.io/user-guide/cli/#autofixing-errors) will fix as many errors as possible. The fixes are made to the actual source files. All unfixed errors will be reported.

```console
stylelint [path-to-file] --fix
```

### Rubocop

RuboCop is a code analyzer tool we use at Decidim to enforce our code formatting guidelines.

```console
# Run Rubocop
bundle exec rubocop
# Run Rubocop and automatically correct offenses
bundle exec rubocop -a
```

### Markdown linter

This project uses [markdownlint](https://github.com/markdownlint/markdownlint) to check markdown files and flag style issues.

## Good to know

- There is an application with current designs at: https://decidim-design.herokuapp.com/

## Testing

Refer to the [testing](docs/advanced/testing.md) guide.
