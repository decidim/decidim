(() => {
  $("button.collapse-all").on("click", () => {
    $("[id^=questionnaire_question]").find("button.question--collapse[aria-expanded='true']").click()
  });

  $("button.expand-all").on("click", () => {
    $("[id^=questionnaire_question]").find("button.question--collapse[aria-expanded='false']").click()
  });
})(window);
