import icon from "src/decidim/icon"

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
      show: icon("eye-line"),
      hide: icon("eye-off-line")
    }
  }

  // Call init() to hide the password confirmation and add a "view password" inline button
  init() {
    this.createControls();
    this.button.addEventListener("click", (evt) => {
      this.toggleVisibility(evt);
    });
    if (this.form) {
      // to prevent browsers trying to use autocomplete, turn the type back to password before submitting
      this.form.addEventListener("submit", () => {
        this.hidePassword();
      });
    }
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
    this.createButton();
    this.createStatusText();
    this.addInputGroupWrapperAsParent();
  }

  createButton() {
    const button = document.createElement("button");
    button.setAttribute("type", "button");
    button.setAttribute("aria-controls", this.input.getAttribute("id"));
    button.setAttribute("aria-label", this.texts.showPassword);
    button.innerHTML = this.icons.show;
    this.button = button;
  }

  createStatusText() {
    const statusText = document.createElement("span");
    statusText.classList.add("sr-only");
    statusText.setAttribute("aria-live", "polite");
    statusText.textContent = this.texts.hiddenPassword;
    this.statusText = statusText;
  }

  addInputGroupWrapperAsParent() {
    const inputGroupWrapper = document.createElement("div");
    inputGroupWrapper.classList.add("input-group__password");

    this.input.parentNode.replaceChild(inputGroupWrapper, this.input);
    inputGroupWrapper.appendChild(this.input);
    this.input.before(this.button);

    const formError = this.password.querySelector(".form-error");
    if (formError) {
      this.input.after(formError);
    }
  }

  toggleVisibility(evt) {
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
    this.button.innerHTML = this.icons.hide;
    this.input.setAttribute("type", "text");
  }

  hidePassword() {
    this.statusText.textContent = this.texts.hiddenPassword;
    this.button.setAttribute("aria-label", this.texts.showPassword);
    this.button.innerHTML = this.icons.show;
    this.input.setAttribute("type", "password");
  }

  isText() {
    return this.input.getAttribute("type") === "text"
  }
}
