# Manual installation tutorial

## Step by step

In order to develop on decidim, you'll need:

* **Git** 2.15+
* **PostgreSQL** 9.5+
* **Ruby** 2.5.0 (2.3+ should work just fine, but that's the version we test against)
* **NodeJS** 9.x.x
* **ImageMagick**
* **Chrome** browser and [chromedriver](https://sites.google.com/a/chromium.org/chromedriver/).

We're starting with an Ubuntu 16.04 LTS. This is an opinionated guide and YMMV, so if you're free to use the technology that you fell most comfortable on. If you have any doubts and you're blocked you can go and ask on [our Gitter](https://gitter.im/decidim/decidim). We recommend that you follow some Ruby on Rails tutorials (like [Getting Started with Ruby on Rails](http://guides.rubyonrails.org/getting_started.html)) and have some knowledge on how gems and engines work.

On this tutorial we'll see how to install rbenv, PostgreSQL and Decidim, and how to configure everything together.

### Installing rbenv

First we're going to install rbenv, for managing various ruby versions. We're following the guide from [DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-16-04). You could also use [rvm](https://rvm.io/) as an alternative on this step. On these instruction we're using the latest ruby published version at the moment (2.5.3), but you should check this out on [Ruby official website](https://www.ruby-lang.org/en/downloads/).

```bash
sudo apt update
sudo apt install -y build-essential autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libicu-dev
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 2.5.3
rbenv global 2.5.3
echo "gem: --no-document" > ~/.gemrc
gem install bundler
```

### Installing PostgreSQL

Now we're going to install PostgreSQL for the database:

```bash
sudo apt install -y postgresql libpq-dev
sudo -u postgres psql -c "CREATE USER decidim_app WITH SUPERUSER CREATEDB NOCREATEROLE PASSWORD 'thepassword'"
```

You need to change the password (on this example is "thepassword") and save it somewhere to configure it later with the application.

### Installing Decidim

Next, we need to install the `decidim` gem:

```bash
gem install bootsnap
gem install listen
gem install decidim
```

Afterwards, we can create an application with the nice `decidim` executable, where `decidim_application` is your application name (ie decidim.barcelona):

```bash
decidim decidim_application
cd decidim_application
```

We recommend that you save it all on Git.

```bash
git init .
git commit -m "Initial commit. Generated with Decidim 0.X https://decidim.org"
```

### Configure the database

You need to modify your secrets (see `config/database.yml`). For this you can use [figaro](https://github.com/laserlemon/figaro), [dotenv](https://github.com/bkeepers/dotenv) or [rbenv-vars](https://github.com/rbenv/rbenv-vars). You should always be careful of not uploading your plain secrets on git or your version control system. You can also upload the encrypted secrets, using the sekrets gem or if you're on Ruby on Rails greater than 5.1 you can do it natively.

For instance, for working with figaro, add this to your `Gemfile`:

```ruby
gem "figaro"
```

Then install it:

```bash
bundle install
bundle exec figaro install
```

Next add this to your `config/application.yml`, using the setup the PostgreSQL database name, user and password that you configure before.

```yaml
DATABASE_HOST: localhost
DATABASE_USERNAME: decidim_app
DATABASE_PASSWORD: your_password
```

Finally, save it all to git:

```bash
git add .
git commit -m "Adds figaro configuration management"
```

### Initializing your app for local development

We should now setup your database:

```bash
bin/rails db:create db:migrate
bin/rails db:seed
```

This will also create some default data so you can start testing the app:

* A `Decidim::System::Admin` with email `system@example.org` and password `decidim123456`, to log in at `/system`.
* A `Decidim::Organization` named `Decidim Staging`. You probably want to change its name and hostname to match your needs.
* A `Decidim::User` acting as an admin for the organization, with email `admin@example.org` and password `decidim123456`.
* A `Decidim::User` that also belongs to the organization but it's a regular user, with email `user@example.org` and password `decidim123456`.

This data won't be created in production environments, if you still want to do it, run:

```bash
SEED=true rails db:setup
```

You can now start your server!

```bash
bin/rails s
```

Visit [http://localhost:3000](http://localhost:3000) to see your app running. 🎉 🎉
