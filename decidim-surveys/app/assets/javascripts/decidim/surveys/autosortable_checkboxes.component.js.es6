/* eslint-disable max-depth */
((exports) => {
  class AutosortableCheckboxesComponent {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this._bindEvent();
      this._run();
    }

    _run() {
      const sortedResults = [];
      const unsortedResults = [];

      $(this.wrapperField).children("label").each((idx, label) => {
        const current = $(label).clone(true);
        const isChecked = $(current).children("input[type=checkbox]").is(":checked");
        const position = parseInt($(current).children("input[name$=\\[position\\]]").val(), 10);

        if (isChecked) {
          if (Number.isInteger(position)) {
            let wasInserted = false;
            for (let index = 0; index < sortedResults.length; index += 1) {
              let sorted = sortedResults[index];
              const sortedPosition = parseInt($(sorted).children("input[name$=\\[position\\]]").val(), 10);
              if (Number.isInteger(sortedPosition) && (position < sortedPosition)) {
                sortedResults.splice(index, 0, current);
                wasInserted = true;
                break;
              }
            }
            if (!wasInserted) {
              sortedResults.push(current);
            }
          } else {
            sortedResults.push(current);
          }
          $(current).addClass("sorted");
          $(current).removeClass("unsorted");
        } else {
          unsortedResults.push(current);
          $(current).addClass("unsorted");
          $(current).removeClass("sorted");
        }

      });

      $(this.wrapperField).empty();
      $(this.wrapperField).append(sortedResults.concat(unsortedResults));

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
