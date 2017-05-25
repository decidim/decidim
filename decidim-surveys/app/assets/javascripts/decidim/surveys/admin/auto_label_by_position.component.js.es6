((exports) => {
  class AutoLabelByPositionComponent {
    constructor(listSelector, labelSelector) {
      this.listSelector = listSelector;
      this.labelSelector = labelSelector;
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

        // $(el).find('input[name="survey[questions][][position]"]').val(idx);        
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.AutoLabelByPositionComponent = AutoLabelByPositionComponent;
})(window);
