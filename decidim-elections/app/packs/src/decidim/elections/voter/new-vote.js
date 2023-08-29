/* eslint-disable no-inner-declarations */
/* eslint-disable require-jsdoc */
/* eslint-disable func-style */
/* eslint-disable no-console */
import VoteQuestionsComponent from "src/decidim/elections/voter/vote_questions.component";

$(async () => {
  // UI Elements
  const $voteWrapper = $("#vote-wrapper");

  if ($voteWrapper.length) {
    const $ballotHash = $voteWrapper.find("#ballot-hash");
    const ballotStyleId = $voteWrapper.data("ballotStyleId");
    const isPreview = $voteWrapper.data("previewMode");

    // Use the questions component
    const questionsComponent = new VoteQuestionsComponent($voteWrapper);
    questionsComponent.init();

    // Activates the events associated to the forms after show a new step
    $(document).on("on:toggle", () => questionsComponent.init());

    async function setup(component) {
      // Get the vote component and bind it to all UI events
      const voteComponent = component($voteWrapper);

      try {
        await voteComponent.bindEvents({
          onBindEncryptButton(onEventTriggered) {
            $("[id='next-encrypting']").on("click", onEventTriggered);
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
            $voteWrapper.find("#step-encrypting").attr("hidden", true);
            $ballotHash.text(encryptedDataHash);

            // show the next step
            $voteWrapper.find("#step-ballot_decision").attr("hidden", false);
            // simulates a toggle click, in order to update the wizard step
            document.dispatchEvent(new Event("on:toggle"));

            const $form = $("form.new_vote");
            $("#vote_encrypted_data", $form).val(encryptedData);
            $("#vote_encrypted_data_hash", $form).val(encryptedDataHash);
          },
          onBindAuditBallotButton(onEventTriggered) {
            $("#audit_ballot").on("click", onEventTriggered);
          },
          onBindCastBallotButton(onEventTriggered) {
            $("#cast_ballot").on("click", onEventTriggered);
          },
          onAuditBallot(auditedData, auditedDataFileName) {
            const vote = JSON.stringify(auditedData);
            const link = document.createElement("a");
            $voteWrapper.find("#cast_ballot").attr("hidden", true);
            $voteWrapper.find("#back").attr("hidden", false);
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
            $("#cast_ballot").prop("disabled", true);
          },
          onCastComplete() {
            console.log("Cast completed");
          },
          onInvalid() {
            console.log("Something went wrong.");
          }
        });
      } catch (error) {
        console.error(error);
        questionsComponent.errored();
      }
    }

    if (isPreview) {
      import("./setup-preview").then(({ default: module }) => setup(module))
    } else {
      import("./setup-vote").then(({ default: module }) => setup(module))
    }
  }
});
