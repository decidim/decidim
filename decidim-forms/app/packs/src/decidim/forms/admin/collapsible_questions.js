(() => {
  const getButtons = document.querySelectorAll("button.question--collapse");

  setTimeout(() => {
    getButtons.forEach((button) => {
      if (button.classList.contains("question-error")) {
        button.click();
      }
    });
  }, 100);

  document.querySelector("button.collapse-all")?.addEventListener("click", () => {
    document.querySelectorAll("[id$=field] button.question--collapse[aria-expanded='true']").
      forEach((button) => button.click());
  });

  document.querySelector("button.expand-all")?.addEventListener("click", () => {
    document.querySelectorAll("[id$=field] button.question--collapse[aria-expanded='false']").
      forEach((button) => button.click());
  });
})();
