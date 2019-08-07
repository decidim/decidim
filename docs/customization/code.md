# Code

Decidim is multiple things:

* A command line utility, which can create an application
* A set of libraries, that the application can use

Most of the time, you should work with the generated application. That application (development_app on this docs) should be named as your project, for instance for Barcelona City Council is `DecidimBarcelona`, so for creating it should be:

```console
decidim DecidimBarcelona
```

If you want to override/change anything (for instance the homepage), you can just do it with the same name of the file, through Monkey Patching.

If you want to extend Decidim, the prefered way should be by having a Module. This is a Ruby on Rails Engine which provides ruby code (models, views, controllers, assets, etc). You can use it through multiple ways:

* Putting it on the same directory as your app and pointing on the Gemfile. [See example on GitHub](https://github.com/AjuntamentdeBarcelona/decidim-barcelona/tree/c210b5338d7ba1338c9879627e081da1441f1946). For instance:

```ruby
gem "decidim-debates", path: "decidim-debates"
```

* Publishing on a git reposotory and pointing in on the Gemfile. For instance:

```ruby
gem "decidim-consultations", git: "https://github.com/decidim/decidim-module-consultations"
```

* Publishing it on rubygems.org
