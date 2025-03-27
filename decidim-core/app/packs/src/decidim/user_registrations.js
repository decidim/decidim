import PasswordToggler from "src/decidim/password_toggler";

$(() => {
  const $userRegistrationForm = $("#register-form");
  const $userOmniauthRegistrationForm = $("#omniauth-register-form");
  const userPassword         =  document.querySelector(".user-password");
  const newsletterSelector    = 'input[type="checkbox"][name="user[newsletter]"]';
  const $newsletterModal      = $("#sign-up-newsletter-modal");

  const checkNewsletter = (check) => {
    $userRegistrationForm.find(newsletterSelector).prop("checked", check);
    $userOmniauthRegistrationForm.find(newsletterSelector).prop("checked", check);
    $newsletterModal.data("continue", true);
    window.Decidim.currentDialogs["sign-up-newsletter-modal"].close()
    $userRegistrationForm.submit();
    $userOmniauthRegistrationForm.submit();
  }

  $userRegistrationForm.on("submit", (event) => {
    const newsletterChecked = $userRegistrationForm.find(newsletterSelector);
    if (!$newsletterModal.data("continue")) {
      if (!newsletterChecked.prop("checked")) {
        event.preventDefault();
        window.Decidim.currentDialogs["sign-up-newsletter-modal"].open()
      }
    }
  });

  $userOmniauthRegistrationForm.on("submit", (event) => {
    const newsletterChecked = $userOmniauthRegistrationForm.find(newsletterSelector);
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
