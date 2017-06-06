((exports) => {
  class AutoLabelByPositionComponent {
    constructor(options = {}) {
      this.listSelector = options.listSelector;
      this.labelSelector = options.labelSelector;
      this.onPositionComputed = options.onPositionComputed;

      this.run();
    }

    run() {
      const $list = $(this.listSelector);

      $list.each((idx, el) => {
        const $label = $(el).find(this.labelSelector);
        const labelContent = $label.html();

        if (labelContent.match(/#(\d+)/)) {
          $label.html(labelContent.replace(/#(\d+)/, `#${idx + 1}`));
        } else {
          $label.html(`${labelContent} #${idx + 1}`);
        }

        if (this.onPositionComputed) {
          this.onPositionComputed(el, idx);
        }
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.AutoLabelByPositionComponent = AutoLabelByPositionComponent;
})(window);
