$(() => {
  $(document).on("click", ".diff-view-by a.diff-view-mode", (event) => {
    event.preventDefault();
    const $target = $(event.target);
    $target.parents(".is-dropdown-submenu-parent").find("#diff-view-selected").text($target.text());

    if ($target.attr("id") === "diff-view-unified") {
      $(".row#diff_split").addClass("hide");
      $(".row#diff_unified").removeClass("hide");
    }
    if ($target.attr("id") === "diff-view-split") {
      $(".row#diff_unified").addClass("hide");
      $(".row#diff_split").removeClass("hide");
    }
  })
});
