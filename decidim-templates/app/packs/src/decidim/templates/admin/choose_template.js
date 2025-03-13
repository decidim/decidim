import { datalistSelect } from "src/decidim/datalist_select";

$(() => {
  const chooseTemplateForm = document.querySelector("[data-choose-questionnaire-templates]");
  if (!chooseTemplateForm) {
    return;
  }

  const chooseTemplateWrapper = document.querySelector("#choose-template");
  if (!chooseTemplateWrapper) {
    return;
  }

  const createNewFormButton = document.querySelector("[data-create-new-form-button]");
  const withTemplateButton = document.querySelector("[data-with-template-button]");
  const disabledContinueButton = document.querySelector("[data-disabled-button]");
  const questionnaireTemplatePreview = document.querySelector("[data-questionnaire-template-preview]");

  const toggleElementsOnChange = () => {
    const radios = document.querySelectorAll("input[name='template']");

    radios.forEach((radio) => {
      radio.addEventListener("change", function() {
        switch (radio.value) {
        case "create_new_form":
          chooseTemplateWrapper.classList.add("hidden");
          disabledContinueButton.classList.add("hidden");
          withTemplateButton.classList.add("hidden");
          questionnaireTemplatePreview.classList.add("hidden");
          createNewFormButton.classList.remove("hidden");
          break;

        case "select_template":
          chooseTemplateWrapper.classList.remove("hidden");
          disabledContinueButton.classList.remove("hidden");
          questionnaireTemplatePreview.classList.remove("hidden");
          createNewFormButton.classList.add("hidden");
          // withTemplateButton.classList.add("hidden");

          // Clean-up old values in case the admin is changing between the options after filling 'Select template'
          // chooseTemplateWrapper.classList.add("hide");
          document.querySelector("#questionnaire_questionnaire_template_id").value = "";
          document.querySelector("input[name=select-template]").value = "";
          document.querySelector("[data-template-name]").innerHTML = "";
          document.querySelector("[data-template-description]").innerHTML = "";
          document.querySelector("[data-choose-template-preview]").innerHTML = "";

          break;

        default:
          console.error("Unknown template type for choosing a questionnaire template");
        }
      });
    });
  }

  const preview = (id) => {
    const options = chooseTemplateWrapper.dataset;
    const previewURL = options.previewurl;
    if (!previewURL) {
      return;
    }
    const params = new URLSearchParams({ id: id });
    Rails.ajax({
      url: `${previewURL}?${params.toString()}`,
      type: "GET",
      error: (data) => (console.error(data))
    });

    disabledContinueButton.classList.add("hidden");
    withTemplateButton.classList.remove("hidden");
  }

  datalistSelect(chooseTemplateWrapper, preview)
  toggleElementsOnChange();
})
