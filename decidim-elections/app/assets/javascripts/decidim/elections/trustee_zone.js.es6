/* eslint-disable require-jsdoc, no-alert, func-style */

// = require ./identification_keys

window.Decidim = window.Decidim || {};

$(() => {
  function identificationKeys() {
    const $form = $(".trustee_zone form");
    const $trusteeId = $("#trustee_id", $form);
    const $trusteePublicKey = $("#trustee_public_key", $form);

    window.trusteeIdentificationKeys = new window.Decidim.IdentificationKeys(`trustee-${$trusteeId.val()}`, $trusteePublicKey.val());
    if (!window.trusteeIdentificationKeys.browserSupport) {
      $("#not_supported_browser").addClass("visible");
      return;
    }

    const $submit = $("#submit_identification_keys");
    const $generate = $("#generate_identification_keys");
    const $upload = $("#upload_identification_keys");

    $("button", $generate).click(() => {
      window.trusteeIdentificationKeys.generate().then(() => {
        $trusteePublicKey.val(JSON.stringify(window.trusteeIdentificationKeys.publicKey));
        $submit.addClass("visible");
      });
    });

    $("button.hollow", $submit).click(() => {
      $trusteePublicKey.val("");
      $submit.removeClass("visible");
    });

    $("button", $upload).click(() => {
      window.trusteeIdentificationKeys.upload().then(() => {
        $upload.addClass("hide");
      }).catch((errorMessage) => {
        alert($upload.data(errorMessage));
      });
    })

    window.trusteeIdentificationKeys.present((result) => {
      $upload.toggleClass("hide", result);
    });
  }

  $(document).ready(() => {
    identificationKeys()
  })
})
