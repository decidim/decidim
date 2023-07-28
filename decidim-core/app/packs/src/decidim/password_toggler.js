import icon from "src/decidim/redesigned_icon"

export default class PasswordToggler {
  constructor(password) {
    this.password = password;
    this.input = this.password.querySelector('input[type="password"]');
    this.form = this.input.closest("form");
    this.texts = {
      showPassword: this.password.getAttribute("data-show-password") || "Show password",
      hidePassword: this.password.getAttribute("data-hide-password") || "Hide password",
      hiddenPassword: this.password.getAttribute("data-hidden-password") || "Your password is hidden",
      shownPassword: this.password.getAttribute("data-shown-password") || "Your password is shown"
    }
    this.icons = {
      show: icon("eye-fill", {title: this.texts.showPassword}),
      hide: icon("eye-off-fill", {title: this.texts.hidePassword})
    }
  }

  // Call init() to hide the password confirmation and add a "view password" inline button
  init() {
    this.createControls();
    this.button.addEventListener("click", (evt) => {
      this.toggleVisibiliy(evt);
    });
    // to prevent browsers trying to use autocomplete, turn the type back to password before submitting
    this.form.addEventListener("submit", () => {
      this.hidePassword();
    });
  }

  // Call destroy() to switch back to the original password box
  destroy() {
    this.button.removeEventListener("click");
    this.input.removeEventListener("change");
    this.form.removeEventListener("submit");
    const input = this.input.detach();
    this.inputGroup.replaceWith(input);
  }

  createControls() {
    let button = document.createElement("button");
    button.classList.add("mt-3")
    button.setAttribute("aria-controls", this.input.getAttribute("id"));
    button.setAttribute("aria-label", this.texts.showPassword);
    button.textContent = this.icons.show;

    let statusText = document.createElement("span");
    statusText.classList.add("sr-only");
    statusText.setAttribute("aria-live", "polite");
    statusText.textContent = this.texts.hiddenPassword;

    this.button = button;
    this.statusText = statusText;

    let inputGroupWrapper = document.createElement("div");
    inputGroupWrapper.classList.add("filter-search", "filter-container");
    const inputParent = this.input.parentNode;
    inputParent.replaceChild(inputGroupWrapper, this.input);
    inputGroupWrapper.appendChild(this.input);

    this.input.after(this.button);
    this.input.after(this.statusText);
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
    this.statusText.textContent = this.texts.shownPassword;
    this.button.setAttribute("aria-label", this.texts.hidePassword);
    this.button.textContent = this.icons.hide;
    this.input.setAttribute("type", "text");
  }

  hidePassword() {
    this.statusText.textContent = this.texts.hiddenPassword;
    this.button.setAttribute("aria-label", this.texts.showPassword);
    this.button.textContent = this.icons.show;
    this.input.setAttribute("type", "password");
  }

  isText() {
    return this.input.getAttribute("type") === "text"
  }
}
