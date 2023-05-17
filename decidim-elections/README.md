# Decidim::Elections

:warning: This module is under development and is not ready to be used in production.

The Elections module adds elections to any participatory space.

## Usage

Elections will be available as a Component for a Participatory Space.

In order to celebrate [End-to-end auditable votings](https://en.wikipedia.org/wiki/End-to-end_auditable_voting_systems) using the Elections module, you will need to connect your Decidim instance with an instance of the [Decidim Bulletin Board application](https://github.com/decidim/decidim-bulletin-board/). To create this connection, please check the [instructions](https://docs.decidim.org/en/services/elections_bulletin_board/).

## Development

In the case that you only want to use this module for local development or testing purposes, you have an example docker-compose configuration in `docs/`. Mind that this setup is not recommended for production environments. It works with default seeds and configurations for a Decidim installation, so you shouldn't do anything.

```bash
cd docs/docker/bulletin_board
docker-compose up
```

One important caveat is that as the Trustees' key generation functionality uses the IndexedDB API, and at least in Firefox there isn't support for this in the Private Browsing mode (see ticket [#1639542 in Mozilla's Bugzilla](https://bugzilla.mozilla.org/show_bug.cgi?id=1639542)). As a workaround there's the [Firefox Multi-Account Containers addon](https://addons.mozilla.org/es/firefox/addon/multi-account-containers/).

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

You can configure it with `crontab -e`, for instance if you have created your Decidim application on /home/user/decidim_application:

```bash
# Remove census export files
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim_votings_census:delete_census_access_codes_export
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
