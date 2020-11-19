# Batch email notifications

Batch email notifications are a way to send several email notifications at the same time.

This is useful for grouping notifications and not overloading your users emails.

Notifications are sent in groups, sorted from the most recent notifications.

Notifications that have not been sent after a certain time are not sent at all. This means that your users have already received plenty of them and will already have to visit the platform.

Deleting a notification cancels the future associated email.

This is based on 3 parameters:

- batch_email_notifications_enabled: Enable batch email notifications and disable single email notification (default to false)

- batch_email_notifications_expired: period of time after which a notification is considered to have expired (default to 1 week)

- batch_email_notifications_max_length: Number of notifications to send in the same email (default to 5)

## How to setup?

### App setup

In `config/initialize/decidim.rb`

Set to desired value

```ruby
config.batch_email_notifications_enabled = true
config.batch_email_notifications_expired = 1.week
config.batch_email_notifications_max_length = 5
```

### Server setup

Batch email notification required to execute a rake task ("rake decidim:batch_email_notifications:send") at regular intervals.

1. Cron setup

    Use `crontab -e` and enter the following lines:

    ```shell script
    0 */3 * * * cd {MY_APP} && {/path/to/bundle} exec rake decidim:batch_email_notifications:send
    ```

    You could find the documentation about cron on [cron man page](https://www.man7.org/linux/man-pages/man8/cron.8.html)

1. Heroku scheduler

    You can find information on how to setup heroku scheduler on [heroku documentation](https://devcenter.heroku.com/articles/scheduler)

1. Sidekiq scheduler

    In `config/sidekiq.yml`

    ```yaml
    # sidekiq_scheduler.yml

    batch_email_notifications:
      every: ['3h', first_in: '1m']
      class: Decidim::BatchEmailNotificationsGeneratorJob
      queue: scheduled
      description: 'This job executes batch email notifications'
    ```
