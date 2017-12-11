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
        let $element = $(element);
        let input    = "hidden",
            multiple = typeof $element.data('picker-multiple') !== 'undefined',
            name     = $element.data('picker-name'),
            values   = $(".picker-values", $element);

        if (multiple) {
          $element.addClass("picker-multiple");
          input = "checkbox";
          name += "[]";
        } else {
          $element.addClass("picker-single");
        }

        $("div", values).each((_index2, div) => {
          let value = $("a", div).data("picker-value");
          $(div).prepend($(`<input type="${input}" checked name="${name}" value="${value}"/>`));
        });

        $element.on("click", "a", (event) => {
          event.preventDefault();
          if ($element.hasClass('disabled')) {
            return;
          }
          this._openPicker($element, event.target.parentNode);
        });

        $element.on("click", "input", (event) => {
          this._removeValue($element, event.target.parentNode);
        });
      });
    }

    enabled(picker, value) {
      picker.toggleClass("disabled", !value);
      $(".picker-hidden", picker).attr("disabled", !value);
    }

    _createModalContainer() {
      return $(`<div class="small reveal" id="data_picker-modal" aria-hidden="true" role="dialog" aria-labelledby="data_picker-title" data-reveal>
                <div class="data_picker-modal-content"></div>
                <button class="close-button" data-close type="button"><span aria-hidden="true">&times;</span></button>
              </div>`);
    }

    _openPicker(picker, div) {
      this._setCurrentPicker(picker, div);
      this._load($("a", div).attr('href'));
    }

    _setCurrentPicker(picker, div) {
      let currentDiv = false;
      if (div && !$(div).hasClass("picker-prompt")) {
        currentDiv = $(div);
      }

      this.current = {
                        multiple: picker.hasClass("picker-multiple"),
                        picker: picker,
                        name: picker.data('picker-name'),
                        values: $(".picker-values", picker),
                        div: currentDiv
                      };
    }

    _load(url) {
      $.ajax(url).done((resp) => {
        let modalContent = $(".data_picker-modal-content", this.modal);
        modalContent.html(resp);
        this._handleLinks(modalContent);
        this.modal.foundation('open');
      });
    }

    _handleLinks(content) {
      $("a", content).each((_index, link) => {
        let $link = $(link);
        $link.click((event) => {
          event.preventDefault();
          if ($link.data('data-close')) {
            return;
          }

          let chooseUrl = $link.attr('href');
          if (chooseUrl) {
            if (typeof $link.data('picker-choose') === 'undefined') {
              this._load(chooseUrl);
            } else {
              this._choose(chooseUrl, $link.data('picker-value') || "", $link.data('picker-text') || "");
            }
          }
        });
      });
    }

    _choose(url, value, text) {
      if (this.current.div) {
        let link = $("a", this.current.div)
        link.attr("href", url);
        link.text(text);
      } else {
        let input = "hidden",
            name  = this.current.name;

        if (this.current.multiple) {
          input = "checkbox";
          name += "[]";
        }
        this.current.div = $(`<div><input type="${input}" checked name="${name}"/><a href="${url}">${text}</a></div>`);
        this.current.div.appendTo(this.current.values);
      }
      $("input", this.current.div).val(value).trigger("change");
      this.modal.foundation('close');
    }

    _removeValue(picker, div) {
      this._setCurrentPicker(picker, div);
      this.current.div.fadeOut(500, () => {
        this.current.div.remove();
        this.current.div = null;
      });
    }
  }

  $(() => {
    exports.Decidim = exports.Decidim || {};
    exports.Decidim.DataPicker = new DataPicker($(".data-picker"));
  });
})(window);
