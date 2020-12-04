// = require decidim-bulletin_board
// = require ../identification_keys

$(() => { 
  // TODO: hardcoded stuff
  const $keyCeremony = $(".key-ceremony");
  const $startButton = $keyCeremony.find(".start");
  const $keyGeneration = $keyCeremony.find("#key_generation");
  const $keyPublishing = $keyCeremony.find("#key_publishing");
  const $jointKey = $keyCeremony.find("#joint_key");
  const $backupElectionKeys = $keyCeremony.find(".backup-election-keys")
  const $generateElectionKeys = $keyCeremony.find(".election-key-generation")
  
  const trusteeContext = {
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
          id: `${$keyCeremony.data("authorityName")}.${$keyCeremony.data("electionId")}`,
          currentTrusteeContext: {
            id: `trustee-${trusteeContext.id}`,
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

        if (result) {
          $jointKey.find(".pending").addClass("hide")
          $jointKey.find(".processing").addClass("hide")
          $jointKey.find(".completed").removeClass("hide")
          $startButton.addClass("hide");
          $generateElectionKeys.addClass("hide");
          $backupElectionKeys.removeClass("hide")
        }
      })

      keyCeremony.events.subscribe((event) => {   
        if (event.type === "[Message] Received" && event.message.logType === "create_election") {
          $keyGeneration.find(".processing").addClass("hide")
          $keyGeneration.find(".completed").removeClass("hide")
          $keyPublishing.find(".pending").addClass("hide")
          $keyPublishing.find(".processing").removeClass("hide")
        }
        if (event.type === "[Message] Processed" && event.message.logType === "key_ceremony") {
          $keyPublishing.find(".processing").addClass("hide")
          $keyPublishing.find(".completed").removeClass("hide")
          $jointKey.find(".pending").addClass("hide")
          $jointKey.find(".processing").removeClass("hide")
        }
      })
    }
  });
})

