// show a message to the user if comunication is lost
import "src/decidim/elections/error_handler";
import {
  Client,
  Election,
  MessageParser
} from "@decidim/decidim-bulletin_board";

const WAIT_TIME_MS = 10 * 1_000;

$(async () => {
  const $trusteesProcess = $("#trustees_process");
  const $checkingTrustees = $trusteesProcess.find(".trustee");
  const electionUniqueId = $trusteesProcess.data("electionUniqueId");
  const processType = $trusteesProcess.data("processType");
  const bulletinBoardClient = new Client({
    apiEndpointUrl: $trusteesProcess.data("apiEndpointUrl")
  });
  const election = new Election({
    uniqueId: electionUniqueId,
    bulletinBoardClient,
    typesFilter: ["create_election", processType]
  });

  const authorityPublicKeyJSON = JSON.stringify(
    $trusteesProcess.data("authorityPublicKey")
  );
  const parser = new MessageParser({ authorityPublicKeyJSON });
  const trusteesStatuses = {};
  let lastMessageIndex = 0;

  const missingTrusteesAllowed = $trusteesProcess.data("missingTrusteesAllowed") || 0;
  const checkPendingActionPath = $trusteesProcess.data("checkPendingActionPath");

  // Fix buttons formaction, that is not working properly
  const $form = $("form.step");
  $form.find("button").on("click", (event) => {
    $form.attr("action", $(event.currentTarget).attr("formaction"));
    $form.trigger("submit");
  });

  const updateTrusteesStatuses = async () => {
    await election.getLogEntries();

    for (
      ;
      lastMessageIndex < election.logEntries.length;
      lastMessageIndex += 1
    ) {
      const { messageIdentifier, decodedData } = await parser.parse(
        election.logEntries[lastMessageIndex]
      );

      if (messageIdentifier.author.type === "t") {
        trusteesStatuses[messageIdentifier.author.id] = true;
      } else if (
        messageIdentifier.type === "tally" &&
        messageIdentifier.subtype === "missing_trustee" &&
        !(decodedData.trustee_id in trusteesStatuses)
      ) {
        trusteesStatuses[decodedData.trustee_id] = false;
      }
    }
  }

  const checkPendingAction = async () => {
    if (!checkPendingActionPath) {
      return false
    }

    try {
      const response = await $.ajax({
        url: checkPendingActionPath,
        method: "PATCH",
        contentType: "application/json",
        headers: {
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      })

      return response && response.status === "pending";
    } catch (err) {
      return true;
    }
  }

  const checkTrusteesActivity = async () => {
    await updateTrusteesStatuses();
    const pendingAction = await checkPendingAction();
    const missingTrustees = Object.values(trusteesStatuses).filter(
      (present) => !present
    ).length;
    const allowReportMissing = missingTrustees < missingTrusteesAllowed;

    $checkingTrustees.each((_index, trustee) => {
      const $trustee = $(trustee);
      const trusteeSlug = $trustee.data("trusteeSlug");

      if (trusteeSlug in trusteesStatuses) {
        if (missingTrusteesAllowed > 0) {
          $trustee.find(".js-report-missing-trustee").addClass("hide");
        }
        $trustee.removeClass("loading");
        $trustee.find(".loading").hide();
        if (trusteesStatuses[trusteeSlug]) {
          $trustee.find(".active").removeClass("hide");
          $trustee.find(".missing").addClass("hide");
        } else {
          $trustee.find(".missing").removeClass("hide");
        }
      } else if (allowReportMissing && !pendingAction) {
        $trustee.find(".js-report-missing-trustee").removeClass("hide");
      }
    });

    if (
      Object.keys(trusteesStatuses).length === $checkingTrustees.length &&
      missingTrustees <= missingTrusteesAllowed && !pendingAction
    ) {
      $(".js-continue-link").removeClass("disabled");
    } else {
      setTimeout(checkTrusteesActivity, WAIT_TIME_MS);
    }
  };

  await checkTrusteesActivity();
});
