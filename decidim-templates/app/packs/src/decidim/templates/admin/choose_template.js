$(() => {
  const textInput = document.querySelector("input[name='template-name']");
  const input = document.querySelector("input#questionnaire_questionnaire_template_id");
  if (!input || !textInput) {
    return;
  }

  const options = document.querySelector("#template-list").children;

  textInput.addEventListener("input", (event) => {
    const selected = event.data

    for (let idx = 0; idx < options.length; idx += 1) {
      if (options[idx].innerHTML === selected) {
        input.value = options[idx].dataset.value;
        break;
      }
    }
  })
})
