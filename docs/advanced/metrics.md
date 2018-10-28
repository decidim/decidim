# Metrics

Metrics calculations must be executed everyday. Some `rake task` have been added to perform it.

- To execute all metrics at once. Related to previous date from *today*

  ```ruby
  bundle exec rake decidim:metrics:all
  ```

- To execute an specific metric. Related to previous date from *today*

  ```ruby
  bundle exec rake decidim:metrics:one["<metric name>"]
  ```

- To execute metrics for a given date (all or an specific one)

  ```ruby
  bundle exec rake decidim:metrics:all["YYYY-MM-DD"]
  bundle exec rake decidim:metrics:one["<metric name>","YYYY-MM-DD"]
  ```

## Current available metric names

- *users*, confirmed Users
- *proposals*, available Proposals
- *accepted_proposals*, currently accepted Proposals
- *votes*, votes in Proposals

## To configure it correctly

- A **crontab** line must be added to your server to maintain them updated daily. You could use [Whenever](https://github.com/javan/whenever) to manage it directly from the APP
- A **ActiveJob** queue, like [Sidekiq](https://github.com/mperham/sidekiq) or [DelayedJob](https://github.com/collectiveidea/delayed_job/)
