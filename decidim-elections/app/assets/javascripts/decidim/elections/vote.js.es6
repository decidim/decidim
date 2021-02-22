// = require decidim/bulletin_board/decidim-bulletin_board
// = require decidim/bulletin_board/dummy-voting-scheme

// = require ./vote_questions.component

$(async () => {
  const { VoteQuestionsComponent } = window.Decidim;
  const { VoteComponent } = window.decidimBulletinBoard;
  const { VoterWrapperAdapter: DummyVoterWrapperAdapter } = window.dummyVotingScheme;

  // UI Elements
  const $voteWrapper = $(".vote-wrapper");

  // Data
  const bulletinBoardClientParams = {
    apiEndpointUrl: $voteWrapper.data("apiEndpointUrl")
  };
  const electionUniqueId = $voteWrapper.data("electionUniqueId");
  const authorityPublicKeyJSON = JSON.stringify($voteWrapper.data("authorityPublicKey"))
  const voterUniqueId = $voteWrapper.data("voterId");
  const schemeName = $voteWrapper.data("schemeName");

  // Use the questions component
  const questionsComponent = new VoteQuestionsComponent($voteWrapper);
  questionsComponent.init();
  $(document).on("on.zf.toggler", () => {
    // continue and back btn
    questionsComponent.init()
  });

  // Use the correct voter wrapper adapter
  let voterWrapperAdapter = null;

  if (schemeName === "dummy") {
    voterWrapperAdapter = new DummyVoterWrapperAdapter({
      voterId: voterUniqueId
    });
  } else {
    throw new Error(`Voting scheme ${schemeName} not supported.`);
  }

  // Use the voter component and bind all UI events
  const voteComponent = new VoteComponent({
    bulletinBoardClientParams,
    authorityPublicKeyJSON,
    electionUniqueId,
    voterUniqueId,
    voterWrapperAdapter
  });

  await voteComponent.bindEvents({
    onSetup() {},
    onBindEncryptButton(onEventTriggered) {
      $(".button.confirm").on("click", onEventTriggered);
    },
    onStart() {},
    onVoteEncryption(validVoteFn) {
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
    castOrAuditBallot(encryptedBallot) {

    },
    onBindAuditBallotButton(onEventTriggered) {

    },
    onBindCastBallotButton(onEventTriggered) {

    },
    onAuditBallot(auditedVote, auditFileName) {

    },
    onAuditComplete() {

    },
    onCastBallot({ encryptedBallot }) {
    },
    onCastComplete() {},
    onInvalid() {},
    // TODO: old event
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
    }
  });
});
