import attachGeocoding from "src/decidim/geocoding/attach_input"

$(() => {
  const $form = $(".result_form_admin");

  if ($form.length > 0) {
    const $resultAddress = $form.find("#result_address");

    if ($resultAddress.length !== 0) {
      attachGeocoding($resultAddress);
    }
  }
});
