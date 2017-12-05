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
        let name  = $element.data('picker-name'),
            text  = $element.text(),
            value = $element.data('picker-value') || "";

        $element.html(`<input class="picker-value" type="hidden" name="${name}" value="${value}"/>
                        <span class="picker-text">${text}</span>`);
        $element.click((event) => {
          event.preventDefault();
          if ($element.hasClass('disabled')) {
            return;
          }
          this._openPicker($element);
        });
      });
    }

    enabled(picker, value) {
      picker.toggleClass("disabled", !value);
      $(".picker-value", picker).attr("disabled", !value);
    }

    _createModalContainer() {
      return $(`<div class="small reveal" id="data_picker-modal" aria-hidden="true" role="dialog" aria-labelledby="data_picker-title" data-reveal>
                <div class="data_picker-modal-content"></div>
                <button class="close-button" data-close type="button"><span aria-hidden="true">&times;</span></button>
              </div>`);
    }

    _openPicker(picker) {
      this.current = {
                        picker: picker,
                        value: $(".picker-value", picker),
                        text: $(".picker-text", picker)
                      };

      this._load(picker.data('picker-url'));
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

          let chooseLink = $link.attr('href');
          if (chooseLink) {
            if (typeof $link.data('picker-choose') === 'undefined') {
              this._load(chooseLink);
            } else {
              this._choose(chooseLink, $link.data('picker-value') || "", $link.data('picker-text') || "");
            }
          }
        });
      });
    }

    _choose(link, value, text) {
      this.current.picker.data('picker-url', link);
      this.current.value.attr('value', value);
      this.current.text.html(text);
      this.modal.foundation('close');
    }
  }

  $(() => {
    exports.Decidim = exports.Decidim || {};
    exports.Decidim.DataPicker = new DataPicker($(".data-picker"));
  });
})(window);
