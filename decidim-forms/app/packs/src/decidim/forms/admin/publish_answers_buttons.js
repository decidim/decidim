/**
 * Initializes event listeners for a button to toggle the publication status of question answers.
 *
 * The button's `data-publish-question-answer-action` attribute determines whether the action is
 * to "publish" or "unpublish." Based on this attribute, the function makes an AJAX request using
 * Rails' AJAX helper and updates the button's state and associated labels.
 *
 * @param {HTMLButtonElement} button - The button element that triggers the publication toggle action.
 *
 * @returns {void}
 *
 * Button element must have the following data attributes:
 * - `data-publish-question-answer-action`: Specifies the current action ("publish" or "unpublish").
 * - `data-publish-question-answer-question-url`: Specifies the endpoint URL for the AJAX request.
 *
 * The DOM structure must include:
 * - A parent element with the class `toggle__switch-toggle`.
 * - A child element with the class `toggle__switch-trigger-text`.
 * - Two labels within `toggle__switch-trigger-text`:
 *   - One with the class `label success` to indicate the "published" state.
 *   - One with the class `label success` to indicate the "unpublished" state.
 *
 * Example usage:
 * ```html
 *  <label class="toggle__switch-toggle">
 *   <span class="toggle__switch-trigger-text">
 *     <span class="label success">Published</span>
 *     <span class="label alert hidden">Unpublished</span>
 *   <span>
 *     <input
 *     data-publish-question-answer-action="unpublish"
 *     data-publish-question-answer-question-url="/path/to/publish/or/unpublish">
 *   </span>
 *  </label>
 * ```
 */
export default function createPublicableQuestionAnswersButtons(button) {
  button.addEventListener("click", () => {
    const action = button.dataset.publishQuestionAnswerAction;
    const url = button.dataset.publishQuestionAnswerQuestionUrl;
    const buttonText = button.closest(".toggle__switch-toggle").querySelector(".toggle__switch-trigger-text");
    const publishedLabel = buttonText.querySelector(".label.success");
    const unpublishedLabel = buttonText.querySelector(".label.alert");

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
