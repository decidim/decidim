// = require decidim/bulletin_board/decidim-bulletin_board

$(() => {
  const { TallyComponent, IdentificationKeys, MessageIdentifier, MESSAGE_RECEIVED } = window.decidimBulletinBoard;

  // UI Elements
  const $tally = $(".tally");
  const $startButton = $tally.find(".start");
  const getStepRow = (step) => {
    return $(`#${step.replace(".", "-")}`);
  };
  const $restoreModal = $("#show-restore-modal");
  const $restoreButton = $restoreModal.find(".upload-election-keys");
  const $backButton = $tally.find(".back");

  // Data
  const bulletinBoardClientParams = {
    apiEndpointUrl: $tally.data("apiEndpointUrl")
  };
  const electionUniqueId = `${$tally.data("authorityUniqueId")}.${$tally.data("electionId")}`
  const trusteeContext = {
    uniqueId: $tally.data("trusteeUniqueId"),
    publicKeyJSON: JSON.stringify($tally.data("trusteePublicKey"))
  };
  const trusteeIdentificationKeys = new IdentificationKeys(
    trusteeContext.uniqueId,
    trusteeContext.publicKeyJSON
  );
  let currentStep = null;

  // Use the tally component and bind all UI events
  const component = new TallyComponent({
    bulletinBoardClientParams,
    electionUniqueId,
    trusteeUniqueId: trusteeContext.uniqueId,
    trusteeIdentificationKeys
  });

  const bindComponentEvents = async () => {
    await component.bindEvents({
      onEvent(event) {
        let messageIdentifier = MessageIdentifier.parse(
          event.message.messageId
        );

        if (event.type === MESSAGE_RECEIVED) {
          if (currentStep && currentStep !== messageIdentifier.typeSubtype) {
            const $previousStep = getStepRow(currentStep);
            $previousStep.attr("data-step-status", "completed");
          }
          currentStep = messageIdentifier.typeSubtype;

          const $currentStep = getStepRow(currentStep);
          if ($currentStep.data("step-status") !== "completed") {
            $currentStep.attr("data-step-status", "processing");
          }
        }
      },
      onSetup() {
        $startButton.prop("disabled", false);
      },
      onBindStartButton(onEventTriggered) {
        $startButton.on("click", onEventTriggered);
      },
      onStart() {
        $startButton.prop("disabled", true);
      },
      onComplete() {
        const $allSteps = $(".step_status");
        $allSteps.attr("data-step-status", "completed");

        $startButton.addClass("hide");
        $backButton.removeClass("hide");

        $.ajax({
          method: "PATCH",
          url: $tally.data("updateElectionStatusUrl"),
          contentType: "application/json",
          data: JSON.stringify({
            status: "tally"
          }),
          headers: {
            "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
          }
        });
      },
      onTrusteeNeedsToBeRestored() {
        $restoreModal.foundation("open");
      },
      onBindRestoreButton(onEventTriggered) {
        $restoreButton.on("change", ".restore-button-input", onEventTriggered);
      },
      onRestore() {
        $restoreModal.foundation("close");
      }
    });
  };

  trusteeIdentificationKeys.present(async (exists) => {
    if (exists) {
      await bindComponentEvents();
    }
  });
});
