/**
 * Select2 filter component.
 */

((exports) => {
  class Select2Field {
    constructor(element) {
      const selectedLang = $("html").attr('lang') || 'en';

      let $element = $(element);

      let options = {
        language: selectedLang,
        multiple: $element.attr("multiple")==="multiple",
        width: "100%",
        allowClear: true
      };
      if ($element.data("remote-path")) {
        options.ajax = {
          url: $element.data("remote-path"),
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
  exports.Decidim.Select2Field = Select2Field;
})(window);
