import InstantValidator from "src/decidim/registrations/instant_validator";

$(() => {
  // ms before xhr check
  const TIMEOUT_INTERVAL = 150;

  const $form = $("form.instant-validation");
  let checkTimeout = null;
  $form.find('input[type="text"]').on("keyup", (evt) => {
    let $input = $(evt.currentTarget);
    // Trigger live validation with a delay to avoid throttling
    if (checkTimeout) {
      clearTimeout(checkTimeout);
    }
    checkTimeout = setTimeout(() => {
      const validator = new InstantValidator($input);
      validator.validate($input);
    }, TIMEOUT_INTERVAL);
  });
});
