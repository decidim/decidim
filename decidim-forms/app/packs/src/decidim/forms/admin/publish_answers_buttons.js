
export default function createPublicableQuestionAnswersButtons(button) {
  button.addEventListener("click", (_event) => {
    const action = button.dataset.publishQuestionAnswerAction;
    const url = button.dataset.publishQuestionAnswerQuestionUrl;
    const buttonText = button.closest(".toggle__switch-toggle").querySelector(".toggle__switch-trigger-text");

    switch (action) {
      case "publish":
        Rails.ajax({
          url: url,
          type: "PUT",
          success: function(){
            button.setAttribute("data-publish-question-answer-action", "unpublish")
            buttonText.querySelector(".label.success").classList.remove("hidden");
            buttonText.querySelector(".label.alert").classList.add("hidden");
          }
        });
        break;
      case "unpublish":
        Rails.ajax({
          url: url,
          type: "DELETE",
          success: function(){
            button.setAttribute("data-publish-question-answer-action", "publish")
            buttonText.querySelector(".label.alert").classList.remove("hidden");
            buttonText.querySelector(".label.success").classList.add("hidden");
          }
        });
        break;
      default:
        console.log("Publish questions answers: Unknown action" + action + ".");
    }
  });
}
