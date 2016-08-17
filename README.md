# Decidim

## Installation instructions

```
$ rails new my_application
```

Then, edit the `Gemfile` and add:

```ruby
git 'https://github.com/codegram/decidim.git' do
  gem 'decidim'
end
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
