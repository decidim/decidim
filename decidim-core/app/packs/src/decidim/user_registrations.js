import PasswordToggler from "./password_toggler";

$(() => {
  const $userRegistrationForm = $("#register-form");
  const $userGroupFields      = $userRegistrationForm.find(".user-group-fields");
  const userPassword         =  document.querySelector(".user-password");
  const inputSelector         = 'input[name="user[sign_up_as]"]';
  const newsletterSelector    = 'input[type="checkbox"][name="user[newsletter]"]';
  const $newsletterModal      = $("#sign-up-newsletter-modal");


  const setGroupFieldsVisibility = (value) => {
    if (value === "user") {
      $userGroupFields.hide();
    } else {
      $userGroupFields.show();
    }
  }

  const checkNewsletter = (check) => {
    $userRegistrationForm.find(newsletterSelector).prop("checked", check);
    $newsletterModal.data("continue", true);
    window.Decidim.currentDialogs["sign-up-newsletter-modal"].close()
    $userRegistrationForm.submit();
  }

  setGroupFieldsVisibility($userRegistrationForm.find(`${inputSelector}:checked`).val());

  $userRegistrationForm.on("change", inputSelector, (event) => {
    const value = event.target.value;

    setGroupFieldsVisibility(value);
  });

  $userRegistrationForm.on("submit", (event) => {
    const newsletterChecked = $userRegistrationForm.find(newsletterSelector);
    if (!$newsletterModal.data("continue")) {
      if (!newsletterChecked.prop("checked")) {
        event.preventDefault();
        window.Decidim.currentDialogs["sign-up-newsletter-modal"].open()
      }
    }
  });

  $newsletterModal.find("[data-check]").on("click", (event) => {
    checkNewsletter($(event.target).data("check"));
  });

  if (userPassword) {
    new PasswordToggler(userPassword).init();
  }
});
