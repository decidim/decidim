# Etherpad

Decidim can be integrated with Etherpad so meetings can have their own pads.

In order to use it you need to have your own Etherpad deployment, you can do it
with the Docker compose using the provided `docker-compose-etherpad.yml`.

You should edit that file to configure the environment variables and then run:

```sh
docker swarm init # just one time

docker stack deploy --compose-file docker-compose-etherpad.yml decidim-etherpad
```

After deploying Etherpad, you should get back to Decidim's server and set the Etherpad host and API Key at
`config/initializers/decidim.rb` and `config/secrets.yml`

An example snippet in `config/initializers/decidim.rb` may be:

```ruby
config.etherpad = {
  server: Rails.application.secrets.etherpad[:server],
  api_key: Rails.application.secrets.etherpad[:api_key],
  api_version: Rails.application.secrets.etherpad[:api_version]
}
```

and then in `config/secrets.yml`:

```
  etherpad:
    server: <%= ENV["ETHERPAD_SERVER"] %>
    api_key: <%= ENV["ETHERPAD_API_KEY"] %>
    api_version: <%= ENV["ETHERPAD_API_VERSION"] %>
```
