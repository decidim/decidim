import icon from "src/decidim/redesigned_icon"

export default class PasswordToggler {
  constructor($password, $confirmation) {
    this.$password = $password.first();
    this.$confirmation = $confirmation.first();
    this.$input = this.$password.find('input[type="password"]');
    this.$inputConfirmation = this.$confirmation.find('input[type="password"]');
    this.$form = this.$input.closest("form");
    this.texts = {
      showPassword: this.$password.data("showPassword") || "Show password",
      hidePassword: this.$password.data("hidePassword") || "Hide password",
      hiddenPassword: this.$password.data("hiddenPassword") || "Your password is hidden",
      shownPassword: this.$password.data("shownPassword") || "Your password is shown"
    }
    this.icons = {
      show: icon("eye-fill", {title: this.texts.showPassword})
    }
  }

  // Call init() to hide the password confirmation and add a "view password" inline button
  init() {
    this.createControls();
    this.$confirmation.hide();
    this.$button.on("click.password_toggler", (evt) => this.toggleVisibiliy(evt));
    this.$input.on("change.password_toggler", () => {
      this.$inputConfirmation.val(this.$input.val());
    });
    // to prevent browsers trying to use autocomplete, turn the type back to password before submitting
    this.$form.on("submit.password_toggler", () => {
      this.$inputConfirmation.val(this.$input.val());
      this.hidePassword();
    });
  }

  // Call destroy() to switch back to the original password/password confirmation boxes
  destroy() {
    this.$button.off("click.password_toggler");
    this.$input.off("change.password_toggler");
    this.$form.off("submit.password_toggler");
    const $input = this.$input.detach();
    this.$inputGroup.replaceWith($input);
    this.$confirmation.show();
  }

  createControls() {
    this.$button = $(`<button type="button"
                            class="mt-3"
                            aria-controls="${this.$input.attr("id")}"
                            aria-label="${this.texts.showPassword}">${this.icons.show}</button>`);
    this.$statusText = $(`<span class="sr-only" aria-live="polite">${this.texts.hiddenPassword}</span>`);
    // ensure error message is handled by foundation abide
    this.$input.next(".form-error").attr("data-form-error-for", this.$input.attr("id"));
    this.$input.wrap('<div class="filter-search filter-container"/>').
      after(this.$statusText).
      after(this.$button);
    this.$inputGroup = this.$input.parent();
  }

  toggleVisibiliy(evt) {
    evt.preventDefault();
    if (this.isText()) {
      this.hidePassword();
    } else {
      this.showPassword();
    }
  }

  showPassword() {
    this.$statusText.text(this.texts.shownPassword);
    this.$button.attr("aria-label", this.texts.hidePassword).addClass("crossed");
    this.$input.attr("type", "text");
  }

  hidePassword() {
    this.$statusText.text(this.texts.hiddenPassword);
    this.$button.attr("aria-label", this.texts.showPassword).removeClass("crossed")
    this.$input.attr("type", "password");
  }

  isText() {
    return this.$input.attr("type") === "text"
  }
}
