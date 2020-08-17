# Elections Bulletin Board

In order to celebrate [End-to-end auditable votings](https://en.wikipedia.org/wiki/End-to-end_auditable_voting_systems) using the Elections module, you will need to connect your Decidim instance with an instance of the [Decidim Bulletin Board application](https://github.com/decidim/decidim-bulletin-board/), preferably run by an independent organization.

## Identification pair of keys generation

The first step needed to setup the connection is to generate an a pair of keys to identify the application against the Bulletin Board. This can be done running the following rake task in your application environment:

```sh
bundle exec rake decidim_elections:generate_identification_keys
```

This task will output the generated private and public keys. You should copy the public key and send it to the Bulletin Board administrator through a secure channel. When copying the key, include the starting and ending lines with the prefix `-----`.

After that, use one of these methods to make the private key available from your Decidim installation:

a. Copy the private key, paste in a new file and store its path on the environment variable `BULLETIN_BOARD_IDENTIFICATION_PRIVATE_KEY`.
b. Copy the private key and store that value on the environment variable `BULLETIN_BOARD_IDENTIFICATION_PRIVATE_KEY`.

Regardless of the used method, when copying the private key remember to include the lines prefixed by `-----` and ensure that the private key is not lost between deployments and servers reboots and that only can be accessed by the application.

## Configuration of the Bulletin Board application

The Bulletin Board administrator will store the received public key in their server and will send you back an API key. To complete the setup process you should store this API key and the Bulletin Board URL address on the environment variables `BULLETIN_BOARD_API_KEY` and `BULLETIN_BOARD_SERVER`, respectively.

The following YAML snippet with all the defined environment variables should be used in the `default` block of your application `config/secrets.yml` file. Maybe this is already done, as it was included in the Decidim applications generator during the development of the Elections module.

```yaml
  bulletin_board:
    identification_private_key: |
<%= ENV["BULLETIN_BOARD_IDENTIFICATION_PRIVATE_KEY"]&.indent(6) %>
    server: <%= ENV["BULLETIN_BOARD_SERVER"] %>
    api_key: <%= ENV["BULLETIN_BOARD_API_KEY"] %>
```

After restarting the Decidim instance, administrator users will be able to create elections on the configured Bulletin Board.
