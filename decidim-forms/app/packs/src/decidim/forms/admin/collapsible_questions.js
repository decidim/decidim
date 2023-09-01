(() => {
  const getButtons = document.querySelectorAll("button.question--collapse");

  setTimeout(() => {
    [...getButtons].forEach((button) => {
      if(button.classList.contains("question-error")){
        button.setAttribute('aria-expanded','true')
      }
    })

    document.querySelectorAll(".panel-question-card ").forEach((panel) => {
      console.log("panel", panel);
      if(panel.classList.contains("panel-error")){
        panel.setAttribute('aria-hidden','false')
      }
    })
  },100)

  $("button.collapse-all").on("click", () => {
    [...getButtons].forEach((button) => {
      button.setAttribute("aria-expanded", "false");
    })

    document.querySelectorAll(".panel-question-card ").forEach((panel) => {
      panel.setAttribute("aria-hidden", "true");
    })
  });

  $("button.expand-all").on("click", () => {
    [...getButtons].forEach((button) => {
      button.setAttribute("aria-expanded", "true");
    })
    document.querySelectorAll(".panel-question-card ").forEach((panel) => {
      panel.setAttribute("aria-hidden", "false");
    })

  });
})(window);
