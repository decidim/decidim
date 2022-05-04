/* eslint-disable require-jsdoc, no-alert, func-style */

import { IdentificationKeys } from "@decidim/decidim-bulletin_board";

$(() => {
  function identificationKeys() {
    const $form = $(".trustee_zone form");
    const $trusteeSlug = $("#trustee_slug", $form);
    const $trusteePublicKey = $("#trustee_public_key", $form);

    window.trusteeIdentificationKeys = new IdentificationKeys(
      $trusteeSlug.val(),
      $trusteePublicKey.val()
    );
    if (!window.trusteeIdentificationKeys.browserSupport) {
      $("#not_supported_browser").addClass("visible");
      return;
    }

    const $submit = $("#submit_identification_keys");
    const $generate = $("#generate_identification_keys");
    const $upload = $("#upload_identification_keys");

    $("button", $generate).on("click", () => {
      window.trusteeIdentificationKeys.
        generate().
        then(() => {
          $trusteePublicKey.val(
            JSON.stringify(window.trusteeIdentificationKeys.publicKey)
          );
          $submit.addClass("visible");
        }).
        catch(() => {
          alert($generate.data("error"));
        });
    });

    $("button.hollow", $submit).click(() => {
      $trusteePublicKey.val("");
      $submit.removeClass("visible");
    });

    $("button", $upload).click(() => {
      window.trusteeIdentificationKeys.
        upload().
        then(() => {
          $upload.addClass("hide");
        }).
        catch((errorMessage) => {
          alert($upload.data(errorMessage));
        });
    });

    window.trusteeIdentificationKeys.present((result) => {
      $upload.toggleClass("hide", result);
    });
  }

  $(document).ready(() => {
    identificationKeys();
  });
});
