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

  const unHideElement = (el) => {
    if ($(el).hasClass("hidden")) {
      $(el).removeClass("hidden")
    }
  }

  const hideElement = (el) => {
    if ($(el).hasClass("hidden")) {
      return;
    }
    $(el).addClass("hidden")
  }

  const toggleHiddenElement = (el) => {
    if ($(el).hasClass("hidden")) {
      unHideElement($(el))
    } else {
      hideElement($(el))
    }
  }


  $(passwordChange).on("click", "span", () => {
    [$("#panel-old-password"), $("#panel-password")].forEach((field) => toggleHiddenElement(field));
    passwordFields.forEach((field) => {
      togglePasswordFieldValidators(field);
    })
  });

  emailField.addEventListener("input", () => {
    const oldPassword = $("#panel-old-password")
    if ($(emailField).data("origin") !== emailField.value) {
      console.log("TRIGGERED")
      unHideElement(oldPassword)
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
