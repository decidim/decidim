import attachGeocoding from "src/decidim/geocoding/attach_input"

$(() => {
  const $form = $(".edit_polling_station, .new_polling_station");

  if ($form.length > 0) {
    attachGeocoding($form.find("#polling_station_address"));
  }
})
