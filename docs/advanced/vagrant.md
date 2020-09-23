# Vagrant

Vagrant is an open-source software product for building and maintaining portable virtual software development environments.

It needs [Vagrant](https://www.vagrantup.com/docs/installation) and [Virtualbox](https://www.virtualbox.org/) installed in order to work.

To get started, first clone the decidim repo

```console
git clone https://github.com/decidim/decidim
```

Switch to the cloned folder

```console
cd decidim
```

Start the vagrant virtual machine

```console
vagrant up
```

Connect to the virtual machine

```console
vagrant ssh
```

Then create a development application

```console
bundle install
bundle exec rake development_app
bundle exec rails server -b 0.0.0.0
```

Your decidim application is now available on `localhost:3000`

You may find more informations on [vagrant official documentation](https://www.vagrantup.com/docs)
