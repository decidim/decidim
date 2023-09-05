(() => {
  const getButtons = document.querySelectorAll("button.question--collapse");

  setTimeout(() => {
    [...getButtons].forEach((button) => {
      if (button.classList.contains("question-error")) {
        button.click()
      }
    })
  }, 100)

  $("button.collapse-all").on("click", () => {
    $("[id$=field]").find("button.question--collapse[aria-expanded='true']").click()
  });

  $("button.expand-all").on("click", () => {
    $("[id$=field]").find("button.question--collapse[aria-expanded='false']").click()
  });
})(window);
