/* eslint-disable max-params */
document.addEventListener("DOMContentLoaded", () => {
  const watchingDiv = document.querySelector("[data-results-live-update]");
  if (!watchingDiv) {
    return;
  }

  const url = watchingDiv.dataset.resultsLiveUpdate;
  const questionTemplate = document.querySelector("[data-question-template]");
  const optionTemplate = document.querySelector("[data-option-template]");
  const questionContainer = document.querySelector("[data-questions-container]");
  const optionVoteCountTexts = () => document.querySelectorAll("[data-option-votes-count-text]");
  const optionVotePercentTexts = () => document.querySelectorAll("[data-option-votes-percent-text]");
  const optionVoteWidths = () => document.querySelectorAll("[data-option-votes-width]");

  const animateText = (element, value) => {
    if (element.textContent === value) {
      return;
    }
    element.textContent = value;
    element.classList.add("live_results-number_changing");
    setTimeout(() => {
      element.classList.remove("live_results-number_changing");
    }, 1000);
  };

  const digOptionValue = (questionId, optionId, data, key) => {
    data.questions = data.questions || [];
    const question = data.questions.find((item) => item.id === parseInt(questionId, 10));
    if (!question) {
      return null;
    }
    const responseOptions = question.response_options || [];
    if (!Array.isArray(responseOptions)) {
      return null;
    }
    const option = responseOptions.find((item) => item.id === parseInt(optionId, 10));
    if (!option) {
      return null;
    }
    if (key in option) {
      return option[key];
    }
    return null;
  };

  const createAdditionalQuestions = (data) => {
    if (!questionContainer || !questionTemplate || !optionTemplate) {
      return;
    }

    const questions = data.questions || [];
    const additionalQuestions = questions.filter((question) => !document.getElementById(`question-${question.id}`));
    additionalQuestions.forEach((question) => {
      const questionElement = questionTemplate.cloneNode(true);
      questionElement.id = `question-${question.id}`;
      questionElement.classList.remove("hidden");
      questionElement.removeAttribute("data-question-template");
      questionElement.querySelector("[data-question-position]").textContent = question.position + 1;
      questionElement.querySelector("[data-question-body]").textContent = question.body;
      const optionsContainer = questionElement.querySelector("[data-options-container]");
      if (!optionsContainer) {
        console.error("Options container not found in question template");
        return;
      }
      question.response_options.forEach((option, index) => {
        const optionElement = optionTemplate.cloneNode(true);
        optionElement.removeAttribute("data-option-template");
        optionElement.classList.remove("hidden");
        optionElement.querySelector("[data-option-body]").textContent = `${index + 1}. ${option.body}`;
        optionElement.querySelector("[data-option-votes-count-text").dataset.optionVotesCountText = `${question.id},${option.id}`;
        optionElement.querySelector("[data-option-votes-percent-text").dataset.optionVotesPercentText = `${question.id},${option.id}`;
        optionElement.querySelector("[data-option-votes-width").dataset.optionVotesWidth = `${question.id},${option.id}`;
        optionsContainer.appendChild(optionElement);
      });
      questionContainer.appendChild(questionElement);
        
    });
  };

  const fetchResults = async () => {
    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Accept": "application/json", 
          "Content-Type": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      });
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      const data = await response.json();
      optionVoteCountTexts().forEach((el) => {
        const [questionId, optionId] = el.dataset.optionVotesCountText.split(",");
        const val = digOptionValue(questionId, optionId, data, "votes_count_text")
        if (val) {
          animateText(el, val);
        }
      });
      optionVotePercentTexts().forEach((el) => {
        const [questionId, optionId] = el.dataset.optionVotesPercentText.split(",");
        const val = digOptionValue(questionId, optionId, data, "votes_percent_text")
        if (val) {
          animateText(el, val);
        }
      });
      optionVoteWidths().forEach((el) => {
        const [questionId, optionId] = el.dataset.optionVotesWidth.split(",");
        const val = digOptionValue(questionId, optionId, data, "votes_percent")
        if (val) {
          el.style.width = `${val}%`;
        }
      });
      createAdditionalQuestions(data);
      // repeat for ongoing elections only
      if (data.ongoing) {
        setTimeout(fetchResults, 4000);
      }
    } catch (error) {
      console.error("Error fetching results:", error);
    }
  };

  fetchResults();
});
