/**
 * Vote Questions component.
 */

export default class VoteQuestionsComponent {
  constructor($voteWrapper) {
    this.$voteWrapper = $voteWrapper;
    this.$continueButton = this.$voteWrapper.find("a.focus__next");
    this.$confirmButton = this.$voteWrapper.find("a.focus__next.confirm");
    this.$continueSpan = this.$voteWrapper.find("span.disabled-continue");
    this.$currentStep = "";
    this.$currentStepMaxSelection = "";
    this.$answerCounter = 0;
    this.voteCasted = false;
    window.onbeforeunload = () => {
      if (this.voteCasted) {
        return null;
      }
      return "";
    }
  }

  init() {
    this.setCurrentStep();
    this.toggleContinueButton();
    this.$confirmButton.addClass("show").removeClass("hide");
    $(".evote__counter-min").text(this.$answerCounter);
    this.answerCounter();
    this.disableCheckbox();
  }

  setCurrentStep() {
    this.$currentStep = this.$voteWrapper.find(".focus__step:visible")
    this.setSelections();
    this.onSelectionChange();
  }

  errored() {
    this.$currentStep.addClass("hide").removeClass("show")
    this.$currentStep = this.$voteWrapper.find("#failed").addClass("show").removeClass("hide")
  }

  toggleContinueButton() {
    if (this.checkAnswers()) {
      // next step enabled
      this.$continueButton.addClass("show").removeClass("hide")
      this.$continueSpan.addClass("hide").removeClass("show")
    } else {
      // next step disabled
      this.$continueButton.addClass("hide").removeClass("show")
      this.$continueSpan.addClass("show").removeClass("hide")
    }
  }

  // check if answers are correctly checked
  checkAnswers() {
    const currentAnswersChecked = $(`#${this.$currentStep.attr("id")} .answer_input:checked`).length
    const notaAnswerChecked = $(`#${this.$currentStep.attr("id")} .nota_input:checked`).length

    return ((currentAnswersChecked >= 1 || notaAnswerChecked > 0) && (currentAnswersChecked <= this.$currentStepMaxSelection));
  }

  answerCounter() {
    let checked = $(`#${this.$currentStep.attr("id")} .answer_input:checked`).length
    $(".evote__counter-min").text(checked);
  }

  // disable checkboxes if NOTA option is selected
  disableCheckbox() {
    $("[data-disabled-by]").on("click", (event) => {
      if ($(event.target).attr("aria-disabled") || $(event.target).hasClass("is-disabled")) {
        event.preventDefault();
      }
    });

    $("[data-disable-check]").on("change", (event) => {
      let checkId = $(event.target).attr("id");
      let checkStatus = event.target.checked;

      this.$currentStep.find(`[data-disabled-by='#${checkId}']`).each((_index, element) => {
        if (checkStatus) {
          $(element).addClass("is-disabled");
          $(element).find("input[type=checkbox]").prop("checked", false);
          $(element).find("input[type=checkbox]").attr("aria-disabled", "");
        } else {
          $(element).removeClass("is-disabled");
          $(element).find("input[type=checkbox]").removeAttr("aria-disabled");
        }
      });
    });
  }

  setSelections() {
    this.$currentStepMaxSelection = this.$currentStep.find(".evote__options").data("max-selection")
  }


  onSelectionChange() {
    let $voteOptions = this.$currentStep.find(".evote__options");
    $voteOptions.on("change", () => {
      this.toggleContinueButton();
      this.toggleConfirmAnswers();
      this.answerCounter();
    });
  }

  // receive confirmed answers
  toggleConfirmAnswers() {
    $(".answer_input:checked").each((_index, element) => {
      const confirmedAnswer = $(".evote__confirm").find(`#${element.value}`);
      $(confirmedAnswer).removeClass("hide")
    })

    $(".answer_input").not(":checked").each((_index, element) => {
      const confirmedAnswer = $(".evote__confirm").find(`#${element.value}`);
      $(confirmedAnswer).addClass("hide")
    })

    $(".nota_input:checked").each((_index, element) => {
      const confirmedAnswer = $(".evote__confirm").find(`.${element.value}`);
      $(confirmedAnswer).removeClass("hide")
    })

    $(".nota_input").not(":checked").each((_index, element) => {
      const confirmedAnswer = $(".evote__confirm").find(`.${element.value}`);
      $(confirmedAnswer).addClass("hide")
    })
  }
}
