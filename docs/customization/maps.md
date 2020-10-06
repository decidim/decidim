# Custom map providers

Decidim can be configured to use multiple different
[map service providers][link-docs-maps] but it can be also extended to use any
possible service provider out there.

If you want to create your own provider integration, you will need to find a
service provider that provides all the following services:

- [A geocoding server][link-wiki-geocoding] in order to turn user entered
  addresses into [geocoordinates][link-wiki-geocoordinates].
- [A geocoding autocompletion server][link-wiki-autocompletion] in order to
  suggest and predict addresses based on the user input and turning these
  suggested addresses into [geocoordinates][link-wiki-geocoordinates].
- [A map tile server][link-wiki-tile-server] for the dynamic maps, preferrably
  one that is compatible with the default [Leaflet][link-leaflet] map library.
- [A static map image server][link-wiki-static-maps] for the static map images
  e.g. on the proposal pages. This service is optional as Decidim will use the
  dynamic map tiles to generate a similar map element if the static map image
  cannot be provided.

One option is to host some or all of these services yourself as there are open
source alternatives available for all of these services. More information about
self hosting is available at the
[maps and geocoding configuration][link-docs-maps-multiple-providers]
documentation.

You may also decide to [disable some of the services][link-docs-maps-disable]
that are not available at your service provider but in order to get the full out
of Decidim, it is recommended to find a service provider with all these
services.

In case you want to use different service providers for the different categories
of map services, that is also possible. Instructions for this are provided in
the [maps and geocoding configuration][link-docs-maps-multiple-providers]
documentation.

## Creating your own map service provider

First thing you will need is to define a service provider module which also
defines all the services your provider is able to serve. An example service
provider module looks as follows:

```ruby
module Decidim
  module Map
    module Provider
      module Geocoding
        autoload :YourProvider, "decidim/map/provider/geocoding/your_provider"
      end
      module Autocomplete
        autoload :YourProvider, "decidim/map/provider/autocomplete/your_provider"
      end
      module DynamicMap
        autoload :YourProvider, "decidim/map/provider/dynamic_map/your_provider"
      end
      module StaticMap
        autoload :YourProvider, "decidim/map/provider/static_map/your_provider"
      end
    end
  end
end
```

Please note that you will need to place the utility classes for each category of
services under the paths defined for the autoloading functionality.

### Defining the geocoding utility

For the geocoding functionality, Decidim uses the [Geocoder gem][link-geocoder]
which does most of the heavy lifting. It is not necessary to use this gem but
in case your target service is already integrated with that gem, it makes this
step much easier for you. Take a look at the list of
[supported geocoding APIs][link-geocoder-apis] for the Geocoder gem.

In case your API is supported by the Geocoder gem, the only thing you need to do
to create your geocoding utility is to create the following empty class:

```ruby
module Decidim
  module Map
    module Provider
      module Geocoding
        class YourProvider < ::Decidim::Map::Geocoding
          # ... add your customizations here ...
        end
      end
    end
  end
end
```

If the target service has some other "lookup handle" defined in the Geocoder gem
than `:your_provider`, you may want to override the `handle` method in the
geocoding utility's class you just defined. This is passed for the Geocoder gem
as your lookup handle. An example of this can be seen in the
[`Decidim::Map::Provider::Geocoding::Osm`][link-code-osm-geocoder] class which
changes the handle to `:nominatim` instead of the default `:osm` which is not an
existing lookup handle in the Geocoder gem.

In case you want to customize the geocoding utility for your provider, you can
define the following methods in the utility class:

- `search(query, options = {})` - A common method for searching the geocoding
  API and returning an array of results. The results array contains the Geocoder
  gem's result objects of type
  [`Geocoder::Result::Base`][link-code-geocoder-result] or the result type
  specific to your API. If the first parameter is an address string, the method
  does a forward geocoding request finding the closest matching coordinate pairs
  for that address. If the first parameter is a coordinate pair array, the
  method does a reverse geocoding request finding the closest matching addresses
  for the search.
- `coordinates(address, options = {})` - A method that searches the best
  matching coordinates for the given address string. Only returns one coordinate
  pair as an array.
