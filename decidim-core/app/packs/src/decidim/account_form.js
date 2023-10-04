import PasswordToggler from "./password_toggler";

/**
 * Initializes the edit account form to control the password field elements
 * which should only be required when they are visible.
 *
 * @returns {void}
 */
const initializeAccountForm = () => {
  const editUserForm = document.querySelector("form.edit_user");
  if (!editUserForm) {
    return;
  }

  const emailField = document.querySelector("#email-input")
  if (emailField.length < 1) {
    return;
  }

  const passwordChange = editUserForm.querySelector("#accordion-trigger-password");
  if (!passwordChange) {
    return;
  }

  const passwordFields = passwordChange.querySelectorAll("input[type='password']");
  if (passwordFields.length < 1) {
    return;
  }

  const newPassword = $("#panel-password"),
      oldPassword = $("#panel-old-password")

  // Foundation uses jQuery so these have to be bound using jQuery and the
  // attribute value needs to be set through jQuery.
  const togglePasswordFieldValidators = (field) => {
    if ($(field).attr("required")) {
      $(field).removeAttr("required");
    } else {
      $(field).attr("required", true)
      $(field).attr("value", "")
    }
  }

  const toggleElements = () => {
    if ($(emailField).data("origin") === emailField.value) {
      return [newPassword, oldPassword]
    }
    return [newPassword]
  }

  $(passwordChange).on("click", "span", () => {
    const elementsToToggle = toggleElements();
    elementsToToggle.forEach((field) => {
      field.toggleClass("hidden", () => {
        togglePasswordFieldValidators(field)
      })
    })
  })

  emailField.addEventListener("input", () => {
    if ($(emailField).data("origin") !== emailField.value) {
      if (oldPassword.is(":hidden")) {
        oldPassword.toggleClass("hidden")
        togglePasswordFieldValidators(oldPassword)
      }
    }
  })
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
