import "src/decidim/forms/admin/collapsible_questions"

import createEditableForm from "src/decidim/forms/admin/forms"
import createPublicableQuestionAnswersButtons from "src/decidim/forms/admin/publish_answers_buttons"

window.Decidim.createEditableForm = createEditableForm

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll("[data-publish-question-answer-action]").forEach((el) =>  createPublicableQuestionAnswersButtons(el));
});