- `address(coordinates, options = {})` - A method that searches the best
  matching address for the given coordinate pair array. Only returns one address
  as a string.

Customization may be needed if you are not happy with the default results
returned by the Geocoder gem. For instance, in some occasions you might want to
pass extra query options to the geocoding API or sort the results differently
than what was returned by the API and what is already done in Decidim by
default.

In order to provide configuration options for the Geocoder gem's lookup, you can
pass them directly through the maps configuration with the following syntax:

```ruby
config.maps = {
  provider: :your_provider,
  api_key: Rails.application.secrets.maps[:api_key],
  geocoding: { extra_option: "value", another_option: "value" }
}
```

This would equal to configuring the Geocoder gem with the following code:

```ruby
Geocoder.configure(
  your_provider: {
    api_key: Rails.application.secrets.maps[:api_key],
    extra_option: "value",
    another_option: "value"
  }
)
```

Each geocoding API may require their own configuration options. Please refer to
the Geocoder gem's [supported geocoding APIs][link-geocoder-apis] documentation
to find out the available options for your API.

### Defining the geocoding autocompletion maps utility

For the geocoding autocompletion map functionality, you should preferrably use
a service provider that is compatible with [Photon][link-photon] which is
already integrated with Decidim.

If this is not possible, you can also create a custom geocoding autocompletion
maps utility for your own service provider by defining the following empty class
to start with:

```ruby
module Decidim
  module Map
    module Provider
      module Autocomplete
        class YourProvider < ::Decidim::Map::Autocomplete
          # ... add your customizations here ...
        end
      end
    end
  end
end
```

In case you want to customize the geocoding autocompletion map utility for your
provider, you can define the following methods in the utility class:

- `builder_class` - Returns a class for the geocoding autocompletion builder
  that is used to create the input fields for the autocompleted addresses in the
  front-end. By default, this would be
  `Decidim::Map::Provider::Autocomplete::YourProvider::Builder` or if that is
  not defined, defaults to `Decidim::Map::Autocomplete::Builder`. See below for
  further notes about the builder class.
- `builder_options` - A method that prepares the options for the builder
  instance that is used to create the maps in the front-end. By default, this
  is an empty hash that needs to be configured for each provider.

To see an example how to customize the static map utility, take a look at the
[HERE Maps geocoding autocomletion utility][link-code-here-autocomplete].

In order to provide configuration options for the geocoding autocompletion, you
can pass them directly through the maps configuration with the following syntax:

```ruby
config.maps = {
  provider: :your_provider,
  api_key: Rails.application.secrets.maps[:api_key],
  autocomplete: {
    url: "https://photon.example.org/api/"
  }
}
```

And then you can use these options in your provider utility as follows e.g. in
the `builder_options` method:

```ruby
def builder_options
  { url: configuration.fetch(:url, nil) }.compact
end
```

You will also need to define a builder class inside your provider utility class
as follows:

```ruby
module Decidim
  module Map
    module Provider
      module Autocomplete
        class Here < ::Decidim::Map::Autocomplete
          # ... other customizations go gere ...

          # This is the actual builder customization where you could define e.g.
          # the JavaScript asset which is used to initialize the geocoding
          # autocompletion functionality in the front-end:
          class Builder < Decidim::Map::Autocomplete::Builder
            def javascript_snippets
              template.javascript_include_tag("decidim/geocoding/provider/your_provider")
            end
          end
        end
      end
    end
  end
end
```

To see an example of the front-end JavaScript code that handles the geocoding
requests, you can take a look at the
[HERE Maps example][link-code-here-autocomplete-js]. You will have to listen to
the `geocoder-suggest.decidim` JavaScript event on all elements that have the
`data-decidim-geocoding` attribute defined which contains all the configurations
returned by the builder's `builder_options` method as mentioned above. For
example, if you passed the following configuration from that method:

```js
{ url: "https://photon.example.org/api/", other_config: "foo" }
```

This would be available in the JavaScript as follows:

```js
$(document).on("ready", () => {
  $("[data-decidim-geocoding]").each((_i, el) => {
    console.log($(el).data("decidim-geocoding"));
    // => This would print out:
    // {url: "https://photon.example.org/api/", otherConfig: "foo"}
  });
});
```

