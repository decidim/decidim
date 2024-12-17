
export default function createPublicableQuestionAnswersButtons(button) {
  button.addEventListener("click", (_event) => {
    const action = button.dataset.publishQuestionAnswerAction;
    const questionId = button.dataset.publishQuestionAnswerQuestionId;

    switch (action) {
      case "publish":
        document.querySelector(`[data-publish-question-answer="${questionId}"]`).dispatchEvent(new Event('click'));
        break;
      case "unpublish":
        document.querySelector(`[data-unpublish-question-answer="${questionId}"]`).dispatchEvent(new Event('click'));
        break;
      default:
        console.log("Publish questions answers: Unknown action" + action + ".");
    }
  });
}
