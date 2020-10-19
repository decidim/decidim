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

## Issues related to cookies and Iframes

Etherpad requires to set a cookie in order to work.

The way Decidim integrates Etherpad is by creating and Iframe that calls the specific URL for an Etherpad instance. This means that the cookie needs to be created in the context of that Iframe, which is a different one that the Decidim application itself.

Now, recent versions of browsers don't like that and have started to block what's known as "3rd party cookies" (usually used as a tracking mechanism). This is a problem because, usually, Etherpad is installed in a different domain/server and the ability to deal with this situation has been fixed in very [recent versions](https://github.com/ether/etherpad-lite/pull/4384) of Etherpad.

In order to make sure your installation of Etherpad is compatible with Iframe embedding, it is necessary that the cookie generated follows these parameters:

```http
Set-Cookie: session=your_session; SameSite=None; Secure
```

By default, Etherpad sets the `SameSite` attribute to "Lax", which causes problems, you need to be sure it is set to "None". Remember that your Etherpad instance MUST runt under **https** for this to work.

Also, it is highly recommended that you use some sort of proxy that makes your Etherpad instance a subdomain of your Decidim instance. Although this is not strictly required, if you don't do that, some browsers might make you disable 3rd party cookies (eg: Safari) to be able to use the embedded Etherpad.

The suggested `docker-compose-etherpad.yml` provided by Decidim uses an image of Etherpad that incorporates the changes related to this problem. If you are using your custom instance of Etherpad, make sure that incorporate this [changes](https://github.com/ether/etherpad-lite/pull/4384) and that you set these ENV variables as follows:

```sh
TRUST_PROXY=true
COOKIE_SAME_SITE=None
```

The `TRUST_PROXY` variable is necessary if you are handling SSL through a external service (ie: Cloudflare), if unsure set it to true.

## How is Etherpad Lite integrated in Meetings?

To better understand this feature, the final idea is to have the three moments of a meeting covered on Decidim itself by default:

- **Before the meeting**, you let know that the meeting is going to happen, where, when and what is going to be discussed
- **During the meeting**, notes can be taken on a collaborative way
- **After the meeting**, you upload the notes, minutes, metadata and/or pictures to have a record on what was discussed

Pad creation can be enabled by administrators in each `Meetings` component. When enabled, the public view of a Meeting renders an iframe which encapsulates the integrated Pad. This Pad is automatically created before rendering, so there's nothing the user or the administrators has to do to see the Pad.

The pad iframe is only accessible for 24 hours before and 72 hours after the meeting. After the meeting only the read only URL for this pad is shown.
