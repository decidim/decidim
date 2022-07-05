/* eslint-disable line-comment-position, no-ternary, no-inline-comments */

// Instant, server-side validation
// compatible with abide classes https://get.foundation/sites/docs/abide.html
export default class InstantValidator {
  // ms before xhr check
  static get TIMEOUT() {
    return 150;
  }

  constructor($form) {
    this.$form = $form;
    this.$inputs = $form.find("[data-instant-attribute]");
    this.url = this.$form.data("validationUrl");
  }

  init() {
    this.$inputs.on("keyup", (evt) => {
      let $input = $(evt.currentTarget);
      let checkTimeout = $input.data("checkTimeout");
      // Trigger live validation with a delay to avoid throttling
      if (checkTimeout) {
        clearTimeout(checkTimeout);
      }
      $input.data("checkTimeout", setTimeout(() => {
        this.validate($input);
      }, this.TIMEOUT)
      );
    });
  }

  value($input) {
    return $input.val().trim();
  }

  attribute($input) {
    return $input.data("instantAttribute");
  }

  target($input) {
    const $target = this.$form.find($input.data("instantTarget"));
    return $target.length
      ? $target
      : $input;
  }

  validate($input) {
    this.tamper($input);
    this.clearErrors($input);
    this.post($input).done((response) => {
      this.setFeedback(response, $input);
    });
  }

  setFeedback(data, $input) {
    if (!data.valid) {
      this.addErrors(this.target($input), data.error);
    }
  }

  tamper($dest) {
    $dest.data("tampered", $dest.val().trim() !== "");
  }

  isTampered($dest) {
    return $dest.data("tampered");
  }

  addErrors($dest, msg) {
    this.$form.foundation("addErrorClasses", $dest);
    if (msg) {
      $dest.next(".form-error").text(msg);
    }
  }

  clearErrors($dest) {
    this.$form.foundation("removeErrorClasses", $dest);
  }

  post($input) {
    return $.ajax(this.url, {
      method: "post",
      data: {
        "attribute": this.attribute($input),
        "value": this.value($input)
      },
      dataType: "json"
    });
  }
}
