$(() => {
  const $userRegistrationForm  = $("#register-form");
  const $userGroupFields       = $userRegistrationForm.find(".user-group-fields");
  const inputSelector          = "input[name='user[sign_up_as]']";
  const newsletterSelector     = "input[type='checkbox'][name='user[newsletter]']";
  const $newsletterModal       = $("#sign-up-newsletter-modal");
  const $formStepForwardButton = $(".form-step-forward-button");
  const $formStepBackButton    = $(".form-step-back-button");

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
    $newsletterModal.foundation("close");
    $userRegistrationForm.submit();
  }

  const toggleFromSteps = () => {
    $("[form-step]").toggle();
    $("[form-active-step]").toggleClass("step--active");
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
        $newsletterModal.foundation("open");
      }
    }
  });

  $newsletterModal.find(".check-newsletter").on("click", (event) => {
    checkNewsletter($(event.target).data("check"));
  });

  $formStepForwardButton.on("click", (event) => {
    event.preventDefault();

    // validate only input elements from step 1
    $("[form-step='1'] input").each((index, element) => {
      $userRegistrationForm.foundation("validateInput", $(element));
    });

    if (!$userRegistrationForm.find("[data-invalid]:visible").length) {
      toggleFromSteps();
    }
  });

  $formStepBackButton.on("click", (event) => {
    event.preventDefault();

    toggleFromSteps();
  });
});
