const DEFAULT_MESSAGES = {
  correctErrors: "There are errors on the form, please correct them."
};
let MESSAGES = DEFAULT_MESSAGES;

export default class FormValidator {
  static configureMessages(messages) {
    MESSAGES = $.extend(DEFAULT_MESSAGES, messages);
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
    $announce.attr("class", "sr-announce sr-only");
    $announce.attr("aria-live", "assertive");
    this.$form.prepend($announce);

    setTimeout(() => {
      $announce.text(MESSAGES.correctErrors);
    }, 100);
  }
}

$(() => {
  $("form").each((_i, el) => {
    $(el).data("form-validator", new FormValidator($(el)));
  });
  $(document).on("forminvalid.zf.abide", function(_ev, form) {
    form.trigger("form-error.decidim");
  })
});
