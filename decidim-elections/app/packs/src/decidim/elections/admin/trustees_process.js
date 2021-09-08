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

  const missingTrusteesAllowed =
    $trusteesProcess.data("missingTrusteesAllowed") || 0;
  const missingTrusteeUrl = $trusteesProcess.data("missingTrusteeUrl");

  let missingTrustees = 0;
  let allowReportMissing = false;

  if (missingTrusteesAllowed > 0) {
    $checkingTrustees.each((_index, trustee) => {
      const $trustee = $(trustee);
      const trusteeId = $trustee.data("trusteeId");
      const trusteeSlug = $trustee.data("trusteeSlug");

      const $reportMissingTrustee = $trustee.find(".js-report-missing-trustee");
      $reportMissingTrustee.on("click", (event) => {
        event.preventDefault();
        if (allowReportMissing && !(trusteeSlug in trusteesStatuses)) {
          trusteesStatuses[trusteeSlug] = false;
          $(".js-report-missing-trustee").addClass("hide");
          $.ajax({
            url: missingTrusteeUrl,
            method: "PATCH",
            contentType: "application/json",
            data: JSON.stringify({
              trustee_id: trusteeId
            }), // eslint-disable-line camelcase
            headers: {
              "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
            }
          });
        }
      });
    });
  }

  const checkTrusteesActivity = async () => {
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

    missingTrustees = Object.values(trusteesStatuses).filter(
      (present) => !present
    ).length;
    allowReportMissing = missingTrustees < missingTrusteesAllowed;

    if (
      Object.keys(trusteesStatuses).length === $checkingTrustees.length &&
      missingTrustees <= missingTrusteesAllowed
    ) {
      window.location.reload();
      return;
    }

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
      } else {
        if (allowReportMissing) {
          $trustee.find(".js-report-missing-trustee").removeClass("hide");
        }
      }
    });
  };

  await checkTrusteesActivity();
  setInterval(checkTrusteesActivity, WAIT_TIME_MS);
});