When you hook into the `geocoder-suggest.decidim` event on these methods, the
event callback will be provided three arguments:

- `event` - The event that you hooked into
- `query` - The text to be queried, i.e. what the user entered into the input
- `callback` - A callback method which you will need to call with your geocoding
  autocompletion results once the request to the API has finished in the
  front-end.

The `callback` method expects one argument which is the array of result objects.
The result objects need to contain the following keys:

- `key` - The key which will be matched against the user entered input
- `value` - The value which will be added to the address input if the user
  decides to select this value

Optionally, you can also include a `coordinates` key in the result object which
contains an array of two cordinates (latitude and longitude respectively). You
can also include any other data you might need in the front-end for these
results but it will be not used by Decidim.

The final code would look something like follows:

```js
$(document).on("ready", () => {
  $("[data-decidim-geocoding]").each((_i, el) => {
    const $input = $(el);
    const config = $input.data("decidim-geocoding");

    $input.on("geocoder-suggest.decidim", (event, query, callback) => {
        currentSuggestionQuery = setTimeout(() => {
          $.ajax({
            method: "GET",
            url: config.url,
            data: { apiKey: config.apiKey },
            dataType: "json"
          }).done((resp) => {
            if (resp.suggestions) {
              return callback(resp.suggestions.map((item) => {
                return {
                  key: item.label,
                  value: item.label,
                  coordinates: [item.latitude, item.longitude],
                  yourExtraData: item.yourExtraData
                }
              }));
            }
            return null;
          });
    });
  });
});
```

If your autocompletion API does not provide the coordinates information along
with the autocompletion requests, you can hook into another event to do extra
queries for the geocoordinates as follows:

```js
$(document).on("ready", () => {
  $("geocoder-suggest-select.decidim", (ev, selectedItem) => {
    console.log(selectedItem);
    // => This would print out what you returned for the `callback` as shown
    // above.

    // NOTE: YOU DON'T NEED THIS IF YOUR RESPONSE OBJECTS ALREADY CONTAINED THE
    //       COORDINATES IN THE `coordinates` KEY OF EACH RESULT OBJECT!
    // Then, once you know the coordinates, you trigger the following event on
    // the same input (obviously, you need to query the API first):
    const coordinates = [1.123, 2.234];
    $(ev.target).trigger("geocoder-suggest-coordinates.decidim", [coordinates]);
  });
});
```

Finally, if you want to pass these coordinates to the same form where your
address field is located at, you can use the `Decidim.attachGeocoding()` method
as follows:

```js
$(document).ready(function() {
  Decidim.attachGeocoding($("#your_address_input"));
});
```

Now the latitude and longitude coordinates would be passed to the same form
where the address input is located at. For example, if the address input had the
name `record[address]`, new hidden fields would be now generated for the
geocoding autocomplete suggestion's coordinates with the following names:

- `record[latitude]` for the latitude coordinate
- `record[longitude]` for the longitude coordinate

Then, you can read these values along with the form's POST data in order to
store the coordinates for your records in the back-end. This is not 100%
necessary but it improves the accuracy of the geocoding functionality and it
also avoids unnecessary double requests to the geocoding API (front-end +
back-end).

### Defining the dynamic maps utility

For the dynamic map functionality, you should primarily use a service provider
that is compatible with the [Leaflet library][link-leaflet] that ships with
Decidim. You can also integrate to services that are not compatible with Leaflet
but it will cause you more work and is not covered by this guide.

Please note that you don't necessarily even need to create your own dynamic maps
utility if your service provider is already compatible with the
[`Decidim::Map::Provider::DynamicMap::Osm`][link-code-osm-dynamic] provider. In
order to configure your custom OSM compatible service provider take a look at
the [maps and geocoding configuration][link-docs-maps-osm] documentation.

If your service provider is not fully compatible with the default OSM provider,
you can start writing your customizations by creating an empty dynamic map
provider utility with the following code:

