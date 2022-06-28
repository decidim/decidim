import PasswordToggler from "src/decidim/registrations/password_toggler";

$(() => {
  window.Decidim = window.Decidim || {};
  window.Decidim.passwordToggler = new PasswordToggler($(".user-password"), $(".user-password-confirmation"));
  window.Decidim.passwordToggler.init();
});
