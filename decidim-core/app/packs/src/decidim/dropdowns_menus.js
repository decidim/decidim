/* eslint-disable valid-jsdoc */

/**
 * @deprecated since feature/redesign
 *
 * This will apply some fixes for the Foundation dropdown menu element
 * according to W3C instructions at:
 * https://www.w3.org/TR/wai-aria-practices/examples/menu-button/menu-button-links.html
 *
 * NOTE:
 * This needs to run AFTER Foundation has been initialized because those
 * initializers will affect the drop down menu elements.
 */
export default function fixDropdownMenus() {
  $("[data-dropdown-menu]").each((_i, element) => {
    // This will break navigation on macOS VoiceOver app since it will let the
    // user to focus on the li element instead of the <a> element where we
    // actually need the focus to be in.
    $("li.is-dropdown-submenu-parent", element).removeAttr("aria-haspopup").removeAttr("aria-label");
    $("li.is-dropdown-submenu-parent > a:first", element).removeAttr("aria-label");
    // Foundation marks the wrong role for the submenu elements
    $("ul.is-dropdown-submenu", element).attr("role", "menu");
  })
}

// Ensure the first element is always focused when a dropdown is opened as
// this would not always happen when using a screen reader. If this is not
// done, the screen reader will stay quiet when the menu opens which can lead
// to the blind user not understanding the menu has opened.
$(() => {
  $("[data-dropdown-menu]").on("show.zf.dropdownMenu", (_i, element) => {
    $("li:first > a", element).focus();
  });
})
