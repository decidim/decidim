// = require decidim/map/controller
// = require decidim/map/controller/markers
// = require decidim/map/controller/static
// = require_self

((exports) => {
  exports.Decidim = exports.Decidim || {};

  const { MapMarkersController, MapStaticController } = exports.Decidim;

  /**
   * A factory method that creates a new map controller instance. This method
   * can be overridden in order to return different types of maps for
   * differently configured map elements.
   *
   * For instance, one map could pass an extra `type` configuration with the
   * value "custom" for the map element, this factory method would identify
   * it and then return a different controller for that map than the default.
   * This would allow this types of maps to function differently.
   *
   * An example how to use in the ERB view:
   *   <%= dynamic_map_for type: "custom" do %>
   *     <%= javascript_include_tag "map_customization" %>
   *   <% end %>
   *
   * And then the actual customization at `map_customization.js.es6`:
   *   var originalCreateMapController = window.Decidim.createMapController;
   *   window.Decidim.createMapController = (mapId, config) => {
   *     if (config.type === "custom") {
   *       // Obviously you need to implement CustomMapController for this to
   *       // work.
   *       return new window.Decidim.CustomMapController(mapId, config);
   *     }
   *
   *     return originalCreateMapController(mapId, config);
   *   }
   *
   * @param {string} mapId The ID of the map element.
   * @param {Object} config The map configuration object.
   * @returns {MapController} The controller for the map.
   */
  const createMapController = (mapId, config) => {
    if (config.type === "static") {
      return new MapStaticController(mapId, config);
    }

    return new MapMarkersController(mapId, config);
  }

  exports.Decidim.createMapController = createMapController;
})(window);
