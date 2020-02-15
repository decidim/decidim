((exports) => {
  class AutoSelectOptionsFromUrl {
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

      $.getJSON(url, params, function (data) {
        select.find("option:not([value=''])").remove();

        data.forEach((option) => {
          $(`<option value="${option.id}">${option.body}</option>`).appendTo(select);
        });
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.AutoSelectOptionsFromUrl = AutoSelectOptionsFromUrl;
})(window);