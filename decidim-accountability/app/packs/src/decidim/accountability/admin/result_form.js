import attachGeocoding from "src/decidim/geocoding/attach_input"

$(() => {
  const $form = $(".result_form_admin");

  if ($form.length > 0) {
    const $resultAddress = $form.find("#result_address");

    if ($resultAddress.length !== 0) {
      attachGeocoding($resultAddress);
    }
  }

  $("#result_decidim_accountability_status_id").change(function () {
    /* eslint-disable no-invalid-this */
    const progress = $(this).find(":selected").data("progress")
    if (progress || progress === 0) {
      $("#result_progress").val(progress);
    }
  });
});
