((exports) => {
  class AutosortableCheckboxesComponent {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this._bindEvent();
      this._run();
    }

    _run() {
      $(this.wrapperField).find("input[type=checkbox]").each((idx, el) => {
        const $parentLabel = $(el).parents("label");

        if ($(el).is(":checked")) {
          const $lastSorted = this.wrapperField.find("label.sorted").last();

          if ($lastSorted.length > 0) {
            $lastSorted.removeClass("last-sorted");
            $parentLabel.insertAfter($lastSorted);
          } else {
            $parentLabel.insertBefore(this.wrapperField.find("label:first-child"));
          }

          $parentLabel.addClass("sorted");
          $parentLabel.addClass("last-sorted");
        } else {
          const $lastUnsorted = this.wrapperField.find("label:not(.sorted)").last();

          if ($lastUnsorted.length > 0) {
            $parentLabel.insertBefore($lastUnsorted);
          } else {
            $parentLabel.insertAfter(this.wrapperField.find("label:last-child"));
          }

          $parentLabel.removeClass("sorted");
        }
      });

      $(this.wrapperField).find("label").each((idx, el) => {
        const $positionSelector = $(el).find(".position");
        const $positionField = $(el).find("input[name$=\\[position\\]]");

        if ($(el).hasClass("sorted")) {
          $positionField.val(idx);
          $positionField.prop("disabled", false);
          $positionSelector.html(`${idx + 1}. `);
        } else {
          $positionField.val("");
          $positionField.prop("disabled", true);
          $positionSelector.html("");
        }
      });
    }

    _bindEvent() {
      $(this.wrapperField).find("input[type=checkbox]").on("change", () => {
        this._run();
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.createAutosortableCheckboxes = (options) => {
    return new AutosortableCheckboxesComponent(options);
  };
})(window);