```ruby
module Decidim
  module Map
    module Provider
      module DynamicMap
        class YourProvider < ::Decidim::Map::DynamicMap
          # ... add your customizations here ...
        end
      end
    end
  end
end
```

In case you want to customize the dynamic map utility for your provider, you can
define the following methods in the utility class:

- `builder_class` - Returns a class for the dynamic map builder that is used
  to create the maps in the front-end. By default, this would be
  `Decidim::Map::Provider::DynamicMap::YourProvider::Builder` or if that is not
  defined, defaults to `Decidim::Map::DynamicMap::Builder`. See below for
  further notes about the builder class.
- `builder_options` - A method that prepares the options for the builder
  instance that is used to create the maps in the front-end. By default, this
  prepares the tile layer configurations for the Leaflet map.

In addition, you may want to customize the Builder class in case you are not
happy with the default dynamic map builder functionality. To see an example how
to customize the builder, take a look at the
[HERE Maps builder class][link-code-here-dynamic]. Please note that the custom
dynamic map builder needs to extend the
[`Decidim::Map::DynamicMap::Builder`][link-code-dynamic-map] class as you can
also see from the HERE Maps example.

The builder class works directly with the view layer and can refer to the view
in question or any methods available for the view using the `template` object
inside the builder. You may be already familiar with a similar builder concept
if you have ever used the [Rails Form Builder][link-rails-form-builder].

In order to provide configuration options for the dynamic maps, you can pass
them directly through the maps configuration with the following syntax:

```ruby
config.maps = {
  provider: :your_provider,
  api_key: Rails.application.secrets.maps[:api_key],
  dynamic: {
    tile_layer: {
      url: "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}&style={style}",
      api_key: true,
      foo: "bar=baz",
      style: "bright-style",
      attribution: %{
        <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors
      }.strip
    }
  }
}
```

This will cause the following options to be available for the builder instance
by default:

```ruby
{
  tile_layer: {
    url: "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}&style={style}",
    configuration: {
      api_key: Rails.application.secrets.maps[:api_key],
      foo: "bar=baz",
      style: "bright",
      attribution: %{
        <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors
      }.strip
    }
  }
}
```

And by default, this will cause the Leaflet tile layer to be configured as
follows:

```js
L.tileLayer(
  "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}&style={style}",
  {
    apiKey: "your_secret_key",
    foo: "bar=baz",
    style: "bright",
    attribution: '<a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors'
  }
).addTo(map);
```

### Defining the static maps utility

For the static map functionality, you should preferrably use a service provider
that is compatible with [osm-static-maps][link-osm-static-maps] which is already
integrated with Decidim.

If this is not possible, you can also create a custom static maps utility for
your own service provider by defining the following empty class to start with:

```ruby
module Decidim
  module Map
    module Provider
      module StaticMap
        class YourProvider < ::Decidim::Map::StaticMap
          # ... add your customizations here ...
        end
      end
    end
  end
end
```

If you want to use dynamic map elements for the static maps as well, you can
leave the static map utility empty as shown above. Decidim will create a dynamic
map replacement for the static map image in case the static map utility will not
return a proper map URL.

In case you want to customize the static map utility for your provider, you can
define the following methods in the utility class:

- `link(latitude:, longitude:, options: {})` - Returns a link for the given
  geographic location where the static map image is linked to. By default, this
  will return a link to www.openstreetmap.org.
- `url(latitude:, longitude:, options: {})` - Returns a URL for loading the
  static map image from the service provider. By default, this will return a
  link to the configured static map URL with the following URL query parameters:
  - `latitude` - The value for the `latitude` option provided for the method.
  - `longitude` - The value for the `longitude` option provided for the method.
  - `zoom` - The value for key `:zoom` in the options hash (default: 15).
  - `width` - The value for key `:width` in the options hash (default: 120).
  - `height` - The value for key `:height` in the options hash (default: 120).
- `url_params(latitude:, longitude:, options: {})` - Returns a hash of prepared
  URL parameters for the `url` method. For the default parameters, see the
  explanations above for the `url` method.
- `image_data(latitude:, longitude:, options: {})` - Does a request to the URL
  defined by the `url` method and returns the raw binary data in the response
  body of that request. This data will be cached by Decidim once fetched from
  the API to speed up further displays of the same static map.

