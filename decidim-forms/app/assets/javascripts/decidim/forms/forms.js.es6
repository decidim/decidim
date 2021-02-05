// = require ./option_attached_inputs.component
// = require ./autosortable_checkboxes.component
// = require ./display_conditions.component
// = require ./max_choices_alert.component

((exports) => {
  const { createOptionAttachedInputs, createAutosortableCheckboxes, createMaxChoicesAlertComponent, createDisplayConditions } = exports.Decidim;

  $(".radio-button-collection, .check-box-collection").each((idx, el) => {
    createOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=radio], input[type=checkbox]",
      dependentInputSelector: "input[type=text], input[type=hidden]"
    });
  });

  $.unique($(".check-box-collection").parents(".answer")).each((idx, el) => {
    const maxChoices = $(el).data("max-choices");
    if (maxChoices) {
      createMaxChoicesAlertComponent({
        wrapperField: $(el),
        controllerFieldSelector: "input[type=checkbox]",
        controllerCollectionSelector: ".check-box-collection",
        alertElement: $(el).find(".max-choices-alert"),
        maxChoices: maxChoices
      });
    }
  });

  $(".sortable-check-box-collection").each((idx, el) => {
    createAutosortableCheckboxes({
      wrapperField: $(el)
    })
  });

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

    let exitUrl = null;
    const safePath = $form.data("safe-path").split("?")[0];
    $(document).on("click", "a", (event) => {
      exitUrl = event.currentTarget.href;
    });
    $(document).on("submit", "form", (event) => {
      exitUrl = event.currentTarget.action;
    });

    $(window).on("beforeunload", (ev) => {
      const currentExitUrl = exitUrl;
      const hasChanged = $form.data("changed");
      exitUrl = null;

      console.log(ev);

      if (!hasChanged || (currentExitUrl && currentExitUrl.includes(safePath))) {
        console.log("BEFORE UNLOAD FALSE");
        // Linter doesn't like returning undefined, so we need to remove the
        // result value manually in order to achieve this.
        Reflect.deleteProperty(ev, "result");
        return;
      }

      // TODO: Here you should return something that works in FF, IE and Chrome
      //       Returning "test" would cause IE to show message "test".
      //       Returning "" does not seem to work in FF => how we can get it to work?
      console.log("BEFORE UNLOAD TRUE");
      ev.result = "test";
    });
  }
})(window);
