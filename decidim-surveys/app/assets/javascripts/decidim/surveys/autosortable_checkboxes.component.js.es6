((exports) => {
  class AutosortableCheckboxesComponent {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this._bindEvent();
      this._run();
    }

    _run() {

      $(this.wrapperField).children("label").each((idx, label) => {

        const isChecked = $(label).children("input[type=checkbox]").is(":checked");
        const position = parseInt($(label).children("input[name$=\\[position\\]]").val(), 10);

        if (isChecked) {
          if (Number.isInteger(position)) {
            this.wrapperField.children("label.sorted").each((jdx, sorted) => {
              const sortedPosition = parseInt($(sorted).children("input[name$=\\[position\\]]").val(), 10);
              if (Number.isInteger(sortedPosition) && (position < sortedPosition)) {
                $(sorted).insertAfter($(label));
              } else {
                $(sorted).insertBefore($(label));
              }
            });
          } else {
            $(label).insertAfter(this.wrapperField.children("label.sorted").last());
          }
          $(label).addClass("sorted");
        } else {
          $(label).insertAfter(this.wrapperField.children("label").last());
          $(label).removeClass("sorted");
        }

      });

      $(this.wrapperField).children("label").each((idx, el) => {
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