To see an example how to customize the static map utility, take a look at the
[HERE Maps static map utility][link-code-here-static].

In order to provide configuration options for the static maps, you can pass them
directly through the maps configuration with the following syntax:

```ruby
config.maps = {
  provider: :your_provider,
  api_key: Rails.application.secrets.maps[:api_key],
  static: {
    url: "https://staticmap.example.org/",
    foo: "bar",
    style: "bright"
  }
}
```

And then you can use these options in your provider utility as follows e.g. in
the `url_params` method:

```ruby
def url_params(latitude:, longitude:, options: {})
  super.merge(
    style: configuration.fetch(:style, "dark"),
    foo: configuration.fetch(:foo, "baz")
  )
end
```

When calling the `url` method with the latitude of `1.123` and longitude of
`2.456`, the utility would now generate the following URL with these
configurations and customizations:

```bash
https://staticmap.example.org/?latitude=1.123&longitude=2.456&zoom=15&width=120&height=120&style=bright&foo=bar
```

If you want to use the dynamic map replacements for the static map images, do
not configure `static` section for your maps:

```ruby
config.maps = {
  provider: :your_provider,
  api_key: Rails.application.secrets.maps[:api_key]
  # static: { ... } # LEAVE THIS OUT
}
```

Even if you decide to use the dynamic map replacements, you will still need to
define the static map utility because it is used to generate the link where
users will be pointed at when they click the map image. In this case, the static
map utility can be empty as you won't need any customization for it to work.

## Configuring your own map service provider

After you have finished all the steps shown above, you will need to configure
your service provider for Decidim. The configuration key for the example service
provider referred to in this documentation would be `:your_provider`. For
configuration, refer to the [maps and geocoding configuration][link-docs-maps]
documentation.

[link-code-dynamic-map]: /decidim-core/lib/decidim/map/dynamic_map.rb
[link-code-geocoder-result]: https://github.com/alexreisner/geocoder/blob/master/lib/geocoder/results/base.rb
[link-code-here-autocomplete]: /decidim-core/lib/decidim/map/provider/autocomplete/here.rb
[link-code-here-autocomplete-js]: /decidim-core/app/assets/javascripts/decidim/geocoding/provider/here.js.es6
[link-code-here-dynamic]: /decidim-core/lib/decidim/map/provider/dynamic_map/here.rb
[link-code-here-static]: /decidim-core/lib/decidim/map/provider/static_map/here.rb
[link-code-osm-dynamic]: /decidim-core/lib/decidim/map/provider/dynamic_map/osm.rb
[link-code-osm-geocoder]: /decidim-core/lib/decidim/map/provider/geocoding/osm.rb
[link-docs-maps]: /docs/services/maps.md
[link-docs-maps-disable]: /docs/services/maps.md#disabling
[link-docs-maps-osm]: /docs/services/maps.md#configuring-open-street-maps-based-service-providers
[link-docs-maps-multiple-providers]: /docs/services/maps.md#combining-multiple-service-providers
[link-geocoder]: https://github.com/alexreisner/geocoder
[link-geocoder-apis]: https://github.com/alexreisner/geocoder/blob/master/README_API_GUIDE.md
[link-leaflet]: https://leafletjs.com/
[link-osm-static-maps]: https://github.com/jperelli/osm-static-maps
[link-photon]: https://github.com/komoot/photon
[link-rails-form-builder]: https://guides.rubyonrails.org/form_helpers.html#customizing-form-builders
[link-wiki-autocompletion]: https://en.wikipedia.org/wiki/Autocomplete
[link-wiki-geocoding]: https://en.wikipedia.org/wiki/Geocoding
[link-wiki-geocoordinates]: https://en.wikipedia.org/wiki/Geographic_coordinate_system
[link-wiki-map-tiles]: https://wiki.openstreetmap.org/wiki/Tiles
[link-wiki-static-maps]: https://wiki.openstreetmap.org/wiki/Static_map_images
[link-wiki-tile-server]: https://en.wikipedia.org/wiki/Tile_Map_Service
