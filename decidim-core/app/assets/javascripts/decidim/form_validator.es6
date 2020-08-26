((exports) => {
  const DEFAULT_MESSAGES = {
    correctErrors: "There are errors on the form, please correct them."
  };
  let MESSAGES = DEFAULT_MESSAGES;

  class FormValidator {
    static configureMessages(messages) {
      MESSAGES = exports.$.extend(DEFAULT_MESSAGES, messages);
    }

    constructor(form) {
      this.$form = form;

      this.$form.on("form-error.decidim", () => {
        this.handleError();
      });
    }

    handleError() {
      this.announceFormError();

      $(".is-invalid-input:first", this.$form).focus();
    }

    /**
     * This announces immediately to the screen reader that there are errors on
     * the form that need to be fixed. Does not work on all screen readers but
     * works e.g. in Windows+Firefox+NVDA and macOS+Safari+VoiceOver
     * combinations.
     *
     * @returns {undefined}
     */
    announceFormError() {
      let $announce = $(".sr-announce", this.$form);
      if ($announce.length > 0) {
        $announce.remove();
      }
      $announce = $("<div />");
      $announce.attr("class", "sr-announce show-for-sr");
      $announce.attr("aria-live", "assertive");
      this.$form.prepend($announce);

      exports.setTimeout(() => {
        $announce.text(MESSAGES.correctErrors);
      }, 100);
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.FormValidator = FormValidator;

  exports.$(() => {
    exports.$("form").each((_i, el) => {
      exports.$(el).data("form-validator", new FormValidator(exports.$(el)));
    });
    exports.$(document).on("forminvalid.zf.abide", function(_ev, form) {
      form.trigger("form-error.decidim");
    })
  });
})(window);
