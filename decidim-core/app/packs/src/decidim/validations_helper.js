import InstantValidator from "src/decidim/registrations/instant_validator";

$(() => {
  window.Decidim = window.Decidim || {};
  window.Decidim.instantValidator = new InstantValidator($("form.instant-validation"));
  window.Decidim.instantValidator.init();
});
