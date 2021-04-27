$(() => {
  const $submitBtn = $("#btn-submit-from-modal");
  const $modalBtn = $("#btn-modal-closure-sign");
  const $signCheckbox = $("#closure_sign_signed");

  const changeButtonProps = () => {
    $modalBtn.toggleClass("disabled");
    $submitBtn.toggleClass("disabled");

    if ($signCheckbox.is(":checked")) {
      $submitBtn.prop("disabled", false);
      $modalBtn.prop("disabled", false);
    } else {
      $submitBtn.prop("disabled", true);
      $modalBtn.prop("disabled", true);
    }
  };

  $modalBtn.addClass("disabled");
  $submitBtn.addClass("disabled");

  $signCheckbox.on("change", changeButtonProps);
});
