((exports) => {
  class AutoButtonsByMinItemsComponent {
    constructor(options = {}) {
      this.listSelector = options.listSelector;
      this.minItems = options.minItems;
      this.hideOnMinItemsOrLessSelector = options.hideOnMinItemsOrLessSelector;

      this.run();
    }

    run() {
      const $list = $(this.listSelector);
      const $items = $list.find(this.hideOnMinItemsOrLessSelector);

      if ($list.length <= this.minItems) {
        $items.hide();
      } else {
        $items.show();
      }
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.AutoButtonsByMinItemsComponent = AutoButtonsByMinItemsComponent;
})(window);
