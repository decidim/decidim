$(() => {

  /**
   * Since the delete account has a modal to confirm it we need to copy the content of the
   * reason field to the hidden field in the form inside the modal.
   */
  const $deleteAccountForm = $(".delete-account");
  const $deleteAccountModalForm = $(".delete-account-modal");

  if ($deleteAccountForm.length > 0) {
    const $openModalButton = $(".open-modal-button");
    const $modal = $("#deleteConfirm");

    $openModalButton.on("click", (event) => {
      try {
        const reasonValue = $deleteAccountForm.find("textarea#delete_account_delete_reason").val();
        $deleteAccountModalForm.find("input#delete_account_delete_reason").val(reasonValue);
        $modal.foundation("open");
      } catch (error) {
        console.error(error); // eslint-disable-line no-console
      }

      event.preventDefault();
      event.stopPropagation();
      return false;
    });
  }


  /**
   * Resend the confirmation email logig here, we use fetch here because link is inside the form.
  */
  const resendInstructions = document.querySelector("form.edit_user")?.querySelector("#resend-email-confirmation-instructions");

  if (resendInstructions) {
    const link = resendInstructions.querySelector("a");
    const alert = document.querySelector(".email-confirmation-alert");
    link.addEventListener("click", (event) => {
      event.preventDefault();

      fetch(link.href, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      }).then((response) => response.json()).then((data) => {
        alert.classList.remove("hide");
        if (data?.message === "success") {
          alert.innerHTML = resendInstructions.dataset.success;
          alert.classList.add("success");
        } else {
          alert.innerHTML = resendInstructions.dataset.error;
          alert.classList.add("alert");
        }
      });
    })
  }

  /**
   * Cancel the email change logic, this uses fetch because link is inside the form.
  */
  const cancelEmailChange = document.querySelector("form.edit_user")?.querySelector("#cancel-email-change");

  if (cancelEmailChange) {
    const link = cancelEmailChange.querySelector("a");
    const alert = document.querySelector(".email-confirmation-alert");
    link.addEventListener("click", (event) => {
      event.preventDefault();

      fetch(link.href, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      }).then((response) => response.json()).then((data) => {
        alert.classList.remove("hide");
        if (data?.message === "success") {
          document.querySelector("#user_email").disabled = false;
          document.querySelector("#email-change-pending").remove();
          alert.innerHTML = cancelEmailChange.dataset.success;
          alert.classList.add("success");
        } else {
          alert.innerHTML = cancelEmailChange.dataset.error;
          alert.classList.add("alert");
        }
      });
    })
  }
});
