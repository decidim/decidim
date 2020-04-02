((exports) => {
  class LiveTextUpdateComponent {
    constructor(options = {}) {
      this.inputSelector = options.inputSelector;
      this.targetSelector = options.targetSelector;
      this.maxLength = options.maxLength;
      this.omission = options.omission;
      this.placeholder = options.placeholder;
      this._bindEvent();
      this._run();
    }

    _run() {
      const $input = $(this.inputSelector);
      const $target = $(this.targetSelector);

      let text = $input.val() || this.placeholder;

      // truncate string
      if (text.length > this.maxLength) {
        text = text.substring(0, this.maxLength - this.omission.length) + this.omission;
      }

      $target.text(text);
    }

    _bindEvent() {
      const $input = $(this.inputSelector);
      $input.on("change", this._run.bind(this));
    }

  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.LiveTextUpdateComponent = LiveTextUpdateComponent;
  exports.DecidimAdmin.createLiveTextUpdateComponent = (options) => {
    return new LiveTextUpdateComponent(options);
  }
})(window);
