import PasswordToggler from "src/decidim/registrations/password_toggler";

$(() => {
  const pass = new PasswordToggler($(".user-password"), $(".user-password-confirmation"));
  pass.init();
});
