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

## GitFlow Branching model

The Decidim respository follows the GitFlow branching model. There are good documentations on it at:

- the original post: https://nvie.com/posts/a-successful-git-branching-model/
- provided by Atlassian: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow.

This model introduces the `develop` branch as a kind of queue for new features to enter into the next release.

In summary, Decidim developers that work on `feature/...` or `fix/...` branches will branch off from `develop` and must be merged back into `develop`.

Then, to start a new feature branch off from `develop` in the following way:

```bash
git checkout develop
git checkout -b feature/xxx
```

Implement the feature, and open a Pull Request as normal, but against `develop` branch. As this is the most common operation, `develop` is the default branch instead of `master`.

### Naming Decidim branches

We would like to have all branches following this namings:

| Branch prefix | Comment |
| --------  | -------- |
| chore/    | Internal work. For instance, automatisms, etc. No production code change.     |
| ci/       | For continous integration related tasks. No production code change.     |
| deps/     | For dependency management tasks. |
| doc/      | For changes to the documentation. |
| feature/  | For new features for the users or for the Decidim command.  |
| fix/      | For feature bugfixing. |
| release/  | With MAYOR.MINOR-stable. For instance, release/0.22-stable |
| refactor/ | For refactorings related with production code. |
| test/     | When adding missing tests, refactoring tests, improving coverage, etc. |
| backport/ | We only offer support for the last mayor version.  |

## Git commit messages and Pull Request titles

We recommend following [this guide](https://chris.beams.io/posts/git-commit/) for making good git commit messages. It also applies to Pull Request titles. The summary is:

1. Separate subject from body with a blank line
1. Limit the subject line to 50 characters
1. Capitalize the subject line
1. Do not end the subject line with a period
1. Use the imperative mood in the subject line
1. Wrap the body at 72 characters
1. Use the body to explain what and why vs. how

## During development

When creating new migrations in Decidim's modules, you will need to "apply" this migrations to your development_app. The way to do this is by copying the migration from your module into the db/migrate dir of your development_app. Luckily we already have a script that automates this: it copies all missing migrations in development_app/db/migrate. The command is:

```console
bin/rails decidim:upgrade
```

Anyway we recommend re-creating your development_app every once in a while.

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

[eslint](https://eslint.org/docs/user-guide/command-line-interface) and [tslint](https://palantir.github.io/tslint/) are used to ensure homogeneous formatting of JavaScript code.

To lint and try to fix linting errors, run:

```console
npm run lint --fix
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

Refer to the [testing](advanced/testing.md) guide.
