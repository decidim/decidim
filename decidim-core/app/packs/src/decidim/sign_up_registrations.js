import InstantValidator from "src/decidim/registrations/instant_validator";

$(() => {
  const TIMEOUT_INTERVAL = 150; // ms before xhr check

  const $form = $("form.instant-validation");
  let checkTimeout;
  $form.find('input[type="text"]').on("keyup", (e) => {
    let $input = $(e.currentTarget);
    // Trigger live validation with a delay to avoid throttling
    try { clearTimeout(checkTimeout); } catch {}
    checkTimeout = setTimeout(() => {
      const validator = new InstantValidator($input);
      validator.validate($input);
    }, TIMEOUT_INTERVAL);
  });
});