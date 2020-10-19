/* eslint-disable require-jsdoc, prefer-template, func-style, id-length, no-use-before-define, init-declarations, no-invalid-this */
/* eslint no-unused-vars: ["error", { "args": "none" }] */

// = require ./identification_keys

$(() => {

  function identificationKeys() {
    const $trustee_zone = $(".trustee_zone");
    const $form = $("form", $trustee_zone);
    const $trustee_id = $("#trustee_id", $form);
    const $trustee_public_key = $("#trustee_public_key", $form);

    window.trusteeIdentificationKeys = new Decidim.IdentificationKeys(`trustee-${$trustee_id.val()}`, $trustee_public_key.val());
    if (!trusteeIdentificationKeys.browserSupport) {
      $("#not_supported_browser").addClass("visible");
      return;
    }

    const $submit = $("#submit_identification_keys");
    const $generate = $("#generate_identification_keys");
    const $upload = $("#upload_identification_keys");

    $("button", $generate).click((event) => {
      trusteeIdentificationKeys.generate().then((event) => {
        $trustee_public_key.val(JSON.stringify(trusteeIdentificationKeys.publicKey));
        $submit.addClass("visible");
      });
    });

    $("button.hollow", $submit).click((event) => {
      $trustee_public_key.val("");
      $submit.removeClass("visible");
    });

    $("button", $upload).click((event) => {
      trusteeIdentificationKeys.upload().then((event) => {
        $upload.addClass("hide");
      }).catch((event) => {
        alert($upload.data(event));
      });
    })

    trusteeIdentificationKeys.present((result) => {
      $upload.toggleClass("hide", result);
    });
  }

  $(document).ready((event) => {
    identificationKeys()
  })
})
