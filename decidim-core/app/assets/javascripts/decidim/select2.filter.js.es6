/**
 * Select2 filter component.
 */

// included to past tests
const jQuery = require('jquery');

((exports) => {
  class Select2Filter {
    constructor(element) {

      let selectedLang = jQuery("html").attr('lang') || 'en';
      
      let $element = jQuery(element);
      let options = {
        language: selectedLang,
        multiple: $element.attr("multiple")==="multiple",
        allowClear: true
      };
      if ($element.data("remote")) {
        options.ajax = {
          url: $element.data("remote"),
          delay: 250,
          cache: true
        };
      }
      $element.select2(options);

      // Avoid opening dropdown after clearing selection: https://github.com/select2/select2/issues/3320
      $element.on('select2:unselecting', function() {
        $element.data('unselecting', true);
      }).on('select2:open', function() {
        if ($element.data('unselecting')) {
          $element.removeData('unselecting');
          $element.select2('close');
        }
      });

      this.$element = $element;
    }

    destroy() {
      this.$element.select2("destroy");
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.Select2Filter = Select2Filter;
})(window);
