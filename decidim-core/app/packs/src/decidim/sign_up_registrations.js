// Instant, server-side validation
// compatible with abide classes https://get.foundation/sites/docs/abide.html
class InstantValidator {
  static slugify(string, separator = "-") {
    return string
        .toString()
        .normalize('NFD')                  // split an accented letter in the base letter and the acent
        .replace(/[\u0300-\u036f]/g, '')   // remove all previously split accents
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9 ]/g, '')   // remove all chars not letters, numbers and spaces (to be replaced)
        .replace(/\s+/g, separator);
  }

  constructor($form) {
    this.$form = $form;
    this.url = this.$form.data("validationUrl");
  }

  validate($input) {
    console.log("validate", $input, this);
    this.tamper($input)
    if($input.data("suggest-nickname")) {
      this.suggestNickname($input.val(), this.$form.find($input.data("suggest-nickname")))
    }
  }

  suggestNickname(text, $dest) {
    $.ajax(this.url, {
      method: "post",
      data: {
       "input": "name",
        "value": InstantValidator.slugify(text, ""), 
        "suggest": "nickname"
      },
      dataType: "json"
    }).done((response) => {
      this.setFeedback($dest, response);
    });
  }

  setFeedback($input, data) {
    // TODO: only apply if field not tampered by the user, otherwise suggest in the help text
    if(!this.isTampered($input)) {
      this.$form.foundation('removeErrorClasses', $input);
      $input.val(data.suggestion);
    }
  }

  tamper($input) {
    $input.data("tampered", $input.val().trim() != "");
  }

  isTampered($input) {
    return $input.val().trim() != "" && $input.data("tampered")
  }
}

$(() => {
  const TIMEOUT_INTERVAL = 200; // ms before xhr check

  const $form = $("form.instant-validation");
  let checkTimeout;
  $form.find('input[type="text"]').on("keyup", (e) => {
    let $input = $(e.currentTarget);
    // Trigger live validation with a delay to avoid throttling
    try { clearTimeout(checkTimeout); } catch {}
    checkTimeout = setTimeout(() => {
      const validator = new InstantValidator($form);
      validator.validate($input);
    }, TIMEOUT_INTERVAL);
  });
});