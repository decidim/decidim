$(() => {
  // Ensure the first element is always focused when a dropdown is opened as
  // this would not always happen when using a screen reader. If this is not
  // done, the screen reader will stay quiet when the menu opens which can lead
  // to the blind user not understanding the menu has opened.
  $("[data-dropdown-menu]").on("show.zf.dropdownMenu", (_i, element) => {
    $("li:first > a", element).focus();
  });
});
