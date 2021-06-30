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
        const isMultiPicker = $picker.hasClass("picker-multiple");

        if ($(this._targetFromEvent(event)).hasClass("picker-prompt") || !isMultiPicker) {
          this._openPicker($picker, this._targetFromEvent(event));
        }  else if (this._targetFromEvent(event).tagName === "A") {
          this._removeValue($picker, this._targetFromEvent(event).parentNode);
        } else {
          this._removeValue($picker, this._targetFromEvent(event));
        }
      });

      $picker.on("click", "input", (event) => {
        this._removeValue($picker, this._targetFromEvent(event));
      });

      if (this.current.autosort) {
        this._sort();
      }
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
        this._choose(data, { interactive: false, modify: false });
      });
      if (this.current.autosort) {
        this._sort();
      }
    }

    _createModalContainer() {
      // Add a header because we are referencing the title element with
      // `aria-labelledby`. If the title doesn't exist, the "labelled by"
      // reference is incorrect.
      const headerHtml = '<div class="scope-picker picker-header"><h6 id="data_picker-title" class="h2"></h6></div>';

      return $(`<div class="small reveal" id="data_picker-modal" aria-hidden="true" aria-live="assertive" role="dialog" aria-labelledby="data_picker-title" data-reveal data-multiple-opened="true">
                <div class="data_picker-modal-content">${headerHtml}</div>
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
        autosort: $picker.hasClass("picker-multiple") && $picker.hasClass("picker-autosort"),
        target: $target
      };
    }

    _load(url) {
      $.ajax(url).done((resp) => {
        let modalContent = $(".data_picker-modal-content", this.modal);
        modalContent.html(resp);
        this._handleLinks(modalContent);
        this._handleCheckboxes(modalContent);
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
              this._choose(
                { url: chooseUrl, value: $link.data("picker-value") || "", text: $link.data("picker-text") || "" }
              );
            }
          }
        });
      });
    }

    _handleCheckboxes(content) {
      $("input[type=checkbox][data-picker-choose]", content).each((_index, checkbox) => {
        const $checkbox = $(checkbox);
        checkbox.checked = this._targetFromValue($checkbox.val()) !== null;
      }).change((event) => {
        const $checkbox = $(event.target);
        if (event.target.checked) {
          this._choose(
            { url: $checkbox.data("picker-url"), value: $checkbox.val() || "", text: $checkbox.data("picker-text") || "" },
            { modify: false, close: false }
          );
        }
        else {
          this._removeValue(this.current.picker, this._targetFromValue($checkbox.val()));
        }
      });
    }

    _choose(data, opts = {}) {
      const options = Object.assign({ interactive: true, modify: true, close: true }, opts);

      let dataText = this._escape(data.text);
      let choosenOption = null;

      if (!this.current.target && options.modify) {
        this.current.target = this._targetFromValue(data.value);
      }

      // Add or update value appearance
      if (this.current.target && options.modify) {
        let link = $("a", this.current.target);
        link.data("picker-value", data.value);
        link.attr("href", data.url);
        choosenOption = this.current.target;
        if (this.current.multiple) {
          link.html(`&times;&nbsp;${dataText}`);
        } else {
          link.text(dataText);
        }
      } else {
        let input = "hidden",
            name = this.current.name;

        if (this.current.multiple) {
          name += "[]";
          choosenOption = $(`<div><input type="${input}" checked name="${name}"/><a href="${data.url}" data-picker-value="${data.value}" class="label primary">&times;&nbsp;${dataText}</a></div>`);
        } else {
          choosenOption = $(`<div><input type="${input}" checked name="${name}"/><a href="${data.url}" data-picker-value="${data.value}">${dataText}</a></div>`);
        }
        choosenOption.appendTo(this.current.values);

        if (!this.current.target) {
          this.current.target = choosenOption;
        }
      }

      // Set input value
      let $input = $("input", choosenOption);
      $input.attr("value", data.value);

      if (this.current.autosort) {
        this._sort();
      }

      if (options.interactive) {
        // Raise changed event
        $input.trigger("change");
        this._removeErrors();

        if (options.close) {
          this._close();
        }
      }
    }

    _sort() {
      const values = $(".picker-values", this.current.picker);
      values.children().sort((item1, item2) => $("input", item1).val() - $("input", item2).val()).detach().appendTo(values);
    }

    _close() {
      // Close modal and unset target element
      this.modal.foundation("close");
      this.current.target = null;
    }

    _removeValue($picker, target) {
      if (target) {
        this._setCurrentPicker($picker, target);
        // Fadeout (with time) doesn't work in system tests
        let fadeoutTime = 500;
        if (navigator && navigator.webdriver) {
          fadeoutTime = 0;
        }
        this.current.target.fadeOut(fadeoutTime, () => {
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

    _targetFromValue(value) {
      return $(`[data-picker-value=${value}]`, this.current.picker).parent()[0] || null;
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.DataPicker = DataPicker;
})(window);
