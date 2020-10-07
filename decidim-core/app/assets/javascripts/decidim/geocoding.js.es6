// = require tribute
// = require decidim/geocoding/format_address

((exports) => {
  const $ = exports.$; // eslint-disable-line
  const Tribute = exports.Tribute;

  $(() => {
    $("[data-decidim-geocoding]").each((_i, el) => {
      const $input = $(el);
      const $fieldContainer = $input.parent();

      $fieldContainer.addClass("has-tribute");

      const tribute = new Tribute(
        {
          autocompleteMode: true,
          // autocompleteSeparator: / \+ /, // See below, requires Tribute update
          allowSpaces: true,
          positionMenu: false,
          replaceTextSuffix: "",
          menuContainer: $fieldContainer.get(0),
          noMatchTemplate: null,
          values: (text, cb) => {
            $input.trigger("geocoder-suggest.decidim", [text, cb]);
          }
        }
      );

      // Port https://github.com/zurb/tribute/pull/406
      // This changes the autocomplete separator from space to " + " so that
      // we can do searches such as "streetname 4" including a space. Otherwise
      // this would do two separate searches for "streetname" and "4".
      tribute.range.getLastWordInText = (text) => {
        const final = text.replace(/\u00A0/g, " ");
        const wordsArray = final.split(/ \+ /);
        const worldsCount = wordsArray.length - 1;

        return wordsArray[worldsCount].trim();
      };

      tribute.attach($input.get(0));

      $input.on("tribute-replaced", function(ev) {
        const selectedItem = ev.detail.item.original;
        $input.trigger("geocoder-suggest-select.decidim", [selectedItem]);

        // Not all geocoding autocomplete APIs include the coordinates in the
        // suggestions response. Therefore, some APIs may require additional
        // query for the coordinates, which should trigger this event for the
        // input element.
        if (selectedItem.coordinates) {
          $input.trigger("geocoder-suggest-coordinates.decidim", [selectedItem.coordinates]);
        }
      });

      $input.data("geocoder-tribute", tribute);
    });
  });
})(window);
