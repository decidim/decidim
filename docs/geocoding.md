# Geocoding

## Configuring geocoding

Decidim has the ability to geocode proposals and meetings using the [Here](http://here.com) service, and no other provider is officially supported.

After generating your app, you'll see that your `config/initializers/decidim.rb` file has come commented code about geocoding:

```ruby
# Geocoder configuration
# config.geocoder = {
#   static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview",
#   here_app_id: Rails.application.secrets.geocoder["here_app_id"],
#   here_app_code: Rails.application.secrets.geocoder["here_app_code"]
# }
```

If you want to enable geocoding in your app:

1. Uncomment or add the previous code in your `config/initializers/decidim.rb`.
1. Make sure your `config/secrets.yml` file has the needed section (it should be added by the genertator automatically).
1. Get your app ID and code from Here.com and set them as environment variables, as required by your `config/secrets.yml` file.

## Enabling geocoding

Once geocoding is configured, you'll need to activate it. As of April 2017, only proposals and meetings have geocoding.

### Proposals

In order to enable geocoding for proposals you'll need to edit the fature configuration and set the global flag to true. This works for that specific feature, so you can have geocoding enabled for meetings in a participatory process, and disabled for another one.

### Meetings

Meetings do not have a configuration option for geocoding. Instead, if geocoding is configured it will try to geocode the address every time you create or update a meeting.. As of April 2017 there's no way to enable or disable geocoding per meetings feature.
