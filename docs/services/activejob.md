# ActiveJob

For some kind of actions to work (for instance, user registration) you need to configure an [ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html) backend on your application.

If you don't want to have any other dependency, you can use [delayed_job](https://github.com/collectiveidea/delayed_job/), although Decidim is agnostic on which kind of backend do you use (ie sidekiq, resque, etc).
