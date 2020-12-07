// = require decidim-bulletin_board
// = require ../identification_keys
/**
 * Generate and backup election keys.
 */

$(() => { 
  const $keyCeremony = $(".key-ceremony");
  const $startButton = $keyCeremony.find(".start");
  const $downloadButton = $keyCeremony.find(".download-election-keys")
  const $keyGeneration = $keyCeremony.find("#key_generation");
  const $keyPublishing = $keyCeremony.find("#key_publishing");
  const $jointKey = $keyCeremony.find("#joint_key");
  const $backupElectionKeys = $keyCeremony.find(".backup-election-keys");
  const $generateElectionKeys = $keyCeremony.find(".election-key-generation");
  const $electionKeyIdentifier = `${$keyCeremony.data("authorityName")}_election_key_backup`;
  let $electionKeys = "";

  const trusteeContext = {
    uniqueId: $keyCeremony.data("trusteeUniqueId"),
    id: $keyCeremony.data("trusteeId"),
    publicKeyJSON: JSON.stringify($keyCeremony.data("trusteePublicKey"))
  };
  const identificationKeys = new window.Decidim.IdentificationKeys(`trustee-${trusteeContext.id}`, trusteeContext.publicKeyJSON);

  identificationKeys.present(async (exists) => {
    if (exists) {
      const { Client, KeyCeremony } = decidimBulletinBoard;

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
          authorityName: $keyCeremony.data("authorityName"),
          id: `${$keyCeremony.data("authorityName")}.${$keyCeremony.data("electionId")}`,
          currentTrusteeContext: {
            id: trusteeContext.uniqueId,
            identificationKeys
          }
        }
      })

      await keyCeremony.setup();

      $startButton.on("click", async () => {
        $keyGeneration.find(".pending").addClass("hide")
        $keyGeneration.find(".processing").removeClass("hide")
        $startButton.addClass("disabled");
        const result = await keyCeremony.run();
        console.log("RESULT", result)
        if (result) {
          $jointKey.find(".pending").addClass("hide")
          $jointKey.find(".processing").addClass("hide")
          $jointKey.find(".completed").removeClass("hide")
          $startButton.addClass("hide");
          $generateElectionKeys.addClass("hide");
          $backupElectionKeys.removeClass("hide")
          $electionKeys = result.joint_election_key
        }
      })

      $downloadButton.on("click", async () => {
        return new Promise((resolve, reject) => {
          try {
            let element = document.createElement("a");
            element.setAttribute("href", `data:text/plain;charset=utf-8,${$electionKeys}`);
            element.setAttribute("download", `${$electionKeyIdentifier}.txt`);
            element.style.display = "none";
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);
            return resolve();
          } catch (error) {
            return reject();
          }
        })
      })

      keyCeremony.events.subscribe((event) => {   
        if (event.type === "[Message] Received" && event.message.message_id.includes("create_election")) {
          $keyGeneration.find(".processing").addClass("hide")
          $keyGeneration.find(".completed").removeClass("hide")
          $keyPublishing.find(".pending").addClass("hide")
          $keyPublishing.find(".processing").removeClass("hide")
        }
        if (event.type === "[Message] Processed" && event.message.message_id.includes("key_ceremony")) {
          $keyPublishing.find(".processing").addClass("hide")
          $keyPublishing.find(".completed").removeClass("hide")
          $jointKey.find(".pending").addClass("hide")
          $jointKey.find(".processing").removeClass("hide")
        }
      })
    }
  });
})
