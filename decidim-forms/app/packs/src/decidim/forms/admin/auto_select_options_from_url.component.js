export default class AutoSelectOptionsFromUrl {
  constructor(options = {}) {
    this.$source = options.source;
    this.$select = options.select;
    this.sourceToParams = options.sourceToParams;
    this.run();
  }

  run() {
    this.$source.on("change", this._onSourceChange.bind(this));
    this._onSourceChange();
  }

  _onSourceChange() {
    const select = this.$select;
    const params = this.sourceToParams(this.$source);
    const url = this.$source.data("url");

    $.getJSON(url, params).done(function (data) {
      select.find("option:not([value=''])").remove();
      const selectedValue = select.data("selected");
      $.each(data, function(i, option) {
        let optionElement = $(`<option value="${option.id}">${option.body}</option>`).appendTo(select);
        if (option.id === selectedValue) {
          optionElement.attr("selected", true);
        }
      });

      if (selectedValue) {
        select.val(selectedValue);
      }
    }).fail(function( jqxhr, textStatus, error ) {
      var err = textStatus + ", " + error;
      console.error( "Request Failed: " + err );
    });
  }
}
