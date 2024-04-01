// Check one radio button when another is checked
//
// @example
// ```erb
// <%= form.radio_button :text_color, "Blue",
//                       data: {
//                         "sync-radio-buttons" => true,
//                         "sync-radio-buttons-value" => "unique-key"
//                       } %>
//
// <%= form.radio_button :bg_color, "Blue,"
//                       data: {
//                         "sync-radio-buttons-value-target" => "unique-key"
//                       } %>
// ```
//
window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("input[data-sync-radio-buttons=true]").forEach((element) => {
    element.addEventListener("change", (event) => {
      const value = event.target.dataset.syncRadioButtonsValue;
      const radio = document.querySelector(`input[data-sync-radio-buttons-value-target=${value}]`);

      radio.checked = true;
      radio.dispatchEvent(new Event("change"));
    })
  })
})
