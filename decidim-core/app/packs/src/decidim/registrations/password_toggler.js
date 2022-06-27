import icon from "src/decidim/icon"

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
      show: icon("eye", {title: this.texts.showPassword}),
      hide: icon("ban", {title: this.texts.hidePassword})
    }
  }
  
  init() {
    this.createControls();
    this.$confirmation.hide();
    this.$button.on("click", (evt) => this.toggleVisibiliy(evt));
    // to prevent browsers trying to use autocomplete, turn the type back to password before submitting
    this.$form.on("submit", () => {
      this.$inputConfirmation.val(this.$input.val());
      this.hidePassword();
    });
  }

  createControls() {
    this.$button = $(`<button type="button" 
                            aria-controls="${this.$input.attr("id")}" 
                            aria-label="${this.texts.showPassword}">${this.icons.show}</button>`);
    this.$buttonGroup = $('<div class="input-group"/>');
    this.$statusText = $(`<span class="show-for-sr" aria-live="polite">${this.texts.hiddenPassword}</span>`);
    this.$inputGroup = $('<div class="input-inline-group"/>');
    this.$buttonGroup.html(this.$button);
    this.$input.wrap(this.$inputGroup).
      after(this.$statusText).
      after(this.$buttonGroup);
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
    this.$button.attr("aria-label", this.texts.hidePassword).html(this.icons.hide);
    this.$input.attr("type", "text");
  }
  
  hidePassword() {
    this.$statusText.text(this.texts.hiddenPassword);
    this.$button.attr("aria-label", this.texts.showPassword).html(this.icons.show)
    this.$input.attr("type", "password");
  }

  isText() {
    return this.$input.attr("type") === "text"
  }
}
