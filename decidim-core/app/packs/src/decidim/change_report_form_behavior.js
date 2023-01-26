/**
 * These set of functions aims to change the behavior of the report modal forms
 * so that when checking various checkboxes, to change the label of the button
 * to either report or hide.
 */

/**
 * @param {Object} container The form handling the report.
 * @return {Void} Nothing
 */
export default function changeReportFormBehavior(container) {
  container.querySelectorAll("[data-hide=true]").forEach((checkbox) => {
    checkbox.addEventListener("change", (event) => {
      let input = event.target;
      let submit = input.closest("form").querySelector("button[type=submit]");

      if (submit.querySelector("span") !== null) {
        submit = submit.querySelector("span");
      }

      if (input.checked === true) {
        submit.innerHTML = input.dataset.labelHide;
      } else {
        submit.innerHTML = input.dataset.labelReport;
      }
    });
  });
}
