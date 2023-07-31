/**
 * Vote Questions component.
 */

export default class VoteQuestionsComponent {
  constructor($voteWrapper) {
    this.$voteWrapper = $voteWrapper;
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

    $("[data-counter-selection]").text(this.$answerCounter);
    this.answerCounter();
    this.disableCheckbox();
  }

  setCurrentStep() {
    this.$currentStep = this.$voteWrapper.find('[id^="step"]:not([hidden])')
    this.$confirmButton = this.$currentStep.find('[id^="next"]');

    this.setSelections();
    this.onSelectionChange();
    this.updateWizardSteps(this.$currentStep.attr("id"));
  }

  errored() {
    this.$currentStep.attr("hidden", true);
    this.$currentStep = this.$voteWrapper.find("#failed").attr("hidden", false);
  }

  toggleContinueButton() {
    // ignore the button if the step is not a question
    if (!this.isQuestion(this.$currentStep.attr("id"))) {
      return
    }

    if (this.checkAnswers()) {
      // next step enabled
      this.$confirmButton.attr("disabled", false)
    } else {
      // next step disabled
      this.$confirmButton.attr("disabled", true)
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
    $("[data-counter-selection]").text(checked);
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

      this.$currentStep.find(`[data-disabled-by='${checkId}']`).each((_index, element) => {
        const $checkbox = $(element).find("input[type=checkbox]")

        if (checkStatus) {
          $checkbox.prop("disabled", true);
          $checkbox.prop("checked", false);
          $(element).attr("aria-disabled", true);
        } else {
          $checkbox.prop("disabled", false);
          $(element).removeAttr("aria-disabled");
        }
      });
    });
  }

  setSelections() {
    this.$currentStepMaxSelection = this.$currentStep.find('[id^="question"]').data("max-selection")
  }

  onSelectionChange() {
    let $voteOptions = this.$currentStep.find('[id^="question"]');
    $voteOptions.on("change", () => {
      this.toggleContinueButton();
      this.toggleConfirmAnswers();
      this.answerCounter();
    });
  }

  updateWizardSteps(id) {
    const wizard = document.getElementById("wizard-steps")
    const heading = document.getElementById("heading")

    if (heading) {
      // this step has no heading 🤷‍♀️
      if (id === "step-encrypting") {
        heading.hidden = true

        return
      }

      heading.hidden = false
    }

    if (wizard) {
      let selector = id

      if (this.isQuestion(id)) {
        selector = "step-election"
      }

      wizard.querySelectorAll("[data-step]").forEach((element) => {
        if (element.dataset.step === selector) {
          element.setAttribute("aria-current", "step")
        } else {
          element.removeAttribute("aria-current")
        }
      })
    }
  }

  // the question ids always end with a number
  isQuestion(id) {
    return (/[0-9]+$/).test(id);
  }

  // receive confirmed answers
  toggleConfirmAnswers() {
    $(".answer_input:checked").each((_index, element) => {
      const confirmedAnswer = $("#step-confirm").find(`#${element.value}`);
      $(confirmedAnswer).attr("hidden", false)
    })

    $(".answer_input").not(":checked").each((_index, element) => {
      const confirmedAnswer = $("#step-confirm").find(`#${element.value}`);
      $(confirmedAnswer).attr("hidden", true)
    })

    $(".nota_input:checked").each((_index, element) => {
      const confirmedAnswer = $("#step-confirm").find(`#${element.value}`);
      $(confirmedAnswer).attr("hidden", false)
    })

    $(".nota_input").not(":checked").each((_index, element) => {
      const confirmedAnswer = $("#step-confirm").find(`#${element.value}`);
      $(confirmedAnswer).attr("hidden", true)
    })
  }
}
