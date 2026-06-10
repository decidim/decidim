import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    this.newPasswordPanel = this.element.querySelector("#panel-password");
    this.oldPasswordPanel = this.element.querySelector("#panel-old-password");
    this.emailField = this.element.querySelector("input[type='email']");

    this.originalEmail = this.emailField.dataset.original;
    this.emailChanged = this.originalEmail !== this.emailField.value;
    this.newPwVisible = false;
    this.observer = null;

    this.setupMutationObserver();
    this.setupEmailChangeListener();
  }

  toggleNewPassword() {
    const input = this.newPasswordPanel.querySelector("input");
    if (this.newPwVisible) {
      input.required = true;
    } else {
      input.required = false;
      input.value = "";
    }
  }

  toggleOldPassword() {
    if (!this.oldPasswordPanel) {
      return;
    }

    const input = this.oldPasswordPanel.querySelector("input");
    if (this.emailChanged || this.newPwVisible) {
      this.oldPasswordPanel.classList.remove("hidden");
      input.required = true;
    } else {
      this.oldPasswordPanel.classList.add("hidden");
      input.required = false;
    }
  }

  setupMutationObserver() {
    if (!this.newPasswordPanel) {
      return;
    }

    this.observer = new MutationObserver(() => {
      let ariaHiddenValue = this.newPasswordPanel.getAttribute("aria-hidden");
      this.newPwVisible = ariaHiddenValue === "false";

      this.toggleNewPassword();
      this.toggleOldPassword();
    });

    this.observer.observe(this.newPasswordPanel, { attributes: true });
  }

  setupEmailChangeListener() {
    if (!this.emailField) {
      return;
    }

    this.emailField.addEventListener("change", () => {
      this.emailChanged = this.emailField.value !== this.originalEmail;
      this.toggleOldPassword();
    });
  }

  destroy() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
  }
}
