$(() => {
  const $userRegistrationForm = $("#register-form");
  const $userGroupFields      = $userRegistrationForm.find(".user-group-fields");
  const inputSelector         = 'input[name="user[sign_up_as]"]';
  const newsletterSelector    = 'input[type="checkbox"][name="user[newsletter]"]';
  const $newsletterModal      = $("#sign-up-newsletter-modal");
  const $formStepButton       = $(".form-step-button");

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

  $(document).on("forminvalid.zf.abide", (event) => {
    if (event.target.id === $userRegistrationForm.attr("id")) {
      $("[form-step='2']").hide();
      $("[form-step-field]").show();
    }
  });

  $newsletterModal.find(".check-newsletter").on("click", (event) => {
    checkNewsletter($(event.target).data("check"));
  });

  $formStepButton.on("click", (event) => {
    event.preventDefault();

    $("[form-step]").toggle();
  });
});
