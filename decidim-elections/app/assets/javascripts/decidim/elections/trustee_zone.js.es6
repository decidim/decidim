/* eslint-disable require-jsdoc, prefer-template, func-style, id-length, no-use-before-define, init-declarations, no-invalid-this */
/* eslint no-unused-vars: ["error", { "args": "none" }] */

$(() => {
  function identificationKeys() {
    const div = $("#generate_identification_keys")
    $("form", div).submit((event) => {
      $("#trustee_public_key", div).val((Math.random()).toString(16).substr(2))
    });
  }

  $(document).ready((event) => {
    identificationKeys()
  });
});