/**
 * DataPicker component.
 */
((exports) => {
  class DataPicker {
    constructor(pickers) {
      this.modal = this._createModalContainer();
      this.modal.appendTo($("body"));
      this.current = null;

      pickers.each((_index, picker) => {
        this.activate(picker);
      });
    }

    activate(picker) {
      let $picker = $(picker);

      this._setCurrentPicker($picker, null);

      let input = "hidden",
          name = this.current.name,
          values = this.current.values;

      if (this.current.multiple) {
        input = "checkbox";
        name += "[]";
      }

      $("div", values).each((_index2, div) => {
        let value = $("a", div).data("picker-value");
        $(div).prepend($(`<input type="${input}" checked name="${name}" value="${value}"/>`));
      });

      $picker.on("click", "a", (event) => {
        event.preventDefault();
        if ($picker.hasClass("disabled")) {
          return;
        }
        this._openPicker($picker, this._targetFromEvent(event));
      });

      $picker.on("click", "input", (event) => {
        this._removeValue($picker, this._targetFromEvent(event));
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

    _openPicker($picker, target) {
      this._setCurrentPicker($picker, target);
      this._load($("a", target).attr("href"));
    }

    _setCurrentPicker($picker, target) {
      let $target = false;
      if (target && !$(target).hasClass("picker-prompt")) {
        $target = $(target);
      }

      this.current = {
        picker: $picker,
        name: $picker.data("picker-name"),
        values: $picker.find(".picker-values"),
        multiple: $picker.hasClass("picker-multiple"),
        target: $target
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


    _choose(data, user = true, modify = true, close = true) {
      // Prevent choosing is nothing has been selected. This would otherwise
      // cause an empty checkbox to appear in the selected values list.
      if (!data.value || data.value.length < 1) {
        return;
      }

      let dataText = this._escape(data.text);
      let choosenOption = null;

      // Add or update value appearance
      if (this.current.target && modify) {
        let link = $("a", this.current.target);
        link.data("picker-value", data.value);
        link.attr("href", data.url);
        choosenOption = this.current.target;
        link.html(dataText);
      } else {
        let input = "hidden",
            name = this.current.name;

        if (this.current.multiple) {
          input = "checkbox";
          name += "[]";
        }

        choosenOption = $(`<div><input type="${input}" checked name="${name}"/><a href="${data.url}" data-picker-value="${data.value}">${dataText}</a></div>`);
        choosenOption.appendTo(this.current.values);

        if (!this.current.target) {
          this.current.target = choosenOption;
        }
      }

      // Set input value
      let $input = $("input", choosenOption);
      $input.attr("value", data.value);

      if (user) {
        // Raise changed event
        $input.trigger("change");
        this._removeErrors();

        if (close) {
          this._close();
        }
      }
    }



    _close() {
      // Close modal and unset target element
      this.modal.foundation("close");
      this.current.target = null;
    }

    _removeValue($picker, target) {
      if (target) {
        this._setCurrentPicker($picker, target);
        this.current.target.fadeOut(500, () => {
          this.current.target.remove();
          this.current.target = null;
        });
      }
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

    _targetFromEvent(event) {
      return event.target.parentNode;
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.DataPicker = DataPicker;
})(window);
