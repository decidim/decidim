import "src/decidim/forms/admin/collapsible_questions"

import createEditableForm from "src/decidim/forms/admin/forms"
import createPublicableQuestionResponsesButtons from "src/decidim/forms/admin/publish_responses_buttons"

window.Decidim.createEditableForm = createEditableForm

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll("[data-publish-question-response-action]").forEach((el) =>  createPublicableQuestionResponsesButtons(el));
});
