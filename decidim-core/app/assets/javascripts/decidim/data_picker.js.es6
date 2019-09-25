/**
 * DataPicker component.
 */
((exports) => {
  class DataPicker {
    constructor(elements) {
      this.modal = this._createModalContainer();
      this.modal.appendTo($("body"));
      this.current = null;

      elements.each((_index, element) => {
        this.activate(element);
      });
    }

    activate(picker) {
      let $element = $(picker);
      let input = "hidden",
          name = $element.data("picker-name"),
          values = $(".picker-values", $element);

      if ($element.hasClass("picker-multiple")) {
        input = "checkbox";
        name += "[]";
      }

      $("div", values).each((_index2, div) => {
        let value = $("a", div).data("picker-value");
        $(div).prepend($(`<input type="${input}" checked name="${name}" value="${value}"/>`));
      });

      $element.on("click", "a", (event) => {
        event.preventDefault();
        if ($element.hasClass("disabled")) {
          return;
        }
        this._openPicker($element, event.target.parentNode);
      });

      $element.on("click", "input", (event) => {
        this._removeValue($element, event.target.parentNode);
      });
    }

    enabled(picker, value) {
      $(picker).toggleClass("disabled", !value);
      $("input", picker).attr("disabled", !value);
    }

    clear(picker) {
      $(".picker-values", picker).html("");
    }

    save(picker) {
      return $(".picker-values div:has(input:checked)", picker).map((_index, div) => {
        let $link = $("a", div);
        return {
          value: $("input", div).val(),
          text: $link.text(),
          url: $link.attr("href")
        };
      }).get();
    }

    load(picker, savedData) {
      this._setCurrentPicker($(picker), null);
      $.each(savedData, (_index, data) => {
        this._choose(data, false);
      });
    }

    _createModalContainer() {
      return $(`<div class="small reveal" id="data_picker-modal" aria-hidden="true" role="dialog" aria-labelledby="data_picker-title" data-reveal data-multiple-opened="true">
                <div class="data_picker-modal-content"></div>
                <button class="close-button" data-close type="button" data-reveal-id="data_picker-modal"><span aria-hidden="true">&times;</span></button>
              </div>`);
    }

    _openPicker($picker, div) {
      this._setCurrentPicker($picker, div);
      this._load($("a", div).attr("href"));
    }

    _setCurrentPicker($picker, div) {
      let currentDiv = false;
      if (div && !$(div).hasClass("picker-prompt")) {
        currentDiv = $(div);
      }

      this.current = {
        multiple: $picker.hasClass("picker-multiple"),
        picker: $picker,
        name: $picker.data("picker-name"),
        values: $picker.find(".picker-values"),
        div: currentDiv
      };
    }

    _load(url) {
      $.ajax(url).done((resp) => {
        let modalContent = $(".data_picker-modal-content", this.modal);
        modalContent.html(resp);
        this._handleLinks(modalContent);
        this.modal.foundation("open");
      });
    }

    _handleLinks(content) {
      $("a", content).each((_index, link) => {
        let $link = $(link);
        $link.click((event) => {
          event.preventDefault();
          if ($link.data("data-close")) {
            return;
          }

          let chooseUrl = $link.attr("href");
          if (chooseUrl) {
            if (typeof $link.data("picker-choose") === "undefined") {
              this._load(chooseUrl);
            } else {
              this._choose({ url: chooseUrl, value: $link.data("picker-value") || "", text: $link.data("picker-text") || "" });
            }
          }
        });
      });
    }

    _choose(data, user = true) {
      // Prevent choosing is nothing has been selected. This would otherwise
      // cause an empty checkbox to appear in the selected values list.
      if (!data.value || data.value.length < 1) {
        return;
      }

      let dataText = this._escape(data.text);

      // Add or update value appearance
      if (this.current.div) {
        let link = $("a", this.current.div);
        link.data("picker-value", data.value);
        link.attr("href", data.url);
        link.text(dataText);
      } else {
        let input = "hidden",
            name = this.current.name;

        if (this.current.multiple) {
          input = "checkbox";
          name += "[]";
        }
        this.current.div = $(`<div><input type="${input}" checked name="${name}"/><a href="${data.url}" data-picker-value="${data.value}">${dataText}</a></div>`);
        this.current.div.appendTo(this.current.values);
      }

      // Set input value
      let $input = $("input", this.current.div);
      $input.attr("value", data.value);

      // Raise changed event
      if (user) {
        $input.trigger("change");
        this._removeErrors();
        this.modal.foundation("close");
      }

      // Unselect updated value and close modal
      this.current.div = null;
    }

    _removeValue($picker, div) {
      this._setCurrentPicker($picker, div);
      this.current.div.fadeOut(500, () => {
        this.current.div.remove();
        this.current.div = null;
      });
    }

    _removeErrors() {
      let parent = this.current.picker.parent();
      $(".is-invalid-input", parent).removeClass("is-invalid-input");
      $(".is-invalid-label", parent).removeClass("is-invalid-label");
      $(".form-error.is-visible", parent).removeClass("is-visible");
    }

    _escape(str) {
      return str.replace(/[\u00A0-\u9999<>&]/gim, function (char) {
        return `&#${char.charCodeAt(0)};`;
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.DataPicker = DataPicker;
})(window);
