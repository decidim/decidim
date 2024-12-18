// Given a toggle button for publishing or unpublishing a questions' answers:
//
// 1. Depending on the action it publishes or unpublishes ...
// 2. ... by sending an AJAX request to the URL depending on the action ...
// 3. ... and changing the labels and action accordingly
//
// @param {HTMLElement} button - the button to bind the click listener
//
// @example
// ```
// <label class="toggle__switch-toggle">
//   <span class="toggle__switch-trigger-text">
//     <span class="label success">Published</span>
//     <span class="label alert hidden">Unpublished</span>
//   <span>
//     <input
//     data-publish-question-answer-action="unpublish"
//     data-publish-question-answer-question-url="/path/to/publish/or/unpublish">
//   </span>
// </label>
// ```
export default function createPublicableQuestionAnswersButtons(button) {
  button.addEventListener("click", () => {
    const action = button.dataset.publishQuestionAnswerAction;
    const url = button.dataset.publishQuestionAnswerQuestionUrl;
    const buttonText = button.closest(".toggle__switch-toggle").querySelector(".toggle__switch-trigger-text");
    const publishedLabel = buttonText.querySelector(".label.success");
    const unpublishedLabel = buttonText.querySelector(".label.success");

    switch (action) {
    case "publish":
      Rails.ajax({
        url: url,
        type: "PUT",
        success: function() {
          button.setAttribute("data-publish-question-answer-action", "unpublish")
          publishedLabel.classList.remove("hidden");
          unpublishedLabel.classList.add("hidden");
        }
      });
      break;
    case "unpublish":
      Rails.ajax({
        url: url,
        type: "DELETE",
        success: function() {
          button.setAttribute("data-publish-question-answer-action", "publish")
          unpublishedLabel.classList.remove("hidden");
          publishedLabel.classList.add("hidden");
        }
      });
      break;
    default:
      console.log(`Publish questions answers: Unknown action ${action}`);
    }
  });
}
