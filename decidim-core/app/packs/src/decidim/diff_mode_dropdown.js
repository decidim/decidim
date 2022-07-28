$(() => {
  const $allDiffViews = $(".row.diff_view");

  $(document).on("click", ".diff-view-by a.diff-view-mode", (event) => {
    event.preventDefault();
    const $target = $(event.target);
    const $container = $target.closest(".tabs-panel");
    const $unified = $container.find(".diff_view_unified")
    const $split = $container.find(".diff_view_split")
    const $selected = $target.parents(".is-dropdown-submenu-parent").find("#diff-view-selected");
    if ($selected.text().trim() === $target.text().trim()) {
      return;
    }

    $selected.text($target.text());

    if ($target.hasClass("diff-view-unified")) {
      $split.addClass("hide");
      $unified.removeClass("hide");
    }
    if ($target.hasClass("diff-view-split")) {
      $unified.addClass("hide");
      $split.removeClass("hide");
    }
  })
});