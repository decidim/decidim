document.addEventListener("DOMContentLoaded", function() {
  const emailInput = document.getElementById("session_user_email");
  const form = document.getElementById("session_new_user");

  if (emailInput && form) {
    const emailError = emailInput.closest("label").querySelector(".form-error");

    form.removeAttribute("data-live-validate");

    emailInput.addEventListener("input", function () {
      emailError.classList.remove("is-visible");
    });
  }
});
