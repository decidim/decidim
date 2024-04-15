// Copy the value of a text input or textarea to another element.
//
// @example
// ```erb
// <%= form.translated :text_field, :example, data: { "text-copy" => true, "target" => "strong[data-copy-example]" } %>
//
// <div data-copy-example>
//   <%= t(".preview") %>
// </div>
// ```
//
window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("input[data-text-copy=true], textarea[data-text-copy=true]").forEach((element) => {
    element.addEventListener("change", (event) => {
      const target = document.querySelector(event.target.dataset.target);
      target.innerText = event.target.value;
    })
  });
})
