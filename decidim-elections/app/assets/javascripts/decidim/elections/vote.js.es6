/* eslint-disable require-jsdoc, prefer-template, func-style, id-length, no-use-before-define, init-declarations, no-invalid-this */
/* eslint no-unused-vars: ["error", { "args": "none" }] */
// = require decidim/bulletin_board/decidim-bulletin_board

$(() => {
  const { Voter, Client } = decidimBulletinBoard;
  const $voteWrapper = $(".vote-wrapper");
  const $continueButton = $voteWrapper.find("a.focus__next");
  const $confirmButton = $voteWrapper.find("a.focus__next.confirm");
  const $continueSpan = $voteWrapper.find("span.disabled-continue");

  let $answerCounter = 0;
  let $currentStep,
      $currentStepMaxSelection = "";
  let $formData = $voteWrapper.find(".answer_input");

  // Updates the status of the vote
  const updateVoteStatus = (id) => {
    $.ajax({
      method: "PATCH",
      url: $voteWrapper.data("updateVoteStatusUrl"),
      contentType: "application/json",
      data: JSON.stringify({ vote_id: id }), // eslint-disable-line camelcase
      headers: {
        "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
      }
    });
  }

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
    $currentStep = $voteWrapper.find(".focus__step:visible")
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
    return formData.serializeArray().reduce((acc, {name, value}) => {
      if (!acc[name]) {
        acc[name] = [];
      }
      acc[name] = [...acc[name], value];
      return acc;
    }, {"ballot_style": "unique"});
  }

  // confirm vote
  $(".button.confirm").on("click", (event) => {
    const boothMode = $(event.currentTarget).data("booth-mode");
    const formData = getFormData($formData);
    castVote(boothMode, formData)
  });

  const isPreview = $voteWrapper.data("booth-mode") === "preview";

  function simulatePreviewDelay() {
    return new Promise((resolve) => {
      setTimeout(resolve, 500);
    })
  }

  // cast vote
  function castVote(_boothMode, formData) {
    const bulletinBoardClient = new Client({
      apiEndpointUrl: $voteWrapper.data("apiEndpointUrl"),
      wsEndpointUrl: $voteWrapper.data("websocketUrl")
    });

    const voter = new Voter({
      id: $voteWrapper.data("voterId"),
      bulletinBoardClient,
      electionContext: {
        id: $voteWrapper.data("electionUniqueId")
      }
    });

    let encryptedVoteHashToVerify = null;

    voter.encrypt(formData).then((encryptedVoteAsJSON) => {
      return crypto.subtle.digest("SHA-256", new TextEncoder().encode(encryptedVoteAsJSON)).then((hashBuffer) => {
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");

        return {
          encryptedVote: encryptedVoteAsJSON,
          encryptedVoteHash: hashHex
        };
      })
    }).then(({ encryptedVote, encryptedVoteHash}) => {
      encryptedVoteHashToVerify = encryptedVoteHash;

      return $.ajax({
        method: "POST",
        url: $voteWrapper.data("castVoteUrl"),
        contentType: "application/json",
        data: JSON.stringify({ encrypted_vote: encryptedVote, encrypted_vote_hash: encryptedVoteHash }), // eslint-disable-line camelcase
        headers: {
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      })
    }).then(() => {
      const $messageId = $voteWrapper.find(".vote-confirmed-result").data("messageId");

      if (isPreview) {
        return simulatePreviewDelay()
      }

      return voter.waitForPendingMessageToBeProcessed($messageId)
    }).then((pendingMessage) => {
      const $voteId = $voteWrapper.find(".vote-confirmed-result").data("voteId");

      if (isPreview) {
        return simulatePreviewDelay()
      }

      updateVoteStatus($voteId)

      if (pendingMessage.status === "rejected") {
        return null
      }

      $voteWrapper.find("#encrypting").addClass("hide");
      $voteWrapper.find("#confirmed_page").removeClass("hide");
      $voteWrapper.find(".vote-confirmed-result").hide();
      window.confirmed = true;

      return voter.verifyVote(encryptedVoteHashToVerify);
    }).then((logEntry) => {
      if (logEntry) {
        $voteWrapper.find(".vote-confirmed-processing").hide();
        $voteWrapper.find(".vote-confirmed-result").show();
      } else {
        const $error = $voteWrapper.find(".vote-confirmed-result").data("error");
        alert($error); // eslint-disable-line no-alert
      }
    })
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
