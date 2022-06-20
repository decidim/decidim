// Instant, server-side validation
// compatible with abide classes https://get.foundation/sites/docs/abide.html
export default class InstantValidator {
  static slugify(string, separator = "-") {
    // From the glorious Stackoverflow!
    return string
        .toString()
        .normalize('NFD')                // split an accented letter in the base letter and the accent
        .replace(/[\u0300-\u036f]/g, '') // remove all previously split accents
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9_\- ]/g, '')   // remove all chars not letters, numbers and spaces (to be replaced)
        .replace(/\s+/g, separator);
  }

  constructor($input) {
    this.$input = $input;
    this.$form = $input.closest("form.instant-validation");
    this.url = this.$form.data("validationUrl");
  }

  value() {
    if(this.action() == "suggest") {
      return InstantValidator.slugify(this.$input.val(), "");
    }
    return this.$input.val().trim();
  }

  attribute() {
    return this.$input.data("instantAttribute");
  }

  action() {
    return this.$input.data("instantAction") || "check";
  }

  target() {
    return this.$form.find(this.$input.data("instantTarget")) || this.$input;
  }

  validate() {
    console.log("validate", this);
    this.tamper(this.$input);
    this.clearErrors(this.$input);
    this.post().done((response) => {
      if(this.action() == "suggest") {
        this.setValue(response);
      } else {
        this.setFeedback(response);
      }
    });
  }

  setValue(data) {
    console.log("value for",this, data);
    // TODO: only apply if field not tampered by the user, otherwise suggest in the help text
    if(!this.isTampered(this.target())) {
      this.clearErrors(this.target());
      this.target().val(data.suggestion);
    }
  }

  setFeedback(data) {
    console.log("feedback for", this, data);
    if(!data.valid) {
      this.addErrors(this.target(), this.action() == "uniqueness" ? data.errorWithSuggestion : data.error);
    }
  }

  tamper($dest) {
    $dest.data("tampered", $dest.val().trim() != "");
  }

  isTampered($dest) {
    return $dest.data("tampered");
  }

  addErrors($dest, msg) {
    this.$form.foundation("addErrorClasses", $dest);
    if(msg) this.target().next(".form-error").text(msg);
  }

  clearErrors($dest) {
    this.$form.foundation('removeErrorClasses', $dest);
  }

  post() {
    return $.ajax(this.url, {
      method: "post",
      data: {
        "attribute": this.attribute(),
        "value": this.value(),
      },
      dataType: "json"
    });
  }
}
