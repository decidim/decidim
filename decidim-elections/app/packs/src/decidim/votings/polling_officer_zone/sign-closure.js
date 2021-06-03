$(() => {
  const $submitBtn = $("#btn-submit-from-modal");
  const $modalBtn = $("#btn-modal-closure-sign");
  const $signCheckbox = $("#closure_sign_signed");

  const changeButtonProps = (event) => {
    const notSigned = !$(event.target).is(":checked");
    $modalBtn.prop("disabled", notSigned);
    $submitBtn.prop("disabled", notSigned);
  };

  $signCheckbox.on("change", changeButtonProps);
});
