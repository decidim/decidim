/* eslint-disable require-jsdoc */

/**
 * Since the ["drag-on-drop"](https://github.com/schne324/dragon-drop) dependency is just an A11Y wrapper,
 * its core is actually using the ["dragula"](https://github.com/bevacqua/dragula) resource,
 * therefore the styles must be imported from the original library.
 */
import DragonDrop from "drag-on-drop";
import "dragula/dist/dragula.css";

import createOptionAttachedInputs from "src/decidim/forms/option_attached_inputs.component"
import createDisplayConditions from "src/decidim/forms/display_conditions.component"
import createMaxChoicesAlertComponent from "src/decidim/forms/max_choices_alert.component"
import { preventUnload } from "src/decidim/utilities/dom"

$(() => {
  $(".js-radio-button-collection, .js-check-box-collection").each((idx, el) => {
    createOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=radio], input[type=checkbox]",
      dependentInputSelector: "input[type=text], input[type=hidden]"
    });
  });

  $.unique($(".js-check-box-collection").parents(".response")).each((idx, el) => {
    const maxChoices = $(el).data("max-choices");
    if (maxChoices) {
      createMaxChoicesAlertComponent({
        wrapperField: $(el),
        controllerFieldSelector: "input[type=checkbox]",
        controllerCollectionSelector: ".js-check-box-collection",
        alertElement: $(el).find(".max-choices-alert"),
        maxChoices: maxChoices
      });
    }
  });

  document.querySelectorAll(".js-sortable-check-box-collection").forEach((el) => new DragonDrop(el, {
    handle: false,
    item: ".js-collection-input"
  }));

  $(".response-questionnaire .question[data-conditioned='true']").each((idx, el) => {
    createDisplayConditions({
      wrapperField: $(el)
    });
  });

  const form = document.querySelector("form.response-questionnaire");
  if (form) {
    const safePath = form.dataset.safePath.split("?")[0];
    let exitUrl = "";
    document.addEventListener("click", (event) => {
      const link = event.target?.closest("a");
      if (link) {
        exitUrl = link.href;
      }
    });

    // The submit listener has to be registered through jQuery because the
    // custom confirm dialog does not dispatch the "submit" event normally.
    $(document).on("submit", "form", (event) => {
      exitUrl = event.currentTarget.action;
    });

    let hasChanged = false;
    const controls = form.querySelectorAll("input, textarea, select");
    const changeListener = () => {
      if (!hasChanged) {
        hasChanged = true;
        controls.forEach((control) => control.removeEventListener("change", changeListener));

        preventUnload(() => !exitUrl.includes(safePath));
      }
    };
    controls.forEach((control) => control.addEventListener("change", changeListener));
  }
})
