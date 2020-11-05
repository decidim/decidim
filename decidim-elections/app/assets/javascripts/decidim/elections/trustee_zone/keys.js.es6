// = require decidim-bulletin_board
// = require ../identification_keys

$(() => { 
  // TODO: hardcoded stuff
  const $keyCeremony = $('.key-ceremony');
  const $startButton = $keyCeremony.find(".start");

  const trusteeContext = {
    id: $keyCeremony.data('trusteeId'),
    publicKeyJSON: JSON.stringify($keyCeremony.data('trusteePublicKey'))
  };
  const identificationKeys = new window.Decidim.IdentificationKeys(`trustee-${trusteeContext.id}`, trusteeContext.publicKeyJSON);

  identificationKeys.present(async (exists) => {
    if (exists) {
      const { Client, KeyCeremony } = decidimBulletinBoard;
  
      // TODO: hardcoded stuff
      const bulletinBoardClient = new Client({
        apiEndpointUrl: "http://localhost:8000/api",
        wsEndpointUrl: "ws://localhost:8000/cable",
        headers: {
          Authorization: `${$keyCeremony.data('trusteeUniqueId')}`
        }
      });
        
      const keyCeremony = new KeyCeremony({
        bulletinBoardClient,
        electionContext: {
          id: `decidim-test-authority.${$keyCeremony.data('electionId')}`,
          currentTrusteeContext: {
            id: `trustee-${trusteeContext.id}`,
            identificationKeys
          },
        }
      })
    
      await keyCeremony.setup();

      $startButton.on("click", async () => {
        const result = await keyCeremony.run();
        console.log("RESULT", result);
      })

      keyCeremony.events.subscribe((event) => {
        console.log(event);
      })
    }
  });
})

