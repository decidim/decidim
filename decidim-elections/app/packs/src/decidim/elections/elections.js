document.addEventListener("turbo:load", () => {
  const responseContainers = document.querySelectorAll(".response[data-max-choices]");
  if (!responseContainers.length) {
    return;
  }

  responseContainers.forEach((container) => {
    const maxChoices = parseInt(container.dataset.maxChoices, 10);
    if (!maxChoices) {
      return;
    }

    const checkboxes = container.querySelectorAll("input[type=checkbox]");
    const alertElement = container.querySelector(".max-choices-alert");

    const checkLimit = () => {
      const checkedCount = container.querySelectorAll("input[type=checkbox]:checked").length;

      if (checkedCount > maxChoices) {
        alertElement.style.display = "block";
      } else {
        alertElement.style.display = "none";
      }
    };

    checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", checkLimit);
    });

    checkLimit();
  });
});
