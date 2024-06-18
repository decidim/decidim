// Preview CSS changes in real time through data attributes when the change event is dispatched.
//
// @example
// ```erb
// <%= form.radio_button :text_color, "Blue"
//                       data: {
//                         "css-preview" => true,
//                         "css-preview-updates" => "[data-css-example]:color:blue;"
//                       } %>
//
// <%= form.radio_button :text_color, "Red"
//                       data: {
//                         "css-preview" => true,
//                         "css-preview-updates" => "[data-css-example]:color:red;"
//                       } %>
//
// <div data-css-example>This is an example</div>
// ```
//
// It supports multiple rules separated by semicolons:
//   selector:property:value; selector:property:value;
//
// for example:
//   strong[data-css-example]:color:#0000ff; strong[data-css-example]:backgroundColor:#eeeeee;
//
window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("input[data-css-preview=true]").forEach((element) => {
    element.addEventListener("change", (event) => {
      const updateRules = event.target.dataset.cssPreviewUpdates.split(";");

      updateRules.forEach((rule) => {
        const [target, property, value] = rule.split(":");
        if (target !== "") {
          document.querySelector(target).style[property.trim()] = value.trim();
        }
      });
    })
  })
})
