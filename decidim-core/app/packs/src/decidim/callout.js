/**
 * Improves the accessibility of the callout messages for screen readers. Not
 * all screen readers would announce the callout alert contents after the page
 * reload without this.
 */

$(() => {
  const $callout = $('.callout[role="alert"]:first');
  if ($callout.length > 0) {
    setTimeout(() => {
      // The content insertion is to try to hint some of the screen readers
      // that the alert content has changed and needs to be announced.
      $callout.attr("tabindex", "0").focus().html(`${$callout.html()}&nbsp;`);
    }, 500);
  }
});
