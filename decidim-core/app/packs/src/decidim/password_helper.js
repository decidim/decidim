import PasswordToggler from "src/decidim/registrations/password_toggler";

$(() => {
  const pass = new PasswordToggler($('.user-password input[type="password"]:first'));
  pass.init();
  $(".user-password-confirmation").hide();
});
