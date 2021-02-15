# Videoconferences

For embedded videoconferences in the Meetings component, some options can be defined to use a server and api other than the default one.

## Jitsi

### Integration

Set the domain and API URL for your Jitsi server in
`config/initializers/decidim.rb` and `config/secrets.yml`

An example snippet in `config/initializers/decidim.rb` may be:

```ruby
config.videoconferences = {
  jitsi: {
    domain: Rails.application.secrets.videoconferences[:jitsi][:domain],
    api_url: Rails.application.secrets.videoconferences[:jitsi][:api_url]
  }
}
```

and then in `config/secrets.yml`:

```yaml
  videoconferences:
    jitsi:
      domain: <%= ENV["JITSI_DOMAIN"] %> # e.g. meet.jit.si
      api_url: <%= ENV["JITSI_API_URL"] %> # e.g. https://meet.jit.si/external_api.js 
```

### How is Jitsi integrated in Meetings?

When a meeting is of the Embedded Videoconference type, a button will be shown on the public page for the meeting for participants to join the videoconference, n minutes before the meeting start time and n minutes after the meeting end time.

Once clicked, the user will be displayed an iframe with the Jitsi videoconference.

Decidim will generate a random room name to be used by the Jitsi API, and if the user is logged it will populate the display name with the user name.

Users cannot see the room name or share the videoconference link, to prevent unwanted participants to join.