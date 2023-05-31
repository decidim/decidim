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

$(() => {
  $(".js-radio-button-collection, .js-check-box-collection").each((idx, el) => {
    createOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=radio], input[type=checkbox]",
      dependentInputSelector: "input[type=text], input[type=hidden]"
    });
  });

  $.unique($(".js-check-box-collection").parents(".answer")).each((idx, el) => {
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

  $(".answer-questionnaire .question[data-conditioned='true']").each((idx, el) => {
    createDisplayConditions({
      wrapperField: $(el)
    });
  });

  const $form = $("form.answer-questionnaire");
  if ($form.length > 0) {
    $form.find("input, textarea, select").on("change", () => {
      $form.data("changed", true);
    });

    const safePath = $form.data("safe-path").split("?")[0];
    $(document).on("click", "a", (event) => {
      window.exitUrl = event.currentTarget.href;
    });
    $(document).on("submit", "form", (event) => {
      window.exitUrl = event.currentTarget.action;
    });

    window.addEventListener("beforeunload", (event) => {
      const exitUrl = window.exitUrl;
      const hasChanged = $form.data("changed");
      window.exitUrl = null;

      if (!hasChanged || (exitUrl && exitUrl.includes(safePath))) {
        return;
      }

      event.returnValue = true;
    });
  }
})
