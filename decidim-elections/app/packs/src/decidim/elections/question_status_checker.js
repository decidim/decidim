/**
 * Polls the server to check if the current question is still available for voting.
 * When voting is closed, redirects user to the waiting room or next question.
 */
document.addEventListener("DOMContentLoaded", () => {
  const votingBooth = document.querySelector("[data-question-status-url]");
  if (!votingBooth) {
    return;
  }

  const statusUrl = votingBooth.dataset.questionStatusUrl;
  if (!statusUrl) {
    return;
  }

  const checkStatus = async () => {
    try {
      const response = await fetch(statusUrl, {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      });

      if (response.ok) {
        const result = await response.json();
        if (!result.voting_enabled && result.redirect_url) {
          window.location.href = result.redirect_url;
          return;
        }
      }
    } catch (error) {
      console.error("[QuestionStatusChecker] Error:", error);
    }

    setTimeout(checkStatus, 1000);
  };

  setTimeout(checkStatus, 1000);
});
