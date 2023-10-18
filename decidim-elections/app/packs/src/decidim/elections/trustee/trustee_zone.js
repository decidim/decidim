/* eslint-disable require-jsdoc, no-alert, func-style */

import { IdentificationKeys } from "@decidim/decidim-bulletin_board";

$(() => {
  function identificationKeys() {
    const $form = $("#trustee_zone form");
    const $trusteeSlug = $("#trustee_slug", $form);
    const $trusteePublicKey = $("#trustee_public_key", $form);

    window.trusteeIdentificationKeys = new IdentificationKeys(
      $trusteeSlug.val(),
      $trusteePublicKey.val()
    );

    if (!window.trusteeIdentificationKeys.browserSupport) {
      $("#not_supported_browser").attr("hidden", false);
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
          $submit.attr("hidden", false);
          $generate.attr("hidden", true);
        }).
        catch(() => {
          alert($generate.data("error"));
        });
    });

    $("button", $submit).click(() => {
      $trusteePublicKey.val("");
      $submit.attr("hidden", true);
    });

    $("button", $upload).click(() => {
      window.trusteeIdentificationKeys.
        upload().
        then(() => {
          $upload.attr("hidden", true);
        }).
        catch((errorMessage) => {
          alert($upload.data(errorMessage));
        });
    });

    window.trusteeIdentificationKeys.present((result) => {
      $upload.attr("hidden", result);
    });
  }

  $(document).ready(() => {
    identificationKeys();
  });
});
