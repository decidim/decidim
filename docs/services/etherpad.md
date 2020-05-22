# Etherpad

On some cases, users need to have near real time collaborative writing, for instance for having the minutes on a physical meeting.

To ease online/offline participation, Decidim can be integrated with Etherpad so meetings can have their own pads.

## Integration

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

```yaml
  etherpad:
    server: <%= ENV["ETHERPAD_SERVER"] %>
    api_key: <%= ENV["ETHERPAD_API_KEY"] %>
    api_version: <%= ENV["ETHERPAD_API_VERSION"] %>
```

## How is Etherpad Lite integrated in Meetings?

To better understand this feature, the final idea is to have the three moments of a meeting covered on Decidim itself by default:

- **Before the meeting**, you let know that the meeting is going to happen, where, when and what is going to be discussed
- **During the meeting**, notes can be taken on a collaborative way
- **After the meeting**, you upload the notes, minutes, metadata and/or pictures to have a record on what was discussed

Pad creation can be enabled by administrators in each `Meetings` component. When enabled, the public view of a Meeting renders an iframe which encapsulates the integrated Pad. This Pad is automatically created before rendering, so there's nothing the user or the administrators has to do to see the Pad.

The pad iframe is only accessible for 24 hours before and 72 hours after the meeting. After the meeting only the read only URL for this pad is shown.
