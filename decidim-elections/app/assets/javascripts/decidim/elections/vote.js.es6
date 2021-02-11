// = require decidim/bulletin_board/decidim-bulletin_board
// = require ./vote_questions.component

$(async () => {
  const { VoteQuestionsComponent } = window.Decidim;
  const { VoteComponent } = window.decidimBulletinBoard;

  // UI Elements
  const $voteWrapper = $(".vote-wrapper");

  // Data
  const bulletinBoardClientParams = {
    apiEndpointUrl: $voteWrapper.data("apiEndpointUrl")
  };
  const electionUniqueId = $voteWrapper.data("electionUniqueId");
  const voterUniqueId = $voteWrapper.data("voterId");

  // Use the questions component
  const questionsComponent = new VoteQuestionsComponent($voteWrapper);
  questionsComponent.init();
  $(document).on("on.zf.toggler", () => {
    // continue and back btn
    questionsComponent.init()
  });

  // Use the voter component and bind all UI events
  const voteComponent = new VoteComponent({
    bulletinBoardClientParams,
    electionUniqueId,
    voterUniqueId
  });

  await voteComponent.bindEvents({
    onSetup() {},
    onBindStartButton(onEventTriggered) {
      $(".button.confirm").on("click", onEventTriggered);
    },
    onStart() {},
    onVoteValidation(validVoteFn) {
      const getFormData = (formData) => {
        return formData.serializeArray().reduce((acc, {name, value}) => {
          if (!acc[name]) {
            acc[name] = [];
          }
          acc[name] = [...acc[name], value];
          return acc;
        }, {"ballot_style": "unique"});
      }

      const formData = getFormData($voteWrapper.find(".answer_input"));
      validVoteFn(formData);
    },
    async onVoteEncrypted({encryptedVote, encryptedVoteHash}) {
      const simulatePreviewDelay = () => {
        return new Promise((resolve) => setTimeout(resolve, 500));
      };
      const isPreview = $voteWrapper.data("booth-mode") === "preview";

      await $.ajax({
        method: "POST",
        url: $voteWrapper.data("castVoteUrl"),
        contentType: "application/json",
        data: JSON.stringify({ encrypted_vote: encryptedVote, encrypted_vote_hash: encryptedVoteHash }), // eslint-disable-line camelcase
        headers: {
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      });

      if (isPreview) {
        await simulatePreviewDelay();
        $voteWrapper.find("#encrypting").addClass("hide");
        $voteWrapper.find("#confirmed_page").removeClass("hide");
        $voteWrapper.find(".vote-confirmed-result").hide();
        questionsComponent.voteCasted = true;
        await simulatePreviewDelay()
        $voteWrapper.find(".vote-confirmed-processing").hide();
        $voteWrapper.find(".vote-confirmed-result").show();
      } else {
        const messageId = $voteWrapper.find(".vote-confirmed-result").data("messageId");
        const voteId = $voteWrapper.find(".vote-confirmed-result").data("voteId");
        const pendingMessage = await voteComponent.bulletinBoardClient.waitForPendingMessageToBeProcessed(messageId);

        await $.ajax({
          method: "PATCH",
          url: $voteWrapper.data("updateVoteStatusUrl"),
          contentType: "application/json",
          data: JSON.stringify({ vote_id: voteId }), // eslint-disable-line camelcase
          headers: {
            "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
          }
        });

        if (pendingMessage.status === "accepted") {
          $voteWrapper.find("#encrypting").addClass("hide");
          $voteWrapper.find("#confirmed_page").removeClass("hide");
          $voteWrapper.find(".vote-confirmed-result").hide();
          questionsComponent.voteCasted = true;

          const logEntry = await voteComponent.voter.verifyVote(encryptedVoteHash);

          if (logEntry) {
            $voteWrapper.find(".vote-confirmed-processing").hide();
            $voteWrapper.find(".vote-confirmed-result").show();
          } else {
            const $error = $voteWrapper.find(".vote-confirmed-result").data("error");
            alert($error); // eslint-disable-line no-alert
          }
        } else {
          const $error = $voteWrapper.find(".vote-confirmed-result").data("error");
          alert($error); // eslint-disable-line no-alert
        }
      }
    },
    onComplete() {},
    onInvalid() {}
  });
});
