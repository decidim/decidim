((exports) => {
  // If you want to customize the geocoder address format which is displayed
  // when showing the geocoding results list, add this configuration code to
  // your geocoder at config/initializers/decidim.rb:
  // config.maps = {
  //   # ... other configs ...
  //   autocomplete: {
  //     address_format: [%w(street houseNumber), "city", "country"]
  //   }
  // }
  //
  // For the available address keys, refer to the provider's own documentation.
  const compact = (items) => items.filter(
    (part) => part !== null && typeof part !== "undefined" && `${part}`.trim().length > 0
  );
  const formatAddress = (object, keys, separator = ", ") => {
    const parts = keys.map((key) => {
      if (Array.isArray(key)) {
        return formatAddress(object, key, " ");
      }
      return object[key] || object[key.toLowerCase()];
    })

    return compact(parts).join(separator).trim();
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.geocodingFormatAddress = formatAddress;
})(window);
