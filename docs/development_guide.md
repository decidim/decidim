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

## Gitflow Branching model

The Decidim respository follows the Gitflow branching model. There are good documentations on it at:

- the original post: https://nvie.com/posts/a-successful-git-branching-model/
- provided by Atlassian: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow.

This model introduces the `develop` branch as a kind of queue for new features to enter into the next release.

In summary, Decidim developers that work on `feature/...` or `fix/...` branches will branch off from `develop` and must be merged back into `develop`.

Then, to start a new feature branch off from `develop` in the following way:

```
git checkout develop
git checkout -b feature/xxx
```

Implement the feature, and open a Pull Request as normal, but against `develop` branch. As this is the most common operation, `develop` is the default branch instead of `master`.

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

Refer to the [testing](advanced/testing.md) guide.

## Releasing new versions

In order to release new version you need to be owner of all the gems at RubyGems, ask one of the owners to add you before releasing. (Try `gem owners decidim`).

Releasing new ***patch versions*** is quite easy, it's the same process whether it's a new version or a patch:

1. Checkout the branch you want to release: `git checkout -b VERSION-stable`
1. Update `.decidim-version` to the new version number.
1. Run `bin/rake update_versions`, this will update all references to the new version.
1. Run `bin/rake bundle`, this will update all the `Gemfile.lock` files
1. Run `bin/rake webpack`, this will update the JavaScript bundle.
1. Update `CHANGELOG.MD`. At the top you should have an `Unreleased` header with the `Added`, `Changed`, `Fixed` and `Removed` empty section. After that, the header with the current version and link.
1. Commit all the changes: `git add . && git commit -m "Prepare VERSION release"`
1. Run `bin/rake release_all`, this will create all the tags, push the commits and tags and release the gems to RubyGems.
1. Once all the gems are published you should create a new release at this repository, just go to the [releases page](https://github.com/decidim/decidim/releases) and create a new one.
1. Finally, you should update our [Docker repository](https://github.com/decidim/docker) so new images are build for the new release. To do it, just update `DECIDIM_VERSION` at [circle.yml](https://github.com/decidim/docker/blob/master/circle.yml).

If this was a **major version** release:

1. Go back to master with `git checkout master`
1. Update `.decidim-version` to the new major development version
1. Run `bin/rake update_versions`, this will update all references to the new version.
1. Run `bin/rake bundle`, this will update all the `Gemfile.lock` files
1. Run `bin/rake webpack`, this will update the JavaScript bundle.
1. Update `SECURITY.md` and change the supported version to the new version.
1. Commit all the changes: `git add . && git commit -m "Bump version" && git push origin master`
1. Run `bin/rake release_all`, this will create all the tags, push the commits and tags and release the gems to RubyGems.
1. Once all the gems are published you should create a new release at this repository, just go to the [releases page](https://github.com/decidim/decidim/releases) and create a new one.
1. Finally, you should update our [Docker repository](https://github.com/decidim/docker) so new images are build for the new release. To do it, just update `DECIDIM_VERSION` at [circle.yml](https://github.com/decidim/docker/blob/master/circle.yml) and create the sibling branch at the Docker repository. NOTE: You should also take into account if the Ruby version has changed, in which case the Dockerfile should also be updated.

To branch the stable version and let master be the new devel branch again:

1. Create and push the stable branch from master: `git checkout master && git checkout -b VERSION-stable && git push origin VERSION-stable`
1. Update the `CHANGELOG.MD`. At the top you should have an `Unreleased` header with the `Added`, `Changed`, `Fixed` and `Removed` empty section. After that, the header with the current version and link.
1. Turn master into the dev branch for the next release:
  1. Update `.decidim-version` to the new `dev` development version: x.y.z-dev
  1. Run `bin/rake update_versions`, this will update all references to the new version.
  1. Run `bin/rake bundle`, this will update all the `Gemfile.lock` files
  1. Run `bin/rake webpack`, this will update the JavaScript bundle.
