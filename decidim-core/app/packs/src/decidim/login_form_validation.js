document.addEventListener("DOMContentLoaded", function() {
  console.log("DOMContentLoaded event fired");

  const emailInput = document.getElementById("session_user_email");
  const passwordInput = document.getElementById("session_user_password");
  const form = document.getElementById("session_new_user");
  const emailError = emailInput.closest("label").querySelector(".form-error");

  form.removeAttribute("data-live-validate");

  emailInput.removeEventListener("input", Foundation.Abide.validateInput);
  emailInput.removeEventListener("blur", Foundation.Abide.validateInput);

  emailInput.addEventListener("input", function () {
    emailError.classList.remove("is-visible");
  });

  emailInput.addEventListener("blur", function() {
    if (emailInput.value.trim() === "") {
      emailError.classList.add("is-visible");
    } else {
      emailError.classList.remove("is-visible");
    }
  });

  passwordInput.addEventListener("focus", function() {
    emailInput.dispatchEvent(new Event("blur"));
  });
});
