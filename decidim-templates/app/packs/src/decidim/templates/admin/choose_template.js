$(() => {
  const wrapper = document.querySelector("#choose-template");
  const input = wrapper.querySelector("input#questionnaire_questionnaire_template_id");
  if (!input) {
    return;
  }

  const textInput = wrapper.querySelector("input[name='template-name']");
  const options = wrapper.querySelector("#template-list").children;
  const previewURL = wrapper.dataset.previewurl;

  const preview = (id) => {
    if (!previewURL) {
      return;
    }
    const params = new URLSearchParams({ id: id });
    fetch(`${previewURL}?${params.toString()}`, {
      method: "GET",
      headers: { "Content-Type": "application/json" }
    }).then((response) => response.text()).then((data) => {
      const script = document.createElement("script");
      script.type = "text/javascript";
      script.innerHTML = data;
      document.getElementsByTagName("head")[0].appendChild(script);
    }).catch((error) => {
      console.error(error); // eslint-disable-line no-console
    });
  }

  const selectValue = (selected) => {
    for (let idx = 0; idx < options.length; idx += 1) {
      if (options[idx].innerHTML === selected) {
        const id = options[idx].dataset.value;
        input.value = id
        preview(id);
        break;
      }
    }
  }

  textInput.addEventListener("input", () => {
    const selected = textInput.value;
    selectValue(selected);
  })
})
