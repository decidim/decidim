/**
 * DataPicker component.
 */
((exports) => {
  'use strict';

  function DataPicker() {
    this._init();
  };

  DataPicker.prototype._init = function() {
    if (!this.modal) {
      this.modal = this._createModalContainer();
      this.modal.appendTo($("body"));
      new Foundation.Reveal(this.modal);
    }

    var self = this;
    $('.data-picker').each(function(index) {
      var $this = $(this);
      var value = $this.data('picker-value'),
          text  = $this.text(),
          name  = $this.data('picker-name');
      var id    = name.replace(/[^a-zA-Z0-9]/g, "_");

      $this.html('<input class="picker-value" type="hidden" name="'+name+'" value="'+value+'"/>\
                      <span class="picker-text">'+text+'</span>');
      $this.click(function(e){
        e.preventDefault();
        if ($this.attr('disabled')=='disabled') return;
        self.openPicker($this);
      });
    });
  };

  DataPicker.prototype._createModalContainer = function() {
    return $('<div class="small reveal" id="data_picker-modal" aria-labelledby="data_picker-modal" data-reveal>\
                <div class="data_picker-modal-content"></div>\
                <button class="close-button" data-close type="button"><span aria-hidden="true">&times;</span></button>\
              </div>');
  };

  DataPicker.prototype.openPicker = function(picker) {
    this.current = {
                      picker: picker,
                      value: $(".picker-value", picker),
                      text: $(".picker-text", picker)
                    };

    this.load(picker.data('picker-url'));
  };

  DataPicker.prototype.load = function(url) {
    var self = this;
    $.ajax(url).done(function(resp){
        var modalContent = $(".data_picker-modal-content", self.modal);
        modalContent.html(resp);
        self._handleLinks(modalContent);
        self.modal.foundation('open');
    });
  };

  DataPicker.prototype._handleLinks = function(content) {
    var self = this;
    $("a", content).each(function(index){
      var $link = $(this);
      $link.click(function(e){
        e.preventDefault();
        if ($link.data('data-close')) return;
        var choose_value = $link.data('picker-value'),
            choose_text = $link.data('picker-text'),
            choose_link = $link.attr('href');

        if (choose_link) {
          if ($link.data('picker-choose') !== undefined)
            self.choose(choose_link, choose_value, choose_text);
          else
            self.load(choose_link);
        }
      });
    });
  };

  DataPicker.prototype.choose = function(link, value, text) {
    this.current.picker.data('picker-url', link);
    this.current.value.attr('value', value);
    this.current.text.html(text);
    this.modal.foundation('close');
  };

  DataPicker.enabled = function(data_picker, value) {
    data_picker.toggleClass("disabled", !value);
    $("input", data_picker).attr("disabled", !value);
  };

  DataPicker.prototype.current = null;

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.DataPicker = DataPicker;
})( window );
