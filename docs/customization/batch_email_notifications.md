# Batch email notifications

Batch email notifications are a way to send several email notifications at the same time.

This is based on 3 parameters:

- batch_email_notifications_enabled: Enable batch email notifications and disable single email notification (default to false)

- batch_email_notifications_interval: Set interval to check for unsent notifications (default is 24 hours)

- batch_email_notifications_max_length: Number of notifications to send in the same email (default to 5)

## How to setup?

1. Cron setup

    Use `crontab -e` and enter the following lines:

    ```shell script
    0 0 * * * cd {MY_APP} && {/path/to/bundle} exec rake decidim:batch_email_notifications:send
    ```

    You could find the documentation about cron on [cron man page](https://www.man7.org/linux/man-pages/man8/cron.8.html)
1. Heroku scheduler

    You can find information on how to setup heroku scheduler on [heroku documentation](https://devcenter.heroku.com/articles/scheduler)

1. Sidekiq scheduler

    In `config/sidekiq.yml`

    ```yaml
    # sidekiq_scheduler.yml

    batch_email_notifications:
      every: ['6h', first_in: '1m']
      class: Decidim::BatchEmailNotificationsGeneratorJob
      queue: scheduled
      description: 'This job executes batch email notifications'
    ```
