/* eslint-disable no-console */
// = require decidim/bulletin_board/decidim-bulletin_board
// = require decidim/bulletin_board/dummy-voting-scheme
// = require decidim/bulletin_board/election_guard-voting-scheme

// Note: these gems will be moved to the application in the next release
// = require voting_schemes/dummy/dummy
// = require voting_schemes/electionguard/electionguard

// = require ./vote_questions.component

$(async () => {
  const { VoteQuestionsComponent } = window.Decidim;
  const { VoteComponent } = window.decidimBulletinBoard;
  const {
    VoterWrapperAdapter: DummyVoterWrapperAdapter,
  } = window.dummyVotingScheme;
  const {
    VoterWrapperAdapter: ElectionGuardVoterWrapperAdapter,
  } = window.electionGuardVotingScheme;

  // UI Elements
  const $voteWrapper = $(".vote-wrapper");
  const $ballotHash = $voteWrapper.find(".ballot-hash");

  // Data
  const bulletinBoardClientParams = {
    apiEndpointUrl: $voteWrapper.data("apiEndpointUrl"),
  };
  const electionUniqueId = $voteWrapper.data("electionUniqueId");
  const authorityPublicKeyJSON = JSON.stringify(
    $voteWrapper.data("authorityPublicKey")
  );
  const voterUniqueId = $voteWrapper.data("voterId");
  const schemeName = $voteWrapper.data("schemeName");

  // Use the questions component
  const questionsComponent = new VoteQuestionsComponent($voteWrapper);
  questionsComponent.init();
  $(document).on("on.zf.toggler", () => {
    // continue and back btn
    questionsComponent.init();
  });

  // Use the correct voter wrapper adapter
  let voterWrapperAdapter = null;

  if (schemeName === "dummy") {
    voterWrapperAdapter = new DummyVoterWrapperAdapter({
      voterId: voterUniqueId,
    });
  } else if (schemeName === "electionguard") {
    voterWrapperAdapter = new ElectionGuardVoterWrapperAdapter({
      voterId: voterUniqueId,
      workerUrl: "/assets/electionguard/webworker.js",
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
    voterWrapperAdapter,
  });

  await voteComponent.bindEvents({
    onBindEncryptButton(onEventTriggered) {
      $(".button.confirm").on("click", onEventTriggered);
    },
    onStart() {},
    onVoteEncryption(validVoteFn) {
      const getFormData = (formData) => {
        return formData.serializeArray().reduce((acc, { name, value }) => {
          if (!acc[name]) {
            acc[name] = [];
          }
          acc[name] = [...acc[name], `${name}_${value}`];
          return acc;
        }, {});
      };
      const formData = getFormData($voteWrapper.find(".answer_input"));
      validVoteFn(formData);
    },
    castOrAuditBallot({ encryptedData, encryptedDataHash }) {
      $voteWrapper.find("#encrypting").addClass("hide");
      $ballotHash.text(`Your ballot identifier is: ${encryptedDataHash}`);
      $voteWrapper.find("#ballot_decision").removeClass("hide");

      const $form = $("form.new_vote");
      $("#vote_encrypted_data", $form).val(encryptedData);
      $("#vote_encrypted_data_hash", $form).val(encryptedDataHash);
    },
    onBindAuditBallotButton(onEventTriggered) {
      $(".audit_ballot").on("click", onEventTriggered);
    },
    onBindCastBallotButton(onEventTriggered) {
      $(".cast_ballot").on("click", onEventTriggered);
    },
    onAuditBallot(auditedData, auditedDataFileName) {
      const vote = JSON.stringify(auditedData);
      const link = document.createElement("a");
      $voteWrapper.find(".button.cast_ballot").addClass("hide");
      $voteWrapper.find(".button.back").removeClass("hide");
      questionsComponent.voteCasted = true;

      link.setAttribute("href", `data:text/plain;charset=utf-8,${vote}`);
      link.setAttribute("download", auditedDataFileName);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },
    onAuditComplete() {
      console.log("AUDIT COMPLETED");
    },
    onCastBallot() {
      questionsComponent.voteCasted = true;
      $(".cast_ballot").prop("disabled", true);
    },
    onCastComplete() {
      console.log("Cast completed");
    },
    onInvalid() {
      console.log("Something went wrong.");
    },
  });
});
