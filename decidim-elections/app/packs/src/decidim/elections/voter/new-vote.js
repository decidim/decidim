/* eslint-disable no-console */
import VoteQuestionsComponent from "src/decidim/elections/voter/vote_questions.component";
// The voting component might come from set-preview.js or setup-vote.js, it depends if it's a preview
// so in the view template we load the component and attach it to window
const { setupVoteComponent } = window.Decidim;

$(async () => {
  // UI Elements
  const $voteWrapper = $(".vote-wrapper");
  const $ballotHash = $voteWrapper.find(".ballot-hash");
  const ballotStyleId = $voteWrapper.data("ballotStyleId");

  // Use the questions component
  const questionsComponent = new VoteQuestionsComponent($voteWrapper);
  questionsComponent.init();
  $(document).on("on.zf.toggler", () => {
    // continue and back btn
    questionsComponent.init();
  });

  // Get the vote component and bind it to all UI events
  const voteComponent = setupVoteComponent($voteWrapper);
  try {
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
        validVoteFn(formData, ballotStyleId);
      },
      castOrAuditBallot({ encryptedData, encryptedDataHash }) {
        $voteWrapper.find("#encrypting").addClass("hide");
        $ballotHash.text(encryptedDataHash);
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
        console.log("Audit completed");
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
      }
    });
  } catch (e) {
    console.error(e);
    questionsComponent.errored();
  }
});
