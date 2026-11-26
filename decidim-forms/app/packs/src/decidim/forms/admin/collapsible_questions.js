document.addEventListener("turbo:load", () => {
  document.querySelector("button.collapse-all")?.addEventListener("click", () => {
    document.querySelectorAll("[id$=field] button.question--collapse[aria-expanded='true']").
      forEach((button) => button.click());
  });

  document.querySelector("button.expand-all")?.addEventListener("click", () => {
    document.querySelectorAll("[id$=field] button.question--collapse[aria-expanded='false']").
      forEach((button) => button.click());
  });
});
