// show a message to the user if comunication is lost
import "src/decidim/elections/broken_promises_handler";

import {
  TallyComponent,
  IdentificationKeys,
  MessageIdentifier,
  MESSAGE_RECEIVED
} from "@decidim/decidim-bulletin_board";

import { TrusteeWrapperAdapter as DummyTrusteeWrapperAdapter } from "@decidim/voting_schemes-dummy";
import { TrusteeWrapperAdapter as ElectionGuardTrusteeWrapperAdapter } from "@decidim/voting_schemes-electionguard";

$(() => {
  // UI Elements
  const $tally = $("#trustee-step");
  const trusteeStep = $tally.data("currentStep")

  if ($tally.length && trusteeStep === "tally_started") {
    const $startButton = $tally.find("#start");
    const $backButton = $tally.find("#back");

    const getStepRow = (step) => {
      return $(`#${step.replace(".", "-")}`);
    };

    const TRUSTEE_AUTHORIZATION_EXPIRATION_TIME_IN_HOURS = 2;

    // Data
    const bulletinBoardClientParams = {
      apiEndpointUrl: $tally.data("apiEndpointUrl")
    };
    const electionUniqueId = `${$tally.data("authoritySlug")}.${$tally.data(
      "electionId"
    )}`;
    const authorityPublicKeyJSON = JSON.stringify(
      $tally.data("authorityPublicKey")
    );
    const schemeName = $tally.data("schemeName");

    const trusteeContext = {
      uniqueId: $tally.data("trusteeSlug"),
      publicKeyJSON: JSON.stringify($tally.data("trusteePublicKey"))
    };
    const trusteeIdentificationKeys = new IdentificationKeys(
      trusteeContext.uniqueId,
      trusteeContext.publicKeyJSON
    );
    let currentStep = null;

    // Use the correct trustee wrapper adapter
    let trusteeWrapperAdapter = null;

    if (schemeName === "dummy") {
      trusteeWrapperAdapter = new DummyTrusteeWrapperAdapter({
        trusteeId: trusteeContext.uniqueId
      });
    } else if (schemeName === "electionguard") {
      trusteeWrapperAdapter = new ElectionGuardTrusteeWrapperAdapter({
        trusteeId: trusteeContext.uniqueId,
        workerUrl: "/assets/electionguard/webworker.js"
      });
    } else {
      throw new Error(`Voting scheme ${schemeName} not supported.`);
    }

    // Use the tally component and bind all UI events
    const component = new TallyComponent({
      authorityPublicKeyJSON,
      trusteeUniqueId: trusteeContext.uniqueId,
      trusteeIdentificationKeys,
      trusteeWrapperAdapter
    });

    const bindComponentEvents = async () => {
      await component.setupElection({
        bulletinBoardClientParams,
        electionUniqueId,
        authorizationExpirationTimestamp:
          Math.ceil(Number(new Date()) / 1000) +
          TRUSTEE_AUTHORIZATION_EXPIRATION_TIME_IN_HOURS * 3600
      });

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
        onBindStartButton(onEventTriggered) {
          $startButton.on("click", onEventTriggered);
        },
        onStart() {
          $startButton.prop("disabled", true);
        },
        onComplete() {
          const $allSteps = $(".step_status");
          $allSteps.attr("data-step-status", "completed");

          $startButton.attr("hidden", true);
          $backButton.attr("hidden", false);

          $.ajax({
            method: "PATCH",
            url: $tally.data("updateElectionStatusUrl"),
            contentType: "application/json",
            data: JSON.stringify({
              status: "tally_started"
            }),
            headers: {
              "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
            }
          });
        },
        onTrusteeNeedsToBeRestored() {
          window.Decidim.currentDialogs["show-restore-modal"].open()
        },
        onBindRestoreButton(onEventTriggered) {
          $("#restore-button-input").on("change", onEventTriggered);
        },
        onRestore() {
          window.Decidim.currentDialogs["show-restore-modal"].close()
        }
      });
      $startButton.prop("disabled", false);
    };

    trusteeIdentificationKeys.present(async (exists) => {
      if (exists) {
        await bindComponentEvents();
      }
    });
  }
});
