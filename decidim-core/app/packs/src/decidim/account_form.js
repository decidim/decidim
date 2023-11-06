import PasswordToggler from "./password_toggler";

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

/**
 * Since the delete account has a modal to confirm it we need to copy the content of the
 * reason field to the hidden field in the form inside the modal.
 *
 * @return {void}
 */
const initializeDeleteAccount = () => {
  const $deleteAccountForm = $(".delete-account");
  const $deleteAccountModalForm = $(".delete-account-modal");

  if ($deleteAccountForm.length < 1) {
    return;
  }

  const $openModalButton = $(".open-modal-button");

  $openModalButton.on("click", (event) => {
    try {
      const reasonValue = $deleteAccountForm.find("textarea#delete_account_delete_reason").val();
      $deleteAccountModalForm.find("input#delete_account_delete_reason").val(reasonValue);
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
    return false;
  });
};

const initializeOldPasswordToggler = () => {
  const oldUserPassword = document.querySelector(".old-user-password");

  if (oldUserPassword) {
    new PasswordToggler(oldUserPassword).init();
  }
}

$(() => {
  initializeAccountForm();
  initializeDeleteAccount();
  initializeOldPasswordToggler();
});
