((exports) => {
  class AutoButtonsByPositionComponent {
    constructor(options = {}) {
      this.listSelector = options.listSelector;
      this.hideOnFirstSelector = options.hideOnFirstSelector;
      this.hideOnLastSelector = options.hideOnLastSelector;

      this.run();
    }

    run() {
      const $list = $(this.listSelector);
      const hideOnFirst = this.hideOnFirstSelector;
      const hideOnLast = this.hideOnLastSelector;

      if ($list.length === 1) {
        const $item = $list.first();

        $item.find(hideOnFirst).hide();
        $item.find(hideOnLast).hide();
      } else {
        $list.each((idx, el) => {
          if (el.id === $list.first().attr("id")) {
            $(el).find(hideOnFirst).hide();
            $(el).find(hideOnLast).show();
          }
          else if (el.id === $list.last().attr("id")) {
            $(el).find(hideOnLast).hide();
            $(el).find(hideOnFirst).show();
          }
          else {
            $(el).find(hideOnLast).show();
            $(el).find(hideOnFirst).show();
          }
        });
      }
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.AutoButtonsByPositionComponent = AutoButtonsByPositionComponent;
})(window);
