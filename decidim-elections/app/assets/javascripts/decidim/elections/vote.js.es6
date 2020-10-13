/* eslint-disable require-jsdoc, prefer-template, func-style, id-length, no-use-before-define, init-declarations, no-invalid-this */
/* eslint no-unused-vars: ["error", { "args": "none" }] */

$(() => {
  const $vote = $(".focus");
  const $continueButton = $vote.find("a.focus__next");
  const $confirmButton = $vote.find("a.focus__next.confirm");
  const $continueSpan = $vote.find("span.disabled-continue");
  let $answerCounter = 0;
  let $currentStep,
      $currentStepMaxSelection = "";
  let $formData = $vote.find(".answer_input");

  function initStep() {
    setCurrentStep();
    toggleContinueButton();
    $($confirmButton).addClass("show").removeClass("hide");
    $(".evote__counter-min").text($answerCounter);
    answerCounter();
    disableCheckbox();
  }

  initStep()

  function setCurrentStep() {
    $currentStep = $vote.find(".focus__step:visible")
    setSelections();
    onSelectionChange();
  }

  function setSelections() {
    $currentStepMaxSelection = $currentStep.find(".evote__options").data("max-selection")
  }

  function onSelectionChange() {
    let $voteOptions = $currentStep.find(".evote__options");
    $voteOptions.on("change", (event) => {
      toggleContinueButton();
      toggleConfirmAnswers();
      answerCounter();
    });
  }

  // disable checkboxes if NOTA option is selected
  function disableCheckbox() {
    $("[data-disabled-by]").on("click", function(e) {
      if ($(this).attr("aria-disabled") || $(this).hasClass("is-disabled")) {
        e.preventDefault();
      }
    });

    $("[data-disable-check]").on("change", function() {
      let checkId = $(this).attr("id");
      let checkStatus = this.checked;

      $($currentStep).find("[data-disabled-by='#" + checkId + "']").each(function() {
        if (checkStatus) {
          $(this).addClass("is-disabled");
          $(this).find("input[type=checkbox]").prop("checked", false);
        } else {
          $(this).removeClass("is-disabled");
        }

        $(this).find("input[type=checkbox]").attr("aria-disabled", checkStatus);
      });
    });
  }

  function toggleContinueButton() {
    if (checkAnswers() === true) {
      // next step enabled
      $($continueButton).addClass("show").removeClass("hide")
      $($continueSpan).addClass("hide").removeClass("show")
    } else {
      // next step disabled
      $($continueButton).addClass("hide").removeClass("show")
      $($continueSpan).addClass("show").removeClass("hide")
    }
  }

  // check if answers are correctly checked
  function checkAnswers() {
    let currentAnswersChecked = $("#" + $currentStep.attr("id") + " .answer_input:checked").length
    let notaAnswerChecked = $("#" + $currentStep.attr("id") + " .nota_input:checked").length

    if ((currentAnswersChecked >= 1 || notaAnswerChecked > 0) && (currentAnswersChecked <= $currentStepMaxSelection)) {
      return true;
    }

    return false;
  }

  // receive confirmed answers
  function toggleConfirmAnswers() {
    $(".answer_input:checked").each(function() {
      let confirmedAnswer = $(".evote__confirm").find("#" + this.value);
      $(confirmedAnswer).removeClass("hide")
    })

    $(".answer_input").not(":checked").each(function() {
      let confirmedAnswer = $(".evote__confirm").find("#" + this.value);
      $(confirmedAnswer).addClass("hide")
    })

    $(".nota_input:checked").each(function() {
      let confirmedAnswer = $(".evote__confirm").find("." + this.value);
      $(confirmedAnswer).removeClass("hide")
    })

    $(".nota_input").not(":checked").each(function() {
      let confirmedAnswer = $(".evote__confirm").find("." + this.value);
      $(confirmedAnswer).addClass("hide")
    })
  }

  function answerCounter() {
    let checked = $("#" + $currentStep.attr("id") + " .answer_input:checked").length
    $(".evote__counter-min").text(checked);
  }

  // get form Data
  function getFormData(formData) {
    let unindexedArray = formData.serializeArray();
    let indexedArray = {};
    $.map(unindexedArray, function(n, i) {
      indexedArray[n.name] = n.value;
    });

    return indexedArray;
  }

  // confirm vote
  $(".button.confirm").on("click", (event) => {
    const boothMode = $(event.currentTarget).data("booth-mode");
    const formData = getFormData($formData);
    castVote(boothMode, formData)
  });

  // cast vote
  function castVote(boothMode, formData) {
    // log form Data
    console.log(`Your vote got encrypted successfully. The booth mode is ${boothMode}. Your vote content is:`, formData) // eslint-disable-line no-console

    window.setTimeout(function() {
      $($vote).find("#encrypting").addClass("hide")
      $($vote).find("#confirmed_page").removeClass("hide")
      window.confirmed = true;
    }, 3000)
  }

  // exit message before confirming
  const $form = $(".evote__options");
  if ($form.length > 0) {

    window.onbeforeunload = () => {
      const voteCast = window.confirmed;

      if (voteCast) {
        return null;
      }

      return "";
    }
  }

  $(document).on("on.zf.toggler", (event) => {
    // continue and back btn
    initStep()
  });
});
