# Decidim::Elections

:warning: This module is under development and is not ready to be used in production.

The Elections module adds elections to any participatory space.

## Usage

Elections will be available as a Component for a Participatory Space.

In order to celebrate [End-to-end auditable votings](https://en.wikipedia.org/wiki/End-to-end_auditable_voting_systems) using the Elections module, you will need to connect your Decidim instance with an instance of the [Decidim Bulletin Board application](https://github.com/decidim/decidim-bulletin-board/). To create this connection, please check the [instructions](https://docs.decidim.org/en/services/elections_bulletin_board/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-elections"
```

And then execute:

```bash
bundle
```

## Configuration

### Scheduled tasks

For the Elections module to function as expected, there are some background tasks that should be scheduled to be executed regularly. Alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

You can configure it with `crontab -e`, for instance if you've created your Decidim application on /home/user/decidim_application:

```bash
# Remove census export files
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim_votings_census:delete_census_access_codes_export
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
