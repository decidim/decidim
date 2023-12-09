# Decidim::Elections

:warning: This module is under development and is not ready to be used in production.

The Elections module adds elections to any participatory space.

## Usage

Elections will be available as a Component for a Participatory Space.

In order to celebrate [End-to-end auditable votings](https://en.wikipedia.org/wiki/End-to-end_auditable_voting_systems) using the Elections module, you will need to connect your Decidim instance with an instance of the [Decidim Bulletin Board application](https://github.com/decidim/decidim-bulletin-board/). To create this connection, please check the [instructions](https://docs.decidim.org/en/services/elections_bulletin_board/).

## Development

In the case that you only want to use this module for local development or testing purposes, you have an example docker-compose configuration in `docs/`. Mind that this setup is not recommended for production environments. It works with default seeds and configurations for a Decidim installation, so you should not do anything.

```bash
cd docs/docker/bulletin_board
docker-compose up
```

One important caveat is that as the Trustees' key generation functionality uses the IndexedDB API, and at least in Firefox there is unsupported in the Private Browsing mode (see ticket [#1639542 in Mozilla's Bugzilla](https://bugzilla.mozilla.org/show_bug.cgi?id=1639542)). As a workaround there is the [Firefox Multi-Account Containers addon](https://addons.mozilla.org/es/firefox/addon/multi-account-containers/).

## Testing

Besides the [set-up typical for Decidim](https://docs.decidim.org/en/develop/develop/testing), for some of the specs a Bulletin Board installation is needed, running in port 5017 by default with the `DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL` environment variable set up with the "true" string. There is a working configuration on `docs`.

```bash
cd docs/docker/bulletin_board_test
docker-compose up
```

As the Bulletin Board service is a necessary dependency for this module to work, if it is not running while executing the specs, the following exception will be shown.

> Failure/Error: Decidim::Elections.bulletin_board.reset_test_database
>
> StandardError:
> Sorry, something went wrong
>
> ./spec/shared/test_bulletin_board_shared_context.rb:6:in 'block (2 levels) in <top (required)>'
> (...)
> -- Caused by:
> Errno::ECONNREFUSED:
> Connection refused - connect(2) for 127.0.0.1:5017
> ./spec/shared/test_bulletin_board_shared_context.rb:6:in 'block (2 levels) in <top (required)>'

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

### Identification numbers

For the verification of the participants' data in the Voting's census, you can configure which type of documents a participant can have. By default these documents are `identification_number` and `passport`, but in some countries you may need to adapt these to your specifics needs. For instance, in Spain there are `dni`, `nie` and `passport`.

For configuring these you can do so with the Environment Variable `ELECTIONS_DOCUMENT_TYPES`.

```env
ELECTIONS_DOCUMENT_TYPES="dni,nie,passport"
```

You need to also add the following keys in your i18n files (i.e. `config/locales/en.yml`).

```yaml
en:
  decidim:
    votings:
      census:
        document_types:
          dni: DNI
          nie: NIE
          passport: Passport
```

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
