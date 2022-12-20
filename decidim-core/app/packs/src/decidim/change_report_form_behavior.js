/**
 * These set of functions aims to change the behavior of the report modal forms
 * so that when checking various checkboxes, to change the label of the button
 * to either report or hide.
 */

/**
 * @param {DomElement} input The checkbox that is being checked
 * @return {Void} Nothing
 */
const changeLabel = function (input) {
  let submit = input.closest("form").querySelector("button[type=submit]");

  if (submit.querySelector("span") !== null) {
    submit = submit.querySelector("span");
  }
  if (input.checked === true) {
    submit.innerHTML = input.dataset.labelAction;
  } else {
    submit.innerHTML = input.dataset.labelReport;
  }
}

/**
 * @param {Object} container The form handling the report.
 * @return {Void} Nothing
 */
export default function changeReportFormBehavior(container) {
  container.querySelectorAll("[data-hide=true]").forEach((checkbox) => {
    checkbox.addEventListener("change", (event) => {
      changeLabel(event.target);
    });
  });
  container.querySelectorAll("[data-block=true]").forEach((checkbox) => {
    checkbox.addEventListener("change", (event) => {
      changeLabel(event.target);
      let blockAndHide = event.target.closest("form").querySelector("#block_and_hide");
      if (event.target.checked === true) {
        blockAndHide.style.display = "block";
      } else {
        blockAndHide.style.display = "none";
      }
    });
  });
}
