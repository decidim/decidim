/* eslint-disable no-alert */

// = require decidim-bulletin_board
// = require ../identification_keys

/**
 * This file is responsible to generate election keys,
 * create a backup of keys for the trustee and
 * update the election bulletin board status
 */

$(() => {
  const $keyCeremony = $(".key-ceremony");
  const $startButton = $keyCeremony.find(".start");
  const $backButton = $keyCeremony.find(".back");
  const $backupButton = $(".download-election-keys");
  const $keyGeneration = $keyCeremony.find("#create_election");
  const $keyPublishing = $keyCeremony.find("#key_ceremony\\.step_1");

  const $jointKey = $keyCeremony.find("#key_ceremony\\.joint_election_key");
  const $electionKeyIdentifier = `${$keyCeremony.data(
    "authorityName"
  )}_election_key_backup`;

  let $wrapperStatus = "";

  const trusteeContext = {
    uniqueId: $keyCeremony.data("trusteeUniqueId"),
    id: $keyCeremony.data("trusteeId"),
    publicKeyJSON: JSON.stringify($keyCeremony.data("trusteePublicKey"))
  };
  const identificationKeys = new window.Decidim.IdentificationKeys(
    `trustee-${trusteeContext.id}`,
    trusteeContext.publicKeyJSON
  );

  // updates the BulletinBoard Election Status
  const updateElectionStatus = () => {
    $.ajax({
      method: "PUT",
      url: $keyCeremony.data("updateElectionStatusUrl"),
      contentType: "application/json",
      headers: {
        "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
      }
    });
  };

  const completeProcess = () => {
    $jointKey.find(".pending").addClass("hide");
    $jointKey.find(".processing").removeClass("hide");
    $jointKey.find(".processing").addClass("hide");
    $jointKey.find(".completed").removeClass("hide");
    $startButton.addClass("hide");
    $backButton.removeClass("hide");
    updateElectionStatus();
  };

  // generates the keys
  identificationKeys.present(async (exists) => {
    if (exists) {
      const {
        Client,
        KeyCeremony,
        MessageIdentifier
      } = window.decidimBulletinBoard;

      const bulletinBoardClient = new Client({
        apiEndpointUrl: $keyCeremony.data("apiEndpointUrl"),
        wsEndpointUrl: $keyCeremony.data("websocketUrl"),
        headers: {
          Authorization: $keyCeremony.data("trusteeUniqueId")
        }
      });

      const keyCeremony = new KeyCeremony({
        bulletinBoardClient,
        electionContext: {
          id: `${$keyCeremony.data("authorityName")}.${$keyCeremony.data(
            "electionId"
          )}`,
          currentTrusteeContext: {
            id: trusteeContext.uniqueId,
            identificationKeys
          }
        }
      });

      await keyCeremony.setup();

      $startButton.on("click", async () => {
        $keyGeneration.find(".pending").addClass("hide");
        $keyGeneration.find(".processing").removeClass("hide");
        $startButton.addClass("disabled");
        keyCeremony.run();
      });

      $backupButton.on("click", async () => {
        return new Promise((resolve, reject) => {
          try {
            let element = document.createElement("a");
            element.setAttribute(
              "href",
              `data:text/plain;charset=utf-8,${$wrapperStatus}`
            );
            element.setAttribute("download", `${$electionKeyIdentifier}.txt`);
            element.style.display = "none";
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);
            keyCeremony.run();
            return resolve();
          } catch (error) {
            return reject();
          }
        });
      });

      keyCeremony.events.subscribe((event) => {
        let messageIdentifier = MessageIdentifier.parse(
          event.message.messageId
        );

        if (
          event.type === "[Message] Received" &&
          messageIdentifier.typeSubtype === "create_election"
        ) {
          $keyGeneration.find(".processing").addClass("hide");
          $keyGeneration.find(".completed").removeClass("hide");
          $keyPublishing.find(".pending").addClass("hide");
          $keyPublishing.find(".processing").removeClass("hide");
        }

        if (event.type === "[Message] Processed") {
          if (event.result) {
            if (event.result.save) {
              $wrapperStatus = keyCeremony.backup();
              $("#backup-modal").
                get(0).
                click();
            }

            if (event.result.done) {
              completeProcess();
            }
          }

          if (messageIdentifier.typeSubtype === "key_ceremony.step_1") {
            $keyPublishing.find(".processing").addClass("hide");
            $keyPublishing.find(".completed").removeClass("hide");
          }
        }
      });
    }
  });
});
