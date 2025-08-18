const initializeAccountForm = () => {
  const newPasswordPanel = document.getElementById("panel-password");
  const oldPasswordPanel = document.getElementById("panel-old-password");
  const emailField = document.querySelector("input[type='email']");
  if (!newPasswordPanel || !emailField) {
    return;
  }

  const originalEmail = emailField.dataset.original;
  let emailChanged = originalEmail !== emailField.value;
  let newPwVisible = false;

  const toggleNewPassword = () => {
    const input = newPasswordPanel.querySelector("input")
    if (newPwVisible) {
      input.required = true;
    } else {
      input.required = false;
      input.value = "";
    }
  };
  const toggleOldPassword = () => {
    if (!oldPasswordPanel) {
      return;
    }

    const input = oldPasswordPanel.querySelector("input");
    if (emailChanged || newPwVisible) {
      oldPasswordPanel.classList.remove("hidden");
      input.required = true;
    } else {
      oldPasswordPanel.classList.add("hidden");
      input.required = false;
    }
  }

  const observer = new MutationObserver(() => {
    let ariaHiddenValue = newPasswordPanel.getAttribute("aria-hidden");
    newPwVisible = ariaHiddenValue === "false";

    toggleNewPassword();
    toggleOldPassword();
  });
  observer.observe(newPasswordPanel, { attributes: true });

  emailField.addEventListener("change", () => {
    emailChanged = emailField.value !== originalEmail;
    toggleOldPassword();
  });
};

document.addEventListener("turbo:load", () => {
  initializeAccountForm();
});
