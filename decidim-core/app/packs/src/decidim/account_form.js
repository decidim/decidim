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
  const togglePasswordFieldValidators = ({ thisField = null, hidden = true } = {}) => {
    let fields = [];
    if (thisField === null) {
      fields = [newPassword, oldPassword]
    } else {
      fields = [thisField]
    }

    const hasError = (field) => {
      return $(field).find("[data-error]").length > 0
    }
    fields.forEach((field) => {
      const inputElement = $(field).find(("input[type='password']"))
      if (inputElement.attr("required")) {
        inputElement.removeAttr("required");
      } else {
        inputElement.attr("required", true)
        inputElement.attr("value", "")
      }
      if (hidden || hasError(field)) {
        $(field).toggleClass("hidden")
      }
    })

  }
  const emailChanged = () => {
    if ($(emailField).data("origin") !== emailField.value) {
      return true
    }
    return false
  }

  const isHidden = (item) => {
    return $(item).hasClass("hidden")
  }

  $(passwordChange).on("click", "span", () => {
    if (emailChanged()) {
      togglePasswordFieldValidators({thisField: newPassword})
    } else {
      togglePasswordFieldValidators()
    }
  })

  emailField.addEventListener("input", () => {
    if (emailChanged() && isHidden(oldPassword)) {
      togglePasswordFieldValidators({thisField: oldPassword})
    } else if (!emailChanged() && !isHidden(oldPassword) && isHidden(newPassword)) {
      togglePasswordFieldValidators({thisField: oldPassword})
    }
  })

  togglePasswordFieldValidators({hidden: false})
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
