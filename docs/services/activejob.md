# ActiveJob

For some kind of actions to work on production (for instance, sending emails on user registration) you need to configure an [ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html) backend on your application.

If you don't want to introduce any other external dependencies for `decidim` (such as `redis`), you can use the `delayed_job` backend. That setup only depends on an underlying database which is already a requirement for `decidim` to work. Add the [delayed_job](https://github.com/collectiveidea/delayed_job/) gem to your `Gemfile` and follow the instructions in its readme to set it up.

However, Decidim is agnostic on which kind of backend do you use, so feel free to set up the backend (ie `sidekiq`, `resque`, etc) you like the most.
