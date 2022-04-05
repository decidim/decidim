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
  const sendAgainOrCancel = document.querySelector("form.edit_user")?.querySelector("#email-change-send-again-or-cancel");

  if (sendAgainOrCancel) {
    const emailAlert = document.querySelector(".email-confirmation-alert");
    let emailAlertMessage = document.createElement("div");
    emailAlertMessage.classList.add("email-alert-message")
    emailAlert.appendChild(emailAlertMessage);
    const resend = sendAgainOrCancel.querySelector("a.email-resend");
    const cancel = sendAgainOrCancel.querySelector("a.email-cancel-change");

    const sendRequest = (href) => {
      return fetch(href, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      })
    }

    const showCallout = () => {
      emailAlert.classList.remove("hide");
      // emailAlert.setAttribute("style", "display: block;");
    }

    resend.addEventListener("click", (event) => {
      event.preventDefault();
      sendRequest(resend.href).then((response) => response.json()).then((data) => {
        showCallout(emailAlert);
        emailAlertMessage = emailAlert.querySelector(".email-alert-message");
        if (data?.message === "success") {
          emailAlertMessage.innerHTML = sendAgainOrCancel.dataset.resentSuccess;
          emailAlert.classList.add("success");
        } else {
          emailAlertMessage.innerHTML = sendAgainOrCancel.dataset.resentError;
          emailAlert.classList.add("alert");
        }
      })
    })

    cancel.addEventListener("click", (event) => {
      event.preventDefault();
      sendRequest(cancel.href).then((response) => response.json()).then((data) => {
        showCallout(emailAlert);
        emailAlertMessage = emailAlert.querySelector(".email-alert-message");
        if (data?.message === "success") {
          document.querySelector("#user_email").disabled = false;
          document.querySelector("#email-change-pending").remove();
          emailAlertMessage.innerHTML = sendAgainOrCancel.dataset.cancelSuccess;
          emailAlert.classList.add("success");
        } else {
          emailAlertMessage.innerHTML = sendAgainOrCancel.dataset.cancelError;
          emailAlert.classList.add("alert");
        }
      })
    })
  }
});
