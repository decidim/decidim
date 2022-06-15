// show a message to the user if comunication is lost
import "src/decidim/elections/error_handler";

import {
  KeyCeremonyComponent,
  MessageIdentifier,
  IdentificationKeys,
  MESSAGE_RECEIVED
} from "@decidim/decidim-bulletin_board";

import { TrusteeWrapperAdapter as DummyTrusteeWrapperAdapter } from "@decidim/voting_schemes-dummy";
import { TrusteeWrapperAdapter as ElectionGuardTrusteeWrapperAdapter } from "@decidim/voting_schemes-electionguard";

/**
 * This file is responsible to generate election keys,
 * create a backup of keys for the trustee and
 * update the election bulletin board status
 */
$(() => {
  // UI Elements
  const $keyCeremony = $(".trustee-step");
  const $startButton = $keyCeremony.find(".start");
  const $backupModal = $("#show-backup-modal");
  const $backupButton = $backupModal.find(".download-election-keys");
  const $backButton = $keyCeremony.find(".back");
  const $restoreModal = $("#show-restore-modal");
  const $restoreButton = $restoreModal.find(".upload-election-keys");
  const getStepRow = (step) => {
    return $(`#${step.replace(".", "-")}`);
  };
  const TRUSTEE_AUTHORIZATION_EXPIRATION_TIME_IN_HOURS = 2;

  // Data
  const bulletinBoardClientParams = {
    apiEndpointUrl: $keyCeremony.data("apiEndpointUrl")
  };
  const electionUniqueId = `${$keyCeremony.data(
    "authoritySlug"
  )}.${$keyCeremony.data("electionId")}`;
  const authorityPublicKeyJSON = JSON.stringify(
    $keyCeremony.data("authorityPublicKey")
  );
  const schemeName = $keyCeremony.data("schemeName");

  const trusteeContext = {
    uniqueId: $keyCeremony.data("trusteeSlug"),
    publicKeyJSON: JSON.stringify($keyCeremony.data("trusteePublicKey"))
  };

  let currentStep = null;
  const trusteeIdentificationKeys = new IdentificationKeys(
    trusteeContext.uniqueId,
    trusteeContext.publicKeyJSON
  );

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

  // Use the key ceremony component and bind all UI events
  const component = new KeyCeremonyComponent({
    authorityPublicKeyJSON,
    trusteeUniqueId: trusteeContext.uniqueId,
    trusteeIdentificationKeys,
    trusteeWrapperAdapter
  });

  trusteeIdentificationKeys.present(async (exists) => {
    if (exists) {
      await component.setupElection({
        bulletinBoardClientParams,
        electionUniqueId,
        authorizationExpirationTimestamp:
          Math.ceil(Number(new Date()) / 1000) +
          TRUSTEE_AUTHORIZATION_EXPIRATION_TIME_IN_HOURS * 3600
      });

      await component.bindEvents({
        onBindRestoreButton(onEventTriggered) {
          $restoreButton.on(
            "change",
            ".restore-button-input",
            onEventTriggered
          );
        },
        onBindStartButton(onEventTriggered) {
          $startButton.on("click", onEventTriggered);
        },
        onBindBackupButton(backupData, backupFilename, onEventTriggered) {
          $backupButton.attr(
            "href",
            `data:text/plain;charset=utf-8,${backupData}`
          );
          $backupButton.attr("download", backupFilename);
          $backupButton.on("click", onEventTriggered);
        },
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
        onRestore() {
          $restoreModal.foundation("close");
        },
        onComplete() {
          const $allSteps = $(".step_status");
          $allSteps.attr("data-step-status", "completed");

          $startButton.addClass("hide");
          $backButton.removeClass("hide");

          $.ajax({
            method: "PATCH",
            url: $keyCeremony.data("updateElectionStatusUrl"),
            contentType: "application/json",
            data: JSON.stringify({
              status: "key_ceremony"
            }),
            headers: {
              "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
            }
          });
        },
        onStart() {
          $startButton.prop("disabled", true);
        },
        onTrusteeNeedsToBeRestored() {
          $restoreModal.foundation("open");
        },
        onBackupNeeded() {
          $backupModal.foundation("open");
        },
        onBackupStarted() {
          $backupModal.foundation("close");
        }
      });

      $startButton.prop("disabled", false);
    }
  });
});
