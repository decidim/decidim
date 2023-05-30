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

  const passwordChange = editUserForm.querySelector("#panel-password");
  if (!passwordChange) {
    return;
  }

  const passwordFields = passwordChange.querySelectorAll("input[type='password']");
  if (passwordFields.length < 1) {
    return;
  }

  // Foundation uses jQuery so these have to be bound using jQuery and the
  // attribute value needs to be set through jQuery.
  const togglePasswordFieldValidators = (enabled) => {
    $(passwordFields).attr("required", enabled);

    if (!enabled) {
      passwordFields.forEach((field) => (field.value = ""));
    }
  }

  $(passwordChange).on("on.zf.toggler", () => {
    togglePasswordFieldValidators(true);
  });
  $(passwordChange).on("off.zf.toggler", () => {
    togglePasswordFieldValidators(false);
  });
  togglePasswordFieldValidators(false);
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

$(() => {
  initializeAccountForm();
  initializeDeleteAccount();
});
